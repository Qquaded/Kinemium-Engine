#ifndef KINE_FILAMENT_SHIM_H
#define KINE_FILAMENT_SHIM_H

#include "kine_render_shim_export.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

typedef struct KineFilamentContext KineFilamentContext;
typedef struct KineFilamentMesh    KineFilamentMesh;
typedef struct KineFilamentTex     KineFilamentTex;

// ---------------------------------------------------------------------------
// Material kinds for Kine_Filament_DrawMeshEx's materialKind parameter.
// Keep in sync with the KineMaterialKind enum in kine_filament_shim.cpp.
// ---------------------------------------------------------------------------
#define KINE_MAT_DEFAULT 0
#define KINE_MAT_GLASS   1
#define KINE_MAT_NEON    2
#define KINE_MAT_WATER   3

KINE_API KineFilamentContext* Kine_Filament_Create(int width, int height);
KINE_API unsigned int Kine_Filament_GetColorTextureId(KineFilamentContext* ctx);
KINE_API void Kine_Filament_Destroy(KineFilamentContext* ctx);

// deltaTime (seconds) drives ctx->time, used to animate the water material.
KINE_API void Kine_Filament_RenderFrame(KineFilamentContext* ctx, float deltaTime);

KINE_API void Kine_Filament_Resize(KineFilamentContext* ctx, int width, int height);

KINE_API void Kine_Filament_CreateSky(KineFilamentContext* ctx, float r, float g, float b, float a);
KINE_API void Kine_Filament_SetPostProcessing(KineFilamentContext* ctx, bool enabled);

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

// ---------------------------------------------------------------------------
// DrawMeshEx -- queues a mesh to be drawn this frame with a chosen material.
//
//   materialKind : one of KINE_MAT_DEFAULT / KINE_MAT_GLASS / KINE_MAT_NEON / KINE_MAT_WATER
//   r,g,b        : base/emissive color [0..1]
//   param1       : roughness (default/glass/water) or intensity (neon)
//   param2       : metallic (default) or ior (glass/water) -- unused for neon
//   param3       : unused (default/neon) or thickness (glass/water)
//   transmission : unused (default/neon) or transmission (glass/water)
//   mat4         : column-major float[16] world transform (raylib Matrix layout)
//   tex          : optional KineFilamentTex* (from Kine_Filament_CreateTex), nil for no texture
// ---------------------------------------------------------------------------

KINE_API KineFilamentMesh* Kine_Filament_CreateCustomMesh(
    KineFilamentContext* ctx,
    const float* vertexData,   // interleaved px,py,pz,nx,ny,nz,u,v — 8 floats/vertex
    int vertexCount,
    const uint16_t* indices,
    int indexCount);
    
KINE_API void Kine_Filament_DrawMeshEx(
    KineFilamentContext* ctx,
    KineFilamentMesh*    mesh,
    int                  materialKind,
    float r, float g, float b,
    float param1,
    float param2,
    float param3,
    float transmission,
    float* mat4,
    bool   castShadows,
    bool   receiveShadows,
    bool   culling,
    KineFilamentTex* tex);

KINE_API void Kine_Filament_ReadPixels(KineFilamentContext* ctx, void* outPixels);
KINE_API int  Kine_Filament_GetWidth(KineFilamentContext* ctx);
KINE_API int  Kine_Filament_GetHeight(KineFilamentContext* ctx);

// ---------------------------------------------------------------------------
// Atmospheric sky.
//
// Drives the procedural sky appearance each frame.  All colour components are
// linear [0..1].
//
//   sunDirX/Y/Z   : normalised world-space direction *toward* the sun.
//                   Y > 0 = above horizon, Y < 0 = below horizon.
//   skyR/G/B      : zenith (overhead) sky colour.
//   horizonR/G/B  : horizon band colour (blended in at low sun elevation).
//   groundR/G/B   : ground-fill colour visible when sun is below horizon.
//   sunIntensity  : sun light intensity in lux (e.g. 100 000 for full day,
//                   0 for night).  Controls both the sun-light entity and
//                   the brightness of the blended clear colour.
// ---------------------------------------------------------------------------
KINE_API void Kine_Filament_SetSkyAtmosphere(
    KineFilamentContext* ctx,
    float sunDirX,    float sunDirY,    float sunDirZ,
    float skyR,       float skyG,       float skyB,
    float horizonR,   float horizonG,   float horizonB,
    float groundR,    float groundG,    float groundB,
    float sunIntensity);

// ---------------------------------------------------------------------------
// Custom Texture Cubemap Skybox
// Takes 6 Raylib Texture2D pointers and builds a cubemap skybox from them.
// Faces must all be square and have identical dimensions.
// ---------------------------------------------------------------------------
KINE_API void Kine_Filament_CreateSkyboxCubemap(
    KineFilamentContext* ctx,
    void* texPosX, void* texNegX,
    void* texPosY, void* texNegY,
    void* texPosZ, void* texNegZ);

// ---------------------------------------------------------------------------
// Set the built-in sun light direction and intensity independently of the sky.
// ---------------------------------------------------------------------------
KINE_API void Kine_Filament_SetSun(
    KineFilamentContext* ctx,
    float sunDirX, float sunDirY, float sunDirZ,
    float sunIntensity);

// ---------------------------------------------------------------------------
// Point / spot light management.
// Returns an opaque integer light ID, or -1 on failure.
// ---------------------------------------------------------------------------
KINE_API int  Kine_Filament_CreateLight(
    KineFilamentContext* ctx,
    float px, float py, float pz,
    float cr, float cg, float cb,
    float intensity, float falloff);

KINE_API void Kine_Filament_SetColorLight(
    KineFilamentContext* ctx, int light, float r, float g, float b);
KINE_API void Kine_Filament_SetIntensityLight(
    KineFilamentContext* ctx, int light, float intensity);
KINE_API void Kine_Filament_SetFalloffLight(
    KineFilamentContext* ctx, int light, float falloff);
KINE_API void Kine_Filament_SetPositionLight(
    KineFilamentContext* ctx, int light, float x, float y, float z);

// ---------------------------------------------------------------------------
// Screen-space decal management.
// Returns an opaque integer decal ID, or -1 on failure.
// ---------------------------------------------------------------------------
KINE_API int  Kine_Filament_CreateDecal(
    KineFilamentContext* ctx,
    float width, float height,
    void* rlTexturePtr,
    float offsetStudsU, float offsetStudsV,
    float studsPerTileU, float studsPerTileV,
    bool culling, bool castShadows, bool receiveShadows);

KINE_API bool Kine_Filament_SetDecalTiling(
    KineFilamentContext* ctx, int decal,
    float width, float height,
    float offsetStudsU, float offsetStudsV,
    float studsPerTileU, float studsPerTileV);

KINE_API void Kine_Filament_RemoveDecal(KineFilamentContext* ctx, int decal);
KINE_API bool Kine_Filament_SetDecalTransform(KineFilamentContext* ctx, int decal, float* mat4);

KINE_API bool Kine_Filament_EditDecal(
    KineFilamentContext* ctx, int decal,
    float width, float height,
    bool culling, bool castShadows, bool receiveShadows);

#ifdef __cplusplus
}
#endif

#endif