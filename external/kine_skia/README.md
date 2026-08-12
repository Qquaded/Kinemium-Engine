# kine_skia

`kine_skia` is a C ABI wrapper around Skia's CPU raster surface API.
Internally it is implemented in C++, but exported functions only use plain C
types so it can be loaded through FFI.

## Build

From the aggregate native build:

```sh
cmake -S external -B external/build
cmake --build external/build --target kine_skia
```

If `KINE_SKIA_DIR` is not set, CMake downloads Skia from
`https://skia.googlesource.com/skia.git`, runs Skia's dependency sync, generates
a lean GN build, and builds the `skia` static library before linking
`kine_skia`.

Useful overrides:

```sh
cmake -S external -B external/build -DKINE_SKIA_GIT_TAG=<commit-or-tag>
cmake -S external -B external/build -DKINE_SKIA_DIR=/path/to/skia
cmake -S external -B external/build -DKINE_SKIA_LIBRARY=/path/to/libskia.a
```

## API

The wrapper exposes opaque `KineSkiaSurface*` handles, raw pixel access, and a
small set of primitive drawing calls:

- `Kine_Skia_Surface_Create`
- `Kine_Skia_Surface_GetPixels`
- `Kine_Skia_Surface_Clear`
- `Kine_Skia_Surface_DrawRect`
- `Kine_Skia_Surface_DrawRoundRect`
- `Kine_Skia_Surface_DrawCircle`
- `Kine_Skia_Surface_DrawLine`
