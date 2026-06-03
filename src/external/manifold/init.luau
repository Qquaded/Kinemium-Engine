--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./src/external/manifold/bin/"
local ffi = zune.ffi
local platform = zune.platform
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end

local structs = require("./structs")
local funcs = require("./funcs")
local constants = require("./constants")

local libname = "manifold." .. ffi.suffix

local manifoldPath = zembed.IsEmbedded() and zune.fs.path.join(dll, libname) or (dll .. libname)
local manifold: funcs.Fns = ffi.dlopen(manifoldPath, funcs)

return {
	lib = manifold,
	structs = structs,
	constants = constants,
}
