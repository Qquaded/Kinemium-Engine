return function(raylib: typeof(require("@raylib").lib), structs, game, theme)
	local windowRegistry = {}
	local module = {}
	local draggedWindow = nil
	local dragOffset = { x = 0, y = 0 }
	local Color3 = require("@Color3")
	local Enum = require("@EnumMap")
	local spring = require("@kispring")
	local KinemiumFontService = game:GetService("KinemiumFontService")

	local resizingWindow = nil
	local resizeSide = nil
	local resizeStart = vector.create(0, 0)
	local resizeMinSize = vector.create(200, 120)
	local resizeThreshold = 6
	local dragSpring = spring.new(1, 5)
	local vend = KinemiumFontService.GetDefaultFont()

	local windowAnimState = {}

	local FADE_DURATION = 0.18

	local shadowTexture, shadowSize
	if _G.IsHeadless then
		shadowTexture = buffer.create(16)
		shadowSize = vector.create(0, 0)
	else
		shadowTexture = raylib.LoadTexture("./src/assets/images/shadow.png")
		shadowSize = vector.create(buffer.readi32(shadowTexture, 4), buffer.readi32(shadowTexture, 8))
	end

	local MAC_BTN_RADIUS = 6
	local MAC_BTN_SPACING = 8
	local MAC_BTN_LEFT = 12
	local MAC_BTN_SYM_R = 2.5
	local MAC_TAB_PAD_X = 14
	local MAC_TAB_MIN_W = 80
	local MAC_STATUSBAR_H = 18
	local MAC_SEP_H = 1

	local TL_RED = Color3.new(0.988, 0.369, 0.333)
	local TL_YEL = Color3.new(0.988, 0.733, 0.173)
	local TL_GRN = Color3.new(0.259, 0.808, 0.388)
	local TL_UNFOC = Color3.new(0.612, 0.612, 0.612)
	local TL_SYM_R = Color3.new(0.600, 0.098, 0.067)
	local TL_SYM_Y = Color3.new(0.576, 0.361, 0.008)
	local TL_SYM_G = Color3.new(0.047, 0.427, 0.149)

	local BLACK = Color3.new(0, 0, 0)
	local WHITE = Color3.new(1, 1, 1)

	local function wcol(wcfg, key, fallback)
		return wcfg[key] or fallback
	end

	local function wval(wcfg, key, fallback)
		local v = wcfg[key]
		return v ~= nil and v or fallback
	end

	local function shiftBrightness(c, delta)
		return Color3.new(math.clamp(c.R + delta, 0, 1), math.clamp(c.G + delta, 0, 1), math.clamp(c.B + delta, 0, 1))
	end

	local function lerp(a, b, t)
		return a + (b - a) * math.clamp(t, 0, 1)
	end

	local function getOrCreateAnim(window)
		if not windowAnimState[window.id] then
			windowAnimState[window.id] = {
				titlebarHover = 0,
				closeHover = 0,
				minHover = 0,
				maxHover = 0,
				fadeAlpha = 1,
				closing = false,
				closeTimer = 0,
				minimizeAnim = 0,
			}
		end
		return windowAnimState[window.id]
	end

	local function getResizeSide(window, mousePos)
		if window.Minimized then
			return nil
		end
		local sides = {}
		local wx, wy, ww, wh = window.x, window.y, window.width, window.height
		local t = resizeThreshold
		if math.abs(mousePos.x - wx) <= t then
			table.insert(sides, "left")
		elseif math.abs(mousePos.x - (wx + ww)) <= t then
			table.insert(sides, "right")
		end
		if math.abs(mousePos.y - wy) <= t then
			table.insert(sides, "top")
		elseif math.abs(mousePos.y - (wy + wh)) <= t then
			table.insert(sides, "bottom")
		end
		return #sides > 0 and sides or nil
	end

	local function setCursorForResize(sides)
		if not sides then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			return
		end
		local hasH, hasV = false, false
		for _, s in ipairs(sides) do
			if s == "left" or s == "right" then
				hasH = true
			end
			if s == "top" or s == "bottom" then
				hasV = true
			end
		end
		if hasH and hasV then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NWSE.Value)
		elseif hasH then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value)
		elseif hasV then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NS.Value)
		end
	end

	local function getWindowHitHeight(window)
		if window.Minimized then
			return window._titleBarH
		end
		return window.height
	end

	local function isMouseOverWindow(window, mousePos)
		return mousePos.x >= window.x
			and mousePos.x <= window.x + window.width
			and mousePos.y >= window.y
			and mousePos.y <= window.y + getWindowHitHeight(window)
	end

	local function measureTabWidth(text, fontSize)
		local m = raylib.MeasureTextEx(vend, text, fontSize, 1)
		return m.x + MAC_TAB_PAD_X * 2
	end

	local function getTabBarHeight(window)
		if window.Minimized then
			return 0
		end
		return (window.tabs and #window.tabs > 0) and window._tabBarH or 0
	end

	local function getTabAtPosition(window, mousePos, fontSize)
		if window.Minimized then
			return nil
		end
		if not window.tabs or #window.tabs == 0 then
			return nil
		end
		local titleH = (window.headerRender ~= false) and window._titleBarH or 0
		local tabBarY = window.y + titleH
		if mousePos.y < tabBarY or mousePos.y > tabBarY + window._tabBarH then
			return nil
		end
		local curX = window.x
		for i, tab in ipairs(window.tabs) do
			local tw = math.max(measureTabWidth(tab.name, fontSize), MAC_TAB_MIN_W)
			if mousePos.x >= curX and mousePos.x <= curX + tw then
				return i
			end
			curX = curX + tw
		end
		return nil
	end

	local function isMouseOverTitlebar(window, mousePos)
		if window.headerRender == false then
			return false
		end
		return mousePos.x >= window.x
			and mousePos.x <= window.x + window.width
			and mousePos.y >= window.y
			and mousePos.y <= window.y + window._titleBarH
	end

	local function trafficLightCentres(window)
		local cy = window.y + window._titleBarH / 2
		local cx1 = window.x + MAC_BTN_LEFT
		local cx2 = cx1 + MAC_BTN_RADIUS * 2 + MAC_BTN_SPACING
		local cx3 = cx2 + MAC_BTN_RADIUS * 2 + MAC_BTN_SPACING
		return cx1, cx2, cx3, cy
	end

	local function isMouseOverTrafficLight(window, mousePos, which)
		local cx1, cx2, cx3, cy = trafficLightCentres(window)
		local cx = which == 1 and cx1 or which == 2 and cx2 or cx3
		local dx, dy = mousePos.x - cx, mousePos.y - cy
		return (dx * dx + dy * dy) <= (MAC_BTN_RADIUS + 3) ^ 2
	end

	module.OutlineColor = TL_GRN
	module.OutlineTransparency = 1
	module.dragged = function() end
	module.stepped = function() end
	module.dragEnd = function() end
	module.backgroundDrawed = function() end
	module.focused = function() end
	module.unfocused = function() end
	module.tabChanged = function() end
	module.windowClosed = function() end
	module.windowMinimized = function() end
	module.windowUnminimized = function() end
	module.windowMaximized = function() end
	module.windowUnmaximized = function() end

	local anyWindowFocused = false

	local function isMouseInViewport(mousePos)
		local sw, sh = raylib.GetRenderWidth(), raylib.GetRenderHeight()
		local toolbarH = 160
		return mousePos.x >= 0
			and mousePos.x <= sw - 400
			and mousePos.y >= toolbarH
			and mousePos.y <= sh - toolbarH - sh * 0.2
	end

	function module.create(data: {
		headerRender: boolean?,
		step: () -> (),
		title: string,
		x: number,
		y: number,
		width: number,
		height: number,
		enabled: boolean?,
		DisableClipping: boolean?,
		showStatusBar: boolean?,
		statusText: string?,
		parent: { x: number, y: number, width: number, height: number }?,
		tabs: { { name: string, render: (window: any) -> () } }?,
		defaultTab: (number | boolean)?,
	})
		local initialTab
		if data.tabs and #data.tabs > 0 then
			if data.defaultTab == false then
				initialTab = nil
			elseif data.defaultTab ~= nil then
				initialTab = data.defaultTab
			else
				initialTab = 1
			end
		end

		local window = {
			title = data.title,
			x = data.x,
			y = data.y,
			width = data.width,
			height = data.height,
			id = #windowRegistry + 1,
			headerRender = data.headerRender,
			DisableClipping = data.DisableClipping,
			stepped = data.step,
			enabled = data.enabled ~= false,
			Closed = false,
			Focused = false,
			IsDragging = false,
			Minimized = false,
			Maximized = false,
			scrollOffset = vector.create(0, 0),
			showStatusBar = data.showStatusBar or false,
			statusText = data.statusText or "",
			parent = data.parent or nil,
			tabs = data.tabs or nil,
			activeTab = initialTab,
			focused = function() end,
			unfocused = function() end,
			_titleBarH = 28,
			_tabBarH = 28,
			_savedX = data.x,
			_savedY = data.y,
			_savedW = data.width,
			_savedH = data.height,
		}
		table.insert(windowRegistry, window)
		getOrCreateAnim(window)

		function window:MoveTo(x, y)
			window.x = x
			window.y = y
			if not window.Maximized then
				window._savedX = x
				window._savedY = y
			end
		end

		function window:Resize(x, y)
			window.width = math.max(x, resizeMinSize.x)
			window.height = math.max(y, resizeMinSize.y)
			if not window.Maximized then
				window._savedW = window.width
				window._savedH = window.height
			end
		end

		function window:Close()
			local anim = getOrCreateAnim(window)
			if not anim.closing then
				anim.closing = true
				anim.closeTimer = 0
			end
		end

		function window:Open()
			local anim = getOrCreateAnim(window)
			window.Closed = false
			anim.closing = false
			anim.closeTimer = 0
			anim.fadeAlpha = 1
		end

		function window:Minimize()
			if not window.Minimized then
				window.Minimized = true
				if window.Maximized then
					window:Unmaximize()
				end
				module.windowMinimized(window)
			end
		end

		function window:Unminimize()
			if window.Minimized then
				window.Minimized = false
				module.windowUnminimized(window)
			end
		end

		function window:ToggleMinimize()
			if window.Minimized then
				window:Unminimize()
			else
				window:Minimize()
			end
		end

		function window:Maximize()
			if not window.Maximized then
				window._savedX = window.x
				window._savedY = window.y
				window._savedW = window.width
				window._savedH = window.height

				local parent = window.parent
				if parent then
					window.x = parent.x
					window.y = parent.y
					window.width = parent.width
					window.height = parent.height
				else
					window.x = 0
					window.y = 0
					window.width = raylib.GetRenderWidth()
					window.height = raylib.GetRenderHeight()
				end

				window.Maximized = true
				if window.Minimized then
					window.Minimized = false
				end
				module.windowMaximized(window)
			end
		end

		function window:Unmaximize()
			if window.Maximized then
				window.x = window._savedX
				window.y = window._savedY
				window.width = window._savedW
				window.height = window._savedH
				window.Maximized = false
				module.windowUnmaximized(window)
			end
		end

		function window:ToggleMaximize()
			if window.Maximized then
				window:Unmaximize()
			else
				window:Maximize()
			end
		end

		function window:SetStatus(t)
			window.statusText = t or ""
		end

		function window:SetTab(index)
			if index == nil then
				local prev = window.activeTab
				window.activeTab = nil
				if prev ~= nil then
					module.tabChanged(window, nil, nil)
				end
			elseif window.tabs and index >= 1 and index <= #window.tabs then
				local prev = window.activeTab
				window.activeTab = index
				if prev ~= index then
					module.tabChanged(window, index, window.tabs[index])
				end
			end
		end

		function window:SetTabByName(name)
			if window.tabs then
				for i, tab in ipairs(window.tabs) do
					if tab.name == name then
						window:SetTab(i)
						return
					end
				end
			end
		end

		return window
	end

	function module.update(dt, selectedTheme)
		local wcfg = selectedTheme and selectedTheme.window or {}

		local titleH = wval(wcfg, "TitleHeight", 28)
		local tabH = wval(wcfg, "TitleHeight", 28)
		for _, w in pairs(windowRegistry) do
			w._titleBarH = titleH
			w._tabBarH = tabH
		end

		for _, w in pairs(windowRegistry) do
			if not w.enabled then
				continue
			end
			local anim = getOrCreateAnim(w)
			if anim.closing then
				anim.closeTimer = anim.closeTimer + dt
				anim.fadeAlpha = math.max(0, 1 - (anim.closeTimer / FADE_DURATION))
				if anim.closeTimer >= FADE_DURATION then
					w.Closed = true
					anim.closing = false
					anim.fadeAlpha = 0
					module.windowClosed(w)
				end
			end
		end

		local mousePos = raylib.GetMousePosition()
		local mousePressed = raylib.IsMouseButtonPressed(0)
		local mouseRightPressed = raylib.IsMouseButtonPressed(1)
		local mouseDown = raylib.IsMouseButtonDown(0)
		local mouseReleased = raylib.IsMouseButtonReleased(0)

		local tabFontSize = wval(wcfg, "TitleTextSize", 13)

		local speed = 12 * dt
		for _, w in pairs(windowRegistry) do
			if w.Closed or not w.enabled then
				continue
			end
			local anim = getOrCreateAnim(w)
			anim.titlebarHover = lerp(anim.titlebarHover, isMouseOverTitlebar(w, mousePos) and 1 or 0, speed)
			anim.closeHover = lerp(anim.closeHover, isMouseOverTrafficLight(w, mousePos, 1) and 1 or 0, speed * 1.5)
			anim.minHover = lerp(anim.minHover, isMouseOverTrafficLight(w, mousePos, 2) and 1 or 0, speed * 1.5)
			anim.maxHover = lerp(anim.maxHover, isMouseOverTrafficLight(w, mousePos, 3) and 1 or 0, speed * 1.5)
		end

		local hoveredWindow = nil
		for i = #windowRegistry, 1, -1 do
			local w = windowRegistry[i]
			local anim = getOrCreateAnim(w)
			if not w.Closed and not anim.closing and w.enabled and isMouseOverWindow(w, mousePos) then
				hoveredWindow = w
				break
			end
		end

		if mouseRightPressed == 1 then
			if hoveredWindow then
				game.Stop3DInput = true
				anyWindowFocused = true
			elseif isMouseInViewport(mousePos) then
				game.Stop3DInput = false
				anyWindowFocused = false
				for _, w in pairs(windowRegistry) do
					if w.Focused then
						w.Focused = false
						w.unfocused(w)
						module.unfocused(w)
					end
				end
			end
		end

		if mousePressed == 1 then
			for i = #windowRegistry, 1, -1 do
				local w = windowRegistry[i]
				local anim = getOrCreateAnim(w)
				if w.Closed or anim.closing or not w.enabled or w.headerRender == false then
					continue
				end
				if isMouseOverTrafficLight(w, mousePos, 1) then
					w:Close()
					continue
				elseif isMouseOverTrafficLight(w, mousePos, 2) then
					w:ToggleMinimize()
					continue
				elseif isMouseOverTrafficLight(w, mousePos, 3) then
					w:ToggleMaximize()
					continue
				end
			end

			for i = #windowRegistry, 1, -1 do
				local w = windowRegistry[i]
				local anim = getOrCreateAnim(w)
				if not w.Closed and not anim.closing and w.enabled then
					local ct = getTabAtPosition(w, mousePos, tabFontSize)
					if ct then
						w:SetTab(ct)
						table.remove(windowRegistry, i)
						table.insert(windowRegistry, w)
						break
					end
				end
			end

			local focusedThisClick = false
			for _, w in pairs(windowRegistry) do
				local anim = getOrCreateAnim(w)
				if w.Closed or anim.closing or not w.enabled then
					continue
				end
				if w == hoveredWindow then
					if not w.Focused then
						w.Focused = true
						w.focused(w)
						module.focused(w)
					end
					focusedThisClick = true
				else
					if w.Focused then
						w.Focused = false
						w.unfocused(w)
						module.unfocused(w)
					end
				end
			end
			if focusedThisClick then
				game.Stop3DInput = true
				anyWindowFocused = true
			elseif isMouseInViewport(mousePos) then
				game.Stop3DInput = false
				anyWindowFocused = false
			end
		end

		if mousePressed == 1 and not draggedWindow and not resizingWindow then
			for i = #windowRegistry, 1, -1 do
				local w = windowRegistry[i]
				local anim = getOrCreateAnim(w)
				if w.Closed or anim.closing or not w.enabled then
					continue
				end
				local titleBarH = (w.headerRender ~= false) and w._titleBarH or 0
				if
					mousePos.x >= w.x
					and mousePos.x <= w.x + w.width
					and mousePos.y >= w.y
					and mousePos.y <= w.y + titleBarH
					and not isMouseOverTrafficLight(w, mousePos, 1)
					and not isMouseOverTrafficLight(w, mousePos, 2)
					and not isMouseOverTrafficLight(w, mousePos, 3)
					and not getTabAtPosition(w, mousePos, tabFontSize)
					and not w.Maximized
				then
					draggedWindow = w
					dragOffset.x = mousePos.x - w.x
					dragOffset.y = mousePos.y - w.y
					table.remove(windowRegistry, i)
					table.insert(windowRegistry, w)
					break
				end
			end
			if not draggedWindow then
				for i = #windowRegistry, 1, -1 do
					local w = windowRegistry[i]
					local anim = getOrCreateAnim(w)
					if w.Closed or anim.closing or not w.enabled or w.Minimized or w.Maximized then
						continue
					end
					local sides = getResizeSide(w, mousePos)
					if sides then
						resizingWindow = w
						resizeSide = sides
						resizeStart = vector.create(mousePos.x, mousePos.y)
						table.remove(windowRegistry, i)
						table.insert(windowRegistry, w)
						break
					end
				end
			end
		end

		if mouseDown == 1 then
			if draggedWindow then
				raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_ALL.Value)
				draggedWindow.x = mousePos.x - dragOffset.x
				draggedWindow.y = mousePos.y - dragOffset.y
				if not draggedWindow.Maximized then
					draggedWindow._savedX = draggedWindow.x
					draggedWindow._savedY = draggedWindow.y
				end
				draggedWindow.IsDragging = true
				module.dragged(draggedWindow)
			elseif resizingWindow then
				local dx, dy = mousePos.x - resizeStart.x, mousePos.y - resizeStart.y
				for _, side in ipairs(resizeSide) do
					if side == "left" then
						resizingWindow.x = resizingWindow.x + dx
						resizingWindow.width = resizingWindow.width - dx
					elseif side == "right" then
						resizingWindow.width = resizingWindow.width + dx
					elseif side == "top" then
						resizingWindow.y = resizingWindow.y + dy
						resizingWindow.height = resizingWindow.height - dy
					elseif side == "bottom" then
						resizingWindow.height = resizingWindow.height + dy
					end
				end
				resizingWindow.width = math.max(resizingWindow.width, resizeMinSize.x)
				resizingWindow.height = math.max(resizingWindow.height, resizeMinSize.y)
				resizingWindow._savedW = resizingWindow.width
				resizingWindow._savedH = resizingWindow.height
				setCursorForResize(resizeSide)
				resizeStart = vector.create(mousePos.x, mousePos.y)
			end
		else
			if not draggedWindow and not resizingWindow then
				local anySide = false
				for i = #windowRegistry, 1, -1 do
					local w = windowRegistry[i]
					local anim = getOrCreateAnim(w)
					if w.Closed or anim.closing or not w.enabled or w.Minimized or w.Maximized then
						continue
					end
					local sides = getResizeSide(w, mousePos)
					if sides then
						setCursorForResize(sides)
						anySide = true
						break
					end
				end
				if not anySide then
					raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
				end
			end
		end

		if mouseReleased == 1 then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			if draggedWindow then
				draggedWindow.IsDragging = false
				module.dragEnd(draggedWindow)
			end
			draggedWindow = nil
			resizingWindow = nil
			resizeSide = nil
		end
	end

	function module.draw(dt, selectedTheme)
		dragSpring:step(dt)

		local wcfg = selectedTheme and selectedTheme.window or {}

		local bodyColor = wcol(wcfg, "BackgroundColor", Color3.new(0, 0, 0))
		local bodyTransp = wval(wcfg, "BackgroundTransparency", 0.1)
		local titlebarColor = wcol(wcfg, "SecondaryBackgroundColor", Color3.new(0.05, 0.05, 0.05))
		local titlebarTr = wval(wcfg, "TitleBackgroundTransparency", 0)
		local titleColor = wcol(wcfg, "TitleColor", WHITE)
		local accentColor = wcol(wcfg, "DragColor", Color3.new(1, 0.549, 0))
		local shadowColor = wcol(wcfg, "ShadowColor", BLACK)
		local shadowTr = wval(wcfg, "ShadowTransparency", 0.98)
		local shadowsOn = wval(wcfg, "ShadowsEnabled", true)
		local titleFontSz = wval(wcfg, "TitleTextSize", 13)
		local titleH = wval(wcfg, "TitleHeight", 28)
		local cornerPx = wval(wcfg, "CornerRadius", 5)

		local isTitleDark = (titlebarColor.R + titlebarColor.G + titlebarColor.B) / 3 < 0.5
		local titlebarUnfocused = shiftBrightness(titlebarColor, isTitleDark and 0.04 or -0.04)
		local titleColorDim = Color3.new(
			titleColor.R * 0.5 + bodyColor.R * 0.5,
			titleColor.G * 0.5 + bodyColor.G * 0.5,
			titleColor.B * 0.5 + bodyColor.B * 0.5
		)

		local tabActiveColor = titlebarColor
		local tabInactiveColor = shiftBrightness(titlebarColor, isTitleDark and -0.03 or 0.03)
		local tabTextColor = titleColor
		local tabTextDimColor = Color3.new(
			titleColor.R * 0.45 + titlebarColor.R * 0.55,
			titleColor.G * 0.45 + titlebarColor.G * 0.55,
			titleColor.B * 0.45 + titlebarColor.B * 0.55
		)

		local sepColor = shiftBrightness(titlebarColor, isTitleDark and 0.10 or -0.10)
		local cornerFrac = math.clamp(cornerPx / 200, 0, 0.5)
		local tabBarH = titleH

		module.OutlineColor = accentColor

		for _, wd in pairs(windowRegistry) do
			local anim = getOrCreateAnim(wd)
			if wd.Closed or not wd.enabled then
				continue
			end
			if not anim.closing and anim.fadeAlpha <= 0 then
				continue
			end

			local alpha = anim.fadeAlpha
			local wx, wy, ww = wd.x, wd.y, wd.width
			local focused = wd.Focused

			local drawH = wd.Minimized and titleH or wd.height

			local function tr(base)
				return 1 - (1 - base) * alpha
			end

			local btnRed = focused and TL_RED or TL_UNFOC
			local btnYel = focused and TL_YEL or TL_UNFOC
			local btnGrn = focused and TL_GRN or TL_UNFOC

			local curTitlebarColor = focused and titlebarColor or titlebarUnfocused
			local curTitleColor = focused and titleColor or titleColorDim
			local curBodyTransp = wd.IsDragging and 0 or bodyTransp

			if shadowsOn then
				local shadowAlpha = focused and (1 - shadowTr) * 1.4 or (1 - shadowTr)
				shadowAlpha = shadowAlpha * alpha
				local spread = focused and 18 or 10
				local yBias = focused and 10 or 4
				raylib.DrawTexturePro(
					shadowTexture,
					structs.Rectangle:new({ x = 0, y = 0, width = shadowSize.x, height = shadowSize.y }),
					structs.Rectangle:new({
						x = wx - spread * 9,
						y = wy - spread * 5 + yBias,
						width = ww + spread * 18,
						height = drawH + spread * 14,
					}),
					vector.create(0, 0),
					0,
					shadowColor:ToRaylib(1 - math.clamp(shadowAlpha, 0, 1))
				)
			end

			local mainRect = structs.Rectangle:new({ x = wx, y = wy, width = ww, height = drawH })

			raylib.DrawRectangleRounded(mainRect, cornerFrac, 20, bodyColor:ToRaylib(tr(curBodyTransp)))
			module.backgroundDrawed(wd)

			local titleBarH = 0
			if wd.headerRender ~= false then
				titleBarH = titleH

				if not wd.Minimized then
					raylib.DrawLineEx(
						vector.create(wx, wy + titleBarH),
						vector.create(wx + ww, wy + titleBarH),
						MAC_SEP_H,
						sepColor:ToRaylib(tr(titlebarTr))
					)
				end

				local cx1, cx2, cx3, cy = trafficLightCentres(wd)
				local showSymbols = anim.titlebarHover > 0.25 and focused

				local function tlColor(base)
					return Color3.new(base.R, base.G, base.B):ToRaylib(1 - alpha)
				end

				raylib.DrawCircleV(vector.create(cx1, cy), MAC_BTN_RADIUS, tlColor(btnRed))
				if showSymbols then
					local r = MAC_BTN_SYM_R
					local sc = TL_SYM_R:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx1 - r, cy - r), vector.create(cx1 + r, cy + r), 1.2, sc)
					raylib.DrawLineEx(vector.create(cx1 + r, cy - r), vector.create(cx1 - r, cy + r), 1.2, sc)
				end

				raylib.DrawCircleV(vector.create(cx2, cy), MAC_BTN_RADIUS, tlColor(btnYel))
				if showSymbols then
					local r = MAC_BTN_SYM_R
					local sc = TL_SYM_Y:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx2 - r, cy), vector.create(cx2 + r, cy), 1.2, sc)
				end

				raylib.DrawCircleV(vector.create(cx3, cy), MAC_BTN_RADIUS, tlColor(btnGrn))
				if showSymbols then
					local r = MAC_BTN_SYM_R - 0.5
					local sc = TL_SYM_G:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx3 - r, cy + r), vector.create(cx3, cy), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 - r, cy), vector.create(cx3 - r, cy + r), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 + r, cy - r), vector.create(cx3, cy), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 + r, cy), vector.create(cx3 + r, cy - r), 1.1, sc)
				end

				local tm = raylib.MeasureTextEx(vend, wd.title, titleFontSz, 1)
				raylib.DrawTextEx(
					vend,
					wd.title,
					vector.create(wx + (ww - tm.x) / 2, wy + (titleBarH - titleFontSz) / 2),
					titleFontSz,
					1,
					curTitleColor:ToRaylib(1 - alpha)
				)

				if wd.Minimized then
					local minimizedLabel = "Minimized"
					local leftEdge = wx + MAC_BTN_LEFT + (MAC_BTN_RADIUS * 2 + MAC_BTN_SPACING) * 3 + 8
					raylib.DrawTextEx(
						vend,
						minimizedLabel,
						vector.create(leftEdge, wy + (titleBarH - (titleFontSz - 2)) / 2),
						titleFontSz - 2,
						1,
						titleColorDim:ToRaylib(tr(0.4))
					)
				end

				wd.titleRect = { height = titleBarH, width = ww, x = wx, y = wy }
			end

			if not wd.Minimized then
				local hasTabs = wd.tabs and #wd.tabs > 0
				local tabAreaH = hasTabs and tabBarH or 0

				if hasTabs then
					local tabBarY = wy + titleBarH

					raylib.DrawRectangleRec(
						structs.Rectangle:new({ x = wx, y = tabBarY, width = ww, height = tabAreaH }),
						tabInactiveColor:ToRaylib(tr(titlebarTr))
					)

					local curX = wx
					for i, tab in ipairs(wd.tabs) do
						local tw = math.max(measureTabWidth(tab.name, titleFontSz), MAC_TAB_MIN_W)
						local isActive = wd.activeTab == i

						raylib.DrawRectangleRec(
							structs.Rectangle:new({ x = curX, y = tabBarY, width = tw, height = tabAreaH }),
							(isActive and tabActiveColor or tabInactiveColor):ToRaylib(tr(titlebarTr))
						)

						if isActive then
							raylib.DrawRectangleRec(
								structs.Rectangle:new({ x = curX, y = tabBarY, width = tw, height = 2 }),
								accentColor:ToRaylib(tr(wval(wcfg, "DragOutlineTransparency", 0)))
							)
							raylib.DrawLineEx(
								vector.create(curX + 1, tabBarY + tabAreaH),
								vector.create(curX + tw - 1, tabBarY + tabAreaH),
								MAC_SEP_H + 0.5,
								tabActiveColor:ToRaylib(tr(titlebarTr))
							)
						end

						if i > 1 then
							raylib.DrawLineEx(
								vector.create(curX, tabBarY + 5),
								vector.create(curX, tabBarY + tabAreaH - 5),
								0.5,
								sepColor:ToRaylib(tr(titlebarTr))
							)
						end

						local lm = raylib.MeasureTextEx(vend, tab.name, titleFontSz, 1)
						raylib.DrawTextEx(
							vend,
							tab.name,
							vector.create(curX + (tw - lm.x) / 2, tabBarY + (tabAreaH - titleFontSz) / 2),
							titleFontSz,
							1,
							(isActive and tabTextColor or tabTextDimColor):ToRaylib(1 - alpha)
						)

						curX = curX + tw
					end

					raylib.DrawLineEx(
						vector.create(wx, tabBarY + tabAreaH),
						vector.create(wx + ww, tabBarY + tabAreaH),
						MAC_SEP_H,
						sepColor:ToRaylib(tr(titlebarTr))
					)
				end

				local statusBarH = wd.showStatusBar and MAC_STATUSBAR_H or 0
				if wd.showStatusBar then
					local sbY = wy + wd.height - statusBarH
					raylib.DrawRectangleRec(
						structs.Rectangle:new({ x = wx, y = sbY, width = ww, height = statusBarH }),
						curTitlebarColor:ToRaylib(tr(titlebarTr))
					)
					raylib.DrawLineEx(
						vector.create(wx, sbY),
						vector.create(wx + ww, sbY),
						MAC_SEP_H,
						sepColor:ToRaylib(tr(titlebarTr))
					)
					if wd.statusText and wd.statusText ~= "" then
						local statusFontSz = math.max(titleFontSz - 2, 10)
						raylib.DrawTextEx(
							vend,
							wd.statusText,
							vector.create(wx + 8, sbY + (statusBarH - statusFontSz) / 2),
							statusFontSz,
							1,
							curTitleColor:ToRaylib(tr(focused and 0.35 or 0.55))
						)
					end
				end

				raylib.DrawRectangleRoundedLinesEx(mainRect, cornerFrac, 20, 0.75, sepColor:ToRaylib(tr(titlebarTr)))

				if wd.IsDragging then
					local dragOutRect =
						structs.Rectangle:new({ x = wx - 1, y = wy - 1, width = ww + 2, height = wd.height + 2 })
					raylib.DrawRectangleRoundedLinesEx(
						dragOutRect,
						cornerFrac,
						20,
						1.5,
						accentColor:ToRaylib(tr(wval(wcfg, "DragOutlineTransparency", 0)))
					)
				end
			else
				raylib.DrawRectangleRoundedLinesEx(mainRect, cornerFrac, 20, 0.75, sepColor:ToRaylib(tr(titlebarTr)))
			end

			if not anim.closing and not wd.Minimized then
				local hasTabs = wd.tabs and #wd.tabs > 0
				local tabAreaH = hasTabs and tabBarH or 0
				local statusBarH = wd.showStatusBar and MAC_STATUSBAR_H or 0
				local contentOffsetY = titleBarH + tabAreaH
				local contentH = wd.height - contentOffsetY - statusBarH

				if not wd.DisableClipping then
					raylib.BeginScissorMode(wx, wy + contentOffsetY, ww, contentH)
				end

				if hasTabs and wd.activeTab then
					local activeTab = wd.tabs[wd.activeTab]
					if activeTab and activeTab.render then
						activeTab.render(wd)
					end
				end

				module.stepped(wd, dt)

				if not wd.DisableClipping then
					raylib.EndScissorMode()
				end

				if wd.stepped then
					wd.stepped(wd, dt)
				end
			elseif wd.stepped and not anim.closing then
				if not wd.Minimized then
					wd.stepped(wd, dt)
				end
			end
		end
	end

	module.dragspring = dragSpring
	return module
end
