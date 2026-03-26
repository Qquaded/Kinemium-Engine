local rl = require("@raylib")
--local aereon = require("@Aereon")

local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local Color3 = require("@Color3")
local syntax = require("./syntax")
local autocomplete = require("./autocomplete")
local ligatures = require("./ligatures")
local luau = zune.luau

local structs = rl.structs
local const = rl.const

local function sanitizeText(text)
	-- Replace non-ASCII spaces and tabs with standard ones
	text = text:gsub("[\194\160]", " ") -- Non-breaking space (UTF-8)
	text = text:gsub("[\226\128\168]", " ") -- Zero-width space
	text = text:gsub("[\226\128\139]", "") -- Zero-width joiner
	text = text:gsub("[\239\187\191]", "") -- BOM (Byte Order Mark)

	-- Remove or replace any other non-printable characters
	text = text:gsub("[^\9\10\13\32-\126\128-\255]", "")

	-- Normalize line endings
	text = text:gsub("\r\n", "\n")
	text = text:gsub("\r", "\n")

	return text
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
		if text == nil then
			return 0
		end
		if #text == 0 then
			return 0
		end

		local width = 0

		for i = 1, #text do
			local ch = text:sub(i, i)

			if ch == " " then
				width += editor.spaceWidth
			elseif ch == "\t" then
				width += editor.tabWidth
			else
				width += raylib.MeasureTextEx(vend, ch, fontSize, spacing).x
			end
		end

		return width
	end

	local function isMouseInRect(r, mousePos)
		return mousePos.x >= r.x and mousePos.x <= r.x + r.width and mousePos.y >= r.y and mousePos.y <= r.y + r.height
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
		editor_theme.BackgroundColor:ToRaylib(0),
		editor_theme.SecondaryBackgroundColor:ToRaylib(0),
		editor_theme.TextColor:ToRaylib(0),
		editor_theme.currentLineColor:ToRaylib(0)

	local autocompletetheme = editor_theme.autocomplete

	local function measureTextWithTabs(text, fontSize, spacing)
		local width = 0

		for i = 1, #text do
			local ch = text:sub(i, i)

			if ch == "\t" then
				width += editor.tabWidth
			elseif ch == " " then
				width += editor.spaceWidth
			else
				width += raylib.MeasureTextEx(vend, ch, fontSize, spacing).x
			end
		end

		return width
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

	local function copyLines(lines)
		local cloned = table.create(#lines)
		for i, line in ipairs(lines) do
			cloned[i] = line
		end
		return cloned
	end

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

	editor.buffers = {}
	editor.currentBufferIndex = 1
	editor.tabSize = 4
	editor.spaceWidth = nil -- computed from font
	editor.text = ideBuffer.create()
	editor.historyLimit = 200
	editor._historyByBuffer = {}
	editor._pendingEditSnapshot = nil
	editor._lastEditChanged = false
	editor.breakpoints = {}
	editor:updateBreakpoints()
	editor.text.lines = { "" }
	editor.isActive = false
	editor.caretVisible = true
	editor.caretTimer = 0
	editor.caretBlinkRate = 0.5
	editor.formatNotificationTimer = 0

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

	editor.search = {
		active = false,
		query = "",
		results = {},
		currentIndex = 0,
	}

	editor.gotoLine = {
		active = false,
		query = "",
	}

	editor.replace = {
		active = false,
		query = "",
	}

	editor.fontSize = 18
	local spacing = 1
	editor.spaceWidth = raylib.MeasureTextEx(vend, " ", editor.fontSize, spacing).x
	editor.tabWidth = editor.spaceWidth * editor.tabSize

	editor.lsp = {
		errors = {},
		lastCode = "",
		hoveredError = nil,
		hoverX = 0,
		hoverY = 0,
		dirty = false,
		lastEditTime = 0,
		debounceTime = 0.5,
	}

	editor.highlightedToken = nil

	function editor:getHistoryState(bufferRef)
		local key = bufferRef or self.text
		local history = self._historyByBuffer[key]
		if not history then
			history = {
				undoStack = {},
				redoStack = {},
			}
			self._historyByBuffer[key] = history
		end
		return history
	end

	function editor:createSnapshot()
		return {
			lines = copyLines(self.text.lines),
			cursor = {
				line = self.text.cursor.line,
				col = self.text.cursor.col,
			},
			selection = {
				active = self.text.selection.active,
				startLine = self.text.selection.startLine,
				startCol = self.text.selection.startCol,
				endLine = self.text.selection.endLine,
				endCol = self.text.selection.endCol,
			},
			scrollY = self.scrollY,
		}
	end

	function editor:restoreSnapshot(snapshot)
		if not snapshot then
			return
		end

		self.text.lines = copyLines(snapshot.lines)
		self.text.cursor.line = math.clamp(snapshot.cursor.line, 1, #self.text.lines)
		self.text.cursor.col = math.clamp(snapshot.cursor.col, 1, #self.text.lines[self.text.cursor.line] + 1)

		self.text.selection.active = snapshot.selection.active
		self.text.selection.startLine = snapshot.selection.startLine
		self.text.selection.startCol = snapshot.selection.startCol
		self.text.selection.endLine = snapshot.selection.endLine
		self.text.selection.endCol = snapshot.selection.endCol

		self.scrollY = math.max(snapshot.scrollY or 0, 0)
	end

	function editor:textChanged(oldLines, newLines)
		if #oldLines ~= #newLines then
			return true
		end
		for i = 1, #oldLines do
			if oldLines[i] ~= newLines[i] then
				return true
			end
		end
		return false
	end

	function editor:beginTextEdit()
		if self._pendingEditSnapshot then
			return
		end
		self._pendingEditSnapshot = self:createSnapshot()
	end

	function editor:endTextEdit()
		local snapshot = self._pendingEditSnapshot
		self._pendingEditSnapshot = nil
		self._lastEditChanged = false
		if not snapshot then
			return
		end

		if not self:textChanged(snapshot.lines, self.text.lines) then
			return
		end

		local history = self:getHistoryState(self.text)
		table.insert(history.undoStack, snapshot)
		if #history.undoStack > self.historyLimit then
			table.remove(history.undoStack, 1)
		end
		history.redoStack = {}
		self._lastEditChanged = true
	end

	function editor:undo()
		local history = self:getHistoryState(self.text)
		local snapshot = table.remove(history.undoStack)
		if not snapshot then
			return
		end

		table.insert(history.redoStack, self:createSnapshot())
		self:restoreSnapshot(snapshot)
		self._highlightCache = {}
		autocomplete.indexVariables(self, game)
		autocomplete.updateAutocomplete(self, game)
		self:updateLSP()
	end

	function editor:redo()
		local history = self:getHistoryState(self.text)
		local snapshot = table.remove(history.redoStack)
		if not snapshot then
			return
		end

		table.insert(history.undoStack, self:createSnapshot())
		if #history.undoStack > self.historyLimit then
			table.remove(history.undoStack, 1)
		end
		self:restoreSnapshot(snapshot)
		self._highlightCache = {}
		autocomplete.indexVariables(self, game)
		autocomplete.updateAutocomplete(self, game)
		self:updateLSP()
	end

	function editor:getNextUntitledName()
		local used = {}
		for _, tab in ipairs(self.buffers) do
			used[tab.name] = true
		end

		local index = 1
		while true do
			local name = (index == 1) and "untitled.lua" or ("untitled" .. tostring(index) .. ".lua")
			if not used[name] then
				return name
			end
			index += 1
		end
	end

	function editor:activateBuffer(index)
		local tab = self.buffers[index]
		if not tab then
			return
		end

		self.currentBufferIndex = index
		self.text = tab.buffer
		self.breakpoints = tab.breakpoints
		self:updateBreakpoints()
		self:getHistoryState(self.text)
		self._highlightCache = {}
		self:updateLSP()
	end

	function editor:closeCurrentTab()
		if #self.buffers > 0 then
			self:closeTab(self.currentBufferIndex)
		end
	end

	function editor:openTab(name, content)
		local newBuf = ideBuffer.create()
		if content then
			newBuf:clear()
			newBuf:insertString(content)
			newBuf:setCursor(1, 1)
		end
		local tab = { name = name or "untitled.lua", buffer = newBuf, breakpoints = {} }
		table.insert(self.buffers, tab)
		self:activateBuffer(#self.buffers)
	end

	function editor:updateSearch()
		self.search.results = {}
		if #self.search.query == 0 then
			self.search.currentIndex = 0
			return
		end

		local query = self.search.query:lower()
		for i, line in ipairs(self.text.lines) do
			local startPos = 1
			while true do
				local s, e = line:lower():find(query, startPos, true)
				if not s then
					break
				end
				table.insert(self.search.results, { line = i, col = s, length = #query })
				startPos = e + 1
			end
		end

		if #self.search.results > 0 then
			self.search.currentIndex = 1
		else
			self.search.currentIndex = 0
		end
	end

	function editor:nextSearchResult(size, lineHeight)
		if #self.search.results == 0 then
			return
		end
		self.search.currentIndex = (self.search.currentIndex % #self.search.results) + 1
		local res = self.search.results[self.search.currentIndex]
		self.text:setCursor(res.line, res.col)
		-- Center the view
		if size and lineHeight then
			local visibleLines = math.floor(size.y / lineHeight)
			self.scrollY = math.max(0, (res.line - math.floor(visibleLines / 2)) * lineHeight)
		end
	end

	function editor:doGotoLine(size, lineHeight)
		local lineNum = tonumber(self.gotoLine.query)
		if lineNum then
			lineNum = math.clamp(math.floor(lineNum), 1, #self.text.lines)
			self.text:setCursor(lineNum, 1)
			-- Center the view
			if size and lineHeight then
				local visibleLines = math.floor(size.y / lineHeight)
				self.scrollY = math.max(0, (lineNum - math.floor(visibleLines / 2)) * lineHeight)
			end
		end
		self.gotoLine.active = false
		self.gotoLine.query = ""
	end

	function editor:replaceNext(size, lineHeight)
		if #self.search.results == 0 then
			return
		end
		-- Get current result. The currentIndex points to the "current" highlighted match.
		local res = self.search.results[self.search.currentIndex]
		if not res then
			return
		end

		self:beginTextEdit()

		self.text:setCursor(res.line, res.col)
		self.text.selection.active = true
		self.text.selection.startLine = res.line
		self.text.selection.startCol = res.col
		self.text.selection.endLine = res.line
		self.text.selection.endCol = res.col + res.length

		self.text:insertString(self.replace.query)
		self.text.selection.active = false
		self:endTextEdit()

		self:updateLSP()
		self:updateSearch() -- Re-search to find next matches

		if size and lineHeight then
			self:nextSearchResult(size, lineHeight)
		end
	end

	function editor:replaceAll()
		if #self.search.results == 0 then
			return
		end

		self:beginTextEdit()
		for i = #self.search.results, 1, -1 do
			local res = self.search.results[i]
			local line = self.text.lines[res.line]

			local before = line:sub(1, res.col - 1)
			local after = line:sub(res.col + res.length)
			self.text.lines[res.line] = before .. self.replace.query .. after
		end
		self:endTextEdit()

		self:updateLSP()
		self:updateSearch()
	end

	function editor:findMatchingBracket(line, col)
		local currentLine = self.text.lines[line]
		local char = currentLine:sub(col, col)

		local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}" }
		local reversePairs = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

		if pairs[char] then
			local target = pairs[char]
			local depth = 1
			-- Scan forward
			for l = line, #self.text.lines do
				local ln = self.text.lines[l]
				local start = (l == line) and (col + 1) or 1
				for c = start, #ln do
					local ch = ln:sub(c, c)
					if ch == char then
						depth += 1
					elseif ch == target then
						depth -= 1
						if depth == 0 then
							return l, c
						end
					end
				end
			end
		elseif reversePairs[char] then
			local target = reversePairs[char]
			local depth = 1
			-- Scan backward
			for l = line, 1, -1 do
				local ln = self.text.lines[l]
				local start = (l == line) and (col - 1) or #ln
				for c = start, 1, -1 do
					local ch = ln:sub(c, c)
					if ch == char then
						depth += 1
					elseif ch == target then
						depth -= 1
						if depth == 0 then
							return l, c
						end
					end
				end
			end
		end
		return nil
	end

	function editor:format()
		self:beginTextEdit()

		local openers = { ["then"] = true, ["do"] = true, ["function"] = true, ["repeat"] = true, ["{"] = true }
		local closers = { ["end"] = true, ["until"] = true, ["}"] = true }
		local middle = { ["else"] = true, ["elseif"] = true }
		-- ... (rest of format) ...

		local currentIndent = 0
		local newLines = {}

		for i, line in ipairs(self.text.lines) do
			local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
			if trimmed == "" then
				table.insert(newLines, "")
				continue
			end

			local firstWord = trimmed:match("^([%w_]+)") or trimmed:match("^([%{}])")
			local shouldDedent = closers[firstWord] or middle[firstWord]

			if shouldDedent then
				currentIndent = math.max(0, currentIndent - 1)
			end

			table.insert(newLines, string.rep("\t", currentIndent) .. trimmed)

			local net = 0
			for word in trimmed:gmatch("[%w_{}]+") do
				if openers[word] then
					net += 1
				elseif closers[word] then
					net -= 1
				end
			end

			if middle[firstWord] then
				net += 1
			end

			currentIndent = math.max(0, currentIndent + net)
		end

		self.text.lines = newLines
		self:endTextEdit()
		self._highlightCache = {}
		self:updateLSP()
		self.formatNotificationTimer = 2.0
	end

	function editor:closeTab(index)
		if #self.buffers <= 1 then
			return
		end
		table.remove(self.buffers, index)
		if self.currentBufferIndex > #self.buffers then
			self.currentBufferIndex = #self.buffers
		end
		self:activateBuffer(self.currentBufferIndex)
	end

	function editor:getCode()
		local buf = table.create(#self.text.lines)
		for i, line in ipairs(self.text.lines) do
			buf[i] = line
		end
		return table.concat(buf, "\n")
	end

	function editor:performUpdateLSP()
		local code = self:getCode()
		self.lsp.lastCode = code
		self.lsp.dirty = false

		local parseResult = luau.parse(code)
		self.lsp.errors = {}

		if parseResult.errors and #parseResult.errors > 0 then
			for _, err in ipairs(parseResult.errors) do
				table.insert(self.lsp.errors, {
					message = err.message,
					location = err.location,
				})
			end
		end
	end

	function editor:updateLSP()
		self.lsp.dirty = true
		self.lsp.lastEditTime = os.clock()
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
				editor:activateBuffer(i)
			end

			local closeX = tx + tabWidth - 20
			local closeRect = { x = closeX, y = y + 5, width = 15, height = 15 }
			raylib.DrawTextEx(vend, "x", vector.create(closeX, y + 5), 14, 1, const.GRAY)
			if raylib.IsMouseButtonPressed(0) == 1 and isMouseInRect(closeRect, raylib.GetMousePosition()) then
				editor:closeTab(i)
				return
			end
		end

		local plusX = x + #editor.buffers * tabWidth
		local plusRect = { x = plusX, y = y, width = 30, height = tabHeight }
		raylib.DrawRectangle(plusX, y, 30, tabHeight, theme_background)
		raylib.DrawTextEx(vend, "+", vector.create(plusX + 10, y + 5), 18, 1, const.WHITE)
		if raylib.IsMouseButtonPressed(0) == 1 and isMouseInRect(plusRect, raylib.GetMousePosition()) then
			editor:openTab(editor:getNextUntitledName(), "")
			return
		end

		local minimapWidth = 100
		y = y + tabHeight
		size = vector.create(size.x - minimapWidth, size.y - tabHeight)

		local dt = raylib.GetFrameTime()
		editor.caretTimer = (editor.caretTimer or 0) + dt

		editor.lsp.hoveredError = nil

		if editor.lsp.dirty and (os.clock() - editor.lsp.lastEditTime > editor.lsp.debounceTime) then
			editor:performUpdateLSP()
		end

		editor.caretBlinkRate = editor.caretBlinkRate or 0.5
		if editor.caretTimer >= editor.caretBlinkRate then
			editor.caretVisible = not editor.caretVisible
			editor.caretTimer = editor.caretTimer - editor.caretBlinkRate
		end

		local padding = 20
		local fontSize = editor.fontSize
		local lineHeight = fontSize + 4
		local spacing = 1
		local statusBarHeight = 30

		local contentHeight = #editor.text.lines * lineHeight
		local viewportHeight = size.y - (padding * 2) - statusBarHeight
		editor.maxScroll = math.max(0, contentHeight - viewportHeight)

		local background = rect.new(x, y, size.x, size.y)
		if isMouseInRect({ x = x, y = y, width = size.x, height = size.y }, raylib.GetMousePosition()) then
			local wheel = raylib.GetMouseWheelMove()
			if wheel ~= 0 then
				if
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
				then
					editor.fontSize = math.clamp(editor.fontSize + wheel, 8, 72)

					editor.spaceWidth = raylib.MeasureTextEx(vend, " ", editor.fontSize, spacing).x
					editor.tabWidth = editor.spaceWidth * editor.tabSize
				else
					local scrollSpeed = lineHeight * 3
					editor.scrollY = editor.scrollY - (wheel * scrollSpeed)
					editor.scrollY = math.clamp(editor.scrollY, 0, editor.maxScroll)
				end
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

					raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, Color3.new(0, 0.4, 0.8):ToRaylib(0.5))
				end
			end

			-- Highlight search results
			if editor.search.active and #editor.search.results > 0 then
				for idx, res in ipairs(editor.search.results) do
					if res.line >= firstVisibleLine and res.line <= lastVisibleLine then
						local ly = y + padding + (res.line - 1) * lineHeight - editor.scrollY
						local line = editor.text.lines[res.line]
						local x1 = x
							+ gutterwidth
							+ padding
							+ measureTextWidth(line:sub(1, res.col - 1), fontSize, spacing)
						local x2 = x
							+ gutterwidth
							+ padding
							+ measureTextWidth(line:sub(1, res.col + res.length - 1), fontSize, spacing)

						local isCurrent = (idx == editor.search.currentIndex)
						local color = isCurrent and Color3.new(1, 0.5, 0) or Color3.new(1, 0.8, 0)
						raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, color:ToRaylib(0.4))
					end
				end
			end

			-- Highlight other occurrences of the word under cursor
			if editor.highlightedToken then
				local word = editor.highlightedToken
				local len = #word
				if len > 0 then
					-- We only search in visible range for performance
					for i = firstVisibleLine, lastVisibleLine do
						local line = editor.text.lines[i]
						local startPos = 1
						while true do
							local s, e = line:find(word, startPos, true)
							if not s then
								break
							end

							-- Ensure it's a whole word (simple check)
							local charBefore = s > 1 and line:sub(s - 1, s - 1) or ""
							local charAfter = e < #line and line:sub(e + 1, e + 1) or ""

							-- Basic word boundary check
							if not charBefore:match("[%w_]") and not charAfter:match("[%w_]") then
								local ly = y + padding + (i - 1) * lineHeight - editor.scrollY
								local lineStr = line
								local x1 = x
									+ gutterwidth
									+ padding
									+ measureTextWidth(lineStr:sub(1, s - 1), fontSize, spacing)
								local x2 = x
									+ gutterwidth
									+ padding
									+ measureTextWidth(lineStr:sub(1, e), fontSize, spacing)

								raylib.DrawRectangle(
									x1,
									ly,
									x2 - x1,
									lineHeight,
									Color3.new(0.3, 0.3, 0.3):ToRaylib(0.5)
								)
							end
							startPos = e + 1
						end
					end
				end
			end

			-- Highlight Matching Angle Brackets
			local cursorLine = editor.text.lines[editor.text.cursor.line]
			if cursorLine then
				local cursorCol = editor.text.cursor.col
				local checkCols = { cursorCol - 1, cursorCol }
				local matchFound = nil

				for _, cIdx in ipairs(checkCols) do
					if cIdx >= 1 and cIdx <= #cursorLine then
						local char = cursorLine:sub(cIdx, cIdx)
						local pairs =
							{ ["("] = true, ["["] = true, ["{"] = true, [")"] = true, ["]"] = true, ["}"] = true }
						if pairs[char] then
							local mL, mC = editor:findMatchingBracket(editor.text.cursor.line, cIdx)
							if mL and mC then
								matchFound = { { editor.text.cursor.line, cIdx }, { mL, mC } }
								break
							end
						end
					end
				end

				if matchFound then
					for _, pos in ipairs(matchFound) do
						local l, c = pos[1], pos[2]
						if l >= firstVisibleLine and l <= lastVisibleLine then
							local line = editor.text.lines[l]
							local ly = y + padding + (l - 1) * lineHeight - editor.scrollY
							local x1 = x
								+ gutterwidth
								+ padding
								+ measureTextWidth(line:sub(1, c - 1), fontSize, spacing)
							local w = measureTextWidth(line:sub(c, c), fontSize, spacing)
							raylib.DrawRectangleLines(x1, ly, w, lineHeight, Color3.new(1, 1, 0):ToRaylib(0.8))
						end
					end
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
				raylib.DrawCircle(circleX, yLine + lineHeight / 2, circleRadius, Color3.new(0.8, 0.1, 0.1):ToRaylib(0))
			else
				local mousePos = raylib.GetMousePosition()
				if
					mousePos.x >= x
					and mousePos.x <= x + gutterwidth
					and mousePos.y >= yLine
					and mousePos.y <= yLine + lineHeight
				then
					raylib.DrawCircle(
						circleX,
						yLine + lineHeight / 2,
						circleRadius,
						Color3.new(0.8, 0.1, 0.1):ToRaylib(0.7)
					)
				end
			end

			local startX = x + gutterwidth + padding
			local relX = 0
			local tabStop = editor.tabWidth
			local halfTab = tabStop / 2

			for col = 1, #line do
				local ch = line:sub(col, col)

				if ch == " " then
					relX += editor.spaceWidth
				elseif ch == "\t" then
					relX = math.floor(relX / halfTab + 1) * halfTab
				else
					break
				end

				-- draw at each tab boundary
				if math.abs(relX % tabStop) < 0.01 then
					raylib.DrawRectangle(
						startX + relX - 1,
						yLine,
						2,
						lineHeight,
						structs.Color:new({ r = 255, g = 255, b = 255, a = 40 })
					)
				end
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

			for _, seg in ipairs(tokens) do
				for i = 1, #seg.text do
					local ch = seg.text:sub(i, i)

					if ch == " " then
						xPos += editor.spaceWidth
					elseif ch == "\t" then
						xPos += editor.tabWidth
					else
						raylib.DrawTextEx(vend, ch, vector.create(xPos, yLine), fontSize, spacing, seg.color)
						xPos += raylib.MeasureTextEx(vend, ch, fontSize, spacing).x
					end
				end
			end

			for _, err in ipairs(editor.lsp.errors) do
				if err.location.begin.line == i then
					local startCol = err.location.begin.column
					local endCol = err.location["end"].column
					local errorLine = editor.text.lines[i]

					local beforeStart = errorLine:sub(1, startCol)
					local beforeEnd = errorLine:sub(1, endCol)

					local x1 = x + gutterwidth + padding + measureTextWidth(beforeStart, fontSize, spacing)
					local x2 = x + gutterwidth + padding + measureTextWidth(beforeEnd, fontSize, spacing)

					local underlineY = yLine + lineHeight + 18

					local mousePos = raylib.GetMousePosition()
					local isHovering = mousePos.x >= x1
						and mousePos.x <= x2
						and mousePos.y >= yLine + lineHeight
						and mousePos.y <= yLine + lineHeight * 2

					if isHovering then
						editor.lsp.hoveredError = err
						editor.lsp.hoverX = mousePos.x
						editor.lsp.hoverY = yLine + lineHeight
					end

					local wavyWidth = x2 - x1
					if wavyWidth > 0 then
						local waveCount = math.max(1, math.floor(wavyWidth / 4))
						for w = 0, waveCount do
							local wx1 = x1 + (w * wavyWidth / waveCount)
							local wx2 = x1 + ((w + 0.5) * wavyWidth / waveCount)
							local wy1 = underlineY + ((w % 2 == 0) and 0 or 2)
							local wy2 = underlineY + ((w % 2 == 0) and 2 or 0)

							if wx2 <= x2 then
								raylib.DrawLineEx(
									vector.create(wx1, wy1),
									vector.create(wx2, wy2),
									1.5,
									Color3.new(1, 0.2, 0.2):ToRaylib(0)
								)
							end
						end
					end
				end
			end
		end

		if editor.isActive then
			local byte = raylib.GetCharPressed()
			while byte ~= 0 do
				local char = string.char(byte)
				if editor.search.active and not editor.replace.active then
					editor.search.query = editor.search.query .. char
					editor:updateSearch()
				elseif editor.replace.active then
					editor.replace.query = editor.replace.query .. char
				elseif editor.gotoLine.active then
					if char:match("%d") then
						editor.gotoLine.query = editor.gotoLine.query .. char
					end
				else
					editor:beginTextEdit()
					local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
					local handled = false

					if editor.text.selection.active then
						if pairs[char] then
							local text = editor.text:getSelectedText()
							editor.text:deleteSelection()
							editor.text:insertString(char .. text .. pairs[char])
							handled = true
						else
							editor.text:deleteSelection()
						end
					end

					if not handled then
						editor.text:insertChar(char)

						-- Auto-dedent
						local currentLine = editor.text.lines[editor.text.cursor.line]
						local trimmed = currentLine:match("^[\t ]*(.*)$")
						if trimmed == "end" or trimmed == "}" then
							local indent = currentLine:match("^([\t ]*)")
							if indent:sub(1, 1) == "\t" then
								editor.text.lines[editor.text.cursor.line] = indent:sub(2) .. trimmed
								editor.text.cursor.col = math.max(1, editor.text.cursor.col - 1)
							end
						end

						if pairs[char] then
							editor.text:insertChar(pairs[char])
							editor.text:moveLeft()
						end
					end
					editor:endTextEdit()

					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
					editor._highlightCache = {}
					editor:updateLSP()
				end
				byte = raylib.GetCharPressed()
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

			local word = autocomplete.getCurrentWord(editor)
			if #word > 0 then
				editor.highlightedToken = word

				if
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
				then
					for i, line in ipairs(editor.text.lines) do
						-- Simple pattern matching for definition
						if
							line:match("function%s+" .. word)
							or line:match("local%s+" .. word)
							or line:match("local%s+function%s+" .. word)
						then
							editor.gotoLine.query = tostring(i)
							editor:doGotoLine(size, lineHeight)
							found = true
							break
						end
					end
				end
			else
				editor.highlightedToken = nil
			end
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
			local line = editor.text.lines[c.line]
			local textBeforeCursor = line:sub(1, c.col - 1)

			local cursorX = x + gutterwidth + padding
			if #textBeforeCursor > 0 then
				cursorX = cursorX + measureTextWidth(textBeforeCursor, fontSize, spacing)
			end

			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			if cy >= y and cy < y + size.y then
				raylib.DrawRectangle(cursorX, cy, 2, lineHeight, const.WHITE)
			end
		end

		-- Search/GoTo UI
		if editor.search.active or editor.replace.active then
			local boxW = 250
			local boxH = editor.replace.active and 80 or 40
			local boxX = x + size.x - boxW - 20
			local boxY = y + 10
			raylib.DrawRectangle(boxX, boxY, boxW, boxH, theme_secondary)
			raylib.DrawRectangleLines(boxX, boxY, boxW, boxH, const.WHITE)
			raylib.DrawTextEx(
				vend,
				"Find: " .. editor.search.query,
				vector.create(boxX + 10, boxY + 12),
				fontSize,
				spacing,
				const.WHITE
			)
			if #editor.search.results > 0 then
				local resText = string.format("%d/%d", editor.search.currentIndex, #editor.search.results)
				raylib.DrawTextEx(
					vend,
					resText,
					vector.create(boxX + boxW - 60, boxY + 12),
					fontSize,
					spacing,
					const.DARKGRAY
				)
			end

			if editor.replace.active then
				raylib.DrawTextEx(
					vend,
					"Replace: " .. editor.replace.query,
					vector.create(boxX + 10, boxY + 52),
					fontSize,
					spacing,
					const.WHITE
				)
			end
		elseif editor.gotoLine.active then
			local boxW = 200
			local boxH = 40
			local boxX = x + size.x - boxW - 20
			local boxY = y + 10
			raylib.DrawRectangle(boxX, boxY, boxW, boxH, theme_secondary)
			raylib.DrawRectangleLines(boxX, boxY, boxW, boxH, const.WHITE)
			raylib.DrawTextEx(
				vend,
				"Go to: " .. editor.gotoLine.query,
				vector.create(boxX + 10, boxY + 12),
				fontSize,
				spacing,
				const.WHITE
			)
		end

		local mmBackground = { x = x + size.x, y = y, width = minimapWidth, height = size.y }
		raylib.DrawRectangle(mmBackground.x, mmBackground.y, mmBackground.width, mmBackground.height, theme_secondary)

		local lineCount = #editor.text.lines
		local mmPadding = 5
		local mmUsableHeight = size.y - (mmPadding * 2)
		local mmLineHeight = math.min(2, mmUsableHeight / lineCount)

		for i = 1, lineCount do
			if lineCount > 2000 and (i % 2 ~= 0) then
				continue
			end

			local line = editor.text.lines[i]
			if #line > 0 then
				local ly = y + mmPadding + (i - 1) * mmLineHeight

				local lx = mmBackground.x + 5
				local trimmed = line:match("^%s*(.+)") or ""
				local indent = line:match("^(%s*)") or ""
				local indentLen = #indent

				lx = lx + (indentLen * 2) -- Approximate indent
				local lw = math.min(minimapWidth - 10, #trimmed * 2)

				-- Simple coloring based on first character
				local color = Color3.new(0.6, 0.6, 0.6):ToRaylib(0.5)
				local firstChar = trimmed:sub(1, 1)
				if firstChar == "-" then
					color = Color3.new(0.3, 0.6, 0.3):ToRaylib(0.5)
				elseif firstChar == "l" or firstChar == "f" then
					color = Color3.new(0.3, 0.5, 0.8):ToRaylib(0.5)
				end

				raylib.DrawRectangle(lx, ly, lw, math.max(1, mmLineHeight - 0.5), color)
			end
		end

		-- Minimap Lens
		local lensHeight = math.clamp((viewportHeight / contentHeight) * mmUsableHeight, 0, mmUsableHeight)
		local lensY = y + mmPadding + (editor.scrollY / contentHeight) * mmUsableHeight
		raylib.DrawRectangle(mmBackground.x, lensY, minimapWidth, lensHeight, Color3.new(1, 1, 1):ToRaylib(0.8))

		-- Minimap Interaction
		local mousePos = raylib.GetMousePosition()
		if raylib.IsMouseButtonDown(0) == 1 and isMouseInRect(mmBackground, mousePos) then
			local relY = mousePos.y - (y + mmPadding)
			local percent = math.clamp(relY / mmUsableHeight, 0, 1)
			editor.scrollY = math.clamp(percent * contentHeight - (viewportHeight / 2), 0, editor.maxScroll)
		end

		if editor.formatNotificationTimer > 0 then
			editor.formatNotificationTimer -= dt
			local boxW = 150
			local boxH = 30
			local boxX = x + size.x - boxW - 20
			local boxY = y + size.y - boxH - 20
			raylib.DrawRectangle(boxX, boxY, boxW, boxH, theme_secondary)
			raylib.DrawRectangleLines(boxX, boxY, boxW, boxH, const.WHITE)
			raylib.DrawTextEx(
				vend,
				"Code Formatted",
				vector.create(boxX + 15, boxY + 8),
				fontSize - 2,
				spacing,
				const.GREEN
			)
		end

		-- Status Bar
		local sbY = y + size.y - statusBarHeight
		raylib.DrawRectangle(x, sbY, size.x, statusBarHeight, theme_secondary)
		raylib.DrawLine(x, sbY, x + size.x, sbY, Color3.new(0.2, 0.2, 0.2):ToRaylib(0))

		local cursorText = string.format("Ln %d, Col %d", editor.text.cursor.line, editor.text.cursor.col)
		raylib.DrawTextEx(vend, cursorText, vector.create(x + 10, sbY + 8), 14, 1, const.WHITE)

		local infoText = "UTF-8  Lua"
		local infoWidth = measureTextWidth(infoText, 14, 1)
		raylib.DrawTextEx(vend, infoText, vector.create(x + size.x - infoWidth - 20, sbY + 8), 14, 1, const.WHITE)

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
			Color3.ToRaylib,
			vend,
			spacing,
			theme_text,
			theme_secondary,
			y,
			dt,
			IconLoader
		)

		if editor.lsp.hoveredError then
			local tooltipPadding = 8
			local tooltipText = editor.lsp.hoveredError.message
			local tooltipWidth = measureTextWidth(tooltipText, fontSize - 2, spacing) + tooltipPadding * 2
			local tooltipHeight = lineHeight + tooltipPadding

			local tooltipX = editor.lsp.hoverX
			local tooltipY = editor.lsp.hoverY - tooltipHeight - 5

			if tooltipX + tooltipWidth > x + size.x then
				tooltipX = x + size.x - tooltipWidth
			end
			if tooltipY < y then
				tooltipY = editor.lsp.hoverY + lineHeight + 5
			end

			raylib.DrawRectangle(
				tooltipX,
				tooltipY,
				tooltipWidth,
				tooltipHeight,
				Color3.new(0.30, 0.30, 0.30):ToRaylib(0)
			)
			raylib.DrawRectangleLines(
				tooltipX,
				tooltipY,
				tooltipWidth,
				tooltipHeight,
				Color3.new(1, 0.2, 0.2):ToRaylib(0)
			)
			raylib.DrawTextEx(
				vend,
				tooltipText,
				vector.create(tooltipX + tooltipPadding, tooltipY + tooltipPadding / 2),
				fontSize - 2,
				spacing,
				const.WHITE
			)
		end

		if editor.isActive then
			local ctrlDown = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
				or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
			local shiftDown = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
				or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1
			local altDown = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_ALT) == 1
				or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_ALT) == 1

			local function isWordChar(ch)
				return ch:match("[%w_]") ~= nil
			end

			local function moveWordLeft()
				local c = editor.text.cursor
				local line = editor.text.lines[c.line]
				local idx = c.col - 1

				if idx <= 0 then
					if c.line > 1 then
						c.line -= 1
						c.col = #editor.text.lines[c.line] + 1
					end
					return
				end

				while idx > 0 and line:sub(idx, idx):match("%s") do
					idx -= 1
				end

				if idx > 0 and isWordChar(line:sub(idx, idx)) then
					while idx > 0 and isWordChar(line:sub(idx, idx)) do
						idx -= 1
					end
				else
					while idx > 0 and not line:sub(idx, idx):match("[%w_%s]") do
						idx -= 1
					end
				end

				c.col = idx + 1
			end

			local function moveWordRight()
				local c = editor.text.cursor
				local line = editor.text.lines[c.line]
				local idx = c.col

				if idx > #line then
					if c.line < #editor.text.lines then
						c.line += 1
						c.col = 1
					end
					return
				end

				while idx <= #line and line:sub(idx, idx):match("%s") do
					idx += 1
				end

				if idx <= #line and isWordChar(line:sub(idx, idx)) then
					while idx <= #line and isWordChar(line:sub(idx, idx)) do
						idx += 1
					end
				else
					while idx <= #line and not line:sub(idx, idx):match("[%w_%s]") do
						idx += 1
					end
				end

				c.col = idx
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1 then
				if editor.autocomplete.visible then
					editor:beginTextEdit()
					autocomplete.completeWord(editor)
					editor:endTextEdit()
					editor._highlightCache = {}
					editor:updateLSP()
				elseif editor.snippet and editor.snippet.active then
					editor:beginTextEdit()
					autocomplete.cycleSnippet(editor)
					editor:endTextEdit()
					editor._highlightCache = {}
					editor:updateLSP()
				else
					editor:beginTextEdit()
					editor.text:insertChar("\t")
					editor:endTextEdit()
					editor._highlightCache = {}
					editor:updateLSP()
				end
			end

			if ctrlDown and raylib.IsKeyPressed(const.KeyboardKey.KEY_Z) == 1 then
				if shiftDown then
					editor:redo()
				else
					editor:undo()
				end
			elseif ctrlDown and raylib.IsKeyPressed(const.KeyboardKey.KEY_Y) == 1 then
				editor:redo()
			end

			if ctrlDown and raylib.IsKeyPressed(const.KeyboardKey.KEY_N) == 1 then
				editor:openTab(editor:getNextUntitledName(), "")
			end

			if ctrlDown and raylib.IsKeyPressed(const.KeyboardKey.KEY_W) == 1 then
				editor:closeCurrentTab()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				if editor.search.active and not editor.replace.active then
					editor:nextSearchResult(size, lineHeight)
				elseif editor.replace.active then
					editor:beginTextEdit()
					if
						raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
						or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1
					then
						editor:replaceAll()
					else
						editor:replaceNext(size, lineHeight)
					end
					editor:endTextEdit()
				elseif editor.gotoLine.active then
					editor:doGotoLine(size, lineHeight)
				elseif editor.autocomplete.visible then
					editor:beginTextEdit()
					autocomplete.indexVariables(editor, game)
					autocomplete.completeWord(editor)
					editor:endTextEdit()
					editor._highlightCache = {}
					editor:updateLSP()
				else
					editor:beginTextEdit()
					if editor.text.selection.active then
						editor.text:deleteSelection()
					end

					local currentLine = editor.text.lines[editor.text.cursor.line]
					local indent = currentLine:match("^[\t ]*")

					-- Check for block start
					local blockStarts = { "then", "do", "function", "repeat", "{" }
					local isBlockStart = false
					local trimmed = currentLine:gsub("%s*$", "")
					for _, starter in ipairs(blockStarts) do
						if
							trimmed:match("%s" .. starter .. "$")
							or trimmed == starter
							or (starter == "{" and trimmed:match("{$"))
						then
							isBlockStart = true
							break
						end
					end

					editor.text:newline()
					editor.text:insertString(indent)
					if isBlockStart then
						editor.text:insertString("\t")
					end
					editor:endTextEdit()

					autocomplete.indexVariables(editor, game)
					editor._highlightCache = {}
					editor:updateLSP()
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				if editor.search.active then
					editor.search.active = false
				elseif editor.gotoLine.active then
					editor.gotoLine.active = false
				elseif editor.autocomplete.visible then
					editor.autocomplete.visible = false
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				if editor.replace.active then
					editor.replace.query = editor.replace.query:sub(1, -2)
				elseif editor.search.active then
					editor.search.query = editor.search.query:sub(1, -2)
					editor:updateSearch()
				elseif editor.gotoLine.active then
					editor.gotoLine.query = editor.gotoLine.query:sub(1, -2)
				else
					editor:beginTextEdit()
					if ctrlDown and not editor.text.selection.active then
						local oldLine = editor.text.cursor.line
						local oldCol = editor.text.cursor.col
						moveWordLeft()
						local newLine = editor.text.cursor.line
						local newCol = editor.text.cursor.col

						if oldLine ~= newLine or oldCol ~= newCol then
							editor.text.selection.active = true
							editor.text.selection.startLine = newLine
							editor.text.selection.startCol = newCol
							editor.text.selection.endLine = oldLine
							editor.text.selection.endCol = oldCol
							editor.text:deleteSelection()
						end
					elseif editor.text.selection.active then
						editor.text:deleteSelection()
					else
						editor.text:backspace()
					end
					editor:endTextEdit()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
					editor._highlightCache = {}
					editor:updateLSP()
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_DELETE) == 1 then
				if not editor.search.active and not editor.gotoLine.active then
					editor:beginTextEdit()
					if ctrlDown and not editor.text.selection.active then
						local oldLine = editor.text.cursor.line
						local oldCol = editor.text.cursor.col
						moveWordRight()
						local newLine = editor.text.cursor.line
						local newCol = editor.text.cursor.col

						editor.text.selection.active = true
						editor.text.selection.startLine = oldLine
						editor.text.selection.startCol = oldCol
						editor.text.selection.endLine = newLine
						editor.text.selection.endCol = newCol
						editor.text:deleteSelection()
					elseif editor.text.selection.active then
						editor.text:deleteSelection()
					else
						editor.text:delete()
					end
					editor:endTextEdit()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
					editor._highlightCache = {}
					editor:updateLSP()
				end
			end

			-- Arrow key handling
			local shift = shiftDown

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

			-- Handle arrow keys: autocomplete navigation (UP/DOWN) and cursor movement (LEFT/RIGHT/UP/DOWN)
			if editor.autocomplete.visible then
				-- UP/DOWN navigates autocomplete selection
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.autocomplete.selectedIndex =
						math.min(editor.autocomplete.selectedIndex + 1, #editor.autocomplete.items)
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.autocomplete.selectedIndex = math.max(editor.autocomplete.selectedIndex - 1, 1)
				end
				-- LEFT/RIGHT moves cursor while autocomplete is visible
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
					if ctrlDown then
						moveWordLeft()
					else
						editor.text:moveLeft()
					end
					updateSelection()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
					if ctrlDown then
						moveWordRight()
					else
						editor.text:moveRight()
					end
					updateSelection()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
				end
			else
				-- No autocomplete: handle all cursor movement
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
					if ctrlDown then
						moveWordLeft()
					else
						editor.text:moveLeft()
					end
					updateSelection()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
					if ctrlDown then
						moveWordRight()
					else
						editor.text:moveRight()
					end
					updateSelection()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					if altDown then
						editor:beginTextEdit()
						editor.text:moveLineUp()
						editor:endTextEdit()
						editor._highlightCache = {}
						editor:updateLSP()
					else
						editor.text:moveUp()
						updateSelection()
						autocomplete.indexVariables(editor, game)
						autocomplete.updateAutocomplete(editor, game)
					end
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					if altDown then
						editor:beginTextEdit()
						editor.text:moveLineDown()
						editor:endTextEdit()
						editor._highlightCache = {}
						editor:updateLSP()
					else
						editor.text:moveDown()
						updateSelection()
						autocomplete.indexVariables(editor, game)
						autocomplete.updateAutocomplete(editor, game)
					end
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_HOME) == 1 then
				local currentLine = editor.text.lines[editor.text.cursor.line]
				local indent = currentLine:match("^(%s*)")
				local targetCol = #indent + 1
				if editor.text.cursor.col == targetCol then
					editor.text.cursor.col = 1
				else
					editor.text.cursor.col = targetCol
				end
				updateSelection()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_END) == 1 then
				editor.text.cursor.col = #editor.text.lines[editor.text.cursor.line] + 1
				updateSelection()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_PAGE_UP) == 1 then
				local visibleLines = math.floor(viewportHeight / lineHeight)
				editor.text.cursor.line = math.max(1, editor.text.cursor.line - visibleLines)
				editor.scrollY = math.max(0, editor.scrollY - visibleLines * lineHeight)
				updateSelection()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_PAGE_DOWN) == 1 then
				local visibleLines = math.floor(viewportHeight / lineHeight)
				editor.text.cursor.line = math.min(#editor.text.lines, editor.text.cursor.line + visibleLines)
				editor.scrollY = math.min(editor.maxScroll, editor.scrollY + visibleLines * lineHeight)
				updateSelection()
			end

			if
				raylib.IsKeyPressed(const.KeyboardKey.KEY_SLASH) == 1
				and (
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
				)
			then
				editor:beginTextEdit()
				editor.text:toggleLineComment("--")
				editor:endTextEdit()
				editor._highlightCache = {}
				editor:updateLSP()
			end

			-- Ctrl+Shift+K (Delete Line)
			if
				raylib.IsKeyPressed(const.KeyboardKey.KEY_K) == 1
				and (raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1 or raylib.IsKeyDown(
					const.KeyboardKey.KEY_RIGHT_CONTROL
				) == 1)
				and (
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1
				)
			then
				editor:beginTextEdit()
				editor.text:deleteCurrentLine()
				editor:endTextEdit()
				editor._highlightCache = {}
				editor:updateLSP()
			end

			-- Ctrl+D (Duplicate)
			if
				raylib.IsKeyPressed(const.KeyboardKey.KEY_D) == 1
				and (
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
				)
			then
				editor:beginTextEdit()
				editor.text:duplicateLine()
				editor:endTextEdit()
				editor._highlightCache = {}
				editor:updateLSP()
			end

			if ctrlDown then
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_C) == 1 then
					local text = editor.text:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
					end
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_V) == 1 then
					editor:beginTextEdit()
					if editor.text.selection.active then
						editor.text:deleteSelection()
					end
					local text = raylib.GetClipboardText()
					local bufferLength = buffer.len(text:span())
					local data = buffer.readstring(text:span(), 0, bufferLength - 1)

					data = sanitizeText(data)
					data = string.gsub(data, "\r\n", "\n")
					data = string.gsub(data, "\r", "\n")

					editor.text:insertString(data)
					editor:endTextEdit()
					autocomplete.indexVariables(editor, game)
					autocomplete.updateAutocomplete(editor, game)
					editor._highlightCache = {}
					editor:updateLSP()
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_X) == 1 then
					local text = editor.text:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
						editor:beginTextEdit()
						editor.text:deleteSelection()
						editor:endTextEdit()
						editor._highlightCache = {}
						editor:updateLSP()
					end
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_A) == 1 then
					editor.text.selection.active = true
					editor.text.selection.startLine = 1
					editor.text.selection.startCol = 1
					editor.text.selection.endLine = #editor.text.lines
					editor.text.selection.endCol = #editor.text.lines[#editor.text.lines] + 1
					editor.text:setCursor(#editor.text.lines, #editor.text.lines[#editor.text.lines] + 1)
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_S) == 1 then
					editor:format()
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_F) == 1 then
					editor.search.active = not editor.search.active
					if editor.search.active then
						editor.gotoLine.active = false
						editor.search.query = editor.text:getSelectedText():gsub("\n", "")
						editor:updateSearch()
					end
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_G) == 1 then
					editor.gotoLine.active = not editor.gotoLine.active
					if editor.gotoLine.active then
						editor.search.active = false
						editor.gotoLine.query = ""
					end
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_H) == 1 then
					editor.replace.active = not editor.replace.active
					if editor.replace.active then
						editor.search.active = true
						editor.gotoLine.active = false
						editor.replace.query = ""
						local sel = editor.text:getSelectedText()
						if #sel > 0 then
							editor.search.query = sel:gsub("\n", "")
							editor:updateSearch()
						end
					end
				end
			end
		end
	end

	return editor
end
