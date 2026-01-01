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

local rect = require("../rect")(raylib.lib)
local color3 = require("@Color3")

local objects = {}

local comps = {
	frame = function(data)
		local config = {
			obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
			color = color3.new(1, 1, 1),
			raylib_color = c3tr(color3.new(1, 1, 1), 0),
			bgtransparency = 0,
			clicked = nil,
			hoveredCallback = nil,
			rounded = nil,
			disabled = false,
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
							c3tr(color, transparency) or raylib.const.WHITE
						)
					else
						raylib.lib.DrawRectangleLinesEx(
							rect:translate(config.obj_rect),
							value,
							c3tr(color, transparency) or raylib.const.WHITE
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
			config.raylib_color = c3tr(config.color, config.bgtransparency)
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
	end,

	colorPicker = function(data)
		local config = {
			obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
			h = 0,
			s = 1,
			v = 1,
			a = 1,
			dragging = nil, -- "sv", "h", "a"
			onChanged = data.onChanged,
			rounded = data.rounded or { 0.1, 8 },
			modifiers = {},
		}

		local function updateColor()
			local c = color3.fromHSV(config.h, config.s, config.v)
			if config.onChanged then
				config.onChanged(c, config.a)
			end
		end

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.getColor = function()
			return color3.fromHSV(config.h, config.s, config.v)
		end

		wrapper.getAlpha = function()
			return config.a
		end

		wrapper.render = function(dt)
			local r = config.obj_rect
			local mousePos = raylib.lib.GetMousePosition()
			local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1

			local padding = 10
			local sliderHeight = 15
			local previewHeight = 30
			local svSize = math.min(r.width - padding * 2, r.height - padding * 5 - sliderHeight * 2 - previewHeight)
			local svRect = rect.new(r.x + padding, r.y + padding, svSize, svSize)
			local hRect = rect.new(r.x + padding, r.y + padding * 2 + svSize, svSize, sliderHeight)
			local aRect = rect.new(r.x + padding, r.y + padding * 3 + svSize + sliderHeight, svSize, sliderHeight)
			local pRect = rect.new(r.x + padding, r.y + padding * 4 + svSize + sliderHeight * 2, svSize, previewHeight)

			if mouseDown then
				if not config.dragging then
					if rect.MouseIsInRect(svRect) then
						config.dragging = "sv"
					elseif rect.MouseIsInRect(hRect) then
						config.dragging = "h"
					elseif rect.MouseIsInRect(aRect) then
						config.dragging = "a"
					end
				end

				if config.dragging == "sv" then
					config.s = math.clamp((mousePos.x - svRect.x) / svRect.width, 0, 1)
					config.v = 1 - math.clamp((mousePos.y - svRect.y) / svRect.height, 0, 1)
					updateColor()
				elseif config.dragging == "h" then
					config.h = math.clamp((mousePos.x - hRect.x) / hRect.width, 0, 1)
					updateColor()
				elseif config.dragging == "a" then
					config.a = math.clamp((mousePos.x - aRect.x) / aRect.width, 0, 1)
					updateColor()
				end
			else
				config.dragging = nil
			end

			if config.rounded then
				raylib.lib.DrawRectangleRounded(
					rect:translate(r),
					config.rounded[1],
					config.rounded[2],
					c3tr(color3.new(0.1, 0.1, 0.1), 0)
				)
			else
				raylib.lib.DrawRectangleRec(rect:translate(r), c3tr(color3.new(0.1, 0.1, 0.1), 0))
			end

			local baseColor = color3.fromHSV(config.h, 1, 1)
			raylib.lib.DrawRectangleRec(rect:translate(svRect), c3tr(baseColor, 0))
			raylib.lib.DrawRectangleGradientH(
				svRect.x,
				svRect.y,
				svRect.width,
				svRect.height,
				raylib.const.WHITE,
				c3tr(baseColor, 1)
			)
			raylib.lib.DrawRectangleGradientV(
				svRect.x,
				svRect.y,
				svRect.width,
				svRect.height,
				c3tr(color3.new(0, 0, 0), 1),
				raylib.const.BLACK
			)
			raylib.lib.DrawRectangleLinesEx(rect:translate(svRect), 1, raylib.const.GRAY)

			local cursorX = svRect.x + config.s * svRect.width
			local cursorY = svRect.y + (1 - config.v) * svRect.height
			raylib.lib.DrawCircleSector(vector.create(cursorX, cursorY), 6, 0, 360, 16, raylib.const.WHITE)
			raylib.lib.DrawCircleSector(
				vector.create(cursorX, cursorY),
				4,
				0,
				360,
				16,
				c3tr(color3.fromHSV(config.h, config.s, config.v), 0)
			)

			for i = 0, hRect.width - 1 do
				local hue = i / hRect.width
				raylib.lib.DrawRectangle(hRect.x + i, hRect.y, 1, hRect.height, c3tr(color3.fromHSV(hue, 1, 1), 0))
			end
			raylib.lib.DrawRectangleLinesEx(rect:translate(hRect), 1, raylib.const.GRAY)
			raylib.lib.DrawRectangle(
				hRect.x + config.h * hRect.width - 2,
				hRect.y - 2,
				4,
				hRect.height + 4,
				raylib.const.WHITE
			)

			raylib.lib.DrawRectangleRec(rect:translate(aRect), raylib.const.DARKGRAY)
			raylib.lib.DrawRectangleGradientH(
				aRect.x,
				aRect.y,
				aRect.width,
				aRect.height,
				c3tr(color3.fromHSV(config.h, config.s, config.v), 1),
				c3tr(color3.fromHSV(config.h, config.s, config.v), 0)
			)
			raylib.lib.DrawRectangleLinesEx(rect:translate(aRect), 1, raylib.const.GRAY)
			raylib.lib.DrawRectangle(
				aRect.x + config.a * aRect.width - 2,
				aRect.y - 2,
				4,
				aRect.height + 4,
				raylib.const.WHITE
			)

			raylib.lib.DrawRectangleRec(
				rect:translate(pRect),
				c3tr(color3.fromHSV(config.h, config.s, config.v), 1 - config.a)
			)
			raylib.lib.DrawRectangleLinesEx(rect:translate(pRect), 1, raylib.const.WHITE)

			for _, m in pairs(config.modifiers) do
				m()
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	button = function(data)
		local config = {
			obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
			text = data.text or "Button",
			fontSize = data.fontSize or 18,
			backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
			hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
			pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
			textColor = data.textColor or color3.new(1, 1, 1),
			rounded = data.rounded or { 0.3, 8 },
			onClick = data.onClick,
			currentColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.render = function(dt)
			local r = config.obj_rect
			local isHovered = rect.MouseIsInRect(r)
			local isPressed = isHovered and raylib.lib.IsMouseButtonDown(0) == 1

			local targetColor = config.backgroundColor
			if isPressed then
				targetColor = config.pressColor
			elseif isHovered then
				targetColor = config.hoverColor
			end

			config.currentColor = color3.new(
				config.currentColor.R + (targetColor.R - config.currentColor.R) * 0.2,
				config.currentColor.G + (targetColor.G - config.currentColor.G) * 0.2,
				config.currentColor.B + (targetColor.B - config.currentColor.B) * 0.2
			)

			raylib.lib.DrawRectangleRounded(
				rect:translate(r),
				config.rounded[1],
				config.rounded[2],
				c3tr(config.currentColor, 0)
			)

			local textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
			local textX = r.x + (r.width - textWidth) / 2
			local textY = r.y + (r.height - config.fontSize) / 2

			raylib.lib.DrawText(config.text, textX, textY, config.fontSize, c3tr(config.textColor, 0))

			if isHovered and raylib.lib.IsMouseButtonReleased(0) == 1 and config.onClick then
				config.onClick()
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	slider = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3],
				data.height or data[4] or 20
			),
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

			if mouseDown and (config.dragging or rect.MouseIsInRect(r)) then
				config.dragging = true
				local normalizedX = math.clamp((mousePos.x - r.x) / r.width, 0, 1)
				config.value = config.min + normalizedX * (config.max - config.min)
				if config.onChanged then
					config.onChanged(config.value)
				end
			else
				config.dragging = false
			end

			raylib.lib.DrawRectangleRounded(rect:translate(trackRect), 0.5, 8, c3tr(config.trackColor, 0))

			local normalizedValue = (config.value - config.min) / (config.max - config.min)
			local fillWidth = r.width * normalizedValue
			local fillRect = rect.new(r.x, trackY, fillWidth, trackHeight)

			raylib.lib.DrawRectangleRounded(rect:translate(fillRect), 0.5, 8, c3tr(config.fillColor, 0))

			local handleX = r.x + fillWidth
			local handleY = r.y + r.height / 2
			local handleRadius = r.height * 0.6

			raylib.lib.DrawCircleV(vector.create(handleX, handleY), handleRadius, c3tr(config.handleColor, 0))
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	toggle = function(data)
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

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, c3tr(currentColor, 0))

			local handleRadius = r.height * 0.35
			local handlePadding = r.height * 0.15
			local handleMinX = r.x + handlePadding + handleRadius
			local handleMaxX = r.x + r.width - handlePadding - handleRadius
			local handleX = handleMinX + (handleMaxX - handleMinX) * config.animProgress
			local handleY = r.y + r.height / 2

			raylib.lib.DrawCircleV(vector.create(handleX, handleY), handleRadius, c3tr(config.handleColor, 0))

			if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.value = not config.value
				if config.onChanged then
					config.onChanged(config.value)
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	progressBar = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3],
				data.height or data[4] or 20
			),
			progress = data.progress or 0,
			backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),
			fillColor = data.fillColor or color3.new(0.02, 0.5, 1),
			rounded = data.rounded or { 0.5, 8 },
			currentProgress = data.progress or 0,
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.setProgress = function(p)
			config.progress = math.clamp(p, 0, 1)
		end

		wrapper.getProgress = function()
			return config.progress
		end

		wrapper.render = function(dt)
			local r = config.obj_rect
			config.currentProgress = config.currentProgress + (config.progress - config.currentProgress) * 0.1

			raylib.lib.DrawRectangleRounded(
				rect:translate(r),
				config.rounded[1],
				config.rounded[2],
				c3tr(config.backgroundColor, 0)
			)

			local fillWidth = r.width * config.currentProgress
			if fillWidth > 0 then
				local fillRect = rect.new(r.x, r.y, fillWidth, r.height)
				raylib.lib.DrawRectangleRounded(
					rect:translate(fillRect),
					config.rounded[1],
					config.rounded[2],
					c3tr(config.fillColor, 0)
				)
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	label = function(data)
		local config = {
			x = data.x or data[1],
			y = data.y or data[2],
			text = data.text or "Label",
			fontSize = data.fontSize or 18,
			color = data.color or color3.new(1, 1, 1),
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

		wrapper.render = function(dt)
			raylib.lib.DrawText(config.text, config.x, config.y, config.fontSize, c3tr(config.color, 0))
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	checkbox = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.size or data[3] or 20,
				data.size or data[4] or 20
			),
			value = data.value or false,
			onChanged = data.onChanged,
			boxColor = data.boxColor or color3.new(0.2, 0.2, 0.2),
			checkColor = data.checkColor or color3.new(0.02, 0.5, 1),
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

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, c3tr(config.boxColor, 0))

			raylib.lib.DrawRectangleRoundedLinesEx(rect:translate(r), 0.2, 8, 2, c3tr(config.checkColor, 0))

			if config.animProgress > 0.1 then
				local checkSize = r.width * 0.6 * config.animProgress
				local checkX = r.x + (r.width - checkSize) / 2
				local checkY = r.y + (r.height - checkSize) / 2
				local checkRect = rect.new(checkX, checkY, checkSize, checkSize)

				raylib.lib.DrawRectangleRounded(rect:translate(checkRect), 0.3, 8, c3tr(config.checkColor, 0))
			end

			if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.value = not config.value
				if config.onChanged then
					config.onChanged(config.value)
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	textInput = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3],
				data.height or data[4] or 30
			),
			text = data.text or "",
			placeholder = data.placeholder or "Type here...",
			fontSize = data.fontSize or 18,
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

		wrapper.render = function(dt)
			local r = config.obj_rect
			config.cursorBlink = config.cursorBlink + dt

			local borderColor = config.focused and config.focusColor or color3.new(0.3, 0.3, 0.3)

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, c3tr(config.backgroundColor, 0))

			raylib.lib.DrawRectangleRoundedLinesEx(rect:translate(r), 0.2, 8, 2, c3tr(borderColor, 0))

			local displayText = config.text
			local textColor = config.textColor
			if displayText == "" and not config.focused then
				displayText = config.placeholder
				textColor = config.placeholderColor
			end

			local textX = r.x + 8
			local textY = r.y + (r.height - config.fontSize) / 2

			raylib.lib.DrawText(tostring(displayText), textX, textY, config.fontSize, c3tr(textColor, 0))

			if config.focused and math.floor(config.cursorBlink * 2) % 2 == 0 then
				local textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
				raylib.lib.DrawRectangle(textX + textWidth + 2, textY, 2, config.fontSize, c3tr(config.textColor, 0))
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
	end,

	dropdown = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3],
				data.height or data[4] or 30
			),
			options = data.options or { "Option 1", "Option 2", "Option 3" },
			selectedIndex = data.selectedIndex or 1,
			expanded = false,
			backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
			hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
			textColor = data.textColor or color3.new(1, 1, 1),
			fontSize = data.fontSize or 18,
			onSelect = data.onSelect,
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.setSelected = function(index)
			config.selectedIndex = math.clamp(index, 1, #config.options)
		end

		wrapper.getSelected = function()
			return config.selectedIndex, config.options[config.selectedIndex]
		end

		wrapper.render = function(dt)
			local r = config.obj_rect

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, c3tr(config.backgroundColor, 0))

			local selectedText = config.options[config.selectedIndex] or "Select..."
			local textX = r.x + 8
			local textY = r.y + (r.height - config.fontSize) / 2

			raylib.lib.DrawText(selectedText, textX, textY, config.fontSize, c3tr(config.textColor, 0))

			local arrowSize = 8
			local arrowX = r.x + r.width - arrowSize - 8
			local arrowY = r.y + r.height / 2
			if config.expanded then
				raylib.lib.DrawTriangle(
					vector.create(arrowX, arrowY + arrowSize / 2),
					vector.create(arrowX + arrowSize, arrowY + arrowSize / 2),
					vector.create(arrowX + arrowSize / 2, arrowY - arrowSize / 2),
					c3tr(config.textColor, 0)
				)
			else
				raylib.lib.DrawTriangle(
					vector.create(arrowX, arrowY - arrowSize / 2),
					vector.create(arrowX + arrowSize, arrowY - arrowSize / 2),
					vector.create(arrowX + arrowSize / 2, arrowY + arrowSize / 2),
					c3tr(config.textColor, 0)
				)
			end

			if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.expanded = not config.expanded
			end

			if config.expanded then
				local itemHeight = r.height
				local listHeight = itemHeight * #config.options
				local listY = r.y + r.height + 2

				raylib.lib.DrawRectangleRounded(
					structs.Rectangle:new({ x = r.x, y = listY, width = r.width, height = listHeight }),
					0.2,
					8,
					c3tr(config.backgroundColor, 0)
				)

				for i, option in ipairs(config.options) do
					local itemY = listY + (i - 1) * itemHeight
					local itemRect = rect.new(r.x, itemY, r.width, itemHeight)

					if rect.MouseIsInRect(itemRect) then
						raylib.lib.DrawRectangle(
							itemRect.x,
							itemRect.y,
							itemRect.width,
							itemRect.height,
							c3tr(config.hoverColor, 0)
						)

						if raylib.lib.IsMouseButtonReleased(0) == 1 then
							config.selectedIndex = i
							config.expanded = false
							if config.onSelect then
								config.onSelect(i, option)
							end
						end
					end

					raylib.lib.DrawText(
						option,
						r.x + 8,
						itemY + (itemHeight - config.fontSize) / 2,
						config.fontSize,
						c3tr(config.textColor, 0)
					)
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	radioButton = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.size or data[3] or 20,
				data.size or data[4] or 20
			),
			value = data.value or false,
			onChanged = data.onChanged,
			ringColor = data.ringColor or color3.new(0.3, 0.3, 0.3),
			fillColor = data.fillColor or color3.new(0.02, 0.5, 1),
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

			local centerX = r.x + r.width / 2
			local centerY = r.y + r.height / 2
			local radius = r.width / 2

			raylib.lib.DrawCircleV(vector.create(centerX, centerY), radius, c3tr(config.ringColor, 0))

			if config.animProgress > 0.1 then
				local fillRadius = radius * 0.5 * config.animProgress
				raylib.lib.DrawCircleV(vector.create(centerX, centerY), fillRadius, c3tr(config.fillColor, 0))
			end

			if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.value = true
				if config.onChanged then
					config.onChanged(config.value)
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	tooltip = function(data)
		local config = {
			targetRect = data.targetRect,
			text = data.text or "Tooltip",
			fontSize = data.fontSize or 14,
			backgroundColor = data.backgroundColor or color3.new(0.1, 0.1, 0.1),
			textColor = data.textColor or color3.new(1, 1, 1),
			padding = data.padding or 8,
			visible = false,
			animAlpha = 0,
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.render = function(dt)
			if not config.targetRect then
				return
			end

			local isHovered = rect.MouseIsInRect(config.targetRect)
			local targetAlpha = isHovered and 1 or 0
			config.animAlpha = config.animAlpha + (targetAlpha - config.animAlpha) * 0.15

			if config.animAlpha > 0.01 then
				local textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
				local tooltipWidth = textWidth + config.padding * 2
				local tooltipHeight = config.fontSize + config.padding * 2

				local tooltipX = config.targetRect.x + config.targetRect.width / 2 - tooltipWidth / 2
				local tooltipY = config.targetRect.y - tooltipHeight - 5

				local tooltipRect = rect.new(tooltipX, tooltipY, tooltipWidth, tooltipHeight)

				raylib.lib.DrawRectangleRounded(
					rect:translate(tooltipRect),
					0.2,
					8,
					c3tr(config.backgroundColor, 1 - config.animAlpha)
				)

				raylib.lib.DrawText(
					config.text,
					tooltipX + config.padding,
					tooltipY + config.padding,
					config.fontSize,
					c3tr(config.textColor, 1 - config.animAlpha)
				)
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	tabs = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3],
				data.height or data[4] or 40
			),
			tabs = data.tabs or { "Tab 1", "Tab 2", "Tab 3" },
			activeIndex = data.activeIndex or 1,
			onTabChange = data.onTabChange,
			backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),
			activeColor = data.activeColor or color3.new(0.02, 0.5, 1),
			textColor = data.textColor or color3.new(1, 1, 1),
			fontSize = data.fontSize or 16,
			animX = 0,
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.setActive = function(index)
			config.activeIndex = math.clamp(index, 1, #config.tabs)
		end

		wrapper.render = function(dt)
			local r = config.obj_rect
			local tabWidth = r.width / #config.tabs

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.2, 8, c3tr(config.backgroundColor, 0))

			local targetX = r.x + (config.activeIndex - 1) * tabWidth
			config.animX = config.animX + (targetX - config.animX) * 0.15

			local indicatorRect = rect.new(config.animX, r.y + r.height - 3, tabWidth, 3)
			raylib.lib.DrawRectangle(
				indicatorRect.x,
				indicatorRect.y,
				indicatorRect.width,
				indicatorRect.height,
				c3tr(config.activeColor, 0)
			)

			for i, tab in ipairs(config.tabs) do
				local tabX = r.x + (i - 1) * tabWidth
				local tabRect = rect.new(tabX, r.y, tabWidth, r.height)

				local textWidth = raylib.lib.MeasureText(tab, config.fontSize)
				local textX = tabX + (tabWidth - textWidth) / 2
				local textY = r.y + (r.height - config.fontSize) / 2

				raylib.lib.DrawText(tab, textX, textY, config.fontSize, c3tr(config.textColor, 0))

				if rect.MouseIsInRect(tabRect) and raylib.lib.IsMouseButtonReleased(0) == 1 then
					config.activeIndex = i
					if config.onTabChange then
						config.onTabChange(i, tab)
					end
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	card = function(data)
		local config = {
			obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
			backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),
			shadowColor = data.shadowColor or color3.new(0, 0, 0),
			elevation = data.elevation or 4,
			rounded = data.rounded or { 0.15, 8 },
		}

		local wrapper = {}

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.render = function(dt)
			local r = config.obj_rect

			for i = config.elevation, 1, -1 do
				local shadowOffset = i * 0.5
				local shadowRect = rect.new(r.x + shadowOffset, r.y + shadowOffset, r.width, r.height)
				raylib.lib.DrawRectangleRounded(
					rect:translate(shadowRect),
					config.rounded[1],
					config.rounded[2],
					c3tr(config.shadowColor, 0.9 + (i / config.elevation) * 0.1)
				)
			end

			raylib.lib.DrawRectangleRounded(
				rect:translate(r),
				config.rounded[1],
				config.rounded[2],
				c3tr(config.backgroundColor, 0)
			)
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	badge = function(data)
		local config = {
			x = data.x or data[1],
			y = data.y or data[2],
			text = data.text or "1",
			fontSize = data.fontSize or 12,
			backgroundColor = data.backgroundColor or color3.new(1, 0.2, 0.2),
			textColor = data.textColor or color3.new(1, 1, 1),
			minWidth = data.minWidth or 18,
		}

		local wrapper = {}

		wrapper.setText = function(t)
			config.text = t
		end

		wrapper.render = function(dt)
			local textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
			local badgeWidth = math.max(config.minWidth, textWidth + 8)
			local badgeHeight = config.fontSize + 6

			local badgeRect = rect.new(config.x, config.y, badgeWidth, badgeHeight)

			raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.5, 8, c3tr(config.backgroundColor, 0))

			local textX = config.x + (badgeWidth - textWidth) / 2
			local textY = config.y + 3

			raylib.lib.DrawText(config.text, textX, textY, config.fontSize, c3tr(config.textColor, 0))
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	divider = function(data)
		local config = {
			x = data.x or data[1],
			y = data.y or data[2],
			width = data.width or data[3],
			vertical = data.vertical or false,
			height = data.height or data[4] or 1,
			color = data.color or color3.new(0.3, 0.3, 0.3),
		}

		local wrapper = {}

		wrapper.render = function(dt)
			if config.vertical then
				raylib.lib.DrawRectangle(config.x, config.y, config.height, config.width, c3tr(config.color, 0))
			else
				raylib.lib.DrawRectangle(config.x, config.y, config.width, config.height, c3tr(config.color, 0))
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	spinner = function(data)
		local config = {
			x = data.x or data[1],
			y = data.y or data[2],
			radius = data.radius or data[3] or 20,
			color = data.color or color3.new(0.02, 0.5, 1),
			thickness = data.thickness or 3,
			rotation = 0,
		}

		local wrapper = {}

		wrapper.render = function(dt)
			config.rotation = config.rotation + dt * 180
			if config.rotation >= 360 then
				config.rotation = config.rotation - 360
			end

			raylib.lib.DrawRing(
				vector.create(config.x, config.y),
				config.radius - config.thickness,
				config.radius,
				config.rotation,
				config.rotation + 270,
				32,
				c3tr(config.color, 0)
			)
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	image = function(data)
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
	end,

	iconButton = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.size or data[3] or 40,
				data.size or data[4] or 40
			),
			icon = data.icon,
			backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
			hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
			pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
			onClick = data.onClick,
			currentColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		}

		local wrapper = {}

		wrapper.render = function(dt)
			local r = config.obj_rect
			local isHovered = rect.MouseIsInRect(r)
			local isPressed = isHovered and raylib.lib.IsMouseButtonDown(0) == 1

			local targetColor = config.backgroundColor
			if isPressed then
				targetColor = config.pressColor
			elseif isHovered then
				targetColor = config.hoverColor
			end

			config.currentColor = color3.new(
				config.currentColor.R + (targetColor.R - config.currentColor.R) * 0.2,
				config.currentColor.G + (targetColor.G - config.currentColor.G) * 0.2,
				config.currentColor.B + (targetColor.B - config.currentColor.B) * 0.2
			)

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, c3tr(config.currentColor, 0))

			if config.icon then
				local iconSize = r.width * 0.6
				local iconX = r.x + (r.width - iconSize) / 2
				local iconY = r.y + (r.height - iconSize) / 2

				raylib.lib.DrawTexturePro(
					config.icon.texture,
					structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }),
					structs.Rectangle:new({ x = iconX, y = iconY, width = iconSize, height = iconSize }),
					vector.create(0, 0),
					0,
					raylib.const.WHITE
				)
			end

			if isHovered and raylib.lib.IsMouseButtonReleased(0) == 1 and config.onClick then
				config.onClick()
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	switch = function(data)
		local config = {
			obj_rect = rect.new(
				data.x or data[1],
				data.y or data[2],
				data.width or data[3] or 60,
				data.height or data[4] or 30
			),
			value = data.value or false,
			onChanged = data.onChanged,
			offColor = data.offColor or color3.new(0.25, 0.25, 0.25),
			onColor = data.onColor or color3.new(0.3, 0.7, 0.3),
			handleColor = data.handleColor or color3.new(1, 1, 1),
			animProgress = data.value and 1 or 0,
		}

		local wrapper = {}

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

			raylib.lib.DrawRectangleRounded(rect:translate(r), 0.5, 8, c3tr(currentColor, 0))

			local handleSize = r.height - 6
			local handleMinX = r.x + 3
			local handleMaxX = r.x + r.width - handleSize - 3
			local handleX = handleMinX + (handleMaxX - handleMinX) * config.animProgress
			local handleY = r.y + 3

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({ x = handleX, y = handleY, width = handleSize, height = handleSize }),
				0.5,
				8,
				c3tr(config.handleColor, 0)
			)

			if rect.MouseIsInRect(r) and raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.value = not config.value
				if config.onChanged then
					config.onChanged(config.value)
				end
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,

	stepper = function(data)
		local config = {
			x = data.x or data[1],
			y = data.y or data[2],
			steps = data.steps or 3,
			currentStep = data.currentStep or 1,
			size = data.size or 30,
			spacing = data.spacing or 60,
			activeColor = data.activeColor or color3.new(0.02, 0.5, 1),
			inactiveColor = data.inactiveColor or color3.new(0.3, 0.3, 0.3),
			textColor = data.textColor or color3.new(1, 1, 1),
		}

		local wrapper = {}

		wrapper.setStep = function(step)
			config.currentStep = math.clamp(step, 1, config.steps)
		end

		wrapper.render = function(dt)
			for i = 1, config.steps do
				local stepX = config.x + (i - 1) * config.spacing
				local stepY = config.y
				local isActive = i <= config.currentStep
				local stepColor = isActive and config.activeColor or config.inactiveColor

				if i < config.steps then
					raylib.lib.DrawRectangle(
						stepX + config.size,
						stepY + config.size / 2 - 1,
						config.spacing - config.size,
						2,
						c3tr(stepColor, 0)
					)
				end

				raylib.lib.DrawCircleV(
					vector.create(stepX + config.size / 2, stepY + config.size / 2),
					config.size / 2,
					c3tr(stepColor, 0)
				)

				local stepText = tostring(i)
				local fontSize = config.size / 2
				local textWidth = raylib.lib.MeasureText(stepText, fontSize)
				raylib.lib.DrawText(
					stepText,
					stepX + config.size / 2 - textWidth / 2,
					stepY + config.size / 2 - fontSize / 2,
					fontSize,
					c3tr(config.textColor, 0)
				)
			end
		end

		table.insert(objects, wrapper)
		return wrapper
	end,
}

function comps.clear()
	table.clear(objects)
end

function comps:step(dt)
	for _, v in pairs(objects) do
		v.render(dt)
	end
end

return comps
