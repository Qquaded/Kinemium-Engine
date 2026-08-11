local function highlightLine(line)
	local tokens = {}

	local commentStart = line:find("#")
	local code, comment = line, nil
	if commentStart then
		code = line:sub(1, commentStart - 1)
		comment = line:sub(commentStart)
	end

	local trimmed = code:match("^%s*(.-)%s*$")
	if trimmed:match("^%[.*%]$") then
		table.insert(tokens, { text = code, category = "keyword" }) -- section header
	else
		local key, eq, rest = code:match("^(%s*[%w_%.%-\"']+)(%s*=%s*)(.*)$")
		if key then
			table.insert(tokens, { text = key, category = "key" })
			table.insert(tokens, { text = eq, category = "operator" })
			if rest:match('^".*"$') or rest:match("^'.*'$") then
				table.insert(tokens, { text = rest, category = "string" })
			elseif rest:match("^[%d%.%+%-]+$") then
				table.insert(tokens, { text = rest, category = "number" })
			elseif rest == "true" or rest == "false" then
				table.insert(tokens, { text = rest, category = "boolean" })
			else
				table.insert(tokens, { text = rest, category = "default" })
			end
		else
			table.insert(tokens, { text = code, category = "default" })
		end
	end

	if comment then
		table.insert(tokens, { text = comment, category = "comment" })
	end
	return tokens
end

return {
	id = "toml",
	extensions = { "toml" },
	commentPrefix = "#",
	blockOpenChars = {},
	blockCloseChars = {},
	highlight = highlightLine,
}
