local raylib = require("@raylib")
local rect = require("@arect")
local Color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1],
			data.y or data[2],
			data.size or data[3] or 20,
			data.size or data[4] or 20
		),
		value = data.value or false,
		onChanged = data.onChanged,
		boxColor = data.boxColor or Color3.new(0.2, 0.2, 0.2),
		checkColor = data.checkColor or Color3.new(1, 1, 1),
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
		config.animProgress = config.animProgress + (targetProgress - config.animProgress) * 0.2

		raylib.lib.DrawRectangleRounded(rect:translate(r), 0, 0, config.boxColor:ToRaylib(0))
		raylib.lib.DrawRectangleRoundedLinesEx(rect:translate(r), 0, 0, 1, config.checkColor:ToRaylib(0))

		if config.animProgress > 0.01 then
			local innerRect = rect.new(r.x, r.y, r.width, r.height)

			local scale = config.animProgress
			local scaledWidth = innerRect.width * scale
			local scaledHeight = innerRect.height * scale
			local offsetX = (innerRect.width - scaledWidth) / 2
			local offsetY = (innerRect.height - scaledHeight) / 2

			local scaledRect = rect.new(innerRect.x + offsetX, innerRect.y + offsetY, scaledWidth, scaledHeight)

			raylib.lib.DrawRectangleRounded(rect:translate(scaledRect), 0, 0, config.checkColor:ToRaylib(0))
		end

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
