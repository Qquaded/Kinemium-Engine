local fs = zune.fs
local datatypes = {}

local zembed = require("@zembed")

local entries

if zembed.IsEmbedded() then
	entries = zembed.GetScriptsThatHas([[environment\datatypes]])
else
	entries = fs.entries("./src/environment/datatypes")
end

for _, file in pairs(entries) do
	local moduleName
	if zembed.IsEmbedded() then
		local stem = fs.path.stem(file)
		moduleName = fs.path.basename(file)
		moduleName = moduleName:gsub("%.luau$", "")
		if moduleName == "getDatatypes" then
			continue
		end

		moduleName = "datatypes/" .. moduleName
		datatypes[stem] = require("../" .. moduleName)
		datatypes[stem].__type = moduleName
	else
		if file.name == "getDatatypes.luau" then
			continue
		end
		moduleName = file.name:gsub("%.luau$", "")
		datatypes[moduleName] = require("./" .. moduleName)
		datatypes[moduleName].__type = moduleName
	end
end

return datatypes
