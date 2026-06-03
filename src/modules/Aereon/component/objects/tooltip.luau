local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		targetRect = data.targetRect,
		text = data.text or "Tooltip",
		font = data.font or defaultFont,
		fontSize = data.fontSize or 14,
		spacing = data.spacing or 1,
		backgroundColor = data.backgroundColor or color3.new(0.1, 0.1, 0.1),
		textColor = data.textColor or color3.new(1, 1, 1),
		padding = data.padding or 8,
		visible = false,
		animAlpha = 0,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.targetRect then
			return
		end

		local isHovered = rect.MouseIsInRect(config.targetRect)
		local targetAlpha = isHovered and 1 or 0
		config.animAlpha = config.animAlpha + (targetAlpha - config.animAlpha) * 0.15

		if config.animAlpha > 0.01 then
			local textWidth = raylib.lib.MeasureTextEx(config.font, config.text, config.fontSize, config.spacing).x
			local tooltipWidth = textWidth + config.padding * 2
			local tooltipHeight = config.fontSize + config.padding * 2

			local tooltipX = config.targetRect.x + config.targetRect.width / 2 - tooltipWidth / 2
			local tooltipY = config.targetRect.y - tooltipHeight - 5

			local tooltipRect = rect.new(tooltipX, tooltipY, tooltipWidth, tooltipHeight)

			raylib.lib.DrawRectangleRounded(
				rect:translate(tooltipRect),
				0.2,
				8,
				config.backgroundColor:ToRaylib(1 - config.animAlpha)
			)

			raylib.lib.DrawTextEx(
				config.font,
				config.text,
				vector.create(tooltipX + config.padding, tooltipY + config.padding),
				config.fontSize,
				config.spacing,
				config.textColor:ToRaylib(1 - config.animAlpha)
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
