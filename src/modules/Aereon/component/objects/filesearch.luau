local raylib = require("@raylib")
local color3 = require("@Color3")
local rect = require("@arect")
local Aereon = require("@Aereon")

return function(objects, data)
	--  config
	local config = {
		files = data.files or {},
		isOpen = data.isOpen or false,
		onOpen = data.onOpen,
		game = data.game,

		-- Layout
		width = data.width or 700,
		itemHeight = 42,
		maxVisibleItems = 10,
		headerHeight = 48,
		padding = 14,
		iconSize = 15,
		scrollbarWidth = 5,

		-- Colors
		backgroundColor = color3.new(0.10, 0.10, 0.12),
		itemHoverColor = color3.new(0.15, 0.16, 0.19),
		itemSelectedColor = color3.new(0.09, 0.26, 0.52),
		textColor = color3.new(0.92, 0.93, 0.95),
		subtextColor = color3.new(0.48, 0.50, 0.55),
		accentColor = color3.new(0.25, 0.60, 1.00),
		dividerColor = color3.new(0.18, 0.19, 0.22),
		borderColor = color3.new(0.24, 0.25, 0.30),
		dimColor = color3.new(0, 0, 0),
		scrollbarColor = color3.new(0.28, 0.30, 0.35),
		scrollbarHovColor = color3.new(0.42, 0.44, 0.50),
		tagColor = color3.new(0.50, 0.52, 0.58),

		-- Font
		font = data.font,
		fontSize = data.fontSize or 14,
		fontSpacing = 0.5,
		subFontSize = 12,
		subFontSpacing = 0.4,

		-- State
		searchText = "",
		selectedIndex = 1,
		_filtered = {},
		_dirty = true,

		-- Scroll
		scrollOffset = 0,
		scrollTarget = 0,
		scrollbarAlpha = 0,
		_sbDrag = { active = false, offsetY = 0 },

		-- Drag (move palette by header rim)
		_drag = { active = false, offX = 0, offY = 0 },
		_posX = nil,
		_posY = nil,

		_searchBox = nil,
	}

	--  helpers

	local function drawText(text, x, y, size, spacing, col)
		if config.font then
			raylib.lib.DrawTextEx(config.font, text, vector.create(x, y), size, spacing, col:ToRaylib(0))
		else
			raylib.lib.DrawText(text, x, y, size, col:ToRaylib(0))
		end
	end

	local function measureText(text, size, spacing)
		if config.font then
			return raylib.lib.MeasureTextEx(config.font, text, size, spacing).x
		else
			return raylib.lib.MeasureText(text, size)
		end
	end

	local function truncate(text, maxW, size, spacing)
		if measureText(text, size, spacing) <= maxW then
			return text
		end
		local ew = measureText("...", size, spacing)
		if ew >= maxW then
			return ""
		end
		local out = ""
		for i = 1, #text do
			local c = string.sub(text, i, i)
			if measureText(out .. c, size, spacing) + ew > maxW then
				break
			end
			out = out .. c
		end
		return out .. "..."
	end

	local hoverStates = {}
	local function getHover(key, dt, hovered)
		hoverStates[key] = hoverStates[key] or 0
		local v = hoverStates[key]
		hoverStates[key] = hovered and math.min(v + dt * 14, 1) or math.max(v - dt * 14, 0)
		return hoverStates[key]
	end

	--  filtered list

	local function rebuild()
		config._filtered = {}
		local q = config.searchText:lower()
		for _, f in ipairs(config.files) do
			if
				q == ""
				or (f.name and f.name:lower():find(q, 1, true))
				or (f.path and f.path:lower():find(q, 1, true))
			then
				table.insert(config._filtered, f)
			end
		end
		config._dirty = false
		config.selectedIndex = math.clamp(config.selectedIndex, 1, math.max(1, #config._filtered))
	end

	--  file icon

	local function drawFileIcon(x, y, size, accent)
		local col = accent and config.accentColor or color3.new(0.38, 0.52, 0.78)
		local fold = math.floor(size * 0.30)
		local w = size
		local h = math.floor(size * 1.15)
		local dark = color3.new(col.R * 0.45, col.G * 0.45, col.B * 0.45)
		local mid = color3.new(col.R * 0.68, col.G * 0.68, col.B * 0.68)

		raylib.lib.DrawRectangle(x, y + fold, w - fold, h - fold, col:ToRaylib(0.22))
		raylib.lib.DrawRectangle(x, y, w - fold, fold, col:ToRaylib(0.22))
		raylib.lib.DrawTriangle(
			vector.create(x + w - fold, y),
			vector.create(x + w - fold, y + fold),
			vector.create(x + w, y + fold),
			dark:ToRaylib(0.14)
		)
		raylib.lib.DrawTriangle(
			vector.create(x + w - fold, y),
			vector.create(x + w, y + fold),
			vector.create(x + w - fold, y + fold),
			mid:ToRaylib(0.22)
		)
	end

	--  scrollbar

	local function drawScrollbar(lx, ly, lw, lh, contentH, dt)
		local maxScroll = math.max(0, contentH - lh)
		if maxScroll <= 0 then
			config.scrollbarAlpha = math.max(0, config.scrollbarAlpha - dt * 4)
			return
		end

		local mousePos = raylib.lib.GetMousePosition()
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1
		local mousePress = raylib.lib.IsMouseButtonPressed(0) == 1

		local sw = config.scrollbarWidth
		local sh = math.max(28, (lh / contentH) * lh)
		local srange = lh - sh
		local sy = ly + (config.scrollOffset / maxScroll) * srange
		local sx = lx + lw - sw - 3

		local barRect = rect.new(sx, sy, sw, sh)
		local trackRect = rect.new(sx, ly, sw, lh)
		local panelRect = rect.new(lx, ly, lw, lh)
		local isBarHov = rect.MouseIsInRect(barRect)
		local isTrackHov = rect.MouseIsInRect(trackRect)
		local isDragging = config._sbDrag.active

		if rect.MouseIsInRect(panelRect) or isTrackHov or isDragging then
			config.scrollbarAlpha = math.min(config.scrollbarAlpha + dt * 7, 1)
		else
			config.scrollbarAlpha = math.max(config.scrollbarAlpha - dt * 3, 0)
		end

		if mousePress and isBarHov then
			config._sbDrag.active = true
			config._sbDrag.offsetY = mousePos.y - sy
		elseif mousePress and isTrackHov then
			local newSy = math.clamp(mousePos.y - sh / 2, ly, ly + srange)
			local pct = srange > 0 and (newSy - ly) / srange or 0
			config.scrollOffset = pct * maxScroll
			config.scrollTarget = config.scrollOffset
			config._sbDrag.active = true
			config._sbDrag.offsetY = mousePos.y - newSy
		end

		if config._sbDrag.active then
			if mouseDown then
				local newSy = math.clamp(mousePos.y - config._sbDrag.offsetY, ly, ly + srange)
				local pct = srange > 0 and (newSy - ly) / srange or 0
				config.scrollOffset = pct * maxScroll
				config.scrollTarget = config.scrollOffset
				sy = newSy
			else
				config._sbDrag.active = false
			end
		end

		if config.scrollbarAlpha > 0.01 then
			local col = (isBarHov or isDragging) and config.scrollbarHovColor or config.scrollbarColor
			local alpha = 1 - (1 - config.scrollbarAlpha) -- just scrollbarAlpha, kept for clarity
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(sx, sy, sw, sh)),
				0.6,
				4,
				col:ToRaylib(1 - config.scrollbarAlpha)
			)
		end
	end

	--  public API

	local wrapper = {}

	wrapper.toggle = function(force)
		config.isOpen = (force ~= nil) and force or not config.isOpen
		if config.isOpen then
			config.searchText = ""
			config.selectedIndex = 1
			config.scrollOffset = 0
			config.scrollTarget = 0
			config._dirty = true
			config._posX = nil
			config._posY = nil
			if config._searchBox then
				config._searchBox:clear()
				config._searchBox:focus()
			end
		end
		return wrapper
	end

	wrapper.setFiles = function(files)
		config.files = files
		config._dirty = true
		return wrapper
	end

	--  render

	wrapper.render = function(dt)
		if not config.isOpen then
			return
		end
		if config._dirty then
			rebuild()
		end

		local screenW = raylib.lib.GetScreenWidth()
		local screenH = raylib.lib.GetScreenHeight()

		-- backdrop
		raylib.lib.DrawRectangle(0, 0, screenW, screenH, config.dimColor:ToRaylib(0.45))

		-- panel sizing
		local numVisible = math.min(#config._filtered, config.maxVisibleItems)
		local listH = math.max(numVisible, 1) * config.itemHeight
		local totalH = config.headerHeight + listH
		local W = config.width

		if config._posX == nil then
			config._posX = math.floor((screenW - W) / 2)
			config._posY = math.floor(screenH * 0.15)
		end

		local X = config._posX
		local Y = config._posY

		local mousePos = raylib.lib.GetMousePosition()
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1
		local mousePress = raylib.lib.IsMouseButtonPressed(0) == 1

		--  drag to move
		local tbInner = rect.new(X + 4, Y + 4, W - 8, config.headerHeight - 8)
		local headerRect = rect.new(X, Y, W, config.headerHeight)

		if mousePress and rect.MouseIsInRect(headerRect) and not rect.MouseIsInRect(tbInner) then
			config._drag.active = true
			config._drag.offX = mousePos.x - X
			config._drag.offY = mousePos.y - Y
		end

		if config._drag.active then
			if mouseDown then
				config._posX = math.clamp(mousePos.x - config._drag.offX, 0, screenW - W)
				config._posY = math.clamp(mousePos.y - config._drag.offY, 0, screenH - totalH)
				X = config._posX
				Y = config._posY
			else
				config._drag.active = false
			end
		end

		--  panel background
		for i = 1, 8 do
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(X - i, Y - i, W + i * 2, totalH + i * 2)),
				0.05,
				8,
				color3.new(0, 0, 0):ToRaylib(1 - (32 / i) / 255)
			)
		end

		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(X, Y, W, totalH)),
			0.05,
			8,
			config.backgroundColor:ToRaylib(0.012)
		)
		raylib.lib.DrawRectangleRoundedLinesEx(
			rect:translate(rect.new(X, Y, W, totalH)),
			0.05,
			8,
			1,
			config.borderColor:ToRaylib(0)
		)

		--  search box
		if not config._searchBox then
			local game = config.game
			if game then
				local theme = game:GetService("StudioThemeService")
				local TextBoxClass = Aereon.textbox(theme, game)
				config._searchBox = TextBoxClass.new({
					padding = config.padding,
					backgroundColor = config.backgroundColor,
					textColor = config.textColor,
					placeholderColor = config.subtextColor,
					cornerRadius = 0.05,
					BackgroundTransparency = 0,
					BorderTransparency = 1,
					placeholder = "Search files by name (append : for line, @ for symbol)",
					fontSize = config.fontSize,
					escapeBlurs = false,
					blurOnSubmit = false,
					onSubmit = function()
						local sel = config._filtered[config.selectedIndex]
						if sel then
							if config.onOpen then
								config.onOpen(sel)
							end
							wrapper.toggle(false)
						end
					end,
					onChange = function(text)
						if text ~= config.searchText then
							config.searchText = text
							config.selectedIndex = 1
							config.scrollTarget = 0
							config._dirty = true
							rebuild()
						end
					end,
				})
				config._searchBox:focus()
			end
		end

		if config._searchBox then
			config._searchBox:drawWithExtras(X + 1, Y + 1, W - 2, config.headerHeight - 2)
			local boxText = config._searchBox:getText()
			if boxText ~= config.searchText then
				config.searchText = boxText
				config.selectedIndex = 1
				config.scrollTarget = 0
				config._dirty = true
				rebuild()
			end
		else
			-- fallback manual input
			local char = raylib.lib.GetCharPressed()
			while char > 0 do
				if char >= 32 and char <= 126 then
					config.searchText = config.searchText .. string.char(char)
					config.selectedIndex = 1
					config.scrollTarget = 0
					config._dirty = true
					rebuild()
				end
				char = raylib.lib.GetCharPressed()
			end
			if raylib.lib.IsKeyPressed(259) == 1 and #config.searchText > 0 then
				config.searchText = config.searchText:sub(1, -2)
				config.selectedIndex = 1
				config.scrollTarget = 0
				config._dirty = true
				rebuild()
			end
			local display = #config.searchText == 0 and "Search files by name (append : for line, @ for symbol)"
				or config.searchText
			local tc = #config.searchText == 0 and config.subtextColor or config.textColor
			drawText(
				display,
				X + config.padding + 4,
				Y + math.floor((config.headerHeight - config.fontSize) / 2),
				config.fontSize,
				config.fontSpacing,
				tc
			)
		end

		-- divider
		raylib.lib.DrawRectangle(X, Y + config.headerHeight - 1, W, 1, config.dividerColor:ToRaylib(0))

		--  keyboard nav
		if raylib.lib.IsKeyPressed(256) == 1 then -- Escape
			wrapper.toggle(false)
		end
		if raylib.lib.IsKeyPressed(265) == 1 then -- Up
			config.selectedIndex = config.selectedIndex - 1
			if config.selectedIndex < 1 then
				config.selectedIndex = math.max(1, #config._filtered)
			end
		elseif raylib.lib.IsKeyPressed(264) == 1 then -- Down
			config.selectedIndex = config.selectedIndex + 1
			if config.selectedIndex > #config._filtered then
				config.selectedIndex = 1
			end
		elseif raylib.lib.IsKeyPressed(257) == 1 and not config._searchBox then -- Enter (fallback)
			local sel = config._filtered[config.selectedIndex]
			if sel then
				if config.onOpen then
					config.onOpen(sel)
				end
				wrapper.toggle(false)
			end
		end

		-- keep selected in view
		local selTop = (config.selectedIndex - 1) * config.itemHeight
		local selBot = selTop + config.itemHeight
		if selTop < config.scrollTarget then
			config.scrollTarget = selTop
		elseif selBot > config.scrollTarget + listH then
			config.scrollTarget = selBot - listH
		end

		--  smooth scroll
		local contentH = #config._filtered * config.itemHeight
		local maxScroll = math.max(0, contentH - listH)
		config.scrollTarget = math.clamp(config.scrollTarget, 0, maxScroll)

		if rect.MouseIsInRect(rect.new(X, Y + config.headerHeight, W, listH)) then
			local wheel = raylib.lib.GetMouseWheelMove()
			if wheel ~= 0 then
				config.scrollTarget = math.clamp(config.scrollTarget - wheel * 38, 0, maxScroll)
			end
		end

		config.scrollOffset = config.scrollOffset + (config.scrollTarget - config.scrollOffset) * math.min(dt * 20, 1)

		--  item list
		raylib.lib.BeginScissorMode(
			math.floor(X),
			math.floor(Y + config.headerHeight),
			math.floor(W),
			math.floor(listH)
		)

		if #config._filtered == 0 then
			drawText(
				"No results found",
				X + config.padding,
				Y + config.headerHeight + math.floor((config.itemHeight - config.fontSize) / 2),
				config.fontSize,
				config.fontSpacing,
				config.subtextColor
			)
		else
			for i, file in ipairs(config._filtered) do
				local itemY = Y + config.headerHeight + (i - 1) * config.itemHeight - math.floor(config.scrollOffset)

				if itemY + config.itemHeight < Y + config.headerHeight then
					-- above viewport
				elseif itemY > Y + config.headerHeight + listH then
					break
				else
					local iRect = rect.new(X, itemY, W, config.itemHeight)
					local isHov = rect.MouseIsInRect(iRect)
					local isSel = (i == config.selectedIndex)
					local hov = getHover("item_" .. i, dt, isHov)

					if isSel then
						raylib.lib.DrawRectangle(X, itemY, W, config.itemHeight, config.itemSelectedColor:ToRaylib(0))
						raylib.lib.DrawRectangle(X, itemY, 3, config.itemHeight, config.accentColor:ToRaylib(0))
					elseif hov > 0 then
						raylib.lib.DrawRectangle(
							X,
							itemY,
							W,
							config.itemHeight,
							config.itemHoverColor:ToRaylib(1 - hov)
						)
					end

					-- icon
					local iconX = X + config.padding
					local iconY = itemY + math.floor((config.itemHeight - config.iconSize) / 2)
					drawFileIcon(iconX, iconY, config.iconSize, isSel)

					-- filename
					local nameX = iconX + config.iconSize + 10
					local nameY = itemY + math.floor((config.itemHeight - config.fontSize) / 2)
					local nameStr = file.name or "untitled"
					local nameW = measureText(nameStr, config.fontSize, config.fontSpacing)
					drawText(nameStr, nameX, nameY, config.fontSize, config.fontSpacing, config.textColor)

					-- tag (right, selected only)
					local tagStr = file.tag or "recently opened"
					local tagW = measureText(tagStr, config.subFontSize, config.subFontSpacing)
					local tagX = X + W - config.padding - tagW - config.scrollbarWidth - 6
					if isSel then
						drawText(
							tagStr,
							tagX,
							itemY + math.floor((config.itemHeight - config.subFontSize) / 2),
							config.subFontSize,
							config.subFontSpacing,
							config.tagColor
						)
					end

					-- path (dim, between name and tag/edge)
					local pathStr = file.path or ""
					if #pathStr > 0 then
						local pathX = nameX + nameW + 8
						local rightEdge = isSel and (tagX - 8) or (X + W - config.padding - config.scrollbarWidth - 6)
						local avail = rightEdge - pathX
						if avail > 20 then
							local pathDisp = truncate(pathStr, avail, config.subFontSize, config.subFontSpacing)
							drawText(
								pathDisp,
								pathX,
								itemY + math.floor((config.itemHeight - config.subFontSize) / 2) + 1,
								config.subFontSize,
								config.subFontSpacing,
								config.subtextColor
							)
						end
					end

					if isHov and mousePress then
						config.selectedIndex = i
						if config.onOpen then
							config.onOpen(file)
						end
						wrapper.toggle(false)
					end
				end
			end
		end

		raylib.lib.EndScissorMode()

		drawScrollbar(X, Y + config.headerHeight, W, listH, contentH, dt)
	end

	table.insert(objects, wrapper)
	return wrapper
end
