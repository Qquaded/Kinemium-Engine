#include "kine_skia.h"

#include "include/core/SkCanvas.h"
#include "include/core/SkColor.h"
#include "include/core/SkData.h"
#include "include/core/SkFont.h"
#include "include/core/SkFontMgr.h"
#include "include/core/SkImage.h"
#include "include/core/SkImageInfo.h"
#include "include/core/SkPaint.h"
#include "include/core/SkPath.h"
#include "include/core/SkPixmap.h"
#include "include/core/SkRRect.h"
#include "include/core/SkRect.h"
#include "include/core/SkSurface.h"
#include "include/core/SkTextBlob.h"
#include "include/core/SkTypeface.h"
#include "include/core/SkPathBuilder.h"
#include "include/core/SkFontMetrics.h"
#include "include/ports/SkTypeface_win.h"
#include "modules/skshaper/include/SkShaper.h"
#include "modules/skshaper/include/SkShaper_skunicode.h"
#include "modules/skshaper/include/SkShaper_harfbuzz.h"

#include <cstdio>
#include <cstring>
#include <string>
#include <unordered_map>
#include <utility>

struct KineSkiaSurface {
    sk_sp<SkSurface> surface;
};

struct KineSkiaImage {
    sk_sp<SkImage> image;
};

/* ---------------- Paint helpers ---------------- */

static SkPaint kine_skia_paint(uint8_t r, uint8_t g, uint8_t b, uint8_t a, float strokeWidth)
{
    SkPaint paint;
    paint.setAntiAlias(true);
    paint.setColor(SkColorSetARGB(a, r, g, b));
    if (strokeWidth > 0.0f) {
        paint.setStyle(SkPaint::kStroke_Style);
        paint.setStrokeWidth(strokeWidth);
    } else {
        paint.setStyle(SkPaint::kFill_Style);
    }
    return paint;
}

/* ---------------- Font/typeface cache ---------------- */

static std::unordered_map<std::string, sk_sp<SkTypeface>>& kine_skia_typeface_cache()
{
    static std::unordered_map<std::string, sk_sp<SkTypeface>> cache;
    return cache;
}

static sk_sp<SkTypeface> kine_skia_get_typeface(const char* fontPath)
{
    std::string key = (fontPath && fontPath[0] != '\0') ? fontPath : "__default__";

    auto& cache = kine_skia_typeface_cache();
    auto it = cache.find(key);
    if (it != cache.end()) {
        return it->second;
    }

    sk_sp<SkFontMgr> mgr = SkFontMgr_New_DirectWrite();
    sk_sp<SkTypeface> tf;

    if (fontPath && fontPath[0] != '\0') {
        tf = mgr->makeFromFile(fontPath, 0);
        if (!tf) {
            fprintf(stderr, "kine_skia: failed to load font '%s', falling back to default\n", fontPath);
        }
    }

    if (!tf) {
        tf = mgr->legacyMakeTypeface(nullptr, SkFontStyle());
    }

    cache[key] = tf;
    return tf;
}

extern "C" {

/* ---------------- Version ---------------- */

KINE_SKIA_API const char* Kine_Skia_GetVersion(void)
{
    return "kine_skia 0.2.0";
}

/* ---------------- Surface lifecycle ---------------- */

KINE_SKIA_API KineSkiaSurface* Kine_Skia_Surface_Create(int width, int height)
{
    if (width <= 0 || height <= 0) {
        return nullptr;
    }

    SkImageInfo info = SkImageInfo::Make(
        width, height,
        kRGBA_8888_SkColorType,
        kPremul_SkAlphaType);

    sk_sp<SkSurface> surface = SkSurfaces::Raster(info);
    if (!surface) {
        return nullptr;
    }

    KineSkiaSurface* wrapper = new KineSkiaSurface();
    wrapper->surface = std::move(surface);
    wrapper->surface->getCanvas()->clear(SK_ColorTRANSPARENT);

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
    (void)surface;
    /* Raster surfaces are synchronous; nothing to flush. Kept as a stable
       no-op entry point in case a GPU-backed surface is added later. */
}

KINE_SKIA_API void Kine_Skia_Surface_GetPixel(
    KineSkiaSurface* surface,
    int x, int y,
    uint8_t* outR, uint8_t* outG, uint8_t* outB, uint8_t* outA)
{
    if (outR) *outR = 0;
    if (outG) *outG = 0;
    if (outB) *outB = 0;
    if (outA) *outA = 0;

    if (!surface || !surface->surface) {
        return;
    }

    SkPixmap pixmap;
    if (!surface->surface->peekPixels(&pixmap)) {
        return;
    }

    if (x < 0 || y < 0 || x >= pixmap.width() || y >= pixmap.height()) {
        return;
    }

    SkColor c = pixmap.getColor(x, y);
    if (outR) *outR = SkColorGetR(c);
    if (outG) *outG = SkColorGetG(c);
    if (outB) *outB = SkColorGetB(c);
    if (outA) *outA = SkColorGetA(c);
}

/* ---------------- Clear ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_Clear(
    KineSkiaSurface* surface,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    if (!surface || !surface->surface) {
        return;
    }
    surface->surface->getCanvas()->clear(SkColorSetARGB(a, r, g, b));
}

/* ---------------- Shapes ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_DrawRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawRect(SkRect::MakeXYWH(x, y, width, height), paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawRoundRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float radiusX, float radiusY,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawRRect(
        SkRRect::MakeRectXY(SkRect::MakeXYWH(x, y, width, height), radiusX, radiusY),
        paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawCircle(
    KineSkiaSurface* surface,
    float cx, float cy, float radius,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || radius <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawCircle(cx, cy, radius, paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawOval(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawOval(SkRect::MakeXYWH(x, y, width, height), paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawArc(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float startAngle, float sweepAngle, int useCenter,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawArc(
        SkRect::MakeXYWH(x, y, width, height),
        startAngle, sweepAngle, useCenter != 0, paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawLine(
    KineSkiaSurface* surface,
    float x0, float y0, float x1, float y1,
    float strokeWidth,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    if (!surface || !surface->surface || strokeWidth <= 0.0f) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);
    paint.setColor(SkColorSetARGB(a, r, g, b));
    paint.setStyle(SkPaint::kStroke_Style);
    paint.setStrokeWidth(strokeWidth);

    surface->surface->getCanvas()->drawLine(x0, y0, x1, y1, paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawPolygon(
    KineSkiaSurface* surface,
    const float* points, int pointCount,
    int closed,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth)
{
    if (!surface || !surface->surface || !points || pointCount < 2) {
        return;
    }

    SkPathBuilder builder;
    builder.moveTo(points[0], points[1]);
    for (int i = 1; i < pointCount; ++i) {
        builder.lineTo(points[i * 2], points[i * 2 + 1]);
    }
    if (closed) {
        builder.close();
    }
    SkPath path = builder.detach();

    SkPaint paint = kine_skia_paint(r, g, b, a, strokeWidth);
    surface->surface->getCanvas()->drawPath(path, paint);
}

/* ---------------- Transform stack ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_Save(KineSkiaSurface* surface)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->save();
}

KINE_SKIA_API void Kine_Skia_Surface_Restore(KineSkiaSurface* surface)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->restore();
}


KINE_SKIA_API void Kine_Skia_Surface_Translate(KineSkiaSurface* surface, float dx, float dy)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->translate(dx, dy);
}

KINE_SKIA_API void Kine_Skia_Surface_Rotate(KineSkiaSurface* surface, float degrees)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->rotate(degrees);
}

KINE_SKIA_API void Kine_Skia_Surface_Scale(KineSkiaSurface* surface, float sx, float sy)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->scale(sx, sy);
}

KINE_SKIA_API void Kine_Skia_Surface_ClipRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height)
{
    if (!surface || !surface->surface) return;
    surface->surface->getCanvas()->clipRect(SkRect::MakeXYWH(x, y, width, height));
}

KINE_SKIA_API void Kine_Skia_Surface_ClipRoundRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float radiusX, float radiusY)
{
    if (!surface || !surface->surface || width <= 0.0f || height <= 0.0f) return;

    SkRRect rrect = SkRRect::MakeRectXY(
        SkRect::MakeXYWH(x, y, width, height), radiusX, radiusY);

    surface->surface->getCanvas()->clipRRect(rrect, /*doAntiAlias=*/true);
}

/* ---------------- Text ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_DrawText(
    KineSkiaSurface* surface,
    const char* text,
    float x, float y,
    float fontSize,
    const char* fontPath,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    if (!surface || !surface->surface || !text || !text[0]) {
        return;
    }

    sk_sp<SkTypeface> typeface = kine_skia_get_typeface(fontPath);
    if (!typeface) {
        return;
    }

    SkFont font(typeface, fontSize);
    font.setEdging(SkFont::Edging::kAntiAlias);

    sk_sp<SkTextBlob> blob = SkTextBlob::MakeFromText(
        text, strlen(text), font, SkTextEncoding::kUTF8);
    if (!blob) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);
    paint.setColor(SkColorSetARGB(a, r, g, b));

    surface->surface->getCanvas()->drawTextBlob(blob, x, y, paint);
}

KINE_SKIA_API float Kine_Skia_Surface_MeasureText(
    const char* text,
    float fontSize,
    const char* fontPath)
{
    if (!text || fontSize <= 0.0f) {
        return 0.0f;
    }

    sk_sp<SkTypeface> tf = kine_skia_get_typeface(fontPath);
    SkFont font(tf, fontSize);
    return font.measureText(text, strlen(text), SkTextEncoding::kUTF8);
}

KINE_SKIA_API float Kine_Skia_Surface_GetFontLineHeight(
    float fontSize,
    const char* fontPath)
{
    if (fontSize <= 0.0f) {
        return 0.0f;
    }

    sk_sp<SkTypeface> tf = kine_skia_get_typeface(fontPath);
    SkFont font(tf, fontSize);

    SkFontMetrics metrics;
    font.getMetrics(&metrics);

    return (-metrics.fAscent) + metrics.fDescent + metrics.fLeading;
}

/* ---------------- Images ---------------- */

KINE_SKIA_API KineSkiaImage* Kine_Skia_Image_LoadFromFile(const char* path)
{
    if (!path || path[0] == '\0') {
        return nullptr;
    }

    sk_sp<SkData> data = SkData::MakeFromFileName(path);
    if (!data) {
        fprintf(stderr, "kine_skia: failed to read image file '%s'\n", path);
        return nullptr;
    }

    sk_sp<SkImage> image = SkImages::DeferredFromEncodedData(data);
    if (!image) {
        fprintf(stderr, "kine_skia: failed to decode image '%s'\n", path);
        return nullptr;
    }

    KineSkiaImage* wrapper = new KineSkiaImage();
    wrapper->image = std::move(image);
    return wrapper;
}

KINE_SKIA_API KineSkiaImage* Kine_Skia_Image_LoadFromMemory(const uint8_t* data, size_t size)
{
    if (!data || size == 0) {
        return nullptr;
    }

    sk_sp<SkData> skData = SkData::MakeWithCopy(data, size);
    sk_sp<SkImage> image = SkImages::DeferredFromEncodedData(skData);
    if (!image) {
        fprintf(stderr, "kine_skia: failed to decode image from memory buffer\n");
        return nullptr;
    }

    KineSkiaImage* wrapper = new KineSkiaImage();
    wrapper->image = std::move(image);
    return wrapper;
}

KINE_SKIA_API void Kine_Skia_Image_Destroy(KineSkiaImage* image)
{
    delete image;
}

KINE_SKIA_API int Kine_Skia_Image_GetWidth(const KineSkiaImage* image)
{
    return image && image->image ? image->image->width() : 0;
}

KINE_SKIA_API int Kine_Skia_Image_GetHeight(const KineSkiaImage* image)
{
    return image && image->image ? image->image->height() : 0;
}

KINE_SKIA_API void Kine_Skia_Surface_DrawImage(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float x, float y,
    uint8_t alpha)
{
    if (!surface || !surface->surface || !image || !image->image) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);
    if (alpha < 255) {
        paint.setAlphaf(alpha / 255.0f);
    }

    surface->surface->getCanvas()->drawImage(image->image, x, y, SkSamplingOptions(), &paint);
}

KINE_SKIA_API void Kine_Skia_Surface_DrawImageSized(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float x, float y,
    float width, float height,
    uint8_t alpha)
{
    if (!surface || !surface->surface || !image || !image->image) {
        return;
    }

    if (width <= 0.0f || height <= 0.0f) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);

    if (alpha < 255) {
        paint.setAlphaf(alpha / 255.0f);
    }

    SkRect dst = SkRect::MakeXYWH(x, y, width, height);

    surface->surface->getCanvas()->drawImageRect(
        image->image,
        dst,
        SkSamplingOptions(SkFilterMode::kLinear),
        &paint
    );
}

KINE_SKIA_API float Kine_Skia_Surface_GetFontAscent(
    float fontSize,
    const char* fontPath)
{
    if (fontSize <= 0.0f) {
        return 0.0f;
    }

    sk_sp<SkTypeface> tf = kine_skia_get_typeface(fontPath);
    SkFont font(tf, fontSize);

    SkFontMetrics metrics;
    font.getMetrics(&metrics);

    return -metrics.fAscent;
}

KINE_SKIA_API void Kine_Skia_Surface_DrawImageRect(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float srcX, float srcY, float srcWidth, float srcHeight,
    float dstX, float dstY, float dstWidth, float dstHeight,
    uint8_t alpha)
{
    if (!surface || !surface->surface || !image || !image->image) {
        return;
    }
    if (srcWidth <= 0.0f || srcHeight <= 0.0f || dstWidth <= 0.0f || dstHeight <= 0.0f) {
        return;
    }

    SkPaint paint;
    paint.setAntiAlias(true);
    if (alpha < 255) {
        paint.setAlphaf(alpha / 255.0f);
    }

    SkRect src = SkRect::MakeXYWH(srcX, srcY, srcWidth, srcHeight);
    SkRect dst = SkRect::MakeXYWH(dstX, dstY, dstWidth, dstHeight);

    surface->surface->getCanvas()->drawImageRect(
        image->image, src, dst,
        SkSamplingOptions(SkFilterMode::kLinear),
        &paint,
        SkCanvas::kStrict_SrcRectConstraint);
}

}