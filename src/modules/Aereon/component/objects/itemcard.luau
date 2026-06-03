local raylib = require("@raylib")
local structs = raylib.structs
local rect = require("@arect")
local color3 = require("@Color3")
local MouseCursor = require("@Kinemium.MouseCursor")

local function lerp(a, b, t)
	return a + (b - a) * t
end
local function easeOut3(t)
	return 1 - (1 - t) ^ 3
end

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		title = data.title or "Sodium",
		description = data.description or "The fastest and most compatible rendering optimization mod.",
		downloads = data.downloads or "109.6M",
		likes = data.likes or "32.0k",
		category = data.category or "Optimization",
		icon = data.icon,
		bannerImage = data.bannerImage,
		font = data.font,

		backgroundColor = data.backgroundColor or color3.new(0.094, 0.094, 0.110),
		bannerColor = data.bannerColor or color3.new(0.08, 0.18, 0.08),
		borderColor = data.borderColor or color3.new(0.18, 0.18, 0.20),
		hoverBorderColor = data.hoverBorderColor or color3.new(0.32, 0.32, 0.36),
		iconBgColor = data.iconBgColor or color3.new(0.10, 0.28, 0.10),
		accentColor = data.accentColor or color3.new(0.30, 0.86, 0.50),
		textColor = data.textColor or color3.new(0.91, 0.91, 0.93),
		dimTextColor = data.dimTextColor or color3.new(0.40, 0.40, 0.43),
		categoryColor = data.categoryColor or color3.new(0.30, 0.86, 0.50),

		visible = data.visible ~= false,
		lastSize = { width = data.width or data[3] or 0, height = data.height or data[4] or 0 },
		onClick = data.onClick,

		hoverT = 0,
		entryT = 0,
	}

	local BANNER_RATIO = 0.38
	local ICON_SIZE = 40
	local ICON_PAD = 14
	local FOOTER_H = 30
	local ENTRY_SPEED = 6
	local HOVER_SPEED = 9

	local wrapper = {}

	wrapper.get_rect = function()
		if not config.visible then
			return rect.new(config.obj_rect.x, config.obj_rect.y, 0, 0)
		end
		if (config.obj_rect.width == 0 or config.obj_rect.height == 0) and config.lastSize then
			return rect.new(config.obj_rect.x, config.obj_rect.y, config.lastSize.width, config.lastSize.height)
		end
		return config.obj_rect
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		if prop == "obj_rect" and value then
			config.obj_rect = value
			if value.width and value.height and value.width > 0 and value.height > 0 then
				config.lastSize = { width = value.width, height = value.height }
			end
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end

		local r = config.obj_rect
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local isHovered = rect.MouseIsInRect(r)

		-- animate
		config.entryT = math.min(1, config.entryT + dt * ENTRY_SPEED)
		local entryE = easeOut3(config.entryT)
		local slideOffset = (1 - entryE) * 30

		local targetHover = isHovered and 1 or 0
		config.hoverT = lerp(config.hoverT, targetHover, math.min(1, dt * HOVER_SPEED))
		local ht = config.hoverT

		if isHovered then
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
		else
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
		end

		local drawX = r.x - slideOffset
		local lift = ht * -2

		-- card shadow
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(drawX + 2, r.y + 3 + lift, r.width, r.height)),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(lerp(0.85, 0.5, ht))
		)

		-- card body
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(drawX, r.y + lift, r.width, r.height)),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		-- banner area
		local bannerH = math.floor(r.height * BANNER_RATIO)
		local bannerRect = rect.new(drawX, r.y + lift, r.width, bannerH)

		if config.bannerImage then
			raylib.lib.DrawTexturePro(
				config.bannerImage.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.bannerImage.x, height = config.bannerImage.y }),
				rect:translate(bannerRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		else
			-- subtle tinted banner, slightly lighter on hover
			local bannerCol = config.bannerColor:Lerp(config.bannerColor:AdjustBrightness(0.04), ht)
			raylib.lib.DrawRectangleRounded(
				rect:translate(bannerRect),
				config.rounded[1],
				config.rounded[2],
				bannerCol:ToRaylib(0)
			)
			-- cover the bottom corners so banner only rounds at top
			raylib.lib.DrawRectangle(
				math.floor(drawX),
				math.floor(r.y + lift + bannerH - 10),
				r.width,
				10,
				bannerCol:ToRaylib(0)
			)
		end

		-- banner-to-body fade strip
		raylib.lib.DrawRectangleGradientV(
			math.floor(drawX),
			math.floor(r.y + lift + bannerH - 16),
			r.width,
			16,
			config.bannerColor:ToRaylib(1),
			config.backgroundColor:ToRaylib(0)
		)

		-- icon box (straddles banner/body boundary)
		local iconY = r.y + lift + bannerH - ICON_SIZE / 2
		local iconRect = rect.new(drawX + ICON_PAD, iconY, ICON_SIZE, ICON_SIZE)
		local iconBgCol = config.iconBgColor:Lerp(config.iconBgColor:AdjustBrightness(0.06), ht)
		raylib.lib.DrawRectangleRounded(rect:translate(iconRect), 0.2, 8, iconBgCol:ToRaylib(0))

		if config.icon then
			raylib.lib.DrawTexturePro(
				config.icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }),
				rect:translate(iconRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end

		-- body text area
		local bodyTop = r.y + lift + bannerH + ICON_SIZE / 2 + 6
		local textX = drawX + ICON_PAD

		-- title
		local titleCol = config.textColor:Lerp(config.accentColor, ht * 0.12)
		if config.font then
			raylib.lib.DrawTextEx(config.font, config.title, vector.create(textX, bodyTop), 15, 1, titleCol:ToRaylib(0))
		else
			raylib.lib.DrawText(config.title, math.floor(textX), math.floor(bodyTop), 15, titleCol:ToRaylib(0))
		end

		local descY = bodyTop + 20
		local descW = r.width - ICON_PAD * 2
		local descSize = 11
		local descSpace = 0.5
		local lineH = 15

		local words = {}
		for word in config.description:gmatch("%S+") do
			table.insert(words, word)
		end

		local currentLine = ""
		local lineY = descY

		for _, word in ipairs(words) do
			local testLine = currentLine == "" and word or currentLine .. " " .. word
			local lineW
			if config.font then
				lineW = raylib.lib.MeasureTextEx(config.font, testLine, descSize, descSpace).x
			else
				lineW = raylib.lib.MeasureText(testLine, descSize)
			end

			if lineW > descW then
				if config.font then
					raylib.lib.DrawTextEx(
						config.font,
						currentLine,
						vector.create(textX, lineY),
						descSize,
						descSpace,
						config.dimTextColor:ToRaylib(0)
					)
				else
					raylib.lib.DrawText(
						currentLine,
						math.floor(textX),
						math.floor(lineY),
						descSize,
						config.dimTextColor:ToRaylib(0)
					)
				end
				currentLine = word
				lineY = lineY + lineH
			else
				currentLine = testLine
			end
		end
		if currentLine ~= "" then
			if config.font then
				raylib.lib.DrawTextEx(
					config.font,
					currentLine,
					vector.create(textX, lineY),
					descSize,
					descSpace,
					config.dimTextColor:ToRaylib(0)
				)
			else
				raylib.lib.DrawText(
					currentLine,
					math.floor(textX),
					math.floor(lineY),
					descSize,
					config.dimTextColor:ToRaylib(0)
				)
			end
		end

		-- footer separator
		local footerY = r.y + lift + r.height - FOOTER_H
		raylib.lib.DrawRectangle(math.floor(drawX), math.floor(footerY), r.width, 1, config.borderColor:ToRaylib(0))

		-- footer stats
		local statY = footerY + 9
		local statSize = 10
		local statX = textX

		-- downloads icon (small square placeholder  swap for icon texture if available)
		raylib.lib.DrawRectangle(math.floor(statX), math.floor(statY + 1), 9, 9, config.dimTextColor:ToRaylib(0))
		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.downloads,
				vector.create(statX + 13, statY),
				statSize,
				0.5,
				config.dimTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.downloads,
				math.floor(statX + 13),
				math.floor(statY),
				statSize,
				config.dimTextColor:ToRaylib(0)
			)
		end

		local likesX = statX + 72
		raylib.lib.DrawRectangle(math.floor(likesX), math.floor(statY + 1), 9, 9, config.dimTextColor:ToRaylib(0))
		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.likes,
				vector.create(likesX + 13, statY),
				statSize,
				0.5,
				config.dimTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.likes,
				math.floor(likesX + 13),
				math.floor(statY),
				statSize,
				config.dimTextColor:ToRaylib(0)
			)
		end

		-- category badge (right-aligned)
		local catSize = 10
		local catW
		if config.font then
			catW = raylib.lib.MeasureTextEx(config.font, config.category, catSize, 0.5).x
		else
			catW = raylib.lib.MeasureText(config.category, catSize)
		end
		local badgePadX = 8
		local badgeW = catW + badgePadX * 2
		local badgeH = 18
		local badgeX = drawX + r.width - ICON_PAD - badgeW
		local badgeY = footerY + (FOOTER_H - badgeH) / 2

		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(badgeX, badgeY, badgeW, badgeH)),
			0.4,
			6,
			config.iconBgColor:ToRaylib(0)
		)

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.category,
				vector.create(badgeX + badgePadX, badgeY + 4),
				catSize,
				0.5,
				config.categoryColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.category,
				math.floor(badgeX + badgePadX),
				math.floor(badgeY + 4),
				catSize,
				config.categoryColor:ToRaylib(0)
			)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end

		if isHovered and mousePressed and config.onClick then
			config.onClick()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
