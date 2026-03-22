local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local KineFileService = Instance.new("KineFileService")
KineFileService.ExplorerHidden = true

local zembed = require("@zembed")
local fs = zune.fs
local process = zune.process
local os = zune.platform.os

export type KinemiumPlaceFile = {
	ToExe: (string) -> (),
}

local sArgs = {
	"-s",
	"src/main.luau",
	"src/enviroment/*",
	"src/enviroment/class/**",
	"src/enviroment/classlibs/**",
	"src/enviroment/datatypes/**",
	"src/enviroment/libraries/**",

	"src/enviroment/game/services/Workspace/**",
	"src/enviroment/game/services/*/*",
	"src/enviroment/game/*",
	"src/enviroment/game/runtime/*",

	"src/modules/**/*.luau*",
	"src/renderer/**/*.luau*",
	"src/sandboxed/**",
	"src/runtime/**/*.luau*",
	"src/external/**/*.luau*",
	"src/objects/**",
	"src/libs/**",
	"src/**",
	"src/external/signal.luau",
}

local function build(placeFile)
	local args = {
		"bundle",
		"--compression=zstd",
		"-f",
		"./**/.luauurc",
		"src/assets/**",
		"src/assets/images/**",
		"src/assets/icon/**",
		"src/assets/materials/**",
		"src/assets/meshes/**",
		"src/assets/fonts/**",
		"src/assets/sky/**",
		"src/projects.toml",
		"src/assets/sounds/**",
		"src/assets/videos/**",
	}

	if placeFile then
		table.insert(args, placeFile)
	end
	for _, line in pairs(sArgs) do
		table.insert(args, line)
	end
	table.insert(args, "--out=./build/KinemiumRuntime.exe")
	print(args)

	local res = process.run(fs.getExePath(), args)
	print("Building")

	if not res.ok then
		error(`\n- {res.stderr}`)
	end
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

				build()

				return wrapper
			end
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
					build("./build/" .. pathName)
				end

				return wrapper
			end
		end,
	})
end

return KineFileService
