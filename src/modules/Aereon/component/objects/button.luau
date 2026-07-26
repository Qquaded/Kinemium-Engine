local rect = require("@arect")
local color3 = require("@Color3")
local effects = require("./effects")

return function(objects, data, raylib)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		text = data.text or "Button",
		fontSize = data.fontSize or 18,
		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		rounded = data.rounded or { 0.3, 8 },
		onClick = data.onClick,

		backgroundTransparency = data.backgroundTransparency or 0,
	}

	local buttonEffects = effects({
		baseColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		enableShadows = false,
		enableGlow = false,
		enablePress = true,
	}, {}, raylib)

	local wrapper = {}

	wrapper.set = function(prop, value)
		config[prop] = value
		if prop == "backgroundColor" then
			buttonEffects.setBaseColor(value)
		elseif prop == "hoverColor" then
			buttonEffects.setHoverColor(value)
		elseif prop == "pressColor" then
			buttonEffects.setPressColor(value)
		end
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		-- Update effects
		buttonEffects.setRect(r)
		buttonEffects.update(dt)

		-- Render background only (no shadows/glow for legacy button)
		local drawRect = buttonEffects.renderBackground(r, config.rounded, config.backgroundTransparency)

		-- Text
		local textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
		local textX = drawRect.x + (drawRect.width - textWidth) / 2
		local textY = drawRect.y + (drawRect.height - config.fontSize) / 2

		raylib.lib.DrawText(config.text, textX, textY, config.fontSize, config.textColor:ToRaylib(0))

		if
			buttonEffects.isHovered()
			and raylib.lib.IsMouseButtonReleased(0) == 1
			and not _G.__aereon_blockInput
			and config.onClick
		then
			config.onClick()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
