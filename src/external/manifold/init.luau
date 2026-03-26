--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./"
local ffi = zune.ffi
local platform = zune.platform

local structs = require("./structs")
local funcs = require("./funcs")
local constants = require("./constants")

local libname
if platform.os == "windows" then
	libname = "manifold.dll"
elseif platform.os == "linux" then
	libname = "manifold.so"
elseif platform.os == "macos" then
	libname = "manifold.dylib"
end

local manifold: funcs.Fns = ffi.dlopen(dll .. libname, funcs)

return {
	lib = manifold,
	structs = structs,
	constants = constants,
}