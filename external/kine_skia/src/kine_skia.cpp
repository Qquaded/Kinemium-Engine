#include "kine_skia.h"

#include "include/core/SkCanvas.h"
#include "include/core/SkColor.h"
#include "include/core/SkImageInfo.h"
#include "include/core/SkPaint.h"
#include "include/core/SkPixmap.h"
#include "include/core/SkRRect.h"
#include "include/core/SkRect.h"
#include "include/core/SkSurface.h"
#include "include/core/SkSurfaceProps.h"

#include <utility>

struct KineSkiaSurface {
    sk_sp<SkSurface> surface;
};

static SkColor kine_skia_color(KineSkiaColor color)
{
    return SkColorSetARGB(color.a, color.r, color.g, color.b);
}

static SkPaint kine_skia_fill_paint(KineSkiaColor color)
{
    SkPaint paint;
    paint.setAntiAlias(true);
    paint.setColor(kine_skia_color(color));
    paint.setStyle(SkPaint::kFill_Style);
    return paint;
}

extern "C" {


KINE_SKIA_API const char* Kine_Skia_GetVersion(void)
{
    return "kine_skia 0.1.0";
}

KINE_SKIA_API KineSkiaSurface* Kine_Skia_Surface_Create(int width, int height)
{
    if (width <= 0 || height <= 0) {
        return nullptr;
    }

    sk_sp<SkSurface> surface = SkSurfaces::Raster(
        SkImageInfo::MakeN32Premul(width, height));
    if (!surface) {
        return nullptr;
    }

    KineSkiaSurface* wrapper = new KineSkiaSurface();
    wrapper->surface = std::move(surface);
    return wrapper;
}

KINE_SKIA_API void Kine_Skia_Surface_Destroy(KineSkiaSurface* surface)
{
    delete surface;
}

KINE_SKIA_API int Kine_Skia_Surface_GetWidth(const KineSkiaSurface* surface)
{
    return surface && surface->surface ? surface->surface->width() : 0;
}

KINE_SKIA_API int Kine_Skia_Surface_GetHeight(const KineSkiaSurface* surface)
{
    return surface && surface->surface ? surface->surface->height() : 0;
}

KINE_SKIA_API size_t Kine_Skia_Surface_GetRowBytes(const KineSkiaSurface* surface)
{
    if (!surface || !surface->surface) {
        return 0;
    }

    SkPixmap pixmap;
    if (!surface->surface->peekPixels(&pixmap)) {
        return 0;
    }

    return pixmap.rowBytes();
}

KINE_SKIA_API void* Kine_Skia_Surface_GetPixels(KineSkiaSurface* surface)
{
    if (!surface || !surface->surface) {
        return nullptr;
    }

    SkPixmap pixmap;
    if (!surface->surface->peekPixels(&pixmap)) {
        return nullptr;
    }

    return pixmap.writable_addr();
}

KINE_SKIA_API void Kine_Skia_Surface_Flush(KineSkiaSurface* surface)
{
    if (!surface || !surface->surface) {
        return;
    }

    SkPixmap pixmap;
    surface->surface->peekPixels(&pixmap);
}

KINE_SKIA_API void Kine_Skia_Surface_Clear(KineSkiaSurface* surface, KineSkiaColor color)
{
    if (!surface || !surface->surface) {
        return;
    }

    surface->surface->getCanvas()->clear(kine_skia_color(color));
}

KINE_SKIA_API void Kine_Skia_Surface_DrawRect(
    KineSkiaSurface* surface,
    float x,
    float y,
    float width,
    float height,
    KineSkiaColor color)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_fill_paint(color);
    surface->surface->getCanvas()->drawRect(
        SkRect::MakeXYWH(x, y, width, height),
        paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawRoundRect(
    KineSkiaSurface* surface,
    float x,
    float y,
    float width,
    float height,
    float radiusX,
    float radiusY,
    KineSkiaColor color)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_fill_paint(color);
    surface->surface->getCanvas()->drawRRect(
        SkRRect::MakeRectXY(SkRect::MakeXYWH(x, y, width, height), radiusX, radiusY),
        paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawCircle(
    KineSkiaSurface* surface,
    float cx,
    float cy,
    float radius,
    KineSkiaColor color)
{
    if (!surface || !surface->surface || radius <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_fill_paint(color);
    surface->surface->getCanvas()->drawCircle(cx, cy, radius, paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawLine(
    KineSkiaSurface* surface,
    float x0,
    float y0,
    float x1,
    float y1,
    float strokeWidth,
    KineSkiaColor color)
{
    if (!surface || !surface->surface || strokeWidth <= 0.0f) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);
    paint.setColor(kine_skia_color(color));
    paint.setStyle(SkPaint::kStroke_Style);
    paint.setStrokeWidth(strokeWidth);
    surface->surface->getCanvas()->drawLine(x0, y0, x1, y1, paint);
}

}
