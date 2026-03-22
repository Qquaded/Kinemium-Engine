--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./src/external/ultralight/bin/"
local ffi = zune.ffi
local platform = zune.platform

local funcs = require("./appcore/funcs")
local constants = require("./appcore/constants")

local libname = "AppCore." .. ffi.suffix
local appcore: funcs.Fns = ffi.dlopen(dll .. libname, funcs)

return {
	lib = appcore,
	constants = constants,
}
