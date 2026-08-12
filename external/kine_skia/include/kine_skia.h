#ifndef KINE_SKIA_H
#define KINE_SKIA_H

#include "kine_skia_export.h"

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct KineSkiaSurface KineSkiaSurface;

typedef struct KineSkiaColor {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} KineSkiaColor;

KINE_SKIA_API const char* Kine_Skia_GetVersion(void);

KINE_SKIA_API KineSkiaSurface* Kine_Skia_Surface_Create(int width, int height);
KINE_SKIA_API void Kine_Skia_Surface_Destroy(KineSkiaSurface* surface);

KINE_SKIA_API int Kine_Skia_Surface_GetWidth(const KineSkiaSurface* surface);
KINE_SKIA_API int Kine_Skia_Surface_GetHeight(const KineSkiaSurface* surface);
KINE_SKIA_API size_t Kine_Skia_Surface_GetRowBytes(const KineSkiaSurface* surface);
KINE_SKIA_API void* Kine_Skia_Surface_GetPixels(KineSkiaSurface* surface);

KINE_SKIA_API void Kine_Skia_Surface_Flush(KineSkiaSurface* surface);
KINE_SKIA_API void Kine_Skia_Surface_Clear(KineSkiaSurface* surface, KineSkiaColor color);
KINE_SKIA_API void Kine_Skia_Surface_DrawRect(
    KineSkiaSurface* surface,
    float x,
    float y,
    float width,
    float height,
    KineSkiaColor color);
KINE_SKIA_API void Kine_Skia_Surface_DrawRoundRect(
    KineSkiaSurface* surface,
    float x,
    float y,
    float width,
    float height,
    float radiusX,
    float radiusY,
    KineSkiaColor color);
KINE_SKIA_API void Kine_Skia_Surface_DrawCircle(
    KineSkiaSurface* surface,
    float cx,
    float cy,
    float radius,
    KineSkiaColor color);
KINE_SKIA_API void Kine_Skia_Surface_DrawLine(
    KineSkiaSurface* surface,
    float x0,
    float y0,
    float x1,
    float y1,
    float strokeWidth,
    KineSkiaColor color);

#ifdef __cplusplus
}
#endif

#endif
