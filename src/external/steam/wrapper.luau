local dll = "./src/external/steam/bin/"
local ffi = zune.ffi
local platform = zune.platform

local fileFormat = ".dll"

local bindings = require("./bindings")

local libname
if platform.os == "windows" then
	libname = "steam_api.dll"
	fileFormat = ".dll"
elseif platform.os == "linux" then
	libname = "steam_api.so"
	fileFormat = ".so"
elseif platform.os == "macos" then
	libname = "steam_api.dylib"
	fileFormat = ".dylib"
end

local steam: typeof(bindings.funcs) = ffi.dlopen(dll .. libname, bindings.funcs)

return {
	lib = steam,
	structs = bindings.structs,
}
