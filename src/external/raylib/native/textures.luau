--!strict
--!optimize 2
--!native

local ffi = zune.ffi

local adapter = require("./raylib")

local structs = adapter.structs

local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
type int = number
type uint = number
type bool = number
type float = number
type cstring = string | buffer | FFIPointer

local Vector2 = structs.Vector2
local Vector3 = structs.Vector3
local Vector4 = structs.Vector4
local Color = structs.Color
local Rectangle = structs.Rectangle
local Image = structs.Image
local Texture2D = structs.Texture2D
local TextureCubemap = structs.TextureCubemap
local RenderTexture2D = structs.RenderTexture2D
local NPatchInfo = structs.NPatchInfo
local Font = structs.Font
type Vector2 = adapter.Vector2
type Vector3 = adapter.Vector3
type Vector4 = adapter.Vector4
type Color = adapter.Color
type Rectangle = adapter.Rectangle
type Image = adapter.Image
type Texture2D = adapter.Texture2D
type TextureCubemap = adapter.TextureCubemap
type RenderTexture2D = adapter.RenderTexture2D
type NPatchInfo = adapter.NPatchInfo
type Font = adapter.Font

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	LoadImage: (fileName: cstring) -> Image,
	LoadImageRaw: (fileName: cstring, width: int, height: int, format: int, headerSize: int) -> Image,
	LoadImageAnim: (fileName: cstring, frames: FFIPointer) -> Image,
	LoadImageAnimFromMemory: (fileType: cstring, fileData: FFIPointer, dataSize: int, frames: FFIPointer) -> Image,
	LoadImageFromMemory: (fileType: cstring, fileData: FFIPointer, dataSize: int) -> Image,
	LoadImageFromTexture: (texture: Texture2D) -> Image,
	LoadImageFromScreen: () -> Image,
	IsImageValid: (image: Image) -> bool,
	UnloadImage: (image: Image) -> (),
	ExportImage: (image: Image, fileName: cstring) -> bool,
	ExportImageToMemory: (image: Image, fileType: cstring, fileSize: FFIPointer) -> FFIPointer,
	ExportImageAsCode: (image: Image, fileName: cstring) -> bool,
	GenImageColor: (width: int, height: int, color: Color) -> Image,
	GenImageGradientLinear: (width: int, height: int, direction: int, start: Color, endColor: Color) -> Image,
	GenImageGradientRadial: (width: int, height: int, density: float, inner: Color, outer: Color) -> Image,
	GenImageGradientSquare: (width: int, height: int, density: float, inner: Color, outer: Color) -> Image,
	GenImageChecked: (width: int, height: int, checksX: int, checksY: int, col1: Color, col2: Color) -> Image,
	GenImageWhiteNoise: (width: int, height: int, factor: float) -> Image,
	GenImagePerlinNoise: (width: int, height: int, offsetX: int, offsetY: int, scale: float) -> Image,
	GenImageCellular: (width: int, height: int, tileSize: int) -> Image,
	GenImageText: (width: int, height: int, text: cstring) -> Image,
	ImageCopy: (image: Image) -> Image,
	ImageFromImage: (image: Image, rec: Rectangle) -> Image,
	ImageFromChannel: (image: Image, selectedChannel: int) -> Image,
	ImageText: (text: cstring, fontSize: int, color: Color) -> Image,
	ImageTextEx: (font: Font, text: cstring, fontSize: float, spacing: float, tint: Color) -> Image,
	ImageFormat: (image: FFIPointer, newFormat: int) -> (),
	ImageToPOT: (image: FFIPointer, fill: Color) -> (),
	ImageCrop: (image: FFIPointer, crop: Rectangle) -> (),
	ImageAlphaCrop: (image: FFIPointer, threshold: float) -> (),
	ImageAlphaClear: (image: FFIPointer, color: Color, threshold: float) -> (),
	ImageAlphaMask: (image: FFIPointer, alphaMask: Image) -> (),
	ImageAlphaPremultiply: (image: FFIPointer) -> (),
	ImageBlurGaussian: (image: FFIPointer, blurSize: int) -> (),
	ImageKernelConvolution: (image: FFIPointer, kernel: FFIPointer, kernelSize: int) -> (),
	ImageResize: (image: FFIPointer, newWidth: int, newHeight: int) -> (),
	ImageResizeNN: (image: FFIPointer, newWidth: int, newHeight: int) -> (),
	ImageResizeCanvas: (
		image: FFIPointer,
		newWidth: int,
		newHeight: int,
		offsetX: int,
		offsetY: int,
		fill: Color
	) -> (),
	ImageMipmaps: (image: FFIPointer) -> (),
	ImageDither: (image: FFIPointer, rBpp: int, gBpp: int, bBpp: int, aBpp: int) -> (),
	ImageFlipVertical: (image: FFIPointer) -> (),
	ImageFlipHorizontal: (image: FFIPointer) -> (),
	ImageRotate: (image: FFIPointer, degrees: int) -> (),
	ImageRotateCW: (image: FFIPointer) -> (),
	ImageRotateCCW: (image: FFIPointer) -> (),
	ImageColorTint: (image: FFIPointer, color: Color) -> (),
	ImageColorInvert: (image: FFIPointer) -> (),
	ImageColorGrayscale: (image: FFIPointer) -> (),
	ImageColorContrast: (image: FFIPointer, contrast: float) -> (),
	ImageColorBrightness: (image: FFIPointer, brightness: int) -> (),
	ImageColorReplace: (image: FFIPointer, color: Color, replace: Color) -> (),
	LoadImageColors: (image: Image) -> FFIPointer,
	LoadImagePalette: (image: Image, maxPaletteSize: int, colorCount: FFIPointer) -> FFIPointer,
	UnloadImageColors: (colors: FFIPointer) -> (),
	UnloadImagePalette: (colors: FFIPointer) -> (),
	GetImageAlphaBorder: (image: Image, threshold: float) -> Rectangle,
	GetImageColor: (image: Image, x: int, y: int) -> Color,
	ImageClearBackground: (dst: FFIPointer, color: Color) -> (),
	ImageDrawPixel: (dst: FFIPointer, posX: int, posY: int, color: Color) -> (),
	ImageDrawPixelV: (dst: FFIPointer, position: Vector2, color: Color) -> (),
	ImageDrawLine: (dst: FFIPointer, startPosX: int, startPosY: int, endPosX: int, endPosY: int, color: Color) -> (),
	ImageDrawLineV: (dst: FFIPointer, start: Vector2, endPos: Vector2, color: Color) -> (),
	ImageDrawLineEx: (dst: FFIPointer, start: Vector2, endPos: Vector2, thick: int, color: Color) -> (),
	ImageDrawCircle: (dst: FFIPointer, centerX: int, centerY: int, radius: int, color: Color) -> (),
	ImageDrawCircleV: (dst: FFIPointer, center: Vector2, radius: int, color: Color) -> (),
	ImageDrawCircleLines: (dst: FFIPointer, centerX: int, centerY: int, radius: int, color: Color) -> (),
	ImageDrawCircleLinesV: (dst: FFIPointer, center: Vector2, radius: int, color: Color) -> (),
	ImageDrawRectangle: (dst: FFIPointer, posX: int, posY: int, width: int, height: int, color: Color) -> (),
	ImageDrawRectangleV: (dst: FFIPointer, position: Vector2, size: Vector2, color: Color) -> (),
	ImageDrawRectangleRec: (dst: FFIPointer, rec: Rectangle, color: Color) -> (),
	ImageDrawRectangleLines: (dst: FFIPointer, rec: Rectangle, thick: int, color: Color) -> (),
	ImageDrawTriangle: (dst: FFIPointer, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> (),
	ImageDrawTriangleEx: (
		dst: FFIPointer,
		v1: Vector2,
		v2: Vector2,
		v3: Vector2,
		c1: Color,
		c2: Color,
		c3: Color
	) -> (),
	ImageDrawTriangleLines: (dst: FFIPointer, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> (),
	ImageDrawTriangleFan: (dst: FFIPointer, points: FFIPointer, pointCount: int, color: Color) -> (),
	ImageDrawTriangleStrip: (dst: FFIPointer, points: FFIPointer, pointCount: int, color: Color) -> (),
	ImageDraw: (dst: FFIPointer, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) -> (),
	ImageDrawText: (dst: FFIPointer, text: cstring, posX: int, posY: int, fontSize: int, color: Color) -> (),
	ImageDrawTextEx: (
		dst: FFIPointer,
		font: Font,
		text: cstring,
		position: Vector2,
		fontSize: float,
		spacing: float,
		tint: Color
	) -> (),
	LoadTexture: (fileName: cstring) -> Texture2D,
	LoadTextureFromImage: (image: Image) -> Texture2D,
	LoadTextureCubemap: (image: Image, layout: int) -> TextureCubemap,
	LoadRenderTexture: (width: int, height: int) -> RenderTexture2D,
	IsTextureValid: (texture: Texture2D) -> bool,
	UnloadTexture: (texture: Texture2D) -> (),
	IsRenderTextureValid: (target: RenderTexture2D) -> bool,
	UnloadRenderTexture: (target: RenderTexture2D) -> (),
	UpdateTexture: (texture: Texture2D, pixels: FFIPointer) -> (),
	UpdateTextureRec: (texture: Texture2D, rec: Rectangle, pixels: FFIPointer) -> (),
	GenTextureMipmaps: (texture: Texture2D) -> (),
	SetTextureFilter: (texture: Texture2D, filter: int) -> (),
	SetTextureWrap: (texture: Texture2D, wrap: int) -> (),
	DrawTexture: (texture: Texture2D, posX: int, posY: int, tint: Color) -> (),
	DrawTextureV: (texture: Texture2D, position: Vector2, tint: Color) -> (),
	DrawTextureEx: (texture: Texture2D, position: Vector2, rotation: float, scale: float, tint: Color) -> (),
	DrawTextureRec: (texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) -> (),
	DrawTexturePro: (
		texture: Texture2D,
		source: Rectangle,
		dest: Rectangle,
		origin: Vector2,
		rotation: float,
		tint: Color
	) -> (),
	DrawTextureNPatch: (
		texture: Texture2D,
		nPatchInfo: NPatchInfo,
		dest: Rectangle,
		origin: Vector2,
		rotation: float,
		tint: Color
	) -> (),
	ColorIsEqual: (col1: Color, col2: Color) -> bool,
	Fade: (color: Color, alpha: float) -> Color,
	ColorToInt: (color: Color) -> int,
	ColorNormalize: (color: Color) -> Vector4,
	ColorFromNormalized: (normalized: Vector4) -> Color,
	ColorToHSV: (color: Color) -> Vector3,
	ColorFromHSV: (hue: float, saturation: float, value: float) -> Color,
	ColorTint: (color: Color, tint: Color) -> Color,
	ColorBrightness: (color: Color, factor: float) -> Color,
	ColorContrast: (color: Color, contrast: float) -> Color,
	ColorAlpha: (color: Color, alpha: float) -> Color,
	ColorAlphaBlend: (dst: Color, src: Color, tint: Color) -> Color,
	ColorLerp: (color1: Color, color2: Color, factor: float) -> Color,
	GetColor: (hexValue: uint) -> Color,
	GetPixelColor: (srcPtr: FFIPointer, format: int) -> Color,
	SetPixelColor: (dstPtr: FFIPointer, color: Color, format: int) -> (),
	GetPixelDataSize: (width: int, height: int, format: int) -> int,
}

return {
	def = {
		-- Image LoadImage(const char *fileName);
		LoadImage = fn(Image, { cstring }),
		-- Image LoadImageRaw(const char *fileName, int width, int height, int format, int headerSize);
		LoadImageRaw = fn(Image, { cstring, int, int, int, int }),
		-- Image LoadImageAnim(const char *fileName, int *frames);
		LoadImageAnim = fn(Image, { cstring, ffi.types.pointer }),
		-- Image LoadImageAnimFromMemory(const char *fileType, const unsigned char *fileData, int dataSize, int *frames);
		LoadImageAnimFromMemory = fn(Image, { cstring, ffi.types.pointer, int, ffi.types.pointer }),
		-- Image LoadImageFromMemory(const char *fileType, const unsigned char *fileData, int dataSize);
		LoadImageFromMemory = fn(Image, { cstring, ffi.types.pointer, int }),
		-- Image LoadImageFromTexture(Texture2D texture);
		LoadImageFromTexture = fn(Image, { Texture2D }),
		-- Image LoadImageFromScreen(void);
		LoadImageFromScreen = fn(Image, {}),
		-- bool IsImageValid(Image image);
		IsImageValid = fn(bool, { Image }),
		-- void UnloadImage(Image image);
		UnloadImage = fn(void, { Image }),
		-- bool ExportImage(Image image, const char *fileName);
		ExportImage = fn(bool, { Image, cstring }),
		-- unsigned char *ExportImageToMemory(Image image, const char *fileType, int *fileSize);
		ExportImageToMemory = fn(ffi.types.pointer, { Image, cstring, ffi.types.pointer }),
		-- bool ExportImageAsCode(Image image, const char *fileName);
		ExportImageAsCode = fn(bool, { Image, cstring }),

		-- Image GenImageColor(int width, int height, Color color);
		GenImageColor = fn(Image, { int, int, Color }),
		-- Image GenImageGradientLinear(int width, int height, int direction, Color start, Color end);
		GenImageGradientLinear = fn(Image, { int, int, int, Color, Color }),
		-- Image GenImageGradientRadial(int width, int height, float density, Color inner, Color outer);
		GenImageGradientRadial = fn(Image, { int, int, float, Color, Color }),
		-- Image GenImageGradientSquare(int width, int height, float density, Color inner, Color outer);
		GenImageGradientSquare = fn(Image, { int, int, float, Color, Color }),
		-- Image GenImageChecked(int width, int height, int checksX, int checksY, Color col1, Color col2);
		GenImageChecked = fn(Image, { int, int, int, int, Color, Color }),
		-- Image GenImageWhiteNoise(int width, int height, float factor);
		GenImageWhiteNoise = fn(Image, { int, int, float }),
		-- Image GenImagePerlinNoise(int width, int height, int offsetX, int offsetY, float scale);
		GenImagePerlinNoise = fn(Image, { int, int, int, int, float }),
		-- Image GenImageCellular(int width, int height, int tileSize);
		GenImageCellular = fn(Image, { int, int, int }),
		-- Image GenImageText(int width, int height, const char *text);
		GenImageText = fn(Image, { int, int, cstring }),

		-- Image ImageCopy(Image image);
		ImageCopy = fn(Image, { Image }),
		-- Image ImageFromImage(Image image, Rectangle rec);
		ImageFromImage = fn(Image, { Image, Rectangle }),
		-- Image ImageFromChannel(Image image, int selectedChannel);
		ImageFromChannel = fn(Image, { Image, int }),
		-- Image ImageText(const char *text, int fontSize, Color color);
		ImageText = fn(Image, { cstring, int, Color }),
		-- Image ImageTextEx(Font font, const char *text, float fontSize, float spacing, Color tint);
		ImageTextEx = fn(Image, { Font, cstring, float, float, Color }),
		-- void ImageFormat(Image *image, int newFormat);
		ImageFormat = fn(void, { ffi.types.pointer, int }),
		-- void ImageToPOT(Image *image, Color fill);
		ImageToPOT = fn(void, { ffi.types.pointer, Color }),
		-- void ImageCrop(Image *image, Rectangle crop);
		ImageCrop = fn(void, { ffi.types.pointer, Rectangle }),
		-- void ImageAlphaCrop(Image *image, float threshold);
		ImageAlphaCrop = fn(void, { ffi.types.pointer, float }),
		-- void ImageAlphaClear(Image *image, Color color, float threshold);
		ImageAlphaClear = fn(void, { ffi.types.pointer, Color, float }),
		-- void ImageAlphaMask(Image *image, Image alphaMask);
		ImageAlphaMask = fn(void, { ffi.types.pointer, Image }),
		-- void ImageAlphaPremultiply(Image *image);
		ImageAlphaPremultiply = fn(void, { ffi.types.pointer }),
		-- void ImageBlurGaussian(Image *image, int blurSize);
		ImageBlurGaussian = fn(void, { ffi.types.pointer, int }),
		-- void ImageKernelConvolution(Image *image, const float *kernel, int kernelSize);
		ImageKernelConvolution = fn(void, { ffi.types.pointer, ffi.types.pointer, int }),
		-- void ImageResize(Image *image, int newWidth, int newHeight);
		ImageResize = fn(void, { ffi.types.pointer, int, int }),
		-- void ImageResizeNN(Image *image, int newWidth,int newHeight);
		ImageResizeNN = fn(void, { ffi.types.pointer, int, int }),
		-- void ImageResizeCanvas(Image *image, int newWidth, int newHeight, int offsetX, int offsetY, Color fill);
		ImageResizeCanvas = fn(void, { ffi.types.pointer, int, int, int, int, Color }),
		-- void ImageMipmaps(Image *image);
		ImageMipmaps = fn(void, { ffi.types.pointer }),
		-- void ImageDither(Image *image, int rBpp, int gBpp, int bBpp, int aBpp);
		ImageDither = fn(void, { ffi.types.pointer, int, int, int, int }),
		-- void ImageFlipVertical(Image *image);
		ImageFlipVertical = fn(void, { ffi.types.pointer }),
		-- void ImageFlipHorizontal(Image *image);
		ImageFlipHorizontal = fn(void, { ffi.types.pointer }),
		-- void ImageRotate(Image *image, int degrees);
		ImageRotate = fn(void, { ffi.types.pointer, int }),
		-- void ImageRotateCW(Image *image);
		ImageRotateCW = fn(void, { ffi.types.pointer }),
		-- void ImageRotateCCW(Image *image);
		ImageRotateCCW = fn(void, { ffi.types.pointer }),
		-- void ImageColorTint(Image *image, Color color);
		ImageColorTint = fn(void, { ffi.types.pointer, Color }),
		-- void ImageColorInvert(Image *image);
		ImageColorInvert = fn(void, { ffi.types.pointer }),
		-- void ImageColorGrayscale(Image *image);
		ImageColorGrayscale = fn(void, { ffi.types.pointer }),
		-- void ImageColorContrast(Image *image, float contrast);
		ImageColorContrast = fn(void, { ffi.types.pointer, float }),
		-- void ImageColorBrightness(Image *image, int brightness);
		ImageColorBrightness = fn(void, { ffi.types.pointer, int }),
		-- void ImageColorReplace(Image *image, Color color, Color replace);
		ImageColorReplace = fn(void, { ffi.types.pointer, Color, Color }),
		-- Color *LoadImageColors(Image image);
		LoadImageColors = fn(ffi.types.pointer, { Image }),
		-- Color *LoadImagePalette(Image image, int maxPaletteSize, int *colorCount);
		LoadImagePalette = fn(ffi.types.pointer, { Image, int, ffi.types.pointer }),
		-- void UnloadImageColors(Color *colors);
		UnloadImageColors = fn(void, { ffi.types.pointer }),
		-- void UnloadImagePalette(Color *colors);
		UnloadImagePalette = fn(void, { ffi.types.pointer }),
		-- Rectangle GetImageAlphaBorder(Image image, float threshold);
		GetImageAlphaBorder = fn(Rectangle, { Image, float }),
		-- Color GetImageColor(Image image, int x, int y);
		GetImageColor = fn(Color, { Image, int, int }),

		-- void ImageClearBackground(Image *dst, Color color);
		ImageClearBackground = fn(void, { ffi.types.pointer, Color }),
		-- void ImageDrawPixel(Image *dst, int posX, int posY, Color color);
		ImageDrawPixel = fn(void, { ffi.types.pointer, int, int, Color }),
		-- void ImageDrawPixelV(Image *dst, Vector2 position, Color color);
		ImageDrawPixelV = fn(void, { ffi.types.pointer, Vector2, Color }),
		-- void ImageDrawLine(Image *dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color);
		ImageDrawLine = fn(void, { ffi.types.pointer, int, int, int, int, Color }),
		-- void ImageDrawLineV(Image *dst, Vector2 start, Vector2 end, Color color);
		ImageDrawLineV = fn(void, { ffi.types.pointer, Vector2, Vector2, Color }),
		-- void ImageDrawLineEx(Image *dst, Vector2 start, Vector2 end, int thick, Color color);
		ImageDrawLineEx = fn(void, { ffi.types.pointer, Vector2, Vector2, int, Color }),
		-- void ImageDrawCircle(Image *dst, int centerX, int centerY, int radius, Color color);
		ImageDrawCircle = fn(void, { ffi.types.pointer, int, int, int, Color }),
		-- void ImageDrawCircleV(Image *dst, Vector2 center, int radius, Color color);
		ImageDrawCircleV = fn(void, { ffi.types.pointer, Vector2, int, Color }),
		-- void ImageDrawCircleLines(Image *dst, int centerX, int centerY, int radius, Color color);
		ImageDrawCircleLines = fn(void, { ffi.types.pointer, int, int, int, Color }),
		-- void ImageDrawCircleLinesV(Image *dst, Vector2 center, int radius, Color color);
		ImageDrawCircleLinesV = fn(void, { ffi.types.pointer, Vector2, int, Color }),
		-- void ImageDrawRectangle(Image *dst, int posX, int posY, int width, int height, Color color);
		ImageDrawRectangle = fn(void, { ffi.types.pointer, int, int, int, int, Color }),
		-- void ImageDrawRectangleV(Image *dst, Vector2 position, Vector2 size, Color color);
		ImageDrawRectangleV = fn(void, { ffi.types.pointer, Vector2, Vector2, Color }),
		-- void ImageDrawRectangleRec(Image *dst, Rectangle rec, Color color);
		ImageDrawRectangleRec = fn(void, { ffi.types.pointer, Rectangle, Color }),
		-- void ImageDrawRectangleLines(Image *dst, Rectangle rec, int thick, Color color);
		ImageDrawRectangleLines = fn(void, { ffi.types.pointer, Rectangle, int, Color }),
		-- void ImageDrawTriangle(Image *dst, Vector2 v1, Vector2 v2, Vector2 v3, Color color);
		ImageDrawTriangle = fn(void, { ffi.types.pointer, Vector2, Vector2, Vector2, Color }),
		-- void ImageDrawTriangleEx(Image *dst, Vector2 v1, Vector2 v2, Vector2 v3, Color c1, Color c2, Color c3);
		ImageDrawTriangleEx = fn(void, { ffi.types.pointer, Vector2, Vector2, Vector2, Color, Color, Color }),
		-- void ImageDrawTriangleLines(Image *dst, Vector2 v1, Vector2 v2, Vector2 v3, Color color);
		ImageDrawTriangleLines = fn(void, { ffi.types.pointer, Vector2, Vector2, Vector2, Color }),
		-- void ImageDrawTriangleFan(Image *dst, Vector2 *points, int pointCount, Color color);
		ImageDrawTriangleFan = fn(void, { ffi.types.pointer, ffi.types.pointer, int, Color }),
		-- void ImageDrawTriangleStrip(Image *dst, Vector2 *points, int pointCount, Color color);
		ImageDrawTriangleStrip = fn(void, { ffi.types.pointer, ffi.types.pointer, int, Color }),
		-- void ImageDraw(Image *dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint);
		ImageDraw = fn(void, { ffi.types.pointer, Image, Rectangle, Rectangle, Color }),
		-- void ImageDrawText(Image *dst, const char *text, int posX, int posY, int fontSize, Color color);
		ImageDrawText = fn(void, { ffi.types.pointer, cstring, int, int, int, Color }),
		-- void ImageDrawTextEx(Image *dst, Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint);
		ImageDrawTextEx = fn(void, { ffi.types.pointer, Font, cstring, Vector2, float, float, Color }),

		-- Texture2D LoadTexture(const char *fileName);
		LoadTexture = fn(Texture2D, { cstring }),
		-- Texture2D LoadTextureFromImage(Image image);
		LoadTextureFromImage = fn(Texture2D, { Image }),
		-- TextureCubemap LoadTextureCubemap(Image image, int layout);
		LoadTextureCubemap = fn(TextureCubemap, { Image, int }),
		-- RenderTexture2D LoadRenderTexture(int width, int height);
		LoadRenderTexture = fn(RenderTexture2D, { int, int }),
		-- bool IsTextureValid(Texture2D texture);
		IsTextureValid = fn(bool, { Texture2D }),
		-- void UnloadTexture(Texture2D texture);
		UnloadTexture = fn(void, { Texture2D }),
		-- bool IsRenderTextureValid(RenderTexture2D target);
		IsRenderTextureValid = fn(bool, { RenderTexture2D }),
		-- void UnloadRenderTexture(RenderTexture2D target);
		UnloadRenderTexture = fn(void, { RenderTexture2D }),
		-- void UpdateTexture(Texture2D texture, const void *pixels);
		UpdateTexture = fn(void, { Texture2D, ffi.types.pointer }),
		-- void UpdateTextureRec(Texture2D texture, Rectangle rec, const void *pixels);
		UpdateTextureRec = fn(void, { Texture2D, Rectangle, ffi.types.pointer }),

		-- void GenTextureMipmaps(Texture2D *texture);
		GenTextureMipmaps = fn(void, { ffi.types.pointer }),
		-- void SetTextureFilter(Texture2D texture, int filter);
		SetTextureFilter = fn(void, { Texture2D, int }),
		-- void SetTextureWrap(Texture2D texture, int wrap);
		SetTextureWrap = fn(void, { Texture2D, int }),

		-- void DrawTexture(Texture2D texture, int posX, int posY, Color tint);
		DrawTexture = fn(void, { Texture2D, int, int, Color }),
		-- void DrawTextureV(Texture2D texture, Vector2 position, Color tint);
		DrawTextureV = fn(void, { Texture2D, Vector2, Color }),
		-- void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint);
		DrawTextureEx = fn(void, { Texture2D, Vector2, float, float, Color }),
		-- void DrawTextureRec(Texture2D texture, Rectangle source, Vector2 position, Color tint);
		DrawTextureRec = fn(void, { Texture2D, Rectangle, Vector2, Color }),
		-- void DrawTexturePro(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint);
		DrawTexturePro = fn(void, { Texture2D, Rectangle, Rectangle, Vector2, float, Color }),
		-- void DrawTextureNPatch(Texture2D texture, NPatchInfo nPatchInfo, Rectangle dest, Vector2 origin, float rotation, Color tint);
		DrawTextureNPatch = fn(void, { Texture2D, NPatchInfo, Rectangle, Vector2, float, Color }),

		-- bool ColorIsEqual(Color col1, Color col2);
		ColorIsEqual = fn(bool, { Color, Color }),
		-- Color Fade(Color color, float alpha);
		Fade = fn(Color, { Color, float }),
		-- int ColorToInt(Color color);
		ColorToInt = fn(int, { Color }),
		-- Vector4 ColorNormalize(Color color);
		ColorNormalize = fn(Vector4, { Color }),
		-- Color ColorFromNormalized(Vector4 normalized);
		ColorFromNormalized = fn(Color, { Vector4 }),
		-- Vector3 ColorToHSV(Color color);
		ColorToHSV = fn(Vector3, { Color }),
		-- Color ColorFromHSV(float hue, float saturation, float value);
		ColorFromHSV = fn(Color, { float, float, float }),
		-- Color ColorTint(Color color, Color tint);
		ColorTint = fn(Color, { Color, Color }),
		-- Color ColorBrightness(Color color, float factor);
		ColorBrightness = fn(Color, { Color, float }),
		-- Color ColorContrast(Color color, float contrast);
		ColorContrast = fn(Color, { Color, float }),
		-- Color ColorAlpha(Color color, float alpha);
		ColorAlpha = fn(Color, { Color, float }),
		-- Color ColorAlphaBlend(Color dst, Color src, Color tint);
		ColorAlphaBlend = fn(Color, { Color, Color, Color }),
		-- Color ColorLerp(Color color1, Color color2, float factor);
		ColorLerp = fn(Color, { Color, Color, float }),
		-- Color GetColor(unsigned int hexValue);
		GetColor = fn(Color, { uint }),
		-- Color GetPixelColor(void *srcPtr, int format);
		GetPixelColor = fn(Color, { ffi.types.pointer, int }),
		-- void SetPixelColor(void *dstPtr, Color color, int format);
		SetPixelColor = fn(void, { ffi.types.pointer, Color, int }),
		-- int GetPixelDataSize(int width, int height, int format);
		GetPixelDataSize = fn(int, { int, int, int }),
	},
}
