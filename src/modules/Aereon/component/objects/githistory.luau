local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		backgroundColor = color3.new(0.11, 0.11, 0.13),
		itemHoverColor = color3.new(0.16, 0.16, 0.18),
		textColor = color3.new(0.85, 0.85, 0.87),
		dimTextColor = color3.new(0.55, 0.55, 0.60),
		branchColor = color3.new(0.35, 0.55, 0.95),
		tagColor = color3.new(0.60, 0.60, 0.65),

		commitColors = {
			default = color3.new(0.35, 0.55, 0.95), -- Blue
			merge = color3.new(0.70, 0.35, 0.85), -- Purple
			tag = color3.new(0.85, 0.65, 0.35), -- Orange
			branch = color3.new(0.35, 0.75, 0.55), -- Green
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
		itemHeight = 28,
		padding = 12,

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
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local scrollWheel = raylib.lib.GetMouseWheelMove()

		-- Background
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		-- Handle scrolling
		if rect.MouseIsInRect(r) then
			config.scrollOffset = config.scrollOffset - scrollWheel * config.itemHeight
		end

		local maxScroll = math.max(0, (#config.commits * config.itemHeight) - (r.height - config.padding * 2))
		config.scrollOffset = math.clamp(config.scrollOffset, 0, maxScroll)

		-- Draw commits
		config.hoveredIndex = -1
		local timelineX = r.x + config.padding + 8
		local contentX = timelineX + 20

		raylib.lib.BeginScissorMode(r.x, r.y, r.width, r.height)

		for i, commit in ipairs(config.commits) do
			local itemY = r.y + config.padding + (i - 1) * config.itemHeight - config.scrollOffset

			-- Skip if not visible
			if itemY + config.itemHeight < r.y or itemY > r.y + r.height then
				continue
			end

			local itemRect = rect.new(r.x, itemY, r.width, config.itemHeight)
			local isHovered = rect.MouseIsInRect(itemRect)

			if isHovered then
				config.hoveredIndex = i
				raylib.lib.DrawRectangle(
					itemRect.x,
					itemRect.y,
					itemRect.width,
					itemRect.height,
					config.itemHoverColor:ToRaylib(0)
				)
			end

			-- Draw timeline line
			if i < #config.commits then
				local lineColor = config.dimTextColor
				raylib.lib.DrawLineEx(
					vector.create(timelineX, itemY + 12),
					vector.create(timelineX, itemY + config.itemHeight + 12),
					2,
					lineColor:ToRaylib(0)
				)
			end

			-- Draw commit dot/icon
			local dotColor = config.commitColors[commit.type] or config.commitColors.default
			local dotSize = 8

			if commit.type == "merge" then
				raylib.lib.DrawCircle(timelineX, itemY + 12, dotSize / 2 + 2, dotColor:ToRaylib(0))
			elseif commit.type == "tag" then
				raylib.lib.DrawRectangle(
					timelineX - dotSize / 2,
					itemY + 12 - dotSize / 2,
					dotSize,
					dotSize,
					dotColor:ToRaylib(0)
				)
			else
				-- Circle for normal commit
				raylib.lib.DrawCircle(timelineX, itemY + 12, dotSize / 2, dotColor:ToRaylib(0))
			end

			raylib.lib.DrawText(commit.text, contentX, itemY + 6, 12, config.textColor:ToRaylib(0))

			if commit.branch then
				local textWidth = raylib.lib.MeasureText(commit.text, 12)
				local labelX = contentX + textWidth + 8
				local labelPadding = 4

				local labelText = commit.branch
				local labelWidth = raylib.lib.MeasureText(labelText, 10) + labelPadding * 2
				local labelHeight = 16

				raylib.lib.DrawRectangleRounded(
					structs.Rectangle:new({
						x = labelX,
						y = itemY + 5,
						width = labelWidth,
						height = labelHeight,
					}),
					0.5,
					4,
					config.branchColor:ToRaylib(0.7)
				)

				raylib.lib.DrawText(labelText, labelX + labelPadding, itemY + 7, 10, color3.new(1, 1, 1):ToRaylib(0))
			end

			if commit.tag then
				local tagX = r.x + r.width - config.padding - 80
				raylib.lib.DrawText(commit.tag, tagX, itemY + 6, 11, config.tagColor:ToRaylib(0))
			end

			if isHovered and mousePressed and config.onCommitClick then
				config.onCommitClick(commit, i)
			end
		end

		raylib.lib.EndScissorMode()

		if #config.commits * config.itemHeight > r.height - config.padding * 2 then
			local scrollbarWidth = 4
			local scrollbarHeight = ((r.height - config.padding * 2) / (#config.commits * config.itemHeight))
				* (r.height - config.padding * 2)
			local scrollbarY = r.y
				+ config.padding
				+ (config.scrollOffset / maxScroll) * (r.height - config.padding * 2 - scrollbarHeight)

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = r.x + r.width - config.padding - scrollbarWidth,
					y = scrollbarY,
					width = scrollbarWidth,
					height = scrollbarHeight,
				}),
				0.5,
				4,
				config.dimTextColor:ToRaylib(0.5)
			)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
