local raylib = require("@raylib")
local const = raylib.const
local Color3 = require("@Color3")

local cachedIcons = {}
local cachedTextures = {}

local completions = {
	{ label = "function", type = "keyword", icon = "Keyword.png" },
	{ label = "local", type = "keyword", icon = "Keyword.png" },
	{ label = "return", type = "keyword", icon = "Keyword.png" },
	{ label = "if", type = "keyword", icon = "Keyword.png" },
	{ label = "then", type = "keyword", icon = "Keyword.png" },
	{ label = "else", type = "keyword", icon = "Keyword.png" },
	{ label = "elseif", type = "keyword", icon = "Keyword.png" },
	{ label = "while", type = "keyword", icon = "Keyword.png" },
	{ label = "for", type = "keyword", icon = "Keyword.png" },
	{ label = "do", type = "keyword", icon = "Keyword.png" },
	{ label = "break", type = "keyword", icon = "Keyword.png" },
	{ label = "continue", type = "keyword", icon = "Keyword.png" },
	{ label = "in", type = "keyword", icon = "Keyword.png" },
	{ label = "repeat", type = "keyword", icon = "Keyword.png" },
	{ label = "until", type = "keyword", icon = "Keyword.png" },
	{ label = "nil", type = "keyword", icon = "Keyword.png" },
	{ label = "true", type = "keyword", icon = "Keyword.png" },
	{ label = "false", type = "keyword", icon = "Keyword.png" },
	{ label = "and", type = "keyword", icon = "Keyword.png" },
	{ label = "or", type = "keyword", icon = "Keyword.png" },
	{ label = "not", type = "keyword", icon = "Keyword.png" },
	{ label = "end", type = "keyword", icon = "Keyword.png" },

	{ label = "print", type = "function", icon = "Function.png", args = { "..." } },
	{ label = "warn", type = "function", icon = "Function.png", args = { "..." } },
	{ label = "error", type = "function", icon = "Function.png", args = { "message", "level" } },
	{ label = "assert", type = "function", icon = "Function.png", args = { "v", "message" } },
	{ label = "typeof", type = "function", icon = "Function.png", args = { "v" } },
	{ label = "type", type = "function", icon = "Function.png", args = { "v" } },
	{ label = "require", type = "function", icon = "Method.png", args = { "module" } },
	{ label = "import", type = "function", icon = "Method.png", args = { "path" } },
	{ label = "include", type = "function", icon = "Method.png", args = { "path" } },
	{ label = "pairs", type = "function", icon = "Function.png", args = { "t" } },
	{ label = "ipairs", type = "function", icon = "Function.png", args = { "t" } },
	{ label = "next", type = "function", icon = "Function.png", args = { "t", "last" } },
	{ label = "tonumber", type = "function", icon = "Function.png", args = { "e", "base" } },
	{ label = "tostring", type = "function", icon = "Function.png", args = { "e" } },
	{ label = "getmetatable", type = "function", icon = "Function.png", args = { "obj" } },
	{ label = "setmetatable", type = "function", icon = "Function.png", args = { "obj", "mt" } },

	{
		label = "table",
		type = "library",
		icon = "Module.png",
		members = {
			{ label = "insert", type = "method", icon = "Method.png", args = { "t", "v" } },
			{ label = "remove", type = "method", icon = "Method.png", args = { "t", "pos" } },
			{ label = "sort", type = "method", icon = "Method.png", args = { "t", "comp" } },
			{ label = "concat", type = "method", icon = "Method.png", args = { "t", "sep" } },
			{ label = "find", type = "method", icon = "Method.png", args = { "t", "v" } },
			{ label = "clear", type = "method", icon = "Method.png", args = { "t" } },
		},
	},
	{
		label = "math",
		type = "library",
		icon = "Module.png",
		members = {
			{ label = "abs", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "floor", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "ceil", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "sin", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "cos", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "tan", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "sqrt", type = "method", icon = "Method.png", args = { "x" } },
			{ label = "random", type = "method", icon = "Method.png", args = { "m", "n" } },
			{ label = "min", type = "method", icon = "Method.png", args = { "..." } },
			{ label = "max", type = "method", icon = "Method.png", args = { "..." } },
			{ label = "pi", type = "constant", icon = "Variable.png" },
			{ label = "huge", type = "constant", icon = "Variable.png" },
		},
	},
	{
		label = "string",
		type = "library",
		icon = "Module.png",
		members = {
			{ label = "sub", type = "method", icon = "Method.png", args = { "s", "i", "j" } },
			{ label = "find", type = "method", icon = "Method.png", args = { "s", "p", "init" } },
			{ label = "gsub", type = "method", icon = "Method.png", args = { "s", "p", "r" } },
			{ label = "match", type = "method", icon = "Method.png", args = { "s", "p" } },
			{ label = "lower", type = "method", icon = "Method.png", args = { "s" } },
			{ label = "upper", type = "method", icon = "Method.png", args = { "s" } },
			{ label = "len", type = "method", icon = "Method.png", args = { "s" } },
			{ label = "format", type = "method", icon = "Method.png", args = { "s", "..." } },
		},
	},
	{
		label = "task",
		type = "library",
		icon = "Module.png",
		members = {
			{ label = "wait", type = "method", icon = "Method.png", args = { "t" } },
			{ label = "spawn", type = "method", icon = "Method.png", args = { "f", "..." } },
			{ label = "defer", type = "method", icon = "Method.png", args = { "f", "..." } },
			{ label = "delay", type = "method", icon = "Method.png", args = { "t", "f", "..." } },
		},
	},

	{
		label = "game",
		type = "global",
		icon = "Service.png",
		members = {
			{ label = "GetService", type = "method", icon = "Method.png", args = { "name" } },
		},
	},
	{ label = "workspace", type = "global", icon = "Service.png" },
	{ label = "Lighting", type = "global", icon = "Service.png" },
	{ label = "Players", type = "global", icon = "Service.png" },
	{ label = "ReplicatedStorage", type = "global", icon = "Service.png" },
	{ label = "Vector3", type = "class", icon = "Struct.png", members = { { label = "new", icon = "Method.png", args = { "x", "y", "z" } } } },
	{ label = "CFrame", type = "class", icon = "Struct.png", members = { { label = "new", icon = "Method.png", args = { "pos", "lookAt" } } } },
	{ label = "Color3", type = "class", icon = "Struct.png", members = { { label = "new", icon = "Method.png", args = { "r", "g", "b" } }, { label = "fromRGB", icon = "Method.png", args = { "r", "g", "b" } } } },
	{ label = "Instance", type = "class", icon = "Class.png", members = { { label = "new", icon = "Method.png", args = { "className", "parent" } } } },
	{ label = "Enum", type = "class", icon = "Enum.png" },
}


local dynamicVariables = {}

local function getObjectMembers(obj)
	local members = {}
	if type(obj) ~= "table" and type(obj) ~= "userdata" then
		return members
	end

	local seen = {}

	local function addMembers(t)
		for k, v in pairs(t) do
			if type(k) == "string" and not seen[k] then
				local memberType = type(v) == "function" and "method" or "variable"
				local icon = memberType == "method" and "Method.png" or "Variable.png"
				table.insert(members, { label = k, type = memberType, icon = icon })
				seen[k] = true
			end
		end
	end

	addMembers(obj)
	local mt = getmetatable(obj)
	if mt and mt.__index then
		if type(mt.__index) == "table" then
			addMembers(mt.__index)
		elseif type(mt.__index) == "function" then
			-- Can't easily introspect a function __index without calling it
		end
	end

	return members
end

local function indexVariables(editor, game)
	dynamicVariables = {}
	for _, line in ipairs(editor.text.lines) do
		-- Match local X = game:GetService("Y")
		local varName, serviceName = line:match("local%s+([%w_]+)%s*=%s*game:GetService%s*%(%s*[\"']([^\"']+)[\"']%s*%)")
		if varName and serviceName then
			local success, service = pcall(function()
				return game:GetService(serviceName)
			end)
			if success and service then
				dynamicVariables[varName] = {
					type = "service",
					name = serviceName,
					members = getObjectMembers(service),
				}
			end
		end

		-- Match local X = require(path/instance)
		local varName2, requirePath = line:match("local%s+([%w_]+)%s*=%s*require%s*%(%s*[\"']([^\"']+)[\"']%s*%)")
		if varName2 and requirePath then
			local success, lib = pcall(function()
				return require(requirePath)
			end)
			if success and lib then
				dynamicVariables[varName2] = {
					type = "library",
					name = requirePath,
					members = getObjectMembers(lib),
				}
			end
		end
	end
end

local function getCurrentWord(editor)
	local c = editor.text.cursor
	local line = editor.text.lines[c.line] or ""
	local beforeCursor = line:sub(1, c.col - 1)

	-- Check for member access (e.g., math.)
	local library, memberPart = beforeCursor:match("([%w_]+)%.([%w_]*)$")
	if library then
		return memberPart, library, true
	end

	return beforeCursor:match("([%w_]+)$") or "", nil, false
end

local function getDynamicCompletions(editor)
	local dynamic = {}
	local seen = {}
	for _, line in ipairs(editor.text.lines) do
		for word in line:gmatch("[%w_]+") do
			if #word > 2 and not seen[word] then
				table.insert(dynamic, { label = word, type = "variable", icon = "Variable.png" })
				seen[word] = true
			end
		end
	end
	return dynamic
end

local function updateAutocomplete(editor, game)
	if editor.text.selection.active then
		editor.autocomplete.visible = false
		return
	end

	local word, libraryName, isMember = getCurrentWord(editor)

	if #word < 1 and not isMember then
		editor.autocomplete.visible = false
		return
	end

	local items = {}
	local seen = {}

	local function addIfMatch(list)
		for _, item in ipairs(list) do
			if item.label:lower():sub(1, #word) == word:lower() and item.label ~= word and not seen[item.label] then
				table.insert(items, item)
				seen[item.label] = true
			end
		end
	end

	if isMember then
		-- Search for the library in completions
		local libraryItem
		for _, item in ipairs(completions) do
			if item.label == libraryName then
				libraryItem = item
				break
			end
		end

		if libraryItem and libraryItem.members then
			addIfMatch(libraryItem.members)
		elseif dynamicVariables[libraryName] then
			addIfMatch(dynamicVariables[libraryName].members)
		end
	else
		addIfMatch(completions)
		addIfMatch(getDynamicCompletions(editor))

		-- Add dynamic variables themselves to root completions
		for varName, data in pairs(dynamicVariables) do
			if varName:lower():sub(1, #word) == word:lower() and varName ~= word and not seen[varName] then
				table.insert(items, {
					label = varName,
					type = data.type,
					icon = data.type == "service" and "Service.png" or "Module.png",
				})
				seen[varName] = true
			end
		end
	end

	if #items > 0 then
		table.sort(items, function(a, b)
			return a.label < b.label
		end)
		editor.autocomplete.items = items
		editor.autocomplete.visible = true
		editor.autocomplete.selectedIndex = 1
	else
		editor.autocomplete.visible = false
	end
end

local function completeWord(editor)
	if not editor.autocomplete.visible or #editor.autocomplete.items == 0 then
		return
	end

	local item = editor.autocomplete.items[editor.autocomplete.selectedIndex]
	local word = getCurrentWord(editor)

	for i = 1, #word do
		editor.text:backspace()
	end

	if item.args and #item.args > 0 then
		local snippetStr = item.label .. "("
		local argPositions = {}
		
		for i, arg in ipairs(item.args) do
			local startPos = #snippetStr 
			snippetStr = snippetStr .. arg
			local endPos = #snippetStr
			table.insert(argPositions, { start = startPos, ["end"] = endPos, label = arg })
			
			if i < #item.args then
				snippetStr = snippetStr .. ", "
			end
		end
		snippetStr = snippetStr .. ")"
		
		editor.text:insertString(snippetStr)
		
		editor.snippet = {
			active = true,
			index = 1,
			positions = argPositions,
			line = editor.text.cursor.line,
			startCol = editor.text.cursor.col - #snippetStr,
		}
		
		local firstArg = argPositions[1]
		editor.text.cursor.col = editor.snippet.startCol + firstArg["end"]
		editor.text.selection.active = true
		editor.text.selection.startLine = editor.snippet.line
		editor.text.selection.startCol = editor.snippet.startCol + firstArg.start
		editor.text.selection.endLine = editor.snippet.line
		editor.text.selection.endCol = editor.snippet.startCol + firstArg["end"]
	else
		editor.text:insertString(item.label)
	end
	
	editor.autocomplete.visible = false
end

local function cycleSnippet(editor)
	if not editor.snippet or not editor.snippet.active then return false end
	
	editor.snippet.index = editor.snippet.index + 1
	if editor.snippet.index > #editor.snippet.positions then
		editor.snippet.active = false
		editor.text.selection.active = false

		local lastArg = editor.snippet.positions[#editor.snippet.positions]
		editor.text.cursor.col = editor.snippet.startCol + lastArg["end"] + 2
		return true
	end
	
	local arg = editor.snippet.positions[editor.snippet.index]
	
	editor.text.cursor.col = editor.snippet.startCol + arg["end"]
	editor.text.selection.active = true
	editor.text.selection.startLine = editor.snippet.line
	editor.text.selection.startCol = editor.snippet.startCol + arg.start
	editor.text.selection.endLine = editor.snippet.line
	editor.text.selection.endCol = editor.snippet.startCol + arg["end"]
	
	return true
end

local function getIndentLevel(line)
	local tabs = line:match("^\t+")
	if tabs then
		return #tabs
	end
	local spaces = line:match("^ +")
	if spaces then
		return math.floor(#spaces / 4)
	end
	return 0
end

return {
	completions = completions,
	getCurrentWord = getCurrentWord,
	updateAutocomplete = updateAutocomplete,
	indexVariables = indexVariables,
	completeWord = completeWord,
	cycleSnippet = cycleSnippet,
	getIndentLevel = getIndentLevel,
	step = function(
		editor,
		x,
		gutterwidth,
		padding,
		measureTextWidth,
		fontSize,
		spaces,
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
		if editor.isActive and editor.autocomplete.visible then
			local c = editor.text.cursor
			local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			local acWidth = 240 -- wider for icons
			local acItemHeight = 24
			local acPadding = 8
			local iconSize = 16
			local maxVisible = 10
			local acHeight = math.min(#editor.autocomplete.items, maxVisible) * acItemHeight

			local targetX = cx
			local targetY = cy - acHeight - 5
			if targetY < y then
				targetY = cy + lineHeight + 5
			end

			editor.autocomplete.targetX = targetX
			editor.autocomplete.targetY = targetY

			local lerpFactor = 1 - math.exp(-editor.autocomplete.lerpSpeed * dt)
			editor.autocomplete.currentX = (editor.autocomplete.currentX or targetX)
				+ (targetX - (editor.autocomplete.currentX or targetX)) * lerpFactor
			editor.autocomplete.currentY = (editor.autocomplete.currentY or targetY)
				+ (targetY - (editor.autocomplete.currentY or targetY)) * lerpFactor

			local acX, acY = editor.autocomplete.currentX, editor.autocomplete.currentY
			local background = rect.new(acX, acY, acWidth, acHeight)

			raylib.DrawRectangleRounded(
				rect:translate(background),
				0.1,
				15,
				Color3ToRaylib(Color3.new(0.12, 0.12, 0.12), 0)
			)
			raylib.DrawRectangleRoundedLinesEx(
				rect:translate(background),
				0.1,
				15,
				1,
				Color3ToRaylib(Color3.new(0.2, 0.2, 0.2), 0)
			)

			for i = 1, math.min(#editor.autocomplete.items, maxVisible) do
				local item = editor.autocomplete.items[i]
				local itemY = acY + (i - 1) * acItemHeight
				--local itemRect = rect.new(acX, itemY, acWidth, acItemHeight)

				if i == editor.autocomplete.selectedIndex then
					raylib.DrawRectangleRounded(
						rect:translate(rect.new(acX + 2, itemY + 1, acWidth - 4, acItemHeight - 2)),
						0.1,
						15,
						Color3ToRaylib(Color3.new(0.04, 0.35, 0.61), 0) -- VS Code blue
					)
				end

				local iconPath = cachedIcons[item.icon] or IconLoader.Get(item.icon)
				if iconPath then
					cachedIcons[item.icon] = iconPath
					local textureData = cachedTextures[iconPath]
					if not textureData then
						textureData = IconLoader.ToTexture(iconPath)
						cachedTextures[iconPath] = textureData
					end

					if textureData and textureData.texture then
						local iconX = acX + acPadding
						local iconY = itemY + (acItemHeight - iconSize) / 2
						raylib.DrawTexturePro(
							textureData.texture,
							rect:translate(rect.new(0, 0, textureData.x, textureData.y)),
							rect:translate(rect.new(iconX, iconY, iconSize, iconSize)),
							vector.create(0, 0),
							0,
							const.WHITE
						)
					end
				end

				raylib.DrawTextEx(
					vend,
					item.label,
					vector.create(acX + acPadding + iconSize + 6, itemY + (acItemHeight - (fontSize - 4)) / 2),
					fontSize - 4,
					spacing,
					theme_text
				)

				local typeText = item.type
				local tw = measureTextWidth(typeText, fontSize - 6, spacing)
				raylib.DrawTextEx(
					vend,
					typeText,
					vector.create(acX + acWidth - tw - acPadding, itemY + (acItemHeight - (fontSize - 6)) / 2),
					fontSize - 6,
					spacing,
					Color3ToRaylib(Color3.new(0.6, 0.6, 0.6), 0)
				)
			end
		else
			editor.autocomplete.currentX = editor.autocomplete.targetX
			editor.autocomplete.currentY = editor.autocomplete.targetY
		end
	end,
}
