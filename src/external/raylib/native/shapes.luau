--!strict
--!optimize 2
--!native

local ffi = zune.ffi

local adapter = require("./raylib")

local structs = adapter.structs

local void = ffi.types.void
local int = ffi.types.i32
local bool = ffi.types.u8
local float = ffi.types.float
type int = number
type bool = number
type float = number
type cstring = string | buffer | FFIPointer

local Vector2 = structs.Vector2
local Color = structs.Color
local Rectangle = structs.Rectangle
local Texture2D = structs.Texture2D
type Vector2 = adapter.Vector2
type Color = adapter.Color
type Rectangle = adapter.Rectangle
type Texture2D = adapter.Texture2D

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	SetShapesTexture: (texture: Texture2D, source: Rectangle) -> (),
	GetShapesTexture: () -> Texture2D,
	GetShapesTextureRectangle: () -> Rectangle,
	DrawPixel: (posX: int, posY: int, color: Color) -> (),
	DrawPixelV: (position: Vector2, color: Color) -> (),
	DrawLine: (startPosX: int, startPosY: int, endPosX: int, endPosY: int, color: Color) -> (),
	DrawLineV: (startPos: Vector2, endPos: Vector2, color: Color) -> (),
	DrawLineEx: (startPos: Vector2, endPos: Vector2, thick: float, color: Color) -> (),
	DrawLineStrip: (points: FFIPointer, pointCount: int, color: Color) -> (),
	DrawLineBezier: (startPos: Vector2, endPos: Vector2, thick: float, color: Color) -> (),
	DrawCircle: (centerX: int, centerY: int, radius: float, color: Color) -> (),
	DrawCircleSector: (
		center: Vector2,
		radius: float,
		startAngle: float,
		endAngle: float,
		segments: int,
		color: Color
	) -> (),
	DrawCircleSectorLines: (
		center: Vector2,
		radius: float,
		startAngle: float,
		endAngle: float,
		segments: int,
		color: Color
	) -> (),
	DrawCircleGradient: (centerX: int, centerY: int, radius: float, inner: Color, outer: Color) -> (),
	DrawCircleV: (center: Vector2, radius: float, color: Color) -> (),
	DrawCircleLines: (centerX: int, centerY: int, radius: float, color: Color) -> (),
	DrawCircleLinesV: (center: Vector2, radius: float, color: Color) -> (),
	DrawEllipse: (centerX: int, centerY: int, radiusH: float, radiusV: float, color: Color) -> (),
	DrawEllipseLines: (centerX: int, centerY: int, radiusH: float, radiusV: float, color: Color) -> (),
	DrawRing: (
		center: Vector2,
		innerRadius: float,
		outerRadius: float,
		startAngle: float,
		endAngle: float,
		segments: int,
		color: Color
	) -> (),
	DrawRingLines: (
		center: Vector2,
		innerRadius: float,
		outerRadius: float,
		startAngle: float,
		endAngle: float,
		segments: int,
		color: Color
	) -> (),
	DrawRectangle: (posX: int, posY: int, width: int, height: int, color: Color) -> (),
	DrawRectangleV: (position: Vector2, size: Vector2, color: Color) -> (),
	DrawRectangleRec: (rec: Rectangle, color: Color) -> (),
	DrawRectanglePro: (rec: Rectangle, origin: Vector2, rotation: float, color: Color) -> (),
	DrawRectangleGradientV: (posX: int, posY: int, width: int, height: int, top: Color, bottom: Color) -> (),
	DrawRectangleGradientH: (posX: int, posY: int, width: int, height: int, left: Color, right: Color) -> (),
	DrawRectangleGradientEx: (
		rec: Rectangle,
		topLeft: Color,
		bottomLeft: Color,
		topRight: Color,
		bottomRight: Color
	) -> (),
	DrawRectangleLines: (posX: int, posY: int, width: int, height: int, color: Color) -> (),
	DrawRectangleLinesEx: (rec: Rectangle, lineThick: float, color: Color) -> (),
	DrawRectangleRounded: (rec: Rectangle, roundness: float, segments: int, color: Color) -> (),
	DrawRectangleRoundedLines: (rec: Rectangle, roundness: float, segments: int, color: Color) -> (),
	DrawRectangleRoundedLinesEx: (
		rec: Rectangle,
		roundness: float,
		segments: int,
		lineThick: float,
		color: Color
	) -> (),
	DrawTriangle: (v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> (),
	DrawTriangleLines: (v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> (),
	DrawTriangleFan: (points: FFIPointer, pointCount: int, color: Color) -> (),
	DrawTriangleStrip: (points: FFIPointer, pointCount: int, color: Color) -> (),
	DrawPoly: (center: Vector2, sides: int, radius: float, rotation: float, color: Color) -> (),
	DrawPolyLines: (center: Vector2, sides: int, radius: float, rotation: float, color: Color) -> (),
	DrawPolyLinesEx: (
		center: Vector2,
		sides: int,
		radius: float,
		rotation: float,
		lineThick: float,
		color: Color
	) -> (),
	DrawSplineLinear: (points: FFIPointer, pointCount: int, thick: float, color: Color) -> (),
	DrawSplineBasis: (points: FFIPointer, pointCount: int, thick: float, color: Color) -> (),
	DrawSplineCatmullRom: (points: FFIPointer, pointCount: int, thick: float, color: Color) -> (),
	DrawSplineBezierQuadratic: (points: FFIPointer, pointCount: int, thick: float, color: Color) -> (),
	DrawSplineBezierCubic: (points: FFIPointer, pointCount: int, thick: float, color: Color) -> (),
	DrawSplineSegmentLinear: (p1: Vector2, p2: Vector2, thick: float, color: Color) -> (),
	DrawSplineSegmentBasis: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float, color: Color) -> (),
	DrawSplineSegmentCatmullRom: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float, color: Color) -> (),
	DrawSplineSegmentBezierQuadratic: (p1: Vector2, c2: Vector2, p3: Vector2, thick: float, color: Color) -> (),
	DrawSplineSegmentBezierCubic: (
		p1: Vector2,
		c2: Vector2,
		c3: Vector2,
		p4: Vector2,
		thick: float,
		color: Color
	) -> (),
	GetSplinePointLinear: (startPos: Vector2, endPos: Vector2, t: float) -> Vector2,
	GetSplinePointBasis: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float) -> Vector2,
	GetSplinePointCatmullRom: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float) -> Vector2,
	GetSplinePointBezierQuad: (p1: Vector2, c2: Vector2, p3: Vector2, t: float) -> Vector2,
	GetSplinePointBezierCubic: (p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: float) -> Vector2,
	CheckCollisionRecs: (rec1: Rectangle, rec2: Rectangle) -> bool,
	CheckCollisionCircles: (center1: Vector2, radius1: float, center2: Vector2, radius2: float) -> bool,
	CheckCollisionCircleRec: (center: Vector2, radius: float, rec: Rectangle) -> bool,
	CheckCollisionCircleLine: (center: Vector2, radius: float, p1: Vector2, p2: Vector2) -> bool,
	CheckCollisionPointRec: (point: Vector2, rec: Rectangle) -> bool,
	CheckCollisionPointCircle: (point: Vector2, center: Vector2, radius: float) -> bool,
	CheckCollisionPointTriangle: (point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> bool,
	CheckCollisionPointLine: (point: Vector2, p1: Vector2, p2: Vector2, threshold: int) -> bool,
	CheckCollisionPointPoly: (point: Vector2, points: FFIPointer, pointCount: int) -> bool,
	CheckCollisionLines: (
		startPos1: Vector2,
		endPos1: Vector2,
		startPos2: Vector2,
		endPos2: Vector2,
		collisionPoint: FFIPointer
	) -> bool,
	GetCollisionRec: (rec1: Rectangle, rec2: Rectangle) -> Rectangle,
}

return {
	def = {
		-- void SetShapesTexture(Texture2D texture, Rectangle source);
		SetShapesTexture = fn(void, { Texture2D, Rectangle }),
		-- Texture2D GetShapesTexture(void);
		GetShapesTexture = fn(Texture2D, {}),
		-- Rectangle GetShapesTextureRectangle(void);
		GetShapesTextureRectangle = fn(Rectangle, {}),

		-- void DrawPixel(int posX, int posY, Color color);
		DrawPixel = fn(void, { int, int, Color }),
		-- void DrawPixelV(Vector2 position, Color color);
		DrawPixelV = fn(void, { Vector2, Color }),
		-- void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);
		DrawLine = fn(void, { int, int, int, int, Color }),
		-- void DrawLineV(Vector2 startPos, Vector2 endPos, Color color);
		DrawLineV = fn(void, { Vector2, Vector2, Color }),
		-- void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color);
		DrawLineEx = fn(void, { Vector2, Vector2, float, Color }),
		-- void DrawLineStrip(const Vector2 *points, int pointCount, Color color);
		DrawLineStrip = fn(void, { ffi.types.pointer, int, Color }),
		-- void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color);
		DrawLineBezier = fn(void, { Vector2, Vector2, float, Color }),
		-- void DrawCircle(int centerX, int centerY, float radius, Color color
		DrawCircle = fn(void, { int, int, float, Color }),
		-- void DrawCircleSector(Vector2 center, float radius, float startAngle, float end
		DrawCircleSector = fn(void, { Vector2, float, float, float, int, Color }),
		-- void DrawCircleSectorLines(Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color);
		DrawCircleSectorLines = fn(void, { Vector2, float, float, float, int, Color }),
		-- void DrawCircleGradient(int centerX, int centerY, float radius, Color inner, Color outer);
		DrawCircleGradient = fn(void, { int, int, float, Color, Color }),
		-- void DrawCircleV(Vector2 center, float radius, Color color);
		DrawCircleV = fn(void, { Vector2, float, Color }),
		-- void DrawCircleLines(int centerX, int centerY, float radius, Color color);
		DrawCircleLines = fn(void, { int, int, float, Color }),
		-- void DrawCircleLinesV(Vector2 center, float radius, Color color);
		DrawCircleLinesV = fn(void, { Vector2, float, Color }),
		-- void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color);
		DrawEllipse = fn(void, { int, int, float, float, Color }),
		-- void DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, Color color);
		DrawEllipseLines = fn(void, { int, int, float, float, Color }),
		-- void DrawRing(Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color);
		DrawRing = fn(void, { Vector2, float, float, float, float, int, Color }),
		-- void DrawRingLines(Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color);
		DrawRingLines = fn(void, { Vector2, float, float, float, float, int, Color }),
		-- void DrawRectangle(int posX, int posY, int width, int height, Color color);
		DrawRectangle = fn(void, { int, int, int, int, Color }),
		-- void DrawRectangleV(Vector2 position, Vector2 size, Color color);
		DrawRectangleV = fn(void, { Vector2, Vector2, Color }),
		-- void DrawRectangleRec(Rectangle rec, Color color);
		DrawRectangleRec = fn(void, { Rectangle, Color }),
		-- void DrawRectanglePro(Rectangle rec, Vector2 origin, float rotation, Color color);
		DrawRectanglePro = fn(void, { Rectangle, Vector2, float, Color }),
		-- void DrawRectangleGradientV(int posX, int posY, int width, int height, Color top, Color bottom);
		DrawRectangleGradientV = fn(void, { int, int, int, int, Color, Color }),
		-- void DrawRectangleGradientH(int posX, int posY, int width, int height, Color left, Color right);
		DrawRectangleGradientH = fn(void, { int, int, int, int, Color, Color }),
		-- void DrawRectangleGradientEx(Rectangle rec, Color topLeft, Color bottomLeft, Color topRight, Color bottomRight);
		DrawRectangleGradientEx = fn(void, { Rectangle, Color, Color, Color, Color }),
		-- void DrawRectangleLines(int posX, int posY, int width, int height, Color color);
		DrawRectangleLines = fn(void, { int, int, int, int, Color }),
		-- void DrawRectangleLinesEx(Rectangle rec, float lineThick, Color color);
		DrawRectangleLinesEx = fn(void, { Rectangle, float, Color }),
		-- void DrawRectangleRounded(Rectangle rec, float roundness, int segments, Color color);
		DrawRectangleRounded = fn(void, { Rectangle, float, int, Color }),
		-- void DrawRectangleRoundedLines(Rectangle rec, float roundness, int segments, Color color);
		DrawRectangleRoundedLines = fn(void, { Rectangle, float, int, Color }),
		-- void DrawRectangleRoundedLinesEx(Rectangle rec, float roundness, int segments, float lineThick, Color color);
		DrawRectangleRoundedLinesEx = fn(void, { Rectangle, float, int, float, Color }),
		-- void DrawTriangle(Vector2 v1, Vector v2, Vector2 v3, Color color);
		DrawTriangle = fn(void, { Vector2, Vector2, Vector2, Color }),
		-- void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color);
		DrawTriangleLines = fn(void, { Vector2, Vector2, Vector2, Color }),
		-- void DrawTriangleFan(const Vector2 *points, int pointCount, Color color);
		DrawTriangleFan = fn(void, { ffi.types.pointer, int, Color }),
		-- void DrawTriangleStrip(const Vector2 *points, int pointCount, Color color);
		DrawTriangleStrip = fn(void, { ffi.types.pointer, int, Color }),
		-- void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color);
		DrawPoly = fn(void, { Vector2, int, float, float, Color }),
		-- void DrawPolyLines(Vector2 center, int sides, float radius, float rotation, Color color);
		DrawPolyLines = fn(void, { Vector2, int, float, float, Color }),
		-- void DrawPolyLinesEx(Vector2 center, int sides, float radius, float rotation, float lineThick, Color color);
		DrawPolyLinesEx = fn(void, { Vector2, int, float, float, float, Color }),

		-- void DrawSplineLinear(const Vector2 *points, int pointCount, float thick, Color color);
		DrawSplineLinear = fn(void, { ffi.types.pointer, int, float, Color }),
		-- void DrawSplineBasis(const Vector2 *points, int pointCount, float thick, Color color);
		DrawSplineBasis = fn(void, { ffi.types.pointer, int, float, Color }),
		-- void DrawSplineCatmullRom(const Vector2 *points, int pointCount, float thick, Color color);
		DrawSplineCatmullRom = fn(void, { ffi.types.pointer, int, float, Color }),
		-- void DrawSplineBezierQuadratic(const Vector2 *points, int pointCount, float thick, Color color);
		DrawSplineBezierQuadratic = fn(void, { ffi.types.pointer, int, float, Color }),
		-- void DrawSplineBezierCubic(const Vector2 *points, int pointCount, float thick, Color color);
		DrawSplineBezierCubic = fn(void, { ffi.types.pointer, int, float, Color }),
		-- void DrawSplineSegmentLinear(Vector2 p1, Vector2 p2, float thick, Color color);
		DrawSplineSegmentLinear = fn(void, { Vector2, Vector2, float, Color }),
		-- void DrawSplineSegmentBasis(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, float thick, Color color);
		DrawSplineSegmentBasis = fn(void, { Vector2, Vector2, Vector2, Vector2, float, Color }),
		-- void DrawSplineSegmentCatmullRom(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, float thick, Color color);
		DrawSplineSegmentCatmullRom = fn(void, { Vector2, Vector2, Vector2, Vector2, float, Color }),
		-- void DrawSplineSegmentBezierQuadratic(Vector2 p1, Vector2 c2, Vector2 p3, float thick, Color color);
		DrawSplineSegmentBezierQuadratic = fn(void, { Vector2, Vector2, Vector2, float, Color }),
		-- void DrawSplineSegmentBezierCubic(Vector2 p1, Vector2 c2, Vector2 c3, Vector2 p4, float thick, Color color);
		DrawSplineSegmentBezierCubic = fn(void, { Vector2, Vector2, Vector2, Vector2, float, Color }),

		-- Vector2 GetSplinePointLinear(Vector2 startPos, Vector2 endPos, float t);
		GetSplinePointLinear = fn(Vector2, { Vector2, Vector2, float }),
		-- Vector2 GetSplinePointBasis(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, float t);
		GetSplinePointBasis = fn(Vector2, { Vector2, Vector2, Vector2, Vector2, float }),
		-- Vector2 GetSplinePointCatmullRom(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, float t);
		GetSplinePointCatmullRom = fn(Vector2, { Vector2, Vector2, Vector2, Vector2, float }),
		-- Vector2 GetSplinePointBezierQuad(Vector2 p1, Vector2 c2, Vector2 p3, float t);
		GetSplinePointBezierQuad = fn(Vector2, { Vector2, Vector2, Vector2, float }),
		-- Vector2 GetSplinePointBezierCubic(Vector2 p1, Vector2 c2, Vector2 c3, Vector2 p4, float t);
		GetSplinePointBezierCubic = fn(Vector2, { Vector2, Vector2, Vector2, Vector2, float }),

		-- bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2);
		CheckCollisionRecs = fn(bool, { Rectangle, Rectangle }),
		-- bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2);
		CheckCollisionCircles = fn(bool, { Vector2, float, Vector2, float }),
		-- bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec);
		CheckCollisionCircleRec = fn(bool, { Vector2, float, Rectangle }),
		-- bool CheckCollisionCircleLine(Vector2 center, float radius, Vector2 p1, Vector2 p2);
		CheckCollisionCircleLine = fn(bool, { Vector2, float, Vector2, Vector2 }),
		-- bool CheckCollisionPointRec(Vector2 point, Rectangle rec);
		CheckCollisionPointRec = fn(bool, { Vector2, Rectangle }),
		-- bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius);
		CheckCollisionPointCircle = fn(bool, { Vector2, Vector2, float }),
		-- bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3);
		CheckCollisionPointTriangle = fn(bool, { Vector2, Vector2, Vector2, Vector2 }),
		-- bool CheckCollisionPointLine(Vector2 point, Vector2 p1, Vector2 p2, int threshold);
		CheckCollisionPointLine = fn(bool, { Vector2, Vector2, Vector2, int }),
		-- bool CheckCollisionPointPoly(Vector2 point, const Vector2 *points, int pointCount);
		CheckCollisionPointPoly = fn(bool, { Vector2, ffi.types.pointer, int }),
		-- bool CheckCollisionLines(Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2 *collisionPoint);
		CheckCollisionLines = fn(bool, { Vector2, Vector2, Vector2, Vector2, ffi.types.pointer }),
		-- Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2);
		GetCollisionRec = fn(Rectangle, { Rectangle, Rectangle }),
	},
}
