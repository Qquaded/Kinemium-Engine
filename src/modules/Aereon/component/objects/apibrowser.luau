local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")
local aereon = require("@Aereon")
local MDXFormatter = require("../mdxFormatter")
local structs = raylib.structs

return function(objects, data)
	local gui = aereon.gui
	local wrapper = {}
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.06, 12 },
		modifiers = {},

		backgroundColor = color3.new(0.055, 0.060, 0.068), -- near-black blue-gray base
		panelColor = color3.new(0.080, 0.086, 0.096), -- slightly lifted surface
		headerColor = color3.new(0.062, 0.067, 0.076), -- header sits between bg and panel
		itemColor = color3.new(0.100, 0.108, 0.120),
		hoverColor = color3.new(0.130, 0.140, 0.158), -- more visible hover
		selectedColor = color3.new(0.14, 0.30, 0.52), -- deep sapphire selection
		selectedGlow = color3.new(0.22, 0.46, 0.80), -- lighter edge for selected items
		textColor = color3.new(0.94, 0.95, 0.97), -- near-white primary text
		subtextColor = color3.new(0.50, 0.53, 0.58), -- muted secondary text
		accentColor = color3.new(0.28, 0.62, 1.00), -- vivid azure accent
		accentDim = color3.new(0.14, 0.35, 0.64), -- dimmed accent for badges
		dividerColor = color3.new(0.12, 0.13, 0.15), -- very subtle dividers
		scrollbarColor = color3.new(0.22, 0.24, 0.28),
		scrollbarHoverColor = color3.new(0.34, 0.38, 0.44),
		borderColor = color3.new(0.16, 0.17, 0.20), -- panel border
		shadowColor = color3.new(0, 0, 0),

		-- Tag badge colors per type
		classBadgeColor = color3.new(0.13, 0.32, 0.56),
		enumBadgeColor = color3.new(0.38, 0.22, 0.56),
		typeBadgeColor = color3.new(0.14, 0.42, 0.30),
		classBadgeText = color3.new(0.48, 0.78, 1.00),
		enumBadgeText = color3.new(0.78, 0.58, 1.00),
		typeBadgeText = color3.new(0.42, 0.88, 0.64),

		-- Layout
		headerHeight = 52,
		itemHeight = 32,
		padding = 16,
		spacing = 5,
		indentSize = 20,
		iconSize = 13,
		searchHeight = 38,

		-- Panel widths
		leftPanelWidth = 340,
		middlePanelWidth = 320,

		-- Font
		font = data.font,
		game = data.game or game,
		fontSize = data.fontSize or 13,
		fontSpacing = 0.4,
		headerFontSize = 15,
		headerFontSpacing = 0.6,
		labelFontSize = 11,
		labelFontSpacing = 0.5,
		mdxComponents = data.mdxComponents or data.documentationComponents or {},
		mdxStyles = data.mdxStyles or data.documentationStyles or {},
		mdxTheme = data.mdxTheme or data.documentationTheme or {},

		-- Data structure
		categories = data.categories or {
			{
				name = "Classes",
				count = 858,
				expanded = true,
				items = {
					{
						name = "Object",
						type = "class",
						expanded = false,
						children = {
							{ name = "AnimationNode", type = "class" },
							{
								name = "Capture",
								type = "class",
								expanded = false,
								children = {
									{ name = "ScreenshotCapture", type = "class" },
									{ name = "VideoCapture", type = "class" },
								},
							},
							{ name = "ConfigSnapshot", type = "class" },
						},
					},
					{
						name = "Instance",
						type = "class",
						expanded = false,
						children = {
							{ name = "Accessory", type = "class" },
							{ name = "Animation", type = "class" },
						},
					},
				},
			},
			{
				name = "Enums",
				count = 545,
				expanded = false,
				items = {
					{ name = "AccessModifierType", type = "enum" },
					{ name = "AccessoryType", type = "enum" },
					{ name = "ActionType", type = "enum" },
				},
			},
			{
				name = "Types",
				count = 69,
				expanded = false,
				items = {
					{ name = "DataType", type = "type" },
					{ name = "BinaryString", type = "type" },
					{ name = "Color3", type = "type" },
				},
			},
		},

		middleItems = {},
		middleSearch = "",
		_searchBox = nil,

		selectedItem = nil,

		selectedCategoryIndex = 1,
		hoveredItem = nil,
		searchFocused = false,

		hoverStates = {},
		expandAnimations = {},

		onItemSelect = data.onItemSelect,

		leftContentHeight = 0,
		middleContentHeight = 0,
		rightContentHeight = 0,
	}

	-- Derive per-type badge colors
	local function getBadgeColors(itemType)
		if itemType == "class" then
			return config.classBadgeColor, config.classBadgeText
		elseif itemType == "enum" then
			return config.enumBadgeColor, config.enumBadgeText
		else
			return config.typeBadgeColor, config.typeBadgeText
		end
	end

	--  Drawing helpers

	local function drawText(text, x, y, size, spacing, color)
		raylib.lib.DrawTextEx(
			config.font or raylib.lib.GetFontDefault(),
			text,
			vector.create(x, y),
			size,
			spacing,
			color:ToRaylib(0)
		)
	end

	local function measureText(text, size, spacing)
		local m = raylib.lib.MeasureTextEx(config.font or raylib.lib.GetFontDefault(), text, size, spacing)
		return m.x
	end

	local function truncateText(text, maxWidth, size, spacing)
		local w = measureText(text, size, spacing)
		if w <= maxWidth then
			return text
		end
		local ellipsis = "..."
		local ew = measureText(ellipsis, size, spacing)
		for i = #text, 1, -1 do
			local sub = string.sub(text, 1, i)
			if measureText(sub, size, spacing) + ew <= maxWidth then
				return sub .. ellipsis
			end
		end
		return ellipsis
	end

	local function wrapText(text, maxWidth, size, spacing)
		local lines = {}
		local words = {}
		for word in string.gmatch(text, "%S+") do
			table.insert(words, word)
		end

		local function addParagraph(paragraphText)
			local wordsInPara = {}
			for word in string.gmatch(paragraphText, "%S+") do
				table.insert(wordsInPara, word)
			end

			local currentLine = ""
			local function addWrappedLine(l)
				table.insert(lines, l)
			end

			for _, word in ipairs(wordsInPara) do
				local testLine = currentLine == "" and word or (currentLine .. " " .. word)
				if measureText(testLine, size, spacing) <= maxWidth then
					currentLine = testLine
				else
					if currentLine ~= "" then
						addWrappedLine(currentLine)
					end
					currentLine = word
				end
			end
			if currentLine ~= "" then
				addWrappedLine(currentLine)
			end
		end

		-- Handle explicit newlines
		for part in string.gmatch(text .. "\n", "([^\n]*)\n") do
			if part == "" then
				table.insert(lines, "") -- empty line for spacing
			else
				addParagraph(part)
			end
		end

		return lines
	end

	local function drawWrappedLines(lines, x, y, size, spacing, color, lineHeight)
		for i, line in ipairs(lines) do
			if line ~= "" then
				drawText(line, x, y + (i - 1) * lineHeight, size, spacing, color)
			end
		end
	end

	local function createDocumentRenderer()
		local theme = {
			textColor = config.textColor,
			mutedTextColor = config.subtextColor,
			headingColor = config.textColor,
			accentColor = config.accentColor,
			panelColor = config.panelColor,
			headerColor = config.headerColor,
			borderColor = config.dividerColor,
			codeColor = config.accentColor,
		}
		for key, value in pairs(config.mdxTheme) do
			theme[key] = value
		end

		return MDXFormatter.createRenderer({
			font = config.font,
			components = config.mdxComponents,
			styles = config.mdxStyles,
			theme = theme,
		})
	end

	local documentRenderer = createDocumentRenderer()

	local function getHoverState(key, dt, isHovered)
		if not config.hoverStates[key] then
			config.hoverStates[key] = 0
		end
		if isHovered then
			config.hoverStates[key] = math.min(config.hoverStates[key] + dt * 8, 1)
		else
			config.hoverStates[key] = math.max(config.hoverStates[key] - dt * 4, 0)
		end
		return config.hoverStates[key]
	end

	--  UI Primitives

	local function drawIcon(x, y, size, iconType, color)
		local r = structs.Rectangle:new({ x = x, y = y, width = size, height = size })
		if iconType == "expanded" then
			raylib.lib.DrawTriangle(
				vector.create(x + 2, y + 3),
				vector.create(x + size - 2, y + 3),
				vector.create(x + size / 2, y + size - 3),
				color:ToRaylib(0)
			)
		elseif iconType == "collapsed" then
			raylib.lib.DrawTriangle(
				vector.create(x + 3, y + 2),
				vector.create(x + size - 3, y + size / 2),
				vector.create(x + 3, y + size - 2),
				color:ToRaylib(0)
			)
		elseif iconType == "class" then
			raylib.lib.DrawRectangleRounded(r, 0.3, 6, color:ToRaylib(0))
		elseif iconType == "enum" then
			raylib.lib.DrawCircle(x + size / 2, y + size / 2, size / 2, color:ToRaylib(0))
		else
			raylib.lib.DrawRectangle(x + 2, y + 2, size - 4, size - 4, color:ToRaylib(0))
		end
	end

	local function drawTypePill(itemType, x, y)
		local pillColor, textColor = getBadgeColors(itemType)
		local typeLabel = string.upper(itemType)
		local tw = measureText(typeLabel, config.labelFontSize, config.labelFontSpacing)
		local pw = tw + 12
		local ph = 16
		raylib.lib.DrawRectangleRounded(rect:translate(rect.new(x, y, pw, ph)), 0.5, 6, pillColor:ToRaylib(0))
		drawText(
			typeLabel,
			x + 6,
			y + (ph - config.labelFontSize) / 2 - 0.5,
			config.labelFontSize,
			config.labelFontSpacing,
			textColor
		)
		return pw
	end

	local function drawTreeItem(item, x, y, width, indent, mousePos, mousePressed, dt)
		local itemRect = rect.new(x, y, width, config.itemHeight)
		local isHovered = rect.MouseIsInRect(itemRect)
		local hoverAlpha = getHoverState(tostring(item), dt, isHovered)
		local isSelected = config.selectedItem == item

		if isSelected then
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)),
				0.18,
				6,
				config.selectedColor:ToRaylib(0)
			)
		elseif hoverAlpha > 0 then
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)),
				0.18,
				6,
				config.hoverColor:ToRaylib(0)
			)
		end

		-- Icon
		local iconX = x + indent + 4
		local iconY = y + (config.itemHeight - config.iconSize) / 2
		drawIcon(iconX, iconY, config.iconSize, item.type, isSelected and config.accentColor or config.accentDim)

		-- Name
		local nameX = iconX + config.iconSize + 10
		local nameY = y + (config.itemHeight - config.fontSize) / 2
		local nameColor = isSelected and config.textColor or color3.new(0.85, 0.86, 0.90)
		drawText(item.name, nameX, nameY, config.fontSize, config.fontSpacing, nameColor)

		if isHovered and mousePressed then
			config.selectedItem = item
			if config.onItemSelect then
				config.onItemSelect(item)
			end
		end

		local nextY = y + config.itemHeight
		if item.expanded and item.children then
			for _, child in ipairs(item.children) do
				nextY = drawTreeItem(child, x, nextY, width, indent + config.indentSize, mousePos, mousePressed, dt)
			end
		end
		return nextY
	end

	--  Middle panel update

	local function updateMiddlePanel()
		config.middleItems = {}
		if config.selectedCategoryIndex > 0 and config.selectedCategoryIndex <= #config.categories then
			local category = config.categories[config.selectedCategoryIndex]
			local function addItems(items)
				for _, item in ipairs(items) do
					if
						config.middleSearch == ""
						or string.find(string.lower(item.name), string.lower(config.middleSearch))
					then
						table.insert(config.middleItems, item)
					end
					if item.children then
						addItems(item.children)
					end
				end
			end
			if category.items then
				addItems(category.items)
			end
		end
	end

	--  Scrollable Components

	local leftPanelContent
	leftPanelContent = {
		get_rect = function()
			return rect.new(0, 0, config.leftPanelWidth, config.leftContentHeight or 1)
		end,
		set = function(prop, value)
			if prop == "obj_rect" then
				leftPanelContent.rect = value
			end
		end,
		render = function(dt)
			local r = leftPanelContent.rect
			local mousePos = raylib.lib.GetMousePosition()
			local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
			local currentY = r.y + config.padding
			local contentStartY = currentY

			for i, category in ipairs(config.categories) do
				local categoryKey = "cat_" .. i
				local categoryRect = rect.new(
					r.x + config.padding,
					currentY,
					config.leftPanelWidth - config.padding * 2,
					config.itemHeight
				)
				local isHovered = rect.MouseIsInRect(categoryRect)
				local hoverAlpha = getHoverState(categoryKey, dt, isHovered)
				local isActiveCat = config.selectedCategoryIndex == i

				if isActiveCat then
					raylib.lib.DrawRectangleRounded(
						rect:translate(
							rect.new(categoryRect.x, categoryRect.y + 1, categoryRect.width, categoryRect.height - 2)
						),
						0.18,
						6,
						config.panelColor:ToRaylib(0)
					)
					raylib.lib.DrawRectangleRounded(
						rect:translate(rect.new(categoryRect.x, categoryRect.y + 6, 3, categoryRect.height - 12)),
						0.5,
						4,
						config.accentColor:ToRaylib(0)
					)
				elseif hoverAlpha > 0 then
					raylib.lib.DrawRectangleRounded(
						rect:translate(
							rect.new(categoryRect.x, categoryRect.y + 1, categoryRect.width, categoryRect.height - 2)
						),
						0.18,
						6,
						config.hoverColor:ToRaylib(0)
					)
				end

				drawIcon(
					categoryRect.x + 2,
					categoryRect.y + config.itemHeight / 2 - config.iconSize / 2,
					config.iconSize,
					category.expanded and "expanded" or "collapsed",
					isActiveCat and config.accentColor or config.subtextColor
				)

				local textX = categoryRect.x + config.iconSize + 10
				local textY = categoryRect.y + (config.itemHeight - config.fontSize) / 2
				local countText = tostring(category.count)
				local badgeFontSize = config.labelFontSize
				local badgeHeight = 18
				local countWidth = measureText(countText, badgeFontSize, config.labelFontSpacing)
				local badgeWidth = math.max(28, countWidth + 12)
				local badgeRect = rect.new(
					categoryRect.x + categoryRect.width - badgeWidth,
					categoryRect.y + (config.itemHeight - badgeHeight) / 2,
					badgeWidth,
					badgeHeight
				)

				local catText =
					truncateText(category.name, badgeRect.x - textX - 8, config.fontSize, config.fontSpacing)
				local catNameColor = isActiveCat and config.textColor or color3.new(0.72, 0.74, 0.78)
				drawText(catText, textX, textY, config.fontSize, config.fontSpacing, catNameColor)

				raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.5, 6, config.accentDim:ToRaylib(0))
				drawText(
					countText,
					badgeRect.x + (badgeRect.width - countWidth) / 2,
					badgeRect.y + (badgeRect.height - badgeFontSize) / 2 - 0.5,
					badgeFontSize,
					config.labelFontSpacing,
					config.accentColor
				)

				if isHovered and mousePressed then
					category.expanded = not category.expanded
					config.selectedCategoryIndex = i
					updateMiddlePanel()
				end

				currentY = currentY + config.itemHeight
				if category.expanded and category.items then
					for _, item in ipairs(category.items) do
						currentY = drawTreeItem(
							item,
							r.x + config.padding,
							currentY,
							config.leftPanelWidth - config.padding * 2,
							config.indentSize,
							mousePos,
							mousePressed,
							dt
						)
					end
				end
				currentY = currentY + config.spacing
			end
			config.leftContentHeight = currentY - contentStartY + config.padding * 2
		end,
	}

	local middlePanelContent
	middlePanelContent = {
		get_rect = function()
			return rect.new(0, 0, config.middlePanelWidth, config.middleContentHeight or 1)
		end,
		set = function(prop, value)
			if prop == "obj_rect" then
				middlePanelContent.rect = value
			end
		end,
		render = function(dt)
			local r = middlePanelContent.rect
			local mousePos = raylib.lib.GetMousePosition()
			local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
			local currentY = r.y
			local contentStartY = currentY

			if #config.middleItems == 0 then
				updateMiddlePanel()
			end

			for i, item in ipairs(config.middleItems) do
				local itemKey = "middle_" .. i
				local itemRect = rect.new(
					r.x + config.padding,
					currentY,
					config.middlePanelWidth - config.padding * 2,
					config.itemHeight
				)
				local isHovered = rect.MouseIsInRect(itemRect)
				local hoverAlpha = getHoverState(itemKey, dt, isHovered)
				local isSelected = config.selectedItem == item

				if isSelected then
					raylib.lib.DrawRectangleRounded(
						rect:translate(
							rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)
						),
						0.18,
						6,
						config.selectedColor:ToRaylib(0)
					)
					raylib.lib.DrawRectangleRounded(
						rect:translate(rect.new(itemRect.x + 2, itemRect.y + 4, 3, itemRect.height - 8)),
						0.5,
						4,
						config.accentColor:ToRaylib(0)
					)
				elseif hoverAlpha > 0 then
					raylib.lib.DrawRectangleRounded(
						rect:translate(
							rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)
						),
						0.18,
						6,
						config.hoverColor:ToRaylib(0)
					)
				end

				drawIcon(
					itemRect.x + 8,
					itemRect.y + config.itemHeight / 2 - config.iconSize / 2,
					config.iconSize,
					item.type,
					isSelected and config.accentColor or config.accentDim
				)

				local pillW = measureText(item.type, config.labelFontSize, config.labelFontSpacing) + 16
				local nameMaxW = itemRect.width - config.iconSize - 26 - pillW
				local itemText = truncateText(item.name, nameMaxW, config.fontSize, config.fontSpacing)
				local nameColor = isSelected and config.textColor
					or (hoverAlpha > 0.4 and config.textColor or color3.new(0.78, 0.80, 0.84))
				drawText(
					itemText,
					itemRect.x + config.iconSize + 20,
					itemRect.y + (config.itemHeight - config.fontSize) / 2,
					config.fontSize,
					config.fontSpacing,
					nameColor
				)

				drawTypePill(
					item.type,
					itemRect.x + itemRect.width - pillW - 2,
					itemRect.y + (config.itemHeight - 16) / 2
				)

				if isHovered and mousePressed then
					config.selectedItem = item
					if config.onItemSelect then
						config.onItemSelect(item)
					end
				end
				currentY = currentY + config.itemHeight
			end
			config.middleContentHeight = currentY - contentStartY + config.padding
		end,
	}

	local rightPanelContent
	rightPanelContent = {
		get_rect = function()
			return rect.new(
				0,
				0,
				config.obj_rect.width - config.leftPanelWidth - config.middlePanelWidth - 4,
				config.rightContentHeight or 1
			)
		end,
		set = function(prop, value)
			if prop == "obj_rect" then
				rightPanelContent.rect = value
			end
		end,
		render = function(dt)
			if not config.selectedItem then
				return
			end
			local r = rightPanelContent.rect
			local currentY = r.y + config.padding
			local contentStartY = currentY

			local pillW = drawTypePill(config.selectedItem.type, r.x + config.padding, currentY + 2)
			if config.selectedItem.super then
				drawText(
					"extends " .. config.selectedItem.super,
					r.x + config.padding + pillW + 10,
					currentY + 2 + (16 - config.fontSize) / 2,
					config.fontSize,
					config.fontSpacing,
					config.subtextColor
				)
			end
			currentY = currentY + 26

			raylib.lib.DrawRectangle(
				r.x + config.padding,
				currentY,
				r.width - config.padding * 2,
				1,
				config.dividerColor:ToRaylib(0)
			)
			currentY = currentY + 14

			if config.selectedItem.documentationBlocks and #config.selectedItem.documentationBlocks > 0 then
				local docWidth = r.width - config.padding * 2
				local docHeight = documentRenderer.render(
					config.selectedItem.documentationBlocks,
					r.x + config.padding,
					currentY,
					docWidth
				)
				currentY = currentY + docHeight
			else
				drawText(
					"Description",
					r.x + config.padding,
					currentY,
					config.labelFontSize,
					config.labelFontSpacing,
					config.accentColor
				)
				currentY = currentY + 20

				local descText = config.selectedItem.description
					or (
						"Detailed information about "
						.. config.selectedItem.name
						.. ". This would typically include usage examples, parameters, return values, and other relevant documentation."
					)
				local descBoxWidth = r.width - config.padding * 2
				local descPX, descPY = 12, 12
				local descLineHeight = config.fontSize + 7
				local descTextWidth = descBoxWidth - descPX * 2
				local descLines = wrapText(descText, descTextWidth, config.fontSize, config.fontSpacing)
				local descTextHeight = ((#descLines - 1) * descLineHeight) + config.fontSize
				local descBoxHeight = descTextHeight + descPY * 2

				raylib.lib.DrawRectangleRounded(
					rect:translate(rect.new(r.x + config.padding, currentY, descBoxWidth, descBoxHeight)),
					0.10,
					6,
					config.panelColor:ToRaylib(0)
				)
				raylib.lib.DrawRectangleRounded(
					rect:translate(rect.new(r.x + config.padding, currentY + 6, 3, descBoxHeight - 12)),
					0.5,
					4,
					config.accentDim:ToRaylib(0)
				)

				drawWrappedLines(
					descLines,
					r.x + config.padding + descPX + 2,
					currentY + descPY,
					config.fontSize,
					config.fontSpacing,
					config.subtextColor,
					descLineHeight
				)

				currentY = currentY + descBoxHeight + 16
			end
			config.rightContentHeight = currentY - contentStartY + config.padding
		end,
	}

	local leftScroll = gui.scrollable({
		child = leftPanelContent,
		scrollbarWidth = 4,
		scrollbarColor = config.scrollbarColor,
		scrollbarHoverColor = config.scrollbarHoverColor,
		scrollbarBackgroundTransparency = 1,
	})
	local middleScroll = gui.scrollable({
		child = middlePanelContent,
		scrollbarWidth = 4,
		scrollbarColor = config.scrollbarColor,
		scrollbarHoverColor = config.scrollbarHoverColor,
		scrollbarBackgroundTransparency = 1,
	})
	local rightScroll = gui.scrollable({
		child = rightPanelContent,
		scrollbarWidth = 4,
		scrollbarColor = config.scrollbarColor,
		scrollbarHoverColor = config.scrollbarHoverColor,
		scrollbarBackgroundTransparency = 1,
	})

	--  Render

	wrapper.setClassDescription = function(className, newDescription)
		local function scan(items)
			for _, item in ipairs(items) do
				if item.name == className then
					item.description = newDescription
					item.documentationBlocks = MDXFormatter.parse(newDescription)
					return true
				end

				if item.children and scan(item.children) then
					return true
				end
			end

			return false
		end

		for _, category in ipairs(config.categories) do
			if category.items and scan(category.items) then
				return wrapper
			end
		end

		return wrapper
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		-- Background & Border
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(r.x - 2, r.y - 2, r.width + 4, r.height + 4)),
			config.rounded[1],
			config.rounded[2],
			config.shadowColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.borderColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(r.x + 1, r.y + 1, r.width - 2, r.height - 2)),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		local leftPanel = rect.new(r.x + 1, r.y + 1, config.leftPanelWidth, r.height - 2)
		local middlePanel = rect.new(r.x + config.leftPanelWidth + 2, r.y + 1, config.middlePanelWidth, r.height - 2)
		local rightPanel = rect.new(
			r.x + config.leftPanelWidth + config.middlePanelWidth + 3,
			r.y + 1,
			r.width - config.leftPanelWidth - config.middlePanelWidth - 4,
			r.height - 2
		)

		for _, divX in ipairs({
			r.x + config.leftPanelWidth + 1,
			r.x + config.leftPanelWidth + config.middlePanelWidth + 2,
		}) do
			raylib.lib.DrawRectangle(divX, r.y + 1, 1, r.height - 2, config.dividerColor:ToRaylib(0))
			raylib.lib.DrawRectangle(divX + 1, r.y + 1, 1, r.height - 2, color3.new(0.10, 0.11, 0.13):ToRaylib(0))
		end

		-- LEFT PANEL
		local leftHeaderRect = rect.new(leftPanel.x, leftPanel.y, leftPanel.width, config.headerHeight)
		raylib.lib.DrawRectangle(
			leftHeaderRect.x,
			leftHeaderRect.y,
			leftHeaderRect.width,
			config.headerHeight,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			leftHeaderRect.x,
			leftHeaderRect.y + config.headerHeight - 1,
			leftHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)
		drawText(
			"API",
			leftHeaderRect.x + config.padding,
			leftHeaderRect.y + 10,
			config.labelFontSize,
			config.labelFontSpacing,
			config.accentColor
		)
		drawText(
			"Reference",
			leftHeaderRect.x + config.padding,
			leftHeaderRect.y + 24,
			config.headerFontSize,
			config.headerFontSpacing,
			config.textColor
		)

		leftScroll.set(
			"obj_rect",
			rect.new(
				leftPanel.x,
				leftPanel.y + config.headerHeight,
				leftPanel.width,
				leftPanel.height - config.headerHeight
			)
		)
		leftScroll.render(dt)

		-- MIDDLE PANEL
		local middleHeaderRect = rect.new(middlePanel.x, middlePanel.y, middlePanel.width, config.headerHeight)
		raylib.lib.DrawRectangle(
			middleHeaderRect.x,
			middleHeaderRect.y,
			middleHeaderRect.width,
			middleHeaderRect.height,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			middleHeaderRect.x,
			middleHeaderRect.y + config.headerHeight - 1,
			middleHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)

		if config.selectedCategoryIndex > 0 and config.selectedCategoryIndex <= #config.categories then
			local category = config.categories[config.selectedCategoryIndex]
			drawText(
				"Category",
				middleHeaderRect.x + config.padding,
				middleHeaderRect.y + 10,
				config.labelFontSize,
				config.labelFontSpacing,
				config.subtextColor
			)
			drawText(
				truncateText(
					category.name,
					middleHeaderRect.width - config.padding * 2,
					config.headerFontSize,
					config.headerFontSpacing
				),
				middleHeaderRect.x + config.padding,
				middleHeaderRect.y + 24,
				config.headerFontSize,
				config.headerFontSpacing,
				config.textColor
			)
		end

		local searchRect = rect.new(
			middlePanel.x + config.padding,
			middlePanel.y + config.headerHeight + config.padding,
			middlePanel.width - config.padding * 2,
			config.searchHeight
		)

		if not config._searchBox and config.game then
			local theme = config.game:GetService("StudioThemeService")

			local TextBoxClass = aereon.textbox(theme, config.game)
			config._searchBox = TextBoxClass.new({
				padding = 8,
				backgroundColor = config.panelColor,
				textColor = config.textColor,
				placeholderColor = config.subtextColor,
				cornerRadius = 0.22,
				BackgroundTransparency = 0,
				BorderTransparency = 1,
				placeholder = "Search...",
				fontSize = config.fontSize,
				escapeBlurs = false,
				blurOnSubmit = false,
				onChange = function(text)
					if text ~= config.middleSearch then
						config.middleSearch = text
						updateMiddlePanel()
					end
				end,
			})
		end

		if config._searchBox then
			config._searchBox:drawWithExtras(searchRect.x, searchRect.y, searchRect.width, searchRect.height)
			local boxText = config._searchBox:getText() or ""
			if boxText ~= config.middleSearch then
				config.middleSearch = boxText
				updateMiddlePanel()
			end
		else
			raylib.lib.DrawRectangleRounded(rect:translate(searchRect), 0.22, 8, config.panelColor:ToRaylib(0))
			raylib.lib.DrawRectangleRoundedLines(rect:translate(searchRect), 0.22, 8, config.borderColor:ToRaylib(0))
			drawText(
				config.middleSearch == "" and "Search..." or config.middleSearch,
				searchRect.x + 30,
				searchRect.y + (config.searchHeight - config.fontSize) / 2,
				config.fontSize,
				config.fontSpacing,
				config.middleSearch == "" and config.subtextColor or config.textColor
			)
		end

		middleScroll.set(
			"obj_rect",
			rect.new(
				middlePanel.x,
				middlePanel.y + config.headerHeight + config.searchHeight + config.padding * 2,
				middlePanel.width,
				middlePanel.height - config.headerHeight - config.searchHeight - config.padding * 2
			)
		)
		middleScroll.render(dt)

		-- RIGHT PANEL
		local rightHeaderRect = rect.new(rightPanel.x, rightPanel.y, rightPanel.width, config.headerHeight)
		raylib.lib.DrawRectangle(
			rightHeaderRect.x,
			rightHeaderRect.y,
			rightHeaderRect.width,
			rightHeaderRect.height,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			rightHeaderRect.x,
			rightHeaderRect.y + config.headerHeight - 1,
			rightHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)

		if config.selectedItem then
			drawText(
				"Selected",
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 10,
				config.labelFontSize,
				config.labelFontSpacing,
				config.subtextColor
			)
			drawText(
				truncateText(
					config.selectedItem.name,
					rightHeaderRect.width - config.padding * 2,
					config.headerFontSize,
					config.headerFontSpacing
				),
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 24,
				config.headerFontSize,
				config.headerFontSpacing,
				config.textColor
			)
			rightScroll.set(
				"obj_rect",
				rect.new(
					rightPanel.x,
					rightPanel.y + config.headerHeight,
					rightPanel.width,
					rightPanel.height - config.headerHeight
				)
			)
			rightScroll.render(dt)
		else
			drawText(
				"Details",
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 10,
				config.labelFontSize,
				config.labelFontSpacing,
				config.subtextColor
			)
			drawText(
				"",
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 24,
				config.headerFontSize,
				config.headerFontSpacing,
				color3.new(0.30, 0.32, 0.36)
			)
			local hintText = "Select an item to view details"
			local hintW = measureText(hintText, config.fontSize, config.fontSpacing)
			drawText(
				hintText,
				rightPanel.x + (rightPanel.width - hintW) / 2,
				rightPanel.y + rightPanel.height / 2 - config.fontSize / 2,
				config.fontSize,
				config.fontSpacing,
				config.subtextColor
			)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	wrapper.set = function(prop, value)
		config[prop] = value
		if prop == "font" or prop == "mdxComponents" or prop == "mdxStyles" or prop == "mdxTheme" then
			documentRenderer = createDocumentRenderer()
		end
		return wrapper
	end

	table.insert(objects, wrapper)
	return wrapper
end
