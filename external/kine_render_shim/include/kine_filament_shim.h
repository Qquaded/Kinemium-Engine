#ifndef KINE_FILAMENT_SHIM_H
#define KINE_FILAMENT_SHIM_H

#include "kine_render_shim_export.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct KineFilamentContext KineFilamentContext;
typedef struct KineFilamentMesh    KineFilamentMesh;
typedef struct KineFilamentTex     KineFilamentTex;

KINE_API KineFilamentContext* Kine_Filament_Create(int width, int height);
KINE_API unsigned int Kine_Filament_GetColorTextureId(KineFilamentContext* ctx);
KINE_API void Kine_Filament_Destroy(KineFilamentContext* ctx);
KINE_API void Kine_Filament_RenderFrame(KineFilamentContext* ctx);
KINE_API void Kine_Filament_Resize(KineFilamentContext* ctx, int width, int height);

KINE_API void* Kine_Filament_GetEngine(KineFilamentContext* ctx);
KINE_API void* Kine_Filament_GetScene(KineFilamentContext* ctx);
KINE_API void* Kine_Filament_GetView(KineFilamentContext* ctx);
KINE_API void* Kine_Filament_GetCamera(KineFilamentContext* ctx);

KINE_API void Kine_Filament_SetCameraLookAt(
    KineFilamentContext* ctx,
    float eyeX, float eyeY, float eyeZ,
    float targetX, float targetY, float targetZ,
    float upX, float upY, float upZ);

KINE_API void Kine_Filament_SetCameraPerspective(
    KineFilamentContext* ctx,
    double fovYDegrees, double aspect, double nearPlane, double farPlane);

KINE_API void Kine_Filament_SetCameraPosition(KineFilamentContext* ctx, float x, float y, float z);
KINE_API void Kine_Filament_SetCameraDirection(KineFilamentContext* ctx, float dx, float dy, float dz);


KINE_API KineFilamentMesh* Kine_Filament_CreateMesh(KineFilamentContext* ctx, int shape);

KINE_API void Kine_Filament_DestroyMesh(KineFilamentContext* ctx, KineFilamentMesh* mesh);
KINE_API void Kine_Filament_DebugPrintPixel(KineFilamentContext* ctx);

KINE_API KineFilamentTex* Kine_Filament_CreateTex(KineFilamentContext* ctx, void* rlTexturePtr);
KINE_API void             Kine_Filament_DestroyTex(KineFilamentContext* ctx, KineFilamentTex* tex);


KINE_API void Kine_Filament_DrawMesh(
    KineFilamentContext* ctx,
    KineFilamentMesh*   mesh,
    float r, float g, float b,
    KineFilamentTex*    tex,
    float               transparency,
    float               roughness,
    float               metallic,
    float*              mat4);

KINE_API void Kine_Filament_ReadPixels(KineFilamentContext* ctx, void* outPixels);
KINE_API int  Kine_Filament_GetWidth(KineFilamentContext* ctx);
KINE_API int  Kine_Filament_GetHeight(KineFilamentContext* ctx);

#ifdef __cplusplus
}
#endif

#endif 
