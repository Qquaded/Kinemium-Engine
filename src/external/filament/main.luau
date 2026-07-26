--!strict
--!optimize 2
--!native

local ffi = zune.ffi

local funcs = require("./funcs")
local structs = require("./structs")
local const = require("./constants")

local libLocation = "./vendor/kine_filament_shim." .. ffi.suffix
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	libLocation = zembed.RuntimePath("kine_filament_shim." .. ffi.suffix)
end

local lib = ffi.dlopen(libLocation, funcs)

return {
	structs = structs,
	const = const,
	lib = lib :: funcs.Fns,
}
