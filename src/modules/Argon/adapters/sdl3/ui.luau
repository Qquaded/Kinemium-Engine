-- skia adapter
local skia = require("@skia")
local SkiaAdapter = {}
local typedefs = require("../../typedefs")

-- Used by internals only
function SkiaAdapter:Init(width, height)
	return skia.lib.Kine_Skia_Surface_Create(width, height)
end

function SkiaAdapter:DrawRect(context, rect: typedefs.Rectangle)
	local SkiaColor = skia.structs.KineSkiaColor:new({
		r = rect.Color.R,
		g = rect.Color.G,
		b = rect.Color.B,
		a = rect.Color.A,
	})
	skia.lib.Kine_Skia_Surface_DrawRect(context, rect.x, rect.y, rect.width, rect.height, SkiaColor)
end

return SkiaAdapter
