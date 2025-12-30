--!strict
--!optimize 2
--!native

local raylib = require("./raylib")
local structs = raylib.structs

local ffi = _G.zune.ffi
local float = ffi.types.float
local Vector3 = structs.Vector3

type float = number

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	Vector3Distance: (v1: vector, v2: vector) -> float,
}

return {
	defs = {
		Vector3Distance = fn(float, { Vector3, Vector3 }),
	},
}
