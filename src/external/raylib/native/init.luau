--!strict
local fs = zune.fs
local ffi = zune.ffi

local LIBRARY_PATH = "./vendor/raylib." .. ffi.suffix

assert(fs.stat(LIBRARY_PATH).kind == "file", `Raylib library not found at path: {LIBRARY_PATH}`)

local raylib = require("@self/raylib")
local core = require("@self/core")
local shapes = require("@self/shapes")
local textures = require("@self/textures")
local text = require("@self/text")
local models = require("@self/models")
local audio = require("@self/audio")
local rlgl = require("@self/rlgl")
local rmath = require("@self/rmath")

local function combine(...: { [string]: any })
	local list = { ... }
	local first = table.remove(list, 1)
	assert(first)
	local result = table.clone(first)
	for _, tbl in list do
		for k, v in tbl do
			result[k] = v
		end
	end
	return result
end

local export = {}

require("../sdl")

export.const = raylib
export.lib = ffi.dlopen(
	LIBRARY_PATH,
	combine(core.def, shapes.def, textures.def, text.def, audio.def, models.def, rlgl.def, rmath.defs)
) :: {
	GetSymbol: (self: FFILibrary, symbol: string) -> FFIPointer?,
} & core.Fns & shapes.Fns & textures.Fns & text.Fns & audio.Fns & models.Fns & rlgl.Fns & rmath.Fns

return export
