#ifndef KINE_IMGUI_EXPORT_H
#define KINE_IMGUI_EXPORT_H

#if defined(_WIN32) && defined(KINE_IMGUI_BUILD_SHARED)
    #ifdef KINE_IMGUI_BUILD_EXPORTS
        #define KINE_IMGUI_API __declspec(dllexport)
    #else
        #define KINE_IMGUI_API __declspec(dllimport)
    #endif
#elif defined(__GNUC__) && defined(KINE_IMGUI_BUILD_SHARED)
    #define KINE_IMGUI_API __attribute__((visibility("default")))
#else
    #define KINE_IMGUI_API
#endif

#endif // KINE_IMGUI_EXPORT_H
