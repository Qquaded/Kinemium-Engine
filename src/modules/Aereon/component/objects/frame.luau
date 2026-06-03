local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = data.rect
			or rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		color = data.color or color3.new(1, 1, 1),
		raylib_color = data.raylib_color or color3.new(1, 1, 1):ToRaylib(0),
		bgtransparency = data.bgtransparency or 0,
		clicked = data.clicked or nil,
		hoveredCallback = data.hoveredCallback or nil,
		rounded = data.rounded or nil,
		disabled = data.disabled or false,
		modifiers = {},
	}

	local wrapper = {}

	wrapper.modifers = {
		outline = function(value, color, transparency)
			table.insert(config.modifiers, function()
				if config.rounded then
					raylib.lib.DrawRectangleRoundedLinesEx(
						rect:translate(config.obj_rect),
						config.rounded[1],
						config.rounded[2],
						value,
						config.color:ToRaylib(transparency)
					)
				else
					raylib.lib.DrawRectangleLinesEx(
						rect:translate(config.obj_rect),
						value,
						config.color:ToRaylib(transparency)
					)
				end
			end)
			return wrapper
		end,

		mouseIsIn = function(callback)
			if rect.MouseIsInRect(config.obj_rect) then
				callback(wrapper)
			end
		end,

		custom = function(callback)
			callback(wrapper)
		end,
	}

	wrapper.disabled = function(value)
		config.disabled = value
		return wrapper
	end

	wrapper.clicked = function(callback)
		config.clicked = callback
		return wrapper
	end

	wrapper.hovered = function(hoverCallback)
		config.hoveredCallback = hoverCallback
		return wrapper
	end

	wrapper.setTransparency = function(t)
		config.bgtransparency = t
		config.raylib_color = config.color:ToRaylib(t)
		return wrapper
	end

	wrapper.width = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, v, config.obj_rect.height)
		return wrapper
	end

	wrapper.height = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, v)
		return wrapper
	end

	wrapper.rounded = function(radius, segments)
		config.rounded = { radius, segments }
	end

	wrapper.posx = function(v)
		config.obj_rect = rect.new(v, config.obj_rect.y, config.obj_rect.width, config.obj_rect.height)
		return wrapper
	end

	wrapper.posy = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, v, config.obj_rect.width, config.obj_rect.height)
		return wrapper
	end

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.render = function(dt)
		if config.clicked ~= nil then
			if not config.disabled then
				rect.Button(config.obj_rect, function(a0)
					config.clicked(wrapper)
				end)
			end
		end
		if config.hoveredCallback ~= nil then
			rect.Hover(config.obj_rect, function(a0)
				config.hoveredCallback(wrapper)
			end)
		end

		if config.rounded then
			raylib.lib.DrawRectangleRounded(
				rect:translate(config.obj_rect),
				config.rounded[1],
				config.rounded[2],
				config.raylib_color
			)
		else
			raylib.lib.DrawRectangleRec(rect:translate(config.obj_rect), config.raylib_color)
		end

		for _, modifier in pairs(config.modifiers) do
			modifier()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
