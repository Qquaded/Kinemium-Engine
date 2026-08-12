--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

local KineSkiaColor = ffi.struct({
	{ r = ffi.types.u8 },
	{ g = ffi.types.u8 },
	{ b = ffi.types.u8 },
	{ a = ffi.types.u8 },
})
export type KineSkiaColor = typeof(KineSkiaColor:new({}))

local structs = {
	KineSkiaColor = KineSkiaColor,
}

return structs
