local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")
local font = raylib.lib.GetFontDefault()

local function drawText(fnt, text, x, y, size, color)
	raylib.lib.DrawTextEx(fnt, text, vector.create(x, y), size, 1, color)
end

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		h = 0,
		s = 1,
		v = 1,
		a = 0,
		dragging = nil, -- "sv", "hue", "alpha"
		onChanged = data.onChanged,
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},
		font = data.font or font,
		fontSize = data.fontSize or 12,

		backgroundColor = data.backgroundColor or color3.new(0.13, 0.13, 0.15),
		backgroundTransparency = data.backgroundTransparency or 0,

		recentColors = {},
		maxRecentColors = 30,
	}

	local function updateColor()
		local c = color3.fromHSV(config.h, config.s, config.v)
		if config.onChanged then
			config.onChanged(c, config.a)
		end

		local r, g, b = c:ToRGB()
		local newColor = { r = r, g = g, b = b }

		local exists = false
		for _, col in ipairs(config.recentColors) do
			if col.r == newColor.r and col.g == newColor.g and col.b == newColor.b then
				exists = true
				break
			end
		end

		if not exists then
			table.insert(config.recentColors, 1, newColor)
			if #config.recentColors > config.maxRecentColors then
				table.remove(config.recentColors)
			end
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

	wrapper.setColor = function(col)
		local h, s, v = col:ToHSV()

		config.h = h
		config.s = s
		config.v = v

		updateColor()
	end

	wrapper.getColor = function()
		return color3.fromHSV(config.h, config.s, config.v)
	end

	wrapper.getAlpha = function()
		return config.a
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local fnt = config.font
		local fs = config.fontSize
		local mousePos = raylib.lib.GetMousePosition()
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		local padding = 12
		local barHeight = 14
		local spacing = 8
		local headerHeight = 28
		local hexRowHeight = 24
		local recentLabelHeight = 20
		local recentSwatchSize = 18
		local recentSwatchSpacing = 4
		local recentCols = 10

		-- Full width available for content
		local contentWidth = r.width - padding * 2

		-- SV square takes up the full width, height = width for square
		local svSize = contentWidth
		local svRect = rect.new(r.x + padding, r.y + headerHeight + padding, svSize, svSize)

		-- Hue bar  full width, horizontal
		local hueRect = rect.new(r.x + padding, svRect.y + svRect.height + spacing, contentWidth, barHeight)

		-- Alpha bar  full width, horizontal, below hue
		local alphaRect = rect.new(r.x + padding, hueRect.y + barHeight + spacing, contentWidth, barHeight)

		-- Hex row
		local hexRowY = alphaRect.y + barHeight + spacing
		local hexRect = rect.new(r.x + padding, hexRowY, contentWidth, hexRowHeight)

		-- Recent colors section
		local recentY = hexRowY + hexRowHeight + spacing
		local recentRows = math.ceil(config.maxRecentColors / recentCols)
		local recentTotalHeight = recentLabelHeight + recentRows * (recentSwatchSize + recentSwatchSpacing)
		local recentRect = rect.new(r.x + padding, recentY, contentWidth, recentTotalHeight)

		-- Draw background
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		-- Header: "Solid" label + close icon placeholder
		local mutedColor = color3.new(0.55, 0.55, 0.58)

		-- Handle mouse dragging
		if mouseDown then
			if not config.dragging then
				if rect.MouseIsInRect(svRect) then
					config.dragging = "sv"
				elseif rect.MouseIsInRect(hueRect) then
					config.dragging = "hue"
				elseif rect.MouseIsInRect(alphaRect) then
					config.dragging = "alpha"
				end
			end

			if config.dragging == "sv" then
				config.s = math.clamp((mousePos.x - svRect.x) / svRect.width, 0, 1)
				config.v = 1 - math.clamp((mousePos.y - svRect.y) / svRect.height, 0, 1)
				updateColor()
			elseif config.dragging == "hue" then
				config.h = math.clamp((mousePos.x - hueRect.x) / hueRect.width, 0, 1)
				updateColor()
			elseif config.dragging == "alpha" then
				config.a = math.clamp((mousePos.x - alphaRect.x) / alphaRect.width, 0, 1)
				if config.onChanged then
					config.onChanged(color3.fromHSV(config.h, config.s, config.v), config.a)
				end
			end
		else
			config.dragging = nil
		end

		-- === SV Picker ===
		local baseHueColor = color3.fromHSV(config.h, 1, 1)
		-- Base hue fill
		raylib.lib.DrawRectangle(svRect.x, svRect.y, svRect.width, svRect.height, baseHueColor:ToRaylib(0))
		-- White gradient left→right (saturation)
		raylib.lib.DrawRectangleGradientH(
			svRect.x,
			svRect.y,
			svRect.width,
			svRect.height,
			color3.new(1, 1, 1):ToRaylib(0),
			color3.new(1, 1, 1):ToRaylib(1)
		)
		-- Black gradient top→bottom (value)  drawn bottom-bright, top-dark
		raylib.lib.DrawRectangleGradientV(
			svRect.x,
			svRect.y,
			svRect.width,
			svRect.height,
			color3.new(0, 0, 0):ToRaylib(1),
			color3.new(0, 0, 0):ToRaylib(0)
		)

		-- SV cursor
		local cursorX = svRect.x + config.s * svRect.width
		local cursorY = svRect.y + (1 - config.v) * svRect.height
		raylib.lib.DrawCircleV(vector.create(cursorX, cursorY), 7, color3.new(1, 1, 1):ToRaylib(0))
		raylib.lib.DrawCircleV(
			vector.create(cursorX, cursorY),
			5,
			color3.fromHSV(config.h, config.s, config.v):ToRaylib(0)
		)

		-- === Hue Bar (horizontal rainbow) ===
		-- Draw rounded background
		raylib.lib.DrawRectangleRounded(rect:translate(hueRect), 0.5, 8, color3.new(0.08, 0.08, 0.1):ToRaylib(0))
		for i = 0, hueRect.width - 1 do
			local hue = i / hueRect.width
			raylib.lib.DrawRectangle(
				hueRect.x + i,
				hueRect.y + 1,
				1,
				hueRect.height - 2,
				color3.fromHSV(hue, 1, 1):ToRaylib(0)
			)
		end
		-- Hue thumb
		local hueX = hueRect.x + config.h * hueRect.width
		local hueMidY = hueRect.y + hueRect.height / 2
		raylib.lib.DrawCircleV(vector.create(hueX, hueMidY), 8, color3.new(1, 1, 1):ToRaylib(0))
		raylib.lib.DrawCircleV(vector.create(hueX, hueMidY), 6, color3.fromHSV(config.h, 1, 1):ToRaylib(0))

		-- === Alpha Bar (checker + gradient) ===
		-- Checker pattern to indicate transparency
		local checkerSize = 5
		for row = 0, math.ceil(alphaRect.height / checkerSize) - 1 do
			for col = 0, math.ceil(alphaRect.width / checkerSize) - 1 do
				local cx = alphaRect.x + col * checkerSize
				local cy = alphaRect.y + row * checkerSize
				local isLight = (row + col) % 2 == 0
				local checkerCol = isLight and color3.new(0.8, 0.8, 0.8):ToRaylib(0)
					or color3.new(0.55, 0.55, 0.55):ToRaylib(0)
				raylib.lib.DrawRectangle(cx, cy, checkerSize, checkerSize, checkerCol)
			end
		end
		local currentColor = color3.fromHSV(config.h, config.s, config.v)
		local r_val, g_val, b_val = currentColor:ToRGB()
		raylib.lib.DrawRectangleGradientH(
			alphaRect.x,
			alphaRect.y,
			alphaRect.width,
			alphaRect.height,
			structs.Color:new({ r = r_val, g = g_val, b = b_val, a = 0 }),
			structs.Color:new({ r = r_val, g = g_val, b = b_val, a = 255 })
		)
		-- Alpha thumb
		local alphaX = alphaRect.x + config.a * alphaRect.width
		local alphaMidY = alphaRect.y + alphaRect.height / 2
		raylib.lib.DrawCircleV(vector.create(alphaX, alphaMidY), 8, color3.new(1, 1, 1):ToRaylib(0))
		raylib.lib.DrawCircleV(
			vector.create(alphaX, alphaMidY),
			6,
			structs.Color:new({ r = r_val, g = g_val, b = b_val, a = math.floor(config.a * 255) })
		)

		-- === Hex + Opacity Row ===
		local hexText = string.format("#%02x%02x%02x", r_val, g_val, b_val)
		local opacityText = string.format("%d%%", math.floor(config.a * 100))

		-- Small color preview swatch
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(hexRect.x, hexRect.y + 2, 20, 20)),
			0.3,
			4,
			currentColor:ToRaylib(0)
		)

		-- Hex label + value
		drawText(fnt, "HEX", hexRect.x + 26, hexRect.y + 5, fs - 1, mutedColor:ToRaylib(0))
		drawText(fnt, hexText, hexRect.x + 52, hexRect.y + 5, fs, color3.new(0.2, 0.2, 0.22):ToRaylib(0))

		-- Opacity on the right
		local opW = 36
		drawText(
			fnt,
			opacityText,
			hexRect.x + hexRect.width - opW,
			hexRect.y + 5,
			fs,
			color3.new(0.2, 0.2, 0.22):ToRaylib(0)
		)

		-- === Document Colors ===
		drawText(fnt, "Document colors", recentRect.x, recentRect.y, fs - 1, mutedColor:ToRaylib(0))

		for i, col in ipairs(config.recentColors) do
			local row = math.floor((i - 1) / recentCols)
			local column = (i - 1) % recentCols
			local cx = recentRect.x + column * (recentSwatchSize + recentSwatchSpacing)
			local cy = recentRect.y + recentLabelHeight + row * (recentSwatchSize + recentSwatchSpacing)

			local swatchRect = rect.new(cx, cy, recentSwatchSize, recentSwatchSize)
			raylib.lib.DrawRectangleRounded(
				rect:translate(swatchRect),
				0.2,
				4,
				structs.Color:new({ r = col.r, g = col.g, b = col.b, a = 255 })
			)

			if mousePressed and rect.MouseIsInRect(swatchRect) then
				local rn, gn, bn = col.r / 255, col.g / 255, col.b / 255
				local max_v = math.max(rn, gn, bn)
				local min_v = math.min(rn, gn, bn)
				local delta = max_v - min_v

				config.v = max_v
				config.s = max_v == 0 and 0 or delta / max_v

				if delta == 0 then
					config.h = 0
				elseif max_v == rn then
					config.h = ((gn - bn) / delta) % 6
				elseif max_v == gn then
					config.h = (bn - rn) / delta + 2
				else
					config.h = (rn - gn) / delta + 4
				end
				config.h = (config.h / 6) % 1

				if config.onChanged then
					config.onChanged(color3.fromHSV(config.h, config.s, config.v), config.a)
				end
			end
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
