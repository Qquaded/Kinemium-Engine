local adapter = require("@RaylibAdapter")
local structs = adapter.structs
local color3 = require("@Color3")
local rect = require("@arect")
local effects = require("./effects")
local MouseCursor = require("@Kinemium.MouseCursor")

local RADIUS = 8
local SEGMENTS = 6
local BUTTON_H = 36
local CHEVRON_W = 36
local FONT_SIZE = 13
local ITEM_H = 52
local POPUP_PAD = 6

local ColorLookupTable = {
	primary = color3.new(0.13, 0.77, 0.37),
	primaryHov = color3.new(0.10, 0.65, 0.30),
	primaryPrs = color3.new(0.08, 0.55, 0.25),
	surfaceHov = color3.new(0.18, 0.18, 0.22),
	border = color3.new(0.22, 0.22, 0.26),
	divider = color3.new(1, 1, 1),
	textOnPri = color3.new(0.05, 0.05, 0.06),
	textPri = color3.new(0.92, 0.92, 0.94),
	textSec = color3.new(0.55, 0.55, 0.60),
	popupBg = color3.new(0.10, 0.10, 0.12),
	selectedBg = color3.new(0.13, 0.25, 0.16),
	selectedDot = color3.new(0.13, 0.77, 0.37),
}

local function fillRounded(rx, ry, rw, rh, radius, color)
	adapter.lib.DrawRectangleRounded(
		structs.Rectangle:new({ x = rx, y = ry, width = rw, height = rh }),
		radius / math.min(rw, rh) * 2,
		SEGMENTS,
		color
	)
end

local function drawText(font, text, x, y, size, color)
	if font then
		adapter.lib.DrawTextEx(font, text, vector.create(x, y), size, 1, color)
		return math.floor(adapter.lib.MeasureTextEx(font, text, size, 1).x)
	end
	adapter.lib.DrawText(text, x, y, size, color)
	return adapter.lib.MeasureText(text, size)
end

local function measureText(font, text, size)
	if font then
		return math.floor(adapter.lib.MeasureTextEx(font, text, size, 1).x)
	end
	return adapter.lib.MeasureText(text, size)
end

--[[
	data fields:
	  x, y, width       – layout
	  font               – optional raylib Font
	  fontSize           – optional, default 13
	  options = {
	    { label: string, description: string }
	  }
	  selectedIndex      – 1-based, default 1
	  onAction           – function(option, index)
	  shadowLayers       – optional
	  shadowOffsetY      – optional
--]]

return function(objects, data, raylib)
	local config = {
		obj_rect = nil,
		x = data.x or data[1] or 0,
		y = data.y or data[2] or 0,
		width = data.width or data[3] or 260,
		font = data.font,
		fontSize = data.fontSize or FONT_SIZE,
		options = data.options or {
			{
				label = "Merge pull request",
				description = "All commits added to the base branch via a merge commit.",
			},
			{ label = "Squash and merge", description = "Commits combined into one commit in the base branch." },
			{ label = "Rebase and merge", description = "Commits rebased and added to the base branch." },
		},
		selectedIndex = data.selectedIndex or 1,
		onAction = data.onAction,
		open = false,
		modifiers = {},
	}

	-- effects instance for the main (left) button
	local mainEffects = effects({
		baseColor = ColorLookupTable.primary,
		hoverColor = ColorLookupTable.primaryHov,
		pressColor = ColorLookupTable.primaryPrs,
		baseTransparency = 0,
		hoverTransparency = 0,
		pressTransparency = 0,
		shadowColor = color3.new(0, 0, 0),
		enablePress = true,
		shadowLayers = data.shadowLayers or 4,
		shadowOffsetX = data.shadowOffsetX or 0,
		shadowOffsetY = data.shadowOffsetY or 3,
		shadowSpread = data.shadowSpread or 2,
		pressSquish = 1,
	})

	-- effects instance for the chevron (right) button
	local chevEffects = effects({
		baseColor = ColorLookupTable.primary,
		hoverColor = ColorLookupTable.primaryHov,
		pressColor = ColorLookupTable.primaryPrs,
		baseTransparency = 0,
		hoverTransparency = 0,
		pressTransparency = 0,
		shadowColor = color3.new(0, 0, 0),
		enablePress = true,
		shadowLayers = data.shadowLayers or 4,
		shadowOffsetX = data.shadowOffsetX or 0,
		shadowOffsetY = data.shadowOffsetY or 3,
		shadowSpread = data.shadowSpread or 2,
		pressSquish = 1,
	})

	local rounded = data.rounded or { 0.3, SEGMENTS }

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

	wrapper.get_rect = function()
		return rect.new(config.x, config.y, config.width, BUTTON_H)
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		if r then
			config.x = r.x
			config.y = r.y
			config.width = r.width
		end

		local ox = config.x
		local oy = config.y
		local W = config.width
		local fnt = config.font
		local fs = config.fontSize

		local mousePressed = adapter.lib.IsMouseButtonPressed(0) == 1

		local mainW = W - CHEVRON_W
		local mainRect = rect.new(ox, oy, mainW, BUTTON_H)
		local chevRect = rect.new(ox + mainW, oy, CHEVRON_W, BUTTON_H)

		-- Drive effects with their respective rects
		mainEffects.setRect(mainRect)
		mainEffects.update(dt)
		chevEffects.setRect(chevRect)
		chevEffects.update(dt)

		local mainHov = mainEffects.isHovered()
		local chevHov = chevEffects.isHovered()

		if mainHov or chevHov then
			MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
		else
			MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
		end

		-- Render main button background via effects, then square off the right edge
		local mainDraw = mainEffects.renderAll(mainRect, rounded)
		adapter.lib.DrawRectangle(
			mainDraw.x + mainDraw.width - RADIUS,
			mainDraw.y,
			RADIUS,
			mainDraw.height,
			ColorLookupTable.primary:ToRaylib(0)
		)

		-- Render chevron button background via effects, shifted left to share the squared edge
		local chevDraw = chevEffects.renderAll(chevRect, rounded)

		-- Divider line between the two halves
		local pressShift = math.floor(mainEffects.getPressProgress() * 1)
		adapter.lib.DrawRectangle(
			ox + mainW,
			oy + 6 + pressShift,
			1,
			BUTTON_H - 12,
			ColorLookupTable.divider:ToRaylib(0.24)
		)

		-- Main button label
		local option = config.options[config.selectedIndex] or config.options[1]
		local labelW = measureText(fnt, option.label, fs)
		local labelX = mainDraw.x + math.floor((mainDraw.width - labelW) / 2)
		local labelY = mainDraw.y + math.floor((mainDraw.height - fs) / 2)

		local shadowOff = math.floor((1 - mainEffects.getPressProgress()) * 1)
		if fnt then
			adapter.lib.DrawTextEx(
				fnt,
				option.label,
				vector.create(labelX + shadowOff, labelY + shadowOff),
				fs,
				1,
				color3.new(0, 0, 0):ToRaylib(0.35)
			)
			adapter.lib.DrawTextEx(
				fnt,
				option.label,
				vector.create(labelX, labelY),
				fs,
				1,
				ColorLookupTable.textOnPri:ToRaylib(0)
			)
		else
			adapter.lib.DrawText(
				option.label,
				labelX + shadowOff,
				labelY + shadowOff,
				fs,
				color3.new(0, 0, 0):ToRaylib(0.35)
			)
			adapter.lib.DrawText(option.label, labelX, labelY, fs, ColorLookupTable.textOnPri:ToRaylib(0))
		end

		-- Chevron icon
		local cx = chevDraw.x + math.floor(chevDraw.width / 2)
		local cy = chevDraw.y + math.floor(chevDraw.height / 2)
		local hw, hh = 5, 3
		local open = config.open
		adapter.lib.DrawLineEx(
			vector.create(cx - hw, cy + (open and hh or -hh)),
			vector.create(cx, cy + (open and -hh or hh)),
			1.5,
			ColorLookupTable.textOnPri:ToRaylib(0)
		)
		adapter.lib.DrawLineEx(
			vector.create(cx, cy + (open and -hh or hh)),
			vector.create(cx + hw, cy + (open and hh or -hh)),
			1.5,
			ColorLookupTable.textOnPri:ToRaylib(0)
		)

		-- Main button click
		if mainHov and adapter.lib.IsMouseButtonReleased(0) == 1 and not _G.__aereon_blockInput then
			if config.onAction then
				config.onAction(option, config.selectedIndex)
			end
			config.open = false
		end

		-- Chevron click toggles dropdown
		if chevHov and mousePressed and not _G.__aereon_blockInput then
			config.open = not config.open
		end

		-- Dropdown popup
		if config.open then
			local popupW = W
			local popupH = POPUP_PAD * 2 + #config.options * ITEM_H
			local popupX = ox
			local popupY = oy + BUTTON_H + 4

			fillRounded(popupX - 2, popupY - 2, popupW + 4, popupH + 4, RADIUS + 1, color3.new(0, 0, 0):ToRaylib(0.24))
			fillRounded(popupX, popupY, popupW, popupH, RADIUS, ColorLookupTable.popupBg:ToRaylib(0))
			adapter.lib.DrawRectangleRoundedLines(
				structs.Rectangle:new({ x = popupX, y = popupY, width = popupW, height = popupH }),
				RADIUS / math.min(popupW, popupH) * 2,
				SEGMENTS,
				ColorLookupTable.border:ToRaylib(0)
			)

			local itemY = popupY + POPUP_PAD

			for i, opt in ipairs(config.options) do
				local itemRect = rect.new(popupX + 6, itemY, popupW - 12, ITEM_H)
				local itemHov = rect.MouseIsInRect(itemRect)
				local isSelected = (i == config.selectedIndex)

				if isSelected then
					fillRounded(
						itemRect.x,
						itemRect.y,
						itemRect.width,
						itemRect.height,
						6,
						ColorLookupTable.selectedBg:ToRaylib(0)
					)
				elseif itemHov then
					fillRounded(
						itemRect.x,
						itemRect.y,
						itemRect.width,
						itemRect.height,
						6,
						ColorLookupTable.surfaceHov:ToRaylib(0)
					)
				end

				local dotX = itemRect.x + 16
				local dotY = itemRect.y + math.floor(ITEM_H / 2)
				adapter.lib.DrawCircleLines(dotX, dotY, 6, ColorLookupTable.border:ToRaylib(0))
				if isSelected then
					adapter.lib.DrawCircle(dotX, dotY, 3, ColorLookupTable.selectedDot:ToRaylib(0))
				end

				local textX = itemRect.x + 32
				local lY = itemRect.y + 14
				local dY = lY + fs + 4
				drawText(fnt, opt.label, textX, lY, fs, ColorLookupTable.textPri:ToRaylib(0))
				drawText(fnt, opt.description, textX, dY, fs - 1, ColorLookupTable.textSec:ToRaylib(0))

				if i < #config.options then
					adapter.lib.DrawRectangle(
						popupX + 12,
						itemY + ITEM_H - 1,
						popupW - 24,
						1,
						ColorLookupTable.border:ToRaylib(0.31)
					)
				end

				if itemHov and mousePressed and not _G.__aereon_blockInput then
					config.selectedIndex = i
					config.open = false
				end

				if itemHov then
					MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
				end

				itemY = itemY + ITEM_H
			end

			if
				mousePressed
				and not _G.__aereon_blockInput
				and not rect.MouseIsInRect(rect.new(popupX, popupY, popupW, popupH))
				and not chevHov
				and not mainHov
			then
				config.open = false
			end
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
