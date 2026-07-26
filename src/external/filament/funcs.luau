--!strict
local ffi = zune.ffi

-- Type aliases for FFI
type int = number
type float = number
type double = number
type uint = number
type FFIPointer = typeof(ffi.types.pointer)

export type Fns = {
	-- Context lifecycle
	Kine_Filament_Create: (width: int, height: int) -> FFIPointer,
	Kine_Filament_Destroy: (ctx: FFIPointer) -> (),
	Kine_Filament_RenderFrame: (ctx: FFIPointer) -> (),
	Kine_Filament_Resize: (ctx: FFIPointer, width: int, height: int) -> (),
	Kine_Filament_ReadPixels: (ctx: FFIPointer, outPixels: FFIPointer) -> (),
	Kine_Filament_GetWidth: (ctx: FFIPointer) -> int,
	Kine_Filament_GetHeight: (ctx: FFIPointer) -> int,

	-- Scene accessors
	Kine_Filament_GetEngine: (ctx: FFIPointer) -> FFIPointer,
	Kine_Filament_GetScene: (ctx: FFIPointer) -> FFIPointer,
	Kine_Filament_GetView: (ctx: FFIPointer) -> FFIPointer,
	Kine_Filament_GetCamera: (ctx: FFIPointer) -> FFIPointer,

	-- Camera controls
	Kine_Filament_SetCameraLookAt: (
		ctx: FFIPointer,
		eyeX: float,
		eyeY: float,
		eyeZ: float,
		targetX: float,
		targetY: float,
		targetZ: float,
		upX: float,
		upY: float,
		upZ: float
	) -> (),
	Kine_Filament_SetCameraPosition: (ctx: FFIPointer, x: float, y: float, z: float) -> (),
	Kine_Filament_SetCameraDirection: (ctx: FFIPointer, dx: float, dy: float, dz: float) -> (),
	Kine_Filament_SetCameraPerspective: (
		ctx: FFIPointer,
		fovYDegrees: double,
		aspect: double,
		nearPlane: double,
		farPlane: double
	) -> (),

	-- Mesh system
	-- shape: 1 = cube, 2 = sphere, 3 = pyramid
	Kine_Filament_CreateMesh: (ctx: FFIPointer, shape: int) -> FFIPointer,
	Kine_Filament_DestroyMesh: (ctx: FFIPointer, mesh: FFIPointer) -> (),

	-- Texture system
	-- rlTexturePtr: pointer to a raylib Texture2D struct
	Kine_Filament_CreateTex: (ctx: FFIPointer, rlTexturePtr: FFIPointer) -> FFIPointer,
	Kine_Filament_DestroyTex: (ctx: FFIPointer, tex: FFIPointer) -> (),

	-- Draw call (immediate, per-frame)
	-- mat4: pointer to a float[16] column-major world transform
	Kine_Filament_DrawMesh: (
		ctx: FFIPointer,
		mesh: FFIPointer,
		r: float,
		g: float,
		b: float,
		tex: FFIPointer,
		transparency: float,
		mat4: FFIPointer
	) -> (),
}

local funcs = {
	-- Context lifecycle
	Kine_Filament_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.i32, ffi.types.i32 },
	},
	Kine_Filament_GetColorTextureId = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer },
	},

	Kine_Filament_Destroy = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	Kine_Filament_RenderFrame = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	Kine_Filament_Resize = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	Kine_Filament_ReadPixels = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	Kine_Filament_GetWidth = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	Kine_Filament_GetHeight = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},

	-- Scene accessors
	Kine_Filament_GetEngine = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	Kine_Filament_GetScene = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	Kine_Filament_DebugPrintPixel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	Kine_Filament_GetView = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	Kine_Filament_GetCamera = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	-- Camera controls
	Kine_Filament_SetCameraLookAt = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},
	Kine_Filament_SetCameraPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	Kine_Filament_SetCameraDirection = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	Kine_Filament_SetCameraPerspective = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},

	-- Mesh system
	Kine_Filament_CreateMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	Kine_Filament_DestroyMesh = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	-- Texture system
	Kine_Filament_CreateTex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	Kine_Filament_DestroyTex = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	-- Draw call
	Kine_Filament_DrawMesh = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer, -- ctx
			ffi.types.pointer, -- mesh
			ffi.types.float,
			ffi.types.float,
			ffi.types.float, -- r, g, b
			ffi.types.pointer, -- tex (nullable)
			ffi.types.float, -- transparency
			ffi.types.pointer, -- mat4 float[16]
		},
	},
}

return funcs
