local raylib = require("@raylib")
local structs = raylib.structs
local rect = require("@arect")
local color3 = require("@Color3")
local textButton = require("./textButton")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 560,
			data.height or data[4] or 200
		),
		title = data.title or "Prompt",
		message = data.message or "",
		visible = data.visible ~= false,

		font = data.font or defaultFont,
		backgroundColor = data.backgroundColor or color3.new(0.10, 0.11, 0.13),
		overlayColor = data.overlayColor or color3.new(0, 0, 0),
		titleColor = data.titleColor or color3.new(0.96, 0.96, 0.98),
		messageColor = data.messageColor or color3.new(0.62, 0.64, 0.68),
		borderColor = data.borderColor or color3.new(0.20, 0.22, 0.26),
		accentColor = data.accentColor or color3.new(0.24, 0.48, 0.94),

		titleFontSize = data.titleFontSize or 20,
		messageFontSize = data.messageFontSize or 14,

		padding = data.padding or 26,
		rounded = data.rounded or { 0.10, 12 },

		buttons = data.buttons or {
			{ text = "OK", onClick = nil, color = color3.new(0.22, 0.46, 0.92) },
		},
		buttonHeight = data.buttonHeight or 38,
		buttonSpacing = data.buttonSpacing or 8,

		bodyRenderer = data.bodyRenderer,
		bodyHeight = data.bodyHeight or 0,

		showCloseButton = data.showCloseButton ~= false,
		onClose = data.onClose,

		-- Animation state
		animAlpha = 0,
		animSlideY = 0,
		animScale = 0,
		closeButtonHover = 0,
		buttonHoverStates = {},
		isClosing = false,
		buttonInstances = {},
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.show = function()
		config.visible = true
		config.isClosing = false
		config.animAlpha = 0
		config.animSlideY = 0
		config.animScale = 0
		return wrapper
	end

	wrapper.hide = function()
		config.isClosing = true
		return wrapper
	end

	wrapper.setBodyRenderer = function(renderer)
		config.bodyRenderer = renderer
		return wrapper
	end

	wrapper.setButtons = function(buttons)
		config.buttons = buttons
		config.buttonHoverStates = {}
		config.buttonInstances = {}
		for i, btn in ipairs(buttons) do
			config.buttonInstances[i] = textButton({}, {
				x = 0,
				y = 0,
				width = btn.width or 100,
				height = config.buttonHeight,
				text = btn.text,
				backgroundColor = btn.color or color3.new(0.22, 0.24, 0.28),
				hoverColor = btn.hoverColor or color3.new(0.32, 0.34, 0.38),
				pressColor = btn.pressColor or color3.new(0.18, 0.20, 0.24),
				textColor = color3.new(1, 1, 1),
				fontSize = 14,
				font = config.font,
				rounded = { 0.20, 8 },
				onClick = function()
					if btn.onClick then
						btn.onClick()
					end
					wrapper.hide()
				end,
			})
		end
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.visible and not config.isClosing then
			return
		end

		-- Recalculate height from content if bodyHeight is set
		if config.bodyHeight > 0 then
			local titleH = config.title ~= "" and (config.titleFontSize + 14) or 0
			local msgH = config.message ~= "" and (config.messageFontSize + 18) or 0
			config.obj_rect.height = config.padding
				+ titleH
				+ msgH
				+ config.bodyHeight
				+ config.buttonSpacing
				+ config.buttonHeight
				+ config.padding
		end

		-- Animate out
		if config.isClosing then
			config.animSlideY = config.animSlideY + (0 - config.animSlideY) * 0.18
			config.animAlpha = config.animAlpha + (0 - config.animAlpha) * 0.18
			config.animScale = config.animScale + (0 - config.animScale) * 0.18

			if config.animSlideY < 0.01 and config.animAlpha < 0.01 then
				config.visible = false
				config.isClosing = false
			end
		else
			-- Animate in
			config.animSlideY = config.animSlideY + (1 - config.animSlideY) * 0.14 -- slide speed
			config.animAlpha = config.animAlpha + (1 - config.animAlpha) * 0.16 -- fade speed
			config.animScale = config.animScale + (1 - config.animScale) * 0.20 -- scale speed
		end

		local screenW = raylib.lib.GetScreenWidth()
		local screenH = raylib.lib.GetScreenHeight()

		-- Overlay
		local overlayAlpha = config.animAlpha * 0.65
		raylib.lib.DrawRectangle(0, 0, screenW, screenH, config.overlayColor:ToRaylib(1 - overlayAlpha))

		-- Resolve center position
		local baseX = config.obj_rect.x == 0 and (screenW - config.obj_rect.width) / 2 or config.obj_rect.x
		local baseY = config.obj_rect.y == 0 and (screenH - config.obj_rect.height) / 2 or config.obj_rect.y

		-- Slide in from below
		local currentY = screenH + (baseY - screenH) * config.animSlideY

		-- Scale from center
		local w = config.obj_rect.width * config.animScale
		local h = config.obj_rect.height * config.animScale
		local x = baseX + (config.obj_rect.width - w) / 2
		local y = currentY + (config.obj_rect.height - h) / 2

		local pr = rect.new(x, y, w, h) -- prompt rect (scaled)

		-- Layered drop shadow
		for i = 1, 5 do
			local spread = i * 5
			local alpha = 0.04 + (5 - i) * 0.04
			raylib.lib.DrawRectangleRounded(
				rect:translate(
					rect.new(pr.x - spread * 0.5, pr.y + spread * 0.6, pr.width + spread, pr.height + spread * 0.5)
				),
				config.rounded[1],
				config.rounded[2],
				color3.new(0, 0, 0):ToRaylib(1 - alpha)
			)
		end

		-- Border
		raylib.lib.DrawRectangleRounded(
			rect:translate(pr),
			config.rounded[1],
			config.rounded[2],
			config.borderColor:ToRaylib(0)
		)

		-- Background (inset 1px from border)
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(pr.x + 1, pr.y + 1, pr.width - 2, pr.height - 2)),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		-- Close button
		if config.showCloseButton then
			local closeSize = 30
			local closeX = pr.x + pr.width - config.padding - closeSize + 4
			local closeY = pr.y + config.padding - 2
			local closeRect = rect.new(closeX, closeY, closeSize, closeSize)
			local isCloseHovered = rect.MouseIsInRect(closeRect)

			config.closeButtonHover = isCloseHovered and math.min(config.closeButtonHover + dt * 10, 1)
				or math.max(config.closeButtonHover - dt * 10, 0)

			if config.closeButtonHover > 0 then
				raylib.lib.DrawRectangleRounded(
					rect:translate(closeRect),
					0.3,
					8,
					color3.new(0.75, 0.18, 0.18):ToRaylib(1 - config.closeButtonHover * 0.9)
				)
			end

			local lp = 9
			local lt = 1.5
			local iconAlpha = 0.45 + config.closeButtonHover * 0.55
			local xCol = color3.new(
				0.55 + config.closeButtonHover * 0.45,
				0.55 - config.closeButtonHover * 0.35,
				0.55 - config.closeButtonHover * 0.35
			)

			raylib.lib.DrawLineEx(
				vector.create(closeX + lp, closeY + lp),
				vector.create(closeX + closeSize - lp, closeY + closeSize - lp),
				lt,
				xCol:ToRaylib(1 - iconAlpha)
			)
			raylib.lib.DrawLineEx(
				vector.create(closeX + closeSize - lp, closeY + lp),
				vector.create(closeX + lp, closeY + closeSize - lp),
				lt,
				xCol:ToRaylib(1 - iconAlpha)
			)

			if isCloseHovered and raylib.lib.IsMouseButtonReleased(0) == 1 then
				if config.onClose then
					config.onClose()
				end
				wrapper.hide()
			end
		end

		-- Content layout
		local contentY = pr.y + config.padding

		-- Title
		if config.title ~= "" then
			raylib.lib.DrawTextEx(
				config.font,
				config.title,
				vector.create(pr.x + config.padding, contentY),
				config.titleFontSize,
				1,
				config.titleColor:ToRaylib(0)
			)
			contentY = contentY + config.titleFontSize + 14
		end

		-- Message
		if config.message ~= "" then
			raylib.lib.DrawTextEx(
				config.font,
				config.message,
				vector.create(pr.x + config.padding, contentY),
				config.messageFontSize,
				0.5,
				config.messageColor:ToRaylib(0)
			)
			contentY = contentY + config.messageFontSize + 18
		end

		-- Body renderer
		if config.bodyRenderer then
			local bodyW = pr.width - config.padding * 2
			local bodyH = config.bodyHeight > 0 and config.bodyHeight
				or (pr.height - (contentY - pr.y) - config.padding - config.buttonHeight - config.buttonSpacing)

			config.bodyRenderer(dt, pr.x + config.padding, contentY, bodyW, bodyH)
			contentY = contentY + bodyH + config.buttonSpacing
		end

		-- Buttons (right-aligned)
		local totalBtnW = 0
		for i, btn in ipairs(config.buttons) do
			totalBtnW = totalBtnW + (btn.width or 100)
			if i < #config.buttons then
				totalBtnW = totalBtnW + config.buttonSpacing
			end
		end

		local btnY = pr.y + pr.height - config.padding - config.buttonHeight
		local btnX = pr.x + pr.width - config.padding - totalBtnW

		-- Thin separator above buttons
		raylib.lib.DrawLineEx(
			vector.create(pr.x + config.padding, btnY - config.buttonSpacing),
			vector.create(pr.x + pr.width - config.padding, btnY - config.buttonSpacing),
			1,
			config.borderColor:ToRaylib(0.55)
		)

		-- Create button instances if they don't exist
		if #config.buttonInstances == 0 and #config.buttons > 0 then
			wrapper.setButtons(config.buttons)
		end

		-- Update and render buttons
		for i, btnInstance in ipairs(config.buttonInstances) do
			local btn = config.buttons[i]
			local bw = btn.width or 100
			btnInstance.set("obj_rect", rect.new(btnX, btnY, bw, config.buttonHeight))
			btnInstance.render(dt)
			btnX = btnX + bw + config.buttonSpacing
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
