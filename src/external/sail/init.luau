--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./src/external/sail/bin/"
local zembed = require("@zembed")
local Packager = require("@Downloader")
local ffi = zune.ffi

if zembed.IsEmbedded() then
	dll = "./"
end

local downloadLink = `https://github.com/Qquaded/dlls/releases/download/win-sail/{zune.platform.os}.zip`
local dllName = "sail." .. ffi.suffix

if zembed.IsEmbedded() then
	if zune.fs.stat("./" .. dllName).kind == "none" then
		if zune.platform.os == "linux" then
			print(
				"SAIL Binaries might not work on Linux, if you see an error after the installation, Please report it in the Kinemium Engine Discord Server, Thank you!"
			)
		end
		print("Downloading SAIL...")
		print("Downloading from link " .. downloadLink)
		Packager.downloadAndExtract(downloadLink, "./")
		print("Please run the engine again")
		zune.process.exit(0)
	end
else
	if zune.fs.stat("./src/external/sail/bin").kind == "none" then
		if zune.platform.os == "linux" then
			print(
				"SAIL Binaries might not work on Linux, if you see an error after the installation, Please report it in the Kinemium Engine Discord Server, Thank you!"
			)
		end
		print("Downloading SAIL...")
		print("Downloading from link " .. downloadLink)
		local extracted = "./src/external/sail"
		Packager.downloadAndExtract(downloadLink, zembed.IsEmbedded() and "./" or extracted)
		print("Please run the engine again")
		zune.process.exit(0)
	end
end

if zune.platform.os == "windows" then
	local codec_dlls = {
		"zlib1",
		"libpng16",
		"jpeg62",
		"liblzma",
		"tiff",
		"gif",
		"libsharpyuv",
		"libwebp",
		"libwebpdecoder",
		"libwebpdemux",
		"libwebpmux",
		"avutil-60",
		"swresample-6",
		"swscale-9",
		"avcodec-62",
		"avformat-62",
	}

	for _, codec_dll in ipairs(codec_dlls) do
		ffi.dlopen(dll .. codec_dll .. "." .. ffi.suffix, {})
	end
end

repeat
	task.wait()
until zune.fs.stat(dll .. "sail-manip." .. ffi.suffix).kind ~= "none"

local sail_common_funcs = require("./sail/sail-common/funcs")
local sail_manip_funcs = require("./sail/sail-manip/funcs")

local sail_common = ffi.dlopen(dll .. "sail-common." .. ffi.suffix, sail_common_funcs)
local sail_codecs = ffi.dlopen(dll .. "sail-codecs." .. ffi.suffix, {})
local sail_manip = ffi.dlopen(dll .. "sail-manip." .. ffi.suffix, sail_manip_funcs)

local structs = require("./sail/structs")
local funcs = require("./sail/funcs")
local constants = require("./sail/constants")
local sail: funcs.Fns = ffi.dlopen(dll .. "sail." .. ffi.suffix, funcs)

return {
	lib = sail,
	codecslib = sail_codecs,
	commonlib = sail_common,
	structs = structs,
	constants = constants,
	common = {
		structs = require("./sail/sail-common/structs"),
		funcs = sail_common_funcs,
		lib = sail_common,
	},
	manip = {
		lib = sail_manip,
		funcs = sail_manip_funcs,
		structs = require("./sail/sail-manip/structs"),
	},
	ffmpeg = require("./sail/ffmpeg/main"),
}
