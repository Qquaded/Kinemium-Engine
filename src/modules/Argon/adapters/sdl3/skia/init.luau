--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./vendor/"
local ffi = zune.ffi
local platform = zune.platform

local funcs = require("./skia/funcs")
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = "./"
end

local libname
if platform.os == "windows" then
	libname = "kine_skia.dll"
elseif platform.os == "linux" then
	libname = "kine_skia.so"
elseif platform.os == "macos" then
	libname = "kine_skia.dylib"
end

local skia: typeof(funcs) = ffi.dlopen(dll .. libname, funcs)

return {
	lib = skia,
}
