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
local char = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
type int = number
type uint = number
type bool = number
type float = number
type cstring = string | buffer | FFIPointer
type char = number

local Vector2 = structs.Vector2
local Color = structs.Color
local Rectangle = structs.Rectangle
local Image = structs.Image
local GlyphInfo = structs.GlyphInfo
local Font = structs.Font
type Vector2 = adapter.Vector2
type Color = adapter.Color
type Rectangle = adapter.Rectangle
type Image = adapter.Image
type GlyphInfo = adapter.GlyphInfo
type Font = adapter.Font

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	GetFontDefault: () -> Font,
	LoadFont: (fileName: cstring) -> Font,
	LoadFontEx: (fileName: cstring, fontSize: int, codepoints: FFIPointer, codepointCount: int) -> Font,
	LoadFontFromImage: (image: Image, key: Color, firstChar: int) -> Font,
	LoadFontFromMemory: (
		fileType: cstring,
		fileData: FFIPointer,
		dataSize: int,
		fontSize: int,
		codepoints: FFIPointer,
		codepointCount: int
	) -> Font,
	IsFontValid: (font: Font) -> bool,
	LoadFontData: (
		fileData: FFIPointer,
		dataSize: int,
		fontSize: int,
		codepoints: FFIPointer,
		codepointCount: int,
		type_: int
	) -> FFIPointer,
	GenImageFontAtlas: (
		glyphs: FFIPointer,
		glyphRecs: FFIPointer,
		glyphCount: int,
		fontSize: int,
		padding: int,
		packMethod: int
	) -> Image,
	UnloadFontData: (glyphs: FFIPointer, glyphCount: int) -> (),
	UnloadFont: (font: Font) -> (),
	ExportFontAsCode: (font: Font, fileName: cstring) -> bool,
	DrawFPS: (posX: int, posY: int) -> (),
	DrawText: (text: cstring, posX: int, posY: int, fontSize: int, color: Color) -> (),
	DrawTextEx: (font: Font, text: cstring, position: Vector2, fontSize: float, spacing: float, tint: Color) -> (),
	DrawTextPro: (
		font: Font,
		text: cstring,
		position: Vector2,
		origin: Vector2,
		rotation: float,
		fontSize: float,
		spacing: float,
		tint: Color
	) -> (),
	DrawTextCodepoint: (font: Font, codepoint: int, position: Vector2, fontSize: float, tint: Color) -> (),
	DrawTextCodepoints: (
		font: Font,
		codepoints: FFIPointer,
		codepointCount: int,
		position: Vector2,
		fontSize: float,
		spacing: float,
		tint: Color
	) -> (),
	SetTextLineSpacing: (spacing: int) -> (),
	MeasureText: (text: cstring, fontSize: int) -> int,
	MeasureTextEx: (font: Font, text: cstring, fontSize: float, spacing: float) -> Vector2,
	GetGlyphIndex: (font: Font, codepoint: int) -> int,
	GetGlyphInfo: (font: Font, codepoint: int) -> GlyphInfo,
	GetGlyphAtlasRec: (font: Font, codepoint: int) -> Rectangle,
	LoadUTF8: (codepoints: FFIPointer, length: int) -> FFIPointer,
	UnloadUTF8: (text: cstring) -> (),
	LoadCodepoints: (text: cstring, count: FFIPointer) -> FFIPointer,
	UnloadCodepoints: (codepoints: FFIPointer) -> (),
	GetCodepointCount: (text: cstring) -> int,
	GetCodepoint: (text: cstring, codepointSize: FFIPointer) -> int,
	GetCodepointNext: (text: cstring, codepointSize: FFIPointer) -> int,
	GetCodepointPrevious: (text: cstring, codepointSize: FFIPointer) -> int,
	CodepointToUTF8: (codepoint: int, utf8Size: FFIPointer) -> FFIPointer,
	TextCopy: (dst: cstring, src: cstring) -> int,
	TextIsEqual: (text1: cstring, text2: cstring) -> bool,
	TextLength: (text: cstring) -> uint,
	TextFormat: (text: cstring) -> FFIPointer,
	TextSubtext: (text: cstring, position: int, length: int) -> FFIPointer,
	TextReplace: (text: cstring, replace: cstring, by: cstring) -> FFIPointer,
	TextInsert: (text: cstring, insert: cstring, position: int) -> FFIPointer,
	TextJoin: (textList: FFIPointer, count: int, delimiter: cstring) -> FFIPointer,
	TextSplit: (text: cstring, delimiter: char, count: FFIPointer) -> FFIPointer,
	TextAppend: (text: cstring, append: cstring, position: FFIPointer) -> (),
	TextFindIndex: (text: cstring, find: cstring) -> int,
	TextToUpper: (text: cstring) -> FFIPointer,
	TextToLower: (text: cstring) -> FFIPointer,
	TextToPascal: (text: cstring) -> FFIPointer,
	TextToSnake: (text: cstring) -> FFIPointer,
	TextToCamel: (text: cstring) -> FFIPointer,
	TextToInteger: (text: cstring) -> int,
	TextToFloat: (text: cstring) -> float,
}

return {
	def = {
		-- Font GetFontDefault(void);
		GetFontDefault = fn(Font, {}),
		-- Font LoadFont(const char *fileName);
		LoadFont = fn(Font, { cstring }),
		-- Font LoadFontEx(const char *fileName, int fontSize, int *codepoints, int codepointCount);
		LoadFontEx = fn(Font, { cstring, int, ffi.types.pointer, int }),
		-- Font LoadFontFromImage(Image image, Color key, int firstChar);
		LoadFontFromImage = fn(Font, { Image, Color, int }),
		-- Font LoadFontFromMemory(const char *fileType, const unsigned char *fileData, int dataSize, int fontSize, int *codepoints, int codepointCount);
		LoadFontFromMemory = fn(Font, { cstring, ffi.types.pointer, int, int, ffi.types.pointer, int }),
		-- bool IsFontValid(Font font);
		IsFontValid = fn(bool, { Font }),
		-- GlyphInfo *LoadFontData(const unsigned char *fileData, int dataSize, int fontSize, int *codepoints, int codepointCount, int type);
		LoadFontData = fn(ffi.types.pointer, { ffi.types.pointer, int, int, ffi.types.pointer, int, int }),
		-- Image GenImageFontAtlas(const GlyphInfo *glyphs, Rectangle **glyphRecs, int glyphCount, int fontSize, int padding, int packMethod);
		GenImageFontAtlas = fn(Image, { ffi.types.pointer, ffi.types.pointer, int, int, int, int }),
		-- void UnloadFontData(GlyphInfo *glyphs, int glyphCount);
		UnloadFontData = fn(void, { ffi.types.pointer, int }),
		-- void UnloadFont(Font font);
		UnloadFont = fn(void, { Font }),
		-- bool ExportFontAsCode(Font font, const char *fileName);
		ExportFontAsCode = fn(bool, { Font, cstring }),

		-- void DrawFPS(int posX, int posY);
		DrawFPS = fn(void, { int, int }),
		-- void DrawText(const char *text, int posX, int posY, int fontSize, Color color);
		DrawText = fn(void, { cstring, int, int, int, Color }),
		-- void DrawTextEx(Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint);
		DrawTextEx = fn(void, { Font, cstring, Vector2, float, float, Color }),
		-- void DrawTextPro(Font font, const char *text, Vector2 position, Vector2 origin, float rotation, float fontSize, float spacing, Color tint);
		DrawTextPro = fn(void, { Font, cstring, Vector2, Vector2, float, float, float, Color }),
		-- void DrawTextCodepoint(Font font, int codepoint, Vector2 position, float fontSize, Color tint);
		DrawTextCodepoint = fn(void, { Font, int, Vector2, float, Color }),
		-- void DrawTextCodepoints(Font font, const int *codepoints, int codepointCount, Vector2 position, float fontSize, float spacing, Color tint);
		DrawTextCodepoints = fn(void, { Font, ffi.types.pointer, int, Vector2, float, float, Color }),

		-- void SetTextLineSpacing(int spacing);
		SetTextLineSpacing = fn(void, { int }),
		-- int MeasureText(const char *text, int fontSize);
		MeasureText = fn(int, { cstring, int }),
		-- Vector2 MeasureTextEx(Font font, const char *text, float fontSize, float spacing);
		MeasureTextEx = fn(Vector2, { Font, cstring, float, float }),
		-- int GetGlyphIndex(Font font, int codepoint);
		GetGlyphIndex = fn(int, { Font, int }),
		-- GlyphInfo GetGlyphInfo(Font font, int codepoint);
		GetGlyphInfo = fn(GlyphInfo, { Font, int }),
		-- Rectangle GetGlyphAtlasRec(Font font, int codepoint);
		GetGlyphAtlasRec = fn(Rectangle, { Font, int }),

		-- char *LoadUTF8(const int *codepoints, int length);
		LoadUTF8 = fn(cstring, { ffi.types.pointer, int }),
		-- void UnloadUTF8(char *text);
		UnloadUTF8 = fn(void, { cstring }),
		-- int *LoadCodepoints(const char *text, int *count);
		LoadCodepoints = fn(ffi.types.pointer, { cstring, ffi.types.pointer }),
		-- void UnloadCodepoints(int *codepoints);
		UnloadCodepoints = fn(void, { ffi.types.pointer }),
		-- int GetCodepointCount(const char *text);
		GetCodepointCount = fn(int, { cstring }),
		-- int GetCodepoint(const char *text, int *codepointSize);
		GetCodepoint = fn(int, { cstring, ffi.types.pointer }),
		-- int GetCodepointNext(const char *text, int *codepointSize);
		GetCodepointNext = fn(int, { cstring, ffi.types.pointer }),
		-- int GetCodepointPrevious(const char *text, int *codepointSize);
		GetCodepointPrevious = fn(int, { cstring, ffi.types.pointer }),
		-- const char *CodepointToUTF8(int codepoint, int *utf8Size);
		CodepointToUTF8 = fn(cstring, { int, ffi.types.pointer }),

		-- int TextCopy(char *dst, const char *src);
		TextCopy = fn(int, { cstring, cstring }),
		-- bool TextIsEqual(const char *text1, const char *text2);
		TextIsEqual = fn(bool, { cstring, cstring }),
		-- unsigned int TextLength(const char *text);
		TextLength = fn(uint, { cstring }),
		-- const char *TextFormat(const char *text, ...);
		TextFormat = fn(cstring, { cstring }),
		-- const char *TextSubtext(const char *text, int position, int length);
		TextSubtext = fn(cstring, { cstring, int, int }),
		-- char *TextReplace(const char *text, const char *replace, const char *by);
		TextReplace = fn(cstring, { cstring, cstring, cstring }),
		-- char *TextInsert(const char *text, const char *insert, int position);
		TextInsert = fn(cstring, { cstring, cstring, int }),
		-- const char *TextJoin(const char **textList, int count, const char *delimiter);
		TextJoin = fn(cstring, { ffi.types.pointer, int, cstring }),
		-- const char **TextSplit(const char *text, char delimiter, int *count);
		TextSplit = fn(ffi.types.pointer, { cstring, char, ffi.types.pointer }),
		-- void TextAppend(char *text, const char *append, int *position);
		TextAppend = fn(void, { cstring, cstring, ffi.types.pointer }),
		-- int TextFindIndex(const char *text, const char *find);
		TextFindIndex = fn(int, { cstring, cstring }),
		-- const char *TextToUpper(const char *text);
		TextToUpper = fn(cstring, { cstring }),
		-- const char *TextToLower(const char *text);
		TextToLower = fn(cstring, { cstring }),
		-- const char *TextToPascal(const char *text);
		TextToPascal = fn(cstring, { cstring }),
		-- const char *TextToSnake(const char *text);
		TextToSnake = fn(cstring, { cstring }),
		-- const char *TextToCamel(const char *text);
		TextToCamel = fn(cstring, { cstring }),

		-- int TextToInteger(const char *text);
		TextToInteger = fn(int, { cstring }),
		-- float TextToFloat(const char *text);
		TextToFloat = fn(float, { cstring }),
	},
}
