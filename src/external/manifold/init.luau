--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./vendor/"
local ffi = zune.ffi
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end

local structs = require("./manifold/structs")
local funcs = require("./manifold/funcs")
local constants = require("./manifold/constants")

ffi.dlopen(zune.fs.path.join(dll, "manifold." .. ffi.suffix), {})

local libname = "manifoldc." .. ffi.suffix

local manifoldPath = zembed.IsEmbedded() and zune.fs.path.join(dll, libname) or (dll .. libname)
local manifold: funcs.Fns = ffi.dlopen(manifoldPath, funcs)

return {
	lib = manifold,
	structs = structs,
	constants = constants,
}
