-- skia adapter
local skia = require("@skia")
local SkiaAdapter = {}
local typedefs = require("../../typedefs")

-- Used by internals only
function SkiaAdapter:Init(width, height)
	return skia.lib.Kine_Skia_Surface_Create(width, height)
end

function SkiaAdapter:Clear(context, color: typedefs.Color)
	local SkiaColor = skia.structs.KineSkiaColor:new({
		r = math.floor(color.R * 255 + 0.5),
		g = math.floor(color.G * 255 + 0.5),
		b = math.floor(color.B * 255 + 0.5),
		a = math.floor(color.A * 255 + 0.5),
	})
	skia.lib.Kine_Skia_Surface_Clear(context, SkiaColor)
end

function SkiaAdapter:DrawRect(context, rect: typedefs.Rectangle)
	local SkiaColor = skia.structs.KineSkiaColor:new({
		r = math.floor(rect.Color.R * 255 + 0.5),
		g = math.floor(rect.Color.G * 255 + 0.5),
		b = math.floor(rect.Color.B * 255 + 0.5),
		a = math.floor(rect.Color.A * 255 + 0.5),
	})
	skia.lib.Kine_Skia_Surface_DrawRect(context, rect.x, rect.y, rect.width, rect.height, SkiaColor)
end

function SkiaAdapter:GetPixelsAndPitch(skiaSurface)
	local pixels = skia.lib.Kine_Skia_Surface_GetPixels(skiaSurface)
	local pitch = skia.lib.Kine_Skia_Surface_GetRowBytes(skiaSurface)
	return pixels, pitch
end

return SkiaAdapter
