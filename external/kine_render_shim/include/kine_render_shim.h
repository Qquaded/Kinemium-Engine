#ifndef KINE_RENDER_SHIM_H
#define KINE_RENDER_SHIM_H

#include "kine_render_shim_export.h"

#ifdef __cplusplus
extern "C" {
#endif

KINE_API const char* Kine_GetVersion(void);
KINE_API int Kine_GetSDLBuildVersion(void);

#ifdef __cplusplus
}
#endif

#endif // KINE_RENDER_SHIM_H
