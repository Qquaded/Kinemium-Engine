local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local config = {
		profiler = data.profiler,
		font = data.font or defaultFont,

		-- Colors
		backgroundColor = color3.new(0.09, 0.09, 0.11),
		panelColor = color3.new(0.12, 0.12, 0.14),
		headerColor = color3.new(0.15, 0.15, 0.17),
		gridColor = color3.new(0.2, 0.2, 0.22),
		textColor = color3.new(0.86, 0.86, 0.86),
		dimTextColor = color3.new(0.5, 0.5, 0.5),

		zoneColors = {
			color3.new(0.95, 0.35, 0.24), -- Red-orange
			color3.new(0.98, 0.68, 0.24), -- Orange
			color3.new(0.36, 0.78, 0.35), -- Green
			color3.new(0.25, 0.65, 0.95), -- Blue
			color3.new(0.58, 0.32, 0.95), -- Purple
			color3.new(0.95, 0.45, 0.75), -- Pink
			color3.new(0.32, 0.85, 0.82), -- Cyan
			color3.new(0.95, 0.82, 0.24), -- Yellow
		},
		zoneColorMap = {},

		-- Flame graph view
		flameGraphViewStart = 0,
		flameGraphZoom = 1.0,
		flameGraphScroll = 0,

		-- Interaction
		hoveredFrame = nil,
		selectedFrame = nil,
		isDragging = false,
		dragStartX = 0,
		dragStartScroll = 0,

		-- Layout
		topBarHeight = 40,
		flameGraphRowHeight = 24,
		minFrameWidth = 3,
		sidebarWidth = 300,

		-- Settings
		targetFrameTime = 1 / 60,
		showGrid = false,
		showStats = true,
		showTooltip = true,
		maxDepth = 20,

		modifiers = {},
	}

	local function getZoneColor(zoneName)
		if not config.zoneColorMap[zoneName] then
			local idx = (#config.zoneColorMap % #config.zoneColors) + 1
			config.zoneColorMap[zoneName] = config.zoneColors[idx]
		end
		return config.zoneColorMap[zoneName]
	end

	local function hash(str)
		local h = 0
		for i = 1, #str do
			h = (h * 31 + string.byte(str, i)) % 2147483647
		end
		return h
	end

	local function getConsistentZoneColor(zoneName)
		local h = hash(zoneName)
		local idx = (h % #config.zoneColors) + 1
		return config.zoneColors[idx]
	end

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	-- Draw text with custom font support
	local function drawText(text, x, y, fontSize, color)
		if config.font and config.font ~= defaultFont then
			raylib.lib.DrawTextEx(config.font, text, vector.create(x, y), fontSize, 1, color)
		else
			raylib.lib.DrawText(text, x, y, fontSize, color)
		end
	end

	-- Measure text width
	local function measureText(text, fontSize)
		if config.font and config.font ~= defaultFont then
			return raylib.lib.MeasureTextEx(config.font, text, fontSize, 1).x
		else
			return raylib.lib.MeasureText(text, fontSize)
		end
	end

	-- Build flame graph data from profiler frames
	local function buildFlameGraphData(frames)
		if not frames or #frames == 0 then
			return {}
		end

		-- Use the latest frame for flame graph
		local latestFrame = frames[#frames]
		if not latestFrame then
			return {}
		end

		-- Build hierarchical data from zones
		local flameData = {}
		local maxDepth = 0

		-- Process main thread zones (they have parent-child relationships)
		if latestFrame.zones then
			-- Group zones by their call stack
			local stackMap = {}

			for _, zone in ipairs(latestFrame.zones) do
				local stack = zone.callStack or { zone.name }
				local key = table.concat(stack, ";")

				if not stackMap[key] then
					stackMap[key] = {
						stack = stack,
						name = zone.name,
						duration = 0,
						selfDuration = 0,
						count = 0,
					}
				end

				stackMap[key].duration = stackMap[key].duration + (zone.duration or 0)
				stackMap[key].count = stackMap[key].count + 1

				if #stack > maxDepth then
					maxDepth = #stack
				end
			end

			-- Convert to flame graph format
			for key, data in pairs(stackMap) do
				table.insert(flameData, {
					stack = data.stack,
					name = data.name,
					duration = data.duration,
					selfDuration = data.duration, -- Simplified for now
					count = data.count,
				})
			end
		end

		-- Sort by duration (longest first)
		table.sort(flameData, function(a, b)
			return a.duration > b.duration
		end)

		return flameData, maxDepth
	end

	wrapper.render = function(dt)
		if not config.profiler then
			return
		end

		local screenWidth = raylib.lib.GetScreenWidth()
		local screenHeight = raylib.lib.GetScreenHeight()
		local mousePos = raylib.lib.GetMousePosition()
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local mouseReleased = raylib.lib.IsMouseButtonReleased(0) == 1
		local mouseWheel = raylib.lib.GetMouseWheelMove()

		local frames = config.profiler:GetFrames()
		local latestFrame = config.profiler:GetLatestFrame()

		if not frames or #frames == 0 then
			-- Draw empty state
			raylib.lib.ClearBackground(config.backgroundColor:ToRaylib(0))

			local emptyText = "No profiler data available"
			local textWidth = measureText(emptyText, 18)
			drawText(emptyText, (screenWidth - textWidth) / 2, screenHeight / 2, 18, config.dimTextColor:ToRaylib(0))
			return
		end

		-- Background
		raylib.lib.ClearBackground(config.backgroundColor:ToRaylib(0))

		local padding = 12
		local topBarY = 0
		local flameGraphY = topBarY + config.topBarHeight

		-- Calculate flame graph height based on depth
		local flameData, maxDepth = buildFlameGraphData(frames)
		local flameGraphHeight =
			math.min(maxDepth * config.flameGraphRowHeight + 20, screenHeight - config.topBarHeight - 60)

		local mainWidth = screenWidth - config.sidebarWidth - padding * 2

		-- === TOP BAR ===
		raylib.lib.DrawRectangle(0, topBarY, screenWidth, config.topBarHeight, config.headerColor:ToRaylib(0))

		-- FPS and frame time
		local fps = 0
		local frameTime = 0
		if latestFrame then
			local totalTime = 0
			if latestFrame.zones then
				for _, zone in ipairs(latestFrame.zones) do
					totalTime = totalTime + (zone.duration or 0)
				end
			end
			frameTime = totalTime
			fps = totalTime > 0 and (1 / totalTime) or 0
		end

		-- Title
		drawText("Flame Graph Profiler", padding, topBarY + 10, 16, config.textColor:ToRaylib(0))

		-- Stats
		local fpsColor = fps >= 55 and color3.new(0.3, 0.9, 0.3)
			or (fps >= 30 and color3.new(0.9, 0.7, 0.2) or color3.new(0.9, 0.3, 0.3))
		drawText(string.format("%.1f FPS", fps), screenWidth - 220, topBarY + 8, 14, fpsColor:ToRaylib(0))
		drawText(
			string.format("%.2fms", frameTime * 1000),
			screenWidth - 100,
			topBarY + 8,
			14,
			config.textColor:ToRaylib(0)
		)

		-- === FLAME GRAPH ===
		local flameGraphRect = rect.new(padding, flameGraphY, mainWidth, flameGraphHeight)
		raylib.lib.DrawRectangleRounded(rect:translate(flameGraphRect), 0.08, 8, config.panelColor:ToRaylib(0))

		-- Handle interaction
		if rect.MouseIsInRect(flameGraphRect) then
			if mouseWheel ~= 0 then
				local oldZoom = config.flameGraphZoom
				config.flameGraphZoom = math.max(0.5, math.min(10, config.flameGraphZoom + mouseWheel * 0.1))
			end

			if mousePressed then
				config.isDragging = true
				config.dragStartX = mousePos.x
				config.flameGraphScroll = config.flameGraphScroll
			end
		end

		if mouseReleased then
			config.isDragging = false
		end

		if config.isDragging then
			local dragDelta = mousePos.x - config.dragStartX
			config.flameGraphScroll = config.dragStartScroll - dragDelta * 0.5
		end

		-- Total time for scaling
		local totalTime = 0
		for _, data in ipairs(flameData) do
			totalTime = totalTime + data.duration
		end
		totalTime = math.max(totalTime, config.targetFrameTime)

		-- Draw flame graph bars
		config.hoveredFrame = nil

		-- Sort flame data by stack for proper stacking
		local sortedFlameData = {}
		for _, data in ipairs(flameData) do
			table.insert(sortedFlameData, data)
		end

		-- Group by top-level function
		local topLevelGroups = {}
		for _, data in ipairs(sortedFlameData) do
			local topFunc = data.stack[1] or data.name
			if not topLevelGroups[topFunc] then
				topLevelGroups[topFunc] = {
					name = topFunc,
					stack = data.stack,
					children = {},
					totalDuration = 0,
				}
			end
			topLevelGroups[topFunc].totalDuration = topLevelGroups[topFunc].totalDuration + data.duration
			table.insert(topLevelGroups[topFunc].children, data)
		end

		-- Sort groups by total duration
		local sortedGroups = {}
		for _, group in pairs(topLevelGroups) do
			table.insert(sortedGroups, group)
		end
		table.sort(sortedGroups, function(a, b)
			return a.totalDuration > b.totalDuration
		end)

		-- Draw the flame graph
		local currentX = flameGraphRect.x
		local barHeight = config.flameGraphRowHeight - 2

		for groupIdx, group in ipairs(sortedGroups) do
			if currentX > flameGraphRect.x + flameGraphRect.width then
				break
			end

			local groupWidth = (group.totalDuration / totalTime) * flameGraphRect.width * config.flameGraphZoom

			if groupWidth >= config.minFrameWidth then
				local baseColor = getConsistentZoneColor(group.name)

				-- Draw base bar (the function)
				local barY = flameGraphRect.y

				-- Draw the bar with gradient effect based on depth
				local depth = #group.stack
				local colorMultiplier = 1.0 - (depth * 0.08)
				local barColor = color3.new(
					baseColor.R * colorMultiplier,
					baseColor.G * colorMultiplier,
					baseColor.B * colorMultiplier
				)

				raylib.lib.DrawRectangleRounded(
					currentX,
					barY + 2,
					groupWidth - 1,
					barHeight,
					0.04,
					4,
					barColor:ToRaylib(0)
				)

				-- Draw function name if bar is wide enough
				if groupWidth > 40 then
					local textY = barY + (barHeight - 11) / 2 + 2
					local displayName = group.name
					if #displayName > math.floor(groupWidth / 7) then
						displayName = string.sub(displayName, 1, math.floor(groupWidth / 7) - 2) .. ".."
					end
					drawText(displayName, currentX + 4, textY, 11, color3.new(1, 1, 1):ToRaylib(0))
				end

				-- Check hover
				if
					mousePos.x >= currentX
					and mousePos.x <= currentX + groupWidth
					and mousePos.y >= barY
					and mousePos.y <= barY + barHeight + 4
				then
					config.hoveredFrame = group

					-- Highlight
					raylib.lib.DrawRectangleRounded(
						currentX,
						barY + 2,
						groupWidth - 1,
						barHeight,
						0.04,
						4,
						color3.new(1, 1, 1):ToRaylib(0.7)
					)
				end

				-- Draw child bars (stacked above)
				local childX = currentX
				for _, child in ipairs(group.children) do
					if childX > currentX + groupWidth then
						break
					end

					local childWidth = (child.duration / totalTime) * flameGraphRect.width * config.flameGraphZoom
					if childWidth >= config.minFrameWidth and #child.stack > 1 then
						local childDepth = math.min(#child.stack - 1, config.maxDepth - 1)
						local childY = barY - childDepth * (barHeight - 2)

						local childColor = getConsistentZoneColor(child.name)
						local childColorMult = 1.0 - (childDepth * 0.06)
						childColor = color3.new(
							childColor.R * childColorMult,
							childColor.G * childColorMult,
							childColor.B * childColorMult
						)

						raylib.lib.DrawRectangleRounded(
							childX,
							childY + 2,
							childWidth - 1,
							barHeight - 2,
							0.03,
							3,
							childColor:ToRaylib(0)
						)

						-- Draw child name if wide enough
						if childWidth > 30 and childY > flameGraphRect.y then
							local childTextY = childY + (barHeight - 9) / 2 + 2
							local childName = child.name
							if #childName > math.floor(childWidth / 6) then
								childName = string.sub(childName, 1, math.floor(childWidth / 6) - 2) .. ".."
							end
							drawText(childName, childX + 2, childTextY, 9, color3.new(1, 1, 1):ToRaylib(0))
						end
					end

					childX = childX + childWidth
				end

				currentX = currentX + groupWidth
			end
		end

		-- === TIME SCALE ===
		local scaleY = flameGraphRect.y + flameGraphRect.height + 5

		-- Draw time markers
		local numMarkers = 5
		for i = 0, numMarkers do
			local x = flameGraphRect.x + (i / numMarkers) * flameGraphRect.width
			local time = (i / numMarkers) * totalTime * 1000

			raylib.lib.DrawLine(x, scaleY, x, scaleY + 5, config.gridColor:ToRaylib(0))
			drawText(string.format("%.1fms", time), x + 2, scaleY + 6, 9, config.dimTextColor:ToRaylib(0))
		end

		-- === SIDEBAR - CALL STACK DETAILS ===
		local sidebarX = mainWidth + padding * 2

		-- Sidebar background
		raylib.lib.DrawRectangleRounded(
			sidebarX,
			topBarY,
			config.sidebarWidth,
			screenHeight - topBarY,
			0,
			0,
			config.headerColor:ToRaylib(0)
		)

		local sideY = topBarY + padding + 10

		-- Title
		drawText("Call Stack", sidebarX + padding, sideY, 15, config.textColor:ToRaylib(0))
		sideY = sideY + 30

		-- Draw selected or hovered frame details
		local displayFrame = config.hoveredFrame or config.selectedFrame

		if displayFrame then
			-- Function name
			drawText(displayFrame.name, sidebarX + padding, sideY, 14, config.textColor:ToRaylib(0))
			sideY = sideY + 22

			-- Duration
			local durationText =
				string.format("Total: %.2fms", (displayFrame.totalDuration or displayFrame.duration or 0) * 1000)
			drawText(durationText, sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
			sideY = sideY + 18

			-- Call count
			local countText = string.format("Calls: %d", displayFrame.count or 1)
			drawText(countText, sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
			sideY = sideY + 25

			-- Self duration
			local selfText = string.format("Self: %.2fms", (displayFrame.selfDuration or 0) * 1000)
			drawText(selfText, sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
			sideY = sideY + 25

			-- Percentage
			local pctText = string.format("%.1f%% of frame", ((displayFrame.duration or 0) / frameTime * 100))
			drawText(pctText, sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
			sideY = sideY + 30

			-- Call stack (if available)
			if displayFrame.stack and #displayFrame.stack > 1 then
				drawText("Stack:", sidebarX + padding, sideY, 12, config.textColor:ToRaylib(0))
				sideY = sideY + 18

				for i = #displayFrame.stack, 1, -1 do
					if sideY > screenHeight - 40 then
						break
					end

					local depth = #displayFrame.stack - i
					local indent = depth * 12

					local stackColor = getConsistentZoneColor(displayFrame.stack[i])
					drawText(displayFrame.stack[i], sidebarX + padding + indent, sideY, 11, stackColor:ToRaylib(0))
					sideY = sideY + 16
				end
			end
		else
			-- Show summary when nothing selected
			drawText("Hover over a function", sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
			sideY = sideY + 20
			drawText("to see details", sidebarX + padding, sideY, 12, config.dimTextColor:ToRaylib(0))
		end

		-- === TOP FUNCTIONS LIST ===
		sideY = sideY + 30
		drawText("Top Functions", sidebarX + padding, sideY, 14, config.textColor:ToRaylib(0))
		sideY = sideY + 22

		for i = 1, math.min(8, #sortedGroups) do
			local func = sortedGroups[i]
			if sideY > screenHeight - 50 then
				break
			end

			local funcColor = getConsistentZoneColor(func.name)

			-- Color indicator
			raylib.lib.DrawRectangle(sidebarX + padding, sideY + 2, 4, 14, funcColor:ToRaylib(0))

			-- Function name
			local displayName = func.name
			if #displayName > 25 then
				displayName = string.sub(displayName, 1, 22) .. "..."
			end
			drawText(displayName, sidebarX + padding + 10, sideY, 11, config.textColor:ToRaylib(0))

			-- Duration
			local durText = string.format("%.1fms", func.totalDuration * 1000)
			drawText(durText, sidebarX + padding + 180, sideY, 10, config.dimTextColor:ToRaylib(0))

			sideY = sideY + 18
		end

		-- === TOOLTIP ===
		if config.showTooltip and config.hoveredFrame then
			local frame = config.hoveredFrame
			local tooltipWidth = 220
			local tooltipHeight = 85
			local tooltipX = math.min(mousePos.x + 15, screenWidth - tooltipWidth - 10)
			local tooltipY = math.min(mousePos.y + 15, screenHeight - tooltipHeight - 10)

			-- Tooltip background
			raylib.lib.DrawRectangleRounded(
				tooltipX,
				tooltipY,
				tooltipWidth,
				tooltipHeight,
				0.08,
				6,
				color3.new(0.12, 0.12, 0.14):ToRaylib(0)
			)
			raylib.lib.DrawRectangleRoundedLines(
				tooltipX,
				tooltipY,
				tooltipWidth,
				tooltipHeight,
				0.08,
				6,
				1,
				color3.new(0.4, 0.4, 0.4):ToRaylib(0)
			)

			-- Tooltip content
			local ty = tooltipY + 10
			drawText(frame.name, tooltipX + 10, ty, 12, config.textColor:ToRaylib(0))
			ty = ty + 18

			drawText(
				string.format("Total: %.2fms", (frame.totalDuration or frame.duration or 0) * 1000),
				tooltipX + 10,
				ty,
				11,
				config.dimTextColor:ToRaylib(0)
			)
			ty = ty + 16

			drawText(
				string.format("Calls: %d", frame.count or 1),
				tooltipX + 10,
				ty,
				11,
				config.dimTextColor:ToRaylib(0)
			)
			ty = ty + 16

			if frame.stack and #frame.stack > 1 then
				drawText(
					"Stack depth: " .. tostring(#frame.stack),
					tooltipX + 10,
					ty,
					10,
					config.dimTextColor:ToRaylib(0)
				)
			end
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
