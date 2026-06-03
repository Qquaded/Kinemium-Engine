--[[
	ServerCard – Modern flat server card component.

	Collapsed view shows:
	  • Online status dot + server name + MOTD
	  • Player count badge, latency badge, chevron

	Expanded (click to toggle) shows:
	  • Meta row: address:port, map, uptime, tick/tps
	  • Player list rows: initials block, name, id, session time, ping bars + ms

	No IPs are shown anywhere.

	data fields:
	  x, y, width               – layout (height is auto-calculated)
	  font                       – optional raylib Font
	  name                       – server display name
	  motd                       – message of the day
	  address                    – server address string (display only)
	  port                       – number
	  latency                    – number (ms, overall server ping)
	  map                        – string
	  uptime                     – number (seconds)
	  tick                       – number
	  tickRate                   – number
	  players = {
	    max    : number
	    sample : { { name, id, connectedAt, ping }, ... }
	  }
--]]

local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")
local MouseCursor = require("@Kinemium.MouseCursor")

local T = {
	-- surfaces
	card = color3.new(0.11, 0.11, 0.13), -- card bg
	cardHover = color3.new(0.14, 0.14, 0.16), -- header hover tint
	surface = color3.new(0.08, 0.08, 0.09), -- meta bar / player row alt
	-- borders
	border = color3.new(0.22, 0.22, 0.26), -- card outer + dividers
	-- text
	textPri = color3.new(0.92, 0.92, 0.94),
	textSec = color3.new(0.55, 0.55, 0.60),
	textTer = color3.new(0.35, 0.35, 0.40),
	-- accents
	green = color3.new(0.13, 0.77, 0.37), -- online dot / good ping
	yellow = color3.new(0.92, 0.71, 0.00),
	orange = color3.new(0.98, 0.45, 0.09),
	red = color3.new(0.94, 0.27, 0.27),
	-- badge bg
	badgeBg = color3.new(0.18, 0.18, 0.22),
}

local RADIUS = 8 -- corner radius for rounded rects
local SEGMENTS = 6 -- roundness quality

local function col(c3, alpha)
	local r, g, b = c3:ToRGB()
	return structs.Color:new({ r = r, g = g, b = b, a = alpha or 255 })
end

local function colA(c3, a255) -- explicit byte alpha
	return col(c3, a255)
end

local function fillRounded(rx, ry, rw, rh, radius, color)
	raylib.lib.DrawRectangleRounded(
		structs.Rectangle:new({ x = rx, y = ry, width = rw, height = rh }),
		radius / math.min(rw, rh) * 2,
		SEGMENTS,
		color
	)
end

local function strokeRounded(rx, ry, rw, rh, radius, thick, color) end

local function hline(rx, ry, rw, color)
	raylib.lib.DrawRectangle(rx, ry, rw, 1, color)
end

local function drawText(font, text, x, y, size, color)
	if font then
		raylib.lib.DrawTextEx(font, text, vector.create(x, y), size, 1, color)
		return math.floor(raylib.lib.MeasureTextEx(font, text, size, 1).x)
	else
		raylib.lib.DrawText(text, x, y, size, color)
		return raylib.lib.MeasureText(text, size)
	end
end

local function measureText(font, text, size)
	if font then
		return math.floor(raylib.lib.MeasureTextEx(font, text, size, 1).x)
	else
		return raylib.lib.MeasureText(text, size)
	end
end

local function pingColor(ping)
	if ping <= 60 then
		return T.green
	elseif ping <= 120 then
		return T.yellow
	elseif ping <= 250 then
		return T.orange
	else
		return T.red
	end
end

local function drawPingBars(rightEdge, midY, ping)
	local barW, gap = 4, 2
	local heights = { 5, 8, 11, 14 }
	local thresholds = { 60, 120, 250, math.huge }
	local filled = 0
	for i, t in ipairs(thresholds) do
		if ping <= t then
			filled = i
			break
		end
	end
	local pCol = pingColor(ping)
	local totalW = 4 * barW + 3 * gap
	local sx = rightEdge - totalW
	for i = 1, 4 do
		local bx = sx + (i - 1) * (barW + gap)
		local bh = heights[i]
		local by = midY - math.floor(bh / 2)
		local bcol = i <= filled and col(pCol) or col(T.border)
		raylib.lib.DrawRectangle(bx, by, barW, bh, bcol)
	end
	return sx
end

local function fmtUp(s)
	s = math.floor(s)
	if s >= 3600 then
		return string.format("%dh %dm", math.floor(s / 3600), math.floor((s % 3600) / 60))
	elseif s >= 60 then
		return string.format("%dm %ds", math.floor(s / 60), s % 60)
	else
		return string.format("%ds", s)
	end
end

local function drawChevron(cx, cy, size, open, color)
	-- open = pointing up (▲), closed = pointing down (▼)
	local h = math.floor(size * 0.45)
	local hw = math.floor(size * 0.5)
	local dy = open and -h or h
	raylib.lib.DrawLineEx(
		vector.create(cx - hw, cy - (open and h / 2 or -h / 2)),
		vector.create(cx, cy + (open and -h / 2 or h / 2)),
		1.5,
		color
	)
	raylib.lib.DrawLineEx(
		vector.create(cx, cy + (open and -h / 2 or h / 2)),
		vector.create(cx + hw, cy - (open and h / 2 or -h / 2)),
		1.5,
		color
	)
end

local HEADER_H = 56
local META_H = 38
local PLAYER_H = 44
local PAD = 16 -- horizontal padding inside card
local INNER_PAD = 12 -- tighter padding for sub-rows

return function(objects, data)
	local config = {
		x = data.x or 0,
		y = data.y or 0,
		width = data.width or 520,
		font = data.font,

		name = data.name or "Kinemium Server",
		motd = data.motd or "A server is online.",
		address = data.address or "0.0.0.0",
		port = data.port or 1234,
		latency = data.latency or 0,
		map = data.map or "unknown",
		uptime = data.uptime or 0,
		tick = data.tick or 0,
		tickRate = data.tickRate or 20,
		players = data.players or { max = 16, sample = {} },

		expanded = false,
		obj_rect = data.obj_rect or nil,

		onPlay = data.onPlay or nil,
	}

	local function cardHeight()
		if not config.expanded then
			return HEADER_H
		end
		local n = #config.players.sample
		return HEADER_H + META_H + 24 + n * PLAYER_H -- 24 = players section header
	end

	local wrapper = {}
	wrapper.set = function(p, v)
		config[p] = v
		return wrapper
	end
	wrapper.get = function(p)
		return config[p]
	end
	wrapper.get_rect = function()
		return rect.new(config.x, config.y, config.width, cardHeight())
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		if r then
			config.x = r.x
			config.y = r.y
			config.width = r.width
		end

		local ox, oy = config.x, config.y
		local W = config.width
		local H = cardHeight()
		local font = config.font

		local mouseClick = raylib.lib.IsMouseButtonPressed(0) == 1

		fillRounded(ox, oy, W, H, RADIUS, col(T.card))
		strokeRounded(ox, oy, W, H, RADIUS, 1, col(T.border))

		local headerRect = rect.new(ox, oy, W, HEADER_H)
		local hHovered = rect.MouseIsInRect(headerRect)

		if hHovered then
			-- tint just the header area (clipped to top rounded corners when collapsed)
			fillRounded(ox, oy, W, config.expanded and HEADER_H or H, RADIUS, col(T.cardHover))
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
		else
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
		end

		if hHovered and mouseClick then
			config.expanded = not config.expanded
		end

		-- Online dot
		local dotX = ox + PAD + 4
		local dotY = oy + math.floor(HEADER_H / 2)
		raylib.lib.DrawCircle(dotX, dotY, 4, col(T.green))

		-- Server name
		local nameX = dotX + 14
		local nameW = drawText(font, config.name, nameX, oy + 12, 16, col(T.textPri))

		-- MOTD below name
		drawText(font, config.motd, nameX, oy + 32, 12, col(T.textSec))

		-- Right side: player badge, ping badge, chevron
		local rightX = ox + W - PAD

		-- Play button
		local playW, playH = 60, 24
		local playX = rightX - playW
		local playY = dotY - math.floor(playH / 2)

		local playRect = rect.new(playX, playY, playW, playH)
		local playHover = rect.MouseIsInRect(playRect)

		fillRounded(playX, playY, playW, playH, 6, col(playHover and T.green or T.badgeBg))
		drawText(font, "Play", playX + 12, playY + 5, 13, col(T.textPri))

		if playHover and mouseClick then
			if config.onPlay then
				config.onPlay(config)
			end
		end

		rightX = playX - 8

		-- Chevron
		local chevX = rightX - 8
		drawChevron(chevX, dotY, 14, config.expanded, col(T.textTer))
		rightX = chevX - 14

		-- Ping badge
		local pingStr = tostring(config.latency) .. "ms"
		local pCol = pingColor(config.latency)
		local pingW = measureText(font, pingStr, 13)
		local badgePad = 8
		local badgeW = pingW + badgePad * 2
		local badgeX = rightX - badgeW
		local badgeY = dotY - 10
		fillRounded(badgeX, badgeY, badgeW, 20, 5, col(T.badgeBg))
		drawText(font, pingStr, badgeX + badgePad, badgeY + 3, 13, col(pCol))
		rightX = badgeX - 8

		-- Players badge
		local plStr = #config.players.sample .. " / " .. config.players.max
		local plW = measureText(font, plStr, 13)
		local plBadW = plW + badgePad * 2
		local plBadX = rightX - plBadW
		fillRounded(plBadX, badgeY, plBadW, 20, 5, col(T.badgeBg))
		drawText(font, plStr, plBadX + badgePad, badgeY + 3, 13, col(T.textSec))

		--  Expanded section
		if config.expanded then
			local cy = oy + HEADER_H

			-- Divider below header
			hline(ox + 1, cy, W - 2, col(T.border))

			local metaCols = {
				{ label = "address", value = config.address .. ":" .. config.port },
				{ label = "map", value = config.map },
				{ label = "uptime", value = fmtUp(config.uptime) },
				{ label = "tick", value = config.tick .. " @ " .. config.tickRate .. "tps" },
			}
			local colW = math.floor(W / #metaCols)
			for i, mc in ipairs(metaCols) do
				local mcx = ox + (i - 1) * colW + INNER_PAD
				local lY = cy + 6
				local vY = lY + 13
				drawText(font, mc.label, mcx, lY, 11, col(T.textTer))
				drawText(font, mc.value, mcx, vY, 12, col(T.textPri))
				if i < #metaCols then
					raylib.lib.DrawRectangle(ox + i * colW, cy + 6, 1, META_H - 12, col(T.border))
				end
			end
			cy = cy + META_H

			hline(ox + 1, cy, W - 2, col(T.border))

			local phY = cy
			drawText(font, "PLAYERS", ox + PAD, cy + 7, 11, col(T.textTer))
			local onlineStr = tostring(#config.players.sample) .. " online"
			local osW = measureText(font, onlineStr, 11)
			drawText(font, onlineStr, ox + W - PAD - osW, cy + 7, 11, col(T.textTer))
			cy = cy + 24

			hline(ox + 1, cy, W - 2, col(T.border))

			--  Player rows
			for idx, player in ipairs(config.players.sample) do
				local rowY = cy
				local rowMY = rowY + math.floor(PLAYER_H / 2)

				-- Alternating row tint
				if idx % 2 == 0 then
					raylib.lib.DrawRectangle(ox + 1, rowY, W - 2, PLAYER_H, colA(T.surface, 80))
				end

				-- Initials block (no icon)
				local initStr = string.upper(string.sub(player.name, 1, 2))
				local blkS = 28
				local blkX = ox + PAD
				local blkY = rowY + math.floor((PLAYER_H - blkS) / 2)
				fillRounded(blkX, blkY, blkS, blkS, 5, col(T.badgeBg))
				strokeRounded(blkX, blkY, blkS, blkS, 5, 1, col(T.border))
				local iW = measureText(font, initStr, 11)
				drawText(
					font,
					initStr,
					blkX + math.floor((blkS - iW) / 2),
					blkY + math.floor((blkS - 11) / 2),
					11,
					col(T.textSec)
				)

				-- Name + id
				local infoX = blkX + blkS + 10
				drawText(font, player.name, infoX, rowY + 10, 14, col(T.textPri))
				drawText(font, "#" .. tostring(player.id), infoX, rowY + 27, 11, col(T.textTer))

				-- Right side: session + ping bars + ms
				local rightEdge = ox + W - PAD
				local msStr = tostring(player.ping) .. "ms"
				local msW = measureText(font, msStr, 13)
				drawText(font, msStr, rightEdge - msW, rowMY - 6, 13, col(pingColor(player.ping)))

				local barsRight = rightEdge - msW - 8
				drawPingBars(barsRight, rowMY, player.ping)

				-- Session time
				local sessStr = fmtUp(math.max(0, os.time() - player.connectedAt))
				local sessW = measureText(font, sessStr, 11)
				drawText(font, sessStr, barsRight - 8 - sessW, rowMY - 5, 11, col(T.textTer))

				-- Row divider (not after last row)
				if idx < #config.players.sample then
					hline(ox + PAD, rowY + PLAYER_H, W - PAD * 2, col(T.border))
				end

				cy = cy + PLAYER_H
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
