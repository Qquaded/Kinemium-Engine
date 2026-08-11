local adapter = require("@RaylibAdapter")
local const = adapter.const

local COLORS = {
	keyword = const.SKYBLUE,
	builtin = const.MAGENTA,
	stdlib = const.VIOLET,
	string = const.GREEN,
	number = const.ORANGE,
	operator = const.BLUE,
	comment = const.GRAY,
	field = const.YELLOW,
	method = const.YELLOW,
	functionName = const.GOLD,
	default = const.WHITE,
}

local keywords = {
	["local"] = true,
	["function"] = true,
	["if"] = true,
	["then"] = true,
	["end"] = true,
	["while"] = true,
	["for"] = true,
	["do"] = true,
	["return"] = true,
	["break"] = true,
	["else"] = true,
	["elseif"] = true,
	["repeat"] = true,
	["until"] = true,
	["in"] = true,
	["import"] = true,
	["include"] = true,
	["goto"] = true,
}

local builtins = {
	["true"] = true,
	["false"] = true,
	["nil"] = true,
	["and"] = true,
	["or"] = true,
	["not"] = true,
	["self"] = true,
}

local stdlib = {
	-- Basic functions
	["print"] = true,
	["require"] = true,
	["assert"] = true,
	["error"] = true,
	["warn"] = true,
	["type"] = true,
	["typeof"] = true,
	["tonumber"] = true,
	["tostring"] = true,

	-- Iteration
	["pairs"] = true,
	["ipairs"] = true,
	["next"] = true,

	-- Metatables
	["getmetatable"] = true,
	["setmetatable"] = true,
	["rawget"] = true,
	["rawset"] = true,
	["rawequal"] = true,
	["rawlen"] = true,

	-- Function manipulation
	["pcall"] = true,
	["xpcall"] = true,
	["select"] = true,

	-- Module loading
	["dofile"] = true,
	["loadfile"] = true,
	["load"] = true,
	["loadstring"] = true,

	-- Environment
	["_G"] = true,
	["_VERSION"] = true,

	-- Standard libraries
	["table"] = true,
	["string"] = true,
	["math"] = true,
	["io"] = true,
	["os"] = true,
	["debug"] = true,
	["coroutine"] = true,
	["package"] = true,
	["utf8"] = true,

	-- Coroutine functions
	["collectgarbage"] = true,
}

local twoCharOps = {
	["=="] = true,
	["~="] = true,
	["<="] = true,
	[">="] = true,
	[".."] = true,
	["//"] = true,
	["<<"] = true,
	[">>"] = true,
}

local singleCharOps = {
	["+"] = true,
	["-"] = true,
	["*"] = true,
	["/"] = true,
	["="] = true,
	["<"] = true,
	[">"] = true,
	["#"] = true,
	["%"] = true,
	["^"] = true,
	["&"] = true,
	["|"] = true,
	["~"] = true,
}

local function addToken(tokens, text, color)
	table.insert(tokens, { text = text, color = color })
end

local function parseString(text, i, tokens)
	local quote = text:sub(i, i)
	local j = i + 1

	-- Handle long strings [[...]]
	if quote == "[" then
		local equals = ""
		local k = i + 1
		while k <= #text and text:sub(k, k) == "=" do
			equals = equals .. "="
			k = k + 1
		end

		if k <= #text and text:sub(k, k) == "[" then
			-- This is a long string
			local closing = "]" .. equals .. "]"
			local endPos = text:find(closing, k + 1, true)
			if endPos then
				addToken(tokens, text:sub(i, endPos + #closing - 1), COLORS.string)
				return endPos + #closing
			else
				-- Unclosed long string
				addToken(tokens, text:sub(i), COLORS.string)
				return #text + 1
			end
		end
		-- Not a long string, treat as regular character
		addToken(tokens, "[", COLORS.default)
		return i + 1
	end

	-- Regular quoted strings
	while j <= #text do
		local char = text:sub(j, j)

		if char == "\\" and j < #text then
			j = j + 2 -- Skip escaped character
		elseif char == quote then
			-- Found closing quote
			addToken(tokens, text:sub(i, j), COLORS.string)
			return j + 1
		else
			j = j + 1
		end
	end

	-- Unclosed string (goes to end of line)
	addToken(tokens, text:sub(i), COLORS.string)
	return #text + 1
end

-- Parse number literals (including hex, binary, scientific notation)
local function parseNumber(text, i, tokens)
	local j = i
	local isHex = false
	local isBinary = false

	-- Check for hex (0x) or binary (0b)
	if text:sub(j, j) == "0" and j < #text then
		local next = text:sub(j + 1, j + 1):lower()
		if next == "x" then
			isHex = true
			j = j + 2
		elseif next == "b" then
			isBinary = true
			j = j + 2
		end
	end

	-- Parse the number
	while j <= #text do
		local char = text:sub(j, j):lower()

		if isHex and char:match("[0-9a-f]") then
			j = j + 1
		elseif isBinary and char:match("[01]") then
			j = j + 1
		elseif not isHex and not isBinary and char:match("[0-9]") then
			j = j + 1
		elseif char == "." and not isHex and not isBinary then
			j = j + 1
		elseif char == "e" and not isHex and not isBinary then
			-- Scientific notation
			j = j + 1
			if j <= #text and text:sub(j, j):match("[+-]") then
				j = j + 1
			end
		else
			break
		end
	end

	addToken(tokens, text:sub(i, j - 1), COLORS.number)
	return j
end

-- Parse identifier (keyword, builtin, stdlib, or regular identifier)
local function parseIdentifier(text, i, tokens)
	local j = i

	while j <= #text and text:sub(j, j):match("[%w_]") do
		j = j + 1
	end

	local word = text:sub(i, j - 1)
	local color = COLORS.default

	-- Skip whitespace after identifier
	local k = j
	while k <= #text and text:sub(k, k):match("%s") do
		k = k + 1
	end

	-- Check what comes after the identifier
	local nextChar = k <= #text and text:sub(k, k) or ""

	-- Check for function declaration (function name() or local function name())
	-- This checks if we're after "function" keyword
	if #tokens > 0 then
		local prevToken = tokens[#tokens]
		if prevToken.text == "function" then
			-- This is a function name declaration
			addToken(tokens, word, COLORS.functionName)
			return j
		end
	end

	-- Check for function call or method call
	if nextChar == "(" then
		-- Check if previous token is a dot or colon (method call)
		if #tokens > 0 then
			local prevToken = tokens[#tokens]
			if prevToken.text == "." or prevToken.text == ":" then
				color = COLORS.method
			else
				-- Regular function call
				color = stdlib[word] and COLORS.stdlib or COLORS.functionName
			end
		else
			-- Function call at start of line
			color = stdlib[word] and COLORS.stdlib or COLORS.functionName
		end
	-- Check for keywords, builtins, stdlib
	elseif keywords[word] then
		color = COLORS.keyword
	elseif builtins[word] then
		color = COLORS.builtin
	elseif stdlib[word] then
		color = COLORS.stdlib
	end

	addToken(tokens, word, color)
	return j
end

-- Parse field/method access (e.g., obj.field = value or obj:method())
local function parseFieldOrMethod(text, i, tokens, separator)
	-- Add the separator (. or :)
	addToken(tokens, separator, COLORS.default)

	local j = i + 1
	if j > #text or not text:sub(j, j):match("[%a_]") then
		return j
	end

	-- Find the end of the identifier
	local k = j
	while k <= #text and text:sub(k, k):match("[%w_]") do
		k = k + 1
	end

	-- Skip whitespace
	local m = k
	while m <= #text and text:sub(m, m):match("%s") do
		m = m + 1
	end

	-- Determine color based on context
	local nextChar = m <= #text and text:sub(m, m) or ""
	local fieldColor = COLORS.default

	if separator == ":" then
		-- Colon always means method call
		fieldColor = COLORS.method
	elseif nextChar == "(" then
		-- Dot followed by parentheses is a method/function call
		fieldColor = COLORS.method
	else
		-- Check if this is being assigned to
		local remaining = text:sub(k)
		local hasAssignment = remaining:match("^%s*=") and not remaining:match("^%s*==")
		fieldColor = hasAssignment and COLORS.field or COLORS.default
	end

	addToken(tokens, text:sub(j, k - 1), fieldColor)
	return k
end

-- Main tokenization function
local function processTokens(text, tokens)
	local i = 1

	while i <= #text do
		local char = text:sub(i, i)
		local twoChar = text:sub(i, i + 1)

		-- String literals (including long strings)
		if char == '"' or char == "'" or char == "[" then
			local saved_i = i
			i = parseString(text, i, tokens)
			-- If parseString didn't consume the [, it's not a string
			if char == "[" and i == saved_i + 1 then
				-- Already added by parseString as default
			end

		-- Numbers
		elseif char:match("%d") then
			i = parseNumber(text, i, tokens)

		-- Identifiers (keywords, builtins, stdlib, variables)
		elseif char:match("[%a_]") then
			i = parseIdentifier(text, i, tokens)

		-- Method call with colon
		elseif char == ":" then
			local nextChar = text:sub(i + 1, i + 1)
			if nextChar:match("[%a_]") then
				i = parseFieldOrMethod(text, i, tokens, ":")
			else
				addToken(tokens, char, COLORS.default)
				i = i + 1
			end

		-- Field access with dot
		elseif char == "." then
			local nextChar = text:sub(i + 1, i + 1)
			if nextChar:match("[%a_]") then
				i = parseFieldOrMethod(text, i, tokens, ".")
			elseif nextChar:match("%d") then
				-- Number starting with .
				i = parseNumber(text, i, tokens)
			elseif nextChar == "." then
				-- Could be .. or ...
				if text:sub(i + 2, i + 2) == "." then
					addToken(tokens, "...", COLORS.default)
					i = i + 3
				else
					-- .. operator
					addToken(tokens, "..", COLORS.operator)
					i = i + 2
				end
			else
				addToken(tokens, char, COLORS.default)
				i = i + 1
			end

		-- Two-character operators
		elseif twoCharOps[twoChar] then
			addToken(tokens, twoChar, COLORS.operator)
			i = i + 2

		-- Single-character operators
		elseif singleCharOps[char] then
			addToken(tokens, char, COLORS.operator)
			i = i + 1

		-- Punctuation and other symbols
		elseif char:match("[%(%)%[%]{}:;,]") then
			addToken(tokens, char, COLORS.default)
			i = i + 1

		-- Whitespace and other characters
		else
			addToken(tokens, char, COLORS.default)
			i = i + 1
		end
	end
end

-- Main highlight function
local function highlightLine(line)
	local tokens = {}

	-- Handle comments
	local commentStart = line:find("%-%-")
	if commentStart then
		-- Check if it's a long comment --[[...]]
		if line:sub(commentStart, commentStart + 3) == "--[[" then
			-- This is a long comment start
			addToken(tokens, line, COLORS.comment)
			return tokens
		end

		local beforeComment = line:sub(1, commentStart - 1)
		local comment = line:sub(commentStart)

		if #beforeComment > 0 then
			processTokens(beforeComment, tokens)
		end

		addToken(tokens, comment, COLORS.comment)
		return tokens
	end

	processTokens(line, tokens)
	return tokens
end

return {
	highlight = highlightLine,
	colors = COLORS,
}
