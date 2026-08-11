local Instance = require("@Instance")
local Enum = require("@EnumMap")

local KineFileService = Instance.new("KineFileService")
KineFileService.ExplorerHidden = true
KineFileService._Intents = Enum.PluginIntents.Filesystem

local kine = require("./src/environment/game/services/KineFileService/filetypes/kine")
local scene = require("./src/environment/game/services/KineFileService/filetypes/scene")

local zembed = require("@zembed")
local fs = zune.fs
local process = zune.process
local os = zune.platform.os
local zune_path = _G.ZUNE_EMBEDDED

local assetsaver = require("@assetsaver")

export type KinemiumPlaceFile = {
	ToExe: (string) -> (),
}

local buildNames = {
	["windows"] = "windows_x86-64",
	["macos"] = "macos_x86-64",
	["linux"] = "debian_x86-64",
	["freebsd"] = "freebsd_x86-64",
}

local serde = zune.serde

local defaultFlags = {
	["default"] = {
		"client",
		"offline",
		"no_multiplayer",
	},
}

local function buildEngine()
	local res = process.run(zune_path or fs.getExePath(), { "run", "build" })
	return res
end

local function loop(path)
	local dlls = {}

	for _, folder in pairs(fs.entries(path)) do
		if folder.kind == "directory" then
			local result = loop(path .. "/" .. folder.name)
			if result then
				for i, v in pairs(result) do
					table.insert(dlls, v)
				end
			end
		else
			local extension = fs.path.extension(folder.name)
			local main = ".dll"
			if os == "linux" then
				main = ".so"
			elseif os == "macos" then
				main = ".dylib"
			end
			if extension == main then
				table.insert(dlls, path .. "/" .. folder.name)
			end
		end
	end

	return dlls
end

KineFileService.InitRenderer = function(renderer, renderer_signal, datamodel)
	KineFileService:SetProperties({
		BuildRuntime = function()
			if zembed.IsEmbedded() then
				return
			end

			local SerializationService = datamodel:GetService("SerializationService")
			local serialized = SerializationService.SerializeInstancesAsync({ datamodel })

			if serialized then
				local wrapper = {}

				fs.makeDir("./build")

				local dlls = loop("./")
				for _, dll in dlls do
					pcall(function()
						fs.copy(dll, "./build/" .. fs.path.basename(dll))
						print(`Cloned {dll}`)
					end)
				end

				buildEngine()

				return wrapper
			end

			return
		end,

		Save = function(pathName)
			local SerializationService = datamodel:GetService("SerializationService")
			local serialized = SerializationService.SerializeInstancesAsync({ datamodel })
			if serialized then
				local wrapper = {}

				fs.makeDir("./build")

				local dlls = loop("./")
				for _, dll in dlls do
					pcall(function()
						fs.copy(dll, "./build/" .. fs.path.basename(dll))
						print(`Cloned {dll}`)
					end)
				end

				fs.createFile("./build/" .. pathName)
				fs.writeFile("./build/" .. pathName, serialized)

				function wrapper:ToExe()
					buildEngine()
				end

				return wrapper
			end
			return
		end,

		ExportObject = function(instances, path, name)
			local serialized = kine.serialize(instances, datamodel)
			if serialized then
				fs.writeFile(path .. "/" .. name .. ".kine", serialized)
			end
			return serialized, true
		end,

		ExportDatamodel = function(path, name)
			local saved = {}

			for _, service in ipairs(datamodel:GetChildren()) do
				if service.Name == "Players" then
					continue
				end

				local children = service:GetChildren()
				if children[1] ~= nil then
					table.insert(saved, service)
				else
					print("Skipped " .. service.Name)
				end
			end

			return saved
		end,

		ExportGameAsFile = function(path, gameName: string)
			local savedObjects = KineFileService.ExportDatamodel(path, gameName)
			local serialized = KineFileService.ExportObject(savedObjects, path, gameName)
			return serialized
		end,

		DecodeFile = function(filePath)
			local read = fs.readFile(filePath, true)
			if read then
				local deserialized = kine.deserialize(read, datamodel)
				if deserialized then
					if #deserialized == 1 then
						return deserialized[1]
					end
					return deserialized
				end
			end
			return false
		end,

		ExportGameAsExecutable = function(gameName)
			local assets, old_props = assetsaver:GetGameAssets(datamodel)

			local res = buildEngine()
			if not res.ok then
				error(`Got error code {res.code} while building Engine`)
				return
			end

			local platform = buildNames[zune.platform.os]
			local buildFolder = `./build/{platform}`
			local exportedFolder = buildFolder .. "/exported"
			local game_folder_assets = buildFolder .. "/assets/game"

			fs.makeDir(exportedFolder)

			-- write engine flags file, this will determine what flags the engine is gonna
			-- startup with
			fs.writeFile(exportedFolder .. "/flags.toml", serde.toml.encode(defaultFlags))

			-- get assets

			if assets then
				fs.makeDir(game_folder_assets)

				for path, buff in pairs(assets) do
					-- write
					local basename = zune.fs.path.basename(path)
					fs.writeFile(game_folder_assets .. "/" .. basename, buff)
				end
			end

			KineFileService.ExportGameAsFile(exportedFolder, "obj")

			for object, props in pairs(old_props) do
				for property, value in pairs(props) do
					object[property] = value
				end
			end

			return true
		end,
	})
end

return KineFileService
