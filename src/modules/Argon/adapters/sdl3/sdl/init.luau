--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./vendor/"
local ffi = zune.ffi
local platform = zune.platform

local structs = require("./sdl/structs")
local funcs = require("./sdl/funcs")
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = "./"
end

local libname
if platform.os == "windows" then
	libname = "SDL3.dll"
elseif platform.os == "linux" then
	libname = "SDL3.so"
elseif platform.os == "macos" then
	libname = "SDL3.dylib"
end

local sdl3: typeof(funcs) = ffi.dlopen(dll .. libname, funcs)

return {
	lib = sdl3,
	structs = structs,
}
