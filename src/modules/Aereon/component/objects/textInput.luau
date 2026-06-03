local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 30),
		text = data.text or "",
		placeholder = data.placeholder or "Type here...",
		font = data.font or defaultFont,
		fontSize = data.fontSize or 18,
		spacing = data.spacing or 1,
		backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		placeholderColor = data.placeholderColor or color3.new(0.5, 0.5, 0.5),
		focusColor = data.focusColor or color3.new(0.02, 0.5, 1),
		onChanged = data.onChanged,
		focused = false,
		cursorBlink = 0,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setText = function(t)
		config.text = t
	end

	wrapper.getText = function()
		return config.text
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		config.cursorBlink = config.cursorBlink + dt

		local borderColor = config.focused and config.focusColor or color3.new(0.3, 0.3, 0.3)

		raylib.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, config.backgroundColor:ToRaylib(0))

		raylib.lib.DrawRectangleRoundedLinesEx(rect:translate(r), 0.2, 8, 2, borderColor:ToRaylib(0))

		local displayText = config.text
		local textColor = config.textColor
		if displayText == "" and not config.focused then
			displayText = config.placeholder
			textColor = config.placeholderColor
		end

		local textX = r.x + 8
		local textY = r.y + (r.height - config.fontSize) / 2

		raylib.lib.DrawTextEx(
			config.font,
			tostring(displayText),
			vector.create(textX, textY),
			config.fontSize,
			config.spacing,
			textColor:ToRaylib(0)
		)

		if config.focused and math.floor(config.cursorBlink * 2) % 2 == 0 then
			local textWidth = raylib.lib.MeasureTextEx(config.font, config.text, config.fontSize, config.spacing).x
			raylib.lib.DrawRectangle(textX + textWidth + 2, textY, 2, config.fontSize, config.textColor:ToRaylib(0))
		end

		if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
			config.focused = true
		elseif not rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
			config.focused = false
		end

		if config.focused then
			local key = raylib.lib.GetCharPressed()
			while key > 0 do
				if key >= 32 and key <= 126 then
					config.text = config.text .. string.char(key)
					if config.onChanged then
						config.onChanged(config.text)
					end
				end
				key = raylib.lib.GetCharPressed()
			end

			if raylib.lib.IsKeyPressed(259) == 1 and #config.text > 0 then
				config.text = string.sub(config.text, 1, -2)
				if config.onChanged then
					config.onChanged(config.text)
				end
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
