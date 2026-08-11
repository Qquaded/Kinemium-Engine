local fs = zune.fs
local datatypes = {}

local zembed = require("@zembed")
local kilang = require("@kilang")

local entries

if zembed.IsEmbedded() then
	entries = zembed.GetScriptsThatHas([[environment\datatypes]])
else
	entries = fs.entries("./src/environment/datatypes")
end

function datatypes:Init(datamodel, renderer, types)
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
			types[stem] = require("../" .. moduleName)
			types[stem].__type = moduleName
		else
			if file.name == "getDatatypes.luau" then
				continue
			end
			moduleName = file.name:gsub("%.luau$", "")

			local path = "./src/environment/datatypes/" .. moduleName .. ".luau"
			local read = zune.fs.readFile(path)
			local thread, success, result = kilang:execute(
				read,
				{ StackId = path },
				{ game = datamodel, renderer = renderer }
			)

			if not success then
				warn("Failed to add datatype " .. path .. ": " .. result)
				continue
			end
			kilang:remove(thread)
			types[moduleName] = result

			if type(types[moduleName]) == "table" then
				types[moduleName].__type = moduleName
				types[moduleName].__datatype = true
			end
		end
	end
end

return datatypes
