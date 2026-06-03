local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 100,
			data.height or data[4] or 100
		),
		direction = data.direction or "vertical", -- "vertical", "horizontal"
		spacing = data.spacing or 5,
		padding = data.padding or 5,
		alignment = data.alignment or "start", -- "start", "center", "end"
		children = {},
		autoSize = data.autoSize ~= false, -- If true, stack grows to fit children
		backgroundColor = data.backgroundColor or color3.new(0, 0, 0),
		backgroundTransparency = data.backgroundTransparency or 1,
	}

	local wrapper = {}

	wrapper.add = function(component)
		table.insert(config.children, component)
		return component
	end

	wrapper.set = function(prop, value)
		if prop == "width" then
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, value, config.obj_rect.height)
		elseif prop == "height" then
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, value)
		elseif prop == "obj_rect" then
			config.obj_rect = value
		else
			config[prop] = value
		end
		return wrapper
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		if config.backgroundTransparency < 1 then
			local r, g, b = config.backgroundColor:ToRGB()
			raylib.lib.DrawRectangleRec(
				rect:translate(config.obj_rect),
				structs.Color:new({ r = r, g = g, b = b, a = math.floor(255 * (1 - config.backgroundTransparency)) })
			)
		end

		local currentOffset = config.padding
		local maxWidth = 0
		local maxHeight = 0

		for _, child in ipairs(config.children) do
			local childRect = child.get_rect and child.get_rect()
			if not childRect and child.get then
				childRect = child.get("obj_rect")
			end

			if childRect then
				if config.direction == "vertical" then
					local x = config.obj_rect.x + config.padding
					if config.alignment == "center" then
						x = config.obj_rect.x + (config.obj_rect.width - childRect.width) / 2
					elseif config.alignment == "end" then
						x = config.obj_rect.x + config.obj_rect.width - childRect.width - config.padding
					end

					if child.set then
						child.set(
							"obj_rect",
							rect.new(x, config.obj_rect.y + currentOffset, childRect.width, childRect.height)
						)
					end
					if child.render then
						child.render(dt)
					end
					currentOffset = currentOffset + childRect.height + config.spacing
					maxWidth = math.max(maxWidth, childRect.width)
				else
					local y = config.obj_rect.y + config.padding
					if config.alignment == "center" then
						y = config.obj_rect.y + (config.obj_rect.height - childRect.height) / 2
					elseif config.alignment == "end" then
						y = config.obj_rect.y + config.obj_rect.height - childRect.height - config.padding
					end

					if child.set then
						child.set(
							"obj_rect",
							rect.new(config.obj_rect.x + currentOffset, y, childRect.width, childRect.height)
						)
					end
					if child.render then
						child.render(dt)
					end
					currentOffset = currentOffset + childRect.width + config.spacing
					maxHeight = math.max(maxHeight, childRect.height)
				end
			end
		end

		if config.autoSize then
			if config.direction == "vertical" then
				config.obj_rect.height = currentOffset - config.spacing + config.padding
				config.obj_rect.width = maxWidth + config.padding * 2
			else
				config.obj_rect.width = currentOffset - config.spacing + config.padding
				config.obj_rect.height = maxHeight + config.padding * 2
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
