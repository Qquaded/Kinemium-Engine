--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Struct definitions (ordered by dependencies)
-- NOTE: Some structs may have FIXME comments for array sizes that need manual definition

local AVProbeData = ffi.struct({
	{ buf_size = ffi.types.i32 },
})
export type AVProbeData = typeof(AVProbeData:new({}))

local AVOutputFormat = ffi.struct({
	{ audio_codec = ffi.types.pointer },
	{ video_codec = ffi.types.pointer },
	{ subtitle_codec = ffi.types.pointer },
	{ flags = ffi.types.i32 },
})
export type AVOutputFormat = typeof(AVOutputFormat:new({}))

local AVInputFormat = ffi.struct({
	{ flags = ffi.types.i32 },
})
export type AVInputFormat = typeof(AVInputFormat:new({}))

local AVIndexEntry = ffi.struct({
	{ pos = ffi.types.i64 },
	{ timestamp = ffi.types.i64 },
	{ flags = ffi.types.i32 },
	{ size = ffi.types.i32 },
	{ min_distance = ffi.types.i32 },
})
export type AVIndexEntry = typeof(AVIndexEntry:new({}))

local AVStream = ffi.struct({
	{ av_class = ffi.types.pointer }, -- offset 0 (private field)
	{ index = ffi.types.i32 }, -- offset 8
	{ id = ffi.types.i32 }, -- offset 12
	{ codecpar = ffi.types.pointer }, -- offset 16  ← HERE!
	{ time_base = ffi.types.pointer }, -- offset 24
	{ start_time = ffi.types.i64 }, -- offset 32
	{ duration = ffi.types.i64 }, -- offset 40
	{ nb_frames = ffi.types.i64 }, -- offset 48
	{ disposition = ffi.types.i32 }, -- offset 56
	{ discard = ffi.types.pointer }, -- offset 60 (+ padding)
	{ sample_aspect_ratio = ffi.types.pointer },
	{ avg_frame_rate = ffi.types.pointer },
	{ attached_pic = ffi.types.pointer },
	{ event_flags = ffi.types.i32 },
	{ r_frame_rate = ffi.types.pointer },
	{ pts_wrap_bits = ffi.types.i32 },
})
export type AVStream = typeof(AVStream:new({}))

local AVStreamGroupLCEVC = ffi.struct({
	{ lcevc_index = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
})
export type AVStreamGroupLCEVC = typeof(AVStreamGroupLCEVC:new({}))

local params = ffi.struct({
	{ index = ffi.types.i32 },
	{ id = ffi.types.i64 },
	{ type = ffi.types.pointer },
})
export type params = typeof(params:new({}))

local AVProgram = ffi.struct({
	{ id = ffi.types.i32 },
	{ flags = ffi.types.i32 },
	{ discard = ffi.types.pointer },
	{ nb_stream_indexes = ffi.types.i32 },
	{ program_num = ffi.types.i32 },
	{ pmt_pid = ffi.types.i32 },
	{ pcr_pid = ffi.types.i32 },
	{ pmt_version = ffi.types.i32 },
	{ start_time = ffi.types.i64 },
	{ end_time = ffi.types.i64 },
	{ pts_wrap_reference = ffi.types.i64 },
	{ pts_wrap_behavior = ffi.types.i32 },
})
export type AVProgram = typeof(AVProgram:new({}))

local AVChapter = ffi.struct({
	{ id = ffi.types.i64 },
	{ time_base = ffi.types.pointer },
})
export type AVChapter = typeof(AVChapter:new({}))

local AVFormatContext = ffi.struct({
	{ av_class = ffi.types.pointer }, -- offset 0
	{ iformat = ffi.types.pointer }, -- offset 8
	{ oformat = ffi.types.pointer }, -- offset 16
	{ priv_data = ffi.types.pointer }, -- offset 24
	{ pb = ffi.types.pointer }, -- offset 32
	{ ctx_flags = ffi.types.i32 }, -- offset 40
	{ nb_streams = ffi.types.u32 }, -- offset 44
	{ streams = ffi.types.pointer }, -- offset 48
	{ nb_stream_groups = ffi.types.u32 }, -- offset 56 (after padding)
	{ nb_chapters = ffi.types.u32 },
	{ start_time = ffi.types.i64 },
	{ duration = ffi.types.i64 },
	{ bit_rate = ffi.types.i64 },
	{ packet_size = ffi.types.i32 },
	{ max_delay = ffi.types.i32 },
	{ flags = ffi.types.i32 },
	{ probesize = ffi.types.i64 },
	{ max_analyze_duration = ffi.types.i64 },
	{ keylen = ffi.types.i32 },
	{ nb_programs = ffi.types.i32 },
	{ video_codec_id = ffi.types.i32 },
	{ audio_codec_id = ffi.types.i32 },
	{ subtitle_codec_id = ffi.types.i32 },
	{ data_codec_id = ffi.types.i32 },
	{ start_time_realtime = ffi.types.i64 },
	{ fps_probe_size = ffi.types.i32 },
	{ error_recognition = ffi.types.i32 },
	{ interrupt_callback = ffi.types.pointer },
	{ debug = ffi.types.i32 },
	{ max_streams = ffi.types.i32 },
	{ max_index_size = ffi.types.i32 },
	{ max_picture_buffer = ffi.types.i32 },
	{ max_interleave_delta = ffi.types.i64 },
	{ max_ts_probe = ffi.types.i32 },
	{ max_chunk_duration = ffi.types.i32 },
	{ max_chunk_size = ffi.types.i32 },
	{ max_probe_packets = ffi.types.i32 },
	{ strict_std_compliance = ffi.types.i32 },
	{ event_flags = ffi.types.i32 },
	{ avoid_negative_ts = ffi.types.i32 },
	{ audio_preload = ffi.types.i32 },
	{ use_wallclock_as_timestamps = ffi.types.i32 },
	{ skip_estimate_duration_from_pts = ffi.types.i32 },
	{ avio_flags = ffi.types.i32 },
	{ duration_estimation_method = ffi.types.pointer },
	{ skip_initial_bytes = ffi.types.i64 },
	{ correct_ts_overflow = ffi.types.i32 },
	{ seek2any = ffi.types.i32 },
	{ flush_packets = ffi.types.i32 },
	{ probe_score = ffi.types.i32 },
	{ format_probesize = ffi.types.i32 },
	{ io_repositioned = ffi.types.i32 },
	{ metadata_header_padding = ffi.types.i32 },
	{ control_message_cb = ffi.types.pointer },
	{ output_ts_offset = ffi.types.i64 },
	{ duration_probesize = ffi.types.i64 },
})
export type AVFormatContext = typeof(AVFormatContext:new({}))

local AVIODirEntry = ffi.struct({
	{ type = ffi.types.i32 },
	{ utf8 = ffi.types.i32 },
	{ size = ffi.types.i64 },
	{ modification_timestamp = ffi.types.i64 },
	{ access_timestamp = ffi.types.i64 },
	{ status_change_timestamp = ffi.types.i64 },
	{ user_id = ffi.types.i64 },
	{ group_id = ffi.types.i64 },
	{ filemode = ffi.types.i64 },
})
export type AVIODirEntry = typeof(AVIODirEntry:new({}))

local AVIOContext = ffi.struct({
	{ buffer_size = ffi.types.i32 },
	{ pos = ffi.types.i64 },
	{ eof_reached = ffi.types.i32 },
	{ error = ffi.types.i32 },
	{ write_flag = ffi.types.i32 },
	{ max_packet_size = ffi.types.i32 },
	{ min_packet_size = ffi.types.i32 },
	{ checksum = ffi.types.i32 },
	{ seekable = ffi.types.i32 },
	{ direct = ffi.types.i32 },
	{ ignore_boundary_point = ffi.types.i32 },
	{ bytes_read = ffi.types.i64 },
	{ bytes_written = ffi.types.i64 },
})
export type AVIOContext = typeof(AVIOContext:new({}))

-- Function definitions
local funcs = {
	av_get_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	av_append_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	av_disposition_from_string = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avformat_version = { returns = ffi.types.pointer, args = {} },
	avformat_network_init = { returns = ffi.types.i32, args = {} },
	avformat_network_deinit = { returns = ffi.types.i32, args = {} },
	avformat_free_context = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avformat_stream_group_add_stream = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avformat_alloc_output_context2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_probe_input_buffer2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	av_probe_input_buffer = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	avformat_open_input = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	avformat_find_stream_info = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_program_add_stream_index = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	av_find_best_stream = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	av_read_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_seek_frame = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i64, ffi.types.i32 },
	},
	avformat_seek_file = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i64, ffi.types.i64, ffi.types.i64, ffi.types.i32 },
	},
	avformat_flush = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_read_play = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_read_pause = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avformat_close_input = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avformat_write_header = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avformat_init_output = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_write_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_interleaved_write_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_write_uncoded_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer } },
	av_interleaved_write_uncoded_frame = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	av_write_uncoded_frame_query = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_write_trailer = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_guess_codec = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_get_output_timestamp = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i64, ffi.types.i64 },
	},
	av_hex_dump = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	av_hex_dump_log = {
		returns = ffi.types.void,
		args = { ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	av_pkt_dump2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	av_pkt_dump_log2 = {
		returns = ffi.types.void,
		args = { ffi.types.i32, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	av_codec_get_id = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	av_codec_get_tag = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_codec_get_tag2 = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 } },
	av_find_default_stream_index = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_index_search_timestamp = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i64, ffi.types.i32 } },
	avformat_index_get_entries_count = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_add_index_entry = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i64, ffi.types.i64, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	av_url_split = {
		returns = ffi.types.void,
		args = {
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	av_dump_format = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	av_get_frame_filename2 = {
		returns = ffi.types.i32,
		args = { ffi.types.i8, ffi.types.i32, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	av_get_frame_filename = {
		returns = ffi.types.i32,
		args = { ffi.types.i8, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	av_filename_number_test = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_sdp_create = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32 },
	},
	av_match_ext = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avformat_query_codec = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	av_guess_sample_aspect_ratio = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_guess_frame_rate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	avformat_match_stream_specifier = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	avformat_queue_attached_pictures = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avformat_transfer_internal_stream_timing_info = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_stream_get_codec_timebase = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	avio_check = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	avio_open_dir = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	avio_read_dir = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_close_dir = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_free_directory_entry = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avio_context_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avio_w8 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	avio_write = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	avio_wl64 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	avio_wb64 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	avio_wl32 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_wb32 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_wl24 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_wb24 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_wl16 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_wb16 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	avio_put_str = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_put_str16le = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_put_str16be = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_write_marker = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i64, ffi.types.pointer } },
	avio_seek = { returns = ffi.types.i64, args = { ffi.types.pointer, ffi.types.i64, ffi.types.i32 } },
	avio_skip = { returns = ffi.types.i64, args = { ffi.types.pointer, ffi.types.i64 } },
	avio_size = { returns = ffi.types.i64, args = { ffi.types.pointer } },
	avio_feof = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_vprintf = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	avio_print_string_array = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_flush = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avio_read = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8, ffi.types.i32 } },
	avio_read_partial = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8, ffi.types.i32 } },
	avio_r8 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rl16 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rl24 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rl32 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rl64 = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	avio_rb16 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rb24 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rb32 = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_rb64 = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	avio_get_str = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32 } },
	avio_get_str16le = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32 },
	},
	avio_get_str16be = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32 },
	},
	avio_open = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	avio_open2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	avio_close = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_closep = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_open_dyn_buf = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avio_get_dyn_buf = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8 } },
	avio_close_dyn_buf = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8 } },
	avio_pause = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	avio_seek_time = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i64, ffi.types.i32 },
	},
	avio_read_to_bprint = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 } },
	avio_accept = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avio_handshake = { returns = ffi.types.i32, args = { ffi.types.pointer } },
}

local structs = {
	AVProbeData = AVProbeData,
	AVOutputFormat = AVOutputFormat,
	AVInputFormat = AVInputFormat,
	AVIndexEntry = AVIndexEntry,
	AVStream = AVStream,
	AVStreamGroupLCEVC = AVStreamGroupLCEVC,
	params = params,
	AVProgram = AVProgram,
	AVChapter = AVChapter,
	AVFormatContext = AVFormatContext,
	AVIODirEntry = AVIODirEntry,
	AVIOContext = AVIOContext,
}

return { funcs = funcs, structs = structs }
