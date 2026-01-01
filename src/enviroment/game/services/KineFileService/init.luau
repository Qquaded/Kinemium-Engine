local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local KineFileService = Instance.new("KineFileService")
KineFileService.ExplorerHidden = true

local fs = zune.fs
local process = zune.process
local os = zune.platform.os

export type KinemiumPlaceFile = {
	ToExe: (string) -> (),
}

local function build(placeFile)
	local args = {
		"bundle",
		"-f",
		"./**/.luaurc",
		"src/assets/**",
		"src/assets/images/**",
		"src/assets/icon/**",
		"src/assets/lucide/**",
		"src/assets/materials/**",
		"src/assets/meshes/**",
		"src/assets/sky/**",
		"src/assets/shaders/**",
		"src/assets/sounds/**",
		"-s",
		"src/main.lua",
		"src/enviroment/**",
		"src/enviroment/datatypes/**",
		"src/modules/**/*.lua*",
		"src/renderer/**/*.lua*",
		"src/sandboxed/**/*.lua*",
		"src/shaders/**/*.lua*",
		"src/runtime/**/*.lua*",
		"src/external/**/*.lua*",
		"src/runtime/**",
		"src/libs/**",
		"src/**",
		"src/template/**",

		"src/external/signal.lua",
	}

	table.insert(args, placeFile)
	table.insert(args, "--out=./build/KinemiumRuntime.exe")

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

				print(pathName)
				fs.createFile("./build/" .. pathName)
				fs.writeFile("./build/" .. pathName, "return " .. string.format("%q", buffer.tostring(serialized)))

				function wrapper:ToExe()
					build("./build/" .. pathName)
				end

				return wrapper
			end
		end,
	})
end

return KineFileService
