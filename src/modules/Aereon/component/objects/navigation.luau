local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")
local imageTextButton = require("./imageTextButton")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		-- Colors
		backgroundColor = data.backgroundColor or color3.new(0.10, 0.10, 0.11),
		itemBackgroundColor = data.itemBackgroundColor or color3.new(0.14, 0.14, 0.16),
		hoverColor = data.hoverColor or color3.new(0.18, 0.18, 0.20),
		selectedColor = data.selectedColor or color3.new(0.12, 0.35, 0.25),
		iconColor = data.iconColor or color3.new(0.65, 0.65, 0.68),
		selectedIconColor = data.selectedIconColor or color3.new(0.35, 0.85, 0.55),
		textColor = data.textColor or color3.new(0.85, 0.85, 0.87),
		dividerColor = data.dividerColor or color3.new(0.20, 0.20, 0.22),
		categoryColor = data.categoryColor or color3.new(0.55, 0.55, 0.57),

		-- Navigation items
		items = data.items,
		buttonInstances = {},

		-- Layout
		collapsedWidth = 72,
		expandedWidth = 240,
		currentWidth = 60,
		targetWidth = 60,
		itemSize = 48,
		iconSize = 24,
		padding = 8,
		spacing = 8,
		scrollStep = 20,
		dividerHeight = 1,
		expandSpeed = 12,
		font = data.font or raylib.lib.GetFontDefault(),

		-- Indicator bar
		indicatorY = 0,
		indicatorTargetY = 0,
		indicatorHeight = 0,

		-- Interaction
		hoveredIndex = -1,
		selectedIndex = -1,
		scrollOffset = 0,
		scrollTarget = 0,
		isExpanded = false,
		textAlpha = 0,

		onItemClick = data.onItemClick,
	}

	local wrapper = {}

	wrapper.config = config

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setSelected = function(index)
		for i, item in ipairs(config.items) do
			item.selected = (i == index)
			if config.buttonInstances[i] then
				config.buttonInstances[i].set(
					"backgroundColor",
					i == index and config.selectedColor or config.itemBackgroundColor
				)
				config.buttonInstances[i].set("textTransparency", 1 - config.textAlpha)
			end
		end
		config.selectedIndex = index
		return wrapper
	end

	wrapper.addItem = function(icon, itemType, label, texture)
		local index = #config.items + 1
		table.insert(config.items, {
			icon = icon,
			type = itemType or "icon",
			label = label,
			texture = texture,
			selected = false,
		})

		if itemType ~= "divider" and itemType ~= "spacer" and itemType ~= "category" then
			config.buttonInstances[index] = imageTextButton({}, {
				x = 0,
				y = 0,
				width = config.itemSize,
				height = config.itemSize,
				text = label or "",
				icon = texture,
				font = config.font,
				fontSize = 14,
				iconPosition = "left",
				gap = 8,
				iconPadding = 12,
				backgroundColor = config.itemBackgroundColor,
				hoverColor = config.hoverColor,
				pressColor = config.selectedColor,
				textColor = config.textColor,
				rounded = { 0.15, 8 },
				onClick = function()
					wrapper.setSelected(index)
					if config.onItemClick then
						config.onItemClick(config.items[index], index)
					end
				end,
			})
		end

		return wrapper
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local scrollWheel = raylib.lib.GetMouseWheelMove()

		-- Check if mouse is hovering over the navigation
		local navRect = rect.new(r.x, r.y, config.currentWidth, r.height)
		local isHovering = rect.MouseIsInRect(navRect)

		-- Update expansion state
		if isHovering then
			config.targetWidth = config.expandedWidth
			config.isExpanded = true
		else
			config.targetWidth = config.collapsedWidth
			config.isExpanded = false
		end

		-- Animate width
		local widthDiff = config.targetWidth - config.currentWidth
		config.currentWidth = config.currentWidth + widthDiff * config.expandSpeed * dt

		-- Animate text alpha
		if config.isExpanded then
			config.textAlpha = math.min(1, config.textAlpha + 5 * dt)
		else
			config.textAlpha = math.max(0, config.textAlpha - 5 * dt)
		end

		-- Background
		raylib.lib.DrawRectangle(r.x, r.y, config.currentWidth, r.height, config.backgroundColor:ToRaylib(0))

		-- Handle scrolling
		if isHovering then
			config.scrollTarget = config.scrollTarget - scrollWheel * config.scrollStep
		end
		config.scrollOffset = config.scrollOffset
			+ (config.scrollTarget - config.scrollOffset) * (math.min(1, dt * 10) ^ 0.5)

		config.hoveredIndex = -1
		local currentY = r.y + config.padding - config.scrollOffset

		raylib.lib.BeginScissorMode(r.x, r.y, config.currentWidth, r.height)

		local collapseOffset = config.isExpanded and 0 or (config.currentWidth - config.collapsedWidth) / 2
		for i, item in ipairs(config.items) do
			if item.type == "divider" then
				-- Draw divider
				raylib.lib.DrawRectangle(
					r.x + config.padding * 2,
					currentY + config.spacing,
					config.currentWidth - config.padding * 4,
					config.dividerHeight,
					config.dividerColor:ToRaylib(0)
				)
				currentY = currentY + config.spacing * 2 + config.dividerHeight
			elseif item.type == "spacer" then
				local usedSpace = currentY - r.y
				local totalItemHeight = 0

				for j = i + 1, #config.items do
					if config.items[j].type ~= "spacer" then
						totalItemHeight = totalItemHeight + config.itemSize + config.spacing
					end
				end

				local remainingSpace = r.height - usedSpace - totalItemHeight - config.padding
				currentY = currentY + math.max(0, remainingSpace)
			elseif item.type == "category" then
				-- Draw category title (only visible when expanded)
				if config.textAlpha > 0.1 then
					local categoryText = item.label or "CATEGORY"
					raylib.lib.DrawTextEx(
						config.font,
						categoryText,
						vector.create(r.x + config.padding * 2, currentY + 4),
						10,
						1,
						config.categoryColor:ToRaylib(1 - config.textAlpha)
					)
				end
				currentY = currentY + 20
			else
				-- Regular item - use ImageTextButton
				local itemX = config.isExpanded and r.x + config.padding * 1.5
					or r.x + (config.currentWidth - config.itemSize) / 2 - collapseOffset
				local itemRenderWidth = config.isExpanded and (config.currentWidth - config.padding * 3)
					or config.itemSize + collapseOffset * 2

				local buttonInstance = config.buttonInstances[i]
				if buttonInstance then
					buttonInstance.set("obj_rect", rect.new(itemX, currentY, itemRenderWidth, config.itemSize))
					buttonInstance.set("text", config.isExpanded and (item.label or "") or "")
					buttonInstance.set("icon", item.texture)
					buttonInstance.set("textTransparency", 1 - config.textAlpha)
					buttonInstance.render(dt)
				end

				currentY = currentY + config.itemSize + config.spacing
			end
		end

		raylib.lib.EndScissorMode()

		local contentHeight = currentY - r.y + config.padding
		if contentHeight > r.height then
			local maxScroll = contentHeight - r.height
			config.scrollOffset = math.clamp(config.scrollOffset, 0, maxScroll)

			local scrollbarWidth = 3
			local scrollbarHeight = (r.height / contentHeight) * r.height
			local scrollbarY = r.y + (config.scrollOffset / maxScroll) * (r.height - scrollbarHeight)

			raylib.lib.DrawRectangle(
				r.x + config.currentWidth - scrollbarWidth - 2,
				scrollbarY,
				scrollbarWidth,
				scrollbarHeight,
				config.iconColor:ToRaylib(0.3)
			)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
