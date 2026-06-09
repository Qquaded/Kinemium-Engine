local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")
local font = raylib.lib.GetFontDefault()

local function drawText(fnt, text, x, y, size, color)
	raylib.lib.DrawTextEx(fnt, text, vector.create(x, y), size, 1, color)
end

local function measureText(fnt, text, size)
	local v = raylib.lib.MeasureTextEx(fnt, text, size, 1)
	return v.x, v.y
end

local ZONE_COLORS = {
	color3.new(0.20, 0.60, 1.00),
	color3.new(0.20, 0.85, 0.55),
	color3.new(1.00, 0.70, 0.15),
	color3.new(1.00, 0.35, 0.35),
	color3.new(0.75, 0.35, 1.00),
	color3.new(0.20, 0.90, 0.90),
	color3.new(1.00, 0.50, 0.15),
	color3.new(1.00, 0.40, 0.75),
}

local function zoneColor(name)
	local h = 0
	for i = 1, #name do
		h = (h * 31 + string.byte(name, i)) % #ZONE_COLORS
	end
	return ZONE_COLORS[h + 1]
end

local function fmtMs(secs)
	return string.format("%.2fms", secs * 1000)
end

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		profiler = data.profiler,
		visible = true,
		rounded = data.rounded or { 0.06, 8 },
		font = data.font or font,
		fontSize = data.fontSize or 11,
		backgroundColor = data.backgroundColor or color3.new(0.10, 0.10, 0.12),
		backgroundTransparency = data.backgroundTransparency or 0.08,
		headerColor = data.headerColor or color3.new(0.14, 0.14, 0.17),
		borderColor = data.borderColor or color3.new(0.25, 0.25, 0.30),
		textColor = data.textColor or color3.new(0.90, 0.90, 0.92),
		mutedColor = data.mutedColor or color3.new(0.50, 0.50, 0.55),
		gridColor = data.gridColor or color3.new(0.22, 0.22, 0.26),
		selectedFrameColor = data.selectedFrameColor or color3.new(1.00, 1.00, 1.00),
		markerColor = data.markerColor or color3.new(1.00, 0.35, 0.35),
		modifiers = {},

		-- state
		paused = false,
		_snapshot = nil, -- { frames, latestFrame } frozen when paused
		_selectedFrame = nil,
		_hoverFrame = nil,
		_tooltipZone = nil,
		_prevMouseDown = false, -- for edge detection
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.isVisible = function()
		return config.visible
	end

	local function layout()
		local r = config.obj_rect
		local pad = 8

		local headerH = 22
		local headerRect = rect.new(r.x, r.y, r.width, headerH)

		local timelineH = 48
		local timelineRect = rect.new(r.x + pad, r.y + headerH + pad, r.width - pad * 2, timelineH)

		local detailY = timelineRect.y + timelineH + pad
		local detailH = r.height - (detailY - r.y) - pad
		local detailRect = rect.new(r.x + pad, detailY, r.width - pad * 2, detailH)

		return {
			pad = pad,
			headerRect = headerRect,
			timelineRect = timelineRect,
			detailRect = detailRect,
		}
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end

		local r = config.obj_rect
		local fnt = config.font
		local fs = config.fontSize
		local profiler = config.profiler
		if not profiler then
			return
		end

		-- ── Input: single rising-edge click, computed once per frame ────────────
		local mouseDownNow = raylib.lib.IsMouseButtonDown(0) == 1
		local clicked = mouseDownNow and not config._prevMouseDown
		config._prevMouseDown = mouseDownNow

		-- Key toggle (Z)
		if raylib.lib.IsKeyPressed(raylib.const.KeyboardKey.KEY_Z) then
			config.paused = not config.paused
			if config.paused then
				config._snapshot = {
					frames = profiler:GetFrames(),
					latestFrame = profiler:GetLatestFrame(),
				}
			else
				config._snapshot = nil
				config._selectedFrame = nil
			end
		end

		-- Always keep snapshot fresh while live so it's ready the moment we pause
		if not config.paused then
			config._snapshot = {
				frames = profiler:GetFrames(),
				latestFrame = profiler:GetLatestFrame(),
			}
		end

		local snapshot = config._snapshot or { frames = {}, latestFrame = nil }
		local frames = snapshot.frames
		local latestFrame = snapshot.latestFrame
		local numFrames = #frames

		local L = layout()

		-- ── Background ──────────────────────────────────────────────────────────
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		-- ── Header ──────────────────────────────────────────────────────────────
		local hdr = L.headerRect
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(hdr.x, hdr.y, hdr.width, hdr.height)),
			0.3,
			6,
			config.headerColor:ToRaylib(0)
		)

		drawText(fnt, "Microprofiler", hdr.x + 8, hdr.y + 5, fs, config.textColor:ToRaylib(0))

		-- Click header to toggle pause (uses rising edge so it fires exactly once)
		if clicked and rect.MouseIsInRect(hdr) then
			config.paused = not config.paused
			if config.paused then
				config._snapshot = {
					frames = profiler:GetFrames(),
					latestFrame = profiler:GetLatestFrame(),
				}
			else
				config._snapshot = nil
				config._selectedFrame = nil
			end
		end

		-- Pause indicator
		local pauseLabel = config.paused and "[PAUSED]" or "[LIVE]"
		local pauseCol = config.paused and color3.new(1.0, 0.70, 0.15) or color3.new(0.25, 0.85, 0.45)
		local pw = measureText(fnt, pauseLabel, fs)
		drawText(fnt, pauseLabel, hdr.x + hdr.width - pw - 90, hdr.y + 5, fs, pauseCol:ToRaylib(0))

		-- FPS / frame time
		if latestFrame then
			local totalMs = 0
			for _, z in ipairs(latestFrame.zones or {}) do
				totalMs = totalMs + (z.duration or 0)
			end
			local fpsStr = string.format("%.1f fps  |  %s", dt > 0 and 1 / dt or 0, fmtMs(totalMs))
			local tw = measureText(fnt, fpsStr, fs)
			drawText(fnt, fpsStr, hdr.x + hdr.width - tw - 8, hdr.y + 5, fs, config.mutedColor:ToRaylib(0))
		end

		-- ── Timeline strip ──────────────────────────────────────────────────────
		local tl = L.timelineRect

		raylib.lib.DrawRectangle(tl.x, tl.y, tl.width, tl.height, config.headerColor:ToRaylib(0))
		raylib.lib.DrawRectangleLines(tl.x, tl.y, tl.width, tl.height, config.gridColor:ToRaylib(0))

		local targetMs = 1 / 60
		local maxMs = 0

		for _, f in ipairs(frames) do
			local total = 0
			for _, z in ipairs(f.zones or {}) do
				total = total + (z.duration or 0)
			end
			if total > maxMs then
				maxMs = total
			end
		end
		if maxMs == 0 then
			maxMs = targetMs * 2
		end

		-- 60fps target line
		local targetRatio = math.min(targetMs / maxMs, 1)
		local targetLineY = tl.y + tl.height - math.floor(targetRatio * tl.height)
		raylib.lib.DrawLine(tl.x, targetLineY, tl.x + tl.width, targetLineY, color3.new(0.30, 0.85, 0.45):ToRaylib(0.4))

		-- Frame bars
		local maxBars = profiler.maxFrames or 120
		local barW = math.max(1, math.floor(tl.width / maxBars))
		local startI = math.max(1, numFrames - math.floor(tl.width / barW) + 1)

		config._hoverFrame = nil
		for i = startI, numFrames do
			local slot = i - startI
			local bx = tl.x + slot * barW
			local total = 0
			for _, z in ipairs(frames[i].zones or {}) do
				total = total + (z.duration or 0)
			end
			local ratio = math.min(total / maxMs, 1)
			local bh = math.max(1, math.floor(ratio * tl.height))
			local by = tl.y + tl.height - bh

			local barCol
			local norm = total / targetMs
			if norm <= 1 then
				barCol = color3.new(0.20 + 0.60 * norm, 0.75, 0.25)
			else
				local over = math.min((norm - 1) / 2, 1)
				barCol = color3.new(1.0, 0.75 - 0.55 * over, 0.25 - 0.20 * over)
			end

			if config._selectedFrame == i then
				raylib.lib.DrawRectangle(bx, tl.y, barW, tl.height, config.selectedFrameColor:ToRaylib(0.06))
			end

			raylib.lib.DrawRectangle(bx, by, math.max(barW - 1, 1), bh, barCol:ToRaylib(0))

			local bRect = rect.new(bx, tl.y, barW, tl.height)
			if rect.MouseIsInRect(bRect) then
				config._hoverFrame = i
				local tip = string.format("Frame %d  %s", i, fmtMs(total))
				drawText(fnt, tip, bx + 2, tl.y - fs - 2, fs, config.textColor:ToRaylib(0))
			end
		end

		-- Click timeline to select a frame (only fires if NOT also on header)
		if clicked and rect.MouseIsInRect(tl) and not rect.MouseIsInRect(hdr) then
			config._selectedFrame = config._hoverFrame
			-- clicking a frame bar also pauses so the detail stays frozen
			if config._hoverFrame and not config.paused then
				config.paused = true
				config._snapshot = {
					frames = profiler:GetFrames(),
					latestFrame = profiler:GetLatestFrame(),
				}
			end
		end

		-- ── Detail panel ────────────────────────────────────────────────────────
		local det = L.detailRect
		if det.height < 20 then
			for _, m in pairs(config.modifiers) do
				m()
			end
			return
		end

		drawText(fnt, "Frame detail", det.x, det.y - fs - 2, fs - 1, config.mutedColor:ToRaylib(0))

		local gridMs = { 0, 4, 8, 12, 16, 20, 33 }
		local detMaxMs = 33.3 / 1000
		for _, gm in ipairs(gridMs) do
			local gx = det.x + math.floor((gm / 1000) / detMaxMs * det.width)
			if gx <= det.x + det.width then
				raylib.lib.DrawLine(gx, det.y, gx, det.y + det.height, config.gridColor:ToRaylib(0))
				drawText(fnt, gm .. "ms", gx + 2, det.y + 1, fs - 2, config.mutedColor:ToRaylib(0.4))
			end
		end

		local marker16x = det.x + math.floor(targetMs / detMaxMs * det.width)
		raylib.lib.DrawLine(marker16x, det.y, marker16x, det.y + det.height, config.markerColor:ToRaylib(0.45))

		local selFrame = config._selectedFrame and frames[config._selectedFrame]
		if not selFrame then
			local hint = "Click a frame bar above to inspect zones"
			local hw = measureText(fnt, hint, fs)
			drawText(
				fnt,
				hint,
				det.x + (det.width - hw) / 2,
				det.y + det.height / 2 - fs / 2,
				fs,
				config.mutedColor:ToRaylib(0)
			)
			for _, m in pairs(config.modifiers) do
				m()
			end
			return
		end

		do
			local zones = selFrame.zones or {}
			local lanes = {}
			local zoneRows = {}

			for _, z in ipairs(zones) do
				local assigned = false
				for li, lane in ipairs(lanes) do
					if (z.start or 0) >= lane.endTime then
						table.insert(zoneRows, { zone = z, lane = li })
						lane.endTime = (z.start or 0) + (z.duration or 0)
						assigned = true
						break
					end
				end
				if not assigned then
					table.insert(lanes, { endTime = (z.start or 0) + (z.duration or 0) })
					table.insert(zoneRows, { zone = z, lane = #lanes })
				end
			end

			local laneH = 18
			local laneGap = 2
			local maxLanes = math.floor(det.height / (laneH + laneGap))
			local numLanes = math.min(#lanes, maxLanes)

			local t0 = math.huge
			for _, z in ipairs(zones) do
				if (z.start or 0) < t0 then
					t0 = z.start or 0
				end
			end

			config._tooltipZone = nil

			for _, entry in ipairs(zoneRows) do
				local z = entry.zone
				local lane = entry.lane
				if lane > maxLanes then
					break
				end

				local zStart = (z.start or t0) - t0
				local zDuration = z.duration or 0
				local zx = det.x + math.floor(zStart / detMaxMs * det.width)
				local zw = math.max(2, math.floor(zDuration / detMaxMs * det.width))
				local zy = det.y + (lane - 1) * (laneH + laneGap)

				if zy + laneH > det.y + det.height then
					break
				end

				local zCol = zoneColor(z.name or "")
				raylib.lib.DrawRectangle(zx, zy, zw, laneH, zCol:ToRaylib(0.15))
				raylib.lib.DrawRectangle(zx, zy, zw, 2, zCol:ToRaylib(0))

				if zw > 28 then
					local label = z.name or "?"
					local lw = measureText(fnt, label, fs - 1)
					if lw + 4 <= zw then
						drawText(fnt, label, zx + 3, zy + (laneH - (fs - 1)) / 2, fs - 1, config.textColor:ToRaylib(0))
					end
				end

				local zRect = rect.new(zx, zy, zw, laneH)
				if rect.MouseIsInRect(zRect) then
					config._tooltipZone = { zone = z, x = zx, y = zy }
				end
			end

			-- Worker lanes
			if selFrame.workerZones then
				local workerY = det.y + numLanes * (laneH + laneGap) + 4
				if workerY + laneH <= det.y + det.height then
					drawText(fnt, "workers", det.x, workerY - fs - 1, fs - 2, config.mutedColor:ToRaylib(0))
					for workerName, wzones in pairs(selFrame.workerZones) do
						for _, z in ipairs(wzones) do
							local zStart = (z.start or t0) - t0
							local zDuration = z.duration or 0
							local zx = det.x + math.floor(zStart / detMaxMs * det.width)
							local zw = math.max(2, math.floor(zDuration / detMaxMs * det.width))
							local zCol = zoneColor(workerName)
							raylib.lib.DrawRectangle(zx, workerY, zw, laneH, zCol:ToRaylib(0.12))
							raylib.lib.DrawRectangle(zx, workerY, zw, 2, zCol:ToRaylib(0))
							if zw > 40 then
								drawText(fnt, workerName, zx + 3, workerY + 2, fs - 1, config.textColor:ToRaylib(0))
							end
						end
						workerY = workerY + laneH + laneGap
						if workerY + laneH > det.y + det.height then
							break
						end
					end
				end
			end

			-- Counters
			local counters = selFrame.counters or {}
			local counterParts = {}
			for k, v in pairs(counters) do
				table.insert(counterParts, string.format("%s: %s", k, tostring(v)))
			end
			if #counterParts > 0 then
				local cy = det.y + det.height - fs - 1
				drawText(fnt, table.concat(counterParts, "   "), det.x, cy, fs - 1, config.mutedColor:ToRaylib(0))
			end
		end

		-- Zone tooltip
		if config._tooltipZone then
			local tip = config._tooltipZone
			local z = tip.zone
			local tipText = string.format("%s  %s", z.name or "?", fmtMs(z.duration or 0))
			local tw = measureText(fnt, tipText, fs)
			local tx = math.min(tip.x, r.x + r.width - tw - 10)
			local ty = tip.y - fs - 6
			raylib.lib.DrawRectangle(tx - 4, ty - 2, tw + 8, fs + 6, config.backgroundColor:ToRaylib(0.05))
			drawText(fnt, tipText, tx, ty, fs, config.textColor:ToRaylib(0))
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
