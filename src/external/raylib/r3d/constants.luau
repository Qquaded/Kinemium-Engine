--!strict
--!optimize 2

local constants = {
	R3D_AnimationEvent = {
		R3D_ANIM_EVENT_FINISHED = 0,
		R3D_ANIM_EVENT_LOOPED = 1,
	},

	-- Bitmask flags from r3d_instance.h
	R3D_INSTANCE_POSITION = bit32.lshift(1, 0),
	R3D_INSTANCE_ROTATION = bit32.lshift(1, 1),
	R3D_INSTANCE_SCALE = bit32.lshift(1, 2),
	R3D_INSTANCE_COLOR = bit32.lshift(1, 3),
	R3D_INSTANCE_CUSTOM = bit32.lshift(1, 4),

	-- Defined constants
	R3D_LAYER_ALL = 4294967295,
	R3D_INSTANCE_ATTRIBUTE_COUNT = 5,

	R3D_TRANSPARENCY_DISABLED = 0,
	R3D_TRANSPARENCY_PREPASS = 1,
	R3D_TRANSPARENCY_ALPHA = 2,
	R3D_BILLBOARD_DISABLED = 0,
	R3D_BILLBOARD_FRONT = 1,
	R3D_BILLBOARD_Y_AXIS = 2,
	R3D_CULL_NONE = 0,
}

return constants
