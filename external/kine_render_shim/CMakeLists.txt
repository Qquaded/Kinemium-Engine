cmake_minimum_required(VERSION 3.15...3.31)
project(kine_render_shim VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

option(KINE_BUILD_SHARED "Build kine_render_shim as a shared library (.dll/.so)" ON)

set(BUILD_SHARED_LIBS ${KINE_BUILD_SHARED})

include(FetchContent)

# SDL3
FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG release-3.2.0
    GIT_SHALLOW TRUE
)

set(SDL_SHARED ON CACHE BOOL "" FORCE)
set(SDL_STATIC OFF CACHE BOOL "" FORCE)
set(SDL_TESTS OFF CACHE BOOL "" FORCE)
set(SDL_EXAMPLES OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(SDL3)

if(TARGET SDL3::SDL3)
    set(KINE_SDL3_TARGET SDL3::SDL3)
elseif(TARGET SDL3::SDL3-shared)
    set(KINE_SDL3_TARGET SDL3::SDL3-shared)
elseif(TARGET SDL3-shared)
    set(KINE_SDL3_TARGET SDL3-shared)
else()
    message(FATAL_ERROR "SDL3 target was not created by FetchContent")
endif()

if(TARGET SDL3-shared AND TARGET SDL3_Headers)
    install(TARGETS SDL3-shared SDL3_Headers EXPORT sdl3-targets)
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
        ${KINE_SDL3_TARGET}
)

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

    set(MAT_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    file(MAKE_DIRECTORY ${MAT_GEN_DIR})

    function(kine_add_material NAME)
        set(_src "${CMAKE_CURRENT_SOURCE_DIR}/src/${NAME}.mat")
        set(_bin "${CMAKE_CURRENT_BINARY_DIR}/${NAME}.filamat")
        set(_cpp "${MAT_GEN_DIR}/${NAME}_package.c")
        set(_h   "${MAT_GEN_DIR}/${NAME}_package.h")

        add_custom_command(
            OUTPUT  ${_bin}
            COMMAND ${MATC_EXE} -a opengl -p desktop -o ${_bin} ${_src}
            DEPENDS ${_src}
            COMMENT "Compiling Filament material: ${NAME}.mat"
        )

        add_custom_command(
            OUTPUT  ${_cpp} ${_h}
            COMMAND ${RESGEN_EXE} -c -p ${NAME}_package -x ${MAT_GEN_DIR} ${_bin}
            DEPENDS ${_bin}
            COMMENT "Generating material package: ${NAME}_package"
        )

        set(${NAME}_GEN_CPP ${_cpp} PARENT_SCOPE)
        set(${NAME}_GEN_H   ${_h}   PARENT_SCOPE)
    endfunction()

    kine_add_material(kine_default)
    kine_add_material(kine_glass)
    kine_add_material(kine_neon)
    kine_add_material(kine_water)
    kine_add_material(kine_decal)

    add_library(kine_filament_shim
        src/kine_filament_shim.cpp
        ${kine_default_GEN_CPP}
        ${kine_glass_GEN_CPP}
        ${kine_neon_GEN_CPP}
        ${kine_water_GEN_CPP}
        ${kine_decal_GEN_CPP}
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
                ${KINE_SDL3_TARGET}
                ${KINE_FILAMENT_CORE_LIBS}
                gdi32 user32 opengl32
        )
    elseif(APPLE)
        target_link_libraries(kine_filament_shim
            PRIVATE
                ${KINE_SDL3_TARGET}
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
                ${KINE_SDL3_TARGET}
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
                ${KINE_SDL3_TARGET}
                kine_filament_shim
        )

        set_target_properties(kine_filament_example PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        )
    endif()
endif()
