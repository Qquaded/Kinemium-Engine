return function(lib, structs)
	local zembed = require("@zembed")

	local function LoadTextureFromFile(path: string)
		return lib.LoadTexture(zembed.AssetPath(path))
	end

	local function LoadTextureFromFileAsync(path: string)
		path = zembed.AssetPath(path)
		local success, data: buffer? = zune.fs.readFileSync(path, true)
		if success then
			local image = lib.LoadImageFromMemory(lib.GetFileExtension(path), data, buffer.len(data))
			if image ~= zune.ffi.null then
				local texture = lib.LoadTextureFromImage(image)
				lib.UnloadImage(image)
				return texture
			end
		end
		return structs.Texture2D:new({})
	end

	local function GetMaterials()
		local path = zembed.AssetPath("kineasset://materials/compressed")
		local fs = zune.fs
		local entries = fs.entries(path)

		local result = {}
		for i, v in pairs(entries) do
			if v.kind == "directory" then
				local directoryPath = fs.path.join(path, v.name)
				local components = fs.entries(directoryPath)

				local albedo, normal, orm
				for i, v in pairs(components) do
					local name = v.name
					local objectPath = directoryPath .. "/" .. name
					if string.match(name, "^albedo%.?") then
						albedo = objectPath
					elseif string.match(name, "^normal%.?") then
						normal = objectPath
					elseif string.match(name, "^orm%.?") then
						orm = objectPath
					end
				end

				result[v.name] = {
					albedo = albedo,
					normal = normal,
					orm = orm
				}
			else
				local objectPath = fs.path.join(path, v.name)
				result[v.name:gsub("(%.%w+)", "")] = {
					albedo = objectPath,
					normal = nil,
					orm = nil
				}
			end
		end

		return result
	end

	return {
		LoadTextureFromFile = LoadTextureFromFile,
		LoadTextureFromFileAsync = LoadTextureFromFileAsync,
		GetMaterials = GetMaterials,
	}
end
