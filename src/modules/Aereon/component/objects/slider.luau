local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 20),
		value = data.value or 0.5,
		min = data.min or 0,
		max = data.max or 1,
		onChanged = data.onChanged,
		trackColor = data.trackColor or color3.new(0.15, 0.15, 0.15),
		fillColor = data.fillColor or color3.new(0.02, 0.5, 1),
		handleColor = data.handleColor or color3.new(1, 1, 1),
		dragging = false,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setValue = function(v)
		config.value = math.clamp(v, config.min, config.max)
	end

	wrapper.getValue = function()
		return config.value
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1

		local trackHeight = r.height * 0.3
		local trackY = r.y + (r.height - trackHeight) / 2
		local trackRect = rect.new(r.x, trackY, r.width, trackHeight)

		if mouseDown and (config.dragging or rect.MouseIsInRect(r)) and not _G.__aereon_blockInput then
			config.dragging = true
			local normalizedX = math.clamp((mousePos.x - r.x) / r.width, 0, 1)
			config.value = config.min + normalizedX * (config.max - config.min)
			if config.onChanged then
				config.onChanged(config.value)
			end
		else
			config.dragging = false
		end

		raylib.lib.DrawRectangleRounded(rect:translate(trackRect), 0.5, 8, config.trackColor:ToRaylib(0))

		local normalizedValue = (config.value - config.min) / (config.max - config.min)
		local fillWidth = r.width * normalizedValue
		local fillRect = rect.new(r.x, trackY, fillWidth, trackHeight)

		raylib.lib.DrawRectangleRounded(rect:translate(fillRect), 0.5, 8, config.fillColor:ToRaylib(0))

		local handleX = r.x + fillWidth
		local handleY = r.y + r.height / 2
		local handleRadius = r.height * 0.6

		raylib.lib.DrawCircleV(vector.create(handleX, handleY), handleRadius, config.handleColor:ToRaylib(0))
	end

	table.insert(objects, wrapper)
	return wrapper
end
