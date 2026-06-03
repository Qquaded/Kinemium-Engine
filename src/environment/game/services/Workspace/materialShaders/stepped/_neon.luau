local r3d = require("@r3d")
local raylib = require("@raylib")
local const = raylib.const

return {
	Apply = function(material)
		--[[
	local R3D_EmissionMap = ffi.struct({
		{ texture = Texture },
		{ color = Color },
		{ energy = ffi.types.float },
	})
	export type R3D_EmissionMap = typeof(R3D_EmissionMap:new({}))
	--]]
		local map = r3d.structs.R3D_EmissionMap:new({
			color = const.WHITE,
			energy = 5.0,
		})
		buffer.copy(material, r3d.structs.R3D_Material:offset("emission"), map, 0, r3d.structs.R3D_EmissionMap:size())
	end,

	Apply3DObj = function(part, albedo, material)
		local map = r3d.structs.R3D_EmissionMap:new({
			color = part.Color:ToRaylib(part.Transparency),
			energy = part.NeonEnergy or 5.0,
		})
		buffer.copy(material, r3d.structs.R3D_Material:offset("emission"), map, 0, r3d.structs.R3D_EmissionMap:size())
	end,
}
