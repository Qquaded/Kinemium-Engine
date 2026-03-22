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

local ULClipboard = ffi.struct({
	{ clear = ffi.types.pointer },
	{ read_plain_text = ffi.types.pointer },
	{ write_plain_text = ffi.types.pointer },
})
export type ULClipboard = typeof(ULClipboard:new({}))

local ULRect = ffi.struct({
	{ left = ffi.types.float },
	{ top = ffi.types.float },
	{ right = ffi.types.float },
	{ bottom = ffi.types.float },
})
export type ULRect = typeof(ULRect:new({}))

local ULIntRect = ffi.struct({
	{ left = ffi.types.i32 },
	{ top = ffi.types.i32 },
	{ right = ffi.types.i32 },
	{ bottom = ffi.types.i32 },
})
export type ULIntRect = typeof(ULIntRect:new({}))

local ULRenderTarget = ffi.struct({
	{ is_empty = ffi.types.u8 },
	{ width = ffi.types.u32 },
	{ height = ffi.types.u32 },
	{ texture_id = ffi.types.u32 },
	{ texture_width = ffi.types.u32 },
	{ texture_height = ffi.types.u32 },
	{ texture_format = ffi.types.pointer },
	{ uv_coords = ULRect },
	{ render_buffer_id = ffi.types.u32 },
})
export type ULRenderTarget = typeof(ULRenderTarget:new({}))

local ULFileSystem = ffi.struct({
	{ file_exists = ffi.types.pointer },
	{ get_file_mime_type = ffi.types.pointer },
	{ get_file_charset = ffi.types.pointer },
	{ open_file = ffi.types.pointer },
})
export type ULFileSystem = typeof(ULFileSystem:new({}))

local ULFontLoader = ffi.struct({
	{ get_fallback_font = ffi.types.pointer },
	{ get_fallback_font_for_characters = ffi.types.pointer },
	{ load = ffi.types.pointer },
})
export type ULFontLoader = typeof(ULFontLoader:new({}))

local ULRenderBuffer = ffi.struct({
	{ texture_id = ffi.types.u32 },
	{ width = ffi.types.u32 },
	{ height = ffi.types.u32 },
	{ has_stencil_buffer = ffi.types.u8 },
	{ has_depth_buffer = ffi.types.u8 },
})
export type ULRenderBuffer = typeof(ULRenderBuffer:new({}))

local ULVertex_2f_4ub_2f = ffi.struct({
	{ pos = ffi.types.float:array(2) },
	{ color = ffi.types.u8:array(4) },
	{ obj = ffi.types.float:array(2) },
})
export type ULVertex_2f_4ub_2f = typeof(ULVertex_2f_4ub_2f:new({}))

local ULVertex_2f_4ub_2f_2f_28f = ffi.struct({
	{ pos = ffi.types.float:array(2) },
	{ color = ffi.types.u8:array(4) },
	{ tex = ffi.types.float:array(2) },
	{ obj = ffi.types.float:array(2) },
	{ data0 = ffi.types.float:array(4) },
	{ data1 = ffi.types.float:array(4) },
	{ data2 = ffi.types.float:array(4) },
	{ data3 = ffi.types.float:array(4) },
	{ data4 = ffi.types.float:array(4) },
	{ data5 = ffi.types.float:array(4) },
	{ data6 = ffi.types.float:array(4) },
})
export type ULVertex_2f_4ub_2f_2f_28f = typeof(ULVertex_2f_4ub_2f_2f_28f:new({}))

local ULVertexBuffer = ffi.struct({
	{ format = ffi.types.pointer },
	{ size = ffi.types.u32 },
	{ data = ffi.types.pointer },
})
export type ULVertexBuffer = typeof(ULVertexBuffer:new({}))

local ULIndexBuffer = ffi.struct({
	{ size = ffi.types.u32 },
	{ data = ffi.types.pointer },
})
export type ULIndexBuffer = typeof(ULIndexBuffer:new({}))

local ULMatrix4x4 = ffi.struct({
	{ data = ffi.types.float:array(16) },
})
export type ULMatrix4x4 = typeof(ULMatrix4x4:new({}))

local ULvec4 = ffi.struct({
	{ value = ffi.types.float:array(4) },
})
export type ULvec4 = typeof(ULvec4:new({}))

local ULGPUState = ffi.struct({
	{ viewport_width = ffi.types.u32 },
	{ viewport_height = ffi.types.u32 },
	{ transform = ULMatrix4x4 },
	{ enable_texturing = ffi.types.u8 },
	{ enable_blend = ffi.types.u8 },
	{ shader_type = ffi.types.u8 },
	{ render_buffer_id = ffi.types.u32 },
	{ texture_1_id = ffi.types.u32 },
	{ texture_2_id = ffi.types.u32 },
	{ texture_3_id = ffi.types.u32 },
	{ uniform_scalar = ffi.types.float:array(8) },
	{ uniform_vector = ffi.types.pointer:array(8) },
	{ clip_size = ffi.types.u8 },
	{ clip = ffi.types.pointer:array(8) },
	{ enable_scissor = ffi.types.u8 },
	{ scissor_rect = ULIntRect },
})
export type ULGPUState = typeof(ULGPUState:new({}))

local ULCommand = ffi.struct({
	{ command_type = ffi.types.u8 },
	{ gpu_state = ULGPUState },
	{ geometry_id = ffi.types.u32 },
	{ indices_count = ffi.types.u32 },
	{ indices_offset = ffi.types.u32 },
})
export type ULCommand = typeof(ULCommand:new({}))

local ULCommandList = ffi.struct({
	{ size = ffi.types.u32 },
	{ commands = ffi.types.pointer },
})
export type ULCommandList = typeof(ULCommandList:new({}))

local ULGPUDriver = ffi.struct({
	{ begin_synchronize = ffi.types.pointer },
	{ end_synchronize = ffi.types.pointer },
	{ next_texture_id = ffi.types.pointer },
	{ create_texture = ffi.types.pointer },
	{ update_texture = ffi.types.pointer },
	{ destroy_texture = ffi.types.pointer },
	{ next_render_buffer_id = ffi.types.pointer },
	{ create_render_buffer = ffi.types.pointer },
	{ destroy_render_buffer = ffi.types.pointer },
	{ next_geometry_id = ffi.types.pointer },
	{ create_geometry = ffi.types.pointer },
	{ update_geometry = ffi.types.pointer },
	{ destroy_geometry = ffi.types.pointer },
	{ update_command_list = ffi.types.pointer },
})
export type ULGPUDriver = typeof(ULGPUDriver:new({}))

local ULLogger = ffi.struct({
	{ log_message = ffi.types.pointer },
})
export type ULLogger = typeof(ULLogger:new({}))

local ULSurfaceDefinition = ffi.struct({
	{ create = ffi.types.pointer },
	{ destroy = ffi.types.pointer },
	{ get_width = ffi.types.pointer },
	{ get_height = ffi.types.pointer },
	{ get_row_bytes = ffi.types.pointer },
	{ get_size = ffi.types.pointer },
	{ lock_pixels = ffi.types.pointer },
	{ unlock_pixels = ffi.types.pointer },
	{ resize = ffi.types.pointer },
})
export type ULSurfaceDefinition = typeof(ULSurfaceDefinition:new({}))

local structs = {
	ULClipboard = ULClipboard,
	ULRect = ULRect,
	ULIntRect = ULIntRect,
	ULRenderTarget = ULRenderTarget,
	ULFileSystem = ULFileSystem,
	ULFontLoader = ULFontLoader,
	ULRenderBuffer = ULRenderBuffer,
	ULVertex_2f_4ub_2f = ULVertex_2f_4ub_2f,
	ULVertex_2f_4ub_2f_2f_28f = ULVertex_2f_4ub_2f_2f_28f,
	ULVertexBuffer = ULVertexBuffer,
	ULIndexBuffer = ULIndexBuffer,
	ULMatrix4x4 = ULMatrix4x4,
	ULvec4 = ULvec4,
	ULGPUState = ULGPUState,
	ULCommand = ULCommand,
	ULCommandList = ULCommandList,
	ULGPUDriver = ULGPUDriver,
	ULLogger = ULLogger,
	ULSurfaceDefinition = ULSurfaceDefinition,
}

return structs
