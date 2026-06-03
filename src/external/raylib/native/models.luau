--!strict
--!optimize 2
--!native

local ffi = zune.ffi

local raylib = require("./raylib")

local structs = raylib.structs

local void = ffi.types.void
local int = ffi.types.i32
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
local Matrix = structs.Matrix
local Color = structs.Color
local Rectangle = structs.Rectangle
local Image = structs.Image
local Texture2D = structs.Texture2D
local Ray = structs.Ray
local RayCollision = structs.RayCollision
local BoundingBox = structs.BoundingBox
local Mesh = structs.Mesh
local Material = structs.Material
local Model = structs.Model
local ModelAnimation = structs.ModelAnimation
type Vector2 = raylib.Vector2
type Vector3 = raylib.Vector3
type Vector4 = raylib.Vector4
type Matrix = raylib.Matrix
type Color = raylib.Color
type Rectangle = raylib.Rectangle
type Image = raylib.Image
type Texture2D = raylib.Texture2D
type Ray = raylib.Ray
type RayCollision = raylib.RayCollision
type BoundingBox = raylib.BoundingBox
type Mesh = raylib.Mesh
type Material = raylib.Material
type Model = raylib.Model
type ModelAnimation = raylib.ModelAnimation
type BoneInfo = raylib.BoneInfo
type Transform = raylib.Transform

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	DrawLine3D: (startPos: Vector3, endPos: Vector3, color: Color) -> (),
	DrawPoint3D: (position: Vector3, color: Color) -> (),
	DrawCircle3D: (center: Vector3, radius: float, rotationAxis: Vector3, rotationAngle: float, color: Color) -> (),
	DrawTriangle3D: (v1: Vector3, v2: Vector3, v3: Vector3, color: Color) -> (),
	DrawTriangleStrip3D: (points: FFIPointer, pointCount: int, color: Color) -> (),
	DrawCube: (position: Vector3, width: float, height: float, length: float, color: Color) -> (),
	DrawCubeV: (position: Vector3, size: Vector3, color: Color) -> (),
	DrawCubeWires: (position: Vector3, width: float, height: float, length: float, color: Color) -> (),
	DrawCubeWiresV: (position: Vector3, size: Vector3, color: Color) -> (),
	DrawSphere: (centerPos: Vector3, radius: float, color: Color) -> (),
	DrawSphereEx: (centerPos: Vector3, radius: float, rings: int, slices: int, color: Color) -> (),
	DrawSphereWires: (centerPos: Vector3, radius: float, rings: int, slices: int, color: Color) -> (),
	DrawCylinder: (
		position: Vector3,
		radiusTop: float,
		radiusBottom: float,
		height: float,
		slices: int,
		color: Color
	) -> (),
	DrawCylinderEx: (
		startPos: Vector3,
		endPos: Vector3,
		startRadius: float,
		endRadius: float,
		sides: int,
		color: Color
	) -> (),
	DrawCylinderWires: (
		position: Vector3,
		radiusTop: float,
		radiusBottom: float,
		height: float,
		slices: int,
		color: Color
	) -> (),
	DrawCylinderWiresEx: (
		startPos: Vector3,
		endPos: Vector3,
		startRadius: float,
		endRadius: float,
		sides: int,
		color: Color
	) -> (),
	DrawCapsule: (startPos: Vector3, endPos: Vector3, radius: float, slices: int, rings: int, color: Color) -> (),
	DrawCapsuleWires: (startPos: Vector3, endPos: Vector3, radius: float, slices: int, rings: int, color: Color) -> (),
	DrawPlane: (centerPos: Vector3, size: Vector2, color: Color) -> (),
	DrawRay: (ray: Ray, color: Color) -> (),
	DrawGrid: (slices: int, spacing: float) -> (),
	LoadModel: (fileName: cstring) -> Model,
	LoadModelFromMesh: (mesh: Mesh) -> Model,
	IsModelValid: (model: Model) -> bool,
	UnloadModel: (model: Model) -> (),
	GetModelBoundingBox: (model: Model) -> BoundingBox,
	DrawModel: (model: Model, position: Vector3, scale: float, tint: Color) -> (),
	DrawModelEx: (
		model: Model,
		position: Vector3,
		rotationAxis: Vector3,
		rotationAngle: float,
		scale: Vector3,
		tint: Color
	) -> (),
	DrawModelWires: (model: Model, position: Vector3, scale: float, tint: Color) -> (),
	DrawModelWiresEx: (
		model: Model,
		position: Vector3,
		rotationAxis: Vector3,
		rotationAngle: float,
		scale: Vector3,
		tint: Color
	) -> (),
	DrawBoundingBox: (box: BoundingBox, color: Color) -> (),
	DrawBillboard: (camera: FFIPointer, texture: Texture2D, position: Vector3, scale: float, tint: Color) -> (),
	DrawBillboardRec: (
		camera: FFIPointer,
		texture: Texture2D,
		source: Rectangle,
		position: Vector3,
		size: Vector2,
		tint: Color
	) -> (),
	DrawBillboardPro: (
		camera: FFIPointer,
		texture: Texture2D,
		source: Rectangle,
		position: Vector3,
		up: Vector3,
		size: Vector2,
		origin: Vector2,
		rotation: float,
		tint: Color
	) -> (),
	UploadMesh: (mesh: FFIPointer, dynamic: bool) -> (),
	UpdateMeshBuffer: (mesh: Mesh, index: int, data: FFIPointer, dataSize: int, offset: int) -> (),
	UnloadMesh: (mesh: Mesh) -> (),
	DrawMesh: (mesh: Mesh, material: Material, transform: Matrix) -> (),
	DrawMeshInstanced: (mesh: Mesh, material: Material, transforms: FFIPointer, instances: int) -> (),
	GetMeshBoundingBox: (mesh: Mesh) -> BoundingBox,
	GenMeshTangents: (mesh: FFIPointer) -> (),
	ExportMesh: (mesh: Mesh, fileName: cstring) -> bool,
	ExportMeshAsCode: (mesh: Mesh, fileName: cstring) -> bool,
	GenMeshPoly: (sides: int, radius: float) -> Mesh,
	GenMeshPlane: (width: float, length: float, resX: int, resZ: int) -> Mesh,
	GenMeshCube: (width: float, height: float, length: float) -> Mesh,
	GenMeshSphere: (radius: float, rings: int, slices: int) -> Mesh,
	GenMeshHemiSphere: (radius: float, rings: int, slices: int) -> Mesh,
	GenMeshCylinder: (radius: float, height: float, slices: int) -> Mesh,
	GenMeshCone: (radius: float, height: float, slices: int) -> Mesh,
	GenMeshTorus: (radius: float, size: float, radSeg: int, sides: int) -> Mesh,
	GenMeshKnot: (radius: float, size: float, radSeg: int, sides: int) -> Mesh,
	GenMeshHeightmap: (heightmap: Image, size: Vector3) -> Mesh,
	GenMeshCubicmap: (cubicmap: Image, cubeSize: Vector3) -> Mesh,
	LoadMaterials: (fileName: cstring, materialCount: FFIPointer) -> FFIPointer,
	LoadMaterialDefault: () -> Material,
	IsMaterialValid: (material: Material) -> bool,
	UnloadMaterial: (material: Material) -> (),
	SetMaterialTexture: (material: FFIPointer, mapType: int, texture: Texture2D) -> (),
	SetModelMeshMaterial: (model: FFIPointer, meshId: int, materialId: int) -> (),
	LoadModelAnimations: (fileName: cstring, animCount: FFIPointer) -> FFIPointer,
	UpdateModelAnimation: (model: Model, anim: ModelAnimation, frame: int) -> (),
	IsModelAnimationValid: (model: Model, anim: ModelAnimation) -> bool,
	CheckCollisionSpheres: (center1: Vector3, radius1: float, center2: Vector3, radius2: float) -> bool,
	CheckCollisionBoxes: (box1: BoundingBox, box2: BoundingBox) -> bool,
	CheckCollisionBoxSphere: (box: BoundingBox, center: Vector3, radius: float) -> bool,
	GetRayCollisionSphere: (ray: Ray, center: Vector3, radius: float) -> RayCollision,
	GetRayCollisionBox: (ray: Ray, box: BoundingBox) -> RayCollision,
	GetRayCollisionMesh: (ray: Ray, mesh: Mesh, transform: Matrix) -> RayCollision,
	GetRayCollisionTriangle: (ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3) -> RayCollision,
	GetRayCollisionQuad: (ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> RayCollision,
}

return {
	def = {
		-- void DrawLine3D(Vector3 startPos, Vector3 endPos, Color color);
		DrawLine3D = fn(void, { Vector3, Vector3, Color }),
		-- void DrawPoint3D(Vector3 position, Color color);
		DrawPoint3D = fn(void, { Vector3, Color }),
		-- void DrawCircle3D(Vector3 center, float radius, Vector3 rotationAxis, float rotationAngle, Color color);
		DrawCircle3D = fn(void, { Vector3, float, Vector3, float, Color }),
		-- void DrawTriangle3D(Vector3 v1, Vector3 v2, Vector3 v3, Color color);
		DrawTriangle3D = fn(void, { Vector3, Vector3, Vector3, Color }),
		-- void DrawTriangleStrip3D(const Vector3 *points, int pointCount, Color color);
		DrawTriangleStrip3D = fn(void, { ffi.types.pointer, int, Color }),
		-- void DrawCube(Vector3 position, float width, float height, float length, Color color);
		DrawCube = fn(void, { Vector3, float, float, float, Color }),
		-- void DrawCubeV(Vector3 position, Vector3 size, Color color);
		DrawCubeV = fn(void, { Vector3, Vector3, Color }),
		-- void DrawCubeWires(Vector3 position, float width, float height, float length, Color color);
		DrawCubeWires = fn(void, { Vector3, float, float, float, Color }),
		-- void DrawCubeWiresV(Vector3 position, Vector3 size, Color color);
		DrawCubeWiresV = fn(void, { Vector3, Vector3, Color }),
		-- void DrawSphere(Vector3 centerPos, float radius, Color color);
		DrawSphere = fn(void, { Vector3, float, Color }),
		-- void DrawSphereEx(Vector3 centerPos, float radius, int rings, int slices, Color color);
		DrawSphereEx = fn(void, { Vector3, float, int, int, Color }),
		-- void DrawSphereWires(Vector3 centerPos, float radius, int rings, int slices, Color color);
		DrawSphereWires = fn(void, { Vector3, float, int, int, Color }),
		-- void DrawCylinder(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color);
		DrawCylinder = fn(void, { Vector3, float, float, float, int, Color }),
		-- void DrawCylinderEx(Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color);
		DrawCylinderEx = fn(void, { Vector3, Vector3, float, float, int, Color }),
		-- void DrawCylinderWires(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color);
		DrawCylinderWires = fn(void, { Vector3, float, float, float, int, Color }),
		-- void DrawCylinderWiresEx(Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color);
		DrawCylinderWiresEx = fn(void, { Vector3, Vector3, float, float, int, Color }),
		-- void DrawCapsule(Vector3 startPos, Vector3 endPos, float radius, int slices, int rings, Color color);
		DrawCapsule = fn(void, { Vector3, Vector3, float, int, int, Color }),
		-- void DrawCapsuleWires(Vector3 startPos, Vector3 endPos, float radius, int slices, int rings, Color color);
		DrawCapsuleWires = fn(void, { Vector3, Vector3, float, int, int, Color }),
		-- void DrawPlane(Vector3 centerPos, Vector2 size, Color color);
		DrawPlane = fn(void, { Vector3, Vector2, Color }),
		-- void DrawRay(Ray ray, Color color);
		DrawRay = fn(void, { Ray, Color }),
		-- void DrawGrid(int slices, float spacing);
		DrawGrid = fn(void, { int, float }),
		-- Model LoadModel(const char *fileName);
		LoadModel = fn(Model, { cstring }),
		-- Model LoadModelFromMesh(Mesh mesh);
		LoadModelFromMesh = fn(Model, { Mesh }),
		-- bool IsModelValid(Model model);
		IsModelValid = fn(bool, { Model }),
		-- void UnloadModel(Model model);
		UnloadModel = fn(void, { Model }),
		-- BoundingBox GetModelBoundingBox(Model model);
		GetModelBoundingBox = fn(BoundingBox, { Model }),
		-- void DrawModel(Model model, Vector3 position, float scale, Color tint);
		DrawModel = fn(void, { Model, Vector3, float, Color }),
		-- void DrawModelEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint);
		DrawModelEx = fn(void, { Model, Vector3, Vector3, float, Vector3, Color }),
		-- void DrawModelWires(Model model, Vector3 position, float scale, Color tint);
		DrawModelWires = fn(void, { Model, Vector3, float, Color }),
		-- void DrawModelWiresEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint);
		DrawModelWiresEx = fn(void, { Model, Vector3, Vector3, float, Vector3, Color }),
		-- void DrawBoundingBox(BoundingBox box, Color color);
		DrawBoundingBox = fn(void, { BoundingBox, Color }),
		-- void DrawBillboard(Camera camera, Texture2D texture, Vector3 position, float scale, Color tint);
		DrawBillboard = fn(void, { raylib.ptrs.Camera, Texture2D, Vector3, float, Color }),
		-- void DrawBillboardRec(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector2 size, Color tint);
		DrawBillboardRec = fn(void, { raylib.ptrs.Camera, Texture2D, Rectangle, Vector3, Vector2, Color }),
		-- void DrawBillboardPro(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector3 up, Vector2 size, Vector2 origin, float rotation, Color tint);
		DrawBillboardPro = fn(
			void,
			{ raylib.ptrs.Camera, Texture2D, Rectangle, Vector3, Vector3, Vector2, Vector2, float, Color }
		),
		-- void UploadMesh(Mesh *mesh, bool dynamic);
		UploadMesh = fn(void, { ffi.types.pointer, bool }),
		-- void UpdateMeshBuffer(Mesh mesh, int index, const void *data, int dataSize, int offset);
		UpdateMeshBuffer = fn(void, { Mesh, int, ffi.types.pointer, int, int }),
		-- void UnloadMesh(Mesh mesh);
		UnloadMesh = fn(void, { Mesh }),
		-- void DrawMesh(Mesh mesh, Material material, Matrix transform);
		DrawMesh = fn(void, { Mesh, Material, Matrix }),
		-- void DrawMeshInstanced(Mesh mesh, Material material, const Matrix *transforms, int instances);
		DrawMeshInstanced = fn(void, { Mesh, Material, ffi.types.pointer, int }),
		-- BoundingBox GetMeshBoundingBox(Mesh mesh);
		GetMeshBoundingBox = fn(BoundingBox, { Mesh }),
		-- void GenMeshTangents(Mesh *mesh);
		GenMeshTangents = fn(void, { ffi.types.pointer }),
		-- bool ExportMesh(Mesh mesh, const char *fileName);
		ExportMesh = fn(bool, { Mesh, cstring }),
		-- bool ExportMeshAsCode(Mesh mesh, const char *fileName);
		ExportMeshAsCode = fn(bool, { Mesh, cstring }),
		-- Mesh GenMeshPoly(int sides, float radius);
		GenMeshPoly = fn(Mesh, { int, float }),
		-- Mesh GenMeshPlane(float width, float length, int resX, int resZ);
		GenMeshPlane = fn(Mesh, { float, float, int, int }),
		-- Mesh GenMeshCube(float width, float height, float length);
		GenMeshCube = fn(Mesh, { float, float, float }),
		-- Mesh GenMeshSphere(float radius, int rings, int slices);
		GenMeshSphere = fn(Mesh, { float, int, int }),
		-- Mesh GenMeshHemiSphere(float radius, int rings, int slices);
		GenMeshHemiSphere = fn(Mesh, { float, int, int }),
		-- Mesh GenMeshCylinder(float radius, float height, int slices);
		GenMeshCylinder = fn(Mesh, { float, float, int }),
		-- Mesh GenMeshCone(float radius, float height, int slices);
		GenMeshCone = fn(Mesh, { float, float, int }),
		-- Mesh GenMeshTorus(float radius, float size, int radSeg, int sides);
		GenMeshTorus = fn(Mesh, { float, float, int, int }),
		-- Mesh GenMeshKnot(float radius, float size, int radSeg, int sides);
		GenMeshKnot = fn(Mesh, { float, float, int, int }),
		-- Mesh GenMeshHeightmap(Image heightmap, Vector3 size);
		GenMeshHeightmap = fn(Mesh, { Image, Vector3 }),
		-- Mesh GenMeshCubicmap(Image cubicmap, Vector3 cubeSize);
		GenMeshCubicmap = fn(Mesh, { Image, Vector3 }),
		-- Material *LoadMaterials(const char *fileName, int *materialCount);
		LoadMaterials = fn(ffi.types.pointer, { cstring, ffi.types.pointer }),
		-- Material LoadMaterialDefault(void);
		LoadMaterialDefault = fn(Material, {}),
		-- bool IsMaterialValid(Material material);
		IsMaterialValid = fn(bool, { Material }),
		-- void UnloadMaterial(Material material);
		UnloadMaterial = fn(void, { Material }),
		-- void SetMaterialTexture(Material *material, int mapType, Texture2D texture);
		SetMaterialTexture = fn(void, { ffi.types.pointer, int, Texture2D }),
		-- void SetModelMeshMaterial(Model *model, int meshId, int materialId);
		SetModelMeshMaterial = fn(void, { ffi.types.pointer, int, int }),
		-- ModelAnimation *LoadModelAnimations(const char *fileName, int *animCount);
		LoadModelAnimations = fn(ffi.types.pointer, { cstring, ffi.types.pointer }),
		-- void UpdateModelAnimation(Model model, ModelAnimation anim, int frame);
		UpdateModelAnimation = fn(void, { Model, ModelAnimation, int }),
		-- bool IsModelAnimationValid(Model model, ModelAnimation anim);
		IsModelAnimationValid = fn(bool, { Model, ModelAnimation }),
		-- bool CheckCollisionSpheres(Vector3 center1, float radius1, Vector3 center2, float radius2);
		CheckCollisionSpheres = fn(bool, { Vector3, float, Vector3, float }),
		-- bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2);
		CheckCollisionBoxes = fn(bool, { BoundingBox, BoundingBox }),
		-- bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius);
		CheckCollisionBoxSphere = fn(bool, { BoundingBox, Vector3, float }),
		-- RayCollision GetRayCollisionSphere(Ray ray, Vector3 center, float radius);
		GetRayCollisionSphere = fn(RayCollision, { Ray, Vector3, float }),
		-- RayCollision GetRayCollisionBox(Ray ray, BoundingBox box);
		GetRayCollisionBox = fn(RayCollision, { Ray, BoundingBox }),
		-- RayCollision GetRayCollisionMesh(Ray ray, Mesh mesh, Matrix transform);
		GetRayCollisionMesh = fn(RayCollision, { Ray, Mesh, Matrix }),
		-- RayCollision GetRayCollisionTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3);
		GetRayCollisionTriangle = fn(RayCollision, { Ray, Vector3, Vector3, Vector3 }),
		-- RayCollision GetRayCollisionQuad(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4);
		GetRayCollisionQuad = fn(RayCollision, { Ray, Vector3, Vector3, Vector3, Vector3 }),
	},
}
