# kine_render_shim

Minimal C library scaffold, linked against raylib, meant to be loaded via
Luau FFI. The point of this library is to move raw struct/pointer poking
(material fields, shader locations, framebuffer setup, etc.) out of Luau —
where nothing checks struct layouts against the real C ABI — into C, where
the compiler verifies correctness at build time.

## Build

Standalone, fetching raylib automatically:

```bash
mkdir build && cd build
cmake ..
cmake --build . --parallel --config Debug
```

The compiled library lands in `build/bin/` (`kine_render_shim.dll` on
Windows, `.so` on Linux, `.dylib` on macOS).

## Using an already-vendored raylib

If you drop this folder into a bigger project that already builds a
`raylib` CMake target elsewhere (e.g. via `add_subdirectory`), this
CMakeLists.txt detects that automatically and reuses it instead of
fetching a second copy — no changes needed, just make sure the other
`raylib` target is added to the build *before* `add_subdirectory` on this
folder.

To force using a system-installed raylib instead of fetching:

```bash
cmake .. -DKINE_VENDOR_RAYLIB=OFF
```

## Adding functions

1. Declare the function in `include/kine_render_shim.h`, prefixed with
   `KINE_API` so it gets exported correctly on all platforms.
2. Implement it in `src/kine_render_shim.c`.
3. Rebuild.
4. Load it from Luau the same way you already load raylib/R3D via FFI —
   point the loader at `kine_render_shim.dll`/`.so`, and its exported
   `Kine_*` functions become callable.

## Verifying it works

After building, load the library from Luau and call:

```lua
print(lib.Kine_GetVersion())
-- should print: kine_render_shim 0.1.0
```

If that prints correctly, the build/link/export pipeline is confirmed
working before you add any real rendering code.

## Filament integration (`kine_filament_shim`)

A second target, `kine_filament_shim`, bridges Google Filament into a
raylib `RenderTexture2D`. Same philosophy as the rest of this repo: every
Filament C++ object (`Engine`, `Scene`, `View`, `Camera`, ...) stays behind
an opaque `void*` handle, so Luau never touches a struct layout — just
numbers and pointers passed straight back into the next `Kine_Filament_*`
call.

### How it works

1. `Kine_Filament_Create` grabs raylib's *current* OpenGL context (via
   `wglGetCurrentContext` / `glXGetCurrentContext` / `CGLGetCurrentContext`
   depending on platform) and creates a Filament `Engine` that shares it.
2. Since there's no second window to hand Filament, it gets a headless
   `SwapChain` instead.
3. Raylib's existing color texture (`renderTexture.texture.id`) is
   wrapped with `Texture::Builder().import(...)` and attached to a
   Filament `RenderTarget` — Filament renders straight into the same GL
   texture object raylib's FBO owns. No copy, no readback.
4. `Kine_Filament_RenderFrame` renders one Filament frame, then calls
   raylib's `rlDisableFramebuffer()` so rlgl's own state assumptions hold
   for whatever you draw next.

### Building it

Filament ships as a prebuilt SDK per platform — building it from source
requires clang/ninja and takes a long time, so this target expects you've
already downloaded a release from
https://github.com/google/filament/releases (the `filament-vX.Y.Z-<os>.tgz`
matching your platform) and unpacked it somewhere:

```bash
cmake .. -DKINE_WITH_FILAMENT=ON -DFILAMENT_DIR=/path/to/filament-sdk
cmake --build . --parallel --config Debug
```

This produces `kine_filament_shim.dll`/`.so`/`.dylib` in `build/bin/`
alongside `kine_render_shim`. Load both from Luau the same way.

### Using it from Luau

See `examples/luau/filament_example.lua` for a full loop (init, resize
handling, per-frame render, shutdown) using the real API. There's also
`examples/standalone_c/main.c` -- a plain C/raylib program with no Luau
involved at all, useful for confirming the shim itself works (context
sharing + texture import) before you wire up FFI on top of it:

```bash
cmake .. -DKINE_WITH_FILAMENT=ON -DKINE_BUILD_FILAMENT_EXAMPLE=ON \
          -DFILAMENT_DIR=/path/to/filament-sdk
cmake --build . --parallel --config Debug
./build/bin/kine_filament_example
```

Quick reference, same shape either language:

```lua
local width, height = 800, 600
local target = rl.LoadRenderTexture(width, height)

local fctx = filament.Kine_Filament_Create(target.texture.id, width, height)
assert(fctx ~= nil, "Filament init failed -- check you called this after InitWindow()")

filament.Kine_Filament_SetCameraLookAt(fctx, 0, 2, 6,  0, 0, 0,  0, 1, 0)
filament.Kine_Filament_SetCameraPerspective(fctx, 60.0, width / height, 0.1, 1000.0)

-- main loop:
filament.Kine_Filament_RenderFrame(fctx)
-- ... raylib draws target as a texture here (DrawTextureRec etc.) ...

-- on shutdown:
filament.Kine_Filament_Destroy(fctx)
```

### What's deliberately left out

This is a minimal bridge, not a full engine wrapper. There's no entity,
material, light, or glTF loading yet — `Kine_Filament_GetEngine` /
`GetScene` / `GetView` / `GetCamera` hand back opaque handles so you can
extend `kine_filament_shim.h`/`.cpp` with those next, following the same
pattern as `Kine_Filament_SetCameraLookAt`. Likely next additions:
a directional/IBL light helper, an entity-creation call, and (the big one)
`gltfio` asset loading — each of those pulls in more prebuilt Filament
libs (`ibl`, `gltfio`, `dracodec`, etc.), so budget CMake time accordingly.
