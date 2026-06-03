local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")

return function(objects, data)
	local config = {
		options = data.options or {}, -- { {text = "...", callback = ...}, ... }
		isOpen = data.isOpen or false,
		searchText = "",
		selectedIndex = 1,

		-- Layout
		width = data.width or 450,
		height = data.height or 380,

		-- Colors
		backgroundColor = color3.new(0.08, 0.08, 0.1),
		itemHoverColor = color3.new(0.15, 0.15, 0.18),
		itemSelectedColor = color3.new(0.02, 0.5, 1),
		textColor = color3.new(0.9, 0.9, 0.9),
		dimColor = color3.new(0, 0, 0),
		dimTransparency = 0.6,
	}

	local wrapper = {}

	wrapper.toggle = function(force)
		config.isOpen = (force ~= nil) and force or not config.isOpen
		if config.isOpen then
			config.searchText = ""
			config.selectedIndex = 1
		end
		return wrapper
	end

	wrapper.setOptions = function(opts)
		config.options = opts
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.isOpen then
			return
		end

		local screenWidth = raylib.lib.GetScreenWidth()
		local screenHeight = raylib.lib.GetScreenHeight()

		-- Backdrop dim
		local r_d, g_d, b_d = config.dimColor:ToRGB()
		raylib.lib.DrawRectangle(
			0,
			0,
			screenWidth,
			screenHeight,
			structs.Color:new({
				r = r_d,
				g = g_d,
				b = b_d,
				a = math.floor(255 * config.dimTransparency),
			})
		)

		local x = (screenWidth - config.width) / 2
		local y = screenHeight * 0.2
		local r = rect.new(x, y, config.width, config.height)

		-- Main Background
		local r_bg, g_bg, b_bg = config.backgroundColor:ToRGB()
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			0.1,
			8,
			structs.Color:new({
				r = r_bg,
				g = g_bg,
				b = b_bg,
				a = 250,
			})
		)
		raylib.lib.DrawRectangleRoundedLinesEx(
			rect:translate(r),
			0.1,
			8,
			1,
			structs.Color:new({
				r = 80,
				g = 80,
				b = 100,
				a = 255,
			})
		)

		-- Search Bar Area
		local inputPadding = 15
		local inputY = y + inputPadding

		if #config.searchText == 0 then
			raylib.lib.DrawText(
				"Search commands...",
				x + inputPadding,
				inputY,
				20,
				structs.Color:new({ r = 100, g = 100, b = 120, a = 255 })
			)
		else
			raylib.lib.DrawText(config.searchText, x + inputPadding, inputY, 20, raylib.const.WHITE)
		end

		raylib.lib.DrawRectangle(
			x + inputPadding,
			inputY + 25,
			config.width - inputPadding * 2,
			1,
			structs.Color:new({ r = 50, g = 50, b = 60, a = 255 })
		)

		-- Filter Options
		local filtered = {}
		for _, opt in ipairs(config.options) do
			if opt.text:lower():find(config.searchText:lower()) then
				table.insert(filtered, opt)
			end
		end

		-- Handle Inputs
		if raylib.lib.IsKeyPressed(256) == 1 then -- Escape
			wrapper.toggle(false)
		end

		if raylib.lib.IsKeyPressed(265) == 1 then -- Up
			config.selectedIndex = config.selectedIndex - 1
			if config.selectedIndex < 1 then
				config.selectedIndex = #filtered
			end
		elseif raylib.lib.IsKeyPressed(264) == 1 then -- Down
			config.selectedIndex = config.selectedIndex + 1
			if config.selectedIndex > #filtered then
				config.selectedIndex = 1
			end
		elseif raylib.lib.IsKeyPressed(257) == 1 then -- Enter
			if filtered[config.selectedIndex] then
				filtered[config.selectedIndex].callback()
				wrapper.toggle(false)
			end
		end

		-- Typing
		local char = raylib.lib.GetCharPressed()
		while char > 0 do
			if char >= 32 and char <= 126 then
				config.searchText = config.searchText .. string.char(char)
				config.selectedIndex = 1
			end
			char = raylib.lib.GetCharPressed()
		end
		if raylib.lib.IsKeyPressed(259) == 1 and #config.searchText > 0 then -- Backspace
			config.searchText = config.searchText:sub(1, -2)
			config.selectedIndex = 1
		end

		-- Render Results
		local listY = inputY + 40
		local maxVisible = 8
		for i, opt in ipairs(filtered) do
			if i > maxVisible then
				break
			end

			local itemRect = rect.new(x + 5, listY, config.width - 10, 35)
			local isHovered = rect.MouseIsInRect(itemRect)
			local isSelected = (i == config.selectedIndex)

			if isSelected then
				local r_s, g_s, b_s = config.itemSelectedColor:ToRGB()
				raylib.lib.DrawRectangleRounded(
					rect:translate(itemRect),
					0.2,
					8,
					structs.Color:new({
						r = r_s,
						g = g_s,
						b = b_s,
						a = 255,
					})
				)
			elseif isHovered then
				local r_h, g_h, b_h = config.itemHoverColor:ToRGB()
				raylib.lib.DrawRectangleRounded(
					rect:translate(itemRect),
					0.2,
					8,
					structs.Color:new({
						r = r_h,
						g = g_h,
						b = b_h,
						a = 255,
					})
				)
			end

			raylib.lib.DrawText(opt.text, x + 20, listY + 8, 17, raylib.const.WHITE)

			if isHovered and raylib.lib.IsMouseButtonPressed(0) == 1 then
				opt.callback()
				wrapper.toggle(false)
			end

			listY = listY + 40
		end

		if #filtered == 0 and #config.searchText > 0 then
			raylib.lib.DrawText(
				"No results found",
				x + 20,
				listY + 10,
				16,
				structs.Color:new({ r = 150, g = 150, b = 150, a = 255 })
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
