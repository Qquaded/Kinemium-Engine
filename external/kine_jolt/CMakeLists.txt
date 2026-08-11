cmake_minimum_required(VERSION 3.25)

project(JoltWrapper
    VERSION 1.0.0
    LANGUAGES CXX
)

include(FetchContent)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ---------------------------------------------------------
# Jolt Physics
# ---------------------------------------------------------

set(USE_ASSERTS OFF CACHE BOOL "" FORCE)
set(DOUBLE_PRECISION ON CACHE BOOL "" FORCE)
set(GENERATE_DEBUG_SYMBOLS ON CACHE BOOL "" FORCE)
set(OVERRIDE_CXX_FLAGS ON CACHE BOOL "" FORCE)
set(CROSS_PLATFORM_DETERMINISTIC OFF CACHE BOOL "" FORCE)
set(FLOATING_POINT_EXCEPTIONS_ENABLED OFF CACHE BOOL "" FORCE)
set(CPP_EXCEPTIONS_ENABLED OFF CACHE BOOL "" FORCE)
set(CPP_RTTI_ENABLED OFF CACHE BOOL "" FORCE)

set(OBJECT_LAYER_BITS 32 CACHE STRING "" FORCE)

set(USE_SSE4_1 ON CACHE BOOL "" FORCE)
set(USE_SSE4_2 ON CACHE BOOL "" FORCE)
set(USE_AVX ON CACHE BOOL "" FORCE)
set(USE_AVX2 ON CACHE BOOL "" FORCE)
set(USE_AVX512 OFF CACHE BOOL "" FORCE)
set(USE_LZCNT ON CACHE BOOL "" FORCE)
set(USE_TZCNT ON CACHE BOOL "" FORCE)
set(USE_F16C ON CACHE BOOL "" FORCE)
set(USE_FMADD ON CACHE BOOL "" FORCE)

set(TRACK_BROADPHASE_STATS OFF CACHE BOOL "" FORCE)
set(TRACK_NARROWPHASE_STATS OFF CACHE BOOL "" FORCE)

set(DEBUG_RENDERER_IN_DEBUG_AND_RELEASE OFF CACHE BOOL "" FORCE)
set(DEBUG_RENDERER_IN_DISTRIBUTION OFF CACHE BOOL "" FORCE)
set(PROFILER_IN_DEBUG_AND_RELEASE OFF CACHE BOOL "" FORCE)
set(PROFILER_IN_DISTRIBUTION OFF CACHE BOOL "" FORCE)

set(JPH_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(DISABLE_CUSTOM_ALLOCATOR OFF CACHE BOOL "" FORCE)
set(USE_STD_VECTOR OFF CACHE BOOL "" FORCE)
set(ENABLE_ALL_WARNINGS OFF CACHE BOOL "" FORCE)
set(ENABLE_OBJECT_STREAM OFF CACHE BOOL "" FORCE)

# ---------------------------------------------------------
# Download Jolt
# ---------------------------------------------------------

FetchContent_Declare(
    Jolt
    GIT_REPOSITORY https://github.com/jrouwe/JoltPhysics.git
    GIT_TAG master
    GIT_SHALLOW TRUE
)

FetchContent_GetProperties(Jolt)

if(NOT jolt_POPULATED)
    FetchContent_Populate(Jolt)
endif()

# Jolt's CMakeLists.txt is inside Build/
add_subdirectory(
    ${jolt_SOURCE_DIR}/Build
    ${jolt_BINARY_DIR}
)

# ---------------------------------------------------------
# Jolt Wrapper DLL
# ---------------------------------------------------------

add_library(JoltWrapper SHARED
    src/jolt_wrapper.cpp
)

target_include_directories(JoltWrapper
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(JoltWrapper
    PRIVATE
        Jolt
)

target_compile_definitions(JoltWrapper
    PRIVATE
        JOLT_WRAPPER_EXPORTS
)

if(WIN32)
    target_compile_definitions(JoltWrapper PRIVATE NOMINMAX)
endif()

set_target_properties(JoltWrapper PROPERTIES
    OUTPUT_NAME "JoltWrapper"
)

# Jolt is built with OVERRIDE_CXX_FLAGS=ON which forces /MT (static CRT).
# JoltWrapper must use the same CRT to avoid LNK2038 mismatches.
if(MSVC)
    set_property(TARGET JoltWrapper PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
    )
endif()