local rl = require("@raylib")
--local aereon = require("@Kinemium.Aereon")

local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local Color3 = require("@Color3")
local syntax = require("./syntax")
local autocomplete = require("./autocomplete")
local structs = rl.structs
local const = rl.const

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

return function(raylib: typeof(rl.lib), theme, aereon, game)
	local rect = aereon.rect()
	local editor = {}
	local KinemiumFontService = game:GetService("KinemiumFontService")
	local IconLoader = game:GetService("KinemiumIconLoader")

	local _icons = {
		constant = "./src/assets/images/icons/vanilla3/general/32x/200/WireframeRendering.png",
		functionVar = "./src/assets/images/icons/vanilla3/general/32x/200/Function.png",
	}

	local vend = KinemiumFontService.GetMonoFontDefault()

	local function measureTextWidth(text, fontSize, spacing)
		if #text == 0 then
			return 0
		end
		return raylib.MeasureTextEx(vend, text, fontSize, spacing).x
	end

	local function isMouseInRect(r, mousePos)
		return mousePos.x >= r.x and mousePos.x <= r.x + r.width and mousePos.y >= r.y and mousePos.y <= r.y + r.height
	end

	local function getColumnFromX(line, xPos, fontSize, spacing)
		if #line == 0 then
			return 1
		end

		local bestCol = 1
		local bestDist = math.abs(xPos)

		for col = 1, #line + 1 do
			local substr = line:sub(1, col - 1)
			local width = measureTextWidth(substr, fontSize, spacing)
			local dist = math.abs(xPos - width)

			if dist < bestDist then
				bestDist = dist
				bestCol = col
			end
		end

		return bestCol
	end

	--[[
        ide = {
			BackgroundColor = Color3.new(0.05, 0.05, 0.05),
			SecondaryBackgroundColor = Color3.new(0.07, 0.07, 0.07),
			TextColor = Color3.new(1, 1, 1),
		},
    --]]
	local editor_theme = theme.ide
	local theme_background, theme_secondary, theme_text, currentLineColor =
		Color3ToRaylib(editor_theme.BackgroundColor, 0),
		Color3ToRaylib(editor_theme.SecondaryBackgroundColor, 0),
		Color3ToRaylib(editor_theme.TextColor, 0),
		Color3ToRaylib(editor_theme.currentLineColor, 0)

	local autocompletetheme = editor_theme.autocomplete

	function editor:updateBreakpoints()
		local active = {}
		for line, enabled in pairs(self.breakpoints) do
			if enabled then
				table.insert(active, line)
			end
		end
		table.sort(active)
		self.Breakpoints = active
	end

	editor.buffers = { { name = "untitled.lua", buffer = ideBuffer.create(), breakpoints = {} } }
	editor.currentBufferIndex = 1
	editor.text = editor.buffers[1].buffer
	editor.breakpoints = editor.buffers[1].breakpoints
	editor:updateBreakpoints()
	editor.text.lines = { "" }
	editor.isActive = false
	editor.caretVisible = true
	editor.caretTimer = 0
	editor.caretBlinkRate = 0.5

	editor.autocomplete = {
		visible = false,
		items = {}, -- will be populated by updateAutocomplete
		selectedIndex = 1,
		currentX = 0,
		currentY = 0,
		targetX = 0,
		targetY = 0,
		lerpSpeed = 35,
	}
	
	editor.snippet = {
		active = false,
		index = 1,
		positions = {},
		line = 0,
		startCol = 0,
	}

	function editor:openTab(name, content)
		local newBuf = ideBuffer.create()
		if content then
			newBuf:clear()
			newBuf:insertString(content)
			newBuf:setCursor(1, 1)
		end
		table.insert(self.buffers, { name = name or "untitled.lua", buffer = newBuf, breakpoints = {} })
		self.currentBufferIndex = #self.buffers
		self.text = newBuf
		self.breakpoints = self.buffers[self.currentBufferIndex].breakpoints
		self:updateBreakpoints()
		self._highlightCache = {}
	end

	function editor:closeTab(index)
		if #self.buffers <= 1 then
			return
		end
		table.remove(self.buffers, index)
		if self.currentBufferIndex > #self.buffers then
			self.currentBufferIndex = #self.buffers
		end
		self.text = self.buffers[self.currentBufferIndex].buffer
		self.breakpoints = self.buffers[self.currentBufferIndex].breakpoints
		self:updateBreakpoints()
		self._highlightCache = {}
	end

	function editor:getCode()
		local buf = table.create(#self.text.lines)
		for i, line in ipairs(self.text.lines) do
			buf[i] = line
		end
		return table.concat(buf, "\n")
	end

	editor.scrollY = 0
	editor.maxScroll = 0

	function editor.draw(x, y, size, gutterwidth)
		local tabHeight = 30
		local tabWidth = 120

		for i, tab in ipairs(editor.buffers) do
			local tx = x + (i - 1) * tabWidth
			local tabRect = { x = tx, y = y, width = tabWidth, height = tabHeight }
			local isCurrent = (i == editor.currentBufferIndex)

			local bgColor = isCurrent and theme_secondary or theme_background
			raylib.DrawRectangle(tx, y, tabWidth, tabHeight, bgColor)
			raylib.DrawTextEx(vend, tab.name, vector.create(tx + 5, y + 5), 14, 1, const.WHITE)

			if raylib.IsMouseButtonPressed(0) == 1 and isMouseInRect(tabRect, raylib.GetMousePosition()) then
				editor.currentBufferIndex = i
				editor.text = tab.buffer
				editor._highlightCache = {}
			end

			local closeX = tx + tabWidth - 20
			local closeRect = { x = closeX, y = y + 5, width = 15, height = 15 }
			raylib.DrawTextEx(vend, "x", vector.create(closeX, y + 5), 14, 1, const.GRAY)
			if raylib.IsMouseButtonPressed(0) == 1 and isMouseInRect(closeRect, raylib.GetMousePosition()) then
				editor:closeTab(i)
				return
			end
		end

		y = y + tabHeight
		size = vector.create(size.x, size.y - tabHeight)

		local dt = raylib.GetFrameTime()
		editor.caretTimer = (editor.caretTimer or 0) + dt

		editor.caretBlinkRate = editor.caretBlinkRate or 0.5
		if editor.caretTimer >= editor.caretBlinkRate then
			editor.caretVisible = not editor.caretVisible
			editor.caretTimer = editor.caretTimer - editor.caretBlinkRate
		end

		local padding = 20
		local fontSize = 18
		local lineHeight = fontSize + 4
		local spacing = 1

		local contentHeight = #editor.text.lines * lineHeight
		local viewportHeight = size.y - (padding * 2)
		editor.maxScroll = math.max(0, contentHeight - viewportHeight)

		local background = rect.new(x, y, size.x, size.y)
		if isMouseInRect({ x = x, y = y, width = size.x, height = size.y }, raylib.GetMousePosition()) then
			local wheel = raylib.GetMouseWheelMove()
			if wheel ~= 0 then
				local scrollSpeed = lineHeight * 3
				editor.scrollY = editor.scrollY - (wheel * scrollSpeed)
				editor.scrollY = math.clamp(editor.scrollY, 0, editor.maxScroll)
			end
		end

		local firstVisibleLine = math.floor(editor.scrollY / lineHeight) + 1
		local lastVisibleLine = math.ceil((editor.scrollY + viewportHeight) / lineHeight)
		firstVisibleLine = math.max(1, firstVisibleLine)
		lastVisibleLine = math.min(#editor.text.lines, lastVisibleLine)

		local lines = rect.new(x, y, gutterwidth, size.y)
		raylib.DrawRectangleRec(rect:translate(background), theme_background)
		raylib.DrawRectangleRec(rect:translate(lines), theme_secondary)

		if editor.isActive then
			local c = editor.text.cursor
			local lineY = y + padding + (c.line - 1) * lineHeight - editor.scrollY
			if lineY >= y and lineY < y + size.y then
				raylib.DrawRectangle(x + gutterwidth, lineY, size.x - gutterwidth, lineHeight, currentLineColor)
			end

			local sL, sC, eL, eC = editor.text:getSelectionRange()
			if sL then
				for i = math.max(firstVisibleLine, sL), math.min(lastVisibleLine, eL) do
					local ly = y + padding + (i - 1) * lineHeight - editor.scrollY
					local line = editor.text.lines[i]
					local startX = (i == sL) and sC or 1
					local endX = (i == eL) and eC or #line + 1

					local x1 = x + gutterwidth + padding + measureTextWidth(line:sub(1, startX - 1), fontSize, spacing)
					local x2 = x + gutterwidth + padding + measureTextWidth(line:sub(1, endX - 1), fontSize, spacing)

					raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, Color3ToRaylib(Color3.new(0, 0.4, 0.8), 0.5))
				end
			end
		end

		for i = firstVisibleLine, lastVisibleLine do
			local line = editor.text.lines[i]
			if not line then
				break
			end

			local yLine = y + padding + (i - 1) * lineHeight - editor.scrollY

			local circleRadius = 5
			local circleX = x + gutterwidth - 8
			
			if editor.breakpoints[i] then
				raylib.DrawCircle(circleX, yLine + lineHeight / 2, circleRadius, Color3ToRaylib(Color3.new(0.8, 0.1, 0.1), 0))
			else
				local mousePos = raylib.GetMousePosition()
				if 
					mousePos.x >= x and mousePos.x <= x + gutterwidth and
					mousePos.y >= yLine and mousePos.y <= yLine + lineHeight
				then
					raylib.DrawCircle(circleX, yLine + lineHeight / 2, circleRadius, Color3ToRaylib(Color3.new(0.8, 0.1, 0.1), 0.7))
				end
			end

			local indentLevel = autocomplete.getIndentLevel(line)
			local indentWidth = 14
			local indentStartX = x + gutterwidth + padding

			for lvl = 1, indentLevel do
				local rx = indentStartX + (lvl - 1) * indentWidth

				raylib.DrawRectangle(
					rx,
					yLine,
					2,
					lineHeight,
					structs.Color:new({
						r = 255,
						g = 255,
						b = 255,
						a = 40, -- transparency
					})
				)
			end

			editor._highlightCache = editor._highlightCache or {}
			local tokens = editor._highlightCache[i]
			if not tokens then
				tokens = syntax.highlight(line)
				editor._highlightCache[i] = tokens
			end

			local lineNumberText = tostring(i)
			local lineNumberX = x + padding
			raylib.DrawTextEx(vend, lineNumberText, vector.create(lineNumberX, yLine), fontSize, spacing, const.WHITE)

			local xPos = x + gutterwidth + padding
			for _, tok in ipairs(tokens) do
				raylib.DrawTextEx(vend, tok.text, vector.create(xPos, yLine), fontSize, spacing, tok.color)

				xPos += raylib.MeasureTextEx(vend, tok.text, fontSize, spacing).x
			end
		end

		if editor.isActive then
			local byte = raylib.GetCharPressed()
			if byte ~= 0 then
				local char = string.char(byte)
				if editor.text.selection.active then
					editor.text:deleteSelection()
				end

				editor.text:insertChar(char)

				local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
				if pairs[char] then
					editor.text:insertChar(pairs[char])
					editor.text:moveLeft()
				end

				autocomplete.updateAutocomplete(editor)
				editor._highlightCache = {}
			end
		end

		if raylib.IsMouseButtonPressed(0) == 1 and rect.MouseIsInRect(background) then
			editor.isActive = true

			local mousePos = raylib.GetMousePosition()
			local relY = mousePos.y - (y + padding) + editor.scrollY
			local clickedLine = math.clamp(math.floor(relY / lineHeight) + 1, 1, #editor.text.lines)

			if mousePos.x < x + gutterwidth then
				editor.breakpoints[clickedLine] = not editor.breakpoints[clickedLine]
				editor:updateBreakpoints()
				return
			end

			local relX = mousePos.x - (x + gutterwidth + padding)
			local clickedCol = getColumnFromX(editor.text.lines[clickedLine], relX, fontSize, spacing)

			editor.text.cursor.line = clickedLine
			editor.text.cursor.col = clickedCol

			editor.text.selection.active = true
			editor.text.selection.startLine = clickedLine
			editor.text.selection.startCol = clickedCol
			editor.text.selection.endLine = clickedLine
			editor.text.selection.endCol = clickedCol
		elseif raylib.IsMouseButtonDown(0) == 1 and editor.isActive then
			local mousePos = raylib.GetMousePosition()
			local relX = mousePos.x - (x + gutterwidth + padding)
			local relY = mousePos.y - (y + padding) + editor.scrollY

			local clickedLine = math.clamp(math.floor(relY / lineHeight) + 1, 1, #editor.text.lines)
			local clickedCol = getColumnFromX(editor.text.lines[clickedLine], relX, fontSize, spacing)

			editor.text.cursor.line = clickedLine
			editor.text.cursor.col = clickedCol
			editor.text.selection.endLine = clickedLine
			editor.text.selection.endCol = clickedCol

			if
				editor.text.selection.startLine == editor.text.selection.endLine
				and editor.text.selection.startCol == editor.text.selection.endCol
			then
				editor.text.selection.active = false
			else
				editor.text.selection.active = true
			end
		end

		if rect.MouseIsInRect(background) then
			raylib.SetMouseCursor(EnumMap.KinemiumMouseCursor.MOUSE_CURSOR_IBEAM.Value)
		else
			raylib.SetMouseCursor(EnumMap.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			if raylib.IsMouseButtonReleased(0) == 1 then
				if editor.isActive then
					editor.isActive = false
				end
			end
		end

		if editor.isActive and editor.caretVisible then
			local c = editor.text.cursor
			local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			if cy >= y and cy < y + size.y then
				raylib.DrawRectangle(cx, cy, 2, lineHeight, const.WHITE)
			end

			local caretTop = (c.line - 1) * lineHeight
			local caretBottom = c.line * lineHeight

			if caretTop < editor.scrollY then
				editor.scrollY = caretTop
			elseif caretBottom > editor.scrollY + viewportHeight then
				editor.scrollY = caretBottom - viewportHeight
			end
		end

		autocomplete.step(
			editor,
			x,
			gutterwidth,
			padding,
			measureTextWidth,
			fontSize,
			5,
			lineHeight,
			autocompletetheme,
			rect,
			raylib,
			Color3ToRaylib,
			vend,
			spacing,
			theme_text,
			theme_secondary,
			y,
			dt,
			IconLoader
		)

		if editor.isActive then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1 then
				if editor.autocomplete.visible then
					autocomplete.completeWord(editor)
					editor._highlightCache = {}
				elseif editor.snippet and editor.snippet.active then
					autocomplete.cycleSnippet(editor)
					editor._highlightCache = {}
				else
					editor.text:insertChar("\t")
					editor._highlightCache = {}
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				if editor.autocomplete.visible then
					autocomplete.completeWord(editor)
					editor._highlightCache = {}
				else
					if editor.text.selection.active then
						editor.text:deleteSelection()
					end

					local currentLine = editor.text.lines[editor.text.cursor.line]
					local indent = currentLine:match("^[\t ]*")

					editor.text:newline()
					editor.text:insertString(indent)

					editor._highlightCache = {}
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				if editor.autocomplete.visible then
					editor.autocomplete.visible = false
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				if editor.text.selection.active then
					editor.text:deleteSelection()
				else
					editor.text:backspace()
				end
				autocomplete.updateAutocomplete(editor)
				editor._highlightCache = {}
			end

			-- paste
			if editor.autocomplete.visible then
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.autocomplete.selectedIndex =
						math.min(editor.autocomplete.selectedIndex + 1, #editor.autocomplete.items)
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.autocomplete.selectedIndex = math.max(editor.autocomplete.selectedIndex - 1, 1)
				end
			else
				local shift = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1

				local function updateSelection()
					if shift then
						if not editor.text.selection.active then
							editor.text.selection.active = true
							editor.text.selection.startLine = editor.text.cursor.line
							editor.text.selection.startCol = editor.text.cursor.col
						end
						editor.text.selection.endLine = editor.text.cursor.line
						editor.text.selection.endCol = editor.text.cursor.col
					else
						editor.text.selection.active = false
					end
				end

				if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
					editor.text:moveLeft()
					updateSelection()
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
					editor.text:moveRight()
					updateSelection()
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.text:moveUp()
					updateSelection()
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.text:moveDown()
					updateSelection()
					autocomplete.updateAutocomplete(editor)
				end
			end

			if raylib.IsKeyDown(341) == 1 then
				if raylib.IsKeyReleased(const.KeyboardKey.KEY_C) == 1 then
					local text = editor.text:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
					end
				elseif raylib.IsKeyReleased(const.KeyboardKey.KEY_X) == 1 then
					local text = editor.text:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
						editor.text:deleteSelection()
						editor._highlightCache = {}
					end
				elseif raylib.IsKeyReleased(const.KeyboardKey.KEY_A) == 1 then
					editor.text.selection.active = true
					editor.text.selection.startLine = 1
					editor.text.selection.startCol = 1
					editor.text.selection.endLine = #editor.text.lines
					editor.text.selection.endCol = #editor.text.lines[#editor.text.lines] + 1
					editor.text:setCursor(#editor.text.lines, #editor.text.lines[#editor.text.lines] + 1)
				elseif raylib.IsKeyReleased(const.KeyboardKey.KEY_V) == 1 then
					if editor.text.selection.active then
						editor.text:deleteSelection()
					end
					local text = raylib.GetClipboardText()
					local bufferLength = buffer.len(text:span())
					local data = buffer.readstring(text:span(), 0, bufferLength - 1)
					data = string.gsub(data, "\r\n", "\n")
					data = string.gsub(data, "\r", "\n")
					editor.text:insertString(data)
					autocomplete.updateAutocomplete(editor)
					editor._highlightCache = {}
				end
			end
		end
	end

	return editor
end
