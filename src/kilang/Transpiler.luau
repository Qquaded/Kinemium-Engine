local Transpiler = {}

local default = require("./superset/kilang")
local cpp = require("./superset/cpp")

local langs = {
	kilang = default,
	cpp = cpp,
	typescript = require("./superset/typescript"),
}

local function resolveLang(lang, code)
	if type(lang) ~= "table" then
		error("Language definition must be a table")
	end

	if type(lang.process) == "function" then
		local gsubFuncs, dataThread = lang.process(code)
		return gsubFuncs or {}, dataThread or {}
	end

	if type(lang[1]) == "table" then
		return lang, {}
	end

	error("Invalid language definition: expected process() or rule array")
end

function Transpiler.run(code, lang, gsubFuncs, dataThread)
	local env = lang.env or {}

	local strings = {}
	local out = {}
	local i = 1
	local len = #code
	local last_i = 1

	while i <= len do
		local c = code:sub(i, i)
		if c == '"' or c == "'" then
			table.insert(out, code:sub(last_i, i - 1))
			local quote = c
			local start_idx = i
			i = i + 1
			while i <= len do
				local c2 = code:sub(i, i)
				if c2 == '\\' then
					i = i + 2
				elseif c2 == quote then
					i = i + 1
					break
				else
					i = i + 1
				end
			end
			local str = code:sub(start_idx, i - 1)
			local key = string.format("__KILANG_STR_%d__", #strings + 1)
			table.insert(strings, str)
			table.insert(out, key)
			last_i = i
		elseif c == '[' then
			local is_long_string = false
			local eq_count = 0
			local j = i + 1
			while j <= len and code:sub(j, j) == '=' do
				eq_count = eq_count + 1
				j = j + 1
			end
			if j <= len and code:sub(j, j) == '[' then
				table.insert(out, code:sub(last_i, i - 1))
				is_long_string = true
				local start_idx = i
				local closing_pattern = "]" .. string.rep("=", eq_count) .. "]"
				local end_idx = code:find(closing_pattern, j + 1, true)
				if end_idx then
					i = end_idx + #closing_pattern
				else
					i = len + 1
				end
				local str = code:sub(start_idx, i - 1)
				local key = string.format("__KILANG_STR_%d__", #strings + 1)
				table.insert(strings, str)
				table.insert(out, key)
				last_i = i
			end
			
			if not is_long_string then
				i = i + 1
			end
		else
			i = i + 1
		end
	end
	table.insert(out, code:sub(last_i, len))
	code = table.concat(out)

	for _, rule in ipairs(gsubFuncs) do
		local success, nextCode, nextDataThread = pcall(function()
			return rule.gsub(code, env, dataThread)
		end)

		if success then
			if type(nextCode) == "string" then
				code = nextCode
			end
			if type(nextDataThread) == "table" then
				dataThread = nextDataThread
			end
			if type(rule.success) == "function" then
				local ok, err = pcall(rule.success, code, dataThread)
				if not ok then
					warn("Rule success handler failed:", err)
				end
			end
		else
			local ruleName = type(rule) == "table" and rule.name or "unknown"
			warn(("Rule failed (%s): %s"):format(tostring(ruleName), tostring(nextCode)))
		end
	end

	for j = #strings, 1, -1 do
		local replacement = strings[j]:gsub("%%", "%%%%")
		code = code:gsub("__KILANG_STR_" .. j .. "__", replacement)
	end

	return code, dataThread
end

function Transpiler.registerLang(name, rules)
	langs[name] = rules
end

function Transpiler.runLang(code, name)
	local lang = langs[name]
	if not lang then
		error("Language not registered: " .. name)
	end
	local gsubFuncs, dataThread = resolveLang(lang, code)
	return Transpiler.run(code, lang, gsubFuncs, dataThread)
end

return Transpiler
