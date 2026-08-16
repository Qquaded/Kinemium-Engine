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

local SDL_AssertData = ffi.struct({
	{ always_ignore = ffi.types.u8 },
	{ trigger_count = ffi.types.u32 },
	{ condition = ffi.types.pointer },
	{ filename = ffi.types.pointer },
	{ linenum = ffi.types.i32 },
	{ ["function"] = ffi.types.pointer },
	{ next = ffi.types.pointer },
})
export type SDL_AssertData = typeof(SDL_AssertData:new({}))

local SDL_AsyncIOOutcome = ffi.struct({
	{ asyncio = ffi.types.pointer },
	{ type = ffi.types.pointer },
	{ result = ffi.types.pointer },
	{ buffer = ffi.types.pointer },
	{ offset = ffi.types.u64 },
	{ bytes_requested = ffi.types.u64 },
	{ bytes_transferred = ffi.types.u64 },
	{ userdata = ffi.types.pointer },
})
export type SDL_AsyncIOOutcome = typeof(SDL_AsyncIOOutcome:new({}))

local SDL_AtomicInt = ffi.struct({
	{ value = ffi.types.i32 },
})
export type SDL_AtomicInt = typeof(SDL_AtomicInt:new({}))

local SDL_Event = ffi.struct({
	{ padding = ffi.types.u8:array(128) },
})

export type SDL_Event = typeof(SDL_Event:new({}))

local SDL_AtomicU32 = ffi.struct({
	{ value = ffi.types.u32 },
})
export type SDL_AtomicU32 = typeof(SDL_AtomicU32:new({}))

local SDL_AudioSpec = ffi.struct({
	{ format = ffi.types.pointer },
	{ channels = ffi.types.i32 },
	{ freq = ffi.types.i32 },
})
export type SDL_AudioSpec = typeof(SDL_AudioSpec:new({}))

local SDL_CameraSpec = ffi.struct({
	{ format = ffi.types.pointer },
	{ colorspace = ffi.types.pointer },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
	{ framerate_numerator = ffi.types.i32 },
	{ framerate_denominator = ffi.types.i32 },
})
export type SDL_CameraSpec = typeof(SDL_CameraSpec:new({}))

local SDL_DialogFileFilter = ffi.struct({
	{ name = ffi.types.pointer },
	{ pattern = ffi.types.pointer },
})
export type SDL_DialogFileFilter = typeof(SDL_DialogFileFilter:new({}))

local EGLClientPixmapHI = ffi.struct({
	{ pData = ffi.types.pointer },
	{ iWidth = ffi.types.pointer },
	{ iHeight = ffi.types.pointer },
	{ iStride = ffi.types.pointer },
})
export type EGLClientPixmapHI = typeof(EGLClientPixmapHI:new({}))

local SDL_CommonEvent = ffi.struct({
	{ type = ffi.types.u32 },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
})
export type SDL_CommonEvent = typeof(SDL_CommonEvent:new({}))

local SDL_DisplayEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ displayID = ffi.types.pointer },
	{ data1 = ffi.types.i32 },
	{ data2 = ffi.types.i32 },
})
export type SDL_DisplayEvent = typeof(SDL_DisplayEvent:new({}))

local SDL_WindowEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ data1 = ffi.types.i32 },
	{ data2 = ffi.types.i32 },
})
export type SDL_WindowEvent = typeof(SDL_WindowEvent:new({}))

local SDL_KeyboardDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
})
export type SDL_KeyboardDeviceEvent = typeof(SDL_KeyboardDeviceEvent:new({}))

local SDL_KeyboardEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ scancode = ffi.types.pointer },
	{ key = ffi.types.pointer },
	{ mod = ffi.types.pointer },
	{ raw = ffi.types.u16 },
	{ down = ffi.types.u8 },
	{ ["repeat"] = ffi.types.u8 },
})
export type SDL_KeyboardEvent = typeof(SDL_KeyboardEvent:new({}))

local SDL_TextEditingEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ text = ffi.types.pointer },
	{ start = ffi.types.i32 },
	{ length = ffi.types.i32 },
})
export type SDL_TextEditingEvent = typeof(SDL_TextEditingEvent:new({}))

local SDL_TextEditingCandidatesEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ candidates = ffi.types.pointer },
	{ num_candidates = ffi.types.i32 },
	{ selected_candidate = ffi.types.i32 },
	{ horizontal = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_TextEditingCandidatesEvent = typeof(SDL_TextEditingCandidatesEvent:new({}))

local SDL_TextInputEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ text = ffi.types.pointer },
})
export type SDL_TextInputEvent = typeof(SDL_TextInputEvent:new({}))

local SDL_MouseDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
})
export type SDL_MouseDeviceEvent = typeof(SDL_MouseDeviceEvent:new({}))

local SDL_MouseMotionEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ state = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ xrel = ffi.types.float },
	{ yrel = ffi.types.float },
})
export type SDL_MouseMotionEvent = typeof(SDL_MouseMotionEvent:new({}))

local SDL_MouseButtonEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ button = ffi.types.u8 },
	{ down = ffi.types.u8 },
	{ clicks = ffi.types.u8 },
	{ padding = ffi.types.u8 },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
})
export type SDL_MouseButtonEvent = typeof(SDL_MouseButtonEvent:new({}))

local SDL_MouseWheelEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ direction = ffi.types.pointer },
	{ mouse_x = ffi.types.float },
	{ mouse_y = ffi.types.float },
})
export type SDL_MouseWheelEvent = typeof(SDL_MouseWheelEvent:new({}))

local SDL_JoyAxisEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ axis = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
	{ value = ffi.types.i16 },
	{ padding4 = ffi.types.u16 },
})
export type SDL_JoyAxisEvent = typeof(SDL_JoyAxisEvent:new({}))

local SDL_JoyBallEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ ball = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
	{ xrel = ffi.types.i16 },
	{ yrel = ffi.types.i16 },
})
export type SDL_JoyBallEvent = typeof(SDL_JoyBallEvent:new({}))

local SDL_JoyHatEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ hat = ffi.types.u8 },
	{ value = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_JoyHatEvent = typeof(SDL_JoyHatEvent:new({}))

local SDL_JoyButtonEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ button = ffi.types.u8 },
	{ down = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_JoyButtonEvent = typeof(SDL_JoyButtonEvent:new({}))

local SDL_JoyDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
})
export type SDL_JoyDeviceEvent = typeof(SDL_JoyDeviceEvent:new({}))

local SDL_JoyBatteryEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ state = ffi.types.pointer },
	{ percent = ffi.types.i32 },
})
export type SDL_JoyBatteryEvent = typeof(SDL_JoyBatteryEvent:new({}))

local SDL_GamepadAxisEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ axis = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
	{ value = ffi.types.i16 },
	{ padding4 = ffi.types.u16 },
})
export type SDL_GamepadAxisEvent = typeof(SDL_GamepadAxisEvent:new({}))

local SDL_GamepadButtonEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ button = ffi.types.u8 },
	{ down = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_GamepadButtonEvent = typeof(SDL_GamepadButtonEvent:new({}))

local SDL_GamepadDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
})
export type SDL_GamepadDeviceEvent = typeof(SDL_GamepadDeviceEvent:new({}))

local SDL_GamepadTouchpadEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ touchpad = ffi.types.i32 },
	{ finger = ffi.types.i32 },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ pressure = ffi.types.float },
})
export type SDL_GamepadTouchpadEvent = typeof(SDL_GamepadTouchpadEvent:new({}))

local SDL_GamepadSensorEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ sensor = ffi.types.i32 },
	{ data = ffi.types.float:array(3) },
	{ sensor_timestamp = ffi.types.u64 },
})
export type SDL_GamepadSensorEvent = typeof(SDL_GamepadSensorEvent:new({}))

local SDL_AudioDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ recording = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_AudioDeviceEvent = typeof(SDL_AudioDeviceEvent:new({}))

local SDL_CameraDeviceEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
})
export type SDL_CameraDeviceEvent = typeof(SDL_CameraDeviceEvent:new({}))

local SDL_RenderEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
})
export type SDL_RenderEvent = typeof(SDL_RenderEvent:new({}))

local SDL_TouchFingerEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ touchID = ffi.types.pointer },
	{ fingerID = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ dx = ffi.types.float },
	{ dy = ffi.types.float },
	{ pressure = ffi.types.float },
	{ windowID = ffi.types.pointer },
})
export type SDL_TouchFingerEvent = typeof(SDL_TouchFingerEvent:new({}))

local SDL_PenProximityEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
})
export type SDL_PenProximityEvent = typeof(SDL_PenProximityEvent:new({}))

local SDL_PenMotionEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ pen_state = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
})
export type SDL_PenMotionEvent = typeof(SDL_PenMotionEvent:new({}))

local SDL_PenTouchEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ pen_state = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ eraser = ffi.types.u8 },
	{ down = ffi.types.u8 },
})
export type SDL_PenTouchEvent = typeof(SDL_PenTouchEvent:new({}))

local SDL_PenButtonEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ pen_state = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ button = ffi.types.u8 },
	{ down = ffi.types.u8 },
})
export type SDL_PenButtonEvent = typeof(SDL_PenButtonEvent:new({}))

local SDL_PenAxisEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ which = ffi.types.pointer },
	{ pen_state = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ axis = ffi.types.pointer },
	{ value = ffi.types.float },
})
export type SDL_PenAxisEvent = typeof(SDL_PenAxisEvent:new({}))

local SDL_DropEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ source = ffi.types.pointer },
	{ data = ffi.types.pointer },
})
export type SDL_DropEvent = typeof(SDL_DropEvent:new({}))

local SDL_ClipboardEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ owner = ffi.types.u8 },
	{ num_mime_types = ffi.types.i32 },
	{ mime_types = ffi.types.pointer },
})
export type SDL_ClipboardEvent = typeof(SDL_ClipboardEvent:new({}))

local SDL_SensorEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ which = ffi.types.pointer },
	{ data = ffi.types.float:array(6) },
	{ sensor_timestamp = ffi.types.u64 },
})
export type SDL_SensorEvent = typeof(SDL_SensorEvent:new({}))

local SDL_QuitEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
})
export type SDL_QuitEvent = typeof(SDL_QuitEvent:new({}))

local SDL_UserEvent = ffi.struct({
	{ type = ffi.types.u32 },
	{ reserved = ffi.types.u32 },
	{ timestamp = ffi.types.u64 },
	{ windowID = ffi.types.pointer },
	{ code = ffi.types.i32 },
	{ data1 = ffi.types.pointer },
	{ data2 = ffi.types.pointer },
})
export type SDL_UserEvent = typeof(SDL_UserEvent:new({}))

local SDL_PathInfo = ffi.struct({
	{ type = ffi.types.pointer },
	{ size = ffi.types.u64 },
	{ create_time = ffi.types.pointer },
	{ modify_time = ffi.types.pointer },
	{ access_time = ffi.types.pointer },
})
export type SDL_PathInfo = typeof(SDL_PathInfo:new({}))

local axis = ffi.struct({
	{ input_type = ffi.types.pointer },
	{ button = ffi.types.pointer },
	{ axis = ffi.types.pointer },
	{ axis_min = ffi.types.i32 },
	{ axis_max = ffi.types.i32 },
})
export type axis = typeof(axis:new({}))

local SDL_GPUViewport = ffi.struct({
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ w = ffi.types.float },
	{ h = ffi.types.float },
	{ min_depth = ffi.types.float },
	{ max_depth = ffi.types.float },
})
export type SDL_GPUViewport = typeof(SDL_GPUViewport:new({}))

local SDL_GPUTextureTransferInfo = ffi.struct({
	{ transfer_buffer = ffi.types.pointer },
	{ offset = ffi.types.u32 },
	{ pixels_per_row = ffi.types.u32 },
	{ rows_per_layer = ffi.types.u32 },
})
export type SDL_GPUTextureTransferInfo = typeof(SDL_GPUTextureTransferInfo:new({}))

local SDL_GPUTransferBufferLocation = ffi.struct({
	{ transfer_buffer = ffi.types.pointer },
	{ offset = ffi.types.u32 },
})
export type SDL_GPUTransferBufferLocation = typeof(SDL_GPUTransferBufferLocation:new({}))

local SDL_GPUTextureLocation = ffi.struct({
	{ texture = ffi.types.pointer },
	{ mip_level = ffi.types.u32 },
	{ layer = ffi.types.u32 },
	{ x = ffi.types.u32 },
	{ y = ffi.types.u32 },
	{ z = ffi.types.u32 },
})
export type SDL_GPUTextureLocation = typeof(SDL_GPUTextureLocation:new({}))

local SDL_GPUTextureRegion = ffi.struct({
	{ texture = ffi.types.pointer },
	{ mip_level = ffi.types.u32 },
	{ layer = ffi.types.u32 },
	{ x = ffi.types.u32 },
	{ y = ffi.types.u32 },
	{ z = ffi.types.u32 },
	{ w = ffi.types.u32 },
	{ h = ffi.types.u32 },
	{ d = ffi.types.u32 },
})
export type SDL_GPUTextureRegion = typeof(SDL_GPUTextureRegion:new({}))

local SDL_GPUBlitRegion = ffi.struct({
	{ texture = ffi.types.pointer },
	{ mip_level = ffi.types.u32 },
	{ layer_or_depth_plane = ffi.types.u32 },
	{ x = ffi.types.u32 },
	{ y = ffi.types.u32 },
	{ w = ffi.types.u32 },
	{ h = ffi.types.u32 },
})
export type SDL_GPUBlitRegion = typeof(SDL_GPUBlitRegion:new({}))

local SDL_GPUBufferLocation = ffi.struct({
	{ buffer = ffi.types.pointer },
	{ offset = ffi.types.u32 },
})
export type SDL_GPUBufferLocation = typeof(SDL_GPUBufferLocation:new({}))

local SDL_GPUBufferRegion = ffi.struct({
	{ buffer = ffi.types.pointer },
	{ offset = ffi.types.u32 },
	{ size = ffi.types.u32 },
})
export type SDL_GPUBufferRegion = typeof(SDL_GPUBufferRegion:new({}))

local SDL_GPUIndirectDrawCommand = ffi.struct({
	{ num_vertices = ffi.types.u32 },
	{ num_instances = ffi.types.u32 },
	{ first_vertex = ffi.types.u32 },
	{ first_instance = ffi.types.u32 },
})
export type SDL_GPUIndirectDrawCommand = typeof(SDL_GPUIndirectDrawCommand:new({}))

local SDL_GPUIndexedIndirectDrawCommand = ffi.struct({
	{ num_indices = ffi.types.u32 },
	{ num_instances = ffi.types.u32 },
	{ first_index = ffi.types.u32 },
	{ vertex_offset = ffi.types.i32 },
	{ first_instance = ffi.types.u32 },
})
export type SDL_GPUIndexedIndirectDrawCommand = typeof(SDL_GPUIndexedIndirectDrawCommand:new({}))

local SDL_GPUIndirectDispatchCommand = ffi.struct({
	{ groupcount_x = ffi.types.u32 },
	{ groupcount_y = ffi.types.u32 },
	{ groupcount_z = ffi.types.u32 },
})
export type SDL_GPUIndirectDispatchCommand = typeof(SDL_GPUIndirectDispatchCommand:new({}))

local SDL_GPUSamplerCreateInfo = ffi.struct({
	{ min_filter = ffi.types.pointer },
	{ mag_filter = ffi.types.pointer },
	{ mipmap_mode = ffi.types.pointer },
	{ address_mode_u = ffi.types.pointer },
	{ address_mode_v = ffi.types.pointer },
	{ address_mode_w = ffi.types.pointer },
	{ mip_lod_bias = ffi.types.float },
	{ max_anisotropy = ffi.types.float },
	{ compare_op = ffi.types.pointer },
	{ min_lod = ffi.types.float },
	{ max_lod = ffi.types.float },
	{ enable_anisotropy = ffi.types.u8 },
	{ enable_compare = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ props = ffi.types.pointer },
})
export type SDL_GPUSamplerCreateInfo = typeof(SDL_GPUSamplerCreateInfo:new({}))

local SDL_GPUVertexBufferDescription = ffi.struct({
	{ slot = ffi.types.u32 },
	{ pitch = ffi.types.u32 },
	{ input_rate = ffi.types.pointer },
	{ instance_step_rate = ffi.types.u32 },
})
export type SDL_GPUVertexBufferDescription = typeof(SDL_GPUVertexBufferDescription:new({}))

local SDL_GPUVertexAttribute = ffi.struct({
	{ location = ffi.types.u32 },
	{ buffer_slot = ffi.types.u32 },
	{ format = ffi.types.pointer },
	{ offset = ffi.types.u32 },
})
export type SDL_GPUVertexAttribute = typeof(SDL_GPUVertexAttribute:new({}))

local SDL_GPUVertexInputState = ffi.struct({
	{ vertex_buffer_descriptions = ffi.types.pointer },
	{ num_vertex_buffers = ffi.types.u32 },
	{ vertex_attributes = ffi.types.pointer },
	{ num_vertex_attributes = ffi.types.u32 },
})
export type SDL_GPUVertexInputState = typeof(SDL_GPUVertexInputState:new({}))

local SDL_GPUStencilOpState = ffi.struct({
	{ fail_op = ffi.types.pointer },
	{ pass_op = ffi.types.pointer },
	{ depth_fail_op = ffi.types.pointer },
	{ compare_op = ffi.types.pointer },
})
export type SDL_GPUStencilOpState = typeof(SDL_GPUStencilOpState:new({}))

local SDL_GPUColorTargetBlendState = ffi.struct({
	{ src_color_blendfactor = ffi.types.pointer },
	{ dst_color_blendfactor = ffi.types.pointer },
	{ color_blend_op = ffi.types.pointer },
	{ src_alpha_blendfactor = ffi.types.pointer },
	{ dst_alpha_blendfactor = ffi.types.pointer },
	{ alpha_blend_op = ffi.types.pointer },
	{ color_write_mask = ffi.types.pointer },
	{ enable_blend = ffi.types.u8 },
	{ enable_color_write_mask = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_GPUColorTargetBlendState = typeof(SDL_GPUColorTargetBlendState:new({}))

local SDL_GPUShaderCreateInfo = ffi.struct({
	{ code_size = ffi.types.u64 },
	{ code = ffi.types.pointer },
	{ entrypoint = ffi.types.pointer },
	{ format = ffi.types.pointer },
	{ stage = ffi.types.pointer },
	{ num_samplers = ffi.types.u32 },
	{ num_storage_textures = ffi.types.u32 },
	{ num_storage_buffers = ffi.types.u32 },
	{ num_uniform_buffers = ffi.types.u32 },
	{ props = ffi.types.pointer },
})
export type SDL_GPUShaderCreateInfo = typeof(SDL_GPUShaderCreateInfo:new({}))

local SDL_GPUTextureCreateInfo = ffi.struct({
	{ type = ffi.types.pointer },
	{ format = ffi.types.pointer },
	{ usage = ffi.types.pointer },
	{ width = ffi.types.u32 },
	{ height = ffi.types.u32 },
	{ layer_count_or_depth = ffi.types.u32 },
	{ num_levels = ffi.types.u32 },
	{ sample_count = ffi.types.pointer },
	{ props = ffi.types.pointer },
})
export type SDL_GPUTextureCreateInfo = typeof(SDL_GPUTextureCreateInfo:new({}))

local SDL_GPUBufferCreateInfo = ffi.struct({
	{ usage = ffi.types.pointer },
	{ size = ffi.types.u32 },
	{ props = ffi.types.pointer },
})
export type SDL_GPUBufferCreateInfo = typeof(SDL_GPUBufferCreateInfo:new({}))

local SDL_GPUTransferBufferCreateInfo = ffi.struct({
	{ usage = ffi.types.pointer },
	{ size = ffi.types.u32 },
	{ props = ffi.types.pointer },
})
export type SDL_GPUTransferBufferCreateInfo = typeof(SDL_GPUTransferBufferCreateInfo:new({}))

local SDL_GPURasterizerState = ffi.struct({
	{ fill_mode = ffi.types.pointer },
	{ cull_mode = ffi.types.pointer },
	{ front_face = ffi.types.pointer },
	{ depth_bias_constant_factor = ffi.types.float },
	{ depth_bias_clamp = ffi.types.float },
	{ depth_bias_slope_factor = ffi.types.float },
	{ enable_depth_bias = ffi.types.u8 },
	{ enable_depth_clip = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_GPURasterizerState = typeof(SDL_GPURasterizerState:new({}))

local SDL_GPUMultisampleState = ffi.struct({
	{ sample_count = ffi.types.pointer },
	{ sample_mask = ffi.types.u32 },
	{ enable_mask = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_GPUMultisampleState = typeof(SDL_GPUMultisampleState:new({}))

local SDL_GPUDepthStencilState = ffi.struct({
	{ compare_op = ffi.types.pointer },
	{ back_stencil_state = SDL_GPUStencilOpState },
	{ front_stencil_state = SDL_GPUStencilOpState },
	{ compare_mask = ffi.types.u8 },
	{ write_mask = ffi.types.u8 },
	{ enable_depth_test = ffi.types.u8 },
	{ enable_depth_write = ffi.types.u8 },
	{ enable_stencil_test = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_GPUDepthStencilState = typeof(SDL_GPUDepthStencilState:new({}))

local SDL_GPUColorTargetDescription = ffi.struct({
	{ format = ffi.types.pointer },
	{ blend_state = SDL_GPUColorTargetBlendState },
})
export type SDL_GPUColorTargetDescription = typeof(SDL_GPUColorTargetDescription:new({}))

local SDL_GPUGraphicsPipelineTargetInfo = ffi.struct({
	{ color_target_descriptions = ffi.types.pointer },
	{ num_color_targets = ffi.types.u32 },
	{ depth_stencil_format = ffi.types.pointer },
	{ has_depth_stencil_target = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_GPUGraphicsPipelineTargetInfo = typeof(SDL_GPUGraphicsPipelineTargetInfo:new({}))

local SDL_GPUGraphicsPipelineCreateInfo = ffi.struct({
	{ vertex_shader = ffi.types.pointer },
	{ fragment_shader = ffi.types.pointer },
	{ vertex_input_state = SDL_GPUVertexInputState },
	{ primitive_type = ffi.types.pointer },
	{ rasterizer_state = SDL_GPURasterizerState },
	{ multisample_state = SDL_GPUMultisampleState },
	{ depth_stencil_state = SDL_GPUDepthStencilState },
	{ target_info = SDL_GPUGraphicsPipelineTargetInfo },
	{ props = ffi.types.pointer },
})
export type SDL_GPUGraphicsPipelineCreateInfo = typeof(SDL_GPUGraphicsPipelineCreateInfo:new({}))

local SDL_GPUComputePipelineCreateInfo = ffi.struct({
	{ code_size = ffi.types.u64 },
	{ code = ffi.types.pointer },
	{ entrypoint = ffi.types.pointer },
	{ format = ffi.types.pointer },
	{ num_samplers = ffi.types.u32 },
	{ num_readonly_storage_textures = ffi.types.u32 },
	{ num_readonly_storage_buffers = ffi.types.u32 },
	{ num_readwrite_storage_textures = ffi.types.u32 },
	{ num_readwrite_storage_buffers = ffi.types.u32 },
	{ num_uniform_buffers = ffi.types.u32 },
	{ threadcount_x = ffi.types.u32 },
	{ threadcount_y = ffi.types.u32 },
	{ threadcount_z = ffi.types.u32 },
	{ props = ffi.types.pointer },
})
export type SDL_GPUComputePipelineCreateInfo = typeof(SDL_GPUComputePipelineCreateInfo:new({}))

local SDL_GPUDepthStencilTargetInfo = ffi.struct({
	{ texture = ffi.types.pointer },
	{ clear_depth = ffi.types.float },
	{ load_op = ffi.types.pointer },
	{ store_op = ffi.types.pointer },
	{ stencil_load_op = ffi.types.pointer },
	{ stencil_store_op = ffi.types.pointer },
	{ cycle = ffi.types.u8 },
	{ clear_stencil = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
})
export type SDL_GPUDepthStencilTargetInfo = typeof(SDL_GPUDepthStencilTargetInfo:new({}))

local SDL_GPUBufferBinding = ffi.struct({
	{ buffer = ffi.types.pointer },
	{ offset = ffi.types.u32 },
})
export type SDL_GPUBufferBinding = typeof(SDL_GPUBufferBinding:new({}))

local SDL_GPUTextureSamplerBinding = ffi.struct({
	{ texture = ffi.types.pointer },
	{ sampler = ffi.types.pointer },
})
export type SDL_GPUTextureSamplerBinding = typeof(SDL_GPUTextureSamplerBinding:new({}))

local SDL_GPUStorageBufferReadWriteBinding = ffi.struct({
	{ buffer = ffi.types.pointer },
	{ cycle = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_GPUStorageBufferReadWriteBinding = typeof(SDL_GPUStorageBufferReadWriteBinding:new({}))

local SDL_GPUStorageTextureReadWriteBinding = ffi.struct({
	{ texture = ffi.types.pointer },
	{ mip_level = ffi.types.u32 },
	{ layer = ffi.types.u32 },
	{ cycle = ffi.types.u8 },
	{ padding1 = ffi.types.u8 },
	{ padding2 = ffi.types.u8 },
	{ padding3 = ffi.types.u8 },
})
export type SDL_GPUStorageTextureReadWriteBinding = typeof(SDL_GPUStorageTextureReadWriteBinding:new({}))

local SDL_GUID = ffi.struct({
	{ data = ffi.types.u8:array(16) },
})
export type SDL_GUID = typeof(SDL_GUID:new({}))

local SDL_HapticDirection = ffi.struct({
	{ type = ffi.types.u8 },
	{ dir = ffi.types.i32:array(3) },
})
export type SDL_HapticDirection = typeof(SDL_HapticDirection:new({}))

local SDL_HapticConstant = ffi.struct({
	{ type = ffi.types.u16 },
	{ direction = SDL_HapticDirection },
	{ length = ffi.types.u32 },
	{ delay = ffi.types.u16 },
	{ button = ffi.types.u16 },
	{ interval = ffi.types.u16 },
	{ level = ffi.types.i16 },
	{ attack_length = ffi.types.u16 },
	{ attack_level = ffi.types.u16 },
	{ fade_length = ffi.types.u16 },
	{ fade_level = ffi.types.u16 },
})
export type SDL_HapticConstant = typeof(SDL_HapticConstant:new({}))

local SDL_HapticPeriodic = ffi.struct({
	{ type = ffi.types.u16 },
	{ direction = SDL_HapticDirection },
	{ length = ffi.types.u32 },
	{ delay = ffi.types.u16 },
	{ button = ffi.types.u16 },
	{ interval = ffi.types.u16 },
	{ period = ffi.types.u16 },
	{ magnitude = ffi.types.i16 },
	{ offset = ffi.types.i16 },
	{ phase = ffi.types.u16 },
	{ attack_length = ffi.types.u16 },
	{ attack_level = ffi.types.u16 },
	{ fade_length = ffi.types.u16 },
	{ fade_level = ffi.types.u16 },
})
export type SDL_HapticPeriodic = typeof(SDL_HapticPeriodic:new({}))

local SDL_HapticCondition = ffi.struct({
	{ type = ffi.types.u16 },
	{ direction = SDL_HapticDirection },
	{ length = ffi.types.u32 },
	{ delay = ffi.types.u16 },
	{ button = ffi.types.u16 },
	{ interval = ffi.types.u16 },
	{ right_sat = ffi.types.u16:array(3) },
	{ left_sat = ffi.types.u16:array(3) },
	{ right_coeff = ffi.types.i16:array(3) },
	{ left_coeff = ffi.types.i16:array(3) },
	{ deadband = ffi.types.u16:array(3) },
	{ center = ffi.types.i16:array(3) },
})
export type SDL_HapticCondition = typeof(SDL_HapticCondition:new({}))

local SDL_HapticRamp = ffi.struct({
	{ type = ffi.types.u16 },
	{ direction = SDL_HapticDirection },
	{ length = ffi.types.u32 },
	{ delay = ffi.types.u16 },
	{ button = ffi.types.u16 },
	{ interval = ffi.types.u16 },
	{ start = ffi.types.i16 },
	{ ["end"] = ffi.types.i16 },
	{ attack_length = ffi.types.u16 },
	{ attack_level = ffi.types.u16 },
	{ fade_length = ffi.types.u16 },
	{ fade_level = ffi.types.u16 },
})
export type SDL_HapticRamp = typeof(SDL_HapticRamp:new({}))

local SDL_HapticLeftRight = ffi.struct({
	{ type = ffi.types.u16 },
	{ length = ffi.types.u32 },
	{ large_magnitude = ffi.types.u16 },
	{ small_magnitude = ffi.types.u16 },
})
export type SDL_HapticLeftRight = typeof(SDL_HapticLeftRight:new({}))

local SDL_HapticCustom = ffi.struct({
	{ type = ffi.types.u16 },
	{ direction = SDL_HapticDirection },
	{ length = ffi.types.u32 },
	{ delay = ffi.types.u16 },
	{ button = ffi.types.u16 },
	{ interval = ffi.types.u16 },
	{ channels = ffi.types.u8 },
	{ period = ffi.types.u16 },
	{ samples = ffi.types.u16 },
	{ data = ffi.types.pointer },
	{ attack_length = ffi.types.u16 },
	{ attack_level = ffi.types.u16 },
	{ fade_length = ffi.types.u16 },
	{ fade_level = ffi.types.u16 },
})
export type SDL_HapticCustom = typeof(SDL_HapticCustom:new({}))

local SDL_hid_device_info = ffi.struct({
	{ path = ffi.types.pointer },
	{ vendor_id = ffi.types.u16 },
	{ product_id = ffi.types.u16 },
	{ serial_number = ffi.types.pointer },
	{ release_number = ffi.types.u16 },
	{ manufacturer_string = ffi.types.pointer },
	{ product_string = ffi.types.pointer },
	{ usage_page = ffi.types.u16 },
	{ usage = ffi.types.u16 },
	{ interface_number = ffi.types.i32 },
	{ interface_class = ffi.types.i32 },
	{ interface_subclass = ffi.types.i32 },
	{ interface_protocol = ffi.types.i32 },
	{ bus_type = ffi.types.pointer },
	{ next = ffi.types.pointer },
})
export type SDL_hid_device_info = typeof(SDL_hid_device_info:new({}))

local SDL_IOStreamInterface = ffi.struct({
	{ version = ffi.types.u32 },
	{ size = ffi.types.pointer },
	{ seek = ffi.types.pointer },
	{ read = ffi.types.pointer },
	{ write = ffi.types.pointer },
	{ flush = ffi.types.pointer },
	{ close = ffi.types.pointer },
})
export type SDL_IOStreamInterface = typeof(SDL_IOStreamInterface:new({}))

local SDL_VirtualJoystickTouchpadDesc = ffi.struct({
	{ nfingers = ffi.types.u16 },
	{ padding = ffi.types.u16:array(3) },
})
export type SDL_VirtualJoystickTouchpadDesc = typeof(SDL_VirtualJoystickTouchpadDesc:new({}))

local SDL_VirtualJoystickSensorDesc = ffi.struct({
	{ type = ffi.types.pointer },
	{ rate = ffi.types.float },
})
export type SDL_VirtualJoystickSensorDesc = typeof(SDL_VirtualJoystickSensorDesc:new({}))

local SDL_VirtualJoystickDesc = ffi.struct({
	{ version = ffi.types.u32 },
	{ type = ffi.types.u16 },
	{ padding = ffi.types.u16 },
	{ vendor_id = ffi.types.u16 },
	{ product_id = ffi.types.u16 },
	{ naxes = ffi.types.u16 },
	{ nbuttons = ffi.types.u16 },
	{ nballs = ffi.types.u16 },
	{ nhats = ffi.types.u16 },
	{ ntouchpads = ffi.types.u16 },
	{ nsensors = ffi.types.u16 },
	{ padding2 = ffi.types.u16:array(2) },
	{ button_mask = ffi.types.u32 },
	{ axis_mask = ffi.types.u32 },
	{ name = ffi.types.pointer },
	{ touchpads = ffi.types.pointer },
	{ sensors = ffi.types.pointer },
	{ userdata = ffi.types.pointer },
	{ Update = ffi.types.pointer },
	{ SetPlayerIndex = ffi.types.pointer },
	{ Rumble = ffi.types.pointer },
	{ RumbleTriggers = ffi.types.pointer },
	{ SetLED = ffi.types.pointer },
	{ SendEffect = ffi.types.pointer },
	{ SetSensorsEnabled = ffi.types.pointer },
	{ Cleanup = ffi.types.pointer },
})
export type SDL_VirtualJoystickDesc = typeof(SDL_VirtualJoystickDesc:new({}))

local SDL_Locale = ffi.struct({
	{ language = ffi.types.pointer },
	{ country = ffi.types.pointer },
})
export type SDL_Locale = typeof(SDL_Locale:new({}))

local SDL_MessageBoxButtonData = ffi.struct({
	{ flags = ffi.types.pointer },
	{ buttonID = ffi.types.i32 },
	{ text = ffi.types.pointer },
})
export type SDL_MessageBoxButtonData = typeof(SDL_MessageBoxButtonData:new({}))

local SDL_MessageBoxColor = ffi.struct({
	{ r = ffi.types.u8 },
	{ g = ffi.types.u8 },
	{ b = ffi.types.u8 },
})
export type SDL_MessageBoxColor = typeof(SDL_MessageBoxColor:new({}))

local SDL_MessageBoxData = ffi.struct({
	{ flags = ffi.types.pointer },
	{ window = ffi.types.pointer },
	{ title = ffi.types.pointer },
	{ message = ffi.types.pointer },
	{ numbuttons = ffi.types.i32 },
	{ buttons = ffi.types.pointer },
	{ colorScheme = ffi.types.pointer },
})
export type SDL_MessageBoxData = typeof(SDL_MessageBoxData:new({}))

local SDL_InitState = ffi.struct({
	{ status = SDL_AtomicInt },
	{ thread = ffi.types.pointer },
	{ reserved = ffi.types.pointer },
})
export type SDL_InitState = typeof(SDL_InitState:new({}))

local SDL_Color = ffi.struct({
	{ r = ffi.types.u8 },
	{ g = ffi.types.u8 },
	{ b = ffi.types.u8 },
	{ a = ffi.types.u8 },
})
export type SDL_Color = typeof(SDL_Color:new({}))

local SDL_FColor = ffi.struct({
	{ r = ffi.types.float },
	{ g = ffi.types.float },
	{ b = ffi.types.float },
	{ a = ffi.types.float },
})
export type SDL_FColor = typeof(SDL_FColor:new({}))

local SDL_Palette = ffi.struct({
	{ ncolors = ffi.types.i32 },
	{ colors = ffi.types.pointer },
	{ version = ffi.types.u32 },
	{ refcount = ffi.types.i32 },
})
export type SDL_Palette = typeof(SDL_Palette:new({}))

local SDL_PixelFormatDetails = ffi.struct({
	{ format = ffi.types.pointer },
	{ bits_per_pixel = ffi.types.u8 },
	{ bytes_per_pixel = ffi.types.u8 },
	{ padding = ffi.types.u8:array(2) },
	{ Rmask = ffi.types.u32 },
	{ Gmask = ffi.types.u32 },
	{ Bmask = ffi.types.u32 },
	{ Amask = ffi.types.u32 },
	{ Rbits = ffi.types.u8 },
	{ Gbits = ffi.types.u8 },
	{ Bbits = ffi.types.u8 },
	{ Abits = ffi.types.u8 },
	{ Rshift = ffi.types.u8 },
	{ Gshift = ffi.types.u8 },
	{ Bshift = ffi.types.u8 },
	{ Ashift = ffi.types.u8 },
})
export type SDL_PixelFormatDetails = typeof(SDL_PixelFormatDetails:new({}))

local SDL_Point = ffi.struct({
	{ x = ffi.types.i32 },
	{ y = ffi.types.i32 },
})
export type SDL_Point = typeof(SDL_Point:new({}))

local SDL_FPoint = ffi.struct({
	{ x = ffi.types.float },
	{ y = ffi.types.float },
})
export type SDL_FPoint = typeof(SDL_FPoint:new({}))

local SDL_Rect = ffi.struct({
	{ x = ffi.types.i32 },
	{ y = ffi.types.i32 },
	{ w = ffi.types.i32 },
	{ h = ffi.types.i32 },
})
export type SDL_Rect = typeof(SDL_Rect:new({}))

local SDL_FRect = ffi.struct({
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ w = ffi.types.float },
	{ h = ffi.types.float },
})
export type SDL_FRect = typeof(SDL_FRect:new({}))

local SDL_Vertex = ffi.struct({
	{ position = SDL_FPoint },
	{ color = SDL_FColor },
	{ tex_coord = SDL_FPoint },
})
export type SDL_Vertex = typeof(SDL_Vertex:new({}))

local SDL_Texture = ffi.struct({
	{ format = ffi.types.pointer },
	{ w = ffi.types.i32 },
	{ h = ffi.types.i32 },
	{ refcount = ffi.types.i32 },
})
export type SDL_Texture = typeof(SDL_Texture:new({}))

local SDL_alignment_test = ffi.struct({
	{ a = ffi.types.u8 },
	{ b = ffi.types.pointer },
})
export type SDL_alignment_test = typeof(SDL_alignment_test:new({}))

local SDL_StorageInterface = ffi.struct({
	{ version = ffi.types.u32 },
	{ close = ffi.types.pointer },
	{ ready = ffi.types.pointer },
	{ enumerate = ffi.types.pointer },
	{ info = ffi.types.pointer },
	{ read_file = ffi.types.pointer },
	{ write_file = ffi.types.pointer },
	{ mkdir = ffi.types.pointer },
	{ remove = ffi.types.pointer },
	{ rename = ffi.types.pointer },
	{ copy = ffi.types.pointer },
	{ space_remaining = ffi.types.pointer },
})
export type SDL_StorageInterface = typeof(SDL_StorageInterface:new({}))

local SDL_Surface = ffi.struct({
	{ flags = ffi.types.pointer },
	{ format = ffi.types.pointer },
	{ w = ffi.types.i32 },
	{ h = ffi.types.i32 },
	{ pitch = ffi.types.i32 },
	{ pixels = ffi.types.pointer },
	{ refcount = ffi.types.i32 },
	{ reserved = ffi.types.pointer },
})
export type SDL_Surface = typeof(SDL_Surface:new({}))

local SDLTest_ArgumentParser = ffi.struct({
	{ parse_arguments = ffi.types.pointer },
	{ finalize = ffi.types.pointer },
	{ usage = ffi.types.pointer },
	{ data = ffi.types.pointer },
	{ next = ffi.types.pointer },
})
export type SDLTest_ArgumentParser = typeof(SDLTest_ArgumentParser:new({}))

local SDLTest_Crc32Context = ffi.struct({
	{ crc32_table = ffi.types.pointer:array(256) },
})
export type SDLTest_Crc32Context = typeof(SDLTest_Crc32Context:new({}))

local SDLTest_TextWindow = ffi.struct({
	{ rect = SDL_FRect },
	{ current = ffi.types.i32 },
	{ numlines = ffi.types.i32 },
	{ lines = ffi.types.pointer },
})
export type SDLTest_TextWindow = typeof(SDLTest_TextWindow:new({}))

local SDLTest_TestCaseReference = ffi.struct({
	{ testCase = ffi.types.pointer },
	{ name = ffi.types.pointer },
	{ description = ffi.types.pointer },
	{ enabled = ffi.types.i32 },
})
export type SDLTest_TestCaseReference = typeof(SDLTest_TestCaseReference:new({}))

local SDLTest_TestSuiteReference = ffi.struct({
	{ name = ffi.types.pointer },
	{ testSetUp = ffi.types.pointer },
	{ testCases = ffi.types.pointer },
	{ testTearDown = ffi.types.pointer },
})
export type SDLTest_TestSuiteReference = typeof(SDLTest_TestSuiteReference:new({}))

local SDLTest_Md5Context = ffi.struct({
	{ i = ffi.types.pointer:array(2) },
	{ buf = ffi.types.pointer:array(4) },
	{ ["in"] = ffi.types.u8:array(64) },
	{ digest = ffi.types.u8:array(16) },
})
export type SDLTest_Md5Context = typeof(SDLTest_Md5Context:new({}))

local SDL_DateTime = ffi.struct({
	{ year = ffi.types.i32 },
	{ month = ffi.types.i32 },
	{ day = ffi.types.i32 },
	{ hour = ffi.types.i32 },
	{ minute = ffi.types.i32 },
	{ second = ffi.types.i32 },
	{ nanosecond = ffi.types.i32 },
	{ day_of_week = ffi.types.i32 },
	{ utc_offset = ffi.types.i32 },
})
export type SDL_DateTime = typeof(SDL_DateTime:new({}))

local SDL_Finger = ffi.struct({
	{ id = ffi.types.pointer },
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ pressure = ffi.types.float },
})
export type SDL_Finger = typeof(SDL_Finger:new({}))

local SDL_DisplayMode = ffi.struct({
	{ displayID = ffi.types.pointer },
	{ format = ffi.types.pointer },
	{ w = ffi.types.i32 },
	{ h = ffi.types.i32 },
	{ pixel_density = ffi.types.float },
	{ refresh_rate = ffi.types.float },
	{ refresh_rate_numerator = ffi.types.i32 },
	{ refresh_rate_denominator = ffi.types.i32 },
	{ internal = ffi.types.pointer },
})
export type SDL_DisplayMode = typeof(SDL_DisplayMode:new({}))

local structs = {
	SDL_AssertData = SDL_AssertData,
	SDL_AsyncIOOutcome = SDL_AsyncIOOutcome,
	SDL_AtomicInt = SDL_AtomicInt,
	SDL_AtomicU32 = SDL_AtomicU32,
	SDL_AudioSpec = SDL_AudioSpec,
	SDL_CameraSpec = SDL_CameraSpec,
	SDL_DialogFileFilter = SDL_DialogFileFilter,
	EGLClientPixmapHI = EGLClientPixmapHI,
	SDL_CommonEvent = SDL_CommonEvent,
	SDL_DisplayEvent = SDL_DisplayEvent,
	SDL_WindowEvent = SDL_WindowEvent,
	SDL_KeyboardDeviceEvent = SDL_KeyboardDeviceEvent,
	SDL_KeyboardEvent = SDL_KeyboardEvent,
	SDL_TextEditingEvent = SDL_TextEditingEvent,
	SDL_TextEditingCandidatesEvent = SDL_TextEditingCandidatesEvent,
	SDL_TextInputEvent = SDL_TextInputEvent,
	SDL_MouseDeviceEvent = SDL_MouseDeviceEvent,
	SDL_MouseMotionEvent = SDL_MouseMotionEvent,
	SDL_MouseButtonEvent = SDL_MouseButtonEvent,
	SDL_MouseWheelEvent = SDL_MouseWheelEvent,
	SDL_JoyAxisEvent = SDL_JoyAxisEvent,
	SDL_JoyBallEvent = SDL_JoyBallEvent,
	SDL_JoyHatEvent = SDL_JoyHatEvent,
	SDL_JoyButtonEvent = SDL_JoyButtonEvent,
	SDL_JoyDeviceEvent = SDL_JoyDeviceEvent,
	SDL_JoyBatteryEvent = SDL_JoyBatteryEvent,
	SDL_GamepadAxisEvent = SDL_GamepadAxisEvent,
	SDL_GamepadButtonEvent = SDL_GamepadButtonEvent,
	SDL_GamepadDeviceEvent = SDL_GamepadDeviceEvent,
	SDL_GamepadTouchpadEvent = SDL_GamepadTouchpadEvent,
	SDL_GamepadSensorEvent = SDL_GamepadSensorEvent,
	SDL_AudioDeviceEvent = SDL_AudioDeviceEvent,
	SDL_CameraDeviceEvent = SDL_CameraDeviceEvent,
	SDL_RenderEvent = SDL_RenderEvent,
	SDL_TouchFingerEvent = SDL_TouchFingerEvent,
	SDL_PenProximityEvent = SDL_PenProximityEvent,
	SDL_PenMotionEvent = SDL_PenMotionEvent,
	SDL_PenTouchEvent = SDL_PenTouchEvent,
	SDL_PenButtonEvent = SDL_PenButtonEvent,
	SDL_PenAxisEvent = SDL_PenAxisEvent,
	SDL_DropEvent = SDL_DropEvent,
	SDL_ClipboardEvent = SDL_ClipboardEvent,
	SDL_SensorEvent = SDL_SensorEvent,
	SDL_QuitEvent = SDL_QuitEvent,
	SDL_UserEvent = SDL_UserEvent,
	SDL_PathInfo = SDL_PathInfo,
	SDL_GPUViewport = SDL_GPUViewport,
	SDL_GPUTextureTransferInfo = SDL_GPUTextureTransferInfo,
	SDL_GPUTransferBufferLocation = SDL_GPUTransferBufferLocation,
	SDL_GPUTextureLocation = SDL_GPUTextureLocation,
	SDL_GPUTextureRegion = SDL_GPUTextureRegion,
	SDL_GPUBlitRegion = SDL_GPUBlitRegion,
	SDL_GPUBufferLocation = SDL_GPUBufferLocation,
	SDL_GPUBufferRegion = SDL_GPUBufferRegion,
	SDL_GPUIndirectDrawCommand = SDL_GPUIndirectDrawCommand,
	SDL_GPUIndexedIndirectDrawCommand = SDL_GPUIndexedIndirectDrawCommand,
	SDL_GPUIndirectDispatchCommand = SDL_GPUIndirectDispatchCommand,
	SDL_GPUSamplerCreateInfo = SDL_GPUSamplerCreateInfo,
	SDL_GPUVertexBufferDescription = SDL_GPUVertexBufferDescription,
	SDL_GPUVertexAttribute = SDL_GPUVertexAttribute,
	SDL_GPUVertexInputState = SDL_GPUVertexInputState,
	SDL_GPUStencilOpState = SDL_GPUStencilOpState,
	SDL_GPUColorTargetBlendState = SDL_GPUColorTargetBlendState,
	SDL_GPUShaderCreateInfo = SDL_GPUShaderCreateInfo,
	SDL_GPUTextureCreateInfo = SDL_GPUTextureCreateInfo,
	SDL_GPUBufferCreateInfo = SDL_GPUBufferCreateInfo,
	SDL_GPUTransferBufferCreateInfo = SDL_GPUTransferBufferCreateInfo,
	SDL_GPURasterizerState = SDL_GPURasterizerState,
	SDL_GPUMultisampleState = SDL_GPUMultisampleState,
	SDL_GPUDepthStencilState = SDL_GPUDepthStencilState,
	SDL_GPUColorTargetDescription = SDL_GPUColorTargetDescription,
	SDL_GPUGraphicsPipelineTargetInfo = SDL_GPUGraphicsPipelineTargetInfo,
	SDL_GPUGraphicsPipelineCreateInfo = SDL_GPUGraphicsPipelineCreateInfo,
	SDL_GPUComputePipelineCreateInfo = SDL_GPUComputePipelineCreateInfo,
	SDL_GPUColorTargetInfo = SDL_GPUColorTargetInfo,
	SDL_GPUDepthStencilTargetInfo = SDL_GPUDepthStencilTargetInfo,
	SDL_GPUBlitInfo = SDL_GPUBlitInfo,
	SDL_GPUBufferBinding = SDL_GPUBufferBinding,
	SDL_GPUTextureSamplerBinding = SDL_GPUTextureSamplerBinding,
	SDL_GPUStorageBufferReadWriteBinding = SDL_GPUStorageBufferReadWriteBinding,
	SDL_GPUStorageTextureReadWriteBinding = SDL_GPUStorageTextureReadWriteBinding,
	SDL_GUID = SDL_GUID,
	SDL_HapticDirection = SDL_HapticDirection,
	SDL_HapticConstant = SDL_HapticConstant,
	SDL_HapticPeriodic = SDL_HapticPeriodic,
	SDL_HapticCondition = SDL_HapticCondition,
	SDL_HapticRamp = SDL_HapticRamp,
	SDL_HapticLeftRight = SDL_HapticLeftRight,
	SDL_HapticCustom = SDL_HapticCustom,
	SDL_hid_device_info = SDL_hid_device_info,
	SDL_IOStreamInterface = SDL_IOStreamInterface,
	SDL_VirtualJoystickTouchpadDesc = SDL_VirtualJoystickTouchpadDesc,
	SDL_VirtualJoystickSensorDesc = SDL_VirtualJoystickSensorDesc,
	SDL_VirtualJoystickDesc = SDL_VirtualJoystickDesc,
	SDL_Locale = SDL_Locale,
	SDL_MessageBoxButtonData = SDL_MessageBoxButtonData,
	SDL_MessageBoxColor = SDL_MessageBoxColor,
	SDL_MessageBoxColorScheme = SDL_MessageBoxColorScheme,
	SDL_MessageBoxData = SDL_MessageBoxData,
	SDL_InitState = SDL_InitState,
	SDL_Color = SDL_Color,
	SDL_FColor = SDL_FColor,
	SDL_Palette = SDL_Palette,
	SDL_PixelFormatDetails = SDL_PixelFormatDetails,
	SDL_Point = SDL_Point,
	SDL_FPoint = SDL_FPoint,
	SDL_Rect = SDL_Rect,
	SDL_FRect = SDL_FRect,
	SDL_Vertex = SDL_Vertex,
	SDL_Texture = SDL_Texture,
	SDL_alignment_test = SDL_alignment_test,
	SDL_StorageInterface = SDL_StorageInterface,
	SDL_Surface = SDL_Surface,
	SDLTest_ArgumentParser = SDLTest_ArgumentParser,
	SDLTest_CommonState = SDLTest_CommonState,
	SDLTest_Crc32Context = SDLTest_Crc32Context,
	SDLTest_TextWindow = SDLTest_TextWindow,
	SDLTest_TestCaseReference = SDLTest_TestCaseReference,
	SDLTest_TestSuiteReference = SDLTest_TestSuiteReference,
	SDLTest_Md5Context = SDLTest_Md5Context,
	SDL_DateTime = SDL_DateTime,
	SDL_Finger = SDL_Finger,
	SDL_DisplayMode = SDL_DisplayMode,
	SDL_Event = SDL_Event,
}

return structs
