#ifndef KINE_RENDER_SHIM_H
#define KINE_RENDER_SHIM_H

#include "raylib.h"
#include "kine_render_shim_export.h"

#ifdef __cplusplus
extern "C" {
#endif

KINE_API const char* Kine_GetVersion(void);

#ifdef __cplusplus
}
#endif

#endif // KINE_RENDER_SHIM_H
