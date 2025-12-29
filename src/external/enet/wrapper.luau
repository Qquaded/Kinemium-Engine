local dll = "./src/external/enet/bin/"
local ffi = zune.ffi
local platform = zune.platform

local bindings = require("./bindings")

local libname
if platform.os == "windows" then
	libname = "enet.dll"
elseif platform.os == "linux" then
	libname = "enet.so"
elseif platform.os == "macos" then
	libname = "enet.dylib"
end

local enet: typeof(bindings.funcs) = ffi.dlopen(dll .. libname, bindings.funcs)

return {
	lib = enet,
	structs = bindings.structs,
}
