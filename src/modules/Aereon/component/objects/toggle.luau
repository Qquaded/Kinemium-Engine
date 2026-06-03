local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1],
			data.y or data[2],
			data.width or data[3] or 50,
			data.height or data[4] or 25
		),
		value = data.value or false,
		onChanged = data.onChanged,
		offColor = data.offColor or color3.new(0.3, 0.3, 0.3),
		onColor = data.onColor or color3.new(0.02, 0.5, 1),
		handleColor = data.handleColor or color3.new(1, 1, 1),
		animProgress = data.value and 1 or 0,
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
		config.value = v
	end

	wrapper.getValue = function()
		return config.value
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local targetProgress = config.value and 1 or 0
		config.animProgress = config.animProgress + (targetProgress - config.animProgress) * 0.15

		local currentColor = color3.new(
			config.offColor.R + (config.onColor.R - config.offColor.R) * config.animProgress,
			config.offColor.G + (config.onColor.G - config.offColor.G) * config.animProgress,
			config.offColor.B + (config.onColor.B - config.offColor.B) * config.animProgress
		)

		raylib.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, currentColor:ToRaylib(0))

		local handleRadius = r.height * 0.35
		local handlePadding = r.height * 0.15
		local handleMinX = r.x + handlePadding + handleRadius
		local handleMaxX = r.x + r.width - handlePadding - handleRadius
		local handleX = handleMinX + (handleMaxX - handleMinX) * config.animProgress
		local handleY = r.y + r.height / 2

		raylib.lib.DrawCircleV(vector.create(handleX, handleY), handleRadius, config.handleColor:ToRaylib(0))

		if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
			config.value = not config.value
			if config.onChanged then
				config.onChanged(config.value)
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
