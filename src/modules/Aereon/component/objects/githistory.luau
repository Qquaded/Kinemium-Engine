return function(objects, data, raylib)
	local structs = raylib.structs

	local rect = require("@arect")
	local color3 = require("@Color3")
	local defaultFont = raylib.lib.GetFontDefault()

	local function drawText(fnt, text, x, y, size, color)
		raylib.lib.DrawTextEx(fnt, text, vector.create(x, y), size, 1, color)
	end

	local function measureText(fnt, text, size)
		return raylib.lib.MeasureTextEx(fnt, text, size, 1).x
	end

	local function truncateText(fnt, text, size, maxWidth)
		if measureText(fnt, text, size) <= maxWidth then
			return text
		end

		local ellipsis = "..."
		local truncated = text

		while #truncated > 0 do
			truncated = string.sub(truncated, 1, #truncated - 1)
			local candidate = truncated .. ellipsis
			if measureText(fnt, candidate, size) <= maxWidth then
				return candidate
			end
		end

		return ellipsis
	end

	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		font = data.font or defaultFont,
		fontSize = data.fontSize or 12,
		labelFontSize = data.labelFontSize or 10,

		backgroundTransparency = data.backgroundTransparency or 1,
		backgroundColor = color3.new(0.11, 0.11, 0.13),
		itemHoverColor = color3.new(1, 1, 1),
		itemHoverAlpha = 0.05,
		lineColor = color3.new(1, 1, 1),
		lineAlpha = 0.85,
		textColor = color3.new(0.88, 0.88, 0.90),
		dimTextColor = color3.new(0.52, 0.52, 0.57),
		branchColor = color3.new(0.40, 0.58, 0.95),
		tagColor = color3.new(0.62, 0.62, 0.68),
		emptyTextColor = color3.new(0.45, 0.45, 0.50),

		outlineColor = color3.new(1, 1, 1),
		outlineTransparency = 0.85, -- how transparent the outline is; lower = more visible

		commitColors = {
			default = color3.new(0.40, 0.58, 0.95), -- Blue
			merge = color3.new(0.72, 0.42, 0.88), -- Purple
			tag = color3.new(0.88, 0.68, 0.38), -- Orange
			branch = color3.new(0.40, 0.78, 0.58), -- Green
		},

		commits = data.commits or {
			{ text = "Update README...", branch = "origin/main", type = "branch", icon = "branch" },
			{ text = "Merge branch 'main'...", branch = "main", type = "merge", icon = "merge" },
			{ text = "Add Luau to the list of projec...", type = "default", icon = "commit" },
			{ text = "1.1.0.6", tag = "Qquaded", type = "tag", icon = "tag" },
			{ text = "Merge branch 'main' of https:...", type = "merge", icon = "merge" },
			{ text = "Add step to change directory...", type = "default", icon = "commit" },
			{ text = "Update JoltPhysics clone com...", type = "default", icon = "commit" },
			{ text = "Simplify CMake configuration...", type = "default", icon = "commit" },
			{ text = "Enhance artifact packaging a...", type = "default", icon = "commit" },
			{ text = "Update library names and ad...", type = "default", icon = "commit" },
			{ text = "Merge pull request #8 from...", type = "merge", icon = "merge" },
			{ text = "Add GitHub Actions workfl...", type = "default", icon = "commit" },
			{ text = "1.1.0.5", tag = "Qquaded", type = "tag", icon = "tag" },
			{ text = "1.1.0.4.6", tag = "Qquaded", type = "tag", icon = "tag" },
			{ text = "1.1.0.4.5 | Stable Backup", tag = "Qquaded", type = "tag", icon = "tag" },
			{ text = "1.1.0.4.5 | Fixed some networki...", type = "default", icon = "commit" },
		},

		-- Interaction
		hoveredIndex = -1,
		scrollOffset = 0,
		itemHeight = 30,
		padding = 14,

		onCommitClick = data.onCommitClick,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.addCommit = function(text, commitType, branch, tag)
		table.insert(config.commits, {
			text = text,
			type = commitType or "default",
			branch = branch,
			tag = tag,
			icon = commitType or "commit",
		})
		return wrapper
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local fnt = config.font
		local fs = config.fontSize
		local lfs = config.labelFontSize
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local scrollWheel = raylib.lib.GetMouseWheelMove()

		-- Background
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		-- Outline
		raylib.lib.DrawRectangleRoundedLinesEx(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.outlineThickness or 1,
			config.outlineColor:ToRaylib(config.outlineTransparency or 0)
		)

		if #config.commits == 0 then
			local msg = "No commits yet"
			local msgWidth = measureText(fnt, msg, fs)
			drawText(
				fnt,
				msg,
				r.x + (r.width - msgWidth) / 2,
				r.y + r.height / 2 - fs / 2,
				fs,
				config.emptyTextColor:ToRaylib(0)
			)
			for _, m in pairs(config.modifiers) do
				m()
			end
			return
		end

		-- Handle scrolling
		if rect.MouseIsInRect(r) then
			config.scrollOffset = config.scrollOffset - scrollWheel * config.itemHeight
		end

		local innerHeight = r.height - config.padding * 2
		local contentHeight = #config.commits * config.itemHeight
		local maxScroll = math.max(0, contentHeight - innerHeight)
		config.scrollOffset = math.clamp(config.scrollOffset, 0, maxScroll)

		local timelineX = r.x + config.padding + 8
		local contentX = timelineX + 22
		local dotRadius = 4

		local tagReserve = 84
		local contentMaxWidth = (r.x + r.width - config.padding - tagReserve) - contentX

		raylib.lib.BeginScissorMode(r.x, r.y, r.width, r.height)

		local firstY = r.y + config.padding - config.scrollOffset + config.itemHeight / 2
		local lastY = r.y
			+ config.padding
			- config.scrollOffset
			+ (#config.commits - 1) * config.itemHeight
			+ config.itemHeight / 2
		raylib.lib.DrawLineEx(
			vector.create(timelineX, math.max(firstY, r.y)),
			vector.create(timelineX, math.min(lastY, r.y + r.height)),
			2,
			config.lineColor:ToRaylib(1 - config.lineAlpha)
		)

		config.hoveredIndex = -1

		for i, commit in ipairs(config.commits) do
			local itemY = r.y + config.padding + (i - 1) * config.itemHeight - config.scrollOffset
			local midY = itemY + config.itemHeight / 2

			-- Skip if not visible
			if itemY + config.itemHeight < r.y or itemY > r.y + r.height then
				continue
			end

			local itemRect = rect.new(r.x + 4, itemY, r.width - 8, config.itemHeight)
			local isHovered = rect.MouseIsInRect(itemRect)

			if isHovered then
				config.hoveredIndex = i
				raylib.lib.DrawRectangleRounded(
					rect:translate(itemRect),
					0.25,
					4,
					config.itemHoverColor:ToRaylib(1 - config.itemHoverAlpha)
				)
			end

			-- Commit dot / icon, with a soft ring for emphasis on hover
			local dotColor = config.commitColors[commit.type] or config.commitColors.default

			if isHovered then
				raylib.lib.DrawCircle(timelineX, midY, dotRadius + 3, dotColor:ToRaylib(0.75))
			end

			if commit.type == "merge" then
				raylib.lib.DrawCircle(timelineX, midY, dotRadius + 2, dotColor:ToRaylib(0))
				raylib.lib.DrawCircle(timelineX, midY, dotRadius - 1, config.backgroundColor:ToRaylib(0))
			elseif commit.type == "tag" then
				raylib.lib.DrawRectangleRounded(
					structs.Rectangle:new({
						x = timelineX - dotRadius,
						y = midY - dotRadius,
						width = dotRadius * 2,
						height = dotRadius * 2,
					}),
					0.3,
					4,
					dotColor:ToRaylib(0)
				)
			else
				raylib.lib.DrawCircle(timelineX, midY, dotRadius, dotColor:ToRaylib(0))
			end

			-- Commit message, truncated to leave room for the tag column
			local label = truncateText(fnt, commit.text, fs, contentMaxWidth)
			local textY = midY - fs / 2
			drawText(fnt, label, contentX, textY, fs, config.textColor:ToRaylib(0))

			if commit.branch then
				local textWidth = measureText(fnt, label, fs)
				local labelPadding = 6
				local labelText = commit.branch
				local labelWidth = measureText(fnt, labelText, lfs) + labelPadding * 2
				local labelHeight = 16
				local labelX = contentX + textWidth + 10
				local labelY = midY - labelHeight / 2

				raylib.lib.DrawRectangleRounded(
					structs.Rectangle:new({
						x = labelX,
						y = labelY,
						width = labelWidth,
						height = labelHeight,
					}),
					0.5,
					4,
					config.branchColor:ToRaylib(0.75)
				)

				drawText(
					fnt,
					labelText,
					labelX + labelPadding,
					labelY + (labelHeight - lfs) / 2,
					lfs,
					color3.new(1, 1, 1):ToRaylib(0)
				)
			end

			if commit.tag then
				local tagWidth = measureText(fnt, commit.tag, lfs)
				local tagX = r.x + r.width - config.padding - tagWidth
				drawText(fnt, commit.tag, tagX, midY - lfs / 2, lfs, config.tagColor:ToRaylib(0))
			end

			if isHovered and mousePressed and config.onCommitClick then
				config.onCommitClick(commit, i)
			end
		end

		raylib.lib.EndScissorMode()

		-- Scrollbar
		if contentHeight > innerHeight then
			local scrollbarWidth = 4
			local scrollbarHeight = math.max(20, (innerHeight / contentHeight) * innerHeight)
			local scrollbarY = r.y
				+ config.padding
				+ (config.scrollOffset / maxScroll) * (innerHeight - scrollbarHeight)

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = r.x + r.width - config.padding - scrollbarWidth,
					y = scrollbarY,
					width = scrollbarWidth,
					height = scrollbarHeight,
				}),
				0.5,
				4,
				config.dimTextColor:ToRaylib(0.6)
			)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
