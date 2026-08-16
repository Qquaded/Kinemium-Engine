#ifndef KINE_IMGUI_H
#define KINE_IMGUI_H

#include <SDL3/SDL.h>

#ifdef _WIN32
    #ifdef KINE_IMGUI_BUILD_EXPORTS
        #define KINE_IMGUI_API __declspec(dllexport)
    #else
        #define KINE_IMGUI_API __declspec(dllimport)
    #endif
#else
    #define KINE_IMGUI_API
#endif

#ifdef __cplusplus
extern "C" {
#endif
typedef struct KineImGuiContext KineImGuiContext;

typedef void* KineImFont;

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

KINE_IMGUI_API KineImGuiContext* Kine_ImGui_Create(SDL_Window* window, SDL_Renderer* renderer, int width, int height);
KINE_IMGUI_API void Kine_ImGui_Destroy(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_Resize(KineImGuiContext* ctx, int width, int height);
KINE_IMGUI_API int  Kine_ImGui_ProcessEvent(KineImGuiContext* ctx, SDL_Event* event);

KINE_IMGUI_API void Kine_ImGui_NewFrame(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_Render(KineImGuiContext* ctx, float deltaTime);

KINE_IMGUI_API int Kine_ImGui_WantCaptureMouse(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_WantCaptureKeyboard(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_WantTextInput(KineImGuiContext* ctx);

KINE_IMGUI_API void* Kine_ImGui_GetContext(KineImGuiContext* ctx);

KINE_IMGUI_API int Kine_ImGui_GetWidth(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_GetHeight(KineImGuiContext* ctx);

// ---------------------------------------------------------------------------
// Demo / style
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_ShowDemoWindow(KineImGuiContext* ctx, int* p_open);
KINE_IMGUI_API void Kine_ImGui_ShowMetricsWindow(KineImGuiContext* ctx, int* p_open);

KINE_IMGUI_API void Kine_ImGui_StyleDark(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_StyleLight(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_StyleClassic(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_SetGlobalScale(KineImGuiContext* ctx, float scale);

// ---------------------------------------------------------------------------
// Windows
// ---------------------------------------------------------------------------

// name behaves like Begin("name##id") when unique_id is non-null, letting
// callers reuse a display title across multiple windows.
KINE_IMGUI_API void Kine_ImGui_Begin(KineImGuiContext* ctx, const char* name, int* p_open);
KINE_IMGUI_API int  Kine_ImGui_BeginEx(KineImGuiContext* ctx, const char* name, int* p_open, int flags);
KINE_IMGUI_API void Kine_ImGui_End(KineImGuiContext* ctx);

KINE_IMGUI_API int  Kine_ImGui_BeginChild(KineImGuiContext* ctx, const char* str_id, float width, float height, int border);
KINE_IMGUI_API void Kine_ImGui_EndChild(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_SetNextWindowPos(KineImGuiContext* ctx, float x, float y);
KINE_IMGUI_API void Kine_ImGui_SetWindowSize(KineImGuiContext* ctx, float width, float height);
KINE_IMGUI_API void Kine_ImGui_SetNextWindowSizeConstraints(KineImGuiContext* ctx, float min_w, float min_h, float max_w, float max_h);
KINE_IMGUI_API void Kine_ImGui_SetNextWindowBgAlpha(KineImGuiContext* ctx, float alpha);
KINE_IMGUI_API void Kine_ImGui_SetNextWindowCollapsed(KineImGuiContext* ctx, int collapsed);

// ---------------------------------------------------------------------------
// Basic widgets
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_Text(KineImGuiContext* ctx, const char* text);
KINE_IMGUI_API void Kine_ImGui_TextColored(KineImGuiContext* ctx, const char* text, float r, float g, float b, float a);
KINE_IMGUI_API void Kine_ImGui_TextDisabled(KineImGuiContext* ctx, const char* text);
KINE_IMGUI_API void Kine_ImGui_TextWrapped(KineImGuiContext* ctx, const char* text);
KINE_IMGUI_API void Kine_ImGui_BulletText(KineImGuiContext* ctx, const char* text);
KINE_IMGUI_API void Kine_ImGui_LabelText(KineImGuiContext* ctx, const char* label, const char* text);

KINE_IMGUI_API int Kine_ImGui_Button(KineImGuiContext* ctx, const char* label);
KINE_IMGUI_API int Kine_ImGui_ButtonSized(KineImGuiContext* ctx, const char* label, float width, float height);
KINE_IMGUI_API int Kine_ImGui_SmallButton(KineImGuiContext* ctx, const char* label);
KINE_IMGUI_API int Kine_ImGui_InvisibleButton(KineImGuiContext* ctx, const char* str_id, float width, float height);
KINE_IMGUI_API int Kine_ImGui_ArrowButton(KineImGuiContext* ctx, const char* str_id, int dir); // 0=left,1=right,2=up,3=down

KINE_IMGUI_API int Kine_ImGui_Checkbox(KineImGuiContext* ctx, const char* label, int* v);
KINE_IMGUI_API int Kine_ImGui_RadioButton(KineImGuiContext* ctx, const char* label, int active);
KINE_IMGUI_API int Kine_ImGui_RadioButtonInt(KineImGuiContext* ctx, const char* label, int* v, int v_button);

// ---------------------------------------------------------------------------
// Sliders / drags / inputs (numeric)
// ---------------------------------------------------------------------------

KINE_IMGUI_API int Kine_ImGui_SliderFloat(KineImGuiContext* ctx, const char* label, float* v, float v_min, float v_max);
KINE_IMGUI_API int Kine_ImGui_SliderFloat2(KineImGuiContext* ctx, const char* label, float* v /*[2]*/, float v_min, float v_max);
KINE_IMGUI_API int Kine_ImGui_SliderFloat3(KineImGuiContext* ctx, const char* label, float* v /*[3]*/, float v_min, float v_max);
KINE_IMGUI_API int Kine_ImGui_SliderInt(KineImGuiContext* ctx, const char* label, int* v, int v_min, int v_max);
KINE_IMGUI_API int Kine_ImGui_SliderAngle(KineImGuiContext* ctx, const char* label, float* rad, float deg_min, float deg_max);

KINE_IMGUI_API int Kine_ImGui_DragFloat(KineImGuiContext* ctx, const char* label, float* v, float speed, float v_min, float v_max);
KINE_IMGUI_API int Kine_ImGui_DragInt(KineImGuiContext* ctx, const char* label, int* v, float speed, int v_min, int v_max);

KINE_IMGUI_API int Kine_ImGui_InputFloat(KineImGuiContext* ctx, const char* label, float* v, float step);
KINE_IMGUI_API int Kine_ImGui_InputInt(KineImGuiContext* ctx, const char* label, int* v, int step);

// ---------------------------------------------------------------------------
// Text input
// ---------------------------------------------------------------------------

// buf must be a caller-owned, zero-terminated buffer of buf_size bytes.
// Returns 1 if the contents changed this frame.
KINE_IMGUI_API int Kine_ImGui_InputText(KineImGuiContext* ctx, const char* label, char* buf, int buf_size);
KINE_IMGUI_API int Kine_ImGui_InputTextMultiline(KineImGuiContext* ctx, const char* label, char* buf, int buf_size, float width, float height);
KINE_IMGUI_API int Kine_ImGui_InputTextWithHint(KineImGuiContext* ctx, const char* label, const char* hint, char* buf, int buf_size);
KINE_IMGUI_API int Kine_ImGui_InputTextPassword(KineImGuiContext* ctx, const char* label, char* buf, int buf_size);

// ---------------------------------------------------------------------------
// Choice widgets
// ---------------------------------------------------------------------------

// items_separated_by_zeros: "Item1\0Item2\0Item3\0\0" (double NUL terminated).
KINE_IMGUI_API int Kine_ImGui_Combo(KineImGuiContext* ctx, const char* label, int* current_item, const char* items_separated_by_zeros);
KINE_IMGUI_API int Kine_ImGui_ListBox(KineImGuiContext* ctx, const char* label, int* current_item, const char* items_separated_by_zeros, int height_in_items);

// ---------------------------------------------------------------------------
// Color
// ---------------------------------------------------------------------------

KINE_IMGUI_API int Kine_ImGui_ColorEdit3(KineImGuiContext* ctx, const char* label, float* col /*[3]*/);
KINE_IMGUI_API int Kine_ImGui_ColorEdit4(KineImGuiContext* ctx, const char* label, float* col /*[4]*/);
KINE_IMGUI_API int Kine_ImGui_ColorPicker3(KineImGuiContext* ctx, const char* label, float* col /*[3]*/);

// ---------------------------------------------------------------------------
// Layout / grouping
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_SameLine(KineImGuiContext* ctx, float offset_from_start_x, float spacing);
KINE_IMGUI_API void Kine_ImGui_Spacing(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_NewLine(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_Separator(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_SeparatorText(KineImGuiContext* ctx, const char* label);
KINE_IMGUI_API void Kine_ImGui_Indent(KineImGuiContext* ctx, float width);
KINE_IMGUI_API void Kine_ImGui_Unindent(KineImGuiContext* ctx, float width);
KINE_IMGUI_API void Kine_ImGui_Dummy(KineImGuiContext* ctx, float width, float height);

KINE_IMGUI_API void Kine_ImGui_BeginGroup(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_EndGroup(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_PushItemWidth(KineImGuiContext* ctx, float width);
KINE_IMGUI_API void Kine_ImGui_PopItemWidth(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_BeginDisabled(KineImGuiContext* ctx, int disabled);
KINE_IMGUI_API void Kine_ImGui_EndDisabled(KineImGuiContext* ctx);

KINE_IMGUI_API int  Kine_ImGui_BeginColumns(KineImGuiContext* ctx, const char* str_id, int count);
KINE_IMGUI_API void Kine_ImGui_NextColumn(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_EndColumns(KineImGuiContext* ctx);

// ---------------------------------------------------------------------------
// Trees / collapsing headers
// ---------------------------------------------------------------------------

KINE_IMGUI_API int  Kine_ImGui_TreeNode(KineImGuiContext* ctx, const char* label);
KINE_IMGUI_API void Kine_ImGui_TreePop(KineImGuiContext* ctx);
KINE_IMGUI_API int  Kine_ImGui_CollapsingHeader(KineImGuiContext* ctx, const char* label);

// ---------------------------------------------------------------------------
// Progress / misc feedback
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_ProgressBar(KineImGuiContext* ctx, float fraction, float width, float height, const char* overlay);

// ---------------------------------------------------------------------------
// Tooltips / popups
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_SetTooltip(KineImGuiContext* ctx, const char* text);
KINE_IMGUI_API void Kine_ImGui_BeginTooltip(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_EndTooltip(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_OpenPopup(KineImGuiContext* ctx, const char* str_id);
KINE_IMGUI_API int  Kine_ImGui_BeginPopup(KineImGuiContext* ctx, const char* str_id);
KINE_IMGUI_API int  Kine_ImGui_BeginPopupModal(KineImGuiContext* ctx, const char* name, int* p_open);
KINE_IMGUI_API void Kine_ImGui_EndPopup(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_CloseCurrentPopup(KineImGuiContext* ctx);

// ---------------------------------------------------------------------------
// Menus
// ---------------------------------------------------------------------------

KINE_IMGUI_API int  Kine_ImGui_BeginMainMenuBar(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_EndMainMenuBar(KineImGuiContext* ctx);
KINE_IMGUI_API int  Kine_ImGui_BeginMenuBar(KineImGuiContext* ctx);
KINE_IMGUI_API void Kine_ImGui_EndMenuBar(KineImGuiContext* ctx);
KINE_IMGUI_API int  Kine_ImGui_BeginMenu(KineImGuiContext* ctx, const char* label, int enabled);
KINE_IMGUI_API void Kine_ImGui_EndMenu(KineImGuiContext* ctx);
KINE_IMGUI_API int  Kine_ImGui_MenuItem(KineImGuiContext* ctx, const char* label, const char* shortcut, int selected, int enabled);

// ---------------------------------------------------------------------------
// Item status queries
// ---------------------------------------------------------------------------

KINE_IMGUI_API int Kine_ImGui_IsItemHovered(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_IsItemActive(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_IsItemClicked(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_IsItemFocused(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_IsWindowFocused(KineImGuiContext* ctx);
KINE_IMGUI_API int Kine_ImGui_IsWindowHovered(KineImGuiContext* ctx);

KINE_IMGUI_API void Kine_ImGui_GetItemRectMin(KineImGuiContext* ctx, float* out_x, float* out_y);
KINE_IMGUI_API void Kine_ImGui_GetItemRectMax(KineImGuiContext* ctx, float* out_x, float* out_y);

// ---------------------------------------------------------------------------
// Plotting
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_PlotLines(KineImGuiContext* ctx, const char* label, const float* values, int values_count,
                         float scale_min, float scale_max, float width, float height);
KINE_IMGUI_API void Kine_ImGui_PlotHistogram(KineImGuiContext* ctx, const char* label, const float* values, int values_count,
                         float scale_min, float scale_max, float width, float height);

// ---------------------------------------------------------------------------
// Images (SDL_Texture* used directly as ImGui's ImTextureID via the
// SDL_Renderer backend)
// ---------------------------------------------------------------------------

KINE_IMGUI_API void Kine_ImGui_Image(KineImGuiContext* ctx, SDL_Texture* texture, float width, float height);
KINE_IMGUI_API void Kine_ImGui_ImageTinted(KineImGuiContext* ctx, SDL_Texture* texture, float width, float height,
                           float r, float g, float b, float a);
KINE_IMGUI_API int  Kine_ImGui_ImageButton(KineImGuiContext* ctx, const char* str_id, SDL_Texture* texture, float width, float height);

// Convenience: draws the image sized to the texture's native pixel dimensions.
KINE_IMGUI_API void Kine_ImGui_ImageNativeSize(KineImGuiContext* ctx, SDL_Texture* texture);

// ---------------------------------------------------------------------------
// Fonts
// ---------------------------------------------------------------------------

// Returns 1 on success (legacy behavior kept for compatibility).
KINE_IMGUI_API int Kine_ImGui_LoadFont(KineImGuiContext* ctx, const char* path, float size);

// Returns an opaque font handle (nullptr on failure) usable with PushFont/PopFont.
KINE_IMGUI_API KineImFont Kine_ImGui_LoadFontHandle(KineImGuiContext* ctx, const char* path, float size);
KINE_IMGUI_API void Kine_ImGui_PushFont(KineImGuiContext* ctx, KineImFont font);
KINE_IMGUI_API void Kine_ImGui_PopFont(KineImGuiContext* ctx);
// Must be called after loading fonts and before the next NewFrame; rebuilds
// the font atlas texture used by the SDL_Renderer backend.
KINE_IMGUI_API void Kine_ImGui_BuildFontAtlas(KineImGuiContext* ctx);

#ifdef __cplusplus
}
#endif

#endif // KINE_IMGUI_H