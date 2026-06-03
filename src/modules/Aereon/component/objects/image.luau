local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		texture = data.texture,
		rounded = data.rounded or nil,
	}

	local wrapper = {}

	wrapper.setTexture = function(tex)
		config.texture = tex
	end

	wrapper.render = function(dt)
		if not config.texture then
			return
		end

		local r = config.obj_rect

		if config.rounded then
			raylib.lib.BeginScissorMode(r.x, r.y, r.width, r.height)
			raylib.lib.DrawTexturePro(
				config.texture.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.texture.x, height = config.texture.y }),
				rect:translate(r),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
			raylib.lib.EndScissorMode()
		else
			raylib.lib.DrawTexturePro(
				config.texture.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.texture.x, height = config.texture.y }),
				rect:translate(r),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
