local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		x = data.x or data[1],
		y = data.y or data[2],
		text = data.text or "1",
		font = data.font or defaultFont,
		fontSize = data.fontSize or 12,
		spacing = data.spacing or 1,
		backgroundColor = data.backgroundColor or color3.new(1, 0.2, 0.2),
		textColor = data.textColor or color3.new(1, 1, 1),
		minWidth = data.minWidth or 18,
	}

	local wrapper = {}

	wrapper.setText = function(t)
		config.text = t
	end

	wrapper.set = function(prop, value)
		config[prop] = value
	end

	wrapper.render = function(dt)
		local textWidth = raylib.lib.MeasureTextEx(config.font, config.text, config.fontSize, config.spacing).x
		local badgeWidth = math.max(config.minWidth, textWidth + 8)
		local badgeHeight = config.fontSize + 6

		local badgeRect = rect.new(config.x, config.y, badgeWidth, badgeHeight)

		raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.5, 8, config.backgroundColor:ToRaylib(0))

		local textX = config.x + (badgeWidth - textWidth) / 2
		local textY = config.y + 3

		raylib.lib.DrawTextEx(
			config.font,
			config.text,
			vector.create(textX, textY),
			config.fontSize,
			config.spacing,
			config.textColor:ToRaylib(0)
		)
	end

	table.insert(objects, wrapper)
	return wrapper
end
