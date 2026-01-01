return function(lib)
	local zembed = require("@zembed")

	local function LoadTextureFromFile(path: string)
		return lib.LoadTexture(path)
	end

	local function GetMaterials()
		local path = "./src/assets/materials"
		local fs = zune.fs

		local entries
		if zembed.IsEmbedded() then
			entries = zembed.GetFilesThatHas([[assets\materials]])
		else
			entries = fs.entries(path)
		end

		local result = {}
		for i, v in pairs(entries) do
			if zembed.IsEmbedded() then
				local basename = fs.path.basename(v)
				result[basename:gsub(".png", "")] = v
			else
				local objectPath = "src/assets/materials/" .. v.name
				result[v.name:gsub(".png", "")] = objectPath
			end
		end
		return result
	end

	return {
		LoadTextureFromFile = LoadTextureFromFile,
		GetMaterials = GetMaterials,
	}
end
