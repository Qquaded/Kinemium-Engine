local adapter = require("@RaylibAdapter")
local rect = require("@arect")
local color3 = require("@Color3")
local syntax = require("../../../modules/Aereon/ide/syntax")

local MDXFormatter = {}

local function merge(base, overrides)
	local out = {}
	for k, v in pairs(base or {}) do
		out[k] = v
	end
	for k, v in pairs(overrides or {}) do
		out[k] = v
	end
	return out
end

local function trim(value)
	return (string.gsub(value or "", "^%s*(.-)%s*$", "%1"))
end

local function stripInline(value)
	local text = value or ""
	text = string.gsub(text, "%s*%[#[-_%w]+%]%s*$", "")
	text = string.gsub(text, "`([^`]*)`", "%1")
	text = string.gsub(text, "%*%*([^*]*)%*%*", "%1")
	text = string.gsub(text, "%[([^%]]+)%]%([^%)]+%)", "%1")
	return trim(text)
end

local function splitPipeRow(line)
	local row = trim(line)
	if string.sub(row, 1, 1) == "|" then
		row = string.sub(row, 2)
	end
	if string.sub(row, -1) == "|" then
		row = string.sub(row, 1, -2)
	end

	local cells = {}
	for cell in string.gmatch(row .. "|", "([^|]*)|") do
		table.insert(cells, stripInline(cell))
	end
	return cells
end

local function isTableDivider(line)
	local normalized = string.gsub(trim(line), "[|%s:%-]", "")
	return string.find(line, "|", 1, true) ~= nil and normalized == ""
end

local function isImportOrExport(line)
	return string.match(line, "^%s*import%s+") ~= nil or string.match(line, "^%s*export%s+") ~= nil
end

local function isJsxLine(line)
	return string.match(line, "^%s*</?[%u%l][^>]*>%s*$") ~= nil
end

local function pushParagraph(blocks, paragraph)
	if #paragraph == 0 then
		return
	end
	table.insert(blocks, {
		kind = "paragraph",
		text = stripInline(table.concat(paragraph, " ")),
	})
	table.clear(paragraph)
end

function MDXFormatter.parse(source)
	local blocks = {}
	local paragraph = {}
	local lines = {}

	source = string.gsub(source or "", "\r\n", "\n")
	source = string.gsub(source, "\r", "\n")
	for line in string.gmatch(source .. "\n", "([^\n]*)\n") do
		table.insert(lines, line)
	end

	local i = 1
	while i <= #lines do
		local line = lines[i]
		local clean = trim(line)

		if i == 1 and clean == "---" then
			i += 1
			while i <= #lines and trim(lines[i]) ~= "---" do
				i += 1
			end
		elseif clean == "" or isImportOrExport(line) or isJsxLine(line) then
			pushParagraph(blocks, paragraph)
		elseif string.match(line, "^%s*```") then
			pushParagraph(blocks, paragraph)
			local language = trim(string.gsub(line, "^%s*```", ""))
			local codeLines = {}
			i += 1
			while i <= #lines and not string.match(lines[i], "^%s*```") do
				table.insert(codeLines, lines[i])
				i += 1
			end
			table.insert(blocks, {
				kind = "code",
				language = language,
				text = table.concat(codeLines, "\n"),
			})
		elseif string.match(line, "^%s*#+%s+") then
			pushParagraph(blocks, paragraph)
			local marks, title = string.match(line, "^%s*(#+)%s+(.+)$")
			table.insert(blocks, {
				kind = "heading",
				level = math.min(#marks, 6),
				text = stripInline(title),
			})
		elseif string.find(line, "|", 1, true) and i < #lines and isTableDivider(lines[i + 1]) then
			pushParagraph(blocks, paragraph)
			local headers = splitPipeRow(line)
			local rows = {}
			i += 2
			while i <= #lines and string.find(lines[i], "|", 1, true) do
				table.insert(rows, splitPipeRow(lines[i]))
				i += 1
			end
			i -= 1
			table.insert(blocks, {
				kind = "table",
				headers = headers,
				rows = rows,
			})
		elseif string.match(line, "^%s*[-*+]%s+") then
			pushParagraph(blocks, paragraph)
			local items = {}
			while i <= #lines do
				local item = string.match(lines[i], "^%s*[-*+]%s+(.+)$")
				if not item then
					break
				end
				table.insert(items, stripInline(item))
				i += 1
			end
			i -= 1
			table.insert(blocks, {
				kind = "list",
				items = items,
			})
		elseif
			string.match(clean, "^%*%*%*+$")
			or string.match(clean, "^%-%-%-+$")
			or string.match(clean, "^___%_*$")
		then
			pushParagraph(blocks, paragraph)
			table.insert(blocks, { kind = "separator" })
		else
			table.insert(paragraph, clean)
		end

		i += 1
	end

	pushParagraph(blocks, paragraph)
	return blocks
end

local defaultTheme = {
	textColor = color3.new(0.88, 0.90, 0.94),
	mutedTextColor = color3.new(0.54, 0.57, 0.62),
	headingColor = color3.new(0.96, 0.97, 1.00),
	accentColor = color3.new(0.28, 0.62, 1.00),
	panelColor = color3.new(0.080, 0.086, 0.096),
	headerColor = color3.new(0.10, 0.11, 0.13),
	borderColor = color3.new(0.15, 0.16, 0.19),
	codeColor = color3.new(0.78, 0.88, 1.00),
}

local defaultStyles = {
	padding = 16,
	blockGap = 14,
	paragraphFontSize = 13,
	paragraphSpacing = 0.4,
	paragraphLineHeight = 20,
	headingSpacing = 0.5,
	tableFontSize = 12,
	tableSpacing = 0.3,
	tableRowHeight = 30,
	tableCellPadding = 10,
	codeFontSize = 12,
	codeSpacing = 0.25,
	codeLineHeight = 19,
	listLineHeight = 21,
}

function MDXFormatter.createRenderer(options)
	options = options or {}
	local theme = merge(defaultTheme, options.theme)
	local styles = merge(defaultStyles, options.styles)
	local custom = options.components or {}
	local font = options.font or adapter.lib.GetFontDefault()

	local renderer = {}
	renderer.contentHeight = 1

	local function drawText(text, x, y, size, spacing, color, transparency)
		adapter.lib.DrawTextEx(font, text or "", vector.create(x, y), size, spacing, color:ToRaylib(transparency or 0))
	end

	local function measureText(text, size, spacing)
		local measured = adapter.lib.MeasureTextEx(font, text or "", size, spacing)
		return measured.x
	end

	local function wrapText(text, maxWidth, size, spacing)
		local lines = {}
		for rawLine in string.gmatch((text or "") .. "\n", "([^\n]*)\n") do
			local current = ""
			for word in string.gmatch(rawLine, "%S+") do
				local nextLine = current == "" and word or (current .. " " .. word)
				if measureText(nextLine, size, spacing) <= maxWidth then
					current = nextLine
				else
					if current ~= "" then
						table.insert(lines, current)
					end
					current = word
				end
			end
			if current ~= "" then
				table.insert(lines, current)
			elseif rawLine == "" then
				table.insert(lines, "")
			end
		end
		return lines
	end

	local helpers = {
		raylib = raylib,
		rect = rect,
		theme = theme,
		styles = styles,
		drawText = drawText,
		measureText = measureText,
		wrapText = wrapText,
	}

	local headingHoverAlpha = {}

	local function renderHeading(block, x, y, width)
		local sizeByLevel = { 30, 23, 18, 16, 14, 13 }
		local size = sizeByLevel[block.level] or 14
		local topGap = block.level == 1 and 2 or 6
		local height = size + topGap + 8

		local dt = adapter.lib.GetFrameTime()
		local key = block.text
		headingHoverAlpha[key] = headingHoverAlpha[key] or 0

		local hoverRect = rect.new(x, y, width, height)
		local target = rect.MouseIsInRect(hoverRect) and 1 or 0
		local speed = 8
		headingHoverAlpha[key] = headingHoverAlpha[key] + (target - headingHoverAlpha[key]) * math.min(1, dt * speed)

		local alpha = headingHoverAlpha[key]
		if alpha > 0.001 then
			local highlightColor = color3.new(theme.accentColor.R, theme.accentColor.G, theme.accentColor.B)
			adapter.lib.DrawRectangle(x, y, width, height, highlightColor:ToRaylib(1 - alpha * 0.88))
		end

		drawText(block.text, x, y + topGap, size, styles.headingSpacing, theme.headingColor, 0)

		if block.level <= 2 then
			adapter.lib.DrawRectangle(x, y + height - 1, width, 1, theme.borderColor:ToRaylib(0))
			height += 8
		end

		return height
	end

	local function renderParagraph(block, x, y, width)
		local lines = wrapText(block.text, width, styles.paragraphFontSize, styles.paragraphSpacing)
		for index, line in ipairs(lines) do
			drawText(
				line,
				x,
				y + (index - 1) * styles.paragraphLineHeight,
				styles.paragraphFontSize,
				styles.paragraphSpacing,
				theme.textColor
			)
		end
		return math.max(styles.paragraphLineHeight, #lines * styles.paragraphLineHeight)
	end

	local function renderList(block, x, y, width)
		local bulletWidth = 18
		local contentWidth = width - bulletWidth
		local currentY = y
		for _, item in ipairs(block.items) do
			local lines = wrapText(item, contentWidth, styles.paragraphFontSize, styles.paragraphSpacing)
			drawText("-", x + 2, currentY, styles.paragraphFontSize, styles.paragraphSpacing, theme.accentColor)
			for index, line in ipairs(lines) do
				drawText(
					line,
					x + bulletWidth,
					currentY + (index - 1) * styles.listLineHeight,
					styles.paragraphFontSize,
					styles.paragraphSpacing,
					theme.textColor
				)
			end
			currentY += math.max(styles.listLineHeight, #lines * styles.listLineHeight)
		end
		return currentY - y
	end

	local function renderCode(block, x, y, width)
		local lines = {}
		for line in string.gmatch((block.text or "") .. "\n", "([^\n]*)\n") do
			table.insert(lines, line)
		end
		local height = math.max(styles.codeLineHeight, #lines * styles.codeLineHeight) + styles.tableCellPadding * 2

		adapter.lib.DrawRectangleRounded(
			rect:translate(rect.new(x, y, width, height)),
			0.08,
			6,
			theme.panelColor:ToRaylib(0)
		)
		adapter.lib.DrawRectangleRoundedLines(
			rect:translate(rect.new(x, y, width, height)),
			0.08,
			6,
			theme.borderColor:ToRaylib(0)
		)

		local isLuau = block.language == "luau" or block.language == "lua" or block.language == ""

		for index, line in ipairs(lines) do
			local lineY = y + styles.tableCellPadding + (index - 1) * styles.codeLineHeight
			local cursorX = x + styles.tableCellPadding

			if isLuau then
				local tokens = syntax.highlight(line)
				for _, token in ipairs(tokens) do
					adapter.lib.DrawTextEx(
						font,
						token.text,
						vector.create(cursorX, lineY),
						styles.codeFontSize,
						styles.codeSpacing,
						token.color
					)
					local w = adapter.lib.MeasureTextEx(font, token.text, styles.codeFontSize, styles.codeSpacing)
					cursorX += w.x
				end
			else
				drawText(line, cursorX, lineY, styles.codeFontSize, styles.codeSpacing, theme.codeColor)
			end
		end

		return height
	end

	local function renderTable(block, x, y, width)
		local columns = math.max(1, #block.headers)
		local cellWidth = width / columns
		local totalRows = #block.rows + 1
		local height = totalRows * styles.tableRowHeight

		adapter.lib.DrawRectangleRounded(
			rect:translate(rect.new(x, y, width, height)),
			0.06,
			6,
			theme.panelColor:ToRaylib(0)
		)
		adapter.lib.DrawRectangle(x, y, width, styles.tableRowHeight, theme.headerColor:ToRaylib(0))

		for col, header in ipairs(block.headers) do
			local cellX = x + (col - 1) * cellWidth
			if col > 1 then
				adapter.lib.DrawRectangle(cellX, y, 1, height, theme.borderColor:ToRaylib(0))
			end
			drawText(
				header,
				cellX + styles.tableCellPadding,
				y + 8,
				styles.tableFontSize,
				styles.tableSpacing,
				theme.headingColor
			)
		end

		for rowIndex, row in ipairs(block.rows) do
			local rowY = y + rowIndex * styles.tableRowHeight
			adapter.lib.DrawRectangle(x, rowY, width, 1, theme.borderColor:ToRaylib(0))
			for col = 1, columns do
				local cellX = x + (col - 1) * cellWidth
				local value = row[col] or ""
				local color = col == 1 and theme.codeColor or theme.mutedTextColor
				drawText(
					value,
					cellX + styles.tableCellPadding,
					rowY + 8,
					styles.tableFontSize,
					styles.tableSpacing,
					color
				)
			end
		end

		return height
	end

	local defaults = {
		heading = renderHeading,
		paragraph = renderParagraph,
		list = renderList,
		code = renderCode,
		table = renderTable,
		separator = function(block, x, y, width)
			local midY = y + 6
			adapter.lib.DrawRectangle(x, midY, width, 1, theme.borderColor:ToRaylib(0))
			return 13
		end,
	}

	function renderer.render(blocks, x, y, width)
		local currentY = y
		for _, block in ipairs(blocks or {}) do
			local component = custom[block.kind] or defaults[block.kind]
			if component then
				local height = component(block, x, currentY, width, helpers) or 0
				currentY += height + styles.blockGap
			end
		end
		renderer.contentHeight = math.max(1, currentY - y + styles.padding)
		return renderer.contentHeight
	end

	return renderer
end

return MDXFormatter
