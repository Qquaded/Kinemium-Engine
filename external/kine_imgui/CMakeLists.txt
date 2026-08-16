cmake_minimum_required(VERSION 3.15...3.31)
project(kine_imgui VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(KINE_BUILD_SHARED "Build kine_imgui as a shared library (.dll/.so)" ON)

include(FetchContent)

# ---------------------------------------------------------------------------
# SDL3  - use the same target as the parent external build when available.
# ---------------------------------------------------------------------------
if(NOT TARGET SDL3::SDL3 AND NOT TARGET SDL3-shared AND NOT TARGET SDL3::SDL3-shared)
    FetchContent_Declare(
        SDL3
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG        release-3.2.0
        GIT_SHALLOW    TRUE
    )
    set(SDL_SHARED  ON  CACHE BOOL "" FORCE)
    set(SDL_STATIC  OFF CACHE BOOL "" FORCE)
    set(SDL_TESTS   OFF CACHE BOOL "" FORCE)
    set(SDL_EXAMPLES OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(SDL3)
endif()

if(TARGET SDL3::SDL3)
    set(KINE_SDL3_TARGET SDL3::SDL3)
elseif(TARGET SDL3::SDL3-shared)
    set(KINE_SDL3_TARGET SDL3::SDL3-shared)
elseif(TARGET SDL3-shared)
    set(KINE_SDL3_TARGET SDL3-shared)
else()
    message(FATAL_ERROR "kine_imgui: SDL3 target not found")
endif()

# ---------------------------------------------------------------------------
# Dear ImGui — fetched from GitHub at the specified tag.
# We compile imgui core plus the SDL3/SDL_Renderer backends directly into our
# DLL, mirroring Dear ImGui's official SDL3 renderer example.
# ---------------------------------------------------------------------------
set(KINE_IMGUI_TAG "v1.91.9" CACHE STRING "Dear ImGui git tag to fetch")

FetchContent_Declare(
    imgui
    GIT_REPOSITORY https://github.com/ocornut/imgui.git
    GIT_TAG        ${KINE_IMGUI_TAG}
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(imgui)

# Build ImGui as an INTERFACE / object library so we can pull sources.
# FetchContent puts sources at ${imgui_SOURCE_DIR}.
set(IMGUI_DIR ${imgui_SOURCE_DIR})

set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_demo.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdl3.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdlrenderer3.cpp
)

# ---------------------------------------------------------------------------
# kine_imgui shared library
# ---------------------------------------------------------------------------
if(KINE_BUILD_SHARED)
    set(_LIB_TYPE SHARED)
else()
    set(_LIB_TYPE STATIC)
endif()

add_library(kine_imgui ${_LIB_TYPE}
    src/kine_imgui.cpp
    ${IMGUI_SOURCES}
)

target_include_directories(kine_imgui
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        ${IMGUI_DIR}
        ${IMGUI_DIR}/backends
)

target_compile_definitions(kine_imgui
    PRIVATE
        KINE_IMGUI_BUILD_EXPORTS
    PUBLIC
        $<$<BOOL:${KINE_BUILD_SHARED}>:KINE_IMGUI_BUILD_SHARED>
)

# Silence MSVC warnings inside Dear ImGui headers
if(MSVC)
    target_compile_options(kine_imgui PRIVATE /wd4996 /wd4244 /wd4267)
    set_property(TARGET kine_imgui PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

# ---------------------------------------------------------------------------
# Link: SDL3
# ---------------------------------------------------------------------------
target_link_libraries(kine_imgui PRIVATE ${KINE_SDL3_TARGET})

# ---------------------------------------------------------------------------
# Output locations (mirrors kine_render_shim convention)
# ---------------------------------------------------------------------------
set_target_properties(kine_imgui PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)
