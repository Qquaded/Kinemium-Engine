--!strict
--!optimize 2
--!native

local raylib = require("./raylib")

local structs = raylib.structs

local ffi = zune.ffi

local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
local double = ffi.types.double
local long = ffi.types.i64
type int = number
type uint = number
type bool = number
type float = number
type long = buffer
type double = number
type FFIPointer = any
type cstring = string | buffer | FFIPointer

local Vector2 = structs.Vector2
local Vector3 = structs.Vector3
local Matrix = structs.Matrix
local Color = structs.Color
local Image = structs.Image
local Texture = structs.Texture
local RenderTexture2D = structs.RenderTexture2D
local Shader = structs.Shader
local Camera3D = structs.Camera3D
local Camera2D = structs.Camera2D
local Ray = structs.Ray
local VrStereoConfig = structs.VrStereoConfig
local VrDeviceInfo = structs.VrDeviceInfo
local FilePathList = structs.FilePathList
local AutomationEvent = structs.AutomationEvent
local AutomationEventList = structs.AutomationEventList
type Vector2 = raylib.Vector2
type Vector3 = raylib.Vector3
type Matrix = raylib.Matrix
type Color = raylib.Color
type Image = raylib.Image
type Texture = raylib.Texture
type RenderTexture2D = raylib.RenderTexture2D
type Shader = raylib.Shader
type Camera3D = raylib.Camera3D
type Camera2D = raylib.Camera2D
type Ray = raylib.Ray
type VrStereoConfig = raylib.VrStereoConfig
type VrDeviceInfo = raylib.VrDeviceInfo
type FilePathList = raylib.FilePathList
type AutomationEvent = raylib.AutomationEvent
type AutomationEventList = raylib.AutomationEventList

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	InitWindow: (width: int, height: int, title: cstring) -> (),
	CloseWindow: () -> (),
	WindowShouldClose: () -> bool,
	IsWindowReady: () -> bool,
	IsWindowFullscreen: () -> bool,
	IsWindowHidden: () -> bool,
	IsWindowMinimized: () -> bool,
	IsWindowMaximized: () -> bool,
	IsWindowFocused: () -> bool,
	IsWindowResized: () -> bool,
	IsWindowState: (flag: int) -> bool,
	SetWindowState: (flags: int) -> (),
	ClearWindowState: (flags: int) -> (),
	ToggleFullscreen: () -> (),
	ToggleBorderlessWindowed: () -> (),
	MaximizeWindow: () -> (),
	MinimizeWindow: () -> (),
	RestoreWindow: () -> (),
	SetWindowIcon: (image: Image) -> (),
	SetWindowIcons: (images: FFIPointer, count: int) -> (),
	SetWindowTitle: (title: cstring) -> (),
	SetWindowPosition: (x: int, y: int) -> (),
	SetWindowMonitor: (monitor: int) -> (),
	SetWindowMinSize: (width: int, height: int) -> (),
	SetWindowMaxSize: (width: int, height: int) -> (),
	SetWindowSize: (width: int, height: int) -> (),
	SetWindowOpacity: (opacity: float) -> (),
	SetWindowFocused: () -> (),
	GetWindowHandle: () -> FFIPointer,
	GetScreenWidth: () -> int,
	GetScreenHeight: () -> int,
	GetRenderWidth: () -> int,
	GetRenderHeight: () -> int,
	GetMonitorCount: () -> int,
	GetCurrentMonitor: () -> int,
	GetMonitorPosition: (monitor: int) -> Vector2,
	GetMonitorWidth: (monitor: int) -> int,
	GetMonitorHeight: (monitor: int) -> int,
	GetMonitorPhysicalWidth: (monitor: int) -> int,
	GetMonitorPhysicalHeight: (monitor: int) -> int,
	GetMonitorRefreshRate: (monitor: int) -> int,
	GetWindowPosition: () -> Vector2,
	GetWindowScaleDPI: () -> Vector2,
	GetMonitorName: (monitor: int) -> FFIPointer,
	SetClipboardText: (text: cstring) -> (),
	GetClipboardText: () -> FFIPointer,
	GetClipboardImage: () -> Image,
	EnableEventWaiting: () -> (),
	DisableEventWaiting: () -> (),
	ShowCursor: () -> (),
	HideCursor: () -> (),
	EnableCursor: () -> (),
	DisableCursor: () -> (),
	IsCursorHidden: () -> bool,
	IsCursorOnScreen: () -> bool,
	ClearBackground: (color: Color) -> (),
	BeginDrawing: () -> (),
	EndDrawing: () -> (),
	BeginMode2D: (camera: Camera2D) -> (),
	EndMode2D: () -> (),
	BeginMode3D: (camera: Camera3D) -> (),
	EndMode3D: () -> (),
	BeginTextureMode: (target: RenderTexture2D) -> (),
	EndTextureMode: () -> (),
	BeginShaderMode: (shader: Shader) -> (),
	EndShaderMode: () -> (),
	BeginBlendMode: (mode: int) -> (),
	EndBlendMode: () -> (),
	BeginScissorMode: (x: int, y: int, width: int, height: int) -> (),
	EndScissorMode: () -> (),
	BeginVrStereoMode: (config: VrStereoConfig) -> (),
	EndVrStereoMode: () -> (),
	LoadVrStereoConfig: (device: VrDeviceInfo) -> VrStereoConfig,
	UnloadVrStereoConfig: (config: VrStereoConfig) -> (),
	LoadShader: (vsFileName: cstring, fsFileName: cstring) -> Shader,
	LoadShaderFromMemory: (vsCode: cstring, fsCode: cstring) -> Shader,
	IsShaderValid: (shader: Shader) -> bool,
	GetShaderLocation: (shader: Shader, uniformName: cstring) -> int,
	GetShaderLocationAttrib: (shader: Shader, attribName: cstring) -> int,
	SetShaderValue: (shader: Shader, locIndex: int, value: FFIPointer, uniformType: int) -> (),
	SetShaderValueV: (shader: Shader, locIndex: int, value: FFIPointer, uniformType: int, count: int) -> (),
	SetShaderValueMatrix: (shader: Shader, locIndex: int, mat: Matrix) -> (),
	SetShaderValueTexture: (shader: Shader, locIndex: int, texture: Texture) -> (),
	UnloadShader: (shader: Shader) -> (),
	GetScreenToWorldRay: (position: Vector2, camera: Camera3D) -> Ray,
	GetScreenToWorldRayEx: (position: Vector2, camera: Camera3D, width: int, height: int) -> Ray,
	GetWorldToScreen: (position: Vector3, camera: Camera3D) -> Vector2,
	GetWorldToScreenEx: (position: Vector3, camera: Camera3D, width: int, height: int) -> Vector2,
	GetWorldToScreen2D: (position: Vector2, camera: Camera2D) -> Vector2,
	GetScreenToWorld2D: (position: Vector2, camera: Camera2D) -> Vector2,
	GetCameraMatrix: (camera: Camera3D) -> Matrix,
	GetCameraMatrix2D: (camera: Camera2D) -> Matrix,
	SetTargetFPS: (fps: int) -> (),
	GetFrameTime: () -> float,
	GetTime: () -> double,
	GetFPS: () -> int,
	SwapScreenBuffer: () -> (),
	PollInputEvents: () -> (),
	WaitTime: (seconds: double) -> (),
	SetRandomSeed: (seed: uint) -> (),
	GetRandomValue: (min: int, max: int) -> int,
	LoadRandomSequence: (count: uint, min: int, max: int) -> FFIPointer,
	UnloadRandomSequence: (sequence: FFIPointer) -> (),
	TakeScreenshot: (fileName: cstring) -> (),
	SetConfigFlags: (flags: uint) -> (),
	OpenURL: (url: cstring) -> (),
	TraceLog: (logLevel: int, text: cstring) -> (),
	SetTraceLogLevel: (logLevel: int) -> (),
	MemAlloc: (size: uint) -> FFIPointer,
	MemRealloc: (ptr: FFIPointer, size: uint) -> FFIPointer,
	MemFree: (ptr: FFIPointer) -> (),
	SetTraceLogCallback: (callback: FFIPointer) -> (),
	SetLoadFileDataCallback: (callback: FFIPointer) -> (),
	SetSaveFileDataCallback: (callback: FFIPointer) -> (),
	SetLoadFileTextCallback: (callback: FFIPointer) -> (),
	SetSaveFileTextCallback: (callback: FFIPointer) -> (),
	LoadFileData: (fileName: cstring, dataSize: FFIPointer) -> FFIPointer,
	UnloadFileData: (data: FFIPointer) -> (),
	SaveFileData: (fileName: cstring, data: FFIPointer, dataSize: int) -> bool,
	ExportDataAsCode: (data: FFIPointer, dataSize: int, fileName: cstring) -> bool,
	LoadFileText: (fileName: cstring) -> FFIPointer,
	UnloadFileText: (text: cstring) -> (),
	SaveFileText: (fileName: cstring, text: cstring) -> bool,
	FileExists: (fileName: cstring) -> bool,
	DirectoryExists: (dirPath: cstring) -> bool,
	IsFileExtension: (fileName: cstring, ext: cstring) -> bool,
	GetFileLength: (fileName: cstring) -> int,
	GetFileExtension: (fileName: cstring) -> FFIPointer,
	GetFileName: (fileName: cstring) -> FFIPointer,
	GetFileNameWithoutExt: (fileName: cstring) -> FFIPointer,
	GetDirectoryPath: (fileName: cstring) -> FFIPointer,
	GetWorkingDirectory: () -> FFIPointer,
	GetApplicationDirectory: () -> FFIPointer,
	ChangeDirectory: (dir: cstring) -> bool,
	IsPathFile: (path: cstring) -> bool,
	LoadDirectoryFiles: (dirPath: cstring) -> FilePathList,
	UnloadDirectoryFiles: (filePathList: FilePathList) -> (),
	GetFileModTime: (fileName: cstring) -> long,
	CompressData: (data: FFIPointer, dataSize: int, compDataSize: FFIPointer) -> FFIPointer,
	DecompressData: (compData: FFIPointer, compDataSize: int, dataSize: FFIPointer) -> FFIPointer,
	EncodeDataBase64: (data: FFIPointer, dataSize: int, outputSize: FFIPointer) -> FFIPointer,
	DecodeDataBase64: (data: cstring, outputSize: FFIPointer) -> FFIPointer,
	IsKeyPressed: (key: int) -> bool,
	IsKeyDown: (key: int) -> bool,
	IsKeyReleased: (key: int) -> bool,
	IsKeyUp: (key: int) -> bool,
	GetKeyPressed: () -> int,
	GetCharPressed: () -> int,
	SetExitKey: (key: int) -> (),
	IsGamepadAvailable: (gamepad: int) -> bool,
	GetGamepadName: (gamepad: int) -> FFIPointer,
	IsGamepadButtonPressed: (gamepad: int, button: int) -> bool,
	IsGamepadButtonDown: (gamepad: int, button: int) -> bool,
	IsGamepadButtonReleased: (gamepad: int, button: int) -> bool,
	IsGamepadButtonUp: (gamepad: int, button: int) -> bool,
	GetGamepadButtonPressed: () -> int,
	GetGamepadAxisCount: (gamepad: int) -> int,
	GetGamepadAxisMovement: (gamepad: int, axis: int) -> float,
	SetGamepadMappings: (mappings: cstring) -> int,
	SetGamepadVibration: (gamepad: int, leftMotor: float, rightMotor: float, duration: float) -> (),
	IsMouseButtonPressed: (button: int) -> bool,
	IsMouseButtonDown: (button: int) -> bool,
	IsMouseButtonReleased: (button: int) -> bool,
	IsMouseButtonUp: (button: int) -> bool,
	GetMouseX: () -> int,
	GetMouseY: () -> int,
	GetMousePosition: () -> Vector2,
	GetMouseDelta: () -> Vector2,
	SetMousePosition: (x: int, y: int) -> (),
	SetMouseOffset: (offsetX: int, offsetY: int) -> (),
	SetMouseScale: (scaleX: float, scaleY: float) -> (),
	GetMouseWheelMove: () -> float,
	GetMouseWheelMoveV: () -> Vector2,
	SetMouseCursor: (cursor: int) -> (),
	GetTouchX: () -> int,
	GetTouchY: () -> int,
	GetTouchPosition: (index: int) -> Vector2,
	GetTouchPointCount: () -> int,
	SetGesturesEnabled: (flags: uint) -> (),
	IsGestureDetected: (gesture: uint) -> bool,
	GetGestureDetected: () -> int,
	GetGestureHoldDuration: () -> float,
	GetGestureDragVector: () -> Vector2,
	GetGestureDragAngle: () -> float,
	GetGesturePinchVector: () -> Vector2,
	GetGesturePinchAngle: () -> float,
	UpdateCamera: (camera: FFIPointer, mode: int) -> (),
	UpdateCameraPro: (camera: FFIPointer, movement: Vector3, rotation: Vector3, zoom: float) -> (),
}

return {
	def = {
		-- void InitWindow(int width, int height, const char *title);
		InitWindow = fn(void, { int, int, cstring }),
		-- void CloseWindow(void);
		CloseWindow = fn(void, {}),
		-- bool WindowShouldClose(void);
		WindowShouldClose = fn(bool, {}),
		-- bool IsWindowReady(void);
		IsWindowReady = fn(bool, {}),
		-- bool IsWindowFullscreen(void);
		IsWindowFullscreen = fn(bool, {}),
		-- bool IsWindowHidden(void);
		IsWindowHidden = fn(bool, {}),
		-- bool IsWindowMinimized(void);
		IsWindowMinimized = fn(bool, {}),
		-- bool IsWindowMaximized(void);
		IsWindowMaximized = fn(bool, {}),
		-- bool IsWindowFocused(void);
		IsWindowFocused = fn(bool, {}),
		-- bool IsWindowResized(void);
		IsWindowResized = fn(bool, {}),
		-- bool IsWindowState(unsigned int flag);
		IsWindowState = fn(bool, { uint }),
		-- void SetWindowState(unsigned int flags);
		SetWindowState = fn(void, { uint }),
		-- void ClearWindowState(unsigned int flags);
		ClearWindowState = fn(void, { uint }),
		-- void ToggleFullscreen(void);
		ToggleFullscreen = fn(void, {}),
		-- void ToggleBorderlessWindowed(void);
		ToggleBorderlessWindowed = fn(void, {}),
		-- void MaximizeWindow(void);
		MaximizeWindow = fn(void, {}),
		-- void MinimizeWindow(void);
		MinimizeWindow = fn(void, {}),
		-- void RestoreWindow(void);
		RestoreWindow = fn(void, {}),
		-- void SetWindowIcon(Image image);
		SetWindowIcon = fn(void, { Image }),
		-- void SetWindowIcons(Image *images, int count);
		SetWindowIcons = fn(void, { ffi.types.pointer, int }),
		-- void SetWindowTitle(const char *title);
		SetWindowTitle = fn(void, { cstring }),
		-- void SetWindowPosition(int x, int y);
		SetWindowPosition = fn(void, { int, int }),
		-- void SetWindowMonitor(int monitor);
		SetWindowMonitor = fn(void, { int }),
		-- void SetWindowMinSize(int width, int height);
		SetWindowMinSize = fn(void, { int, int }),
		-- void SetWindowMaxSize(int width, int height);
		SetWindowMaxSize = fn(void, { int, int }),
		-- void SetWindowSize(int width, int height);
		SetWindowSize = fn(void, { int, int }),
		-- void SetWindowOpacity(float opacity);
		SetWindowOpacity = fn(void, { float }),
		-- void SetWindowFocused(void);
		SetWindowFocused = fn(void, {}),
		-- void *GetWindowHandle(void);
		GetWindowHandle = fn(ffi.types.pointer, {}),
		-- int GetScreenWidth(void);
		GetScreenWidth = fn(int, {}),
		-- int GetScreenHeight(void);
		GetScreenHeight = fn(int, {}),
		-- int GetRenderWidth(void);
		GetRenderWidth = fn(int, {}),
		-- int GetRenderHeight(void);
		GetRenderHeight = fn(int, {}),
		-- int GetMonitorCount(void);
		GetMonitorCount = fn(int, {}),
		-- int GetCurrentMonitor(void);
		GetCurrentMonitor = fn(int, {}),
		-- Vector2 GetMonitorPosition(int monitor);
		GetMonitorPosition = fn(Vector2, { int }),
		-- int GetMonitorWidth(int monitor);
		GetMonitorWidth = fn(int, { int }),
		-- int GetMonitorHeight(int monitor);
		GetMonitorHeight = fn(int, { int }),
		-- int GetMonitorPhysicalWidth(int monitor);
		GetMonitorPhysicalWidth = fn(int, { int }),
		-- int GetMonitorPhysicalHeight(int monitor);
		GetMonitorPhysicalHeight = fn(int, { int }),
		-- int GetMonitorRefreshRate(int monitor);
		GetMonitorRefreshRate = fn(int, { int }),
		-- Vector2 GetWindowPosition(void);
		GetWindowPosition = fn(Vector2, {}),
		-- Vector2 GetWindowScaleDPI(void);
		GetWindowScaleDPI = fn(Vector2, {}),
		-- const char *GetMonitorName(int monitor);
		GetMonitorName = fn(cstring, { int }),
		-- void SetClipboardText(const char *text);
		SetClipboardText = fn(void, { cstring }),
		-- const char *GetClipboardText(void);
		GetClipboardText = fn(cstring, {}),
		-- Image GetClipboardImage(void);
		GetClipboardImage = fn(Image, {}),
		-- void EnableEventWaiting(void);
		EnableEventWaiting = fn(void, {}),
		-- void DisableEventWaiting(void);
		DisableEventWaiting = fn(void, {}),
		-- void ShowCursor(void);
		ShowCursor = fn(void, {}),
		-- void HideCursor(void);
		HideCursor = fn(void, {}),
		-- void EnableCursor(void);
		EnableCursor = fn(void, {}),
		-- void DisableCursor(void);
		DisableCursor = fn(void, {}),
		-- bool IsCursorHidden(void);
		IsCursorHidden = fn(bool, {}),
		-- bool IsCursorOnScreen(void);
		IsCursorOnScreen = fn(bool, {}),
		-- void ClearBackground(Color color);
		ClearBackground = fn(void, { Color }),
		-- void BeginDrawing(void);
		BeginDrawing = fn(void, {}),
		-- void EndDrawing(void);
		EndDrawing = fn(void, {}),
		-- void BeginMode2D(Camera2D camera);
		BeginMode2D = fn(void, { Camera2D }),
		-- void EndMode2D(void);
		EndMode2D = fn(void, {}),
		-- void BeginMode3D(Camera3D camera);
		BeginMode3D = fn(void, { Camera3D }),
		-- void EndMode3D(void);
		EndMode3D = fn(void, {}),
		-- void BeginTextureMode(RenderTexture2D target);
		BeginTextureMode = fn(void, { RenderTexture2D }),
		-- void EndTextureMode(void);
		EndTextureMode = fn(void, {}),
		-- void BeginShaderMode(Shader shader);
		BeginShaderMode = fn(void, { Shader }),
		-- void EndShaderMode(void);
		EndShaderMode = fn(void, {}),
		-- void BeginBlendMode(int mode);
		BeginBlendMode = fn(void, { int }),
		-- void EndBlendMode(void);
		EndBlendMode = fn(void, {}),
		-- void BeginScissorMode(int x, int y, int width, int height);
		BeginScissorMode = fn(void, { int, int, int, int }),
		-- void EndScissorMode(void);
		EndScissorMode = fn(void, {}),
		-- void BeginVrStereoMode(VrStereoConfig config);
		BeginVrStereoMode = fn(void, { VrStereoConfig }),
		-- void EndVrStereoMode(void);
		EndVrStereoMode = fn(void, {}),
		-- VrStereoConfig LoadVrStereoConfig(VrDeviceInfo device);
		LoadVrStereoConfig = fn(VrStereoConfig, { VrDeviceInfo }),
		-- void UnloadVrStereoConfig(VrStereoConfig config);
		UnloadVrStereoConfig = fn(void, { VrStereoConfig }),
		-- Shader LoadShader(const char *vsFileName, const char *fsFileName);
		LoadShader = fn(Shader, { cstring, cstring }),
		-- Shader LoadShaderFromMemory(const char *vsCode, const char *fsCode);
		LoadShaderFromMemory = fn(Shader, { cstring, cstring }),
		-- bool IsShaderValid(Shader shader);
		IsShaderValid = fn(bool, { Shader }),
		-- int GetShaderLocation(Shader shader, const char *uniformName);
		GetShaderLocation = fn(int, { Shader, cstring }),
		-- int GetShaderLocationAttrib(Shader shader, const char *attribName);
		GetShaderLocationAttrib = fn(int, { Shader, cstring }),
		-- void SetShaderValue(Shader shader, int locIndex, const void *value, int uniformType);
		SetShaderValue = fn(void, { Shader, int, ffi.types.pointer, int }),
		-- void SetShaderValueV(Shader shader, int locIndex, const void *value, int uniformType, int count);
		SetShaderValueV = fn(void, { Shader, int, ffi.types.pointer, int, int }),
		-- void SetShaderValueMatrix(Shader shader, int locIndex, Matrix mat);
		SetShaderValueMatrix = fn(void, { Shader, int, Matrix }),
		-- void SetShaderValueTexture(Shader shader, int locIndex, Texture2D texture);
		SetShaderValueTexture = fn(void, { Shader, int, Texture }),
		-- void UnloadShader(Shader shader);
		UnloadShader = fn(void, { Shader }),
		-- Ray GetScreenToWorldRay(Vector2 position, Camera camera);
		GetScreenToWorldRay = fn(Ray, { Vector2, Camera3D }),
		-- Ray GetScreenToWorldRayEx(Vector2 position, Camera camera, int width, int height);
		GetScreenToWorldRayEx = fn(Ray, { Vector2, Camera3D, int, int }),
		-- Vector2 GetWorldToScreen(Vector3 position, Camera camera);
		GetWorldToScreen = fn(Vector2, { Vector3, Camera3D }),
		-- Vector2 GetWorldToScreenEx(Vector3 position, Camera camera, int width, int height);
		GetWorldToScreenEx = fn(Vector2, { Vector3, Camera3D, int, int }),
		-- Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera);
		GetWorldToScreen2D = fn(Vector2, { Vector2, Camera2D }),
		-- Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera);
		GetScreenToWorld2D = fn(Vector2, { Vector2, Camera2D }),
		-- Matrix GetCameraMatrix(Camera camera);
		GetCameraMatrix = fn(Matrix, { Camera3D }),
		-- Matrix GetCameraMatrix2D(Camera2D camera);
		GetCameraMatrix2D = fn(Matrix, { Camera2D }),
		-- void SetTargetFPS(int fps);
		SetTargetFPS = fn(void, { int }),
		-- float GetFrameTime(void);
		GetFrameTime = fn(float, {}),
		-- double GetTime(void);
		GetTime = fn(ffi.types.double, {}),
		-- int GetFPS(void);
		GetFPS = fn(int, {}),
		-- void SwapScreenBuffer(void);
		SwapScreenBuffer = fn(void, {}),
		-- void PollInputEvents(void);
		PollInputEvents = fn(void, {}),
		-- void WaitTime(double seconds);
		WaitTime = fn(void, { ffi.types.double }),
		-- void SetRandomSeed(unsigned int seed);
		SetRandomSeed = fn(void, { uint }),
		-- int GetRandomValue(int min, int max);
		GetRandomValue = fn(int, { int, int }),
		-- int *LoadRandomSequence(unsigned int count, int min, int max);
		LoadRandomSequence = fn(ffi.types.pointer, { uint, int, int }),
		-- void UnloadRandomSequence(int *sequence);
		UnloadRandomSequence = fn(void, { ffi.types.pointer }),
		-- void TakeScreenshot(const char *fileName);
		TakeScreenshot = fn(void, { cstring }),
		-- void SetConfigFlags(unsigned int flags);
		SetConfigFlags = fn(void, { uint }),
		-- void OpenURL(const char *url);
		OpenURL = fn(void, { cstring }),
		-- void TraceLog(int logLevel, const char *text, ...);
		TraceLog = fn(void, { int, cstring }),
		-- void SetTraceLogLevel(int logLevel);
		SetTraceLogLevel = fn(void, { int }),
		-- void *MemAlloc(unsigned int size);
		MemAlloc = fn(ffi.types.pointer, { uint }),
		-- void *MemRealloc(void *ptr, unsigned int size);
		MemRealloc = fn(ffi.types.pointer, { ffi.types.pointer, uint }),
		-- void MemFree(void *ptr);
		MemFree = fn(void, { ffi.types.pointer }),
		-- void SetTraceLogCallback(TraceLogCallback callback);
		SetTraceLogCallback = fn(void, { ffi.types.pointer }),
		-- void SetLoadFileDataCallback(LoadFileDataCallback callback);
		SetLoadFileDataCallback = fn(void, { ffi.types.pointer }),
		-- void SetSaveFileDataCallback(SaveFileDataCallback callback);
		SetSaveFileDataCallback = fn(void, { ffi.types.pointer }),
		-- void SetLoadFileTextCallback(LoadFileTextCallback callback);
		SetLoadFileTextCallback = fn(void, { ffi.types.pointer }),
		-- void SetSaveFileTextCallback(SaveFileTextCallback callback);
		SetSaveFileTextCallback = fn(void, { ffi.types.pointer }),
		-- unsigned char *LoadFileData(const char *fileName, int *dataSize);
		LoadFileData = fn(ffi.types.pointer, { cstring, ffi.types.pointer }),
		-- void UnloadFileData(unsigned char *data);
		UnloadFileData = fn(void, { ffi.types.pointer }),
		-- bool SaveFileData(const char *fileName, void *data, int dataSize);
		SaveFileData = fn(bool, { cstring, ffi.types.pointer, int }),
		-- bool ExportDataAsCode(const unsigned char *data, int dataSize, const char *fileName);
		ExportDataAsCode = fn(bool, { ffi.types.pointer, int, cstring }),
		-- char *LoadFileText(const char *fileName);
		LoadFileText = fn(cstring, { cstring }),
		-- void UnloadFileText(char *text);
		UnloadFileText = fn(void, { cstring }),
		-- bool SaveFileText(const char *fileName, char *text);
		SaveFileText = fn(bool, { cstring, cstring }),
		-- bool FileExists(const char *fileName);
		FileExists = fn(bool, { cstring }),
		-- bool DirectoryExists(const char *dirPath);
		DirectoryExists = fn(bool, { cstring }),
		-- bool IsFileExtension(const char *fileName, const char *ext);
		IsFileExtension = fn(bool, { cstring, cstring }),
		-- int GetFileLength(const char *fileName);
		GetFileLength = fn(int, { cstring }),
		-- const char *GetFileExtension(const char *fileName);
		GetFileExtension = fn(cstring, { cstring }),
		-- const char *GetFileName(const char filePath);
		GetFileName = fn(cstring, { cstring }),
		-- const char *GetFileNameWithoutExt(const char *filePath);
		GetFileNameWithoutExt = fn(cstring, { cstring }),
		-- const char *GetDirectoryPath(const char *filePath);
		GetDirectoryPath = fn(cstring, { cstring }),
		-- const char *GetWorkingDirectory(void);
		GetWorkingDirectory = fn(cstring, {}),
		-- const char *GetApplicationDirectory(void);
		GetApplicationDirectory = fn(cstring, {}),
		-- bool ChangeDirectory(const char *dir);
		ChangeDirectory = fn(bool, { cstring }),
		-- bool IsPathFile(const char *path);
		IsPathFile = fn(bool, { cstring }),
		-- FilePathList LoadDirectoryFiles(const char *dirPath);
		LoadDirectoryFiles = fn(FilePathList, { cstring }),
		-- void UnloadDirectoryFiles(FilePathList files);
		UnloadDirectoryFiles = fn(void, { FilePathList }),
		-- long GetFileModTime(const char *fileName);
		GetFileModTime = fn(long, { cstring }),
		-- unsigned char *CompressData(const unsigned char *data, int dataSize, int *compDataSize);
		CompressData = fn(ffi.types.pointer, { ffi.types.pointer, int, ffi.types.pointer }),
		-- unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize);
		DecompressData = fn(ffi.types.pointer, { ffi.types.pointer, int, ffi.types.pointer }),
		-- char *EncodeDataBase64(const unsigned char *data, int dataSize, int *outputSize);
		EncodeDataBase64 = fn(cstring, { ffi.types.pointer, int, ffi.types.pointer }),
		-- unsigned char *DecodeDataBase64(const unsigned char *data, int *outputSize);
		DecodeDataBase64 = fn(ffi.types.pointer, { ffi.types.pointer, ffi.types.pointer }),
		-- bool IsKeyPressed(int key);
		IsKeyPressed = fn(bool, { int }),
		-- bool IsKeyDown(int key);
		IsKeyDown = fn(bool, { int }),
		-- bool IsKeyReleased(int key);
		IsKeyReleased = fn(bool, { int }),
		-- bool IsKeyUp(int key);
		IsKeyUp = fn(bool, { int }),
		-- int GetKeyPressed(void);
		GetKeyPressed = fn(int, {}),
		-- int GetCharPressed(void);
		GetCharPressed = fn(int, {}),
		-- void SetExitKey(int key);
		SetExitKey = fn(void, { int }),
		-- bool IsGamepadAvailable(int gamepad);
		IsGamepadAvailable = fn(bool, { int }),
		-- const char *GetGamepadName(int gamepad);
		GetGamepadName = fn(cstring, { int }),
		-- bool IsGamepadButtonPressed(int gamepad, int button);
		IsGamepadButtonPressed = fn(bool, { int, int }),
		-- bool IsGamepadButtonDown(int gamepad, int button);
		IsGamepadButtonDown = fn(bool, { int, int }),
		-- bool IsGamepadButtonReleased(int gamepad, int button);
		IsGamepadButtonReleased = fn(bool, { int, int }),
		-- bool IsGamepadButtonUp(int gamepad, int button);
		IsGamepadButtonUp = fn(bool, { int, int }),
		-- int GetGamepadButtonPressed(void);
		GetGamepadButtonPressed = fn(int, {}),
		-- int GetGamepadAxisCount(int gamepad);
		GetGamepadAxisCount = fn(int, { int }),
		-- float GetGamepadAxisMovement(int gamepad, int axis);
		GetGamepadAxisMovement = fn(float, { int, int }),
		-- int SetGamepadMappings(const char *mappings);
		SetGamepadMappings = fn(int, { cstring }),
		-- void SetGamepadVibration(int gamepad, float leftMotor, float rightMotor, float duration);
		SetGamepadVibration = fn(void, { int, float, float, float }),
		-- bool IsMouseButtonPressed(int button);
		IsMouseButtonPressed = fn(bool, { int }),
		-- bool IsMouseButtonDown(int button);
		IsMouseButtonDown = fn(bool, { int }),
		-- bool IsMouseButtonReleased(int button);
		IsMouseButtonReleased = fn(bool, { int }),
		-- bool IsMouseButtonUp(int button);
		IsMouseButtonUp = fn(bool, { int }),
		-- int GetMouseX(void);
		GetMouseX = fn(int, {}),
		-- int GetMouseY(void);
		GetMouseY = fn(int, {}),
		-- Vector2 GetMousePosition(void);
		GetMousePosition = fn(Vector2, {}),
		-- Vector2 GetMouseDelta(void);
		GetMouseDelta = fn(Vector2, {}),
		-- void SetMousePosition(int x, int y);
		SetMousePosition = fn(void, { int, int }),
		-- void SetMouseOffset(int offsetX, int offsetY);
		SetMouseOffset = fn(void, { int, int }),
		-- void SetMouseScale(float scaleX, float scaleY);
		SetMouseScale = fn(void, { float, float }),
		-- float GetMouseWheelMove(void);
		GetMouseWheelMove = fn(float, {}),
		-- Vector2 GetMouseWheelMoveV(void);
		GetMouseWheelMoveV = fn(Vector2, {}),
		-- void SetMouseCursor(int cursor);
		SetMouseCursor = fn(void, { int }),
		-- int GetTouchX(void);
		GetTouchX = fn(int, {}),
		-- int GetTouchY(void);
		GetTouchY = fn(int, {}),
		-- Vector2 GetTouchPosition(int index);
		GetTouchPosition = fn(Vector2, { int }),
		-- int GetTouchPointCount(void);
		GetTouchPointCount = fn(int, {}),
		-- void SetGesturesEnabled(unsigned int flags);
		SetGesturesEnabled = fn(void, { uint }),
		-- bool IsGestureDetected(unsigned int gesture);
		IsGestureDetected = fn(bool, { uint }),
		-- int GetGestureDetected(void);
		GetGestureDetected = fn(int, {}),
		-- float GetGestureHoldDuration(void);
		GetGestureHoldDuration = fn(float, {}),
		-- Vector2 GetGestureDragVector(void);
		GetGestureDragVector = fn(Vector2, {}),
		-- float GetGestureDragAngle(void);
		GetGestureDragAngle = fn(float, {}),
		-- Vector2 GetGesturePinchVector(void);
		GetGesturePinchVector = fn(Vector2, {}),
		-- float GetGesturePinchAngle(void);
		GetGesturePinchAngle = fn(float, {}),
		-- void UpdateCamera(Camera *camera, int mode);
		UpdateCamera = fn(void, { ffi.types.pointer, int }),
		-- void UpdateCameraPro(Camera *camera, Vector3 movement, Vector3 rotation, float zoom);
		UpdateCameraPro = fn(void, { ffi.types.pointer, Vector3, Vector3, float }),
	},
}
