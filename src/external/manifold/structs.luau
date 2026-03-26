--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

local ManifoldManifoldPair = ffi.struct({
	{ first = ffi.types.pointer },
	{ second = ffi.types.pointer },
})
export type ManifoldManifoldPair = typeof(ManifoldManifoldPair:new({}))

local ManifoldVec2 = ffi.struct({
	{ x = ffi.types.double },
	{ y = ffi.types.double },
})
export type ManifoldVec2 = typeof(ManifoldVec2:new({}))

local ManifoldVec3 = ffi.struct({
	{ x = ffi.types.double },
	{ y = ffi.types.double },
	{ z = ffi.types.double },
})
export type ManifoldVec3 = typeof(ManifoldVec3:new({}))

local ManifoldIVec3 = ffi.struct({
	{ x = ffi.types.i32 },
	{ y = ffi.types.i32 },
	{ z = ffi.types.i32 },
})
export type ManifoldIVec3 = typeof(ManifoldIVec3:new({}))

local ManifoldVec4 = ffi.struct({
	{ x = ffi.types.double },
	{ y = ffi.types.double },
	{ z = ffi.types.double },
	{ w = ffi.types.double },
})
export type ManifoldVec4 = typeof(ManifoldVec4:new({}))

local ManifoldProperties = ffi.struct({
	{ surface_area = ffi.types.double },
	{ volume = ffi.types.double },
})
export type ManifoldProperties = typeof(ManifoldProperties:new({}))

local ManifoldMeshGLOptions = ffi.struct({
	{ run_indices = ffi.types.pointer },
	{ run_indices_length = ffi.types.u64 },
	{ run_original_ids = ffi.types.pointer },
	{ run_original_ids_length = ffi.types.u64 },
	{ merge_from_vert = ffi.types.pointer },
	{ merge_to_vert = ffi.types.pointer },
	{ merge_verts_length = ffi.types.u64 },
	{ halfedge_tangents = ffi.types.pointer },
})
export type ManifoldMeshGLOptions = typeof(ManifoldMeshGLOptions:new({}))

local ManifoldMeshGL64Options = ffi.struct({
	{ run_indices = ffi.types.pointer },
	{ run_indices_length = ffi.types.u64 },
	{ run_original_ids = ffi.types.pointer },
	{ run_original_ids_length = ffi.types.u64 },
	{ merge_from_vert = ffi.types.pointer },
	{ merge_to_vert = ffi.types.pointer },
	{ merge_verts_length = ffi.types.u64 },
	{ halfedge_tangents = ffi.types.pointer },
})
export type ManifoldMeshGL64Options = typeof(ManifoldMeshGL64Options:new({}))

local structs = {
	ManifoldManifoldPair = ManifoldManifoldPair,
	ManifoldVec2 = ManifoldVec2,
	ManifoldVec3 = ManifoldVec3,
	ManifoldIVec3 = ManifoldIVec3,
	ManifoldVec4 = ManifoldVec4,
	ManifoldProperties = ManifoldProperties,
	ManifoldMeshGLOptions = ManifoldMeshGLOptions,
	ManifoldMeshGL64Options = ManifoldMeshGL64Options,
}

return structs
