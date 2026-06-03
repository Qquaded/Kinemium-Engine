local raylib = require("@raylib")

local structs = raylib.structs

local rect = require("@arect")

local color3 = require("@Color3")

local effects = require("./effects")

return function(objects, data)
	local config = {

		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.size or data[3] or 40, data.size or data[4] or 40
),

		icon = data.icon,

		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),

		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),

		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),

		onClick = data.onClick,
	}

	-- Create effects instance

	local buttonEffects = effects({

		baseColor = config.backgroundColor,

		hoverColor = config.hoverColor,

		pressColor = config.pressColor,

		enableShadows = false,

		enableGlow = false,

		enablePress = false,
	})

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

		-- Render background only (no shadows/glow for legacy iconButton)

		local drawRect = buttonEffects.renderBackground(r, { 0.5, 8 })

		-- Icon

		if config.icon then
			local iconSize = r.width * 0.6

			local iconX = r.x + (r.width - iconSize) / 2

			local iconY = r.y + (r.height - iconSize) / 2

			raylib.lib.DrawTexturePro(config.icon.texture, structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }), structs.Rectangle:new({
				x = iconX,
				y = iconY,
				width = iconSize,
				height = iconSize,
			}), vector.create(0, 0), 0, raylib.const.WHITE
)
		end

		if buttonEffects.isHovered() and raylib.lib.IsMouseButtonReleased(0) == 1 and config.onClick then
			config.onClick()
		end
	end

	table.insert(objects, wrapper)

	return wrapper
end
