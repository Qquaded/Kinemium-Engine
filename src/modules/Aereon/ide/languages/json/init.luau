local function addToken(tokens, text, category)
	table.insert(tokens, { text = text, category = category })
end

local function highlightLine(line)
	local tokens = {}
	local i = 1
	while i <= #line do
		local ch = line:sub(i, i)

		if ch == '"' then
			local j = i + 1
			while j <= #line do
				local c = line:sub(j, j)
				if c == "\\" and j < #line then
					j = j + 2
				elseif c == '"' then
					j = j + 1
					break
				else
					j = j + 1
				end
			end
			local k = j
			while k <= #line and line:sub(k, k):match("%s") do
				k = k + 1
			end
			local isKey = line:sub(k, k) == ":"
			addToken(tokens, line:sub(i, j - 1), isKey and "key" or "string")
			i = j
		elseif ch:match("[%-%d]") then
			local j = i
			while j <= #line and line:sub(j, j):match("[%d%.eE%+%-]") do
				j = j + 1
			end
			addToken(tokens, line:sub(i, j - 1), "number")
			i = j
		elseif line:sub(i, i + 3) == "true" then
			addToken(tokens, "true", "boolean")
			i += 4
		elseif line:sub(i, i + 4) == "false" then
			addToken(tokens, "false", "boolean")
			i += 5
		elseif line:sub(i, i + 3) == "null" then
			addToken(tokens, "null", "keyword")
			i += 4
		elseif ch:match("[{}%[%],:]") then
			addToken(tokens, ch, "operator")
			i += 1
		else
			addToken(tokens, ch, "default")
			i += 1
		end
	end
	return tokens
end

local function format(code)
	local ok, decoded = pcall(function()
		return zune.serde.json.decode(code)
	end)
	if not ok then
		return nil, "invalid json"
	end
	local ok2, encoded = pcall(function()
		return zune.serde.json.encode(decoded, { prettyIndent = "\t" })
	end)
	if not ok2 then
		return nil, encoded
	end
	return encoded
end

local function parseErrors(code)
	local ok, err = pcall(function()
		zune.serde.json.decode(code)
	end)
	if ok then
		return {}
	end

	return {
		{
			message = tostring(err),
			location = { begin = { line = 1, column = 1 }, ["end"] = { line = 1, column = 1 } },
		},
	}
end

return {
	id = "json",
	extensions = { "json" },
	commentPrefix = nil,
	blockOpenChars = { "{", "[" },
	blockCloseChars = { "}", "]" },
	highlight = highlightLine,
	format = format,
	parseErrors = parseErrors,
}
