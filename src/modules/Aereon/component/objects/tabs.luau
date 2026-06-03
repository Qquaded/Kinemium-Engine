local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")
local effects = require("./effects")
local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 40),
		tabs = data.tabs or { "Tab 1", "Tab 2", "Tab 3" },
		activeIndex = data.activeIndex or 1,
		onTabChange = data.onTabChange,
		font = data.font or defaultFont,
		backgroundColor = data.backgroundColor or color3.new(1, 1, 1),
		backgroundTransparency = data.backgroundTransparency or 0,
		activeColor = data.activeColor or color3.new(0.02, 0.5, 1),
		hoverColor = data.hoverColor or color3.new(0.25, 0.25, 0.3),
		textColor = data.textColor or color3.new(0, 0, 0),
		fontSize = data.fontSize or 16,
		spacing = data.spacing or 1,
		animX = 0,
		tabEffects = {},
	}

	for i = 1, #config.tabs do
		config.tabEffects[i] = effects({
			baseColor = config.backgroundColor,
			hoverColor = config.hoverColor,
			pressColor = config.activeColor,
			enableShadows = false,
			enableGlow = false,
			enablePress = false,
		})
	end

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end

		config[prop] = value

		return wrapper
	end

	wrapper.setActive = function(index)
		config.activeIndex = math.clamp(index, 1, #config.tabs)
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		local tabWidth = r.width / #config.tabs

		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			0.2,
			8,
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		local targetX = r.x + (config.activeIndex - 1) * tabWidth

		config.animX = config.animX + (targetX - config.animX) * 0.15

		local indicatorRect = rect.new(config.animX, r.y + r.height - 3, tabWidth, 3)

		raylib.lib.DrawRectangle(
			indicatorRect.x,
			indicatorRect.y,
			indicatorRect.width,
			indicatorRect.height,
			config.activeColor:ToRaylib(0)
		)

		for i, tab in ipairs(config.tabs) do
			local tabX = r.x + (i - 1) * tabWidth
			local tabRect = rect.new(tabX, r.y, tabWidth, r.height)

			-- Update effects for this tab
			if not config.tabEffects[i] then
				-- add it
				config.tabEffects[i] = effects({
					baseColor = config.backgroundColor,
					hoverColor = config.hoverColor,
					pressColor = config.activeColor,
					enableShadows = false,
					enableGlow = false,
					enablePress = false,
				})
			end

			config.tabEffects[i].setRect(tabRect)
			config.tabEffects[i].update(dt)

			-- Draw tab background with hover effect

			local tabBgColor = config.backgroundColor

			if i == config.activeIndex then
				tabBgColor = config.activeColor
			elseif config.tabEffects[i].isHovered() then
				tabBgColor = config.tabEffects[i].getCurrentColor()
			end

			raylib.lib.DrawRectangle(tabRect.x, tabRect.y, tabRect.width, tabRect.height, tabBgColor:ToRaylib(0.5))

			local textWidth = raylib.lib.MeasureTextEx(config.font, tab, config.fontSize, config.spacing).x

			local textX = tabX + (tabWidth - textWidth) / 2

			local textY = r.y + (r.height - config.fontSize) / 2

			raylib.lib.DrawTextEx(
				config.font,
				tab,
				vector.create(textX, textY),
				config.fontSize,
				config.spacing,
				config.textColor:ToRaylib(0)
			)

			if config.tabEffects[i].isHovered() and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.activeIndex = i

				if config.onTabChange then
					config.onTabChange(i, tab)
				end
			end
		end
	end

	table.insert(objects, wrapper)

	return wrapper
end
