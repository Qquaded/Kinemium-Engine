--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./src/external/gns/bin/"
local ffi = zune.ffi
local platform = zune.platform
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end

local structs = require("./gns/structs")
local funcs = require("./gns/funcs")

local libname
if platform.os == "windows" then
	libname = "GameNetworkingSockets.dll"
elseif platform.os == "linux" then
	libname = "GameNetworkingSockets.so"
elseif platform.os == "macos" then
	libname = "GameNetworkingSockets.dylib"
end

local function libPath(name: string): string
	if zembed.IsEmbedded() then
		return zune.fs.path.join(dll, name)
	end
	return dll .. name
end

if platform.os == "windows" then
	ffi.dlopen(libPath("abseil_dll." .. ffi.suffix), {})
	ffi.dlopen(libPath("libprotobuf." .. ffi.suffix), {})
	ffi.dlopen(libPath("libcrypto-3-x64." .. ffi.suffix), {})
end

local gns: funcs.Fns = ffi.dlopen(libPath(libname), funcs)

return {
	lib = gns,
	structs = structs,
}
