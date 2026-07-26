#ifndef KINE_RENDER_SHIM_EXPORT_H
#define KINE_RENDER_SHIM_EXPORT_H

#if defined(_WIN32) && defined(KINE_BUILD_SHARED)
    #ifdef KINE_BUILD_EXPORTS
        #define KINE_API __declspec(dllexport)
    #else
        #define KINE_API __declspec(dllimport)
    #endif
#elif defined(__GNUC__) && defined(KINE_BUILD_SHARED)
    #define KINE_API __attribute__((visibility("default")))
#else
    #define KINE_API
#endif

#ifdef __cplusplus
    #define KINE_EXTERN_C extern "C"
#else
    #define KINE_EXTERN_C
#endif

#endif // KINE_RENDER_SHIM_EXPORT_H
