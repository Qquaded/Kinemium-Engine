local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		x = data.x or data[1],
		y = data.y or data[2],
		radius = data.radius or data[3] or 20,
		color = data.color or color3.new(0.02, 0.5, 1),
		thickness = data.thickness or 3,
		rotation = 0,
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
		config.rotation = config.rotation + dt * 180
		if config.rotation >= 360 then
			config.rotation = config.rotation - 360
		end

		raylib.lib.DrawRing(
			vector.create(config.x, config.y),
			config.radius - config.thickness,
			config.radius,
			config.rotation,
			config.rotation + 270,
			32,
			config.color:ToRaylib(0)
		)
	end

	table.insert(objects, wrapper)
	return wrapper
end
