local mtsh = {}

local looping = "./src/environment/game/services/Workspace/materialShaders/stepped"
local fs = zune.fs

local collected = {}

local zembed = require("@zembed")
if zembed.IsEmbedded() then
	looping = zembed.GetFilesThatHas([[materialShaders\stepped]])
end

function mtsh:AddFilters()
	local files = zembed.IsEmbedded() and looping or zune.fs.entries(looping)

	for i, file in pairs(files) do
		local path = zembed.IsEmbedded() and file or looping .. "/" .. file.name
		local basename = fs.path.stem(path)
		local newname = string.gsub(basename, ".luau", "")
		local require_path = zembed.IsEmbedded() and file or "./stepped/" .. newname
		require_path = string.gsub(require_path, ".luau", "")
		newname = string.gsub(newname, "_", "")
		local required = require(require_path)
		collected[newname] = required
	end

	return collected
end

return mtsh
