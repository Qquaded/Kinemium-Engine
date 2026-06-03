--!strict
--!optimize 2
--!native
-- https://github.com/btzy/nativefiledialog-extended

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double
local platform = zune.platform

local funcs = require("./funcs")
local structs = require("./structs")
local const = require("./constants")

local libLocation = "./src/external/nfd/bin/nfd." .. ffi.suffix
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	libLocation = zembed.RuntimePath("nfd." .. ffi.suffix)
end

local lib = ffi.dlopen(libLocation, funcs)

return {
	structs = structs,
	const = const,
	lib = lib :: funcs.Fns,
}
