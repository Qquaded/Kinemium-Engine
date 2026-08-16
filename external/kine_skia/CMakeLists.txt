cmake_minimum_required(VERSION 3.25)

project(kine_skia VERSION 0.1.0 LANGUAGES CXX)

include(ExternalProject)

option(KINE_BUILD_SHARED "Build Kinemium native wrappers as shared libraries" ON)
option(KINE_SKIA_AUTO_DOWNLOAD "Download and build Skia automatically when KINE_SKIA_DIR is not set" ON)
set(KINE_SKIA_GIT_TAG "main" CACHE STRING "Skia git tag, branch, or commit to download")
set(KINE_SKIA_BUILD_NAME "Kinemium" CACHE STRING "Skia GN output directory name under out/")
set(KINE_SKIA_LIBRARY "" CACHE FILEPATH "Path to an already built Skia library")
set(KINE_SKIA_DIR "" CACHE PATH "Path to an existing Skia checkout")
set(KINE_SKIA_INCLUDE_DIR "" CACHE PATH "Path to Skia headers when KINE_SKIA_LIBRARY points at a prebuilt library")

set(KINE_SKIA_PREBUILT_LIBRARY_PROVIDED OFF)
if(KINE_SKIA_LIBRARY)
    set(KINE_SKIA_PREBUILT_LIBRARY_PROVIDED ON)
endif()

if(KINE_BUILD_SHARED)
    set(KINE_SKIA_LIBRARY_TYPE SHARED)
else()
    set(KINE_SKIA_LIBRARY_TYPE STATIC)
endif()

add_library(kine_skia ${KINE_SKIA_LIBRARY_TYPE}
    src/kine_skia.cpp
)

target_compile_features(kine_skia PRIVATE cxx_std_20)

target_include_directories(kine_skia
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)

target_compile_definitions(kine_skia
    PRIVATE
        KINE_SKIA_BUILD_EXPORTS
    PUBLIC
        $<$<BOOL:${KINE_BUILD_SHARED}>:KINE_BUILD_SHARED>
)

set_target_properties(kine_skia PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

if(MSVC)
    set_property(TARGET kine_skia PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
    )
endif()

if(KINE_SKIA_DIR)
    set(KINE_SKIA_SOURCE_DIR "${KINE_SKIA_DIR}")
else()
    set(KINE_SKIA_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/skia-src")
endif()

file(MAKE_DIRECTORY "${KINE_SKIA_SOURCE_DIR}")

if(KINE_SKIA_PREBUILT_LIBRARY_PROVIDED AND NOT KINE_SKIA_DIR AND NOT KINE_SKIA_INCLUDE_DIR)
    message(FATAL_ERROR "KINE_SKIA_INCLUDE_DIR must be set when using KINE_SKIA_LIBRARY without KINE_SKIA_DIR")
endif()

if(NOT KINE_SKIA_INCLUDE_DIR)
    if(KINE_SKIA_DIR)
        set(KINE_SKIA_INCLUDE_DIR "${KINE_SKIA_DIR}")
    else()
        set(KINE_SKIA_INCLUDE_DIR "${KINE_SKIA_SOURCE_DIR}")
    endif()
endif()

if(NOT KINE_SKIA_LIBRARY)
    set(KINE_SKIA_LIBRARY
        "${KINE_SKIA_SOURCE_DIR}/out/${KINE_SKIA_BUILD_NAME}/${CMAKE_STATIC_LIBRARY_PREFIX}skia${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()

add_library(kine_skia_skiacore STATIC IMPORTED GLOBAL)
set_target_properties(kine_skia_skiacore PROPERTIES
    IMPORTED_LOCATION "${KINE_SKIA_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${KINE_SKIA_INCLUDE_DIR}"
)

if(NOT KINE_SKIA_DIR AND NOT KINE_SKIA_PREBUILT_LIBRARY_PROVIDED)
    if(NOT KINE_SKIA_AUTO_DOWNLOAD)
        message(FATAL_ERROR "KINE_SKIA_DIR or KINE_SKIA_LIBRARY must be set when KINE_SKIA_AUTO_DOWNLOAD is OFF")
    endif()

    find_package(Python3 REQUIRED COMPONENTS Interpreter)

    set(KINE_SKIA_GN_ARGS
        "is_debug=false"
        "is_official_build=false"
        "skia_enable_svg=true"
        "skia_use_libpng=true"
        "skia_use_freetype=true"
        "skia_use_system_freetype2=false"
        "skia_use_harfbuzz=true"
    )

    if(WIN32)
        list(APPEND KINE_SKIA_GN_ARGS
            "extra_cflags=[\"/MD\"]"
            "extra_cflags_cc=[\"/MD\"]"
        )
    else()
        list(APPEND KINE_SKIA_GN_ARGS
            "extra_cflags=[\"-fPIC\"]"
            "extra_cflags_cc=[\"-fPIC\"]"
        )
    endif()

    list(JOIN KINE_SKIA_GN_ARGS " " KINE_SKIA_GN_ARGS_STRING)

    find_program(KINE_SKIA_NINJA NAMES ninja ninja-build)
    if(KINE_SKIA_NINJA)
        set(KINE_SKIA_NINJA_COMMAND "${KINE_SKIA_NINJA}")
        set(KINE_SKIA_FETCH_NINJA_COMMAND "")
    else()
        set(KINE_SKIA_NINJA_COMMAND "<SOURCE_DIR>/third_party/ninja/ninja${CMAKE_EXECUTABLE_SUFFIX}")
        set(KINE_SKIA_FETCH_NINJA_COMMAND
            COMMAND "${Python3_EXECUTABLE}" "bin/fetch-ninja"
        )
    endif()

    ExternalProject_Add(kine_skia_external
        GIT_REPOSITORY "https://skia.googlesource.com/skia.git"
        GIT_TAG "${KINE_SKIA_GIT_TAG}"
        GIT_SHALLOW FALSE
        SOURCE_DIR "${KINE_SKIA_SOURCE_DIR}"
        BUILD_IN_SOURCE TRUE
        CONFIGURE_COMMAND
            "${Python3_EXECUTABLE}" "tools/git-sync-deps"
            ${KINE_SKIA_FETCH_NINJA_COMMAND}
            COMMAND "<SOURCE_DIR>/bin/gn${CMAKE_EXECUTABLE_SUFFIX}" "gen" "out/${KINE_SKIA_BUILD_NAME}" "--args=${KINE_SKIA_GN_ARGS_STRING}"
        BUILD_COMMAND
            "${KINE_SKIA_NINJA_COMMAND}" "-C" "out/${KINE_SKIA_BUILD_NAME}" "skia"
        INSTALL_COMMAND ""
        BUILD_BYPRODUCTS "${KINE_SKIA_LIBRARY}"
    )

    add_dependencies(kine_skia_skiacore kine_skia_external)
    add_dependencies(kine_skia kine_skia_external)
endif()

target_include_directories(kine_skia
    PRIVATE
        "${KINE_SKIA_INCLUDE_DIR}"
)

target_link_libraries(kine_skia
    PRIVATE
        kine_skia_skiacore
)

if(WIN32)
    target_link_libraries(kine_skia PRIVATE user32 gdi32 ole32 shell32)
elseif(APPLE)
    target_link_libraries(kine_skia
        PRIVATE
            "-framework CoreFoundation"
            "-framework CoreGraphics"
            "-framework CoreText"
    )
else()
    target_link_libraries(kine_skia PRIVATE pthread dl m)
endif()
