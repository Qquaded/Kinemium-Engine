local raylib = require("@raylib")
local structs = raylib.structs

local function c3tr(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local rect = require("@arect")(raylib.lib)
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 900,
			data.height or data[4] or 380
		),
		visible = data.visible ~= false,
		title = data.title or "Enter Text",
		placeholder = data.placeholder or "Type here...",
		text = data.text or "",
		maxLength = data.maxLength or 100,

		backgroundColor = color3.new(0.12, 0.12, 0.14),
		keyColor = color3.new(0.18, 0.18, 0.2),
		selectedKeyColor = color3.new(0.3, 0.5, 0.9),
		textColor = color3.new(0.86, 0.86, 0.86),
		dimTextColor = color3.new(0.47, 0.47, 0.47),

		rounded = data.rounded or { 0.08, 8 },
		padding = data.padding or 20,

		onSubmit = data.onSubmit,
		onCancel = data.onCancel,
		onChange = data.onChange,

		-- Keyboard layout
		layouts = {
			lowercase = {
				{ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" },
				{ "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]" },
				{ "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'" },
				{ "SHIFT", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "BKSP" },
				{ "SPACE", "CANCEL", "SUBMIT" },
			},
			uppercase = {
				{ "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+" },
				{ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "{", "}" },
				{ "A", "S", "D", "F", "G", "H", "J", "K", "L", ":", '"' },
				{ "SHIFT", "Z", "X", "C", "V", "B", "N", "M", "<", ">", "?", "BKSP" },
				{ "SPACE", "CANCEL", "SUBMIT" },
			},
		},

		currentLayout = "lowercase",
		selectedRow = 0,
		selectedCol = 0,

		-- Animation states
		animScale = 0,
		animAlpha = 0,
		keyAnimations = {},
		keyHoverStates = {},
		cursorBlink = 0,

		-- Input timing
		repeatDelay = 0.4,
		repeatRate = 0.08,
		timeSinceInput = 0,
		lastInput = nil,
	}

	-- Initialize key animations
	for row = 0, 4 do
		config.keyAnimations[row] = {}
		config.keyHoverStates[row] = {}
	end

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.show = function()
		config.visible = true
		config.animScale = 0
		config.animAlpha = 0
		config.text = ""
		config.selectedRow = 0
		config.selectedCol = 0
		return wrapper
	end

	wrapper.hide = function()
		config.visible = false
		return wrapper
	end

	wrapper.getText = function()
		return config.text
	end

	wrapper.setText = function(text)
		config.text = text or ""
		return wrapper
	end

	local function handleKeyPress(key)
		if key == "BKSP" then
			if #config.text > 0 then
				config.text = config.text:sub(1, -2)
				if config.onChange then
					config.onChange(config.text)
				end
			end
		elseif key == "SPACE" then
			if #config.text < config.maxLength then
				config.text = config.text .. " "
				if config.onChange then
					config.onChange(config.text)
				end
			end
		elseif key == "SHIFT" then
			config.currentLayout = config.currentLayout == "lowercase" and "uppercase" or "lowercase"
		elseif key == "SUBMIT" then
			if config.onSubmit then
				config.onSubmit(config.text)
			end
			wrapper.hide()
		elseif key == "CANCEL" then
			if config.onCancel then
				config.onCancel()
			end
			wrapper.hide()
		else
			if #config.text < config.maxLength then
				config.text = config.text .. key
				if config.onChange then
					config.onChange(config.text)
				end
			end
		end
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end

		-- Smooth animations
		config.animScale = config.animScale + (1 - config.animScale) * 0.15
		config.animAlpha = config.animAlpha + (1 - config.animAlpha) * 0.12
		config.cursorBlink = (config.cursorBlink + dt * 2) % 2

		local screenWidth = raylib.lib.GetScreenWidth()
		local screenHeight = raylib.lib.GetScreenHeight()

		-- Draw overlay
		raylib.lib.DrawRectangle(0, 0, screenWidth, screenHeight, c3tr(color3.new(0, 0, 0), 1 - config.animAlpha * 0.7))

		-- Calculate keyboard position
		local kbX = config.obj_rect.x
		local kbY = config.obj_rect.y
		if config.obj_rect.x == 0 and config.obj_rect.y == 0 then
			kbX = (screenWidth - config.obj_rect.width) / 2
			kbY = (screenHeight - config.obj_rect.height) / 2
		end

		local scaledWidth = config.obj_rect.width * config.animScale
		local scaledHeight = config.obj_rect.height * config.animScale
		local scaledX = kbX + (config.obj_rect.width - scaledWidth) / 2
		local scaledY = kbY + (config.obj_rect.height - scaledHeight) / 2

		local kbRect = rect.new(scaledX, scaledY, scaledWidth, scaledHeight)

		-- Draw shadow
		for i = 0, 3 do
			local offset = 6 + i * 2
			raylib.lib.DrawRectangleRounded(
				rect:translate(
					rect.new(kbRect.x + offset - i, kbRect.y + offset, kbRect.width + i * 2, kbRect.height + i)
				),
				config.rounded[1],
				config.rounded[2],
				c3tr(color3.new(0, 0, 0), 0.9 + i * 0.02)
			)
		end

		-- Draw background
		raylib.lib.DrawRectangleRounded(
			rect:translate(kbRect),
			config.rounded[1],
			config.rounded[2],
			c3tr(config.backgroundColor, 0)
		)

		-- Draw title
		raylib.lib.DrawText(
			config.title,
			kbRect.x + config.padding,
			kbRect.y + config.padding,
			16,
			c3tr(config.textColor, 0)
		)

		-- Text input field
		local inputY = kbRect.y + config.padding + 30
		local inputHeight = 45
		local inputRect = rect.new(kbRect.x + config.padding, inputY, kbRect.width - config.padding * 2, inputHeight)

		raylib.lib.DrawRectangleRounded(rect:translate(inputRect), 0.15, 8, c3tr(color3.new(0.08, 0.08, 0.1), 0))

		local displayText = config.text
		if #displayText == 0 then
			raylib.lib.DrawText(
				config.placeholder,
				inputRect.x + 12,
				inputRect.y + 14,
				14,
				c3tr(config.dimTextColor, 0)
			)
		else
			raylib.lib.DrawText(displayText, inputRect.x + 12, inputRect.y + 14, 14, c3tr(config.textColor, 0))

			-- Blinking cursor
			if config.cursorBlink < 1 then
				local textWidth = raylib.lib.MeasureText(displayText, 14)
				raylib.lib.DrawRectangle(
					inputRect.x + 12 + textWidth + 2,
					inputRect.y + 12,
					2,
					20,
					c3tr(config.selectedKeyColor, 0)
				)
			end
		end

		-- Keyboard keys
		local keyStartY = inputY + inputHeight + 20
		local layout = config.layouts[config.currentLayout]
		local keySpacing = 6
		local rowSpacing = 8

		-- Handle gamepad input
		local gamepadPressed = false
		local gamepadDir = nil

		if raylib.lib.IsGamepadAvailable(0) == 1 then
			-- D-pad navigation
			if raylib.lib.IsGamepadButtonPressed(0, 1) == 1 then -- DPAD_UP
				gamepadDir = "up"
				gamepadPressed = true
			elseif raylib.lib.IsGamepadButtonPressed(0, 3) == 1 then -- DPAD_DOWN
				gamepadDir = "down"
				gamepadPressed = true
			elseif raylib.lib.IsGamepadButtonPressed(0, 4) == 1 then -- DPAD_LEFT
				gamepadDir = "left"
				gamepadPressed = true
			elseif raylib.lib.IsGamepadButtonPressed(0, 2) == 1 then -- DPAD_RIGHT
				gamepadDir = "right"
				gamepadPressed = true
			end

			-- Left stick navigation
			local axisX = raylib.lib.GetGamepadAxisMovement(0, 0)
			local axisY = raylib.lib.GetGamepadAxisMovement(0, 1)

			if not gamepadPressed then
				if math.abs(axisX) > 0.5 or math.abs(axisY) > 0.5 then
					if config.lastInput == nil or (axisX ~= config.lastInput.x or axisY ~= config.lastInput.y) then
						config.timeSinceInput = 0
						config.lastInput = { x = axisX, y = axisY }
					else
						config.timeSinceInput = config.timeSinceInput + dt
					end

					local delay = config.timeSinceInput == 0 and 0
						or (config.timeSinceInput < config.repeatDelay and math.huge or config.repeatRate)

					if config.timeSinceInput == 0 or config.timeSinceInput >= config.repeatDelay then
						if config.timeSinceInput >= config.repeatDelay then
							config.timeSinceInput = config.repeatDelay
						end

						if math.abs(axisY) > math.abs(axisX) then
							gamepadDir = axisY > 0.5 and "down" or "up"
						else
							gamepadDir = axisX > 0.5 and "right" or "left"
						end
						gamepadPressed = true
					end
				else
					config.lastInput = nil
					config.timeSinceInput = 0
				end
			end
		end

		-- Keyboard navigation
		if raylib.lib.IsKeyPressed(265) == 1 then
			gamepadDir = "up"
			gamepadPressed = true
		end
		if raylib.lib.IsKeyPressed(264) == 1 then
			gamepadDir = "down"
			gamepadPressed = true
		end
		if raylib.lib.IsKeyPressed(263) == 1 then
			gamepadDir = "left"
			gamepadPressed = true
		end
		if raylib.lib.IsKeyPressed(262) == 1 then
			gamepadDir = "right"
			gamepadPressed = true
		end

		if gamepadPressed and gamepadDir then
			if gamepadDir == "up" then
				config.selectedRow = math.max(0, config.selectedRow - 1)
			elseif gamepadDir == "down" then
				config.selectedRow = math.min(#layout - 1, config.selectedRow + 1)
			elseif gamepadDir == "left" then
				config.selectedCol = math.max(0, config.selectedCol - 1)
			elseif gamepadDir == "right" then
				config.selectedCol = math.min(#layout[config.selectedRow + 1] - 1, config.selectedCol + 1)
			end

			-- Clamp column to valid range for current row
			config.selectedCol = math.min(config.selectedCol, #layout[config.selectedRow + 1] - 1)
		end

		-- Check for activation
		local activateKey = false
		if raylib.lib.IsGamepadAvailable(0) == 1 then
			if raylib.lib.IsGamepadButtonPressed(0, 7) == 1 then -- A button
				activateKey = true
			end
		end
		if raylib.lib.IsKeyPressed(257) == 1 or raylib.lib.IsKeyPressed(32) == 1 then -- Enter or Space
			activateKey = true
		end

		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		-- Draw keys
		for rowIdx, row in ipairs(layout) do
			local rowY = keyStartY + (rowIdx - 1) * (35 + rowSpacing)
			local totalRowWidth = 0
			local keyWidths = {}

			-- Calculate key widths
			for colIdx, key in ipairs(row) do
				local keyWidth = 60
				if key == "SPACE" then
					keyWidth = 300
				elseif key == "SHIFT" or key == "BKSP" then
					keyWidth = 90
				elseif key == "CANCEL" or key == "SUBMIT" then
					keyWidth = 120
				end
				keyWidths[colIdx] = keyWidth
				totalRowWidth = totalRowWidth + keyWidth
			end
			totalRowWidth = totalRowWidth + (#row - 1) * keySpacing

			local rowX = kbRect.x + (kbRect.width - totalRowWidth) / 2

			for colIdx, key in ipairs(row) do
				local keyWidth = keyWidths[colIdx]
				local keyRect = rect.new(rowX, rowY, keyWidth, 35)

				local isSelected = (config.selectedRow == rowIdx - 1 and config.selectedCol == colIdx - 1)
				local isHovered = rect.MouseIsInRect(keyRect)

				-- Initialize hover state
				if not config.keyHoverStates[rowIdx - 1] then
					config.keyHoverStates[rowIdx - 1] = {}
				end
				if not config.keyHoverStates[rowIdx - 1][colIdx - 1] then
					config.keyHoverStates[rowIdx - 1][colIdx - 1] = 0
				end

				-- Smooth hover animation
				local targetHover = (isHovered or isSelected) and 1 or 0
				config.keyHoverStates[rowIdx - 1][colIdx - 1] = config.keyHoverStates[rowIdx - 1][colIdx - 1]
					+ (targetHover - config.keyHoverStates[rowIdx - 1][colIdx - 1]) * 0.2

				local hoverAmount = config.keyHoverStates[rowIdx - 1][colIdx - 1]
				local keyColorBase = config.keyColor

				if key == "SUBMIT" then
					keyColorBase = color3.new(0.2, 0.6, 0.3)
				elseif key == "CANCEL" then
					keyColorBase = color3.new(0.6, 0.2, 0.2)
				end

				local displayColor = color3.new(
					math.min(keyColorBase.R + hoverAmount * 0.15, 1),
					math.min(keyColorBase.G + hoverAmount * 0.15, 1),
					math.min(keyColorBase.B + hoverAmount * 0.15, 1)
				)

				-- Key shadow
				raylib.lib.DrawRectangleRounded(
					rect:translate(rect.new(keyRect.x + 2, keyRect.y + 2, keyRect.width, keyRect.height)),
					0.2,
					6,
					c3tr(color3.new(0, 0, 0), 0.75)
				)

				-- Key background
				raylib.lib.DrawRectangleRounded(rect:translate(keyRect), 0.2, 6, c3tr(displayColor, 0))

				-- Key text
				local displayKey = key
				if key == "BKSP" then
					displayKey = "⌫"
				elseif key == "SHIFT" then
					displayKey = "⇧"
				elseif key == "SPACE" then
					displayKey = "SPACE"
				end

				local textSize = raylib.lib.MeasureText(displayKey, 13)
				local textX = keyRect.x + (keyRect.width - textSize) / 2
				local textY = keyRect.y + 11

				raylib.lib.DrawText(displayKey, textX, textY, 13, c3tr(config.textColor, 0))

				-- Handle mouse click
				if isHovered and mousePressed then
					handleKeyPress(key)
				end

				-- Handle gamepad/keyboard activation
				if isSelected and activateKey then
					handleKeyPress(key)
				end

				rowX = rowX + keyWidth + keySpacing
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end