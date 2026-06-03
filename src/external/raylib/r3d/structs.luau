--!strict
--!optimize 2
--!native

local ffi = zune.ffi
local rlstructs = require("@raylibstructs")

local Color = rlstructs.structs.Color
local Vector2 = rlstructs.structs.Vector2
local Vector3 = rlstructs.structs.Vector3
local Vector4 = rlstructs.structs.Vector4
local Quaternion = rlstructs.structs.Quaternion
local Matrix = rlstructs.structs.Matrix
local Texture = rlstructs.structs.Texture
local BoundingBox = rlstructs.structs.BoundingBox

local R3D_AmbientMap = ffi.struct({
	{ flags = ffi.types.u32 },
	{ irradiance = ffi.types.u32 },
	{ prefilter = ffi.types.u32 },
})
export type R3D_AmbientMap = typeof(R3D_AmbientMap:new({}))

local R3D_AnimationTrack = ffi.struct({
	{ times = ffi.types.pointer },
	{ values = ffi.types.pointer },
	{ count = ffi.types.i32 },
})
export type R3D_AnimationTrack = typeof(R3D_AnimationTrack:new({}))

local R3D_AnimationChannel = ffi.struct({
	{ translation = R3D_AnimationTrack },
	{ rotation = R3D_AnimationTrack },
	{ scale = R3D_AnimationTrack },
	{ boneIndex = ffi.types.i32 },
})
export type R3D_AnimationChannel = typeof(R3D_AnimationChannel:new({}))

local R3D_Animation = ffi.struct({
	{ channels = ffi.types.pointer },
	{ channelCount = ffi.types.i32 },
	{ ticksPerSecond = ffi.types.float },
	{ duration = ffi.types.float },
	{ boneCount = ffi.types.i32 },
	{ name = ffi.types.i8:array(32) },
})
export type R3D_Animation = typeof(R3D_Animation:new({}))

local R3D_AnimationLib = ffi.struct({
	{ animations = ffi.types.pointer },
	{ count = ffi.types.i32 },
})
export type R3D_AnimationLib = typeof(R3D_AnimationLib:new({}))

local R3D_AnimationState = ffi.struct({
	{ currentTime = ffi.types.float },
	{ weight = ffi.types.float },
	{ speed = ffi.types.float },
	{ play = ffi.types.u8 },
	{ loop = ffi.types.u8 },
})
export type R3D_AnimationState = typeof(R3D_AnimationState:new({}))

local R3D_Cubemap = ffi.struct({
	{ texture = ffi.types.u32 },
	{ fbo = ffi.types.u32 },
	{ size = ffi.types.i32 },
})
export type R3D_Cubemap = typeof(R3D_Cubemap:new({}))

local R3D_ProceduralSky = ffi.struct({
	{ skyTopColor = Color },
	{ skyHorizonColor = Color },
	{ skyHorizonCurve = ffi.types.float },
	{ skyEnergy = ffi.types.float },
	{ groundBottomColor = Color },
	{ groundHorizonColor = Color },
	{ groundHorizonCurve = ffi.types.float },
	{ groundEnergy = ffi.types.float },
	{ sunDirection = Vector3 },
	{ sunColor = Color },
	{ sunSize = ffi.types.float },
	{ sunCurve = ffi.types.float },
	{ sunEnergy = ffi.types.float },
})
export type R3D_ProceduralSky = typeof(R3D_ProceduralSky:new({}))

local R3D_CubemapSky = R3D_ProceduralSky
export type R3D_CubemapSky = typeof(R3D_CubemapSky:new({}))

local R3D_EnvBackground = ffi.struct({
	{ color = Color },
	{ energy = ffi.types.float },
	{ skyBlur = ffi.types.float },
	{ sky = R3D_Cubemap },
	{ rotation = Quaternion },
})
export type R3D_EnvBackground = typeof(R3D_EnvBackground:new({}))

local R3D_EnvAmbient = ffi.struct({
	{ color = Color },
	{ energy = ffi.types.float },
	{ map = R3D_AmbientMap },
})
export type R3D_EnvAmbient = typeof(R3D_EnvAmbient:new({}))

local R3D_EnvSSAO = ffi.struct({
	{ sampleCount = ffi.types.i32 },
	{ intensity = ffi.types.float },
	{ power = ffi.types.float },
	{ radius = ffi.types.float },
	{ bias = ffi.types.float },
	{ enabled = ffi.types.u8 },
})
export type R3D_EnvSSAO = typeof(R3D_EnvSSAO:new({}))

local R3D_EnvSSIL = ffi.struct({
	{ sampleCount = ffi.types.i32 },
	{ sliceCount = ffi.types.i32 },
	{ radius = ffi.types.float },
	{ thickness = ffi.types.float },
	{ intensity = ffi.types.float },
	{ aoPower = ffi.types.float },
	{ denoiseSteps = ffi.types.i32 },
	{ enabled = ffi.types.u8 },
})
export type R3D_EnvSSIL = typeof(R3D_EnvSSIL:new({}))

local R3D_EnvSSGI = ffi.struct({
	{ sampleCount = ffi.types.i32 },
	{ maxRaySteps = ffi.types.i32 },
	{ stepSize = ffi.types.float },
	{ thickness = ffi.types.float },
	{ maxDistance = ffi.types.float },
	{ fadeStart = ffi.types.float },
	{ fadeEnd = ffi.types.float },
	{ denoiseSteps = ffi.types.i32 },
	{ enabled = ffi.types.u8 },
})
export type R3D_EnvSSGI = typeof(R3D_EnvSSGI:new({}))

local R3D_EnvSSR = ffi.struct({
	{ maxRaySteps = ffi.types.i32 },
	{ binarySteps = ffi.types.i32 },
	{ stepSize = ffi.types.float },
	{ thickness = ffi.types.float },
	{ maxDistance = ffi.types.float },
	{ edgeFade = ffi.types.float },
	{ enabled = ffi.types.u8 },
})
export type R3D_EnvSSR = typeof(R3D_EnvSSR:new({}))

local R3D_EnvBloom = ffi.struct({
	{ mode = ffi.types.i32 },
	{ levels = ffi.types.float },
	{ intensity = ffi.types.float },
	{ threshold = ffi.types.float },
	{ softThreshold = ffi.types.float },
	{ filterRadius = ffi.types.float },
})
export type R3D_EnvBloom = typeof(R3D_EnvBloom:new({}))

local R3D_EnvFog = ffi.struct({
	{ mode = ffi.types.i32 },
	{ color = Color },
	{ start = ffi.types.float },
	{ ["end"] = ffi.types.float },
	{ density = ffi.types.float },
	{ skyAffect = ffi.types.float },
})
export type R3D_EnvFog = typeof(R3D_EnvFog:new({}))

local R3D_EnvDoF = ffi.struct({
	{ mode = ffi.types.i32 },
	{ focusPoint = ffi.types.float },
	{ focusScale = ffi.types.float },
	{ maxBlurSize = ffi.types.float },
})
export type R3D_EnvDoF = typeof(R3D_EnvDoF:new({}))

local R3D_EnvTonemap = ffi.struct({
	{ mode = ffi.types.i32 },
	{ exposure = ffi.types.float },
	{ white = ffi.types.float },
})
export type R3D_EnvTonemap = typeof(R3D_EnvTonemap:new({}))

local R3D_EnvColor = ffi.struct({
	{ brightness = ffi.types.float },
	{ contrast = ffi.types.float },
	{ saturation = ffi.types.float },
})
export type R3D_EnvColor = typeof(R3D_EnvColor:new({}))

local R3D_Environment = ffi.struct({
	{ background = R3D_EnvBackground },
	{ ambient = R3D_EnvAmbient },
	{ ssao = R3D_EnvSSAO },
	{ ssil = R3D_EnvSSIL },
	{ ssgi = R3D_EnvSSGI },
	{ ssr = R3D_EnvSSR },
	{ bloom = R3D_EnvBloom },
	{ fog = R3D_EnvFog },
	{ dof = R3D_EnvDoF },
	{ tonemap = R3D_EnvTonemap },
	{ color = R3D_EnvColor },
})
export type R3D_Environment = typeof(R3D_Environment:new({}))

local R3D_AlbedoMap = ffi.struct({
	{ texture = Texture },
	{ color = Color },
})
export type R3D_AlbedoMap = typeof(R3D_AlbedoMap:new({}))

local R3D_EmissionMap = ffi.struct({
	{ texture = Texture },
	{ color = Color },
	{ energy = ffi.types.float },
})
export type R3D_EmissionMap = typeof(R3D_EmissionMap:new({}))

local R3D_NormalMap = ffi.struct({
	{ texture = Texture },
	{ scale = ffi.types.float },
})
export type R3D_NormalMap = typeof(R3D_NormalMap:new({}))

local R3D_OrmMap = ffi.struct({
	{ texture = Texture },
	{ occlusion = ffi.types.float },
	{ roughness = ffi.types.float },
	{ metalness = ffi.types.float },
})
export type R3D_OrmMap = typeof(R3D_OrmMap:new({}))

local R3D_DepthState = ffi.struct({
	{ mode = ffi.types.i32 },
	{ offsetFactor = ffi.types.float },
	{ offsetUnits = ffi.types.float },
	{ rangeNear = ffi.types.float },
	{ rangeFar = ffi.types.float },
})
export type R3D_DepthState = typeof(R3D_DepthState:new({}))

local R3D_StencilState = ffi.struct({
	{ mode = ffi.types.i32 },
	{ ref = ffi.types.u8 },
	{ mask = ffi.types.u8 },
	{ opFail = ffi.types.i32 },
	{ opZFail = ffi.types.i32 },
	{ opPass = ffi.types.i32 },
})
export type R3D_StencilState = typeof(R3D_StencilState:new({}))

local R3D_SurfaceShader = ffi.struct({
	{ program = ffi.types.pointer }, -- Pointer to r3d_shader_custom_program_t
	{ data = ffi.types.pointer }, -- r3d_shader_custom_data_t (contains uniforms and samplers)
	{ programOwner = ffi.types.u8 }, -- Boolean flag indicating ownership of the program
})
export type R3D_SurfaceShader = typeof(R3D_SurfaceShader:new({}))

local R3D_Material = ffi.struct({
	{ albedo = R3D_AlbedoMap },
	{ emission = R3D_EmissionMap },
	{ normal = R3D_NormalMap },
	{ orm = R3D_OrmMap },
	{ uvOffset = Vector2 },
	{ uvScale = Vector2 },
	{ alphaCutoff = ffi.types.float },
	{ depth = R3D_DepthState },
	{ stencil = R3D_StencilState },
	{ transparencyMode = ffi.types.i32 },
	{ billboardMode = ffi.types.i32 },
	{ blendMode = ffi.types.i32 },
	{ cullMode = ffi.types.i32 },
	{ unlit = ffi.types.u8 },
	{ shader = R3D_SurfaceShader },
})
export type R3D_Material = typeof(R3D_Material:new({}))

local R3D_Mesh = ffi.struct({
	{ vao = ffi.types.u32 },
	{ vbo = ffi.types.u32 },
	{ ebo = ffi.types.u32 },
	{ vertexCapacity = ffi.types.i32 },
	{ indexCapacity = ffi.types.i32 },
	{ vertexCount = ffi.types.i32 },
	{ indexCount = ffi.types.i32 },
	{ shadowCastMode = ffi.types.i32 },
	{ primitiveType = ffi.types.i32 },
	{ usage = ffi.types.i32 },
	{ layerMask = ffi.types.u32 },
	{ aabb = BoundingBox },
})
export type R3D_Mesh = typeof(R3D_Mesh:new({}))

local R3D_Vertex = ffi.struct({
	{ position = Vector3 },
	{ texcoord = Vector2 },
	{ normal = Vector3 },
	{ color = Color },
	{ tangent = Vector4 },
	{ boneIds = ffi.types.i32:array(4) },
	{ weights = ffi.types.float:array(4) },
})
export type R3D_Vertex = typeof(R3D_Vertex:new({}))

local R3D_MeshData = ffi.struct({
	{ vertices = ffi.types.pointer },
	{ indices = ffi.types.pointer },
	{ vertexCapacity = ffi.types.i32 },
	{ indexCapacity = ffi.types.i32 },
	{ vertexCount = ffi.types.i32 },
	{ indexCount = ffi.types.i32 },
})
export type R3D_MeshData = typeof(R3D_MeshData:new({}))

local R3D_BoneInfo = ffi.struct({
	{ name = ffi.types.i8:array(32) },
	{ parent = ffi.types.i32 },
})
export type R3D_BoneInfo = typeof(R3D_BoneInfo:new({}))

local R3D_Skeleton = ffi.struct({
	{ bones = ffi.types.pointer },
	{ boneCount = ffi.types.i32 },
	{ localBind = ffi.types.pointer },
	{ modelBind = ffi.types.pointer },
	{ invBind = ffi.types.pointer },
	{ rootBind = Matrix },
	{ skinTexture = ffi.types.u32 },
})
export type R3D_Skeleton = typeof(R3D_Skeleton:new({}))

local R3D_AnimationPlayer = ffi.struct({
	{ states = ffi.types.pointer },
	{ animLib = R3D_AnimationLib },
	{ skeleton = R3D_Skeleton },
	{ localPose = ffi.types.pointer },
	{ modelPose = ffi.types.pointer },
	{ skinBuffer = ffi.types.pointer },
	{ skinTexture = ffi.types.u32 },
	{ eventCallback = ffi.types.pointer },
	{ eventUserData = ffi.types.pointer },
})
export type R3D_AnimationPlayer = typeof(R3D_AnimationPlayer:new({}))

local R3D_InstanceBuffer = ffi.struct({
	{ buffers = ffi.types.u32:array(5) },
	{ flags = ffi.types.u32 },
	{ capacity = ffi.types.i32 },
})
export type R3D_InstanceBuffer = typeof(R3D_InstanceBuffer:new({}))

local R3D_Model = ffi.struct({
	{ meshes = ffi.types.pointer },
	{ meshData = ffi.types.pointer },
	{ materials = ffi.types.pointer },
	{ meshMaterials = ffi.types.pointer },
	{ meshCount = ffi.types.i32 },
	{ materialCount = ffi.types.i32 },
	{ aabb = BoundingBox },
	{ skeleton = R3D_Skeleton },
})
export type R3D_Model = typeof(R3D_Model:new({}))

local R3D_Decal = ffi.struct({
	{ albedo = R3D_AlbedoMap },
	{ emission = R3D_EmissionMap },
	{ normal = R3D_NormalMap },
	{ orm = R3D_OrmMap },
	{ uvOffset = Vector2 },
	{ uvScale = Vector2 },
	{ alphaCutoff = ffi.types.float },
	{ normalThreshold = ffi.types.float },
	{ fadeWidth = ffi.types.float },
	{ applyColor = ffi.types.u8 },
	{ shader = ffi.types.pointer },
})
export type R3D_Decal = typeof(R3D_Decal:new({}))

local R3D_Capsule = ffi.struct({
	{ start = Vector3 },
	{ ["end"] = Vector3 },
	{ radius = ffi.types.float },
})
export type R3D_Capsule = typeof(R3D_Capsule:new({}))

local R3D_Penetration = ffi.struct({
	{ collides = ffi.types.u8 },
	{ depth = ffi.types.float },
	{ normal = Vector3 },
	{ mtv = Vector3 },
})
export type R3D_Penetration = typeof(R3D_Penetration:new({}))

local R3D_SweepCollision = ffi.struct({
	{ hit = ffi.types.u8 },
	{ time = ffi.types.float },
	{ point = Vector3 },
	{ normal = Vector3 },
})
export type R3D_SweepCollision = typeof(R3D_SweepCollision:new({}))

local structs = {
	R3D_AmbientMap = R3D_AmbientMap,
	R3D_AnimationTrack = R3D_AnimationTrack,
	R3D_AnimationChannel = R3D_AnimationChannel,
	R3D_Animation = R3D_Animation,
	R3D_AnimationLib = R3D_AnimationLib,
	R3D_AnimationState = R3D_AnimationState,
	R3D_AnimationPlayer = R3D_AnimationPlayer,
	R3D_Cubemap = R3D_Cubemap,
	R3D_ProceduralSky = R3D_ProceduralSky,
	R3D_CubemapSky = R3D_CubemapSky,
	R3D_EnvBackground = R3D_EnvBackground,
	R3D_EnvAmbient = R3D_EnvAmbient,
	R3D_EnvSSAO = R3D_EnvSSAO,
	R3D_EnvSSIL = R3D_EnvSSIL,
	R3D_EnvSSGI = R3D_EnvSSGI,
	R3D_EnvBloom = R3D_EnvBloom,
	R3D_EnvSSR = R3D_EnvSSR,
	R3D_EnvFog = R3D_EnvFog,
	R3D_EnvDoF = R3D_EnvDoF,
	R3D_EnvTonemap = R3D_EnvTonemap,
	R3D_EnvColor = R3D_EnvColor,
	R3D_Environment = R3D_Environment,
	R3D_AlbedoMap = R3D_AlbedoMap,
	R3D_EmissionMap = R3D_EmissionMap,
	R3D_NormalMap = R3D_NormalMap,
	R3D_OrmMap = R3D_OrmMap,
	R3D_DepthState = R3D_DepthState,
	R3D_StencilState = R3D_StencilState,
	R3D_Material = R3D_Material,
	R3D_Mesh = R3D_Mesh,
	R3D_Vertex = R3D_Vertex,
	R3D_MeshData = R3D_MeshData,
	R3D_BoneInfo = R3D_BoneInfo,
	R3D_Skeleton = R3D_Skeleton,
	R3D_InstanceBuffer = R3D_InstanceBuffer,
	R3D_Model = R3D_Model,
	R3D_Decal = R3D_Decal,
	R3D_SurfaceShader = R3D_SurfaceShader,
	R3D_Capsule = R3D_Capsule,
	R3D_Penetration = R3D_Penetration,
	R3D_SweepCollision = R3D_SweepCollision,
}

return structs
