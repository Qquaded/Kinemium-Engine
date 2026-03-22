local ffi = zune.ffi
local rlstructs = require("@raylibstructs")

-- Type aliases for FFI
type int = number
type float = number
type bool = boolean
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)
type RayColor = typeof(rlstructs.structs.Color:new({}))
type RayImage = typeof(rlstructs.structs.Image:new({}))
type RayVector3 = vector
type RayBoundingBox = typeof(rlstructs.structs.BoundingBox:new({}))

-- Import struct types
local structs = require("./structs")
type R3D_AlbedoMap = structs.R3D_AlbedoMap
type R3D_AmbientMap = structs.R3D_AmbientMap
type R3D_Animation = structs.R3D_Animation
type R3D_AnimationChannel = structs.R3D_AnimationChannel
type R3D_AnimationLib = structs.R3D_AnimationLib
type R3D_AnimationPlayer = structs.R3D_AnimationPlayer
type R3D_AnimationState = structs.R3D_AnimationState
type R3D_AnimationTrack = structs.R3D_AnimationTrack
type R3D_BoneInfo = structs.R3D_BoneInfo
type R3D_Cubemap = structs.R3D_Cubemap
type R3D_CubemapSky = structs.R3D_CubemapSky
type R3D_Decal = structs.R3D_Decal
type R3D_EmissionMap = structs.R3D_EmissionMap
type R3D_EnvAmbient = structs.R3D_EnvAmbient
type R3D_EnvBackground = structs.R3D_EnvBackground
type R3D_EnvBloom = structs.R3D_EnvBloom
type R3D_EnvColor = structs.R3D_EnvColor
type R3D_EnvDoF = structs.R3D_EnvDoF
type R3D_EnvFog = structs.R3D_EnvFog
type R3D_EnvSSAO = structs.R3D_EnvSSAO
type R3D_EnvSSIL = structs.R3D_EnvSSIL
type R3D_EnvSSR = structs.R3D_EnvSSR
type R3D_EnvTonemap = structs.R3D_EnvTonemap
type R3D_Environment = structs.R3D_Environment
type R3D_InstanceBuffer = structs.R3D_InstanceBuffer
type R3D_Material = structs.R3D_Material
type R3D_Mesh = structs.R3D_Mesh
type R3D_MeshData = structs.R3D_MeshData
type R3D_Model = structs.R3D_Model
type R3D_NormalMap = structs.R3D_NormalMap
type R3D_OrmMap = structs.R3D_OrmMap
type R3D_Skeleton = structs.R3D_Skeleton
type R3D_Vertex = structs.R3D_Vertex

export type Fns = {
	R3D_Begin: (camera: FFIPointer) -> (),
	R3D_BeginCluster: (aabb: FFIPointer) -> (),
	R3D_BeginEx: (target: FFIPointer, camera: FFIPointer) -> (),
	R3D_CalculateAnimationPlayerModelPose: (player: FFIPointer) -> (),
	R3D_CalculateAnimationPlayerPose: (player: FFIPointer) -> (),
	R3D_CalculateMeshDataBoundingBox: (meshData: R3D_MeshData) -> FFIPointer,
	R3D_Close: () -> (),
	R3D_CreateLight: (type: FFIPointer) -> FFIPointer,
	R3D_CreateProbe: (flags: FFIPointer) -> FFIPointer,
	R3D_DestroyLight: (id: int) -> (),
	R3D_DestroyProbe: (id: FFIPointer) -> (),
	R3D_DisableLayers: (bitfield: FFIPointer) -> (),
	R3D_DisableShadow: (id: FFIPointer) -> (),
	R3D_DrawAnimatedModel: (model: R3D_Model, player: R3D_AnimationPlayer, position: FFIPointer, scale: float) -> (),
	R3D_DrawAnimatedModelEx: (
		model: R3D_Model,
		player: R3D_AnimationPlayer,
		position: FFIPointer,
		rotation: FFIPointer,
		scale: FFIPointer
	) -> (),
	R3D_DrawAnimatedModelInstanced: (
		model: R3D_Model,
		player: R3D_AnimationPlayer,
		instances: R3D_InstanceBuffer,
		count: int
	) -> (),
	R3D_DrawAnimatedModelInstancedEx: (
		model: R3D_Model,
		player: R3D_AnimationPlayer,
		instances: R3D_InstanceBuffer,
		count: int,
		transform: FFIPointer
	) -> (),
	R3D_DrawAnimatedModelPro: (model: R3D_Model, player: R3D_AnimationPlayer, transform: FFIPointer) -> (),
	R3D_DrawDecal: (decal: R3D_Decal, position: FFIPointer, scale: float) -> (),
	R3D_DrawDecalEx: (decal: R3D_Decal, position: FFIPointer, rotation: FFIPointer, scale: FFIPointer) -> (),
	R3D_DrawDecalInstanced: (decal: R3D_Decal, instances: R3D_InstanceBuffer, count: int) -> (),
	R3D_DrawDecalInstancedEx: (
		decal: R3D_Decal,
		instances: R3D_InstanceBuffer,
		count: int,
		transform: FFIPointer
	) -> (),
	R3D_DrawDecalPro: (decal: R3D_Decal, transform: FFIPointer) -> (),
	R3D_DrawLightShape: (id: int) -> (),
	R3D_DrawMesh: (mesh: R3D_Mesh, material: R3D_Material, position: FFIPointer, scale: float) -> (),
	R3D_DrawMeshEx: (
		mesh: R3D_Mesh,
		material: R3D_Material,
		position: FFIPointer,
		rotation: FFIPointer,
		scale: FFIPointer
	) -> (),
	R3D_DrawMeshInstanced: (mesh: R3D_Mesh, material: R3D_Material, instances: R3D_InstanceBuffer, count: int) -> (),
	R3D_DrawMeshInstancedEx: (
		mesh: R3D_Mesh,
		material: R3D_Material,
		instances: R3D_InstanceBuffer,
		count: int,
		transform: FFIPointer
	) -> (),
	R3D_DrawMeshPro: (mesh: R3D_Mesh, material: R3D_Material, transform: FFIPointer) -> (),
	R3D_DrawModel: (model: R3D_Model, position: FFIPointer, scale: float) -> (),
	R3D_DrawModelEx: (model: R3D_Model, position: FFIPointer, rotation: FFIPointer, scale: FFIPointer) -> (),
	R3D_DrawModelInstanced: (model: R3D_Model, instances: R3D_InstanceBuffer, count: int) -> (),
	R3D_DrawModelInstancedEx: (
		model: R3D_Model,
		instances: R3D_InstanceBuffer,
		count: int,
		transform: FFIPointer
	) -> (),
	R3D_DrawModelPro: (model: R3D_Model, transform: FFIPointer) -> (),
	R3D_EnableLayers: (bitfield: FFIPointer) -> (),
	R3D_EnableShadow: (id: FFIPointer) -> (),
	R3D_End: () -> (),
	R3D_EndCluster: () -> (),
	R3D_GenAmbientMap: (cubemap: R3D_Cubemap, flags: FFIPointer) -> R3D_AmbientMap,
	R3D_GenMeshCube: (width: float, height: float, length: float) -> R3D_Mesh,
	R3D_GenMeshCubeEx: (width: float, height: float, length: float, resX: int, resY: int, resZ: int) -> R3D_Mesh,
	R3D_GenMeshCubicmap: (cubicmap: FFIPointer, cubeSize: FFIPointer) -> R3D_Mesh,
	R3D_GenMeshCylinder: (bottomRadius: float, topRadius: float, height: float, slices: int) -> R3D_Mesh,
	R3D_GenMeshDataCube: (width: float, height: float, length: float) -> R3D_MeshData,
	R3D_GenMeshDataCubeEx: (
		width: float,
		height: float,
		length: float,
		resX: int,
		resY: int,
		resZ: int
	) -> R3D_MeshData,
	R3D_GenMeshDataCubicmap: (cubicmap: FFIPointer, cubeSize: FFIPointer) -> R3D_MeshData,
	R3D_GenMeshDataHeightmap: (heightmap: FFIPointer, size: FFIPointer) -> R3D_MeshData,
	R3D_GenMeshDataHemiSphere: (radius: float, rings: int, slices: int) -> R3D_MeshData,
	R3D_GenMeshDataKnot: (radius: float, size: float, radSeg: int, sides: int) -> R3D_MeshData,
	R3D_GenMeshDataNormals: (meshData: FFIPointer) -> (),
	R3D_GenMeshDataPlane: (width: float, length: float, resX: int, resZ: int) -> R3D_MeshData,
	R3D_GenMeshDataPoly: (sides: int, radius: float, frontDir: FFIPointer) -> R3D_MeshData,
	R3D_GenMeshDataQuad: (width: float, length: float, resX: int, resZ: int, frontDir: FFIPointer) -> R3D_MeshData,
	R3D_GenMeshDataSphere: (radius: float, rings: int, slices: int) -> R3D_MeshData,
	R3D_GenMeshDataTangents: (meshData: FFIPointer) -> (),
	R3D_GenMeshDataTorus: (radius: float, size: float, radSeg: int, sides: int) -> R3D_MeshData,
	R3D_GenMeshDataUVsCylindrical: (meshData: FFIPointer) -> (),
	R3D_GenMeshDataUVsPlanar: (meshData: FFIPointer, uvScale: FFIPointer, axis: FFIPointer) -> (),
	R3D_GenMeshDataUVsSpherical: (meshData: FFIPointer) -> (),
	R3D_GenMeshHeightmap: (heightmap: FFIPointer, size: FFIPointer) -> R3D_Mesh,
	R3D_GenMeshHemiSphere: (radius: float, rings: int, slices: int) -> R3D_Mesh,
	R3D_GenMeshKnot: (radius: float, size: float, radSeg: int, sides: int) -> R3D_Mesh,
	R3D_GenMeshPlane: (width: float, length: float, resX: int, resZ: int) -> R3D_Mesh,
	R3D_GenMeshPoly: (sides: int, radius: float, frontDir: FFIPointer) -> R3D_Mesh,
	R3D_GenMeshQuad: (width: float, length: float, resX: int, resZ: int, frontDir: FFIPointer) -> R3D_Mesh,
	R3D_GenMeshSphere: (radius: float, rings: int, slices: int) -> R3D_Mesh,
	R3D_GenMeshTorus: (radius: float, size: float, radSeg: int, sides: int) -> R3D_Mesh,
	R3D_GetActiveLayers: () -> FFIPointer,
	R3D_GetAnimation: (animLib: R3D_AnimationLib, name: cstring) -> FFIPointer,
	R3D_GetAnimationIndex: (animLib: R3D_AnimationLib, name: cstring) -> int,
	R3D_GetAnimationLoop: (player: R3D_AnimationPlayer, animIndex: int) -> bool,
	R3D_GetAnimationSpeed: (player: R3D_AnimationPlayer, animIndex: int) -> float,
	R3D_GetAnimationTime: (player: R3D_AnimationPlayer, animIndex: int) -> float,
	R3D_GetAspectMode: () -> FFIPointer,
	R3D_GetBlackTexture: () -> FFIPointer,
	R3D_GetBufferDepth: () -> FFIPointer,
	R3D_GetBufferNormal: () -> FFIPointer,
	R3D_GetDefaultMaterial: () -> R3D_Material,
	R3D_GetDownscaleMode: () -> FFIPointer,
	R3D_GetEnvironment: () -> FFIPointer,
	R3D_GetLightAttenuation: (id: int) -> float,
	R3D_GetLightBoundingBox: (light: int) -> RayBoundingBox,
	R3D_GetLightColor: (id: int) -> RayColor,
	R3D_GetLightColorV: (id: int) -> RayVector3,
	R3D_GetLightDirection: (id: int) -> RayVector3,
	R3D_GetLightEnergy: (id: int) -> float,
	R3D_GetLightInnerCutOff: (id: int) -> float,
	R3D_GetLightOuterCutOff: (id: int) -> float,
	R3D_GetLightPosition: (id: int) -> RayVector3,
	R3D_GetLightRange: (id: int) -> float,
	R3D_GetLightSpecular: (id: int) -> float,
	R3D_GetLightType: (id: int) -> int,
	R3D_GetMatrixInvProjection: () -> FFIPointer,
	R3D_GetMatrixInvView: () -> FFIPointer,
	R3D_GetMatrixProjection: () -> FFIPointer,
	R3D_GetMatrixView: () -> FFIPointer,
	R3D_GetNormalTexture: () -> FFIPointer,
	R3D_GetOutputMode: () -> FFIPointer,
	R3D_GetProbeFalloff: (id: FFIPointer) -> float,
	R3D_GetProbeInterior: (id: FFIPointer) -> bool,
	R3D_GetProbePosition: (id: FFIPointer) -> FFIPointer,
	R3D_GetProbeRange: (id: FFIPointer) -> float,
	R3D_GetProbeShadows: (id: FFIPointer) -> bool,
	R3D_GetProbeUpdateMode: (id: FFIPointer) -> FFIPointer,
	R3D_GetResolution: (width: FFIPointer, height: FFIPointer) -> (),
	R3D_GetShadowDepthBias: (id: int) -> float,
	R3D_GetShadowSlopeBias: (id: int) -> float,
	R3D_GetShadowSoftness: (id: int) -> float,
	R3D_GetShadowUpdateFrequency: (id: int) -> int,
	R3D_GetShadowUpdateMode: (id: int) -> int,
	R3D_GetSkeletonBone: (skeleton: R3D_Skeleton, boneName: cstring) -> FFIPointer,
	R3D_GetSkeletonBoneIndex: (skeleton: R3D_Skeleton, boneName: cstring) -> int,
	R3D_GetUpscaleMode: () -> FFIPointer,
	R3D_GetWhiteTexture: () -> FFIPointer,
	R3D_Init: (resWidth: int, resHeight: int) -> (),
	R3D_IsAABBInFrustum: (aabb: FFIPointer) -> bool,
	R3D_IsAnimationPlayerValid: (player: R3D_AnimationPlayer) -> bool,
	R3D_IsAnimationPlaying: (player: R3D_AnimationPlayer, animIndex: int) -> bool,
	R3D_IsLightActive: (id: int) -> bool,
	R3D_IsLightExist: (id: int) -> bool,
	R3D_IsMeshDataValid: (meshData: R3D_MeshData) -> bool,
	R3D_IsMeshValid: (mesh: R3D_Mesh) -> bool,
	R3D_IsOBBInFrustum: (aabb: FFIPointer, transform: FFIPointer) -> bool,
	R3D_IsProbeActive: (id: FFIPointer) -> bool,
	R3D_IsProbeExist: (id: FFIPointer) -> bool,
	R3D_IsShadowEnabled: (id: int) -> bool,
	R3D_IsSkeletonValid: (skeleton: R3D_Skeleton) -> bool,
	R3D_IsSphereInFrustum: (position: FFIPointer, radius: float) -> bool,
	R3D_LightLookAt: (id: int, position: RayVector3, target: RayVector3) -> (),
	R3D_LoadAlbedoMap: (fileName: cstring, color: RayColor) -> R3D_AlbedoMap,
	R3D_LoadAlbedoMapFromMemory: (
		fileType: cstring,
		fileData: FFIPointer,
		dataSize: int,
		color: RayColor
	) -> R3D_AlbedoMap,
	R3D_LoadAmbientMap: (fileName: cstring, layout: FFIPointer, flags: FFIPointer) -> R3D_AmbientMap,
	R3D_LoadAmbientMapFromImage: (image: FFIPointer, layout: FFIPointer, flags: FFIPointer) -> R3D_AmbientMap,
	R3D_LoadAnimationLib: (filePath: cstring) -> R3D_AnimationLib,
	R3D_LoadAnimationLibFromMemory: (data: FFIPointer, size: int, hint: cstring) -> R3D_AnimationLib,
	R3D_LoadAnimationPlayer: (skeleton: R3D_Skeleton, animLib: R3D_AnimationLib) -> R3D_AnimationPlayer,
	R3D_LoadCubemap: (fileName: cstring, layout: int) -> R3D_Cubemap,
	R3D_LoadCubemapFromImage: (image: RayImage, layout: int) -> R3D_Cubemap,
	R3D_LoadEmissionMap: (fileName: cstring, color: RayColor, energy: float) -> R3D_EmissionMap,
	R3D_LoadEmissionMapFromMemory: (
		fileType: cstring,
		fileData: FFIPointer,
		dataSize: int,
		color: RayColor,
		energy: float
	) -> R3D_EmissionMap,
	R3D_LoadInstanceBuffer: (capacity: int, flags: int) -> R3D_InstanceBuffer,
	R3D_LoadMesh: (type: int, data: R3D_MeshData, aabb: FFIPointer, usage: int) -> R3D_Mesh,
	R3D_LoadModel: (filePath: cstring) -> R3D_Model,
	R3D_LoadModelFromMemory: (data: FFIPointer, size: int, hint: cstring) -> R3D_Model,
	R3D_LoadNormalMap: (fileName: cstring, scale: float) -> R3D_NormalMap,
	R3D_LoadNormalMapFromMemory: (
		fileType: cstring,
		fileData: FFIPointer,
		dataSize: int,
		scale: float
	) -> R3D_NormalMap,
	R3D_LoadOrmMap: (fileName: cstring, occlusion: float, roughness: float, metalness: float) -> R3D_OrmMap,
	R3D_LoadOrmMapFromMemory: (
		fileType: cstring,
		fileData: FFIPointer,
		dataSize: int,
		occlusion: float,
		roughness: float,
		metalness: float
	) -> R3D_OrmMap,
	R3D_LoadSkeleton: (filePath: cstring) -> R3D_Skeleton,
	R3D_MapInstances: (buffer: R3D_InstanceBuffer, flag: int) -> FFIPointer,
	R3D_MergeMeshData: (a: R3D_MeshData, b: R3D_MeshData) -> R3D_MeshData,
	R3D_PauseAnimation: (player: FFIPointer, animIndex: int) -> (),
	R3D_PlayAnimation: (player: FFIPointer, animIndex: int) -> (),
	R3D_RewindAnimation: (player: FFIPointer, animIndex: int) -> (),
	R3D_RotateMeshData: (meshData: FFIPointer, rotation: FFIPointer) -> (),
	R3D_ScaleMeshData: (meshData: FFIPointer, scale: FFIPointer) -> (),
	R3D_SetActiveLayers: (bitfield: FFIPointer) -> (),
	R3D_SetAnimationLoop: (player: FFIPointer, animIndex: int, loop: bool) -> (),
	R3D_SetAnimationSpeed: (player: FFIPointer, animIndex: int, speed: float) -> (),
	R3D_SetAnimationTime: (player: FFIPointer, animIndex: int, time: float) -> (),
	R3D_SetAspectMode: (mode: FFIPointer) -> (),
	R3D_SetColorSpace: (space: FFIPointer) -> (),
	R3D_SetDefaultMaterial: (material: R3D_Material) -> (),
	R3D_SetDownscaleMode: (mode: FFIPointer) -> (),
	R3D_SetEnvironment: (env: FFIPointer) -> (),
	R3D_SetLightActive: (id: int, active: bool) -> (),
	R3D_SetLightAttenuation: (id: int, attenuation: float) -> (),
	R3D_SetLightColor: (id: int, color: RayColor) -> (),
	R3D_SetLightColorV: (id: int, color: RayVector3) -> (),
	R3D_SetLightDirection: (id: int, direction: RayVector3) -> (),
	R3D_SetLightEnergy: (id: int, energy: float) -> (),
	R3D_SetLightInnerCutOff: (id: int, degrees: float) -> (),
	R3D_SetLightOuterCutOff: (id: int, degrees: float) -> (),
	R3D_SetLightPosition: (id: int, position: RayVector3) -> (),
	R3D_SetLightRange: (id: int, range: float) -> (),
	R3D_SetLightSpecular: (id: int, specular: float) -> (),
	R3D_SetOutputMode: (mode: FFIPointer) -> (),
	R3D_SetProbeActive: (id: FFIPointer, active: bool) -> (),
	R3D_SetProbeFalloff: (id: FFIPointer, falloff: float) -> (),
	R3D_SetProbeInterior: (id: FFIPointer, active: bool) -> (),
	R3D_SetProbePosition: (id: FFIPointer, position: FFIPointer) -> (),
	R3D_SetProbeRange: (id: FFIPointer, range: float) -> (),
	R3D_SetProbeShadows: (id: FFIPointer, active: bool) -> (),
	R3D_SetProbeUpdateMode: (id: FFIPointer, mode: FFIPointer) -> (),
	R3D_SetShadowDepthBias: (id: int, value: float) -> (),
	R3D_SetShadowSlopeBias: (id: int, value: float) -> (),
	R3D_SetShadowSoftness: (id: int, softness: float) -> (),
	R3D_SetShadowUpdateFrequency: (id: int, msec: int) -> (),
	R3D_SetShadowUpdateMode: (id: int, mode: int) -> (),
	R3D_SetTextureFilter: (filter: FFIPointer) -> (),
	R3D_SetUpscaleMode: (mode: FFIPointer) -> (),
	R3D_StopAnimation: (player: FFIPointer, animIndex: int) -> (),
	R3D_ToggleLight: (id: int) -> (),
	R3D_TranslateMeshData: (meshData: FFIPointer, translation: FFIPointer) -> (),
	R3D_UnloadAlbedoMap: (map: R3D_AlbedoMap) -> (),
	R3D_UnloadAmbientMap: (ambientMap: R3D_AmbientMap) -> (),
	R3D_UnloadAnimationLib: (animLib: R3D_AnimationLib) -> (),
	R3D_UnloadAnimationPlayer: (player: R3D_AnimationPlayer) -> (),
	R3D_UnloadCubemap: (cubemap: R3D_Cubemap) -> (),
	R3D_UnloadDecalMaps: (decal: R3D_Decal) -> (),
	R3D_UnloadEmissionMap: (map: R3D_EmissionMap) -> (),
	R3D_UnloadInstanceBuffer: (buffer: R3D_InstanceBuffer) -> (),
	R3D_UnloadMaterial: (material: R3D_Material) -> (),
	R3D_UnloadMesh: (mesh: R3D_Mesh) -> (),
	R3D_UnloadMeshData: (meshData: R3D_MeshData) -> (),
	R3D_UnloadModel: (model: R3D_Model, unloadMaterials: bool) -> (),
	R3D_UnloadNormalMap: (map: R3D_NormalMap) -> (),
	R3D_UnloadOrmMap: (map: R3D_OrmMap) -> (),
	R3D_UnloadSkeleton: (skeleton: R3D_Skeleton) -> (),
	R3D_UnmapInstances: (buffer: R3D_InstanceBuffer, flags: int) -> (),
	R3D_UpdateAmbientMap: (ambientMap: R3D_AmbientMap, cubemap: R3D_Cubemap) -> (),
	R3D_UpdateAnimationPlayer: (player: FFIPointer, dt: float) -> (),
	R3D_UpdateMesh: (mesh: FFIPointer, data: R3D_MeshData, aabb: FFIPointer) -> bool,
	R3D_SetResolution: (width: int, height: int) -> (),
	R3D_UpdateShadowMap: (id: int) -> (),
	R3D_UploadAnimationPlayerPose: (player: FFIPointer) -> (),
	R3D_UploadInstances: (
		buffer: R3D_InstanceBuffer,
		flag: int,
		offset: int,
		count: int,
		data: FFIPointer
	) -> (),
}

local funcs = {
	R3D_LoadAmbientMap = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_LoadAmbientMapFromImage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_GenAmbientMap = { returns = structs.R3D_AmbientMap, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UnloadAmbientMap = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_UpdateAmbientMap = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadAnimationLib = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadAnimationLibFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_UnloadAnimationLib = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetAnimationIndex = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetAnimation = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadAnimationPlayer = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UnloadAnimationPlayer = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsAnimationPlayerValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_IsAnimationPlaying = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_PlayAnimation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_PauseAnimation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_StopAnimation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_RewindAnimation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_GetAnimationTime = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_SetAnimationTime = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32, ffi.types.float } },
	R3D_GetAnimationSpeed = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_SetAnimationSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32, ffi.types.float } },
	R3D_GetAnimationLoop = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_SetAnimationLoop = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32, ffi.types.u8 } },
	R3D_Init = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_Close = { returns = ffi.types.void, args = {} },
	R3D_GetResolution = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_SetResolution = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_GetAspectMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetAspectMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetUpscaleMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetUpscaleMode = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetDownscaleMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetDownscaleMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetOutputMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetOutputMode = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_SetTextureFilter = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetColorSpace = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetActiveLayers = { returns = ffi.types.pointer, args = {} },
	R3D_SetActiveLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_EnableLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_DisableLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_LoadCubemap = { returns = structs.R3D_Cubemap, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_LoadCubemapFromImage = { returns = structs.R3D_Cubemap, args = { rlstructs.structs.Image, ffi.types.i32 } },
	R3D_UnloadCubemap = { returns = ffi.types.void, args = { structs.R3D_Cubemap } },
	R3D_UnloadDecalMaps = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_Begin = { returns = ffi.types.void, args = { rlstructs.structs.Camera3D } },
	R3D_BeginEx = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_End = { returns = ffi.types.void, args = {} },
	R3D_BeginCluster = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_EndCluster = { returns = ffi.types.void, args = {} },
	R3D_DrawMesh = {
		returns = ffi.types.void,
		args = { structs.R3D_Mesh, structs.R3D_Material, ffi.types.pointer, ffi.types.float },
	},
	R3D_DrawMeshEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawMeshPro = {
		returns = ffi.types.void,
		args = { structs.R3D_Mesh, structs.R3D_Material, rlstructs.structs.Matrix },
	},
	R3D_DrawMeshInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawMeshInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	R3D_DrawModel = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
	R3D_DrawModelEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawModelPro = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_DrawModelInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawModelInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	R3D_DrawAnimatedModel = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	R3D_DrawAnimatedModelEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawAnimatedModelPro = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawAnimatedModelInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawAnimatedModelInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	R3D_DrawDecal = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
	R3D_DrawDecalEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawDecalPro = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_DrawDecalInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawDecalInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	R3D_GetEnvironment = { returns = ffi.types.pointer, args = {} },
	R3D_SetEnvironment = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_LoadInstanceBuffer = { returns = structs.R3D_InstanceBuffer, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_UnloadInstanceBuffer = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_UploadInstances = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_SetAntiAliasingMode = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_MapInstances = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_UnmapInstances = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_CreateLight = { returns = ffi.types.i32, args = { ffi.types.i32 } },
	R3D_DestroyLight = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_IsLightExist = { returns = ffi.types.u8, args = { ffi.types.i32 } },
	R3D_GetLightType = { returns = ffi.types.i32, args = { ffi.types.i32 } },
	R3D_IsLightActive = { returns = ffi.types.u8, args = { ffi.types.i32 } },
	R3D_ToggleLight = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_SetLightActive = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.u8 } },
	R3D_GetLightColor = { returns = rlstructs.structs.Color, args = { ffi.types.i32 } },
	R3D_GetLightColorV = { returns = rlstructs.structs.Vector3, args = { ffi.types.i32 } },
	R3D_SetLightColor = { returns = ffi.types.void, args = { ffi.types.i32, rlstructs.structs.Color } },
	R3D_SetLightColorV = { returns = ffi.types.void, args = { ffi.types.i32, rlstructs.structs.Vector3 } },
	R3D_GetLightPosition = { returns = rlstructs.structs.Vector3, args = { ffi.types.i32 } },
	R3D_SetLightPosition = { returns = ffi.types.void, args = { ffi.types.i32, rlstructs.structs.Vector3 } },
	R3D_GetLightDirection = { returns = rlstructs.structs.Vector3, args = { ffi.types.i32 } },
	R3D_SetLightDirection = { returns = ffi.types.void, args = { ffi.types.i32, rlstructs.structs.Vector3 } },
	R3D_LightLookAt = {
		returns = ffi.types.void,
		args = { ffi.types.i32, rlstructs.structs.Vector3, rlstructs.structs.Vector3 },
	},
	R3D_GetLightEnergy = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightEnergy = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightSpecular = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightSpecular = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightRange = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightRange = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightAttenuation = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightAttenuation = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightInnerCutOff = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightInnerCutOff = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightOuterCutOff = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetLightOuterCutOff = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_EnableShadow = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_DisableShadow = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_IsShadowEnabled = { returns = ffi.types.u8, args = { ffi.types.i32 } },
	R3D_GetShadowUpdateMode = { returns = ffi.types.i32, args = { ffi.types.i32 } },
	R3D_SetShadowUpdateMode = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_GetShadowUpdateFrequency = { returns = ffi.types.i32, args = { ffi.types.i32 } },
	R3D_SetShadowUpdateFrequency = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_UpdateShadowMap = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetShadowSoftness = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetShadowSoftness = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetShadowDepthBias = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetShadowDepthBias = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetShadowSlopeBias = { returns = ffi.types.float, args = { ffi.types.i32 } },
	R3D_SetShadowSlopeBias = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.float } },
	R3D_GetLightBoundingBox = { returns = rlstructs.structs.BoundingBox, args = { ffi.types.i32 } },
	R3D_DrawLightShape = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetDefaultMaterial = { returns = structs.R3D_Material, args = {} },
	R3D_SetDefaultMaterial = { returns = ffi.types.void, args = { structs.R3D_Material } },
	R3D_UnloadMaterial = { returns = ffi.types.void, args = { structs.R3D_Material } },
	R3D_LoadAlbedoMap = { returns = structs.R3D_AlbedoMap, args = { ffi.types.pointer, rlstructs.structs.Color } },
	R3D_LoadAlbedoMapFromMemory = {
		returns = structs.R3D_AlbedoMap,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, rlstructs.structs.Color },
	},
	R3D_UnloadAlbedoMap = { returns = ffi.types.void, args = { structs.R3D_AlbedoMap } },
	R3D_LoadEmissionMap = {
		returns = structs.R3D_EmissionMap,
		args = { ffi.types.pointer, rlstructs.structs.Color, ffi.types.float },
	},
	R3D_LoadEmissionMapFromMemory = {
		returns = structs.R3D_EmissionMap,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, rlstructs.structs.Color, ffi.types.float },
	},
	R3D_UnloadEmissionMap = { returns = ffi.types.void, args = { structs.R3D_EmissionMap } },
	R3D_LoadNormalMap = { returns = structs.R3D_NormalMap, args = { ffi.types.pointer, ffi.types.float } },
	R3D_LoadNormalMapFromMemory = {
		returns = structs.R3D_NormalMap,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	R3D_UnloadNormalMap = { returns = ffi.types.void, args = { structs.R3D_NormalMap } },
	R3D_LoadOrmMap = {
		returns = structs.R3D_OrmMap,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_LoadOrmMapFromMemory = {
		returns = structs.R3D_OrmMap,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},
	R3D_UnloadOrmMap = { returns = ffi.types.void, args = { structs.R3D_OrmMap } },
	R3D_LoadMesh = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.i32, structs.R3D_MeshData, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_UnloadMesh = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsMeshValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GenMeshQuad = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_GenMeshPlane = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshPoly = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.float, ffi.types.pointer } },
	R3D_GenMeshCube = { returns = structs.R3D_Mesh, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
	R3D_GenMeshCubeEx = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshSphere = { returns = structs.R3D_Mesh, args = { ffi.types.float, ffi.types.i32, ffi.types.i32 } },
	R3D_GenMeshHemiSphere = { returns = structs.R3D_Mesh, args = { ffi.types.float, ffi.types.i32, ffi.types.i32 } },
	R3D_GenMeshCylinder = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.i32 },
	},
	R3D_GenMeshTorus = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshKnot = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshHeightmap = { returns = structs.R3D_Mesh, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshCubicmap = { returns = structs.R3D_Mesh, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UpdateMesh = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	R3D_UnloadMeshData = { returns = ffi.types.void, args = { structs.R3D_MeshData } },
	R3D_IsMeshDataValid = { returns = ffi.types.u8, args = { structs.R3D_MeshData } },
	R3D_GenMeshDataQuad = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_GenMeshDataPlane = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataPoly = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.i32, ffi.types.float, ffi.types.pointer },
	},
	R3D_GenMeshDataCube = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_GenMeshDataCubeEx = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataSphere = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataHemiSphere = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataTorus = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataKnot = {
		returns = structs.R3D_MeshData,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataHeightmap = { returns = structs.R3D_MeshData, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshDataCubicmap = { returns = structs.R3D_MeshData, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_MergeMeshData = { returns = structs.R3D_MeshData, args = { structs.R3D_MeshData, structs.R3D_MeshData } },
	R3D_TranslateMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_RotateMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_ScaleMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshDataUVsPlanar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_GenMeshDataUVsSpherical = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataUVsCylindrical = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataNormals = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataTangents = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_CalculateMeshDataBoundingBox = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadModel = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadModelFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_UnloadModel = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_SetProbeActive = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_GetProbeUpdateMode = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetProbeUpdateMode = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetProbeInterior = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_SetProbeInterior = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_GetProbeShadows = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_SetProbeShadows = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_GetProbePosition = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetProbePosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetProbeRange = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetProbeRange = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetProbeFalloff = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetProbeFalloff = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_LoadSkeleton = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_UnloadSkeleton = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsSkeletonValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GetSkeletonBoneIndex = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetSkeletonBone = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetWhiteTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetBlackTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetNormalTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetBufferNormal = { returns = ffi.types.pointer, args = {} },
	R3D_GetBufferDepth = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixView = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixInvView = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixProjection = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixInvProjection = { returns = ffi.types.pointer, args = {} },

	R3D_DrawMeshInstancedPro = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	R3D_DrawModelInstancedPro = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_DrawAnimatedModelInstancedPro = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	R3D_DrawDecalInstancedPro = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},

	R3D_GenProceduralSky = { returns = structs.R3D_Cubemap, args = { ffi.types.i32, structs.R3D_ProceduralSky } },
	R3D_GenCustomSky = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.pointer } },
	R3D_UpdateProceduralSky = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UpdateCustomSky = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },

	R3D_LoadImporter = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	R3D_LoadImporterFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32 },
	},
	R3D_UnloadImporter = { returns = ffi.types.void, args = { ffi.types.pointer } },

	R3D_SetTextureWrap = { returns = ffi.types.void, args = { ffi.types.u32 } },

	R3D_LoadMaterials = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadMaterialsFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_LoadMaterialsFromImporter = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },

	R3D_LoadModelEx = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	R3D_LoadModelFromMemoryEx = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32 },
	},
	R3D_LoadModelFromImporter = { returns = ffi.types.pointer, args = { ffi.types.pointer } },

	R3D_LoadScreenShader = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadScreenShaderFromMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_UnloadScreenShader = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetScreenShaderUniform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetScreenShaderSampler = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetScreenShaderChain = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },

	R3D_LoadSkyShader = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadSkyShaderFromMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_UnloadSkyShader = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetSkyShaderUniform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetSkyShaderSampler = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	R3D_LoadSurfaceShader = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadSurfaceShaderFromMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_UnloadSurfaceShader = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetSurfaceShaderUniform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetSurfaceShaderSampler = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	R3D_CreateProbe = { returns = ffi.types.i32, args = { ffi.types.u32 } },
	R3D_DestroyProbe = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_IsProbeExist = { returns = ffi.types.u8, args = { ffi.types.i32 } },
	R3D_IsProbeActive = { returns = ffi.types.u8, args = { ffi.types.i32 } },

	R3D_LoadAnimationLibFromImporter = { returns = ffi.types.pointer, args = { ffi.types.pointer } },

	R3D_LoadMeshData = { returns = structs.R3D_MeshData, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_ReserveMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 } },
	R3D_ShrinkMeshData = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_ResetMeshData = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_CopyMeshData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_AppendMeshData = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_TransformMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },

	R3D_GenMeshSlope = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	R3D_GenMeshCapsule = {
		returns = structs.R3D_Mesh,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataSlope = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	R3D_GenMeshDataCylinder = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.i32 },
	},
	R3D_GenMeshDataCapsule = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},

	R3D_LoadSkeletonFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_LoadSkeletonFromImporter = { returns = ffi.types.pointer, args = { ffi.types.pointer } },

	R3D_IsPointVisible = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_IsSphereVisible = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.float } },
	R3D_IsBoundingBoxVisible = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_IsOrientedBoxVisible = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },

	R3D_CheckCollisionCapsuleBox = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_CheckCollisionCapsuleSphere = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	R3D_CheckCollisionCapsules = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_CheckCollisionCapsuleMesh = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_CheckPenetrationCapsuleBox = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_CheckPenetrationCapsuleSphere = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	R3D_CheckPenetrationCapsules = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_SlideVelocity = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_BounceVelocity = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	R3D_SlideSphereBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SlideSphereMesh = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	R3D_SlideCapsuleBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SlideCapsuleMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DepenetrateSphereBox = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DepenetrateCapsuleBox = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_RaycastMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_RaycastModel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepSpherePoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepSphereSegment = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepSphereTrianglePlane = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	R3D_SweepSphereTriangle = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	R3D_SweepSphereBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepSphereMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepCapsuleBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SweepCapsuleMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_IsSphereGroundedBox = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_IsSphereGroundedMesh = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	R3D_IsCapsuleGroundedBox = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_IsCapsuleGroundedMesh = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_ClosestPointOnSegment = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_ClosestPointOnTriangle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_ClosestPointOnBox = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
}

return funcs
