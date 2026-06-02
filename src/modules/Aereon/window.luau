return function(raylib: typeof(require("@raylib").lib), structs, game, theme)
	local gui = require("./component/lib")
	local arect = require("@arect")
	local windowRegistry = {}
	local module = {}
	local draggedWindow = nil
	local dragOffset = { x = 0, y = 0 }
	local Color3 = require("@Color3")
	local Enum = require("@EnumMap")
	local MouseCursor = require("@Kinemium.MouseCursor")
	local spring = require("@kispring")
	local KinemiumFontService = game:GetService("KinemiumFontService")
	local zembed = require("@zembed")

	-- Global registries across all window systems (prevents click-through)
	if not _G.__aereon_allWindows then
		_G.__aereon_allWindows = {}
	end
	if not _G.__aereon_blockInput then
		_G.__aereon_blockInput = false
	end
	if not _G.__aereon_topWindow then
		_G.__aereon_topWindow = nil
	end
	if not _G.__aereon_scissorStack then
		_G.__aereon_scissorStack = {}
	end

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
		shadowTexture = raylib.LoadTexture(zembed.AssetPath("kineasset://images/shadow.png"))
		shadowSize = vector.create(buffer.readi32(shadowTexture, 4), buffer.readi32(shadowTexture, 8))
	end

	-- Traffic light button layout constants
	local BTN_RADIUS = 6
	local BTN_SPACING = 8
	local BTN_LEFT = 12
	local BTN_SYM_R = 2.5
	local TAB_PAD_X = 14
	local TAB_MIN_W = 80
	local STATUSBAR_H = 18
	local SEP_H = 1

	-- Traffic light colours
	local TL_RED = Color3.new(0.988, 0.369, 0.333)
	local TL_YEL = Color3.new(0.988, 0.733, 0.173)
	local TL_GRN = Color3.new(0.259, 0.808, 0.388)
	local TL_UNFOC = Color3.new(0.612, 0.612, 0.612)
	local TL_SYM_R = Color3.new(0.600, 0.098, 0.067)
	local TL_SYM_Y = Color3.new(0.576, 0.361, 0.008)
	local TL_SYM_G = Color3.new(0.047, 0.427, 0.149)

	local BLACK = Color3.new(0, 0, 0)
	local WHITE = Color3.new(1, 1, 1)

	--  Helpers

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

	--  Geometry helpers

	local function getWindowHitHeight(window)
		return window.Minimized and window._titleBarH or window.height
	end

	local function isMouseOverWindow(window, mousePos)
		return mousePos.x >= window.x
			and mousePos.x <= window.x + window.width
			and mousePos.y >= window.y
			and mousePos.y <= window.y + getWindowHitHeight(window)
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
		local cx1 = window.x + BTN_LEFT
		local cx2 = cx1 + BTN_RADIUS * 2 + BTN_SPACING
		local cx3 = cx2 + BTN_RADIUS * 2 + BTN_SPACING
		return cx1, cx2, cx3, cy
	end

	local function isMouseOverTrafficLight(window, mousePos, which)
		local cx1, cx2, cx3, cy = trafficLightCentres(window)
		local cx = which == 1 and cx1 or which == 2 and cx2 or cx3
		local dx, dy = mousePos.x - cx, mousePos.y - cy
		return (dx * dx + dy * dy) <= (BTN_RADIUS + 3) ^ 2
	end

	local function getResizeSide(window, mousePos)
		if window.Minimized then
			return nil
		end
		local sides = {}
		local t = resizeThreshold

		-- Horizontal check - within vertical bounds of window
		local inVerticalBounds = mousePos.y >= window.y - t and mousePos.y <= window.y + window.height + t
		local isLeft = inVerticalBounds and (math.abs(mousePos.x - window.x) <= t)
		local isRight = inVerticalBounds and (math.abs(mousePos.x - (window.x + window.width)) <= t)

		-- Vertical check - within horizontal bounds of window
		local inHorizontalBounds = mousePos.x >= window.x - t and mousePos.x <= window.x + window.width + t
		local isTop = inHorizontalBounds and (math.abs(mousePos.y - window.y) <= t)
		local isBottom = inHorizontalBounds and (math.abs(mousePos.y - (window.y + window.height)) <= t)

		-- Prioritize corner resizes (both H and V)
		if isLeft and isTop then
			table.insert(sides, "left")
			table.insert(sides, "top")
		elseif isLeft and isBottom then
			table.insert(sides, "left")
			table.insert(sides, "bottom")
		elseif isRight and isTop then
			table.insert(sides, "right")
			table.insert(sides, "top")
		elseif isRight and isBottom then
			table.insert(sides, "right")
			table.insert(sides, "bottom")
		-- Then single-side resizes
		elseif isLeft then
			table.insert(sides, "left")
		elseif isRight then
			table.insert(sides, "right")
		elseif isTop then
			table.insert(sides, "top")
		elseif isBottom then
			table.insert(sides, "bottom")
		end

		return #sides > 0 and sides or nil
	end

	local function setCursorForResize(sides)
		if not sides then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			return
		end

		local hasLeft, hasRight, hasTop, hasBottom = false, false, false, false
		for _, s in ipairs(sides) do
			if s == "left" then
				hasLeft = true
			elseif s == "right" then
				hasRight = true
			elseif s == "top" then
				hasTop = true
			elseif s == "bottom" then
				hasBottom = true
			end
		end

		if (hasLeft and hasTop) or (hasRight and hasBottom) then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NWSE.Value)
		elseif (hasRight and hasTop) or (hasLeft and hasBottom) then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NESW.Value)
		elseif hasLeft or hasRight then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value)
		elseif hasTop or hasBottom then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NS.Value)
		end
	end

	local function measureTabWidth(text, fontSize)
		return raylib.MeasureTextEx(vend, text, fontSize, 1).x + TAB_PAD_X * 2
	end

	local function getTabAtPosition(window, mousePos, fontSize)
		if window.Minimized or not window.tabs or #window.tabs == 0 then
			return nil
		end
		local titleH = (window.headerRender ~= false) and window._titleBarH or 0
		local tabBarY = window.y + titleH
		if mousePos.y < tabBarY or mousePos.y > tabBarY + window._tabBarH then
			return nil
		end
		local curX = window.x
		for i, tab in ipairs(window.tabs) do
			local tw = math.max(measureTabWidth(tab.name, fontSize), TAB_MIN_W)
			if mousePos.x >= curX and mousePos.x <= curX + tw then
				return i
			end
			curX = curX + tw
		end
		return nil
	end

	local function isMouseInViewport(mousePos)
		local sw, sh = raylib.GetRenderWidth(), raylib.GetRenderHeight()
		local toolbarH = 160
		return mousePos.x >= 0
			and mousePos.x <= sw - 400
			and mousePos.y >= toolbarH
			and mousePos.y <= sh - toolbarH - sh * 0.2
	end

	--  Module events (overridable callbacks)

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

	--  Window creation

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
			Draggable = data.Draggable or true,
			Resizable = data.Resizable or true,
			IsDragging = false,
			Minimized = data.Minimized or false,
			Maximized = data.Maximized or false,
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
		table.insert(_G.__aereon_allWindows, window)
		getOrCreateAnim(window)

		function window:MoveTo(x, y)
			self.x, self.y = x, y
			if not self.Maximized then
				self._savedX, self._savedY = x, y
			end
		end

		function window:Resize(w, h)
			self.width = math.max(w, resizeMinSize.x)
			self.height = math.max(h, resizeMinSize.y)
			if not self.Maximized then
				self._savedW = self.width
				self._savedH = self.height
			end
		end

		function window:Close()
			local anim = getOrCreateAnim(self)
			if not anim.closing then
				anim.closing = true
				anim.closeTimer = 0
			end
		end

		function window:Open()
			local anim = getOrCreateAnim(self)
			self.Closed = false
			anim.closing = false
			anim.closeTimer = 0
			anim.fadeAlpha = 1
		end

		function window:Minimize()
			if self.Minimized then
				return
			end
			self.Minimized = true
			if self.Maximized then
				self:Unmaximize()
			end
			module.windowMinimized(self)
		end

		function window:Unminimize()
			if not self.Minimized then
				return
			end
			self.Minimized = false
			module.windowUnminimized(self)
		end

		function window:ToggleMinimize()
			if self.Minimized then
				self:Unminimize()
			else
				self:Minimize()
			end
		end

		function window:Maximize()
			if self.Maximized then
				return
			end
			self._savedX = self.x
			self._savedY = self.y
			self._savedW = self.width
			self._savedH = self.height

			local parent = self.parent
			if parent then
				self.x, self.y, self.width, self.height = parent.x, parent.y, parent.width, parent.height
			else
				self.x, self.y = 0, 0
				self.width, self.height = raylib.GetRenderWidth(), raylib.GetRenderHeight()
			end

			self.Maximized = true
			self.Minimized = false
			module.windowMaximized(self)
		end

		function window:Unmaximize()
			if not self.Maximized then
				return
			end
			self.x, self.y = self._savedX, self._savedY
			self.width, self.height = self._savedW, self._savedH
			self.Maximized = false
			module.windowUnmaximized(self)
		end

		function window:ToggleMaximize()
			if self.Maximized then
				self:Unmaximize()
			else
				self:Maximize()
			end
		end

		function window:SetStatus(t)
			self.statusText = t or ""
		end

		function window:SetTab(index)
			if index == nil then
				local prev = self.activeTab
				self.activeTab = nil
				if prev ~= nil then
					module.tabChanged(self, nil, nil)
				end
			elseif self.tabs and index >= 1 and index <= #self.tabs then
				local prev = self.activeTab
				self.activeTab = index
				if prev ~= index then
					module.tabChanged(self, index, self.tabs[index])
				end
			end
		end

		function window:SetTabByName(name)
			if not self.tabs then
				return
			end
			for i, tab in ipairs(self.tabs) do
				if tab.name == name then
					self:SetTab(i)
					return
				end
			end
		end

		return window
	end

	--  Update

	function module.update(dt, selectedTheme)
		local wcfg = selectedTheme and selectedTheme.window or {}
		local titleH = wval(wcfg, "TitleHeight", 28)

		for _, w in pairs(windowRegistry) do
			w._titleBarH = titleH
			w._tabBarH = titleH
		end

		-- Fade-out animation
		for _, w in pairs(windowRegistry) do
			if not w.enabled then
				continue
			end
			local anim = getOrCreateAnim(w)
			if not anim.closing then
				continue
			end
			anim.closeTimer = anim.closeTimer + dt
			anim.fadeAlpha = math.max(0, 1 - anim.closeTimer / FADE_DURATION)
			if anim.closeTimer >= FADE_DURATION then
				w.Closed = true
				anim.closing = false
				anim.fadeAlpha = 0
				module.windowClosed(w)
			end
		end

		local mousePos = raylib.GetMousePosition()
		local mousePressed = raylib.IsMouseButtonPressed(0)
		local mouseRightPressed = raylib.IsMouseButtonPressed(1)
		local mouseDown = raylib.IsMouseButtonDown(0)
		local mouseReleased = raylib.IsMouseButtonReleased(0)
		local mouseWheel = raylib.GetMouseWheelMove()
		local tabFontSize = wval(wcfg, "TitleTextSize", 13)
		local speed = 12 * dt

		-- Hover animations
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

		-- Topmost visible window under the cursor
		local hoveredWindow = nil
		for i = #windowRegistry, 1, -1 do
			local w = windowRegistry[i]
			local anim = getOrCreateAnim(w)
			if not w.Closed and not anim.closing and w.enabled and isMouseOverWindow(w, mousePos) then
				hoveredWindow = w
				break
			end
		end

		-- Determine global topmost window across all window systems for click-through prevention
		_G.__aereon_topWindow = nil
		for i = #_G.__aereon_allWindows, 1, -1 do
			local w = _G.__aereon_allWindows[i]
			local anim = getOrCreateAnim(w)
			if not w.Closed and not anim.closing and w.enabled and isMouseOverWindow(w, mousePos) then
				_G.__aereon_topWindow = w
				break
			end
		end

		-- Mouse wheel: prevent camera scroll when over a window
		if mouseWheel ~= 0 and hoveredWindow then
			game.Stop3DInput = true
		end

		-- Right-click: focus management only
		if mouseRightPressed == 1 then
			if hoveredWindow then
				game.Stop3DInput = true
			elseif isMouseInViewport(mousePos) then
				game.Stop3DInput = false
				for _, w in pairs(windowRegistry) do
					if w.Focused then
						w.Focused = false
						w.unfocused(w)
						module.unfocused(w)
					end
				end
			end
		end

		-- Left click
		if mousePressed == 1 then
			-- Traffic-light buttons (iterate front-to-back)
			for i = #windowRegistry, 1, -1 do
				local w = windowRegistry[i]
				local anim = getOrCreateAnim(w)
				if w.Closed or anim.closing or not w.enabled or w.headerRender == false then
					continue
				end
				if isMouseOverTrafficLight(w, mousePos, 1) then
					w:Close()
					break
				elseif isMouseOverTrafficLight(w, mousePos, 2) then
					w:ToggleMinimize()
					break
				elseif isMouseOverTrafficLight(w, mousePos, 3) then
					w:ToggleMaximize()
					break
				end
			end

			-- Tab click: raise and switch
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

			-- Focus
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
			elseif isMouseInViewport(mousePos) then
				game.Stop3DInput = false
			end

			-- Begin drag or resize
			if not draggedWindow and not resizingWindow then
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
						and w.Draggable
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
						if
							w.Closed
							or anim.closing
							or not w.enabled
							or w.Minimized
							or w.Maximized
							or not w.Resizable
						then
							continue
						end
						local sides = getResizeSide(w, mousePos)
						if sides and w.Resizable then
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
		end

		-- Drag / resize held
		if mouseDown == 1 then
			if draggedWindow then
				MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_ALL.Value)
				draggedWindow.x = mousePos.x - dragOffset.x
				draggedWindow.y = mousePos.y - dragOffset.y
				draggedWindow._savedX = draggedWindow.x
				draggedWindow._savedY = draggedWindow.y
				draggedWindow.IsDragging = true
				module.dragged(draggedWindow)
			elseif resizingWindow then
				local dx = mousePos.x - resizeStart.x
				local dy = mousePos.y - resizeStart.y
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
			-- Hover-resize cursor when nothing is active
			if not draggedWindow and not resizingWindow then
				local anySide = false
				for i = #windowRegistry, 1, -1 do
					local w = windowRegistry[i]
					local anim = getOrCreateAnim(w)
					if w.Closed or anim.closing or not w.enabled or w.Minimized or w.Maximized then
						continue
					end
					local sides = getResizeSide(w, mousePos)
					if sides and w.Resizable then
						setCursorForResize(sides)
						anySide = true
						break
					end
				end
				if not anySide then
					MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
				end
			end
		end

		if mouseReleased == 1 then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			if draggedWindow then
				draggedWindow.IsDragging = false
				module.dragEnd(draggedWindow)
			end
			draggedWindow = nil
			resizingWindow = nil
			resizeSide = nil
		end
	end

	--  Draw

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
		local tabTextDimColor = Color3.new(
			titleColor.R * 0.45 + titlebarColor.R * 0.55,
			titleColor.G * 0.45 + titlebarColor.G * 0.55,
			titleColor.B * 0.45 + titlebarColor.B * 0.55
		)

		local sepColor = shiftBrightness(titlebarColor, isTitleDark and 0.10 or -0.10)
		local cornerFrac = math.clamp(cornerPx / 200, 0, 0.5)

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

			-- Transparency helper: alpha-scale any base transparency
			local function tr(base)
				return 1 - (1 - base) * alpha
			end

			local btnRed = focused and TL_RED or TL_UNFOC
			local btnYel = focused and TL_YEL or TL_UNFOC
			local btnGrn = focused and TL_GRN or TL_UNFOC

			local curTitlebarColor = focused and titlebarColor or titlebarUnfocused
			local curTitleColor = focused and titleColor or titleColorDim
			local curBodyTransp = wd.IsDragging and 0 or bodyTransp

			-- Shadow
			if shadowsOn then
				local shadowAlpha = (focused and (1 - shadowTr) * 1.4 or (1 - shadowTr)) * alpha
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

			-- Title bar
			local titleBarH = 0
			if wd.headerRender ~= false then
				titleBarH = titleH

				if not wd.Minimized then
					raylib.DrawLineEx(
						vector.create(wx, wy + titleBarH),
						vector.create(wx + ww, wy + titleBarH),
						SEP_H,
						sepColor:ToRaylib(tr(titlebarTr))
					)
				end

				-- Traffic lights
				local cx1, cx2, cx3, cy = trafficLightCentres(wd)
				local showSymbols = anim.titlebarHover > 0.25 and focused
				local function tlCol(base)
					return Color3.new(base.R, base.G, base.B):ToRaylib(1 - alpha)
				end

				-- Close
				raylib.DrawCircleV(vector.create(cx1, cy), BTN_RADIUS, tlCol(btnRed))
				if showSymbols then
					local r, sc = BTN_SYM_R, TL_SYM_R:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx1 - r, cy - r), vector.create(cx1 + r, cy + r), 1.2, sc)
					raylib.DrawLineEx(vector.create(cx1 + r, cy - r), vector.create(cx1 - r, cy + r), 1.2, sc)
				end

				-- Minimise
				raylib.DrawCircleV(vector.create(cx2, cy), BTN_RADIUS, tlCol(btnYel))
				if showSymbols then
					local r, sc = BTN_SYM_R, TL_SYM_Y:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx2 - r, cy), vector.create(cx2 + r, cy), 1.2, sc)
				end

				-- Maximise
				raylib.DrawCircleV(vector.create(cx3, cy), BTN_RADIUS, tlCol(btnGrn))
				if showSymbols then
					local r, sc = BTN_SYM_R - 0.5, TL_SYM_G:ToRaylib(1 - alpha)
					raylib.DrawLineEx(vector.create(cx3 - r, cy + r), vector.create(cx3, cy), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 - r, cy), vector.create(cx3 - r, cy + r), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 + r, cy - r), vector.create(cx3, cy), 1.1, sc)
					raylib.DrawLineEx(vector.create(cx3 + r, cy), vector.create(cx3 + r, cy - r), 1.1, sc)
				end

				-- Title text
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
					local leftEdge = wx + BTN_LEFT + (BTN_RADIUS * 2 + BTN_SPACING) * 3 + 8
					raylib.DrawTextEx(
						vend,
						"Minimized",
						vector.create(leftEdge, wy + (titleBarH - (titleFontSz - 2)) / 2),
						titleFontSz - 2,
						1,
						titleColorDim:ToRaylib(tr(0.4))
					)
				end

				wd.titleRect = { height = titleBarH, width = ww, x = wx, y = wy }
			end

			-- Body (non-minimized)
			if not wd.Minimized then
				local hasTabs = wd.tabs and #wd.tabs > 0
				local tabAreaH = hasTabs and titleH or 0

				-- Tab bar
				if hasTabs then
					local tabBarY = wy + titleBarH

					raylib.DrawRectangleRec(
						structs.Rectangle:new({ x = wx, y = tabBarY, width = ww, height = tabAreaH }),
						tabInactiveColor:ToRaylib(tr(titlebarTr))
					)

					local curX = wx
					for i, tab in ipairs(wd.tabs) do
						local tw = math.max(measureTabWidth(tab.name, titleFontSz), TAB_MIN_W)
						local isActive = wd.activeTab == i

						raylib.DrawRectangleRec(
							structs.Rectangle:new({ x = curX, y = tabBarY, width = tw, height = tabAreaH }),
							(isActive and tabActiveColor or tabInactiveColor):ToRaylib(tr(titlebarTr))
						)

						if isActive then
							-- Active indicator bar
							raylib.DrawRectangleRec(
								structs.Rectangle:new({ x = curX, y = tabBarY, width = tw, height = 2 }),
								accentColor:ToRaylib(tr(wval(wcfg, "DragOutlineTransparency", 0)))
							)
							-- Erase the bottom separator for the active tab
							raylib.DrawLineEx(
								vector.create(curX + 1, tabBarY + tabAreaH),
								vector.create(curX + tw - 1, tabBarY + tabAreaH),
								SEP_H + 0.5,
								tabActiveColor:ToRaylib(tr(titlebarTr))
							)
						end

						-- Divider between tabs
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
							(isActive and titleColor or tabTextDimColor):ToRaylib(1 - alpha)
						)

						curX = curX + tw
					end

					raylib.DrawLineEx(
						vector.create(wx, tabBarY + tabAreaH),
						vector.create(wx + ww, tabBarY + tabAreaH),
						SEP_H,
						sepColor:ToRaylib(tr(titlebarTr))
					)
				end

				-- Status bar
				local statusBarH = wd.showStatusBar and STATUSBAR_H or 0
				if wd.showStatusBar then
					local sbY = wy + wd.height - statusBarH
					raylib.DrawRectangleRec(
						structs.Rectangle:new({ x = wx, y = sbY, width = ww, height = statusBarH }),
						curTitlebarColor:ToRaylib(tr(titlebarTr))
					)
					raylib.DrawLineEx(
						vector.create(wx, sbY),
						vector.create(wx + ww, sbY),
						SEP_H,
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

				-- Window outline
				raylib.DrawRectangleRoundedLinesEx(mainRect, cornerFrac, 20, 0.75, sepColor:ToRaylib(tr(titlebarTr)))

				-- Drag outline
				if wd.IsDragging then
					raylib.DrawRectangleRoundedLinesEx(
						structs.Rectangle:new({ x = wx - 1, y = wy - 1, width = ww + 2, height = wd.height + 2 }),
						cornerFrac,
						20,
						1.5,
						accentColor:ToRaylib(tr(wval(wcfg, "DragOutlineTransparency", 0)))
					)
				end

				-- Content
				if not anim.closing then
					local contentOffsetY = titleBarH + tabAreaH
					local contentH = wd.height - contentOffsetY - statusBarH

					if not wd.DisableClipping then
						raylib.BeginScissorMode(wx, wy + contentOffsetY, ww, contentH)
						table.insert(_G.__aereon_scissorStack, { x = wx, y = wy + contentOffsetY, width = ww, height = contentH })
					end

					-- Block input for non-topmost windows to prevent click-through
					local wasBlocking = _G.__aereon_blockInput
					if _G.__aereon_topWindow and _G.__aereon_topWindow ~= wd then
						_G.__aereon_blockInput = true
					end

					if wd.Scrollable then
						if not wd._scrollArea then
							wd._scrollArea = gui.scrollable({
								scrollbarWidth = 6,
								scrollbarColor = Color3.new(0.3, 0.3, 0.3),
								scrollbarHoverColor = Color3.new(0.5, 0.5, 0.5),
								scrollbarBackgroundTransparency = 1,
								child = {
									get_rect = function()
										return arect.new(0, 0, ww, wd._contentHeight or 0)
									end,
									set = function(self, prop, value)
										if prop == "obj_rect" then
											self.rect = value
										end
									end,
									render = function(self, dt)
										if hasTabs and wd.activeTab then
											local activeTab = wd.tabs[wd.activeTab]
											if activeTab and activeTab.render then
												activeTab.render(wd)
											end
										end
										module.stepped(wd, dt)
									end,
								},
							})
						end
						wd._scrollArea.set("obj_rect", arect.new(wx, wy + contentOffsetY, ww, contentH))
						wd._scrollArea.render(dt)
					else
						if hasTabs and wd.activeTab then
							local activeTab = wd.tabs[wd.activeTab]
							if activeTab and activeTab.render then
								activeTab.render(wd)
							end
						end

						module.stepped(wd, dt)
					end

					if _G.__aereon_topWindow and _G.__aereon_topWindow ~= wd then
						_G.__aereon_blockInput = wasBlocking
					end

					if not wd.DisableClipping then
						raylib.EndScissorMode()
						if #_G.__aereon_scissorStack > 0 then
							table.remove(_G.__aereon_scissorStack)
						end
					end

					-- wd.stepped (layout callback, runs outside scissor)
					if wd.stepped then
						local steppedWasBlocking = _G.__aereon_blockInput
						if _G.__aereon_topWindow and _G.__aereon_topWindow ~= wd then
							_G.__aereon_blockInput = true
						end
						wd.stepped(wd, dt)
						if _G.__aereon_topWindow and _G.__aereon_topWindow ~= wd then
							_G.__aereon_blockInput = steppedWasBlocking
						end
					end
				end
			else
				-- Minimized outline only
				raylib.DrawRectangleRoundedLinesEx(mainRect, cornerFrac, 20, 0.75, sepColor:ToRaylib(tr(titlebarTr)))
			end
		end
	end

	module.dragspring = dragSpring
	return module
end
