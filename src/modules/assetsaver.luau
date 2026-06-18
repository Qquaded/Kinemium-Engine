local assetsaver = {}

local Datamodel = require("@DataModel")
local zembed = require("@zembed")
local Instance = require("@Instance")
local zstd = zune.serde.zstd

local asset_suffixes = {
	".png",
	".jpg",
	".jpeg",
	".gif",
	".bmp",
	".tga",
	".webp",
	".svg",
	".ico",
	".dds",
	".exr",
	".hdr",

	-- Video
	".mp4",
	".webm",
	".mov",
	".avi",
	".mkv",

	-- Audio
	".mp3",
	".wav",
	".ogg",
	".flac",
	".m4a",
	".aac",

	-- 3D Models
	".obj",
	".fbx",
	".gltf",
	".glb",
	".dae",
	".blend",
	".stl",

	-- Materials / Shaders
	".mtl",
	".shader",
	".hlsl",
	".glsl",

	-- Fonts
	".ttf",
	".otf",
	".woff",
	".woff2",

	-- Misc Assets
	".json",
	".xml",
	".yaml",
	".yml",
	".toml",
}

local fs = zune.fs

local function isFilePath(str)
	if type(str) ~= "string" or str == "" then
		return false
	end

	-- Windows absolute paths
	if str:match("^[A-Za-z]:[\\/].+") then
		return true
	end

	-- Windows UNC paths
	if str:match("^\\\\[^\\]+\\[^\\]+") then
		return true
	end

	-- Unix/macOS absolute paths
	if str:match("^/.+") then
		return true
	end

	-- Home-relative paths
	if str:match("^~[/\\].+") then
		return true
	end

	-- Relative paths
	if str:match("^%.%.[/\\].+") or str:match("^%.[/\\].+") then
		return true
	end

	return false
end

export type KinemiumObject = typeof(Instance)

function assetsaver:GetGameAssets(game: KinemiumObject)
	local resolved = {}
	local old = {}

	for _, object: KinemiumObject in pairs(game:GetDescendants()) do
		-- this is a bad solution but it works i guess
		local properties = object:GetProperties()
		for prop, value in pairs(properties) do
			if type(value) == "string" then
				if prop == "FilePath" then
					object.FilePath = ""
					continue
				end
				if isFilePath(value) then
					local isAsset = false
					local basename = fs.path.basename(value)

					for _, suffix in pairs(asset_suffixes) do
						if string.find(basename, suffix) then
							isAsset = true
						end
					end

					if not isAsset then
						continue
					end

					local success, buf = pcall(function()
						return fs.readFile(value, true)
					end)
					if success and buf then
						resolved[value] = buf

						old[object] = {}
						old[object][prop] = value

						object[prop] = "kineasset://" .. basename

						print("Changed asset to " .. object[prop])
					end
				end
			end
		end
	end

	return resolved, old
end

function assetsaver:ResolveFileEmbed(file)
	if type(file) == "string" then
		local name = file:match("^kineasset://(.+)$")

		if name then
			return "./assets/game/" .. name
		end
	end

	return nil
end

function assetsaver:ResolveGame(datamodel: Instance)
	for _, descendant in pairs(datamodel:GetDescendants()) do
		local properties = descendant:GetProperties()
		if properties then
			for prop, value in pairs(properties) do
				if type(value) == "string" then
					local resolved = assetsaver:ResolveFileEmbed(value)

					if resolved then
						descendant[prop] = resolved
					end
				end
			end
		end
	end
end

return assetsaver
