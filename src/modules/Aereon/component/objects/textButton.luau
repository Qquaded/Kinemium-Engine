local color3 = require("@Color3")
local rect = require("@arect")
local effects = require("./effects")

return function(objects, data, raylib)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 100,
			data.height or data[4] or 32
		),
		text = data.text or "Button",
		font = data.font,
		fontSize = data.fontSize or 18,
		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		textTransparency = data.textTransparency or 0,
		backgroundTransparency = data.backgroundTransparency or 0,
		hoverTransparency = data.hoverTransparency or data.backgroundTransparency or 0,
		pressTransparency = data.pressTransparency or data.hoverTransparency or data.backgroundTransparency or 0,
		rounded = data.rounded or { 0.3, 8 },
		onClick = data.onClick,
		shadowColor = data.shadowColor or color3.new(0, 0, 0),
		shadowLayers = data.shadowLayers or 2,
		shadowOffsetX = data.shadowOffsetX or 0,
		shadowOffsetY = data.shadowOffsetY or 4,
		shadowSpread = data.shadowSpread or 3,
	}

	local buttonEffects = effects({
		baseColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		baseTransparency = config.backgroundTransparency,
		hoverTransparency = config.hoverTransparency,
		pressTransparency = config.pressTransparency,
		shadowColor = config.shadowColor,
		enablePress = true,
		shadowLayers = config.shadowLayers,
		shadowOffsetX = config.shadowOffsetX,
		shadowOffsetY = config.shadowOffsetY,
		shadowSpread = config.shadowSpread,
		pressSquish = 2,
	}, {}, raylib)

	local function lerp(a, b, t)
		return a + (b - a) * t
	end

	local wrapper = {}
	wrapper.set = function(prop, value)
		config[prop] = value
		if prop == "backgroundColor" then
			buttonEffects.setBaseColor(value)
		elseif prop == "backgroundTransparency" then
			buttonEffects.setBaseTransparency(value)
		elseif prop == "hoverColor" then
			buttonEffects.setHoverColor(value)
		elseif prop == "hoverTransparency" then
			buttonEffects.setHoverTransparency(value)
		elseif prop == "pressColor" then
			buttonEffects.setPressColor(value)
		elseif prop == "pressTransparency" then
			buttonEffects.setPressTransparency(value)
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

		buttonEffects.setRect(r)
		buttonEffects.update(dt)

		-- Render all effects (shadows, glow, background)
		local drawRect = buttonEffects.renderAll(r, config.rounded)

		-- Text
		local textWidth
		if config.font then
			textWidth = raylib.lib.MeasureTextEx(config.font, config.text, config.fontSize, 1).x
		else
			textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
		end

		local requiredWidth = textWidth + (config.paddingX or 32)
		if config.obj_rect.width < requiredWidth then
			config.obj_rect.width = requiredWidth
			r.width = requiredWidth
			drawRect.width = requiredWidth
		end

		local textX = drawRect.x + (drawRect.width - textWidth) / 2
		local textY = drawRect.y + (drawRect.height - config.fontSize) / 2

		local shadowOffset = lerp(1, 0, buttonEffects.getPressProgress())
		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.text,
				vector.create(textX + shadowOffset, textY + shadowOffset),
				config.fontSize,
				1,
				color3.new(0, 0, 0):ToRaylib(0.55 + config.textTransparency)
			)
			raylib.lib.DrawTextEx(
				config.font,
				config.text,
				vector.create(textX, textY),
				config.fontSize,
				1,
				config.textColor:ToRaylib(config.textTransparency)
			)
		else
			raylib.lib.DrawText(
				config.text,
				textX + shadowOffset,
				textY + shadowOffset,
				config.fontSize,
				color3.new(0, 0, 0):ToRaylib(0.55 + config.textTransparency)
			)
			raylib.lib.DrawText(
				config.text,
				textX,
				textY,
				config.fontSize,
				config.textColor:ToRaylib(config.textTransparency)
			)
		end

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
