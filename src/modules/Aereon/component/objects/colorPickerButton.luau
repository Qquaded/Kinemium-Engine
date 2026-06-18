local raylib = require("@raylib")
local color3 = require("@Color3")
local rect = require("@arect")
local textButton = require("./textButton")
local imageButton = require("./imageButton")
local colorPicker = require("./colorPicker")
local zembed = require("@zembed")

local colorIcon = nil
local function getColorIcon()
	if not colorIcon then
		local tex = raylib.lib.LoadTexture(zembed.AssetPath("kineasset://images/icons/ColorPicker.png"))
		if tex then
			colorIcon = {
				texture = tex,
				x = buffer.readi32(tex, 4),
				y = buffer.readi32(tex, 8),
			}
		end
	end
	return colorIcon
end

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 200,
			data.height or data[4] or 32
		),
		color = data.color or color3.new(1, 1, 1),
		alpha = data.alpha or 0,
		font = data.font,
		fontSize = data.fontSize or 18,
		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		textTransparency = data.textTransparency or 0,
		rounded = data.rounded or { 0.3, 8 },
		onColorSelected = data.onColorSelected,
		showAlpha = data.showAlpha ~= false, -- default true
		buttonWidth = data.buttonWidth or 24,
		gap = data.gap or 4,
		-- picker popup state
		_pickerOpen = false,
		_pickerObjects = {},
		_picker = nil,
		_pickerRect = nil,
		-- animation
		_animT = 0, -- 0 = fully closed, 1 = fully open
		_lerpX = 0, -- current animated position
		_lerpY = 0,
		_targetX = 0, -- clamped target position
		_targetY = 0,
		_lerpSpeed = 14, -- higher = snappier
	}

	local function colorToHex(c, a)
		local r, g, b = c:ToRGB()
		if config.showAlpha then
			return string.format("#%02x%02x%02x%02x", r, g, b, math.floor((1 - a) * 255))
		else
			return string.format("#%02x%02x%02x", r, g, b)
		end
	end

	local PICKER_W = 220
	local PICKER_H = 420
	local PICKER_MARGIN = 4 -- gap between button and picker

	local function calcPickerTarget()
		local r = config.obj_rect
		local sw = raylib.lib.GetScreenWidth()
		local sh = raylib.lib.GetScreenHeight()

		-- Prefer below, fall back to above
		local px = r.x
		local py = r.y + r.height + PICKER_MARGIN
		if py + PICKER_H > sh then
			py = r.y - PICKER_H - PICKER_MARGIN
		end
		if py < 0 then
			py = PICKER_MARGIN
		end

		-- Clamp horizontal so picker stays on screen
		px = math.clamp(px, PICKER_MARGIN, sw - PICKER_W - PICKER_MARGIN)

		return px, py
	end

	local function openPicker()
		if config._pickerOpen then
			return
		end
		config._pickerOpen = true
		config._pickerObjects = {}
		config._animT = 0

		local tx, ty = calcPickerTarget()
		config._targetX = tx
		config._targetY = ty

		-- Start lerp from slightly above the target (slide-in feel)
		config._lerpX = tx
		config._lerpY = ty - 8

		config._pickerRect = rect.new(tx, ty, PICKER_W, PICKER_H)

		config._picker = colorPicker(config._pickerObjects, {
			x = tx,
			y = ty,
			width = PICKER_W,
			height = PICKER_H,
			font = config.font,
			fontSize = config.fontSize,
			onChanged = function(c, a)
				config.color = c
				config.alpha = a
				if config.onColorSelected then
					config.onColorSelected(c, a)
				end
			end,
		})
		config._picker.setColor(config.color)
	end

	local function closePicker()
		config._pickerOpen = false
		-- Don't nil _picker here — let the render loop animate it out
	end

	local function togglePicker()
		if config._pickerOpen then
			closePicker()
		else
			openPicker()
		end
	end

	-- Swatch display button (left part): shows hex label + color preview
	local swatchBtn = textButton({}, {
		text = colorToHex(config.color, config.alpha),
		backgroundColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		textColor = config.textColor,
		textTransparency = config.textTransparency,
		fontSize = config.fontSize,
		font = config.font,
		rounded = config.rounded,
		onClick = togglePicker,
	})

	-- Icon button (right part): color dropper/picker icon
	local imgBtn = imageButton({}, {
		image = getColorIcon(),
		imageScale = 0.6,
		backgroundColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		rounded = config.rounded,
		onClick = togglePicker,
	})

	local wrapper = {}

	wrapper.set = function(prop, value)
		config[prop] = value
		if prop == "color" or prop == "alpha" then
			swatchBtn.set("text", colorToHex(config.color, config.alpha))
			if config._picker then
				config._picker.setColor(config.color)
			end
		elseif
			prop == "backgroundColor"
			or prop == "hoverColor"
			or prop == "pressColor"
			or prop == "textColor"
			or prop == "textTransparency"
		then
			swatchBtn.set(prop, value)
			imgBtn.set(prop, value)
		end
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.getColor = function()
		return config.color
	end

	wrapper.getAlpha = function()
		return config.alpha
	end

	wrapper.closePicker = closePicker

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mouseDown = raylib.lib.IsMouseButtonPressed(0) == 1

		-- Close picker on outside click
		if mouseDown and config._pickerOpen then
			local mp = raylib.lib.GetMousePosition()
			local mx, my = mp.x, mp.y
			local pr = config._pickerRect
			local inPicker = pr and mx >= pr.x and mx <= pr.x + PICKER_W and my >= pr.y and my <= pr.y + PICKER_H
			local inButton = mx >= r.x and mx <= r.x + r.width and my >= r.y and my <= r.y + r.height
			if not inPicker and not inButton then
				closePicker()
			end
		end

		local swatchWidth = r.width - config.buttonWidth - config.gap

		swatchBtn.set("text", colorToHex(config.color, config.alpha))
		swatchBtn.set("obj_rect", rect.new(r.x, r.y, swatchWidth, r.height))
		swatchBtn.render(dt)

		-- Color swatch overlay on the left side of the text button
		local swatchPad = 4
		local swatchSize = r.height - swatchPad * 2
		local swatchRect = rect.new(r.x + swatchPad, r.y + swatchPad, swatchSize, swatchSize)
		-- Checker background for transparency indication
		if config.showAlpha then
			local checkerSize = 4
			for row = 0, math.ceil(swatchSize / checkerSize) - 1 do
				for col = 0, math.ceil(swatchSize / checkerSize) - 1 do
					local cx = swatchRect.x + col * checkerSize
					local cy = swatchRect.y + row * checkerSize
					local tw = math.min(checkerSize, swatchRect.x + swatchSize - cx)
					local th = math.min(checkerSize, swatchRect.y + swatchSize - cy)
					local isLight = (row + col) % 2 == 0
					local cc = isLight and color3.new(0.75, 0.75, 0.75):ToRaylib(0)
						or color3.new(0.5, 0.5, 0.5):ToRaylib(0)
					raylib.lib.DrawRectangle(cx, cy, tw, th, cc)
				end
			end
		end
		raylib.lib.DrawRectangleRounded(
			rect:translate(swatchRect),
			config.rounded[1],
			config.rounded[2],
			config.color:ToRaylib(config.alpha)
		)

		-- Right: icon button
		imgBtn.set("obj_rect", rect.new(r.x + swatchWidth + config.gap, r.y, config.buttonWidth, r.height))
		imgBtn.render(dt)

		-- Render the popup picker on top of everything else
		if config._picker then
			-- Lerp animation (runs during open AND during close-fade)
			local speed = config._lerpSpeed * dt
			config._lerpX = config._lerpX + (config._targetX - config._lerpX) * math.min(speed, 1)
			config._lerpY = config._lerpY + (config._targetY - config._lerpY) * math.min(speed, 1)

			if config._pickerOpen then
				config._animT = math.min(config._animT + dt * config._lerpSpeed, 1)
			else
				config._animT = math.max(config._animT - dt * config._lerpSpeed, 0)
				if config._animT <= 0 then
					-- Animation finished closing — fully destroy
					config._picker = nil
					config._pickerObjects = {}
				end
			end

			if config._picker then
				-- Re-target each frame in case button moved
				if config._pickerOpen then
					local tx, ty = calcPickerTarget()
					config._targetX = tx
					config._targetY = ty
					config._pickerRect = rect.new(tx, ty, PICKER_W, PICKER_H)
				end

				local px = math.floor(config._lerpX + 0.5)
				local py = math.floor(config._lerpY + 0.5)

				-- Scale + fade using animT (ease-out quad)
				local ease = 1 - (1 - config._animT) * (1 - config._animT)
				local scale = 0.92 + 0.08 * ease
				local alpha = ease

				-- Clip/offset so it scales from the top
				local scaledH = PICKER_H * scale
				local scaledW = PICKER_W * scale
				local offsetX = px + (PICKER_W - scaledW) / 2
				local offsetY = py

				raylib.lib.BeginScissorMode(offsetX, offsetY, scaledW, scaledH + 2)

				-- Translate the picker's rect to the animated position
				config._picker.set(
					"obj_rect",
					rect.new(offsetX + (px - offsetX) * (1 - scale), offsetY, PICKER_W, PICKER_H)
				)
				-- Apply transparency via backgroundTransparency proxy
				config._picker.set("backgroundTransparency", 1 - alpha)
				config._picker.render(dt)

				raylib.lib.EndScissorMode()
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
