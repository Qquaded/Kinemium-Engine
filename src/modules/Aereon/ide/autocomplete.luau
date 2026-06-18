local Autocomplete = {}

local cachedIcons = {}
local raylib = require("@raylib")
local const = raylib.const
local cachedTextures = {}
local Color3 = require("@Color3")

local function getCurrentWord(editor)
	local c = editor.text.cursor
	local line = editor.text.lines[c.line] or ""
	local beforeCursor = line:sub(1, c.col - 1)

	local instanceClass = beforeCursor:match("Instance%.new%s*%(%s*[\"']([%w_]*)$")
	if instanceClass then
		return instanceClass, "Instance.new", true
	end

	-- Check for member access (e.g., math.)
	local library, memberPart = beforeCursor:match("([%w_]+)%.([%w_]*)$")
	if library then
		return memberPart, library, true
	end

	return beforeCursor:match("([%w_]+)$") or "", nil, false
end

local function tokText(t)
	if type(t) == "table" then
		return t.text or ""
	end
	return tostring(t or "")
end

local function unwrap(entry)
	if type(entry) == "table" and entry.node ~= nil then
		return entry.node
	end
	return entry
end

-- Collect all declared identifiers from the AST, tagged with kind
-- Returns: { [name] = { kind = "local"|"function"|"param", line = N } }
local function collectDeclarations(root)
	local decls = {}

	local function reg(name, kind, node)
		if type(name) ~= "string" or #name == 0 then
			return
		end
		local line = node and node.location and node.location.begin.line
		if not decls[name] then
			decls[name] = { kind = kind, line = line }
		end
	end

	local walk -- forward decl

	local function walkBlock(block)
		if type(block) ~= "table" then
			return
		end
		for _, stmt in ipairs(block.statements or {}) do
			walk(stmt)
		end
	end

	local function walkFunctionBody(body, kind)
		if not body then
			return
		end
		-- self parameter
		if body.self then
			reg("self", "param", body)
		end
		-- named parameters
		for _, entry in ipairs(body.parameters or {}) do
			local ln = entry.node or entry
			local n = ln.node or ln
			local name = tokText(n.name)
			reg(name, "param", n)
		end
		-- vararg isn't a name, skip
		walkBlock(body.body)
	end

	walk = function(node)
		if type(node) ~= "table" then
			return
		end
		local tag = node.tag

		if tag == "local" then
			for _, entry in ipairs(node.variables or {}) do
				local ln = entry.node or entry
				local n = ln.node or ln
				reg(tokText(n.name), "local", n)
			end
			-- still walk values for nested functions
			for _, entry in ipairs(node.values or {}) do
				local vn = unwrap(entry)
				if type(vn) == "table" and vn.tag == "function" then
					walkFunctionBody(vn.body or vn, "param")
				end
			end
		elseif tag == "localfunction" then
			local name = tokText((node.name or {}).name or node.name)
			reg(name, "function", node)
			walkFunctionBody(node.body, "param")
		elseif tag == "function" then
			-- global/member function declaration: name is an expr node
			local nameNode = node.name
			if type(nameNode) == "table" then
				if nameNode.tag == "global" then
					reg(tokText(nameNode.name), "function", node)
				elseif nameNode.tag == "indexname" then
					-- e.g. MyClass.method — register the root name only
					local root = nameNode.expression
					if type(root) == "table" and root.tag == "global" then
						reg(tokText(root.name), "variable", node)
					end
				end
			end
			walkFunctionBody(node.body, "param")
		elseif tag == "assign" then
			for _, entry in ipairs(node.variables or {}) do
				local vn = unwrap(entry)
				if type(vn) == "table" and vn.tag == "global" then
					reg(tokText(vn.name), "variable", node)
				end
			end
		elseif tag == "forin" then
			for _, entry in ipairs(node.variables or {}) do
				local ln = entry.node or entry
				local n = ln.node or ln
				reg(tokText(n.name), "local", n)
			end
			walkBlock(node.body)
		elseif tag == "for" then
			local var = node.variable
			local n = (var and (var.node or var)) or {}
			reg(tokText(n.name), "local", n)
			walkBlock(node.body)
		elseif tag == "conditional" then
			walkBlock(node.consequent)
			for _, ei in ipairs(node.elseifs or {}) do
				walkBlock(ei.consequent)
			end
			if node.antecedent then
				walkBlock(node.antecedent)
			end
		elseif tag == "while" or tag == "repeat" or tag == "do" then
			walkBlock(node.body)
		end
	end

	walkBlock(root)
	return decls
end

-- Infer what's being typed at the cursor:
-- Returns: word (string being completed), context (nil | "member"), contextName (string | nil)
-- e.g. typing "math.fl"  → "fl", "member", "math"
--      typing "Instance.new("Pa" → "Pa", "instance_new", nil
--      typing "foo"  → "foo", nil, nil
local function parseContext(line, col)
	local before = line:sub(1, col - 1)

	-- Instance.new("PartialClass
	local instClass = before:match("Instance%.new%s*%(%s*[\"']([%w_]*)$")
	if instClass then
		return instClass, "instance_new", nil
	end

	-- member access: foo.bar or foo:bar
	local obj, accessor, member = before:match("([%w_]+)([%.%:])([%w_]*)$")
	if obj then
		return member, "member", obj, accessor
	end

	-- plain identifier
	local word = before:match("([%w_]*)$") or ""
	return word, nil, nil, nil
end

-- Score a completion item for sorting: exact-prefix > case-insensitive prefix > contains
local function matchScore(label, word)
	if #word == 0 then
		return 1
	end
	local lw = word:lower()
	local ll = label:lower()
	if label:sub(1, #word) == word then
		return 3
	end -- exact case prefix
	if ll:sub(1, #lw) == lw then
		return 2
	end -- icase prefix
	if ll:find(lw, 1, true) then
		return 1
	end -- contains
	return 0
end

--[[
    Main entry point.

    editor: same shape as your existing code uses
      editor.text.cursor  { line, col }
      editor.text.lines   array of strings

    staticCompletions: your existing k_completions table
      each entry: { label, type, icon, members? (for libraries/classes), args? }

    Returns: array of completion items sorted by relevance
      each: { label, type, icon, args? }
--]]
function Autocomplete.getCompletions(editor, staticCompletions, ast)
	local c = editor.text.cursor
	local line = editor.text.lines[c.line] or ""

	local word, context, contextName, accessor = parseContext(line, c.col)

	if #word < 1 and not context then
		return {}
	end

	local items = {}
	local seen = {}

	local function add(label, type_, icon, args)
		if seen[label] then
			return
		end
		local score = matchScore(label, word)
		if score == 0 then
			return
		end
		-- don't suggest the exact word already typed
		if label == word then
			return
		end
		seen[label] = true
		table.insert(items, { label = label, type = type_, icon = icon, args = args, score = score })
	end

	if context == "instance_new" then
		-- only class completions
		for _, item in ipairs(staticCompletions) do
			if item.type == "class" then
				add(item.label, item.type, item.icon or "Class.png", item.args)
			end
		end
	elseif context == "member" then
		-- look up contextName in static completions first
		local found = false
		for _, item in ipairs(staticCompletions) do
			if item.label == contextName and item.members then
				for _, m in ipairs(item.members) do
					add(m.label, m.type, m.icon, m.args)
				end
				found = true
				break
			end
		end

		-- fall back to AST-derived dynamic members if static didn't cover it
		-- (your existing dynamicVariables table can be passed in here)
		if not found and ast and ast.dynamicVariables then
			local dv = ast.dynamicVariables[contextName]
			if dv and dv.members then
				for _, m in ipairs(dv.members) do
					add(m.label, m.type, m.icon, m.args)
				end
			end
		end
	else
		-- global scope: static + AST-declared names
		for _, item in ipairs(staticCompletions) do
			-- skip member-only items (those only live under a library)
			if item.type ~= "member" then
				add(item.label, item.type, item.icon, item.args)
			end
		end

		-- AST declarations
		if ast and ast.root then
			local decls = collectDeclarations(ast.root)
			for name, info in pairs(decls) do
				if not seen[name] and matchScore(name, word) > 0 then
					local icon = info.kind == "function" and "Method.png" or "Variable.png"
					seen[name] = true
					table.insert(items, { label = name, type = info.kind, icon = icon, score = matchScore(name, word) })
				end
			end
		end
	end

	-- sort: higher score first, then alphabetical
	table.sort(items, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.label < b.label
	end)

	-- strip internal score field before returning
	for _, item in ipairs(items) do
		item.score = nil
	end

	return items
end

-- Convenience: get just the word being typed (for the calling code to know
-- how many chars to delete on completion)
function Autocomplete.getCurrentWord(editor)
	local c = editor.text.cursor
	local line = editor.text.lines[c.line] or ""
	local word, context, contextName, accessor = parseContext(line, c.col)
	return word, context, contextName, accessor
end

function Autocomplete.cycleSnippet(editor)
	if not editor.snippet or not editor.snippet.active then
		return false
	end

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

function Autocomplete.getIndentLevel(line)
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

function Autocomplete.completeWord(editor)
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

function Autocomplete.step(
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

		local viewportW, viewportH
		if type(raylib.GetRenderWidth) == "function" and type(raylib.GetRenderHeight) == "function" then
			viewportW = raylib.GetRenderWidth()
			viewportH = raylib.GetRenderHeight()
		elseif type(raylib.GetScreenWidth) == "function" and type(raylib.GetScreenHeight) == "function" then
			viewportW = raylib.GetScreenWidth()
			viewportH = raylib.GetScreenHeight()
		else
			viewportW = x + acWidth + 8
			viewportH = y + acHeight + 8
		end

		local pad = 4
		local minX = pad
		local maxX = math.max(minX, viewportW - acWidth - pad)
		local minY = pad
		local maxY = math.max(minY, viewportH - acHeight - pad)

		local belowY = cy + lineHeight + 5
		local aboveY = cy - acHeight - 5
		local spaceAbove = cy - minY
		local spaceBelow = (viewportH - pad) - (cy + lineHeight)

		local targetY
		if spaceAbove >= acHeight or spaceAbove >= spaceBelow then
			targetY = aboveY
		else
			targetY = belowY
		end

		local targetX = math.clamp(cx, minX, maxX)
		targetY = math.clamp(targetY, minY, maxY)

		editor.autocomplete.targetX = targetX
		editor.autocomplete.targetY = targetY

		local lerpFactor = 1 - math.exp(-editor.autocomplete.lerpSpeed * dt)
		editor.autocomplete.currentX = (editor.autocomplete.currentX or targetX)
			+ (targetX - (editor.autocomplete.currentX or targetX)) * lerpFactor
		editor.autocomplete.currentY = (editor.autocomplete.currentY or targetY)
			+ (targetY - (editor.autocomplete.currentY or targetY)) * lerpFactor

		local acX, acY = editor.autocomplete.currentX, editor.autocomplete.currentY
		local background = rect.new(acX, acY, acWidth, acHeight)

		raylib.DrawRectangleRounded(rect:translate(background), 0.1, 15, Color3.new(0.12, 0.12, 0.12):ToRaylib(0))
		raylib.DrawRectangleRoundedLinesEx(
			rect:translate(background),
			0.1,
			15,
			1,
			Color3.new(0.2, 0.2, 0.2):ToRaylib(0)
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
					Color3.new(0.04, 0.35, 0.61):ToRaylib(0) -- VS Code blue
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
				Color3.new(0.6, 0.6, 0.6):ToRaylib(0)
			)
		end
	else
		editor.autocomplete.currentX = editor.autocomplete.targetX
		editor.autocomplete.currentY = editor.autocomplete.targetY
	end
end

return Autocomplete
