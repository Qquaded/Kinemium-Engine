#include "kine_render_shim.h"

#include <SDL3/SDL.h>

const char* Kine_GetVersion(void)
{
    return "kine_render_shim 0.1.0 (SDL3)";
}

int Kine_GetSDLBuildVersion(void)
{
    return SDL_VERSIONNUM(SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
}
