local adapter = require("@RaylibAdapter")
local structs = adapter.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = adapter.lib.GetFontDefault()

local immediate = {}

immediate.switch = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 60,
		data.height or data[4] or 30
	)
	local value = data.value or false
	local onChanged = data.onChanged
	local offColor = data.offColor or color3.new(0.25, 0.25, 0.25)
	local onColor = data.onColor or color3.new(0.3, 0.7, 0.3)
	local handleColor = data.handleColor or color3.new(1, 1, 1)

	local animProgress = value and 1 or 0

	local currentColor = color3.new(
		offColor.R + (onColor.R - offColor.R) * animProgress,
		offColor.G + (onColor.G - offColor.G) * animProgress,
		offColor.B + (onColor.B - offColor.B) * animProgress
	)

	adapter.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, currentColor:ToRaylib(0))

	local handleSize = r.height - 6
	local handleMinX = r.x + 3
	local handleMaxX = r.x + r.width - handleSize - 3
	local handleX = handleMinX + (handleMaxX - handleMinX) * animProgress
	local handleY = r.y + 3

	adapter.lib.DrawRectangleRounded(
		structs.Rectangle:new({ x = handleX, y = handleY, width = handleSize, height = handleSize }),
		0.5,
		8,
		handleColor:ToRaylib(0)
	)

	if rect.MouseIsInRect(r) and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
		value = not value
		if onChanged then
			onChanged(value)
		end
	end

	return value
end

immediate.textbox = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 200,
		data.height or data[4] or 30
	)
	local text = data.text or ""
	local placeholder = data.placeholder or "Type here..."
	local fontSize = data.fontSize or 18
	local backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15)
	local textColor = data.textColor or color3.new(1, 1, 1)
	local placeholderColor = data.placeholderColor or color3.new(0.5, 0.5, 0.5)
	local focusColor = data.focusColor or color3.new(0.02, 0.5, 1)
	local onChanged = data.onChanged

	-- Simplified focus and cursor (no state persistence)
	local focused = false
	local cursorBlink = 0

	local borderColor = focused and focusColor or color3.new(0.3, 0.3, 0.3)

	adapter.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, backgroundColor:ToRaylib(0))
	adapter.lib.DrawRectangleRoundedLinesEx(rect:translate(r), 0.2, 8, 2, borderColor:ToRaylib(0))

	local displayText = text
	local displayColor = textColor
	if displayText == "" and not focused then
		displayText = placeholder
		displayColor = placeholderColor
	end

	local textX = r.x + 8
	local textY = r.y + (r.height - fontSize) / 2

	adapter.lib.DrawText(tostring(displayText), textX, textY, fontSize, displayColor:ToRaylib(0))

	if focused and math.floor(cursorBlink * 2) % 2 == 0 then
		local textWidth = adapter.lib.MeasureText(text, fontSize)
		adapter.lib.DrawRectangle(textX + textWidth + 2, textY, 2, fontSize, textColor:ToRaylib(0))
	end

	if rect.MouseIsInRect(r) and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
		focused = true
	elseif not rect.MouseIsInRect(r) and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
		focused = false
	end

	if focused then
		local key = adapter.lib.GetCharPressed()
		while key > 0 do
			if key >= 32 and key <= 126 then
				text = text .. string.char(key)
				if onChanged then
					onChanged(text)
				end
			end
			key = adapter.lib.GetCharPressed()
		end

		if adapter.lib.IsKeyPressed(259) == 1 and #text > 0 then
			text = string.sub(text, 1, -2)
			if onChanged then
				onChanged(text)
			end
		end
	end

	return text
end

immediate.dropdown = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 200,
		data.height or data[4] or 30
	)
	local options = data.options or { "Option 1", "Option 2", "Option 3" }
	local selectedIndex = data.selectedIndex or 1
	local backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2)
	local hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3)
	local textColor = data.textColor or color3.new(1, 1, 1)
	local fontSize = data.fontSize or 18
	local onSelect = data.onSelect

	local expanded = data.expanded or false

	adapter.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, backgroundColor:ToRaylib(0))

	local selectedText = options[selectedIndex] or "Select..."
	local textX = r.x + 8
	local textY = r.y + (r.height - fontSize) / 2

	adapter.lib.DrawText(selectedText, textX, textY, fontSize, textColor:ToRaylib(0))

	local arrowSize = 8
	local arrowX = r.x + r.width - arrowSize - 8
	local arrowY = r.y + r.height / 2
	if expanded then
		adapter.lib.DrawTriangle(
			vector.create(arrowX, arrowY + arrowSize / 2),
			vector.create(arrowX + arrowSize, arrowY + arrowSize / 2),
			vector.create(arrowX + arrowSize / 2, arrowY - arrowSize / 2),
			textColor:ToRaylib(0)
		)
	else
		adapter.lib.DrawTriangle(
			vector.create(arrowX, arrowY - arrowSize / 2),
			vector.create(arrowX + arrowSize, arrowY - arrowSize / 2),
			vector.create(arrowX + arrowSize / 2, arrowY + arrowSize / 2),
			textColor:ToRaylib(0)
		)
	end

	if rect.MouseIsInRect(r) and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
		expanded = not expanded
	end

	if expanded then
		local itemHeight = r.height
		local listHeight = itemHeight * #options
		local listY = r.y + r.height + 2

		adapter.lib.DrawRectangleRounded(
			structs.Rectangle:new({ x = r.x, y = listY, width = r.width, height = listHeight }),
			0.2,
			8,
			backgroundColor:ToRaylib(0)
		)

		for i, option in ipairs(options) do
			local itemY = listY + (i - 1) * itemHeight
			local itemRect = rect.new(r.x, itemY, r.width, itemHeight)

			if rect.MouseIsInRect(itemRect) then
				adapter.lib.DrawRectangle(
					itemRect.x,
					itemRect.y,
					itemRect.width,
					itemRect.height,
					hoverColor:ToRaylib(0)
				)

				if adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
					selectedIndex = i
					expanded = false
					if onSelect then
						onSelect(i, option)
					end
				end
			end

			adapter.lib.DrawText(option, r.x + 8, itemY + (itemHeight - fontSize) / 2, fontSize, textColor:ToRaylib(0))
		end
	end

	return selectedIndex, options[selectedIndex], expanded
end

immediate.colorpicker = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 300,
		data.height or data[4] or 200
	)
	local color = data.color or color3.new(1, 1, 1)
	local onChanged = data.onChanged

	-- Main gradient area (saturation/value)
	local gradientRect = rect.new(r.x, r.y, r.width - 40, r.height)

	-- Draw saturation/value gradient
	for y = 0, gradientRect.height - 1 do
		for x = 0, gradientRect.width - 1 do
			local s = x / gradientRect.width
			local v = 1 - (y / gradientRect.height)

			-- Convert HSV to RGB (assuming current hue)
			local h = color:ToHSV()
			local c = v * s
			local x_val = c * (1 - math.abs((h / 60) % 2 - 1))
			local m = v - c

			local r_val, g_val, b_val
			if h < 60 then
				r_val, g_val, b_val = c, x_val, 0
			elseif h < 120 then
				r_val, g_val, b_val = x_val, c, 0
			elseif h < 180 then
				r_val, g_val, b_val = 0, c, x_val
			elseif h < 240 then
				r_val, g_val, b_val = 0, x_val, c
			elseif h < 300 then
				r_val, g_val, b_val = x_val, 0, c
			else
				r_val, g_val, b_val = c, 0, x_val
			end

			adapter.lib.DrawPixel(
				gradientRect.x + x,
				gradientRect.y + y,
				color3.new(r_val + m, g_val + m, b_val + m):ToRaylib(0)
			)
		end
	end

	-- Hue bar
	local hueBarRect = rect.new(r.x + r.width - 30, r.y, 30, r.height)

	for y = 0, hueBarRect.height - 1 do
		local hue = (y / hueBarRect.height) * 360
		local hueColor = color3.fromHSV(hue, 1, 1)
		adapter.lib.DrawRectangle(hueBarRect.x, hueBarRect.y + y, hueBarRect.width, 1, hueColor:ToRaylib(0))
	end

	if rect.MouseIsInRect(gradientRect) and adapter.lib.IsMouseButtonDown(0) == 1 and not _G.__aereon_blockInput then
		local mouseX = adapter.lib.GetMouseX()
		local mouseY = adapter.lib.GetMouseY()

		local s = math.clamp((mouseX - gradientRect.x) / gradientRect.width, 0, 1)
		local v = math.clamp(1 - (mouseY - gradientRect.y) / gradientRect.height, 0, 1)
		local h = color:ToHSV()

		color = color3.fromHSV(h, s, v)
		if onChanged then
			onChanged(color)
		end
	end

	if rect.MouseIsInRect(hueBarRect) and adapter.lib.IsMouseButtonDown(0) == 1 and not _G.__aereon_blockInput then
		local mouseY = adapter.lib.GetMouseY()
		local hue = math.clamp((mouseY - hueBarRect.y) / hueBarRect.height * 360, 0, 360)
		local _, s, v = color:ToHSV()

		color = color3.fromHSV(hue, s, v)
		if onChanged then
			onChanged(color)
		end
	end

	local h, s, v = color:ToHSV()
	local circleX = gradientRect.x + s * gradientRect.width
	local circleY = gradientRect.y + (1 - v) * gradientRect.height
	adapter.lib.DrawCircleLines(circleX, circleY, 5, color3.new(1, 1, 1):ToRaylib(0))
	adapter.lib.DrawCircleLines(circleX, circleY, 6, color3.new(0, 0, 0):ToRaylib(0))

	local hueY = hueBarRect.y + (h / 360) * hueBarRect.height
	adapter.lib.DrawRectangle(hueBarRect.x, hueY - 2, hueBarRect.width, 4, color3.new(1, 1, 1):ToRaylib(0))

	return color
end

immediate.slider = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 200,
		data.height or data[4] or 20
	)
	local value = data.value or 0
	local min = data.min or 0
	local max = data.max or 100
	local backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2)
	local fillColor = data.fillColor or color3.new(0.3, 0.7, 0.3)
	local handleColor = data.handleColor or color3.new(1, 1, 1)
	local onChanged = data.onChanged

	local handleSize = r.height + 4
	local handleX = r.x + (value - min) / (max - min) * (r.width - handleSize)
	local handleY = r.y - 2

	-- Background
	adapter.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, backgroundColor:ToRaylib(0))

	-- Fill
	local fillWidth = (value - min) / (max - min) * r.width
	adapter.lib.DrawRectangleRounded(
		structs.Rectangle:new({ x = r.x, y = r.y, width = fillWidth, height = r.height }),
		0.5,
		8,
		fillColor:ToRaylib(0)
	)

	-- Handle
	adapter.lib.DrawRectangleRounded(
		structs.Rectangle:new({ x = handleX, y = handleY, width = handleSize, height = handleSize }),
		0.5,
		8,
		handleColor:ToRaylib(0)
	)

	-- Handle interaction
	local handleRect = rect.new(handleX, handleY, handleSize, handleSize)
	if rect.MouseIsInRect(handleRect) and adapter.lib.IsMouseButtonDown(0) == 1 and not _G.__aereon_blockInput then
		local mouseX = adapter.lib.GetMouseX()
		local newValue = min + (mouseX - r.x) / r.width * (max - min)
		value = math.clamp(newValue, min, max)
		if onChanged then
			onChanged(value)
		end
	end

	return value
end

immediate.textbutton = function(data)
	local r = rect.new(
		data.x or data[1] or 0,
		data.y or data[2] or 0,
		data.width or data[3] or 120,
		data.height or data[4] or 40
	)
	local text = data.text or "Button"
	local fontSize = data.fontSize or 18
	local backgroundColor = data.backgroundColor or color3.new(0.3, 0.3, 0.3)
	local hoverColor = data.hoverColor or color3.new(0.4, 0.4, 0.4)
	local activeColor = data.activeColor or color3.new(0.25, 0.25, 0.25)
	local textColor = data.textColor or color3.new(1, 1, 1)
	local cornerRadius = data.cornerRadius or 0.2
	local onClick = data.onClick

	local isHovered = rect.MouseIsInRect(r)
	local isPressed = isHovered and adapter.lib.IsMouseButtonDown(0) == 1
	local wasClicked = isHovered and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput

	-- Determine button color based on state
	local currentColor = backgroundColor
	if isPressed then
		currentColor = activeColor
	elseif isHovered then
		currentColor = hoverColor
	end

	-- Draw button background
	adapter.lib.DrawRectangleRounded(rect:translate(r), cornerRadius, 8, currentColor:ToRaylib(0))

	-- Draw text centered
	local textWidth = adapter.lib.MeasureText(text, fontSize)
	local textX = r.x + (r.width - textWidth) / 2
	local textY = r.y + (r.height - fontSize) / 2

	adapter.lib.DrawText(text, textX, textY, fontSize, textColor:ToRaylib(0))

	-- Handle click
	if wasClicked and onClick then
		onClick()
	end

	return wasClicked
end

return immediate
