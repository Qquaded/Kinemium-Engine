local preprocessor = {}

local default = require("./superset/kilang")
local cpp = require("./superset/cpp")

local langs = {
	kilang = table.clone(default),
	cpp = table.clone(cpp),
}

function preprocessor.run(code, lang)
	local env = lang.env or {}

	for _, rule in ipairs(lang) do
		local success, result = pcall(function()
			return rule.gsub(code, env)
		end)
		if success then
			code = result
			if rule.success then
				rule.success(code)
			end
		else
			warn("Rule failed:", result)
		end
	end
	return code
end

function preprocessor.registerLang(name, rules)
	langs[name] = rules
end

function preprocessor.runLang(code, name)
	local lang = langs[name]
	if not lang then
		error("Language not registered: " .. name)
	end
	return preprocessor.run(code, lang)
end

return preprocessor
