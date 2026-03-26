local rl = require("@raylib")
local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local Color3 = require("@Color3")

local structs = rl.structs
local const = rl.const

return function(raylib: typeof(rl.lib), theme, aereon, game)
	local rect = aereon.rect()
	local TextBox = {}
	TextBox.__index = TextBox

	local KinemiumFontService = game:GetService("KinemiumFontService")
	local vend = KinemiumFontService.GetDefaultFont()

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

	local function getAutocompleteItemText(item)
		if type(item) == "string" then
			return item
		end
		if type(item) ~= "table" then
			return nil
		end
		return item.text or item.label or item.insertText
	end

	local function normalizeAutocompleteItem(item)
		if type(item) == "string" then
			return {
				label = item,
				text = item,
				type = "value",
				icon = "Variable.png",
			}
		end

		if type(item) ~= "table" then
			return nil
		end

		local text = item.text or item.label or item.insertText
		if type(text) ~= "string" or #text == 0 then
			return nil
		end

		item.label = item.label or text
		item.text = item.text or text
		item.type = item.type or "value"
		item.icon = item.icon or "Variable.png"

		return item
	end

	local function normalizeAutocompleteItems(items)
		local normalized = {}
		if type(items) ~= "table" then
			return normalized
		end
		for _, item in ipairs(items) do
			local normalizedItem = normalizeAutocompleteItem(item)
			if normalizedItem then
				table.insert(normalized, normalizedItem)
			end
		end
		return normalized
	end

	local NullIconLoader = {
		Get = function()
			return nil
		end,
		ToTexture = function()
			return nil
		end,
	}

	-- Default context menu items
	local function getDefaultContextMenuItems()
		return {
			{
				label = "Cut",
				shortcut = "Ctrl+X",
				action = function(self)
					local text = self:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
						self:saveHistory()
						self.buffer:deleteSelection()
						if self.onChange then
							self.onChange(self:getText())
						end
						self:validate()
					end
				end,
			},
			{
				label = "Copy",
				shortcut = "Ctrl+C",
				action = function(self)
					local text = self:getSelectedText()
					if #text > 0 then
						raylib.SetClipboardText(text)
					end
				end,
			},
			{
				label = "Paste",
				shortcut = "Ctrl+V",
				action = function(self)
					local text = raylib.GetClipboardText()
					if text and #text > 0 then
						self:saveHistory()
						if self.buffer.selection.active then
							self.buffer:deleteSelection()
						end
						self.buffer:insertString(text)
						if self.onChange then
							self.onChange(self:getText())
						end
						self:validate()
						self:updateAutocomplete()
					end
				end,
			},
			{
				label = "Select All",
				shortcut = "Ctrl+A",
				action = function(self)
					self:selectAll()
				end,
			},
			{ type = "separator" },
			{
				label = "Find...",
				shortcut = "Ctrl+F",
				action = function(self)
					self.search.active = true
					self.search.query = ""
				end,
			},
			{
				label = "Replace...",
				shortcut = "Ctrl+H",
				action = function(self)
					self.replace.active = true
					self.search.active = true
					self.replace.query = ""
				end,
			},
		}
	end

	-- Constructor
	function TextBox.new(config)
		config = config or {}

		local self = setmetatable({}, TextBox)

		-- Appearance
		self.BackgroundTransparency = config.BackgroundTransparency or 0
		self.BorderTransparency = config.BorderTransparency or 0
		self.TextColor = config.TextColor

		-- Configuration
		self.multiline = false
		self.placeholder = config.placeholder or ""
		self.fontSize = config.fontSize or 16
		self.padding = config.padding or 5
		self.showLineNumbers = config.showLineNumbers and self.multiline
		self.readOnly = config.readOnly or false
		self.maxLength = config.maxLength
		self.autoPairs = config.autoPairs ~= false -- default true
		self.scrollable = config.scrollable ~= false and self.multiline
		self.wordWrap = config.wordWrap or false
		self.mask = config.mask -- e.g., "*" for password fields
		self.allowedChars = config.allowedChars -- regex pattern or function
		self.validator = config.validator -- function(text) -> bool, errorMessage
		self.showCharCount = config.showCharCount or false
		self.showLineCount = config.showLineCount or false
		self.tabSize = config.tabSize or 4
		self.lineHighlight = config.lineHighlight ~= false
		self.matchBrackets = config.matchBrackets or false
		self.autoIndent = config.autoIndent or false
		self.trimWhitespace = config.trimWhitespace or false
		self.selectAllOnFocus = config.selectAllOnFocus or false
		self.submitOnCtrlEnter = config.submitOnCtrlEnter or false
		self.blurOnSubmit = config.blurOnSubmit or true
		self.clearOnEscape = config.clearOnEscape or false
		self.escapeBlurs = config.escapeBlurs or false
		self.syntaxHighlighter = config.syntaxHighlighter -- function(line) -> tokens[]
		self.autocompleteProvider = config.autocompleteProvider -- function(text, cursorPos) -> suggestions[] or autocomplete module table
		self.useProviderAutocompleteUI = config.useProviderAutocompleteUI ~= false
		self.contextMenu = config.contextMenu ~= false
		self.doubleClickSelect = config.doubleClickSelect ~= false
		self.tripleClickSelect = config.tripleClickSelect ~= false
		self.cornerRadius = math.clamp(config.cornerRadius or 0, 0, 1)
		self.cornerSegments = math.max(config.cornerSegments or 8, 2)
		self.popupCornerRadius = math.clamp(config.popupCornerRadius or 0.12, 0, 1)
		self.borderWidth = config.borderWidth or 1
		self.focusBorderWidth = config.focusBorderWidth or self.borderWidth
		self.dropShadow = config.dropShadow or false
		self.shadowOffset = config.shadowOffset or 2
		self.shadowTransparency = config.shadowTransparency or 0.7
		self.label = config.label -- Text to display as label
		self.labelPosition = config.labelPosition or "left" -- "left", "top", "right"
		self.labelWidth = config.labelWidth or 60
		self.labelGap = config.labelGap or 10
		self.prefix = config.prefix -- Text before input (e.g., "x", "$", "#")
		self.suffix = config.suffix -- Text after input (e.g., "m", "px", "°", "%")
		self.prefixGap = config.prefixGap or 5
		self.labelOutlineColor = config.labelOutlineColor or Color3.new(1, 0, 0)
		self.suffixGap = config.suffixGap or 5
		self.numeric = config.numeric or false -- Enable numeric mode
		self.numericMin = config.numericMin
		self.numericMax = config.numericMax
		self.numericStep = config.numericStep or 1
		self.numericPrecision = config.numericPrecision -- Decimal places
		self.showStepButtons = config.showStepButtons or false
		self.stepButtonWidth = config.stepButtonWidth or 20
		self.slider = config.slider or false -- Enable slider
		self.sliderWidth = config.sliderWidth or 100
		self.sliderMin = config.sliderMin or 0
		self.sliderMax = config.sliderMax or 100
		self.sliderStep = config.sliderStep or 1
		self.sliderPosition = config.sliderPosition or "right" -- "left", "right", "bottom"
		self.sliderGap = config.sliderGap or 10
		self.enableMinimap = config.enableMinimap or false -- Show minimap for large files
		self.minimapWidth = config.minimapWidth or 80
		self.enableScrollbar = config.enableScrollbar or true -- Show scrollbar
		self.scrollbarWidth = config.scrollbarWidth or 10
		self.enableAnimatedFocus = config.enableAnimatedFocus or true -- Animated focus ring
		self.focusRingSpeed = config.focusRingSpeed or 8
		self.enableHyperlinks = config.enableHyperlinks or false -- Detect and highlight URLs
		self.hyperlinkColor = config.hyperlinkColor or Color3.new(0.3, 0.5, 1)
		self.enableDragDrop = config.enableDragDrop or true -- Enable drag and drop text
		self.enableColumnSelection = config.enableColumnSelection or true -- Alt+click for column selection
		self.virtualTextCutoff = config.virtualTextCutoff or 2000 -- Max characters per line before truncation in display
		self.customContextMenu = config.customContextMenu -- Custom context menu items

		-- Key repeat acceleration config
		self.keyRepeatConfig = {
			initialDelay = config.keyRepeatInitialDelay or 0.5, -- seconds before acceleration starts
			minInterval = config.keyRepeatMinInterval or 0.02, -- fastest repeat interval
			acceleration = config.keyRepeatAcceleration or 0.85, -- multiply interval by this each repeat
		}

		-- Slider state
		self.sliderDragging = false
		self.sliderValue = config.defaultValue or config.sliderMin or 0

		-- Theme
		local default_theme = theme.ide
			or {
				BackgroundColor = Color3.new(0.07, 0.07, 0.07),
				TextColor = Color3.new(1, 1, 1),
				PlaceholderColor = Color3.new(0.5, 0.5, 0.5),
				SelectionColor = Color3.new(0, 0.4, 0.8),
				BorderColor = Color3.new(0.3, 0.3, 0.3),
				currentLineColor = Color3.new(0.1, 0.1, 0.1),
				ErrorColor = Color3.new(1, 0.2, 0.2),
				MatchBracketColor = Color3.new(1, 1, 0),
				SearchHighlightColor = Color3.new(1, 0.8, 0),
			}

		self.theme = {
			background = (config.backgroundColor or default_theme.BackgroundColor):ToRaylib(
				self.BackgroundTransparency
			),
			text = (config.textColor or default_theme.TextColor):ToRaylib(0),
			placeholder = (config.placeholderColor or default_theme.PlaceholderColor):ToRaylib(0),
			selection = (config.selectionColor or default_theme.SelectionColor):ToRaylib(0.5),
			border = (config.borderColor or default_theme.BorderColor):ToRaylib(self.BorderTransparency),
			focusBorder = (config.focusBorderColor or Color3.new(0.4, 0.6, 1)):ToRaylib(self.BorderTransparency),
			currentLine = (config.currentLineColor or default_theme.currentLineColor):ToRaylib(0),
			error = (config.errorColor or default_theme.ErrorColor):ToRaylib(0),
			matchBracket = (config.matchBracketColor or default_theme.MatchBracketColor):ToRaylib(0.8),
			searchHighlight = (config.searchHighlightColor or default_theme.SearchHighlightColor):ToRaylib(0.4),
			gutterBackground = (config.gutterBackgroundColor or Color3.new(0.05, 0.05, 0.05)):ToRaylib(0),
			statusBarBackground = (config.statusBarBackgroundColor or Color3.new(0.05, 0.05, 0.05)):ToRaylib(0),
			popupBackground = (config.popupBackgroundColor or Color3.new(0.1, 0.1, 0.1)):ToRaylib(0),
			shadow = (config.shadowColor or Color3.new(0, 0, 0)):ToRaylib(self.shadowTransparency),
			-- New theme colors
			hyperlink = (config.hyperlinkColor or Color3.new(0.3, 0.5, 1)):ToRaylib(0),
			scrollbar = (config.scrollbarColor or Color3.new(0.3, 0.3, 0.3)):ToRaylib(0),
			scrollbarHover = (config.scrollbarHoverColor or Color3.new(0.4, 0.4, 0.4)):ToRaylib(0),
			minimapBackground = (config.minimapBackgroundColor or Color3.new(0.05, 0.05, 0.05)):ToRaylib(0),
			minimapSelection = (config.minimapSelectionColor or Color3.new(0.2, 0.4, 0.8)):ToRaylib(0.5),
		}
		self.autocompleteTheme = config.autocompleteTheme or default_theme.autocomplete or {}

		-- New state for additional features
		self.columnSelection = { active = false, startLine = 0, startCol = 0, endLine = 0, endCol = 0 }
		self.dragState = { isDragging = false, startPos = nil, dragText = "" }
		self.incSearch = { active = false, query = "" }
		self.imeState = { active = false, composition = "", startPos = 0 }
		self.ctxMenu = { visible = false, x = 0, y = 0, items = {} }
		self.minimapState = { scrollX = 0 }
		self.virtualTextState = { enabled = true, cutoff = self.virtualTextCutoff }
		self.focusRingAnim = { progress = 0, target = 0, speed = self.focusRingSpeed }
		self.scrollbarState = { visible = false, dragging = false, hoverY = 0 }

		-- Accelerated key repeat state
		self.keyRepeat = {
			lastBackspaceTime = 0,
			lastDeleteTime = 0,
			backspaceCount = 0,
			deleteCount = 0,
			initialDelay = self.keyRepeatConfig.initialDelay,
			minInterval = self.keyRepeatConfig.minInterval,
			acceleration = self.keyRepeatConfig.acceleration,
		}

		-- Performance cache
		self.textCache = {}
		self.cacheDirty = true
		self.lineWidthCache = {}
		self.hyperlinkCache = {}

		-- State
		self.buffer = ideBuffer.create()
		self.buffer.lines = { "" }
		self.isActive = false
		self.isFocused = false
		self.caretVisible = true
		self.caretTimer = 0
		self.caretBlinkRate = 0.5
		self.scrollY = 0
		self.scrollX = 0
		self.maxScroll = 0
		self.validationError = nil

		-- History for undo/redo
		self.history = { { lines = { "" }, cursor = { line = 1, col = 1 } } }
		self.historyIndex = 1
		self.maxHistory = config.maxHistory or 100

		-- Search/Replace
		self.search = {
			active = false,
			query = "",
			caseSensitive = false,
			wholeWord = false,
			regex = false,
			results = {},
			currentIndex = 0,
		}

		self.replace = {
			active = false,
			query = "",
		}

		-- Autocomplete
		self.autocomplete = {
			visible = false,
			items = {},
			selectedIndex = 1,
			x = 0,
			y = 0,
			currentX = 0,
			currentY = 0,
			targetX = 0,
			targetY = 0,
			lerpSpeed = 35,
		}
		local okIconLoader, iconLoader = pcall(function()
			return game:GetService("KinemiumIconLoader")
		end)
		self.iconLoader = okIconLoader and iconLoader or NullIconLoader

		-- Click tracking for double/triple click
		self.lastClickTime = 0
		self.clickCount = 0
		self.lastClickPos = { line = 0, col = 0 }

		-- Matched brackets
		self.matchedBrackets = nil

		-- Callbacks
		self.onChange = config.onChange
		self.onSubmit = config.onSubmit
		self.onFocus = config.onFocus
		self.onBlur = config.onBlur
		self.onValidationError = config.onValidationError
		self.onSearch = config.onSearch

		return self
	end

	-- History management
	function TextBox:saveHistory()
		-- Deep copy current state
		local state = {
			lines = {},
			cursor = {
				line = self.buffer.cursor.line,
				col = self.buffer.cursor.col,
			},
		}

		for i, line in ipairs(self.buffer.lines) do
			state.lines[i] = line
		end

		while #self.history > self.historyIndex do
			table.remove(self.history)
		end

		table.insert(self.history, state)
		self.historyIndex = #self.history

		while #self.history > self.maxHistory do
			table.remove(self.history, 1)
			self.historyIndex -= 1
		end
	end

	function TextBox:undo()
		if self.historyIndex > 1 then
			self.historyIndex -= 1
			local state = self.history[self.historyIndex]

			self.buffer.lines = {}
			for i, line in ipairs(state.lines) do
				self.buffer.lines[i] = line
			end

			self.buffer.cursor.line = state.cursor.line
			self.buffer.cursor.col = state.cursor.col

			if self.onChange then
				self.onChange(self:getText())
			end
		end
	end

	function TextBox:redo()
		if self.historyIndex < #self.history then
			self.historyIndex += 1
			local state = self.history[self.historyIndex]

			self.buffer.lines = {}
			for i, line in ipairs(state.lines) do
				self.buffer.lines[i] = line
			end

			self.buffer.cursor.line = state.cursor.line
			self.buffer.cursor.col = state.cursor.col

			if self.onChange then
				self.onChange(self:getText())
			end
		end
	end

	-- Search functionality
	function TextBox:updateSearch()
		self.search.results = {}
		if #self.search.query == 0 then
			self.search.currentIndex = 0
			return
		end

		local query = self.search.query
		if not self.search.caseSensitive then
			query = query:lower()
		end

		for i, line in ipairs(self.buffer.lines) do
			local searchLine = self.search.caseSensitive and line or line:lower()
			local startPos = 1

			while true do
				local s, e

				if self.search.regex then
					s, e = searchLine:find(query, startPos)
				else
					s, e = searchLine:find(query, startPos, true)
				end

				if not s then
					break
				end

				-- Check whole word if needed
				local isWholeWord = true
				if self.search.wholeWord then
					local before = s > 1 and line:sub(s - 1, s - 1) or ""
					local after = e < #line and line:sub(e + 1, e + 1) or ""
					if before:match("[%w_]") or after:match("[%w_]") then
						isWholeWord = false
					end
				end

				if isWholeWord then
					table.insert(self.search.results, { line = i, col = s, length = e - s + 1 })
				end

				startPos = e + 1
			end
		end

		if #self.search.results > 0 then
			self.search.currentIndex = 1
		else
			self.search.currentIndex = 0
		end

		if self.onSearch then
			self.onSearch(self.search.query, #self.search.results)
		end
	end

	function TextBox:nextSearchResult()
		if #self.search.results == 0 then
			return
		end
		self.search.currentIndex = (self.search.currentIndex % #self.search.results) + 1
		local res = self.search.results[self.search.currentIndex]
		self.buffer:setCursor(res.line, res.col)
	end

	function TextBox:previousSearchResult()
		if #self.search.results == 0 then
			return
		end
		self.search.currentIndex -= 1
		if self.search.currentIndex < 1 then
			self.search.currentIndex = #self.search.results
		end
		local res = self.search.results[self.search.currentIndex]
		self.buffer:setCursor(res.line, res.col)
	end

	function TextBox:replaceNext()
		if #self.search.results == 0 then
			return
		end

		local res = self.search.results[self.search.currentIndex]
		if not res then
			return
		end

		self.buffer:setCursor(res.line, res.col)
		self.buffer.selection.active = true
		self.buffer.selection.startLine = res.line
		self.buffer.selection.startCol = res.col
		self.buffer.selection.endLine = res.line
		self.buffer.selection.endCol = res.col + res.length

		self:saveHistory()
		self.buffer:insertString(self.replace.query)
		self.buffer.selection.active = false

		if self.onChange then
			self.onChange(self:getText())
		end

		self:updateSearch()
		if #self.search.results > 0 then
			self:nextSearchResult()
		end
	end

	function TextBox:replaceAll()
		if #self.search.results == 0 then
			return
		end

		self:saveHistory()

		for i = #self.search.results, 1, -1 do
			local res = self.search.results[i]
			local line = self.buffer.lines[res.line]
			local before = line:sub(1, res.col - 1)
			local after = line:sub(res.col + res.length)
			self.buffer.lines[res.line] = before .. self.replace.query .. after
		end

		if self.onChange then
			self.onChange(self:getText())
		end

		self:updateSearch()
	end

	-- Bracket matching
	function TextBox:findMatchingBracket(line, col)
		local currentLine = self.buffer.lines[line]
		local char = currentLine:sub(col, col)

		local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}" }
		local reversePairs = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

		if pairs[char] then
			local target = pairs[char]
			local depth = 1
			for l = line, #self.buffer.lines do
				local ln = self.buffer.lines[l]
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
			for l = line, 1, -1 do
				local ln = self.buffer.lines[l]
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

	-- Validation
	function TextBox:validate()
		if not self.validator then
			self.validationError = nil
			return true
		end

		local isValid, errorMessage = self.validator(self:getText())
		self.validationError = isValid and nil or errorMessage

		if not isValid and self.onValidationError then
			self.onValidationError(errorMessage)
		end

		return isValid
	end

	-- Autocomplete
	function TextBox:updateAutocomplete()
		if not self.autocompleteProvider then
			self.autocomplete.visible = false
			return
		end

		local text = self:getText()
		local cursorPos = self:getCursorPosition()
		local provider = self.autocompleteProvider
		local suggestions

		if type(provider) == "function" then
			local ok, result = pcall(provider, text, cursorPos, self)
			if not ok then
				self.autocomplete.visible = false
				return
			end
			suggestions = result
		elseif type(provider) == "table" then
			if type(provider.updateAutocomplete) == "function" then
				local editorAdapter = {
					text = self.buffer,
					autocomplete = self.autocomplete,
				}
				if type(provider.indexVariables) == "function" then
					pcall(provider.indexVariables, editorAdapter, game)
				end
				local ok = pcall(provider.updateAutocomplete, editorAdapter, game)
				if ok then
					self.autocomplete.items = normalizeAutocompleteItems(self.autocomplete.items)
					if self.autocomplete.visible and #self.autocomplete.items > 0 then
						self.autocomplete.selectedIndex =
							math.clamp(self.autocomplete.selectedIndex, 1, #self.autocomplete.items)
					else
						self.autocomplete.visible = false
					end
				else
					self.autocomplete.visible = false
				end
				return
			elseif type(provider.getSuggestions) == "function" then
				local ok, result = pcall(provider.getSuggestions, text, cursorPos, self)
				if not ok then
					self.autocomplete.visible = false
					return
				end
				suggestions = result
			else
				self.autocomplete.visible = false
				return
			end
		else
			self.autocomplete.visible = false
			return
		end

		suggestions = normalizeAutocompleteItems(suggestions)
		if suggestions and #suggestions > 0 then
			self.autocomplete.items = suggestions
			self.autocomplete.visible = true
			self.autocomplete.selectedIndex = 1
		else
			self.autocomplete.visible = false
		end
	end

	function TextBox:completeAutocomplete()
		if not self.autocomplete.visible or #self.autocomplete.items == 0 then
			return
		end

		local selected = self.autocomplete.items[self.autocomplete.selectedIndex]
		if selected then
			-- Find word start
			local line = self.buffer.lines[self.buffer.cursor.line]
			local col = self.buffer.cursor.col
			local wordStart = col

			while wordStart > 1 do
				local char = line:sub(wordStart - 1, wordStart - 1)
				if not char:match("[%w_]") then
					break
				end
				wordStart -= 1
			end

			-- Delete current word and insert completion
			self.buffer.cursor.col = wordStart
			for i = wordStart, col - 1 do
				self.buffer:delete()
			end

			local insertText = getAutocompleteItemText(selected)
			if not insertText then
				self.autocomplete.visible = false
				return
			end
			self:saveHistory()
			self.buffer:insertString(insertText)

			if self.onChange then
				self.onChange(self:getText())
			end
		end

		self.autocomplete.visible = false
	end

	-- Line operations
	function TextBox:duplicateLine()
		if not self.multiline then
			return
		end

		local line = self.buffer.lines[self.buffer.cursor.line]
		self:saveHistory()
		table.insert(self.buffer.lines, self.buffer.cursor.line + 1, line)
		self.buffer.cursor.line += 1

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:deleteLine()
		if not self.multiline or #self.buffer.lines <= 1 then
			return
		end

		self:saveHistory()
		table.remove(self.buffer.lines, self.buffer.cursor.line)
		self.buffer.cursor.line = math.min(self.buffer.cursor.line, #self.buffer.lines)
		self.buffer.cursor.col = math.min(self.buffer.cursor.col, #self.buffer.lines[self.buffer.cursor.line] + 1)

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:moveLineUp()
		if not self.multiline or self.buffer.cursor.line <= 1 then
			return
		end

		self:saveHistory()
		local currentLine = self.buffer.lines[self.buffer.cursor.line]
		self.buffer.lines[self.buffer.cursor.line] = self.buffer.lines[self.buffer.cursor.line - 1]
		self.buffer.lines[self.buffer.cursor.line - 1] = currentLine
		self.buffer.cursor.line -= 1

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:moveLineDown()
		if not self.multiline or self.buffer.cursor.line >= #self.buffer.lines then
			return
		end

		self:saveHistory()
		local currentLine = self.buffer.lines[self.buffer.cursor.line]
		self.buffer.lines[self.buffer.cursor.line] = self.buffer.lines[self.buffer.cursor.line + 1]
		self.buffer.lines[self.buffer.cursor.line + 1] = currentLine
		self.buffer.cursor.line += 1

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:toggleLineComment(commentPrefix)
		if not self.multiline then
			return
		end

		commentPrefix = commentPrefix or "//"
		self:saveHistory()

		local line = self.buffer.lines[self.buffer.cursor.line]
		local trimmed = line:match("^%s*(.*)$")

		if trimmed:sub(1, #commentPrefix) == commentPrefix then
			-- Uncomment
			self.buffer.lines[self.buffer.cursor.line] =
				line:gsub("^(%s*)" .. commentPrefix:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1") .. "%s?", "%1")
		else
			-- Comment
			local indent = line:match("^(%s*)")
			self.buffer.lines[self.buffer.cursor.line] = indent .. commentPrefix .. " " .. trimmed
		end

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:getCursorPosition()
		local pos = 0
		for i = 1, self.buffer.cursor.line - 1 do
			pos += #self.buffer.lines[i] + 1 -- +1 for newline
		end
		pos += self.buffer.cursor.col - 1
		return pos
	end

	-- Numeric value helpers
	function TextBox:getNumericValue()
		if not self.numeric then
			return nil
		end
		local num = tonumber(self:getText())
		return num
	end

	function TextBox:setNumericValue(value)
		if not self.numeric then
			return
		end

		-- Clamp to min/max
		if self.numericMin and value < self.numericMin then
			value = self.numericMin
		end
		if self.numericMax and value > self.numericMax then
			value = self.numericMax
		end

		-- Format with precision
		local text
		if self.numericPrecision then
			text = string.format("%." .. self.numericPrecision .. "f", value)
		else
			text = tostring(value)
		end

		self:setText(text)
		self.sliderValue = value
	end

	function TextBox:incrementNumeric()
		local current = self:getNumericValue() or 0
		self:setNumericValue(current + self.numericStep)
	end

	function TextBox:decrementNumeric()
		local current = self:getNumericValue() or 0
		self:setNumericValue(current - self.numericStep)
	end

	function TextBox:getText()
		local buf = table.create(#self.buffer.lines)
		for i, line in ipairs(self.buffer.lines) do
			buf[i] = self.trimWhitespace and line:gsub("^%s+", ""):gsub("%s+$", "") or line
		end
		return table.concat(buf, "\n")
	end

	function TextBox:getSelectedText()
		return self.buffer:getSelectedText()
	end

	function TextBox:getLineCount()
		return #self.buffer.lines
	end

	function TextBox:getCharCount()
		return #self:getText()
	end

	function TextBox:getCurrentLine()
		return self.buffer.lines[self.buffer.cursor.line]
	end

	function TextBox:getCurrentWord()
		local line = self:getCurrentLine()
		local col = self.buffer.cursor.col

		-- Find word boundaries
		local wordStart = col
		local wordEnd = col

		while wordStart > 1 and line:sub(wordStart - 1, wordStart - 1):match("[%w_]") do
			wordStart -= 1
		end

		while wordEnd <= #line and line:sub(wordEnd, wordEnd):match("[%w_]") do
			wordEnd += 1
		end

		return line:sub(wordStart, wordEnd - 1)
	end

	function TextBox:selectAll()
		self.buffer.selection.active = true
		self.buffer.selection.startLine = 1
		self.buffer.selection.startCol = 1
		self.buffer.selection.endLine = #self.buffer.lines
		self.buffer.selection.endCol = #self.buffer.lines[#self.buffer.lines] + 1
		self.buffer:setCursor(#self.buffer.lines, #self.buffer.lines[#self.buffer.lines] + 1)
	end

	function TextBox:selectWord()
		local line = self:getCurrentLine()
		local col = self.buffer.cursor.col

		local wordStart = col
		local wordEnd = col

		while wordStart > 1 and line:sub(wordStart - 1, wordStart - 1):match("[%w_]") do
			wordStart -= 1
		end

		while wordEnd <= #line and line:sub(wordEnd, wordEnd):match("[%w_]") do
			wordEnd += 1
		end

		self.buffer.selection.active = true
		self.buffer.selection.startLine = self.buffer.cursor.line
		self.buffer.selection.startCol = wordStart
		self.buffer.selection.endLine = self.buffer.cursor.line
		self.buffer.selection.endCol = wordEnd
	end

	function TextBox:selectLine()
		self.buffer.selection.active = true
		self.buffer.selection.startLine = self.buffer.cursor.line
		self.buffer.selection.startCol = 1
		self.buffer.selection.endLine = self.buffer.cursor.line
		self.buffer.selection.endCol = #self:getCurrentLine() + 1
	end

	function TextBox:insertAtCursor(text)
		if self.readOnly then
			return
		end

		self:saveHistory()
		if self.buffer.selection.active then
			self.buffer:deleteSelection()
		end
		self.buffer:insertString(text)

		if self.onChange then
			self.onChange(self:getText())
		end
		self:validate()
	end

	function TextBox:deleteSelection()
		if not self.buffer.selection.active then
			return
		end

		self:saveHistory()
		self.buffer:deleteSelection()

		if self.onChange then
			self.onChange(self:getText())
		end
		self:validate()
	end

	function TextBox:setText(text)
		if not text then
			self.buffer.lines = { "" }
		else
			-- Normalize line endings
			text = string.gsub(text, "\r\n", "\n")
			text = string.gsub(text, "\r", "\n")

			self.buffer.lines = {}
			for line in (text .. "\n"):gmatch("([^\n]*)\n") do
				table.insert(self.buffer.lines, line)
			end

			if #self.buffer.lines == 0 then
				self.buffer.lines = { "" }
			end
		end

		self.buffer:setCursor(1, 1)
		self.scrollY = 0

		if self.onChange then
			self.onChange(self:getText())
		end
	end

	function TextBox:clear()
		self:setText("")
	end

	function TextBox:submit()
		if self.onSubmit then
			self.onSubmit(self:getText())
		end
		if self.blurOnSubmit then
			self:blur()
		end
	end

	function TextBox:focus()
		if not self.isFocused then
			self.isFocused = true
			self.isActive = true
			if self.selectAllOnFocus and self:getCharCount() > 0 then
				self:selectAll()
			end
			if self.onFocus then
				self.onFocus()
			end
		end
	end

	function TextBox:blur()
		if self.isFocused then
			self.isFocused = false
			self.isActive = false
			if self.onBlur then
				self.onBlur()
			end
		end
	end

	-- Performance: invalidate cache
	function TextBox:invalidateCache()
		self.cacheDirty = true
		self.lineWidthCache = {}
		self.hyperlinkCache = {}
	end

	-- Get cached line width
	function TextBox:getCachedLineWidth(lineIndex)
		if self.lineWidthCache[lineIndex] and self.lineWidthCache[lineIndex][self.fontSize] then
			return self.lineWidthCache[lineIndex][self.fontSize]
		end
		return nil
	end

	-- Set cached line width
	function TextBox:setCachedLineWidth(lineIndex, width)
		if not self.lineWidthCache[lineIndex] then
			self.lineWidthCache[lineIndex] = {}
		end
		self.lineWidthCache[lineIndex][self.fontSize] = width
	end

	-- Detect hyperlinks in a line
	function TextBox:detectHyperlinks(line)
		if self.hyperlinkCache[line] then
			return self.hyperlinkCache[line]
		end

		local hyperlinks = {}
		local urlPattern = "(https?://[%w%p]+)"
		local startPos = 1

		while startPos <= #line do
			local urlStart, urlEnd = line:find(urlPattern, startPos)
			if not urlStart then
				break
			end
			table.insert(hyperlinks, { start = urlStart, finish = urlEnd, text = line:sub(urlStart, urlEnd) })
			startPos = urlEnd + 1
		end

		self.hyperlinkCache[line] = hyperlinks
		return hyperlinks
	end

	-- Get context menu items
	function TextBox:getContextMenuItems()
		if self.customContextMenu then
			return self.customContextMenu
		end
		return getDefaultContextMenuItems()
	end

	-- Show context menu
	function TextBox:showContextMenu(x, y)
		if not self.contextMenu then
			return
		end
		self.ctxMenu.visible = true
		self.ctxMenu.x = x
		self.ctxMenu.y = y
		self.ctxMenu.items = self:getContextMenuItems()
	end

	-- Hide context menu
	function TextBox:hideContextMenu()
		self.ctxMenu.visible = false
	end

	-- Draw context menu
	function TextBox:drawContextMenu()
		if not self.ctxMenu.visible or #self.ctxMenu.items == 0 then
			return
		end

		local menuWidth = 180
		local itemHeight = 28
		local menuHeight = #self.ctxMenu.items * itemHeight + 8
		local x = self.ctxMenu.x
		local y = self.ctxMenu.y

		-- Clamp to viewport
		local viewportW, viewportH
		if type(raylib.GetScreenWidth) == "function" then
			viewportW = raylib.GetScreenWidth()
			viewportH = raylib.GetScreenHeight()
		else
			viewportW = 1920
			viewportH = 1080
		end
		x = math.min(x, viewportW - menuWidth - 10)
		y = math.min(y, viewportH - menuHeight - 10)

		-- Draw background
		local menuRect = structs.Rectangle:new({ x = x, y = y, width = menuWidth, height = menuHeight })
		raylib.DrawRectangleRounded(menuRect, self.popupCornerRadius, self.cornerSegments, self.theme.popupBackground)
		raylib.DrawRectangleRoundedLinesEx(menuRect, self.popupCornerRadius, self.cornerSegments, 1, self.theme.border)

		-- Draw items
		local mousePos = raylib.GetMousePosition()
		for i, item in ipairs(self.ctxMenu.items) do
			if item.type == "separator" then
				-- Separator line
				raylib.DrawLine(
					x + 8,
					y + i * itemHeight - 2,
					x + menuWidth - 8,
					y + i * itemHeight - 2,
					self.theme.border
				)
			else
				local itemY = y + (i - 1) * itemHeight + 4
				local itemRect = { x = x + 4, y = itemY, width = menuWidth - 8, height = itemHeight }
				local hovered = isMouseInRect(itemRect, mousePos)

				if hovered then
					raylib.DrawRectangle(
						itemRect.x,
						itemRect.y,
						itemRect.width,
						itemRect.height,
						Color3.new(0.2, 0.4, 0.8):ToRaylib(0)
					)
				end

				-- Draw label
				raylib.DrawTextEx(vend, item.label or "", vector.create(x + 12, itemY + 6), 14, 1, self.theme.text)

				-- Draw shortcut
				if item.shortcut then
					raylib.DrawTextEx(
						vend,
						item.shortcut,
						vector.create(x + menuWidth - 50, itemY + 6),
						12,
						1,
						Color3.new(0.5, 0.5, 0.5):ToRaylib(0)
					)
				end
			end
		end
	end

	-- Draw scrollbar
	function TextBox:drawScrollbar(x, y, width, height, lineHeight)
		if not self.enableScrollbar or not self.scrollable or self.maxScroll <= 0 then
			return
		end

		local scrollbarX = x + width - self.scrollbarWidth - 4
		local scrollbarHeight = height - 30 -- Account for status bar
		local thumbHeight = math.max(20, (height / (#self.buffer.lines + 1)) * scrollbarHeight)
		local thumbY = y + 4 + (self.scrollY / self.maxScroll) * (scrollbarHeight - thumbHeight)

		-- Draw track
		raylib.DrawRectangle(scrollbarX, y + 4, self.scrollbarWidth, scrollbarHeight, self.theme.scrollbar)

		-- Draw thumb
		local mousePos = raylib.GetMousePosition()
		local thumbRect = { x = scrollbarX, y = thumbY, width = self.scrollbarWidth, height = thumbHeight }
		local hovered = isMouseInRect(thumbRect, mousePos)
		local thumbColor = (hovered or self.scrollbarState.dragging) and self.theme.scrollbarHover
			or self.theme.scrollbar
		thumbColor = Color3.new(0.4, 0.4, 0.4):ToRaylib(0)
		raylib.DrawRectangleRounded(structs.Rectangle:new(thumbRect), 0.3, 4, thumbColor)

		-- Handle scrollbar interaction
		if raylib.IsMouseButtonPressed(0) == 1 then
			if hovered then
				self.scrollbarState.dragging = true
			else
				-- Click on track to jump
				local relY = mousePos.y - (y + 4)
				local percent = relY / (scrollbarHeight - thumbHeight)
				self.scrollY = percent * self.maxScroll
				self.scrollY = math.clamp(self.scrollY, 0, self.maxScroll)
			end
		end

		if self.scrollbarState.dragging and raylib.IsMouseButtonDown(0) == 0 then
			self.scrollbarState.dragging = false
		end

		if self.scrollbarState.dragging then
			local relY = mousePos.y - (y + 4)
			local percent = math.clamp(relY / (scrollbarHeight - thumbHeight), 0, 1)
			self.scrollY = percent * self.maxScroll
			self.scrollY = math.clamp(self.scrollY, 0, self.maxScroll)
		end
	end

	-- Draw minimap
	function TextBox:drawMinimap(x, y, width, height, lineHeight)
		if not self.enableMinimap or #self.buffer.lines < 50 then
			return
		end

		local minimapX = x + width - self.minimapWidth - 16
		local minimapHeight = height - 30
		local minimapY = y + 10

		-- Draw background
		raylib.DrawRectangle(minimapX, minimapY, self.minimapWidth, minimapHeight, self.theme.minimapBackground)

		-- Calculate scale
		local totalLines = #self.buffer.lines
		local lineScale = minimapHeight / totalLines
		local visibleStart = math.floor(self.scrollY / lineHeight) + 1
		local visibleEnd = math.ceil((self.scrollY + height) / lineHeight)

		-- Draw visible region
		local visStartY = minimapY + (visibleStart - 1) * lineScale
		local visHeight = (visibleEnd - visibleStart + 1) * lineScale
		raylib.DrawRectangle(minimapX, visStartY, self.minimapWidth, visHeight, self.theme.minimapSelection)

		-- Draw text preview (simplified)
		for i = 1, totalLines do
			local lineY = minimapY + (i - 1) * lineScale
			if lineScale >= 2 then
				local line = self.buffer.lines[i]
				local previewText = #line > 0 and line:sub(1, math.min(#line, 30)) or ""
				if #previewText > 0 then
					raylib.DrawTextEx(
						vend,
						previewText,
						vector.create(minimapX + 2, lineY),
						6,
						0,
						Color3.new(0.4, 0.4, 0.4):ToRaylib(0)
					)
				end
			end
		end

		-- Minimap click to scroll
		local mousePos = raylib.GetMousePosition()
		local minimapRect = { x = minimapX, y = minimapY, width = self.minimapWidth, height = minimapHeight }
		if raylib.IsMouseButtonPressed(0) == 1 and isMouseInRect(minimapRect, mousePos) then
			local relY = mousePos.y - minimapY
			local percent = relY / minimapHeight
			self.scrollY = percent * self.maxScroll
			self.scrollY = math.clamp(self.scrollY, 0, self.maxScroll)
		end
	end

	-- Draw animated focus ring
	function TextBox:drawFocusRing(x, y, width, height)
		if not self.enableAnimatedFocus then
			return
		end

		-- Update animation
		local target = self.isFocused and 1 or 0
		if self.focusRingAnim.target ~= target then
			self.focusRingAnim.target = target
		end

		-- Lerp towards target
		local speed = self.focusRingAnim.speed * raylib.GetFrameTime()
		self.focusRingAnim.progress = self.focusRingAnim.progress
			+ (self.focusRingAnim.target - self.focusRingAnim.progress) * speed

		if self.focusRingAnim.progress > 0.01 then
			-- Draw animated border
			local inset = 2
			local ringColor = Color3.new(
				0.4 + 0.2 * self.focusRingAnim.progress,
				0.6 + 0.2 * self.focusRingAnim.progress,
				1.0 * self.focusRingAnim.progress
			):ToRaylib(0)
			if self.cornerRadius > 0 then
				raylib.DrawRectangleRoundedLinesEx(
					structs.Rectangle:new({
						x = x + inset,
						y = y + inset,
						width = width - inset * 2,
						height = height - inset * 2,
					}),
					self.cornerRadius,
					self.cornerSegments,
					2,
					ringColor
				)
			else
				raylib.DrawRectangleLinesEx(
					structs.Rectangle:new({
						x = x + inset,
						y = y + inset,
						width = width - inset * 2,
						height = height - inset * 2,
					}),
					2,
					ringColor
				)
			end
		end
	end

	-- Handle column selection (Alt+drag)
	function TextBox:startColumnSelection(line, col)
		if not self.enableColumnSelection or not self.multiline then
			return
		end
		self.columnSelection.active = true
		self.columnSelection.startLine = line
		self.columnSelection.startCol = col
		self.columnSelection.endLine = line
		self.columnSelection.endCol = col
	end

	function TextBox:updateColumnSelection(line, col)
		if not self.columnSelection.active then
			return
		end
		self.columnSelection.endLine = line
		self.columnSelection.endCol = col
	end

	function TextBox:endColumnSelection()
		self.columnSelection.active = false
	end

	-- Draw column selection
	function TextBox:drawColumnSelection(x, y, gutterWidth, lineHeight, spacing)
		if not self.columnSelection.active then
			return
		end

		local sL = math.min(self.columnSelection.startLine, self.columnSelection.endLine)
		local eL = math.max(self.columnSelection.startLine, self.columnSelection.endLine)
		local sC = math.min(self.columnSelection.startCol, self.columnSelection.endCol)
		local eC = math.max(self.columnSelection.startCol, self.columnSelection.endCol)

		for i = sL, eL do
			local line = self.buffer.lines[i]
			if line then
				local ly = y + self.padding + (i - 1) * lineHeight - self.scrollY
				local x1 = x
					+ gutterWidth
					+ self.padding
					+ measureTextWidth(line:sub(1, sC - 1), self.fontSize, spacing)
				local x2 = x
					+ gutterWidth
					+ self.padding
					+ measureTextWidth(line:sub(1, eC - 1), self.fontSize, spacing)
				raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, self.theme.selection)
			end
		end
	end

	-- Handle drag and drop
	function TextBox:startDrag(x, y)
		if not self.enableDragDrop or not self.buffer.selection.active then
			return
		end
		self.dragState.isDragging = true
		self.dragState.startPos = { x = x, y = y }
		self.dragState.dragText = self:getSelectedText()
	end

	function TextBox:endDrag(x, y)
		if not self.dragState.isDragging then
			return
		end
		self.dragState.isDragging = false
		-- Insert text at drop location if different from start
		-- (simplified - actual implementation would need position calculation)
	end

	function TextBox:draw(x, y, width, height)
		local dt = raylib.GetFrameTime()

		-- Update caret blink
		self.caretTimer = self.caretTimer + dt
		if self.caretTimer >= self.caretBlinkRate then
			self.caretVisible = not self.caretVisible
			self.caretTimer = self.caretTimer - self.caretBlinkRate
		end

		local lineHeight = self.fontSize + 4
		local spacing = 1

		-- Calculate dimensions
		local gutterWidth = self.showLineNumbers and 50 or 0
		local statusBarHeight = (self.showCharCount or self.showLineCount or self.validationError) and 25 or 0
		local contentWidth = width - gutterWidth - (self.padding * 2)
		local contentHeight = height - (self.padding * 2) - statusBarHeight

		-- Calculate scrolling
		if self.scrollable then
			local totalHeight = #self.buffer.lines * lineHeight
			local viewportHeight = contentHeight
			self.maxScroll = math.max(0, totalHeight - viewportHeight)
		else
			self.scrollY = 0
			self.maxScroll = 0
		end

		-- Visible line range
		local firstVisibleLine = math.floor(self.scrollY / lineHeight) + 1
		local lastVisibleLine = math.ceil((self.scrollY + contentHeight) / lineHeight)
		firstVisibleLine = math.max(1, firstVisibleLine)
		lastVisibleLine = math.min(#self.buffer.lines, lastVisibleLine)

		local boxRect = structs.Rectangle:new({
			x = x,
			y = y,
			width = width,
			height = height,
		})
		local useRounded = self.cornerRadius > 0

		-- Draw background
		if self.dropShadow then
			local shadowRect = structs.Rectangle:new({
				x = x + self.shadowOffset,
				y = y + self.shadowOffset,
				width = width,
				height = height,
			})
			raylib.DrawRectangleRounded(shadowRect, self.cornerRadius, self.cornerSegments, self.theme.shadow)
		end
		if useRounded then
			raylib.DrawRectangleRounded(boxRect, self.cornerRadius, self.cornerSegments, self.theme.background)
		else
			raylib.DrawRectangle(x, y, width, height, self.theme.background)
		end

		-- Draw border
		local borderColor = self.validationError and self.theme.error
			or (self.isFocused and self.theme.focusBorder or self.theme.border)
		local borderWidth = self.isFocused and self.focusBorderWidth or self.borderWidth
		if useRounded then
			raylib.DrawRectangleRoundedLinesEx(
				boxRect,
				self.cornerRadius,
				self.cornerSegments,
				borderWidth,
				borderColor
			)
		else
			raylib.DrawRectangleLinesEx(boxRect, borderWidth, borderColor)
		end

		-- Draw animated focus ring
		self:drawFocusRing(x, y, width, height)

		-- Draw gutter background
		if self.showLineNumbers then
			local inset = useRounded and 1 or 0
			raylib.DrawRectangle(x, y + inset, gutterWidth, height - (inset * 2), self.theme.gutterBackground)
		end

		-- Draw current line highlight
		if self.isFocused and self.multiline and self.lineHighlight then
			local c = self.buffer.cursor
			local lineY = y + self.padding + (c.line - 1) * lineHeight - self.scrollY
			if lineY >= y and lineY < y + height - statusBarHeight then
				raylib.DrawRectangle(x + gutterWidth, lineY, width - gutterWidth, lineHeight, self.theme.currentLine)
			end
		end

		-- Draw selection
		if self.isFocused then
			local sL, sC, eL, eC = self.buffer:getSelectionRange()
			if sL then
				for i = math.max(firstVisibleLine, sL), math.min(lastVisibleLine, eL) do
					local ly = y + self.padding + (i - 1) * lineHeight - self.scrollY
					local line = self.buffer.lines[i]
					local startX = (i == sL) and sC or 1
					local endX = (i == eL) and eC or #line + 1

					local x1 = x
						+ gutterWidth
						+ self.padding
						+ measureTextWidth(line:sub(1, startX - 1), self.fontSize, spacing)
					local x2 = x
						+ gutterWidth
						+ self.padding
						+ measureTextWidth(line:sub(1, endX - 1), self.fontSize, spacing)

					raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, self.theme.selection)
				end
			end
		end

		-- Draw search highlights
		if self.search.active and #self.search.results > 0 then
			for idx, res in ipairs(self.search.results) do
				if res.line >= firstVisibleLine and res.line <= lastVisibleLine then
					local ly = y + self.padding + (res.line - 1) * lineHeight - self.scrollY
					local line = self.buffer.lines[res.line]
					local x1 = x
						+ gutterWidth
						+ self.padding
						+ measureTextWidth(line:sub(1, res.col - 1), self.fontSize, spacing)
					local x2 = x
						+ gutterWidth
						+ self.padding
						+ measureTextWidth(line:sub(1, res.col + res.length - 1), self.fontSize, spacing)

					local isCurrent = (idx == self.search.currentIndex)
					local color = isCurrent and Color3.new(1, 0.5, 0):ToRaylib(0.4) or self.theme.searchHighlight
					raylib.DrawRectangle(x1, ly, x2 - x1, lineHeight, color)
				end
			end
		end

		-- Draw matched brackets
		if self.matchBrackets and self.isFocused then
			local cursorLine = self.buffer.lines[self.buffer.cursor.line]
			if cursorLine then
				local cursorCol = self.buffer.cursor.col
				local checkCols = { cursorCol - 1, cursorCol }
				local matchFound = nil

				for _, cIdx in ipairs(checkCols) do
					if cIdx >= 1 and cIdx <= #cursorLine then
						local char = cursorLine:sub(cIdx, cIdx)
						local pairs =
							{ ["("] = true, ["["] = true, ["{"] = true, [")"] = true, ["]"] = true, ["}"] = true }
						if pairs[char] then
							local mL, mC = self:findMatchingBracket(self.buffer.cursor.line, cIdx)
							if mL and mC then
								matchFound = { { self.buffer.cursor.line, cIdx }, { mL, mC } }
								break
							end
						end
					end
				end

				if matchFound then
					for _, pos in ipairs(matchFound) do
						local l, c = pos[1], pos[2]
						if l >= firstVisibleLine and l <= lastVisibleLine then
							local line = self.buffer.lines[l]
							local ly = y + self.padding + (l - 1) * lineHeight - self.scrollY
							local x1 = x
								+ gutterWidth
								+ self.padding
								+ measureTextWidth(line:sub(1, c - 1), self.fontSize, spacing)
							local w = measureTextWidth(line:sub(c, c), self.fontSize, spacing)
							raylib.DrawRectangleLines(x1, ly, w, lineHeight, self.theme.matchBracket)
						end
					end
				end
			end
		end

		-- Draw text or placeholder
		local isEmpty = #self.buffer.lines == 1 and #self.buffer.lines[1] == 0

		if isEmpty and not self.isFocused and #self.placeholder > 0 then
			-- Draw placeholder
			raylib.DrawTextEx(
				vend,
				self.placeholder,
				vector.create(x + gutterWidth + self.padding, y + self.padding),
				self.fontSize,
				spacing,
				self.theme.placeholder
			)
		else
			-- Draw text content
			for i = firstVisibleLine, lastVisibleLine do
				local line = self.buffer.lines[i]
				local yLine = y + self.padding + (i - 1) * lineHeight - self.scrollY

				-- Draw line number
				if self.showLineNumbers then
					local lineNumberText = tostring(i)
					local lineNumColor = self.TextColor
						or (i == self.buffer.cursor.line and self.isFocused) and self.theme.text
						or Color3.new(0.5, 0.5, 0.5):ToRaylib(0)
					raylib.DrawTextEx(
						vend,
						lineNumberText,
						vector.create(x + 5, yLine),
						self.fontSize,
						spacing,
						lineNumColor
					)
				end

				-- Handle masking (password field)
				local displayLine = line
				if self.mask and #line > 0 then
					displayLine = string.rep(self.mask, #line)
				end

				-- Draw hyperlinks if enabled
				if self.enableHyperlinks and not self.mask then
					local hyperlinks = self:detectHyperlinks(line)
					for _, link in ipairs(hyperlinks) do
						local x1 = x
							+ gutterWidth
							+ self.padding
							+ measureTextWidth(line:sub(1, link.start - 1), self.fontSize, spacing)
						local x2 = x
							+ gutterWidth
							+ self.padding
							+ measureTextWidth(line:sub(1, link.finish), self.fontSize, spacing)
						raylib.DrawLine(x1, yLine + lineHeight - 2, x2, yLine + lineHeight - 2, self.theme.hyperlink)
					end
				end

				-- Draw line content with syntax highlighting if available
				if self.syntaxHighlighter and not self.mask then
					local tokens = self.syntaxHighlighter(line)
					local xPos = x + gutterWidth + self.padding

					for _, tok in ipairs(tokens) do
						raylib.DrawTextEx(
							vend,
							tok.text,
							vector.create(xPos, yLine),
							self.fontSize,
							spacing,
							tok.color or self.theme.text
						)
						xPos += raylib.MeasureTextEx(vend, tok.text, self.fontSize, spacing).x
					end
				else
					raylib.DrawTextEx(
						vend,
						displayLine,
						vector.create(x + gutterWidth + self.padding, yLine),
						self.fontSize,
						spacing,
						self.TextColor or self.theme.text
					)
				end
			end
		end

		-- Draw caret
		if self.isFocused and self.caretVisible then
			local c = self.buffer.cursor
			local textBeforeCursor = self.buffer.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterWidth + self.padding + measureTextWidth(textBeforeCursor, self.fontSize, spacing)
			local cy = y + self.padding + (c.line - 1) * lineHeight - self.scrollY

			if cy >= y and cy < y + height - statusBarHeight then
				raylib.DrawRectangle(cx, cy, 2, lineHeight, self.theme.text)
			end
		end

		-- Draw status bar
		if statusBarHeight > 0 then
			local sbY = y + height - statusBarHeight
			raylib.DrawRectangle(x, sbY, width, statusBarHeight, self.theme.statusBarBackground)
			raylib.DrawLine(x, sbY, x + width, sbY, self.theme.border)

			local statusText = ""
			if self.showLineCount and self.showCharCount then
				statusText = string.format("Lines: %d | Chars: %d", self:getLineCount(), self:getCharCount())
			elseif self.showLineCount then
				statusText = string.format("Lines: %d", self:getLineCount())
			elseif self.showCharCount then
				statusText = string.format("Chars: %d", self:getCharCount())
			end

			if self.maxLength then
				statusText = statusText .. string.format(" / %d", self.maxLength)
			end

			if self.validationError then
				statusText = "❌ " .. self.validationError
				raylib.DrawTextEx(vend, statusText, vector.create(x + 8, sbY + 5), 12, 1, self.theme.error)
			elseif #statusText > 0 then
				raylib.DrawTextEx(
					vend,
					statusText,
					vector.create(x + 8, sbY + 5),
					12,
					1,
					Color3.new(0.7, 0.7, 0.7):ToRaylib(0)
				)
			end
		end

		-- Draw autocomplete popup
		if self.autocomplete.visible and #self.autocomplete.items > 0 then
			local provider = self.autocompleteProvider
			local renderedByProvider = false
			if
				self.useProviderAutocompleteUI
				and type(provider) == "table"
				and type(provider.step) == "function"
				and self.iconLoader
			then
				local editorAdapter = {
					isActive = self.isFocused,
					text = self.buffer,
					autocomplete = self.autocomplete,
					scrollY = self.scrollY,
				}
				renderedByProvider = pcall(
					provider.step,
					editorAdapter,
					x,
					gutterWidth,
					self.padding,
					measureTextWidth,
					self.fontSize,
					self.tabSize,
					lineHeight,
					self.autocompleteTheme,
					rect,
					raylib,
					function(c, t)
						return c:ToRaylib(t)
					end,
					vend,
					spacing,
					self.TextColor or self.theme.text,
					self.theme.popupBackground,
					y,
					dt,
					self.iconLoader
				)
			end

			if not renderedByProvider then
				local acWidth = 200
				local acItemHeight = 24
				local acHeight = math.min(#self.autocomplete.items * acItemHeight, 200)
				local viewportW, viewportH
				if type(raylib.GetRenderWidth) == "function" and type(raylib.GetRenderHeight) == "function" then
					viewportW = raylib.GetRenderWidth()
					viewportH = raylib.GetRenderHeight()
				elseif type(raylib.GetScreenWidth) == "function" and type(raylib.GetScreenHeight) == "function" then
					viewportW = raylib.GetScreenWidth()
					viewportH = raylib.GetScreenHeight()
				else
					viewportW = x + width
					viewportH = y + height
				end

				-- Position near cursor
				local c = self.buffer.cursor
				local textBeforeCursor = self.buffer.lines[c.line]:sub(1, c.col - 1)
				local acX = x + gutterWidth + self.padding + measureTextWidth(textBeforeCursor, self.fontSize, spacing)
				local caretY = y + self.padding + (c.line - 1) * lineHeight - self.scrollY

				local pad = 4
				local minX = pad
				local maxX = math.max(minX, viewportW - acWidth - pad)
				local minY = pad
				local maxY = math.max(minY, viewportH - acHeight - pad)

				local belowY = caretY + lineHeight + 5
				local aboveY = caretY - acHeight - 5
				local spaceAbove = caretY - minY
				local spaceBelow = (viewportH - pad) - (caretY + lineHeight)
				local acY

				if spaceAbove >= acHeight or spaceAbove >= spaceBelow then
					acY = aboveY
				else
					acY = belowY
				end

				acX = math.clamp(acX, minX, maxX)
				acY = math.clamp(acY, minY, maxY)

				local acRect = structs.Rectangle:new({ x = acX, y = acY, width = acWidth, height = acHeight })
				if self.popupCornerRadius > 0 then
					raylib.DrawRectangleRounded(
						acRect,
						self.popupCornerRadius,
						self.cornerSegments,
						self.theme.popupBackground
					)
					raylib.DrawRectangleRoundedLinesEx(
						acRect,
						self.popupCornerRadius,
						self.cornerSegments,
						self.borderWidth,
						self.theme.border
					)
				else
					raylib.DrawRectangle(acX, acY, acWidth, acHeight, self.theme.popupBackground)
					raylib.DrawRectangleLinesEx(acRect, self.borderWidth, self.theme.border)
				end

				local visibleStart = math.max(1, self.autocomplete.selectedIndex - 8)
				local visibleEnd =
					math.min(#self.autocomplete.items, visibleStart + math.floor(acHeight / acItemHeight) - 1)

				for i = visibleStart, visibleEnd do
					local item = self.autocomplete.items[i]
					local itemY = acY + (i - visibleStart) * acItemHeight
					local itemText = getAutocompleteItemText(item) or ""

					if i == self.autocomplete.selectedIndex then
						raylib.DrawRectangle(acX, itemY, acWidth, acItemHeight, Color3.new(0.2, 0.4, 0.8):ToRaylib(0))
					end

					raylib.DrawTextEx(vend, itemText, vector.create(acX + 5, itemY + 4), 14, 1, self.theme.text)
				end
			end
		end

		-- Draw search/replace UI
		if self.search.active or self.replace.active then
			local boxW = 250
			local boxH = self.replace.active and 80 or 40
			local boxX = x + width - boxW - 10
			local boxY = y + 10

			local searchRect = structs.Rectangle:new({ x = boxX, y = boxY, width = boxW, height = boxH })
			if self.popupCornerRadius > 0 then
				raylib.DrawRectangleRounded(
					searchRect,
					self.popupCornerRadius,
					self.cornerSegments,
					self.theme.popupBackground
				)
				raylib.DrawRectangleRoundedLinesEx(
					searchRect,
					self.popupCornerRadius,
					self.cornerSegments,
					self.borderWidth,
					self.theme.border
				)
			else
				raylib.DrawRectangle(boxX, boxY, boxW, boxH, self.theme.popupBackground)
				raylib.DrawRectangleLinesEx(searchRect, self.borderWidth, self.theme.border)
			end

			raylib.DrawTextEx(
				vend,
				"Find: " .. self.search.query,
				vector.create(boxX + 10, boxY + 12),
				14,
				1,
				self.theme.text
			)

			if #self.search.results > 0 then
				local resText = string.format("%d/%d", self.search.currentIndex, #self.search.results)
				raylib.DrawTextEx(
					vend,
					resText,
					vector.create(boxX + boxW - 50, boxY + 12),
					14,
					1,
					Color3.new(0.7, 0.7, 0.7):ToRaylib(0)
				)
			end

			if self.replace.active then
				raylib.DrawTextEx(
					vend,
					"Replace: " .. self.replace.query,
					vector.create(boxX + 10, boxY + 52),
					14,
					1,
					self.theme.text
				)
			end
		end

		-- Draw scrollbar
		self:drawScrollbar(x, y, width, height, lineHeight)

		-- Draw minimap
		self:drawMinimap(x, y, width, height, lineHeight)

		-- Draw column selection
		self:drawColumnSelection(x, y, gutterWidth, lineHeight, spacing)

		-- Draw context menu
		self:drawContextMenu()

		-- Handle mouse wheel scrolling
		if
			self.scrollable
			and isMouseInRect({ x = x, y = y, width = width, height = height }, raylib.GetMousePosition())
		then
			local wheel = raylib.GetMouseWheelMove()
			if wheel ~= 0 then
				if
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
				then
					-- Zoom
					self.fontSize = math.clamp(self.fontSize + wheel, 8, 72)
				else
					-- Scroll
					local scrollSpeed = lineHeight * 3
					self.scrollY = self.scrollY - (wheel * scrollSpeed)
					self.scrollY = math.clamp(self.scrollY, 0, self.maxScroll)
				end
			end
		end

		-- Handle mouse input
		local mousePos = raylib.GetMousePosition()
		local isInBounds = isMouseInRect({ x = x, y = y, width = width, height = height }, mousePos)

		if raylib.IsMouseButtonPressed(0) == 1 then
			if isInBounds and not self.readOnly then
				self:focus()

				-- Track clicks for double/triple click
				local currentTime = os.clock()
				if currentTime - self.lastClickTime < 0.3 then
					self.clickCount += 1
				else
					self.clickCount = 1
				end
				self.lastClickTime = currentTime

				-- Calculate clicked position
				local relY = mousePos.y - (y + self.padding) + self.scrollY
				local clickedLine = math.clamp(math.floor(relY / lineHeight) + 1, 1, #self.buffer.lines)
				local relX = mousePos.x - (x + gutterWidth + self.padding)
				local clickedCol = getColumnFromX(self.buffer.lines[clickedLine], relX, self.fontSize, spacing)

				self.buffer.cursor.line = clickedLine
				self.buffer.cursor.col = clickedCol

				-- Handle double/triple click
				if self.clickCount == 2 and self.doubleClickSelect then
					self:selectWord()
				elseif self.clickCount == 3 and self.tripleClickSelect then
					self:selectLine()
				else
					self.buffer.selection.active = true
					self.buffer.selection.startLine = clickedLine
					self.buffer.selection.startCol = clickedCol
					self.buffer.selection.endLine = clickedLine
					self.buffer.selection.endCol = clickedCol
				end
			else
				self:blur()
			end
		elseif raylib.IsMouseButtonPressed(1) == 1 then
			-- Right-click for context menu
			if isInBounds and self.contextMenu then
				local mousePos = raylib.GetMousePosition()
				self:showContextMenu(mousePos.x, mousePos.y)
			else
				self:hideContextMenu()
			end
		elseif raylib.IsMouseButtonPressed(2) == 1 then
			-- Middle click - close context menu if clicked outside
			self:hideContextMenu()
		elseif raylib.IsMouseButtonDown(0) == 1 and self.isFocused and isInBounds then
			-- Check for Alt key for column selection
			local altHeld = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_ALT) == 1
				or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_ALT) == 1

			if altHeld and self.enableColumnSelection then
				-- Handle column selection (Alt+drag)
				if not self.columnSelection.active then
					self:startColumnSelection(self.buffer.cursor.line, self.buffer.cursor.col)
				else
					local relX = mousePos.x - (x + gutterWidth + self.padding)
					local relY = mousePos.y - (y + self.padding) + self.scrollY
					local clickedLine = math.clamp(math.floor(relY / lineHeight) + 1, 1, #self.buffer.lines)
					local clickedCol = getColumnFromX(self.buffer.lines[clickedLine], relX, self.fontSize, spacing)
					self:updateColumnSelection(clickedLine, clickedCol)
				end
			else
				-- Handle dragging selection
				local relX = mousePos.x - (x + gutterWidth + self.padding)
				local relY = mousePos.y - (y + self.padding) + self.scrollY

				local clickedLine = math.clamp(math.floor(relY / lineHeight) + 1, 1, #self.buffer.lines)
				local clickedCol = getColumnFromX(self.buffer.lines[clickedLine], relX, self.fontSize, spacing)

				self.buffer.cursor.line = clickedLine
				self.buffer.cursor.col = clickedCol
				self.buffer.selection.endLine = clickedLine
				self.buffer.selection.endCol = clickedCol

				if
					self.buffer.selection.startLine == self.buffer.selection.endLine
					and self.buffer.selection.startCol == self.buffer.selection.endCol
				then
					self.buffer.selection.active = false
				else
					self.buffer.selection.active = true
				end
			end
		end

		-- Set cursor
		if isInBounds then
			raylib.SetMouseCursor(EnumMap.KinemiumMouseCursor.MOUSE_CURSOR_IBEAM.Value)
		end

		-- Handle keyboard input
		if self.isFocused and not self.readOnly then
			self:handleKeyboardInput()
		end
	end

	function TextBox:handleKeyboardInput()
		-- Handle autocomplete navigation
		if self.autocomplete.visible then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
				self.autocomplete.selectedIndex =
					math.min(self.autocomplete.selectedIndex + 1, #self.autocomplete.items)
				return
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
				self.autocomplete.selectedIndex = math.max(self.autocomplete.selectedIndex - 1, 1)
				return
			elseif
				raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1
				or raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1
			then
				self:completeAutocomplete()
				return
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				self.autocomplete.visible = false
				return
			end
		end

		-- Handle search input
		if self.search.active and not self.replace.active then
			local byte = raylib.GetCharPressed()
			while byte ~= 0 do
				self.search.query = self.search.query .. string.char(byte)
				self:updateSearch()
				byte = raylib.GetCharPressed()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				self.search.query = self.search.query:sub(1, -2)
				self:updateSearch()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				self:nextSearchResult()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				self.search.active = false
			end

			return
		end

		-- Handle replace input
		if self.replace.active then
			local byte = raylib.GetCharPressed()
			while byte ~= 0 do
				self.replace.query = self.replace.query .. string.char(byte)
				byte = raylib.GetCharPressed()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				self.replace.query = self.replace.query:sub(1, -2)
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				if
					raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
					or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1
				then
					self:replaceAll()
				else
					self:replaceNext()
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				self.replace.active = false
				self.search.active = false
			end

			return
		end

		-- Character input
		local byte = raylib.GetCharPressed()
		while byte ~= 0 do
			local char = string.char(byte)

			-- Check allowed characters
			if self.allowedChars then
				local isAllowed = false
				if type(self.allowedChars) == "function" then
					isAllowed = self.allowedChars(char)
				elseif type(self.allowedChars) == "string" then
					isAllowed = char:match(self.allowedChars) ~= nil
				end

				if not isAllowed then
					byte = raylib.GetCharPressed()
					continue
				end
			end

			-- Check max length
			if self.maxLength and #self:getText() >= self.maxLength then
				byte = raylib.GetCharPressed()
				continue
			end

			self:saveHistory()

			-- Handle auto-pairing
			if self.autoPairs then
				local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
				local handled = false

				if self.buffer.selection.active then
					if pairs[char] then
						local text = self.buffer:getSelectedText()
						self.buffer:deleteSelection()
						self.buffer:insertString(char .. text .. pairs[char])
						handled = true
					else
						self.buffer:deleteSelection()
					end
				end

				if not handled then
					self.buffer:insertChar(char)
					if pairs[char] then
						self.buffer:insertChar(pairs[char])
						self.buffer:moveLeft()
					end
				end
			else
				if self.buffer.selection.active then
					self.buffer:deleteSelection()
				end
				self.buffer:insertChar(char)
			end

			if self.onChange then
				self.onChange(self:getText())
			end
			self:validate()
			self:updateAutocomplete()

			byte = raylib.GetCharPressed()
		end

		-- Tab key
		if raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1 then
			if self.autocomplete.visible then
				self:completeAutocomplete()
			else
				self:saveHistory()
				if self.buffer.selection.active then
					-- Indent/dedent selection
					local shift = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
						or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1

					local sL, sC, eL, eC = self.buffer:getSelectionRange()
					if sL then
						for i = sL, eL do
							if shift then
								-- Dedent
								if self.buffer.lines[i]:sub(1, 1) == "\t" then
									self.buffer.lines[i] = self.buffer.lines[i]:sub(2)
								elseif self.buffer.lines[i]:sub(1, self.tabSize):match("^%s+$") then
									self.buffer.lines[i] = self.buffer.lines[i]:sub(self.tabSize + 1)
								end
							else
								-- Indent
								self.buffer.lines[i] = "\t" .. self.buffer.lines[i]
							end
						end
					end
				else
					self.buffer:insertChar("\t")
				end

				if self.onChange then
					self.onChange(self:getText())
				end
			end
		end

		-- Enter key
		if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
			local ctrlHeld = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
				or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
			if self.multiline then
				if self.submitOnCtrlEnter and ctrlHeld then
					self:submit()
				else
					self:saveHistory()
					if self.buffer.selection.active then
						self.buffer:deleteSelection()
					end

					-- Auto indent
					if self.autoIndent then
						local currentLine = self.buffer.lines[self.buffer.cursor.line]
						local indent = currentLine:match("^([\t ]*)")
						self.buffer:newline()
						self.buffer:insertString(indent)
					else
						self.buffer:newline()
					end

					if self.onChange then
						self.onChange(self:getText())
					end
				end
			else
				self:submit()
			end
		end

		-- Backspace with acceleration
		if raylib.IsKeyDown(const.KeyboardKey.KEY_BACKSPACE) == 1 then
			local currentTime = os.clock()
			local timeSinceLast = currentTime - self.keyRepeat.lastBackspaceTime
			local shouldDelete = false

			-- Handle selection deletion on first press
			if self.buffer.selection.active then
				self:saveHistory()
				self.buffer:deleteSelection()
				if self.onChange then
					self.onChange(self:getText())
				end
				self:validate()
				self:updateAutocomplete()
			else
				-- Initial delay before acceleration starts
				if self.keyRepeat.backspaceCount == 0 then
					if timeSinceLast > self.keyRepeat.initialDelay then
						shouldDelete = true
						self.keyRepeat.backspaceCount = 1
					end
				else
					-- Calculate accelerated interval
					local interval = self.keyRepeat.minInterval
					for i = 1, self.keyRepeat.backspaceCount do
						interval = interval / self.keyRepeat.acceleration
					end
					interval = math.max(interval, self.keyRepeat.minInterval)

					if timeSinceLast > interval then
						shouldDelete = true
						self.keyRepeat.backspaceCount = self.keyRepeat.backspaceCount + 1
					end
				end

				self.keyRepeat.lastBackspaceTime = currentTime

				if shouldDelete then
					self:saveHistory()
					self.buffer:backspace()
					if self.onChange then
						self.onChange(self:getText())
					end
					self:validate()
					self:updateAutocomplete()
				end
			end
		else
			-- Reset backspace count when key is released
			self.keyRepeat.backspaceCount = 0
		end

		-- Delete key with acceleration
		if raylib.IsKeyDown(const.KeyboardKey.KEY_DELETE) == 1 then
			local currentTime = os.clock()
			local timeSinceLast = currentTime - self.keyRepeat.lastDeleteTime
			local shouldDelete = false

			-- Handle selection deletion on first press
			if self.buffer.selection.active then
				self:saveHistory()
				self.buffer:deleteSelection()
				if self.onChange then
					self.onChange(self:getText())
				end
				self:validate()
			else
				-- Initial delay before acceleration starts
				if self.keyRepeat.deleteCount == 0 then
					if timeSinceLast > self.keyRepeat.initialDelay then
						shouldDelete = true
						self.keyRepeat.deleteCount = 1
					end
				else
					-- Calculate accelerated interval
					local interval = self.keyRepeat.minInterval
					for i = 1, self.keyRepeat.deleteCount do
						interval = interval / self.keyRepeat.acceleration
					end
					interval = math.max(interval, self.keyRepeat.minInterval)

					if timeSinceLast > interval then
						shouldDelete = true
						self.keyRepeat.deleteCount = self.keyRepeat.deleteCount + 1
					end
				end

				self.keyRepeat.lastDeleteTime = currentTime

				if shouldDelete then
					self:saveHistory()
					self.buffer:delete()
					if self.onChange then
						self.onChange(self:getText())
					end
					self:validate()
				end
			end
		else
			-- Reset delete count when key is released
			self.keyRepeat.deleteCount = 0
		end

		-- Escape key
		if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
			if self.autocomplete.visible then
				self.autocomplete.visible = false
			elseif self.buffer.selection.active then
				self.buffer.selection.active = false
			elseif self.clearOnEscape and self:getCharCount() > 0 then
				self:saveHistory()
				self:clear()
				self:validate()
				self:updateAutocomplete()
			elseif self.escapeBlurs then
				self:blur()
			end
		end

		-- Navigation
		local shift = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT) == 1
			or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_SHIFT) == 1
		local ctrl = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1
			or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_CONTROL) == 1
		local alt = raylib.IsKeyDown(const.KeyboardKey.KEY_LEFT_ALT) == 1
			or raylib.IsKeyDown(const.KeyboardKey.KEY_RIGHT_ALT) == 1

		local function updateSelection()
			if shift then
				if not self.buffer.selection.active then
					self.buffer.selection.active = true
					self.buffer.selection.startLine = self.buffer.cursor.line
					self.buffer.selection.startCol = self.buffer.cursor.col
				end
				self.buffer.selection.endLine = self.buffer.cursor.line
				self.buffer.selection.endCol = self.buffer.cursor.col
			else
				self.buffer.selection.active = false
			end
		end

		-- Arrow keys with modifiers
		if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
			if ctrl then
				-- Move word left
				local line = self:getCurrentLine()
				local col = self.buffer.cursor.col
				while col > 1 and not line:sub(col - 1, col - 1):match("[%w_]") do
					col -= 1
				end
				while col > 1 and line:sub(col - 1, col - 1):match("[%w_]") do
					col -= 1
				end
				self.buffer.cursor.col = col
			else
				self.buffer:moveLeft()
			end
			updateSelection()
			self:updateAutocomplete()
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
			if ctrl then
				-- Move word right
				local line = self:getCurrentLine()
				local col = self.buffer.cursor.col
				while col <= #line and line:sub(col, col):match("[%w_]") do
					col += 1
				end
				while col <= #line and not line:sub(col, col):match("[%w_]") do
					col += 1
				end
				self.buffer.cursor.col = col
			else
				self.buffer:moveRight()
			end
			updateSelection()
			self:updateAutocomplete()
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 and self.multiline then
			if alt then
				self:moveLineUp()
			else
				self.buffer:moveUp()
				updateSelection()
				self:updateAutocomplete()
			end
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 and self.multiline then
			if alt then
				self:moveLineDown()
			else
				self.buffer:moveDown()
				updateSelection()
				self:updateAutocomplete()
			end
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_HOME) == 1 then
			if ctrl then
				-- Go to start of document
				self.buffer.cursor.line = 1
				self.buffer.cursor.col = 1
			else
				-- Go to start of line (or first non-whitespace)
				local currentLine = self.buffer.lines[self.buffer.cursor.line]
				local indent = currentLine:match("^(%s*)")
				local targetCol = #indent + 1
				if self.buffer.cursor.col == targetCol then
					self.buffer.cursor.col = 1
				else
					self.buffer.cursor.col = targetCol
				end
			end
			updateSelection()
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_END) == 1 then
			if ctrl then
				-- Go to end of document
				self.buffer.cursor.line = #self.buffer.lines
				self.buffer.cursor.col = #self.buffer.lines[#self.buffer.lines] + 1
			else
				-- Go to end of line
				self.buffer.cursor.col = #self.buffer.lines[self.buffer.cursor.line] + 1
			end
			updateSelection()
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_PAGE_UP) == 1 and self.multiline then
			local linesPerPage = 20
			self.buffer.cursor.line = math.max(1, self.buffer.cursor.line - linesPerPage)
			updateSelection()
		end

		if raylib.IsKeyPressed(const.KeyboardKey.KEY_PAGE_DOWN) == 1 and self.multiline then
			local linesPerPage = 20
			self.buffer.cursor.line = math.min(#self.buffer.lines, self.buffer.cursor.line + linesPerPage)
			updateSelection()
		end

		-- Ctrl shortcuts (using IsKeyPressed for faster response)
		if ctrl then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_C) == 1 then
				local text = self.buffer:getSelectedText()
				if #text > 0 then
					raylib.SetClipboardText(text)
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_X) == 1 then
				local text = self.buffer:getSelectedText()
				if #text > 0 then
					self:saveHistory()
					raylib.SetClipboardText(text)
					self.buffer:deleteSelection()
					if self.onChange then
						self.onChange(self:getText())
					end
					self:validate()
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_A) == 1 then
				self:selectAll()
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_V) == 1 then
				self:saveHistory()
				if self.buffer.selection.active then
					self.buffer:deleteSelection()
				end
				local text = raylib.GetClipboardText()
				local bufferLength = buffer.len(text:span())
				local data = buffer.readstring(text:span(), 0, bufferLength - 1)
				data = string.gsub(data, "\r\n", "\n")
				data = string.gsub(data, "\r", "\n")

				if not self.multiline then
					data = data:gsub("\n", " ")
				end

				-- Check max length
				if self.maxLength then
					local currentLength = #self:getText()
					local availableLength = self.maxLength - currentLength
					if availableLength > 0 then
						data = data:sub(1, availableLength)
					else
						data = ""
					end
				end

				if #data > 0 then
					self.buffer:insertString(data)
					if self.onChange then
						self.onChange(self:getText())
					end
					self:validate()
					self:updateAutocomplete()
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_Z) == 1 then
				if shift then
					self:redo()
				else
					self:undo()
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_Y) == 1 then
				self:redo()
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_D) == 1 and self.multiline then
				self:duplicateLine()
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_F) == 1 then
				self.search.active = not self.search.active
				if self.search.active then
					self.search.query = self.buffer:getSelectedText():gsub("\n", "")
					self:updateSearch()
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_H) == 1 then
				self.replace.active = not self.replace.active
				if self.replace.active then
					self.search.active = true
					self.replace.query = ""
					local sel = self.buffer:getSelectedText()
					if #sel > 0 then
						self.search.query = sel:gsub("\n", "")
						self:updateSearch()
					end
				end
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_SLASH) == 1 and self.multiline then
				self:toggleLineComment()
			elseif shift and raylib.IsKeyPressed(const.KeyboardKey.KEY_K) == 1 and self.multiline then
				self:deleteLine()
			end
		end

		-- F3 for next search result
		if raylib.IsKeyPressed(const.KeyboardKey.KEY_F3) == 1 then
			if shift then
				self:previousSearchResult()
			else
				self:nextSearchResult()
			end
		end
	end

	function TextBox:drawWithExtras(x, y, width, height)
		local originalX, originalY = x, y
		local originalWidth, originalHeight = width, height

		local labelDrawn = false
		local actualTextboxX = x
		local actualTextboxY = y
		local actualTextboxWidth = width
		local actualTextboxHeight = height

		-- Draw label
		if self.label then
			if self.labelPosition == "top" then
				raylib.DrawTextEx(
					vend,
					self.label,
					vector.create(x, y),
					self.fontSize - 2,
					1,
					Color3.new(0.7, 0.7, 0.7):ToRaylib(0)
				)
				actualTextboxY = y + self.fontSize + self.labelGap
				actualTextboxHeight = height - self.fontSize - self.labelGap
			elseif self.labelPosition == "left" then
				raylib.DrawTextEx(
					vend,
					self.label,
					vector.create(x, y + (height / 2) - (self.fontSize / 2)),
					self.fontSize - 2,
					1,
					Color3.new(0.7, 0.7, 0.7):ToRaylib(0)
				)
				actualTextboxX = x + self.labelWidth + self.labelGap
				actualTextboxWidth = width - self.labelWidth - self.labelGap
			elseif self.labelPosition == "right" then
				-- Label will be drawn after textbox
				actualTextboxWidth = width - self.labelWidth - self.labelGap
			end
			labelDrawn = true
		end

		-- Calculate space for prefix/suffix
		local prefixWidth = 0
		local suffixWidth = 0

		if self.prefix then
			prefixWidth = measureTextWidth(self.prefix, self.fontSize - 2, 1) + self.prefixGap * 2
			actualTextboxX = actualTextboxX + prefixWidth
			actualTextboxWidth = actualTextboxWidth - prefixWidth
		end

		if self.suffix then
			suffixWidth = measureTextWidth(self.suffix, self.fontSize - 2, 1) + self.suffixGap * 2
			actualTextboxWidth = actualTextboxWidth - suffixWidth
		end

		-- Calculate space for step buttons
		if self.showStepButtons and self.numeric then
			actualTextboxWidth = actualTextboxWidth - (self.stepButtonWidth * 2)
		end

		-- Calculate space for slider
		local sliderX, sliderY, sliderW, sliderH
		if self.slider then
			if self.sliderPosition == "right" then
				sliderX = actualTextboxX + actualTextboxWidth + self.sliderGap
				sliderY = actualTextboxY
				sliderW = self.sliderWidth
				sliderH = actualTextboxHeight
				actualTextboxWidth = actualTextboxWidth - self.sliderWidth - self.sliderGap
			elseif self.sliderPosition == "left" then
				sliderX = actualTextboxX
				sliderY = actualTextboxY
				sliderW = self.sliderWidth
				sliderH = actualTextboxHeight
				actualTextboxX = actualTextboxX + self.sliderWidth + self.sliderGap
				actualTextboxWidth = actualTextboxWidth - self.sliderWidth - self.sliderGap
			elseif self.sliderPosition == "bottom" then
				sliderX = actualTextboxX
				sliderY = actualTextboxY + actualTextboxHeight + self.sliderGap
				sliderW = actualTextboxWidth
				sliderH = 20
				actualTextboxHeight = actualTextboxHeight - 20 - self.sliderGap
			end
		end

		-- Draw prefix
		if self.prefix then
			local prefixX = actualTextboxX - prefixWidth + self.prefixGap
			local posY = actualTextboxY + (actualTextboxHeight / 2) - (self.fontSize / 2)
			raylib.DrawTextEx(
				vend,
				self.prefix,
				vector.create(prefixX, posY),
				self.fontSize - 2,
				1,
				Color3.new(0.6, 0.6, 0.6):ToRaylib(0)
			)
			raylib.DrawRectangleLines(prefixX, posY, width, height, self.labelOutlineColor:ToRaylib(0))
		end

		-- Draw suffix
		if self.suffix then
			local suffixX = actualTextboxX + actualTextboxWidth + self.suffixGap
			raylib.DrawTextEx(
				vend,
				self.suffix,
				vector.create(suffixX, actualTextboxY + (actualTextboxHeight / 2) - (self.fontSize / 2)),
				self.fontSize - 2,
				1,
				Color3.new(0.6, 0.6, 0.6):ToRaylib(0)
			)
		end

		-- Draw step buttons (if numeric)
		if self.showStepButtons and self.numeric then
			local btnX = actualTextboxX + actualTextboxWidth
			local btnW = self.stepButtonWidth
			local btnH = actualTextboxHeight / 2

			-- Up button
			local upBtnRect = { x = btnX, y = actualTextboxY, width = btnW, height = btnH }
			local mousePos = raylib.GetMousePosition()
			local upHovered = isMouseInRect(upBtnRect, mousePos)

			raylib.DrawRectangle(
				btnX,
				actualTextboxY,
				btnW,
				btnH,
				upHovered and Color3.new(0.15, 0.15, 0.15):ToRaylib(0) or Color3.new(0.1, 0.1, 0.1):ToRaylib(0)
			)
			raylib.DrawRectangleLines(btnX, actualTextboxY, btnW, btnH, self.theme.border)
			raylib.DrawTextEx(vend, "+", vector.create(btnX + 4, actualTextboxY + 2), 10, 1, self.theme.text)

			if raylib.IsMouseButtonPressed(0) == 1 and upHovered then
				self:incrementNumeric()
				self.onSubmit(self:getText())
			end

			-- Down button
			local downBtnRect = { x = btnX, y = actualTextboxY + btnH, width = btnW, height = btnH }
			local downHovered = isMouseInRect(downBtnRect, mousePos)

			raylib.DrawRectangle(
				btnX,
				actualTextboxY + btnH,
				btnW,
				btnH,
				downHovered and Color3.new(0.15, 0.15, 0.15):ToRaylib(0) or Color3.new(0.1, 0.1, 0.1):ToRaylib(0)
			)
			raylib.DrawRectangleLines(btnX, actualTextboxY + btnH, btnW, btnH, self.theme.border)
			raylib.DrawTextEx(vend, "-", vector.create(btnX + 4, actualTextboxY + btnH + 2), 10, 1, self.theme.text)

			if raylib.IsMouseButtonPressed(0) == 1 and downHovered then
				self:decrementNumeric()
				self.onSubmit(self:getText())
			end
		end

		-- Draw slider
		if self.slider then
			local trackColor = Color3.new(0.2, 0.2, 0.2):ToRaylib(0)
			local thumbColor = Color3.new(0.4, 0.6, 1):ToRaylib(0)
			local thumbHoverColor = Color3.new(0.5, 0.7, 1):ToRaylib(0)

			if self.sliderPosition == "right" or self.sliderPosition == "left" then
				-- Vertical slider
				local trackX = sliderX + (sliderW / 2) - 2
				local trackW = 4
				raylib.DrawRectangle(trackX, sliderY, trackW, sliderH, trackColor)

				-- Calculate thumb position
				local range = self.sliderMax - self.sliderMin
				local percent = (self.sliderValue - self.sliderMin) / range
				local thumbY = sliderY + (sliderH - 12) * (1 - percent)
				local thumbX = sliderX + (sliderW / 2) - 6
				local thumbW = 12
				local thumbH = 12

				local mousePos = raylib.GetMousePosition()
				local thumbRect = { x = thumbX, y = thumbY, width = thumbW, height = thumbH }
				local thumbHovered = isMouseInRect(thumbRect, mousePos)

				-- Handle slider interaction
				local sliderRect = { x = sliderX, y = sliderY, width = sliderW, height = sliderH }
				if raylib.IsMouseButtonPressed(0) == 1 and (thumbHovered or isMouseInRect(sliderRect, mousePos)) then
					self.sliderDragging = true
				end

				if self.sliderDragging then
					if raylib.IsMouseButtonDown(0) == 1 then
						local relY = math.clamp(mousePos.y - sliderY, 0, sliderH - 12)
						local percent = 1 - (relY / (sliderH - 12))
						local value = self.sliderMin + (percent * range)

						-- Snap to step
						value = math.floor((value / self.sliderStep) + 0.5) * self.sliderStep

						self:setNumericValue(value)
					else
						self.sliderDragging = false
					end
				end
			else
				-- Horizontal slider
				local trackY = sliderY + (sliderH / 2) - 2
				local trackH = 4
				raylib.DrawRectangle(sliderX, trackY, sliderW, trackH, trackColor)

				-- Calculate thumb position
				local range = self.sliderMax - self.sliderMin
				local percent = (self.sliderValue - self.sliderMin) / range
				local thumbX = sliderX + (sliderW - 12) * percent
				local thumbY = sliderY + (sliderH / 2) - 6
				local thumbW = 12
				local thumbH = 12

				local mousePos = raylib.GetMousePosition()
				local thumbRect = { x = thumbX, y = thumbY, width = thumbW, height = thumbH }
				local thumbHovered = isMouseInRect(thumbRect, mousePos)

				raylib.DrawCircle(
					thumbX + 6,
					thumbY + 6,
					6,
					thumbHovered or self.sliderDragging and thumbHoverColor or thumbColor
				)

				-- Handle slider interaction
				local sliderRect = { x = sliderX, y = sliderY, width = sliderW, height = sliderH }
				if raylib.IsMouseButtonPressed(0) == 1 and (thumbHovered or isMouseInRect(sliderRect, mousePos)) then
					self.sliderDragging = true
				end

				if self.sliderDragging then
					if raylib.IsMouseButtonDown(0) == 1 then
						local relX = math.clamp(mousePos.x - sliderX, 0, sliderW - 12)
						local percent = relX / (sliderW - 12)
						local value = self.sliderMin + (percent * range)

						-- Snap to step
						value = math.floor((value / self.sliderStep) + 0.5) * self.sliderStep

						self:setNumericValue(value)
					else
						self.sliderDragging = false
					end
				end
			end
		end

		-- Draw the actual textbox (call original draw logic)
		self:draw(actualTextboxX, actualTextboxY, actualTextboxWidth, actualTextboxHeight)

		-- Draw right-side label if needed
		if self.label and self.labelPosition == "right" then
			local labelX = actualTextboxX + actualTextboxWidth + self.labelGap
			raylib.DrawTextEx(
				vend,
				self.label,
				vector.create(labelX, actualTextboxY + (actualTextboxHeight / 2) - (self.fontSize / 2)),
				self.fontSize - 2,
				1,
				Color3.new(0.7, 0.7, 0.7):ToRaylib(0)
			)
		end
	end

	return TextBox
end
