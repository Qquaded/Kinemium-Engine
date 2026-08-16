// kine_imgui.cpp
// Dear ImGui -> SDL3 platform backend -> SDL_Renderer backend.
//
// The engine already composites its frame with SDL_Renderer, so this wrapper
// lets ImGui draw into that same renderer just before SDL_RenderPresent.

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlrenderer3.h"

#include <SDL3/SDL.h>

#include "kine_imgui.h"

#include <cstdio>
#include <cstring>
#include <vector>

struct KineImGuiContext
{
    ImGuiContext* ig = nullptr;
    SDL_Window* window = nullptr;       // borrowed
    SDL_Renderer* renderer = nullptr;   // borrowed
    int width = 0;
    int height = 0;
    float deltaTime = 1.0f / 60.0f;
    bool sdlBackendInitialized = false;
    bool rendererBackendInitialized = false;
};

static void kine_imgui_set_display_size(KineImGuiContext* ctx)
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2((float)ctx->width, (float)ctx->height);
    io.DisplayFramebufferScale = ImVec2(1.0f, 1.0f);
}

// Small helper: ImGui's InputText callback resize support isn't needed here
// since callers own fixed-size buffers; std flags keep behavior simple.
static ImGuiInputTextFlags kine_default_input_text_flags()
{
    return ImGuiInputTextFlags_None;
}

extern "C" {

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

KineImGuiContext* Kine_ImGui_Create(SDL_Window* window, SDL_Renderer* renderer, int width, int height)
{
    if (!window || !renderer || width <= 0 || height <= 0) {
        return nullptr;
    }

    auto* ctx = new KineImGuiContext();
    ctx->window = window;
    ctx->renderer = renderer;
    ctx->width = width;
    ctx->height = height;

    IMGUI_CHECKVERSION();
    ctx->ig = ImGui::CreateContext();
    if (!ctx->ig) {
        delete ctx;
        return nullptr;
    }

    ImGui::SetCurrentContext(ctx->ig);

    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    io.IniFilename = nullptr;
    kine_imgui_set_display_size(ctx);

    ImGui::StyleColorsDark();

    if (!ImGui_ImplSDL3_InitForSDLRenderer(window, renderer)) {
        fprintf(stderr, "kine_imgui: ImGui_ImplSDL3_InitForSDLRenderer failed: %s\n", SDL_GetError());
        Kine_ImGui_Destroy(ctx);
        return nullptr;
    }
    ctx->sdlBackendInitialized = true;

    if (!ImGui_ImplSDLRenderer3_Init(renderer)) {
        fprintf(stderr, "kine_imgui: ImGui_ImplSDLRenderer3_Init failed: %s\n", SDL_GetError());
        Kine_ImGui_Destroy(ctx);
        return nullptr;
    }
    ctx->rendererBackendInitialized = true;

    return ctx;
}

void Kine_ImGui_Destroy(KineImGuiContext* ctx)
{
    if (!ctx) return;

    if (ctx->ig) {
        ImGui::SetCurrentContext(ctx->ig);

        if (ctx->rendererBackendInitialized) {
            ImGui_ImplSDLRenderer3_Shutdown();
            ctx->rendererBackendInitialized = false;
        }

        if (ctx->sdlBackendInitialized) {
            ImGui_ImplSDL3_Shutdown();
            ctx->sdlBackendInitialized = false;
        }

        ImGui::DestroyContext(ctx->ig);
        ctx->ig = nullptr;
    }

    delete ctx;
}

void Kine_ImGui_Resize(KineImGuiContext* ctx, int width, int height)
{
    if (!ctx || !ctx->ig || width <= 0 || height <= 0) return;
    ctx->width = width;
    ctx->height = height;

    ImGui::SetCurrentContext(ctx->ig);
    kine_imgui_set_display_size(ctx);
}

int Kine_ImGui_ProcessEvent(KineImGuiContext* ctx, SDL_Event* event)
{
    if (!ctx || !ctx->ig || !event || !ctx->sdlBackendInitialized) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui_ImplSDL3_ProcessEvent(event) ? 1 : 0;
}

void Kine_ImGui_NewFrame(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig || !ctx->sdlBackendInitialized || !ctx->rendererBackendInitialized) return;

    ImGui::SetCurrentContext(ctx->ig);
    ImGuiIO& io = ImGui::GetIO();
    io.DeltaTime = ctx->deltaTime > 0.0f ? ctx->deltaTime : (1.0f / 60.0f);
    kine_imgui_set_display_size(ctx);

    ImGui_ImplSDLRenderer3_NewFrame();
    ImGui_ImplSDL3_NewFrame();
    ImGui::NewFrame();
}

void Kine_ImGui_Render(KineImGuiContext* ctx, float deltaTime)
{
    if (!ctx || !ctx->ig || !ctx->rendererBackendInitialized) return;

    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Render();
    ImGui_ImplSDLRenderer3_RenderDrawData(ImGui::GetDrawData(), ctx->renderer);

    if (deltaTime > 0.0f) {
        ctx->deltaTime = deltaTime;
    }
}

int Kine_ImGui_WantCaptureMouse(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::GetIO().WantCaptureMouse ? 1 : 0;
}

int Kine_ImGui_WantCaptureKeyboard(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::GetIO().WantCaptureKeyboard ? 1 : 0;
}

int Kine_ImGui_WantTextInput(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::GetIO().WantTextInput ? 1 : 0;
}

void* Kine_ImGui_GetContext(KineImGuiContext* ctx)
{
    return ctx ? (void*)ctx->ig : nullptr;
}

int Kine_ImGui_GetWidth(KineImGuiContext* ctx)
{
    return ctx ? ctx->width : 0;
}

int Kine_ImGui_GetHeight(KineImGuiContext* ctx)
{
    return ctx ? ctx->height : 0;
}

// ---------------------------------------------------------------------------
// Demo / style
// ---------------------------------------------------------------------------

void Kine_ImGui_ShowDemoWindow(KineImGuiContext* ctx, int* p_open)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::ShowDemoWindow(reinterpret_cast<bool*>(p_open));
}

void Kine_ImGui_ShowMetricsWindow(KineImGuiContext* ctx, int* p_open)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::ShowMetricsWindow(reinterpret_cast<bool*>(p_open));
}

void Kine_ImGui_StyleDark(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
  	ImGuiStyle& style = ImGui::GetStyle();

	style.Alpha = 1.0f;
	style.DisabledAlpha = 0.6f;
	style.WindowPadding = ImVec2(8.0f, 8.0f);
	style.WindowRounding = 7.0f;
	style.WindowBorderSize = 1.0f;
	style.WindowMinSize = ImVec2(32.0f, 32.0f);
	style.WindowTitleAlign = ImVec2(0.0f, 0.5f);
	style.WindowMenuButtonPosition = ImGuiDir_Left;
	style.ChildRounding = 4.0f;
	style.ChildBorderSize = 1.0f;
	style.PopupRounding = 4.0f;
	style.PopupBorderSize = 1.0f;
	style.FramePadding = ImVec2(5.0f, 2.0f);
	style.FrameRounding = 3.0f;
	style.FrameBorderSize = 1.0f;
	style.ItemSpacing = ImVec2(6.0f, 6.0f);
	style.ItemInnerSpacing = ImVec2(6.0f, 6.0f);
	style.CellPadding = ImVec2(6.0f, 6.0f);
	style.IndentSpacing = 25.0f;
	style.ColumnsMinSpacing = 6.0f;
	style.ScrollbarSize = 15.0f;
	style.ScrollbarRounding = 9.0f;
	style.GrabMinSize = 10.0f;
	style.GrabRounding = 3.0f;
	style.TabRounding = 4.0f;
	style.TabBorderSize = 1.0f;
	style.ColorButtonPosition = ImGuiDir_Right;
	style.ButtonTextAlign = ImVec2(0.5f, 0.5f);
	style.SelectableTextAlign = ImVec2(0.0f, 0.0f);

	style.Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
	style.Colors[ImGuiCol_TextDisabled] = ImVec4(0.49803922f, 0.49803922f, 0.49803922f, 1.0f);
	style.Colors[ImGuiCol_WindowBg] = ImVec4(0.09803922f, 0.09803922f, 0.09803922f, 1.0f);
	style.Colors[ImGuiCol_ChildBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.0f);
	style.Colors[ImGuiCol_PopupBg] = ImVec4(0.1882353f, 0.1882353f, 0.1882353f, 0.92f);
	style.Colors[ImGuiCol_Border] = ImVec4(0.1882353f, 0.1882353f, 0.1882353f, 0.29f);
	style.Colors[ImGuiCol_BorderShadow] = ImVec4(0.0f, 0.0f, 0.0f, 0.24f);
	style.Colors[ImGuiCol_FrameBg] = ImVec4(0.047058824f, 0.047058824f, 0.047058824f, 0.54f);
	style.Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.1882353f, 0.1882353f, 0.1882353f, 0.54f);
	style.Colors[ImGuiCol_FrameBgActive] = ImVec4(0.2f, 0.21960784f, 0.22745098f, 1.0f);
	style.Colors[ImGuiCol_TitleBg] = ImVec4(0.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_TitleBgActive] = ImVec4(0.05882353f, 0.05882353f, 0.05882353f, 1.0f);
	style.Colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_MenuBarBg] = ImVec4(0.13725491f, 0.13725491f, 0.13725491f, 1.0f);
	style.Colors[ImGuiCol_ScrollbarBg] = ImVec4(0.047058824f, 0.047058824f, 0.047058824f, 0.54f);
	style.Colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.3372549f, 0.3372549f, 0.3372549f, 0.54f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.4f, 0.4f, 0.4f, 0.54f);
	style.Colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.5568628f, 0.5568628f, 0.5568628f, 0.54f);
	style.Colors[ImGuiCol_CheckMark] = ImVec4(0.32941177f, 0.6666667f, 0.85882354f, 1.0f);
	style.Colors[ImGuiCol_SliderGrab] = ImVec4(0.3372549f, 0.3372549f, 0.3372549f, 0.54f);
	style.Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.5568628f, 0.5568628f, 0.5568628f, 0.54f);
	style.Colors[ImGuiCol_Button] = ImVec4(0.047058824f, 0.047058824f, 0.047058824f, 0.54f);
	style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.1882353f, 0.1882353f, 0.1882353f, 0.54f);
	style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.2f, 0.21960784f, 0.22745098f, 1.0f);
	style.Colors[ImGuiCol_Header] = ImVec4(0.0f, 0.0f, 0.0f, 0.52f);
	style.Colors[ImGuiCol_HeaderHovered] = ImVec4(0.0f, 0.0f, 0.0f, 0.36f);
	style.Colors[ImGuiCol_HeaderActive] = ImVec4(0.2f, 0.21960784f, 0.22745098f, 0.33f);
	style.Colors[ImGuiCol_Separator] = ImVec4(0.2784314f, 0.2784314f, 0.2784314f, 0.29f);
	style.Colors[ImGuiCol_SeparatorHovered] = ImVec4(0.4392157f, 0.4392157f, 0.4392157f, 0.29f);
	style.Colors[ImGuiCol_SeparatorActive] = ImVec4(0.4f, 0.4392157f, 0.46666667f, 1.0f);
	style.Colors[ImGuiCol_ResizeGrip] = ImVec4(0.2784314f, 0.2784314f, 0.2784314f, 0.29f);
	style.Colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.4392157f, 0.4392157f, 0.4392157f, 0.29f);
	style.Colors[ImGuiCol_ResizeGripActive] = ImVec4(0.4f, 0.4392157f, 0.46666667f, 1.0f);
	style.Colors[ImGuiCol_Tab] = ImVec4(0.0f, 0.0f, 0.0f, 0.52f);
	style.Colors[ImGuiCol_TabHovered] = ImVec4(0.13725491f, 0.13725491f, 0.13725491f, 1.0f);
	style.Colors[ImGuiCol_TabActive] = ImVec4(0.2f, 0.2f, 0.2f, 0.36f);
	style.Colors[ImGuiCol_TabUnfocused] = ImVec4(0.0f, 0.0f, 0.0f, 0.52f);
	style.Colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.13725491f, 0.13725491f, 0.13725491f, 1.0f);
	style.Colors[ImGuiCol_PlotLines] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_PlotLinesHovered] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_PlotHistogram] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_PlotHistogramHovered] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_TableHeaderBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.52f);
	style.Colors[ImGuiCol_TableBorderStrong] = ImVec4(0.0f, 0.0f, 0.0f, 0.52f);
	style.Colors[ImGuiCol_TableBorderLight] = ImVec4(0.2784314f, 0.2784314f, 0.2784314f, 0.29f);
	style.Colors[ImGuiCol_TableRowBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.0f);
	style.Colors[ImGuiCol_TableRowBgAlt] = ImVec4(1.0f, 1.0f, 1.0f, 0.06f);
	style.Colors[ImGuiCol_TextSelectedBg] = ImVec4(0.2f, 0.21960784f, 0.22745098f, 1.0f);
	style.Colors[ImGuiCol_DragDropTarget] = ImVec4(0.32941177f, 0.6666667f, 0.85882354f, 1.0f);
	style.Colors[ImGuiCol_NavHighlight] = ImVec4(1.0f, 0.0f, 0.0f, 1.0f);
	style.Colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.0f, 0.0f, 0.0f, 0.7f);
	style.Colors[ImGuiCol_NavWindowingDimBg] = ImVec4(1.0f, 0.0f, 0.0f, 0.2f);
	style.Colors[ImGuiCol_ModalWindowDimBg] = ImVec4(1.0f, 0.0f, 0.0f, 0.35f);
}

void Kine_ImGui_StyleLight(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::StyleColorsLight();
}

void Kine_ImGui_StyleClassic(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::StyleColorsClassic();
}

void Kine_ImGui_SetGlobalScale(KineImGuiContext* ctx, float scale)
{
    if (!ctx || !ctx->ig || scale <= 0.0f) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::GetStyle().ScaleAllSizes(scale);
    ImGui::GetIO().FontGlobalScale = scale;
}

// ---------------------------------------------------------------------------
// Windows
// ---------------------------------------------------------------------------

void Kine_ImGui_Begin(KineImGuiContext* ctx, const char* name, int* p_open)
{
    if (!ctx || !ctx->ig || !name) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Begin(name, reinterpret_cast<bool*>(p_open));
}

int Kine_ImGui_BeginEx(KineImGuiContext* ctx, const char* name, int* p_open, int flags)
{
    if (!ctx || !ctx->ig || !name) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::Begin(name, reinterpret_cast<bool*>(p_open), (ImGuiWindowFlags)flags) ? 1 : 0;
}

void Kine_ImGui_End(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::End();
}

int Kine_ImGui_BeginChild(KineImGuiContext* ctx, const char* str_id, float width, float height, int border)
{
    if (!ctx || !ctx->ig || !str_id) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginChild(str_id, ImVec2(width, height), border != 0) ? 1 : 0;
}

void Kine_ImGui_EndChild(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndChild();
}

void Kine_ImGui_SetNextWindowPos(KineImGuiContext* ctx, float x, float y)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetNextWindowPos(ImVec2(x, y));
}

void Kine_ImGui_SetWindowSize(KineImGuiContext* ctx, float width, float height)
{
    if (!ctx || !ctx->ig || width <= 0.0f || height <= 0.0f)
        return;

    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetNextWindowSize(ImVec2(width, height));
}

void Kine_ImGui_SetNextWindowSizeConstraints(KineImGuiContext* ctx, float min_w, float min_h, float max_w, float max_h)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetNextWindowSizeConstraints(ImVec2(min_w, min_h), ImVec2(max_w, max_h));
}

void Kine_ImGui_SetNextWindowBgAlpha(KineImGuiContext* ctx, float alpha)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetNextWindowBgAlpha(alpha);
}

void Kine_ImGui_SetNextWindowCollapsed(KineImGuiContext* ctx, int collapsed)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetNextWindowCollapsed(collapsed != 0);
}

// ---------------------------------------------------------------------------
// Basic widgets
// ---------------------------------------------------------------------------

void Kine_ImGui_Text(KineImGuiContext* ctx, const char* text)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::TextUnformatted(text);
}

void Kine_ImGui_TextColored(KineImGuiContext* ctx, const char* text, float r, float g, float b, float a)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::TextColored(ImVec4(r, g, b, a), "%s", text);
}

void Kine_ImGui_TextDisabled(KineImGuiContext* ctx, const char* text)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::TextDisabled("%s", text);
}

void Kine_ImGui_TextWrapped(KineImGuiContext* ctx, const char* text)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::TextWrapped("%s", text);
}

void Kine_ImGui_BulletText(KineImGuiContext* ctx, const char* text)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::BulletText("%s", text);
}

void Kine_ImGui_LabelText(KineImGuiContext* ctx, const char* label, const char* text)
{
    if (!ctx || !ctx->ig || !label || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::LabelText(label, "%s", text);
}

int Kine_ImGui_Button(KineImGuiContext* ctx, const char* label)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::Button(label) ? 1 : 0;
}

int Kine_ImGui_ButtonSized(KineImGuiContext* ctx, const char* label, float width, float height)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::Button(label, ImVec2(width, height)) ? 1 : 0;
}

int Kine_ImGui_SmallButton(KineImGuiContext* ctx, const char* label)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SmallButton(label) ? 1 : 0;
}

int Kine_ImGui_InvisibleButton(KineImGuiContext* ctx, const char* str_id, float width, float height)
{
    if (!ctx || !ctx->ig || !str_id) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InvisibleButton(str_id, ImVec2(width, height)) ? 1 : 0;
}

int Kine_ImGui_ArrowButton(KineImGuiContext* ctx, const char* str_id, int dir)
{
    if (!ctx || !ctx->ig || !str_id) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    ImGuiDir d = ImGuiDir_Left;
    switch (dir) {
        case 0: d = ImGuiDir_Left; break;
        case 1: d = ImGuiDir_Right; break;
        case 2: d = ImGuiDir_Up; break;
        case 3: d = ImGuiDir_Down; break;
        default: break;
    }
    return ImGui::ArrowButton(str_id, d) ? 1 : 0;
}

int Kine_ImGui_Checkbox(KineImGuiContext* ctx, const char* label, int* v)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);

    bool b = *v != 0;
    bool res = ImGui::Checkbox(label, &b);
    *v = b ? 1 : 0;
    return res ? 1 : 0;
}

int Kine_ImGui_RadioButton(KineImGuiContext* ctx, const char* label, int active)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::RadioButton(label, active != 0) ? 1 : 0;
}

int Kine_ImGui_RadioButtonInt(KineImGuiContext* ctx, const char* label, int* v, int v_button)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::RadioButton(label, v, v_button) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Sliders / drags / inputs (numeric)
// ---------------------------------------------------------------------------

int Kine_ImGui_SliderFloat(KineImGuiContext* ctx, const char* label, float* v, float v_min, float v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SliderFloat(label, v, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_SliderFloat2(KineImGuiContext* ctx, const char* label, float* v, float v_min, float v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SliderFloat2(label, v, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_SliderFloat3(KineImGuiContext* ctx, const char* label, float* v, float v_min, float v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SliderFloat3(label, v, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_SliderInt(KineImGuiContext* ctx, const char* label, int* v, int v_min, int v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SliderInt(label, v, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_SliderAngle(KineImGuiContext* ctx, const char* label, float* rad, float deg_min, float deg_max)
{
    if (!ctx || !ctx->ig || !label || !rad) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::SliderAngle(label, rad, deg_min, deg_max) ? 1 : 0;
}

int Kine_ImGui_DragFloat(KineImGuiContext* ctx, const char* label, float* v, float speed, float v_min, float v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::DragFloat(label, v, speed, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_DragInt(KineImGuiContext* ctx, const char* label, int* v, float speed, int v_min, int v_max)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::DragInt(label, v, speed, v_min, v_max) ? 1 : 0;
}

int Kine_ImGui_InputFloat(KineImGuiContext* ctx, const char* label, float* v, float step)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputFloat(label, v, step) ? 1 : 0;
}

int Kine_ImGui_InputInt(KineImGuiContext* ctx, const char* label, int* v, int step)
{
    if (!ctx || !ctx->ig || !label || !v) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputInt(label, v, step) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Text input
// ---------------------------------------------------------------------------

int Kine_ImGui_InputText(KineImGuiContext* ctx, const char* label, char* buf, int buf_size)
{
    if (!ctx || !ctx->ig || !label || !buf || buf_size <= 0) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputText(label, buf, (size_t)buf_size, kine_default_input_text_flags()) ? 1 : 0;
}

int Kine_ImGui_InputTextMultiline(KineImGuiContext* ctx, const char* label, char* buf, int buf_size, float width, float height)
{
    if (!ctx || !ctx->ig || !label || !buf || buf_size <= 0) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputTextMultiline(label, buf, (size_t)buf_size, ImVec2(width, height)) ? 1 : 0;
}

int Kine_ImGui_InputTextWithHint(KineImGuiContext* ctx, const char* label, const char* hint, char* buf, int buf_size)
{
    if (!ctx || !ctx->ig || !label || !hint || !buf || buf_size <= 0) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputTextWithHint(label, hint, buf, (size_t)buf_size) ? 1 : 0;
}

int Kine_ImGui_InputTextPassword(KineImGuiContext* ctx, const char* label, char* buf, int buf_size)
{
    if (!ctx || !ctx->ig || !label || !buf || buf_size <= 0) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::InputText(label, buf, (size_t)buf_size, ImGuiInputTextFlags_Password) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Choice widgets
// ---------------------------------------------------------------------------

int Kine_ImGui_Combo(KineImGuiContext* ctx, const char* label, int* current_item, const char* items_separated_by_zeros)
{
    if (!ctx || !ctx->ig || !label || !current_item || !items_separated_by_zeros) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::Combo(label, current_item, items_separated_by_zeros) ? 1 : 0;
}

int Kine_ImGui_ListBox(KineImGuiContext* ctx, const char* label, int* current_item, const char* items_separated_by_zeros, int height_in_items)
{
    if (!ctx || !ctx->ig || !label || !current_item || !items_separated_by_zeros) return 0;
    ImGui::SetCurrentContext(ctx->ig);

    // ImGui::ListBox wants a const char* const* items[] + count; unpack the
    // double-NUL separated buffer since that's the friendlier C ABI to bind.
    std::vector<const char*> items;
    const char* p = items_separated_by_zeros;
    while (*p) {
        items.push_back(p);
        p += std::strlen(p) + 1;
    }
    if (items.empty()) return 0;

    return ImGui::ListBox(label, current_item, items.data(), (int)items.size(), height_in_items) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Color
// ---------------------------------------------------------------------------

int Kine_ImGui_ColorEdit3(KineImGuiContext* ctx, const char* label, float* col)
{
    if (!ctx || !ctx->ig || !label || !col) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::ColorEdit3(label, col) ? 1 : 0;
}

int Kine_ImGui_ColorEdit4(KineImGuiContext* ctx, const char* label, float* col)
{
    if (!ctx || !ctx->ig || !label || !col) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::ColorEdit4(label, col) ? 1 : 0;
}

int Kine_ImGui_ColorPicker3(KineImGuiContext* ctx, const char* label, float* col)
{
    if (!ctx || !ctx->ig || !label || !col) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::ColorPicker3(label, col) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Layout / grouping
// ---------------------------------------------------------------------------

void Kine_ImGui_SameLine(KineImGuiContext* ctx, float offset_from_start_x, float spacing)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SameLine(offset_from_start_x, spacing);
}

void Kine_ImGui_Spacing(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Spacing();
}

void Kine_ImGui_NewLine(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::NewLine();
}

void Kine_ImGui_Separator(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Separator();
}

void Kine_ImGui_SeparatorText(KineImGuiContext* ctx, const char* label)
{
    if (!ctx || !ctx->ig || !label) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SeparatorText(label);
}

void Kine_ImGui_Indent(KineImGuiContext* ctx, float width)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Indent(width);
}

void Kine_ImGui_Unindent(KineImGuiContext* ctx, float width)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Unindent(width);
}

void Kine_ImGui_Dummy(KineImGuiContext* ctx, float width, float height)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Dummy(ImVec2(width, height));
}

void Kine_ImGui_BeginGroup(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::BeginGroup();
}

void Kine_ImGui_EndGroup(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndGroup();
}

void Kine_ImGui_PushItemWidth(KineImGuiContext* ctx, float width)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PushItemWidth(width);
}

void Kine_ImGui_PopItemWidth(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PopItemWidth();
}

void Kine_ImGui_BeginDisabled(KineImGuiContext* ctx, int disabled)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::BeginDisabled(disabled != 0);
}

void Kine_ImGui_EndDisabled(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndDisabled();
}

int Kine_ImGui_BeginColumns(KineImGuiContext* ctx, const char* str_id, int count)
{
    if (!ctx || !ctx->ig || !str_id || count <= 0) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Columns(count, str_id, true);
    return 1;
}

void Kine_ImGui_NextColumn(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::NextColumn();
}

void Kine_ImGui_EndColumns(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::Columns(1);
}

// ---------------------------------------------------------------------------
// Trees / collapsing headers
// ---------------------------------------------------------------------------

int Kine_ImGui_TreeNode(KineImGuiContext* ctx, const char* label)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::TreeNode(label) ? 1 : 0;
}

void Kine_ImGui_TreePop(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::TreePop();
}

int Kine_ImGui_CollapsingHeader(KineImGuiContext* ctx, const char* label)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::CollapsingHeader(label) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Progress / misc feedback
// ---------------------------------------------------------------------------

void Kine_ImGui_ProgressBar(KineImGuiContext* ctx, float fraction, float width, float height, const char* overlay)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::ProgressBar(fraction, ImVec2(width, height), overlay);
}

// ---------------------------------------------------------------------------
// Tooltips / popups
// ---------------------------------------------------------------------------

void Kine_ImGui_SetTooltip(KineImGuiContext* ctx, const char* text)
{
    if (!ctx || !ctx->ig || !text) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::SetTooltip("%s", text);
}

void Kine_ImGui_BeginTooltip(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::BeginTooltip();
}

void Kine_ImGui_EndTooltip(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndTooltip();
}

void Kine_ImGui_OpenPopup(KineImGuiContext* ctx, const char* str_id)
{
    if (!ctx || !ctx->ig || !str_id) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::OpenPopup(str_id);
}

int Kine_ImGui_BeginPopup(KineImGuiContext* ctx, const char* str_id)
{
    if (!ctx || !ctx->ig || !str_id) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginPopup(str_id) ? 1 : 0;
}

int Kine_ImGui_BeginPopupModal(KineImGuiContext* ctx, const char* name, int* p_open)
{
    if (!ctx || !ctx->ig || !name) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginPopupModal(name, reinterpret_cast<bool*>(p_open)) ? 1 : 0;
}

void Kine_ImGui_EndPopup(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndPopup();
}

void Kine_ImGui_CloseCurrentPopup(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::CloseCurrentPopup();
}

// ---------------------------------------------------------------------------
// Menus
// ---------------------------------------------------------------------------

int Kine_ImGui_BeginMainMenuBar(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginMainMenuBar() ? 1 : 0;
}

void Kine_ImGui_EndMainMenuBar(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndMainMenuBar();
}

int Kine_ImGui_BeginMenuBar(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginMenuBar() ? 1 : 0;
}

void Kine_ImGui_EndMenuBar(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndMenuBar();
}

int Kine_ImGui_BeginMenu(KineImGuiContext* ctx, const char* label, int enabled)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::BeginMenu(label, enabled != 0) ? 1 : 0;
}

void Kine_ImGui_EndMenu(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::EndMenu();
}

int Kine_ImGui_MenuItem(KineImGuiContext* ctx, const char* label, const char* shortcut, int selected, int enabled)
{
    if (!ctx || !ctx->ig || !label) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::MenuItem(label, shortcut, selected != 0, enabled != 0) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Item status queries
// ---------------------------------------------------------------------------

int Kine_ImGui_IsItemHovered(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsItemHovered() ? 1 : 0;
}

int Kine_ImGui_IsItemActive(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsItemActive() ? 1 : 0;
}

int Kine_ImGui_IsItemClicked(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsItemClicked() ? 1 : 0;
}

int Kine_ImGui_IsItemFocused(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsItemFocused() ? 1 : 0;
}

int Kine_ImGui_IsWindowFocused(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsWindowFocused() ? 1 : 0;
}

int Kine_ImGui_IsWindowHovered(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    return ImGui::IsWindowHovered() ? 1 : 0;
}

void Kine_ImGui_GetItemRectMin(KineImGuiContext* ctx, float* out_x, float* out_y)
{
    if (!ctx || !ctx->ig || !out_x || !out_y) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImVec2 v = ImGui::GetItemRectMin();
    *out_x = v.x;
    *out_y = v.y;
}

void Kine_ImGui_GetItemRectMax(KineImGuiContext* ctx, float* out_x, float* out_y)
{
    if (!ctx || !ctx->ig || !out_x || !out_y) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImVec2 v = ImGui::GetItemRectMax();
    *out_x = v.x;
    *out_y = v.y;
}

// ---------------------------------------------------------------------------
// Plotting
// ---------------------------------------------------------------------------

void Kine_ImGui_PlotLines(KineImGuiContext* ctx, const char* label, const float* values, int values_count,
                           float scale_min, float scale_max, float width, float height)
{
    if (!ctx || !ctx->ig || !label || !values || values_count <= 0) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PlotLines(label, values, values_count, 0, nullptr, scale_min, scale_max, ImVec2(width, height));
}

void Kine_ImGui_PlotHistogram(KineImGuiContext* ctx, const char* label, const float* values, int values_count,
                               float scale_min, float scale_max, float width, float height)
{
    if (!ctx || !ctx->ig || !label || !values || values_count <= 0) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PlotHistogram(label, values, values_count, 0, nullptr, scale_min, scale_max, ImVec2(width, height));
}

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

void Kine_ImGui_Image(KineImGuiContext* ctx, SDL_Texture* texture, float width, float height)
{
    if (!ctx || !ctx->ig || !texture) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImTextureID tex_id = (ImTextureID)(intptr_t)texture;
    ImGui::Image(tex_id, ImVec2(width, height));
}

void Kine_ImGui_ImageTinted(KineImGuiContext* ctx, SDL_Texture* texture, float width, float height,
                            float r, float g, float b, float a)
{
    if (!ctx || !ctx->ig || !texture) return;

    ImGui::SetCurrentContext(ctx->ig);

    ImTextureID tex_id = (ImTextureID)(intptr_t)texture;

    ImGui::Image(
        tex_id,
        ImVec2(width, height),
        ImVec2(0.0f, 0.0f),
        ImVec2(1.0f, 1.0f)
    );

    // Tint the image using the draw list.
    ImVec2 min = ImGui::GetItemRectMin();
    ImVec2 max = ImGui::GetItemRectMax();

    ImGui::GetWindowDrawList()->AddRectFilled(
        min,
        max,
        ImGui::ColorConvertFloat4ToU32(ImVec4(r, g, b, a))
    );
}

int Kine_ImGui_ImageButton(KineImGuiContext* ctx, const char* str_id, SDL_Texture* texture, float width, float height)
{
    if (!ctx || !ctx->ig || !str_id || !texture) return 0;
    ImGui::SetCurrentContext(ctx->ig);
    ImTextureID tex_id = (ImTextureID)(intptr_t)texture;
    return ImGui::ImageButton(str_id, tex_id, ImVec2(width, height)) ? 1 : 0;
}

void Kine_ImGui_ImageNativeSize(KineImGuiContext* ctx, SDL_Texture* texture)
{
    if (!ctx || !ctx->ig || !texture) return;
    ImGui::SetCurrentContext(ctx->ig);

    float w = 0.0f, h = 0.0f;
    SDL_GetTextureSize(texture, &w, &h);

    ImTextureID tex_id = (ImTextureID)(intptr_t)texture;
    ImGui::Image(tex_id, ImVec2(w, h));
}

// ---------------------------------------------------------------------------
// Fonts
// ---------------------------------------------------------------------------

int Kine_ImGui_LoadFont(KineImGuiContext* ctx, const char* path, float size)
{
    if (!ctx || !ctx->ig || !path || size <= 0.0f)
        return 0;

    ImGui::SetCurrentContext(ctx->ig);

    ImGuiIO& io = ImGui::GetIO();

    ImFont* font = io.Fonts->AddFontFromFileTTF(path, size);

    return font != nullptr ? 1 : 0;
}

KineImFont Kine_ImGui_LoadFontHandle(KineImGuiContext* ctx, const char* path, float size)
{
    if (!ctx || !ctx->ig || !path || size <= 0.0f)
        return nullptr;

    ImGui::SetCurrentContext(ctx->ig);
    ImGuiIO& io = ImGui::GetIO();
    ImFont* font = io.Fonts->AddFontFromFileTTF(path, size);
    return (KineImFont)font;
}

void Kine_ImGui_PushFont(KineImGuiContext* ctx, KineImFont font)
{
    if (!ctx || !ctx->ig || !font) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PushFont((ImFont*)font);
}

void Kine_ImGui_PopFont(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig) return;
    ImGui::SetCurrentContext(ctx->ig);
    ImGui::PopFont();
}

void Kine_ImGui_BuildFontAtlas(KineImGuiContext* ctx)
{
    if (!ctx || !ctx->ig || !ctx->rendererBackendInitialized) return;
    ImGui::SetCurrentContext(ctx->ig);

    // The SDL_Renderer3 backend owns the atlas texture; destroying and
    // recreating its device objects is the supported way to pick up newly
    // added fonts (see imgui_impl_sdlrenderer3.h).
    ImGui_ImplSDLRenderer3_DestroyDeviceObjects();
    ImGui_ImplSDLRenderer3_CreateDeviceObjects();
}

} // extern "C"