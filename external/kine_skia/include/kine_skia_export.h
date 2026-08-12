#ifndef KINE_SKIA_EXPORT_H
#define KINE_SKIA_EXPORT_H

#if defined(_WIN32) && defined(KINE_BUILD_SHARED)
    #if defined(KINE_SKIA_BUILD_EXPORTS)
        #define KINE_SKIA_API __declspec(dllexport)
    #else
        #define KINE_SKIA_API __declspec(dllimport)
    #endif
#elif defined(__GNUC__) && defined(KINE_BUILD_SHARED)
    #define KINE_SKIA_API __attribute__((visibility("default")))
#else
    #define KINE_SKIA_API
#endif

#endif
