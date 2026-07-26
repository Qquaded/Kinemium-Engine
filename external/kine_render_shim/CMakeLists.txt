cmake_minimum_required(VERSION 3.15...3.31)
project(kine_render_shim VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

option(KINE_BUILD_SHARED "Build kine_render_shim as a shared library (.dll/.so)" ON)
option(KINE_VENDOR_RAYLIB "Fetch and build raylib automatically if not already provided" ON)

set(BUILD_SHARED_LIBS ${KINE_BUILD_SHARED})

# --------------------------------------------------------------
# raylib dependency
# --------------------------------------------------------------
# If this is built as a subdirectory of a bigger project that already
# defines a `raylib` CMake target elsewhere (e.g. Kinemium-Engine's own
# external/ setup), reuse that target instead of fetching a second copy.
if(NOT TARGET raylib)
    if(KINE_VENDOR_RAYLIB)
        include(FetchContent)
        set(FETCHCONTENT_QUIET FALSE)

        # Pin to a specific raylib release. Bump this yourself when you
        # want a newer version — using a floating branch here would make
        # builds non-reproducible.
        FetchContent_Declare(
            raylib
            GIT_REPOSITORY https://github.com/raysan5/raylib.git
            GIT_TAG        5.5
            GIT_SHALLOW    TRUE
        )

        set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
        set(BUILD_GAMES OFF CACHE BOOL "" FORCE)

        FetchContent_MakeAvailable(raylib)

        if(TARGET raylib)
            set_target_properties(raylib PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
                LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
                ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
            )
        endif()
    else()
        find_package(raylib REQUIRED)
    endif()
endif()

# --------------------------------------------------------------
# Library target
# --------------------------------------------------------------
add_library(${PROJECT_NAME}
    src/kine_render_shim.c
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        raylib
)

# raylib's own CMake target doesn't reliably export its public include
# directory when consumed via add_subdirectory/FetchContent (as opposed to
# a properly installed find_package). Add it explicitly so <raylib.h>
# actually resolves.
message(STATUS "kine_render_shim: raylib_SOURCE_DIR = '${raylib_SOURCE_DIR}'")
message(STATUS "kine_render_shim: RAYLIB_INCLUDE_DIRS = '${RAYLIB_INCLUDE_DIRS}'")

if(raylib_SOURCE_DIR)
    target_include_directories(${PROJECT_NAME} PRIVATE ${raylib_SOURCE_DIR}/src)
elseif(RAYLIB_INCLUDE_DIRS)
    target_include_directories(${PROJECT_NAME} PRIVATE ${RAYLIB_INCLUDE_DIRS})
endif()

# KINE_BUILD_EXPORTS is only defined while compiling the library itself,
# so consumers including the header get dllimport instead of dllexport.
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        KINE_BUILD_EXPORTS
    PUBLIC
        $<$<BOOL:${KINE_BUILD_SHARED}>:KINE_BUILD_SHARED>
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    C_VISIBILITY_PRESET hidden
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# --------------------------------------------------------------
# Optional Filament integration (kine_filament_shim)
# --------------------------------------------------------------
# Filament ships as a prebuilt SDK per platform (headers + static libs) --
# building it from source is a multi-tool, multi-hour affair, so we just
# point at a release you've already downloaded from
# https://github.com/google/filament/releases (pick the tnt-<version>-<os>.tgz
# matching your platform) and unpacked somewhere.
#
#   cmake .. -DKINE_WITH_FILAMENT=ON -DFILAMENT_DIR=/path/to/filament
#
# FILAMENT_DIR should contain include/ and lib/x86_64/ (or lib/arm64/ on
# Apple Silicon -- override FILAMENT_LIB_ARCH if so).
option(KINE_WITH_FILAMENT "Build the Filament integration (kine_filament_shim)" ON)

if(KINE_WITH_FILAMENT)
    if(NOT DEFINED FILAMENT_DIR)
        include(FetchContent)
        set(FILAMENT_VERSION "1.74.0")
        if(WIN32)
            set(FILAMENT_OS "windows")
        elseif(APPLE)
            set(FILAMENT_OS "mac")
        else()
            if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|ARM64")
                set(FILAMENT_OS "arm-linux")
            else()
                set(FILAMENT_OS "linux")
            endif()
        endif()

        set(FILAMENT_URL "https://github.com/google/filament/releases/download/v${FILAMENT_VERSION}/filament-v${FILAMENT_VERSION}-${FILAMENT_OS}.tgz")
        message(STATUS "FILAMENT_DIR not defined. Fetching prebuilt Filament ${FILAMENT_VERSION} from ${FILAMENT_URL}...")
        
        FetchContent_Declare(
            filament_prebuilt
            URL ${FILAMENT_URL}
        )
        FetchContent_MakeAvailable(filament_prebuilt)
        set(FILAMENT_DIR ${filament_prebuilt_SOURCE_DIR})
    endif()

    if(NOT DEFINED FILAMENT_LIB_ARCH)
        if(APPLE AND CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
            set(FILAMENT_LIB_ARCH "arm64")
        else()
            set(FILAMENT_LIB_ARCH "x86_64")
        endif()
    endif()

    # ------------------------------------------------------------------
    # Compile the default material with matc (ships in the Filament SDK)
    # and embed the .filamat bytes as a C array using resgen.
    # ------------------------------------------------------------------
    set(MATC_EXE    "${FILAMENT_DIR}/bin/matc${CMAKE_EXECUTABLE_SUFFIX}")
    set(RESGEN_EXE  "${FILAMENT_DIR}/bin/resgen${CMAKE_EXECUTABLE_SUFFIX}")

    set(MAT_SRC  "${CMAKE_CURRENT_SOURCE_DIR}/src/kine_default.mat")
    set(MAT_BIN  "${CMAKE_CURRENT_BINARY_DIR}/kine_default.filamat")
    set(MAT_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    set(MAT_GEN_CPP "${MAT_GEN_DIR}/kine_default_package.c")
    set(MAT_GEN_H   "${MAT_GEN_DIR}/kine_default_package.h")

    file(MAKE_DIRECTORY ${MAT_GEN_DIR})

    add_custom_command(
        OUTPUT  ${MAT_BIN}
        COMMAND ${MATC_EXE} -a opengl -p desktop -o ${MAT_BIN} ${MAT_SRC}
        DEPENDS ${MAT_SRC}
        COMMENT "Compiling Filament material: kine_default.mat"
    )

    add_custom_command(
        OUTPUT  ${MAT_GEN_CPP} ${MAT_GEN_H}
        COMMAND ${RESGEN_EXE} -c -p kine_default_package -x ${MAT_GEN_DIR} ${MAT_BIN}
        DEPENDS ${MAT_BIN}
        COMMENT "Generating material package: kine_default_package"
    )

    add_library(kine_filament_shim
        src/kine_filament_shim.cpp
        ${MAT_GEN_CPP}
    )

    target_include_directories(kine_filament_shim
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        PRIVATE
            ${FILAMENT_DIR}/include
            ${MAT_GEN_DIR}
    )

    if(WIN32)
        # Windows Filament prebuilts are nested by MSVC CRT type (md/mdd/mt/mtd)
        target_link_directories(kine_filament_shim PRIVATE 
            $<$<CONFIG:Debug>:${FILAMENT_DIR}/lib/${FILAMENT_LIB_ARCH}/mdd>
            $<$<NOT:$<CONFIG:Debug>>:${FILAMENT_DIR}/lib/${FILAMENT_LIB_ARCH}/md>
        )
    else()
        target_link_directories(kine_filament_shim PRIVATE ${FILAMENT_DIR}/lib/${FILAMENT_LIB_ARCH})
    endif()

    # This is the link line the Filament README itself documents for
    # consuming a prebuilt release (minus JNI/matc-only pieces we don't
    # need: filamat, vkshaders, bluevk -- we're OpenGL-only here).
    set(KINE_FILAMENT_CORE_LIBS
        filament
        backend
        bluegl
        bluevk
        filabridge
        filaflat
        utils
        geometry
        smol-v
        zstd
        uberarchive
        shaders
    )

    if(WIN32)
        target_link_libraries(kine_filament_shim
            PRIVATE
                raylib
                ${KINE_FILAMENT_CORE_LIBS}
                gdi32 user32 opengl32
        )
    elseif(APPLE)
        target_link_libraries(kine_filament_shim
            PRIVATE
                raylib
                ${KINE_FILAMENT_CORE_LIBS}
                "-framework Cocoa"
                "-framework OpenGL"
                "-framework CoreVideo"
                "-framework IOKit"
                "-framework QuartzCore"
        )
    else()
        # GNU ld cares about static-lib ordering because these archives
        # reference each other circularly; wrap in --start-group/--end-group
        # so it re-scans until everything resolves, instead of hand-tuning
        # link order (which breaks again on the next Filament version bump).
        target_link_libraries(kine_filament_shim
            PRIVATE
                raylib
                -Wl,--start-group
                ${KINE_FILAMENT_CORE_LIBS}
                -Wl,--end-group
                GL X11 dl pthread
        )
    endif()

    target_compile_features(kine_filament_shim PRIVATE cxx_std_20)

    target_compile_definitions(kine_filament_shim
        PRIVATE
            KINE_BUILD_EXPORTS
        PUBLIC
            $<$<BOOL:${KINE_BUILD_SHARED}>:KINE_BUILD_SHARED>
    )

    set_target_properties(kine_filament_shim PROPERTIES
        C_VISIBILITY_PRESET hidden
        CXX_VISIBILITY_PRESET hidden
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )

    # Standalone C smoke test -- no Luau involved, just proves the shim
    # itself works (context sharing + texture import) before you wire up
    # FFI on top of it. See examples/standalone_c/main.c.
    option(KINE_BUILD_FILAMENT_EXAMPLE "Build the standalone kine_filament_shim example executable" OFF)

    if(KINE_BUILD_FILAMENT_EXAMPLE)
        add_executable(kine_filament_example
            examples/standalone_c/main.c
        )

        target_link_libraries(kine_filament_example
            PRIVATE
                raylib
                kine_filament_shim
        )

        set_target_properties(kine_filament_example PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        )
    endif()
endif()
