local registry = {}
local byExtension = {}

local function register(langModule)
	registry[langModule.id] = langModule
	for _, ext in ipairs(langModule.extensions) do
		byExtension[ext:lower()] = langModule
	end
end

local plaintext = require("./languages/plaintext")

local function getForFilename(name)
	local ext = name:match("%.([%w_]+)$")
	if ext then
		local lang = byExtension[ext:lower()]
		if lang then
			return lang
		end
	end
	return plaintext
end

register(require("./languages/luau"))
register(require("./languages/json"))
register(require("./languages/toml"))

return {
	register = register,
	getForFilename = getForFilename,
	plaintext = plaintext,
}
