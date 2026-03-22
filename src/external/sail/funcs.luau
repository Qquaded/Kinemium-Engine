local ffi = zune.ffi

-- Type aliases for FFI
type int = number
type float = number
type bool = boolean
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)

export type Fns = {
	-- IO allocation functions
	sail_alloc_io_read_file: (path: cstring, io: FFIPointer) -> FFIPointer,
	sail_alloc_io_read_memory: (buffer: FFIPointer, length: int, io: FFIPointer) -> FFIPointer,
	sail_alloc_io_read_write_file: (path: cstring, io: FFIPointer) -> FFIPointer,
	sail_alloc_io_read_write_memory: (buffer: FFIPointer, length: int, io: FFIPointer) -> FFIPointer,
	sail_alloc_io_write_expanding_buffer: (initial_capacity: int, io: FFIPointer) -> FFIPointer,

	-- Codec bundle functions
	sail_codec_bundle_list: () -> FFIPointer,

	-- Codec info functions
	sail_codec_info_by_magic_number_from_io: (io: FFIPointer, codec_info: FFIPointer) -> FFIPointer,
	sail_codec_info_by_magic_number_from_memory: (
		buffer: FFIPointer,
		buffer_size: int,
		codec_info: FFIPointer
	) -> FFIPointer,
	sail_codec_info_by_magic_number_from_path: (path: cstring, codec_info: FFIPointer) -> FFIPointer,
	sail_codec_info_from_extension: (extension: cstring, codec_info: FFIPointer) -> FFIPointer,
	sail_codec_info_from_mime_type: (mime_type: cstring, codec_info: FFIPointer) -> FFIPointer,
	sail_codec_info_from_name: (name: cstring, codec_info: FFIPointer) -> FFIPointer,
	sail_codec_info_from_path: (path: cstring, codec_info: FFIPointer) -> FFIPointer,

	-- Initialization functions
	sail_init: () -> FFIPointer,
	sail_init_with_flags: (flags: int) -> FFIPointer,
	sail_finish: () -> (),
	sail_unload_codecs: () -> FFIPointer,

	-- IO buffer functions
	sail_io_expanding_buffer_size: (io: FFIPointer, size: FFIPointer) -> FFIPointer,

	-- IO noop functions
	sail_io_noop_close: (stream: FFIPointer) -> FFIPointer,
	sail_io_noop_eof: (stream: FFIPointer, result: FFIPointer) -> FFIPointer,
	sail_io_noop_flush: (stream: FFIPointer) -> FFIPointer,
	sail_io_noop_seek: (stream: FFIPointer, offset: int, whence: int) -> FFIPointer,
	sail_io_noop_strict_read: (stream: FFIPointer, buf: FFIPointer, size_to_read: int) -> FFIPointer,
	sail_io_noop_strict_write: (stream: FFIPointer, buf: FFIPointer, size_to_write: int) -> FFIPointer,
	sail_io_noop_tell: (stream: FFIPointer, offset: FFIPointer) -> FFIPointer,
	sail_io_noop_tolerant_read: (
		stream: FFIPointer,
		buf: FFIPointer,
		size_to_read: int,
		read_size: FFIPointer
	) -> FFIPointer,
	sail_io_noop_tolerant_write: (
		stream: FFIPointer,
		buf: FFIPointer,
		size_to_write: int,
		written_size: FFIPointer
	) -> FFIPointer,

	-- IO not implemented functions
	sail_io_not_implemented_close: (stream: FFIPointer) -> FFIPointer,
	sail_io_not_implemented_eof: (stream: FFIPointer, result: FFIPointer) -> FFIPointer,
	sail_io_not_implemented_flush: (stream: FFIPointer) -> FFIPointer,
	sail_io_not_implemented_seek: (stream: FFIPointer, offset: int, whence: int) -> FFIPointer,
	sail_io_not_implemented_size: (stream: FFIPointer, size: FFIPointer) -> FFIPointer,
	sail_io_not_implemented_strict_read: (stream: FFIPointer, buf: FFIPointer, size_to_read: int) -> FFIPointer,
	sail_io_not_implemented_strict_write: (stream: FFIPointer, buf: FFIPointer, size_to_write: int) -> FFIPointer,
	sail_io_not_implemented_tell: (stream: FFIPointer, offset: FFIPointer) -> FFIPointer,
	sail_io_not_implemented_tolerant_read: (
		stream: FFIPointer,
		buf: FFIPointer,
		size_to_read: int,
		read_size: FFIPointer
	) -> FFIPointer,
	sail_io_not_implemented_tolerant_write: (
		stream: FFIPointer,
		buf: FFIPointer,
		size_to_write: int,
		written_size: FFIPointer
	) -> FFIPointer,

	-- Load functions
	sail_load_from_file: (path: cstring, image: FFIPointer) -> FFIPointer,
	sail_load_from_memory: (buffer: FFIPointer, buffer_size: int, image: FFIPointer) -> FFIPointer,
	sail_load_next_frame: (state: FFIPointer, image: FFIPointer) -> FFIPointer,
	sail_probe_file: (path: cstring, image: FFIPointer, codec_info: FFIPointer) -> FFIPointer,
	sail_probe_io: (io: FFIPointer, image: FFIPointer, codec_info: FFIPointer) -> FFIPointer,
	sail_probe_memory: (buffer: FFIPointer, buffer_size: int, image: FFIPointer, codec_info: FFIPointer) -> FFIPointer,
	sail_start_loading_from_file: (path: cstring, codec_info: FFIPointer, state: FFIPointer) -> FFIPointer,
	sail_start_loading_from_file_with_options: (
		path: cstring,
		codec_info: FFIPointer,
		load_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_loading_from_io: (io: FFIPointer, codec_info: FFIPointer, state: FFIPointer) -> FFIPointer,
	sail_start_loading_from_io_with_options: (
		io: FFIPointer,
		codec_info: FFIPointer,
		load_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_loading_from_memory: (
		buffer: FFIPointer,
		buffer_size: int,
		codec_info: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_loading_from_memory_with_options: (
		buffer: FFIPointer,
		buffer_size: int,
		codec_info: FFIPointer,
		load_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,

	-- Save functions
	sail_save_into_file: (path: cstring, image: FFIPointer) -> FFIPointer,
	sail_save_into_memory: (buffer: FFIPointer, buffer_size: int, image: FFIPointer, written: FFIPointer) -> FFIPointer,
	sail_start_saving_into_file: (path: cstring, codec_info: FFIPointer, state: FFIPointer) -> FFIPointer,
	sail_start_saving_into_file_with_options: (
		path: cstring,
		codec_info: FFIPointer,
		save_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_saving_into_io: (io: FFIPointer, codec_info: FFIPointer, state: FFIPointer) -> FFIPointer,
	sail_start_saving_into_io_with_options: (
		io: FFIPointer,
		codec_info: FFIPointer,
		save_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_saving_into_memory: (
		buffer: FFIPointer,
		buffer_size: int,
		codec_info: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,
	sail_start_saving_into_memory_with_options: (
		buffer: FFIPointer,
		buffer_size: int,
		codec_info: FFIPointer,
		save_options: FFIPointer,
		state: FFIPointer
	) -> FFIPointer,

	-- Stop functions
	sail_stop_loading: (state: FFIPointer) -> FFIPointer,
	sail_stop_saving: (state: FFIPointer) -> FFIPointer,
	sail_stop_saving_with_written: (state: FFIPointer, written: FFIPointer) -> FFIPointer,

	-- Write function
	sail_write_next_frame: (state: FFIPointer, image: FFIPointer) -> FFIPointer,
}

local funcs = {
	-- IO allocation functions
	sail_alloc_io_read_file = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_alloc_io_read_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_alloc_io_read_write_file = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_alloc_io_read_write_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_alloc_io_write_expanding_buffer = { returns = ffi.types.pointer, args = { ffi.types.u64, ffi.types.pointer } },

	-- Codec bundle functions
	sail_codec_bundle_list = { returns = ffi.types.pointer, args = {} },

	-- Codec info functions
	sail_codec_info_by_magic_number_from_io = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	sail_codec_info_by_magic_number_from_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_codec_info_by_magic_number_from_path = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	sail_codec_info_from_extension = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_codec_info_from_mime_type = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_codec_info_from_name = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_codec_info_from_path = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },

	-- Initialization functions
	sail_init = { returns = ffi.types.pointer, args = {} },
	sail_init_with_flags = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	sail_finish = { returns = ffi.types.void, args = {} },
	sail_unload_codecs = { returns = ffi.types.pointer, args = {} },

	-- IO buffer functions
	sail_io_expanding_buffer_size = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },

	-- IO noop functions
	sail_io_noop_close = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_io_noop_eof = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_io_noop_flush = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_io_noop_seek = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i64, ffi.types.i32 } },
	sail_io_noop_strict_read = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	sail_io_noop_strict_write = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	sail_io_noop_tell = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_io_noop_tolerant_read = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_io_noop_tolerant_write = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},

	-- IO not implemented functions
	sail_io_not_implemented_close = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_io_not_implemented_eof = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_io_not_implemented_flush = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_io_not_implemented_seek = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i64, ffi.types.i32 },
	},
	sail_io_not_implemented_size = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_io_not_implemented_strict_read = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	sail_io_not_implemented_strict_write = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	sail_io_not_implemented_tell = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_io_not_implemented_tolerant_read = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_io_not_implemented_tolerant_write = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},

	-- Load functions
	sail_load_from_file = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_load_from_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	sail_load_next_frame = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_probe_file = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_probe_io = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	sail_probe_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_file = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_file_with_options = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_io = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_io_with_options = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_loading_from_memory_with_options = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	-- Save functions
	sail_save_into_file = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	sail_save_into_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_file = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_file_with_options = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_io = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_io_with_options = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_memory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	sail_start_saving_into_memory_with_options = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	-- Stop functions
	sail_stop_loading = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_stop_saving = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	sail_stop_saving_with_written = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },

	-- Write function
	sail_write_next_frame = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
}

return funcs
