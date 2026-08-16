local ffi = zune.ffi

type int = number
type float = number
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)

export type Fns = {
	Kine_Skia_GetVersion: () -> cstring,

	Kine_Skia_Surface_Create: (width: int, height: int) -> FFIPointer,
	Kine_Skia_Surface_Destroy: (surface: FFIPointer) -> (),

	Kine_Skia_Surface_GetWidth: (surface: FFIPointer) -> int,
	Kine_Skia_Surface_GetHeight: (surface: FFIPointer) -> int,
	Kine_Skia_Surface_GetRowBytes: (surface: FFIPointer) -> number,
	Kine_Skia_Surface_GetPixels: (surface: FFIPointer) -> FFIPointer,

	Kine_Skia_Surface_Flush: (surface: FFIPointer) -> (),

	Kine_Skia_Surface_Clear: (surface: FFIPointer, r: number, g: number, b: number, a: number) -> (),

	Kine_Skia_Surface_DrawRect: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_DrawRoundRect: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		radiusX: float,
		radiusY: float,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_DrawCircle: (
		surface: FFIPointer,
		cx: float,
		cy: float,
		radius: float,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_DrawLine: (
		surface: FFIPointer,
		x0: float,
		y0: float,
		x1: float,
		y1: float,
		strokeWidth: float,
		r: number,
		g: number,
		b: number,
		a: number
	) -> (),

	Kine_Skia_Surface_GetPixel: (
		surface: FFIPointer,
		x: int,
		y: int,
		outR: FFIPointer,
		outG: FFIPointer,
		outB: FFIPointer,
		outA: FFIPointer
	) -> (),

	Kine_Skia_Surface_DrawOval: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_DrawArc: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		startAngle: float,
		sweepAngle: float,
		useCenter: int,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_ClipRoundRect: (
		surface: FFIPointer,
		x: float,
		y: float,
		width: float,
		height: float,
		radiusX: float,
		radiusY: float
	) -> (),

	Kine_Skia_Surface_DrawPolygon: (
		surface: FFIPointer,
		points: FFIPointer,
		pointCount: int,
		closed: int,
		r: number,
		g: number,
		b: number,
		a: number,
		strokeWidth: float
	) -> (),

	Kine_Skia_Surface_Save: (surface: FFIPointer) -> (),
	Kine_Skia_Surface_Restore: (surface: FFIPointer) -> (),

	Kine_Skia_Surface_Translate: (surface: FFIPointer, dx: float, dy: float) -> (),

	Kine_Skia_Surface_Rotate: (surface: FFIPointer, degrees: float) -> (),

	Kine_Skia_Surface_Scale: (surface: FFIPointer, sx: float, sy: float) -> (),

	Kine_Skia_Surface_ClipRect: (surface: FFIPointer, x: float, y: float, width: float, height: float) -> (),

	Kine_Skia_Surface_DrawText: (
		surface: FFIPointer,
		text: cstring,
		x: float,
		y: float,
		fontSize: float,
		fontPath: cstring,
		r: number,
		g: number,
		b: number,
		a: number
	) -> (),

	Kine_Skia_Surface_MeasureText: (text: cstring, fontSize: float, fontPath: cstring) -> float,

	Kine_Skia_Surface_GetFontLineHeight: (fontSize: float, fontPath: cstring) -> float,

	Kine_Skia_Image_LoadFromFile: (path: cstring) -> FFIPointer,

	Kine_Skia_Image_LoadFromMemory: (data: FFIPointer, size: number) -> FFIPointer,

	Kine_Skia_Image_Destroy: (image: FFIPointer) -> (),

	Kine_Skia_Image_GetWidth: (image: FFIPointer) -> int,

	Kine_Skia_Image_GetHeight: (image: FFIPointer) -> int,

	Kine_Skia_Surface_DrawImage: (
		surface: FFIPointer,
		image: FFIPointer,
		x: float,
		y: float,
		alpha: number
	) -> (),

	Kine_Skia_Surface_DrawImageRect: (
		surface: FFIPointer,
		image: FFIPointer,
		srcX: float,
		srcY: float,
		srcWidth: float,
		srcHeight: float,
		dstX: float,
		dstY: float,
		dstWidth: float,
		dstHeight: float,
		alpha: number
	) -> (),
}

local funcs = {
	Kine_Skia_GetVersion = {
		returns = ffi.types.pointer,
		args = {},
	},

	Kine_Skia_Surface_Create = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.i32,
			ffi.types.i32,
		},
	},

	Kine_Skia_Surface_Destroy = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_GetWidth = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_GetHeight = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_GetRowBytes = {
		returns = ffi.types.u64,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_GetPixels = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_Flush = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_Clear = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
		},
	},

	Kine_Skia_Surface_DrawRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
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
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_DrawCircle = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
		},
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
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
		},
	},

	Kine_Skia_Surface_GetPixel = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_DrawOval = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_ClipRoundRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_DrawArc = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.i32,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_DrawPolygon = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_Save = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_Restore = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_Translate = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_Rotate = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_Scale = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_ClipRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},

	Kine_Skia_Surface_DrawText = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
			ffi.types.u8,
		},
	},

	Kine_Skia_Surface_GetFontAscent = {
		returns = ffi.types.float,
		args = {
			ffi.types.float,
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_MeasureText = {
		returns = ffi.types.float,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_GetFontLineHeight = {
		returns = ffi.types.float,
		args = {
			ffi.types.float,
			ffi.types.pointer,
		},
	},

	Kine_Skia_Image_LoadFromFile = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Image_LoadFromMemory = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.u64,
		},
	},

	Kine_Skia_Image_Destroy = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Image_GetWidth = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Image_GetHeight = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
		},
	},

	Kine_Skia_Surface_DrawImage = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u8,
		},
	},

	--[[
	KINE_SKIA_API void Kine_Skia_Surface_DrawImageSized(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float x, float y,
    float width, float height,
    uint8_t alpha);
--]]
	Kine_Skia_Surface_DrawImageSized = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer, -- surface
			ffi.types.pointer, -- image
			ffi.types.float, -- x
			ffi.types.float, -- y
			ffi.types.float, -- width
			ffi.types.float, -- height
			ffi.types.u8, -- alpha
		},
	},

	Kine_Skia_Surface_DrawImageRect = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u8,
		},
	},
}

return funcs
