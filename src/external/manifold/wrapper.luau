local dll = "./src/external/manifold/bin/"
local ffi = zune.ffi
local platform = zune.platform

local fileFormat = ".dll"

local bindings = require("./bindings")

local libname
if platform.os == "windows" then
	libname = "manifoldc.dll"
	fileFormat = ".dll"
elseif platform.os == "linux" then
	libname = "manifoldc.so"
	fileFormat = ".so"
elseif platform.os == "macos" then
	libname = "manifoldc.dylib"
	fileFormat = ".dylib"
end

if platform.os == "windows" then
	local success, result = pcall(function()
		ffi.dlopen(dll .. "manifold" .. fileFormat, {})
	end)
	warn(success, result)
end

local manifoldCSG: typeof(bindings.funcs) = ffi.dlopen(dll .. libname, bindings.funcs)

return {
	lib = manifoldCSG,
	structs = bindings.structs,
}
