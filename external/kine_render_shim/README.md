# kine_render_shim

Minimal SDL3-backed C library scaffold meant to be loaded through Luau FFI.
The public `kine_render_shim` target no longer includes, fetches, or links
raylib.

## Build

```bash
mkdir build && cd build
cmake ..
cmake --build . --config Release
```

The compiled library lands in `build/bin/` (`kine_render_shim.dll` on Windows,
`.so` on Linux, `.dylib` on macOS). SDL3 is downloaded with CMake
`FetchContent` and linked by the shim.

## Extending

1. Declare the function in `include/kine_render_shim.h`, prefixed with
   `KINE_API` so it exports correctly on all platforms.
2. Implement it in `src/kine_render_shim.c`.
3. Rebuild.
4. Load `kine_render_shim.dll`/`.so`/`.dylib` from Luau FFI and call the
   exported `Kine_*` functions.

Small smoke-test function:

```lua
local ffi = require("ffi")
local lib = ffi.load("./build/bin/kine_render_shim.dll")
print(lib.Kine_GetVersion())
```

## Filament integration (`kine_filament_shim`)

The optional `kine_filament_shim` target bridges Google Filament into an
existing OpenGL host context. It keeps Filament C++ objects (`Engine`, `Scene`,
`View`, `Camera`, ...) behind opaque handles so Luau never touches C++ object
layouts.

Texture import uses `KineGLTextureInfo`:

```c
typedef struct KineGLTextureInfo {
    unsigned int id;
    int width;
    int height;
    int mipmaps;
    int format;
} KineGLTextureInfo;
```

That layout intentionally matches the existing engine texture descriptor, but
the API is not tied to a raylib header or CMake target.

Build with Filament enabled:

```bash
cmake .. -DKINE_WITH_FILAMENT=ON
cmake --build . --target kine_filament_shim --config Release
```

If `FILAMENT_DIR` is not provided, the CMake file downloads the matching
prebuilt Filament SDK and uses its `matc`/`resgen` tools to compile embedded
materials.
