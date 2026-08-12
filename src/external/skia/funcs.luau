local ffi = zune.ffi

-- Type aliases for FFI
type int = number
type float = number
type bool = boolean
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)

-- Import struct types
local structs = require("./structs")
type KineSkiaColor = structs.KineSkiaColor

export type Fns = {
	Kine_Skia_GetVersion: () -> cstring,
	Kine_Skia_Surface_Clear: (surface: FFIPointer, color: KineSkiaColor) -> (),
	Kine_Skia_Surface_Create: (width: int, height: int) -> FFIPointer,
	Kine_Skia_Surface_Destroy: (surface: FFIPointer) -> (),
	Kine_Skia_Surface_DrawCircle: (
		surface: FFIPointer,
		cx: float,
		cy: float,
		radius: float,
		color: KineSkiaColor
	) -> (),
	Kine_Skia_Surface_DrawLine: (
		surface: FFIPointer,
		x0: float,
		y0: float,
		x1: float,
		y1: float,
		strokeWidth: float,
		color: KineSkiaColor
	) -> (),
	Kine_Skia_Surface_DrawRect: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		color: KineSkiaColor
	) -> (),
	Kine_Skia_Surface_DrawRoundRect: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		radiusX: float,
		radiusY: float,
		color: KineSkiaColor
	) -> (),
	Kine_Skia_Surface_Flush: (surface: FFIPointer) -> (),
	Kine_Skia_Surface_GetHeight: (surface: FFIPointer) -> int,
	Kine_Skia_Surface_GetPixels: (surface: FFIPointer) -> FFIPointer,
	Kine_Skia_Surface_GetRowBytes: (surface: FFIPointer) -> int,
	Kine_Skia_Surface_GetWidth: (surface: FFIPointer) -> int,
}

local funcs = {
	Kine_Skia_GetVersion = { returns = ffi.types.pointer, args = {} },
	Kine_Skia_Surface_Create = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.i32 } },
	Kine_Skia_Surface_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	Kine_Skia_Surface_GetWidth = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	Kine_Skia_Surface_GetHeight = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	Kine_Skia_Surface_GetRowBytes = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	Kine_Skia_Surface_GetPixels = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	Kine_Skia_Surface_Flush = { returns = ffi.types.void, args = { ffi.types.pointer } },
	Kine_Skia_Surface_Clear = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	Kine_Skia_Surface_DrawRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
	Kine_Skia_Surface_DrawRoundRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
	Kine_Skia_Surface_DrawCircle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	Kine_Skia_Surface_DrawLine = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
}

return funcs
