#ifndef KINE_SKIA_H
#define KINE_SKIA_H

#include <stddef.h>
#include <stdint.h>

#if defined(_WIN32)
  #if defined(KINE_SKIA_BUILD_EXPORTS)
    #define KINE_SKIA_API __declspec(dllexport)
  #else
    #define KINE_SKIA_API __declspec(dllimport)
  #endif
#else
  #define KINE_SKIA_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct KineSkiaSurface KineSkiaSurface;
typedef struct KineSkiaImage KineSkiaImage;

/* ---------------- Version ---------------- */

KINE_SKIA_API const char* Kine_Skia_GetVersion(void);

/* ---------------- Surface lifecycle ---------------- */

KINE_SKIA_API KineSkiaSurface* Kine_Skia_Surface_Create(int width, int height);
KINE_SKIA_API void Kine_Skia_Surface_Destroy(KineSkiaSurface* surface);

KINE_SKIA_API int Kine_Skia_Surface_GetWidth(const KineSkiaSurface* surface);
KINE_SKIA_API int Kine_Skia_Surface_GetHeight(const KineSkiaSurface* surface);
KINE_SKIA_API size_t Kine_Skia_Surface_GetRowBytes(const KineSkiaSurface* surface);
KINE_SKIA_API void* Kine_Skia_Surface_GetPixels(KineSkiaSurface* surface);
KINE_SKIA_API void Kine_Skia_Surface_Flush(KineSkiaSurface* surface);

/* Debug/readback helper: sample a single pixel back out of the surface */
KINE_SKIA_API void Kine_Skia_Surface_GetPixel(
    KineSkiaSurface* surface,
    int x, int y,
    uint8_t* outR, uint8_t* outG, uint8_t* outB, uint8_t* outA);

/* ---------------- Clear ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_Clear(
    KineSkiaSurface* surface,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a);

/* ---------------- Shapes ----------------
   strokeWidth == 0 -> filled. strokeWidth > 0 -> stroked with that width. */

KINE_SKIA_API void Kine_Skia_Surface_DrawRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

KINE_SKIA_API void Kine_Skia_Surface_DrawRoundRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float radiusX, float radiusY,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

KINE_SKIA_API void Kine_Skia_Surface_DrawCircle(
    KineSkiaSurface* surface,
    float cx, float cy, float radius,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

KINE_SKIA_API void Kine_Skia_Surface_DrawOval(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

KINE_SKIA_API void Kine_Skia_Surface_DrawArc(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float startAngle, float sweepAngle, int useCenter,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

KINE_SKIA_API void Kine_Skia_Surface_DrawLine(
    KineSkiaSurface* surface,
    float x0, float y0, float x1, float y1,
    float strokeWidth,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a);

/* points: flat array [x0,y0,x1,y1,...], pointCount = number of (x,y) pairs */
KINE_SKIA_API void Kine_Skia_Surface_DrawPolygon(
    KineSkiaSurface* surface,
    const float* points, int pointCount,
    int closed,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a,
    float strokeWidth);

/* ---------------- Transform stack ---------------- */

KINE_SKIA_API void Kine_Skia_Surface_Save(KineSkiaSurface* surface);
KINE_SKIA_API void Kine_Skia_Surface_Restore(KineSkiaSurface* surface);
KINE_SKIA_API void Kine_Skia_Surface_Translate(KineSkiaSurface* surface, float dx, float dy);
KINE_SKIA_API void Kine_Skia_Surface_Rotate(KineSkiaSurface* surface, float degrees);
KINE_SKIA_API void Kine_Skia_Surface_Scale(KineSkiaSurface* surface, float sx, float sy);
KINE_SKIA_API void Kine_Skia_Surface_ClipRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height);

KINE_SKIA_API void Kine_Skia_Surface_ClipRoundRect(
    KineSkiaSurface* surface,
    float x, float y, float width, float height,
    float radiusX, float radiusY);

KINE_SKIA_API void Kine_Skia_Surface_DrawImageSized(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float x, float y,
    float width, float height,
    uint8_t alpha);

KINE_SKIA_API float Kine_Skia_Surface_GetFontAscent(float fontSize, const char* fontPath);

/* ---------------- Text ---------------- */

/* fontPath may be "" or NULL to use the default system font.
   x,y is the text BASELINE, not top-left. */
KINE_SKIA_API void Kine_Skia_Surface_DrawText(
    KineSkiaSurface* surface,
    const char* text,
    float x, float y,
    float fontSize,
    const char* fontPath,
    uint8_t r, uint8_t g, uint8_t b, uint8_t a);

KINE_SKIA_API float Kine_Skia_Surface_MeasureText(
    const char* text,
    float fontSize,
    const char* fontPath);

/* Approximate line height (ascent+descent+leading) for layout purposes */
KINE_SKIA_API float Kine_Skia_Surface_GetFontLineHeight(
    float fontSize,
    const char* fontPath);

/* ---------------- Images ---------------- */

KINE_SKIA_API KineSkiaImage* Kine_Skia_Image_LoadFromFile(const char* path);
KINE_SKIA_API KineSkiaImage* Kine_Skia_Image_LoadFromMemory(const uint8_t* data, size_t size);
KINE_SKIA_API void Kine_Skia_Image_Destroy(KineSkiaImage* image);

KINE_SKIA_API int Kine_Skia_Image_GetWidth(const KineSkiaImage* image);
KINE_SKIA_API int Kine_Skia_Image_GetHeight(const KineSkiaImage* image);

/* Draw image at native size, top-left at (x,y) */
KINE_SKIA_API void Kine_Skia_Surface_DrawImage(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float x, float y,
    uint8_t alpha);

/* Draw image scaled/cropped: src rect from the image -> dst rect on the surface */
KINE_SKIA_API void Kine_Skia_Surface_DrawImageRect(
    KineSkiaSurface* surface,
    KineSkiaImage* image,
    float srcX, float srcY, float srcWidth, float srcHeight,
    float dstX, float dstY, float dstWidth, float dstHeight,
    uint8_t alpha);

#ifdef __cplusplus
}
#endif

#endif /* KINE_SKIA_H */