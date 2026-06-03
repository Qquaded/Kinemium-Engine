local raylib = require("@raylib")

local structs = raylib.structs

local function c3tr(c, transparency)
	local r, g, b = c:ToRGB()

	return structs.Color:new({

		r = r,

		g = g,

		b = b,

		a = math.floor(255 * (1 - transparency)),
	})
end

local rect = require("@arect")

local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {

		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 20),

		progress = data.progress or 0,

		backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),

		fillColor = data.fillColor or color3.new(0.02, 0.5, 1),

		rounded = data.rounded or { 0.5, 8 },

		currentProgress = data.progress or 0,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end

		config[prop] = value

		return wrapper
	end

	wrapper.setProgress = function(p)
		config.progress = math.clamp(p, 0, 1)
	end

	wrapper.getProgress = function()
		return config.progress
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		config.currentProgress = config.currentProgress + (config.progress - config.currentProgress) * 0.1

		raylib.lib.DrawRectangleRounded(rect:translate(r), config.rounded[1], config.rounded[2], c3tr(config.backgroundColor, 0)
)

		local fillWidth = r.width * config.currentProgress

		if fillWidth > 0 then
			local fillRect = rect.new(r.x, r.y, fillWidth, r.height)

			raylib.lib.DrawRectangleRounded(rect:translate(fillRect), config.rounded[1], config.rounded[2], c3tr(config.fillColor, 0)
)
		end
	end

	table.insert(objects, wrapper)

	return wrapper
end
