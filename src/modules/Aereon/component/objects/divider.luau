local raylib = require("@raylib")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		x = data.x or data[1],
		y = data.y or data[2],
		width = data.width or data[3],
		vertical = data.vertical or false,
		height = data.height or data[4] or 1,
		color = data.color or color3.new(0.3, 0.3, 0.3),
	}

	local wrapper = {}

	wrapper.set = function(key, value)
		config[key] = value
	end

	wrapper.get = function(key)
		return config[key]
	end

	wrapper.render = function(dt)
		if config.vertical then
			raylib.lib.DrawRectangle(config.x, config.y, config.height, config.width, config.color:ToRaylib(0))
		else
			raylib.lib.DrawRectangle(config.x, config.y, config.width, config.height, config.color:ToRaylib(0))
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
