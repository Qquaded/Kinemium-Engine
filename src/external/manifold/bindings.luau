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

-- Struct definitions (ordered by dependencies)
-- NOTE: Some structs may have FIXME comments for array sizes that need manual definition

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

-- Function definitions
local funcs = {
	manifold_simple_polygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_polygons = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 } },
	manifold_simple_polygon_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_polygons_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_polygons_simple_length = { returns = ffi.types.u64, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_simple_polygon_get_point = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_polygons_get_simple = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_polygons_get_point = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	manifold_meshgl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_meshgl_w_tangents = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.u64,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.pointer,
		},
	},
	manifold_get_meshgl = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_copy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_merge = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_meshgl64_w_tangents = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.u64,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.pointer,
		},
	},
	manifold_get_meshgl64 = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_copy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_merge = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_level_set = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.pointer,
		},
	},
	manifold_level_set_seq = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.pointer,
		},
	},
	manifold_manifold_empty_vec = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_manifold_vec = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_manifold_vec_reserve = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_manifold_vec_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_manifold_vec_get = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_manifold_vec_set = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	manifold_manifold_vec_push_back = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_boolean = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_batch_boolean = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_union = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	manifold_difference = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_intersection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_split = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_split_by_plane = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_trim_by_plane = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_slice = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double } },
	manifold_project = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_hull = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_batch_hull = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_hull_pts = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 } },
	manifold_translate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_rotate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_scale = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_transform = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_mirror = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_smooth_by_normals = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	manifold_smooth_out = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_refine = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	manifold_refine_to_length = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double },
	},
	manifold_refine_to_tolerance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double },
	},
	manifold_empty = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_copy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_tetrahedron = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_cube = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double, ffi.types.i32 },
	},
	manifold_cylinder = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double, ffi.types.i32, ffi.types.i32 },
	},
	manifold_sphere = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.double, ffi.types.i32 } },
	manifold_of_meshgl = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_of_meshgl64 = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_smooth = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_smooth64 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_extrude = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.i32,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_revolve = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.double },
	},
	manifold_compose = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_decompose = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_as_original = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_is_empty = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_status = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_num_vert = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_num_edge = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_num_tri = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_num_prop = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_bounding_box = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_epsilon = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_genus = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_surface_area = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_volume = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_get_circular_segments = { returns = ffi.types.i32, args = { ffi.types.double } },
	manifold_original_id = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_reserve_ids = { returns = ffi.types.u32, args = { ffi.types.u32 } },
	manifold_calculate_curvature = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	manifold_min_gap = { returns = ffi.types.double, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double } },
	manifold_calculate_normals = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.double },
	},
	manifold_cross_section_empty = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_cross_section_copy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_of_simple_polygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_of_polygons = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_square = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.i32 },
	},
	manifold_cross_section_circle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.i32 },
	},
	manifold_cross_section_compose = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_decompose = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_empty_vec = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_cross_section_vec = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_cross_section_vec_reserve = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	manifold_cross_section_vec_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_cross_section_vec_get = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	manifold_cross_section_vec_set = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	manifold_cross_section_vec_push_back = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_boolean = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_batch_boolean = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_union = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_difference = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_intersection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_hull = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_batch_hull = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_hull_simple_polygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_hull_polygons = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	manifold_cross_section_translate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_cross_section_rotate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double },
	},
	manifold_cross_section_scale = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_cross_section_mirror = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_cross_section_transform = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_cross_section_simplify = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double },
	},
	manifold_cross_section_offset = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.i32,
		},
	},
	manifold_cross_section_area = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_cross_section_num_vert = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_cross_section_num_contour = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_cross_section_is_empty = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_cross_section_bounds = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_cross_section_to_polygons = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	manifold_rect = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_rect_min = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_rect_max = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_rect_dimensions = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_rect_center = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_rect_scale = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_rect_contains_pt = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_rect_contains_rect = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_rect_include_pt = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_rect_union = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_rect_transform = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_rect_translate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_rect_mul = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double },
	},
	manifold_rect_does_overlap_rect = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_rect_is_empty = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_rect_is_finite = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_box = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_box_min = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_box_max = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_box_dimensions = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_box_center = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	manifold_box_scale = { returns = ffi.types.double, args = { ffi.types.pointer } },
	manifold_box_contains_pt = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_box_contains_box = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_box_include_pt = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_box_union = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	manifold_box_transform = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
			ffi.types.double,
		},
	},
	manifold_box_translate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_box_mul = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_box_does_overlap_pt = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.double, ffi.types.double, ffi.types.double },
	},
	manifold_box_does_overlap_box = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_box_is_finite = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	manifold_set_min_circular_angle = { returns = ffi.types.void, args = { ffi.types.double } },
	manifold_set_min_circular_edge_length = { returns = ffi.types.void, args = { ffi.types.double } },
	manifold_set_circular_segments = { returns = ffi.types.void, args = { ffi.types.i32 } },
	manifold_reset_to_circular_defaults = { returns = ffi.types.void, args = {} },
	manifold_meshgl_num_prop = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_num_vert = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_num_tri = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_vert_properties_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_tri_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_merge_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_run_index_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_run_original_id_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_run_transform_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_face_id_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_tangent_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl_vert_properties = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_tri_verts = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_merge_from_vert = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_merge_to_vert = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_run_index = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_run_original_id = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_run_transform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_face_id = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl_halfedge_tangent = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_num_prop = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_num_vert = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_num_tri = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_vert_properties_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_tri_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_merge_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_run_index_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_run_original_id_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_run_transform_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_face_id_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_tangent_length = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_meshgl64_vert_properties = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_tri_verts = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_merge_from_vert = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_merge_to_vert = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_run_index = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_run_original_id = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_run_transform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_face_id = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_meshgl64_halfedge_tangent = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	manifold_triangulate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.double },
	},
	manifold_triangulation_num_tri = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	manifold_triangulation_tri_verts = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	manifold_manifold_size = { returns = ffi.types.u64, args = {} },
	manifold_manifold_vec_size = { returns = ffi.types.u64, args = {} },
	manifold_cross_section_size = { returns = ffi.types.u64, args = {} },
	manifold_cross_section_vec_size = { returns = ffi.types.u64, args = {} },
	manifold_simple_polygon_size = { returns = ffi.types.u64, args = {} },
	manifold_polygons_size = { returns = ffi.types.u64, args = {} },
	manifold_manifold_pair_size = { returns = ffi.types.u64, args = {} },
	manifold_meshgl_size = { returns = ffi.types.u64, args = {} },
	manifold_meshgl64_size = { returns = ffi.types.u64, args = {} },
	manifold_box_size = { returns = ffi.types.u64, args = {} },
	manifold_rect_size = { returns = ffi.types.u64, args = {} },
	manifold_triangulation_size = { returns = ffi.types.u64, args = {} },
	manifold_alloc_manifold = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_manifold_vec = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_cross_section = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_cross_section_vec = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_simple_polygon = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_polygons = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_meshgl = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_meshgl64 = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_box = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_rect = { returns = ffi.types.pointer, args = {} },
	manifold_alloc_triangulation = { returns = ffi.types.pointer, args = {} },
	manifold_destruct_manifold = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_manifold_vec = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_cross_section = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_cross_section_vec = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_simple_polygon = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_polygons = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_meshgl = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_meshgl64 = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_box = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_rect = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_destruct_triangulation = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_manifold = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_manifold_vec = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_cross_section = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_cross_section_vec = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_simple_polygon = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_polygons = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_meshgl = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_meshgl64 = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_box = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_rect = { returns = ffi.types.void, args = { ffi.types.pointer } },
	manifold_delete_triangulation = { returns = ffi.types.void, args = { ffi.types.pointer } },
}

local structs = {
	ManifoldManifoldPair = ManifoldManifoldPair,
	ManifoldVec2 = ManifoldVec2,
	ManifoldVec3 = ManifoldVec3,
	ManifoldIVec3 = ManifoldIVec3,
	ManifoldVec4 = ManifoldVec4,
	ManifoldProperties = ManifoldProperties,
}

return { funcs = funcs, structs = structs }
