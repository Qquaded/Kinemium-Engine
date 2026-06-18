local raylib = require("@raylib")

local structs = raylib.structs

local rect = require("@arect")

local color3 = require("@Color3")

local effects = require("./effects")

return function(objects, data)
	local config = {

		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 40,
			data.height or data[4] or 40
		),

		image = data.image or data.icon,

		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),

		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),

		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),

		imageColor = data.imageColor or color3.new(1, 1, 1),

		imageTransparency = data.imageTransparency or 0,

		imageScale = data.imageScale or 0.7,

		rounded = data.rounded or { 0.5, 8 },

		onClick = data.onClick,

		shadowColor = data.shadowColor or color3.new(0, 0, 0),

		shadowLayers = data.shadowLayers or 6,

		shadowOffsetX = data.shadowOffsetX or 0,

		shadowOffsetY = data.shadowOffsetY or 4,

		shadowSpread = data.shadowSpread or 3,
	}

	-- Create effects instance

	local buttonEffects = effects({

		baseColor = config.backgroundColor,

		hoverColor = config.hoverColor,

		pressColor = config.pressColor,

		shadowColor = config.shadowColor,

		shadowLayers = config.shadowLayers,

		shadowOffsetX = config.shadowOffsetX,

		shadowOffsetY = config.shadowOffsetY,

		shadowSpread = config.shadowSpread,

		pressSquish = 2,
	})

	local function lerp(a, b, t)
		return a + (b - a) * t
	end

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

		-- Render all effects (shadows, glow, background)

		local drawRect = buttonEffects.renderAll(r, config.rounded)

		-- Image

		if config.image then
			local imgSize = math.min(drawRect.width, drawRect.height) * config.imageScale

			local imgX = drawRect.x + (drawRect.width - imgSize) / 2

			local imgY = drawRect.y + (drawRect.height - imgSize) / 2

			raylib.lib.DrawTexturePro(
				config.image.texture,
				structs.Rectangle:new({
					x = 0,
					y = 0,
					width = config.image.x,
					height = config.image.y,
				}),
				structs.Rectangle:new({ x = imgX, y = imgY, width = imgSize, height = imgSize }),
				vector.create(0, 0),
				0,
				config.imageColor:ToRaylib(config.imageTransparency)
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
