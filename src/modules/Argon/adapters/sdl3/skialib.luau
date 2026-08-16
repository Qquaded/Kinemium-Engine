-- skia adapter
local skia = require("./skia")
local SkiaAdapter = {}
local typedefs = require("../../typedefs")

-- Used by internals only
function SkiaAdapter:Init(width, height)
	return skia.lib.Kine_Skia_Surface_Create(width, height)
end

function SkiaAdapter:Clear(context, color: typedefs.Color)
	skia.lib.Kine_Skia_Surface_Clear(
		context,
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5),
		math.floor(color.A * 255 + 0.5)
	)
end

function SkiaAdapter:DrawRect(context, rect: typedefs.Rectangle)
	skia.lib.Kine_Skia_Surface_DrawRect(
		context,
		rect.x,
		rect.y,
		rect.width,
		rect.height,
		math.floor(rect.Color.R * 255 + 0.5),
		math.floor(rect.Color.G * 255 + 0.5),
		math.floor(rect.Color.B * 255 + 0.5),
		math.floor(rect.Color.A * 255 + 0.5),
		rect.isOutline and 1 or 0
	)
end

function SkiaAdapter:GetFontAscent(fontSize, font: typedefs.Font)
	return skia.lib.Kine_Skia_Surface_GetFontAscent(fontSize, font._path)
end

function SkiaAdapter:GetPixelsAndPitch(skiaSurface)
	skia.lib.Kine_Skia_Surface_Flush(skiaSurface)
	local pixels = skia.lib.Kine_Skia_Surface_GetPixels(skiaSurface)
	local pitch = skia.lib.Kine_Skia_Surface_GetRowBytes(skiaSurface)
	return pixels, pitch
end

function SkiaAdapter:Save(skiaSurface)
	skia.lib.Kine_Skia_Surface_Save(skiaSurface)
end

function SkiaAdapter:Restore(skiaSurface)
	skia.lib.Kine_Skia_Surface_Restore(skiaSurface)
end

function SkiaAdapter:CreateImage(path): typedefs.Image
	return { _handle = skia.lib.Kine_Skia_Image_LoadFromFile(path) }
end

function SkiaAdapter:MeasureText(text: string, size: number, font: typedefs.Font)
	return skia.lib.Kine_Skia_Surface_MeasureText(text, size, font._path)
end

function SkiaAdapter:DrawImageSized(skiaSurface, image: typedefs.Image, rect: typedefs.Rectangle, alpha: number?)
	skia.lib.Kine_Skia_Surface_DrawImageSized(
		skiaSurface,
		image._handle,
		rect.x,
		rect.y,
		rect.width,
		rect.height,
		alpha and math.floor(alpha * 255 + 0.5) or 255
	)
end

function SkiaAdapter:GetFontLineHeight(fontSize, font: typedefs.Font)
	return skia.lib.Kine_Skia_Surface_GetFontLineHeight(fontSize, font._path)
end

function SkiaAdapter:CreateFont(fontPath)
	return { _handle = fontPath, _path = fontPath } :: typedefs.Font
end

function SkiaAdapter:ClipRoundRect(context, rect: typedefs.Rectangle, radiusX: number, radiusY: number)
	skia.lib.Kine_Skia_Surface_ClipRoundRect(context, rect.x, rect.y, rect.width, rect.height, radiusX, radiusY)
end

function SkiaAdapter:InitSkiaSurface(width, height)
	return skia.lib.Kine_Skia_Surface_Create(width, height)
end

function SkiaAdapter:DestroySurface(skiaSurface)
	skia.lib.Kine_Skia_Surface_Destroy(skiaSurface)
end

function SkiaAdapter:DrawText(skiaSurface, text, position: typedefs.TextArgs)
	skia.lib.Kine_Skia_Surface_DrawText(
		skiaSurface,
		text,
		position.X,
		position.Y,
		position.TextSize,
		position.Font._handle,
		math.floor(position.Color.R * 255 + 0.5),
		math.floor(position.Color.G * 255 + 0.5),
		math.floor(position.Color.B * 255 + 0.5),
		math.floor(position.Color.A * 255 + 0.5)
	)
end

return SkiaAdapter
