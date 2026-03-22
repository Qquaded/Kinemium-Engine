--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Struct definitions (ordered by dependencies)
-- NOTE: Some structs may have FIXME comments for array sizes that need manual definition

local RcOverride = ffi.struct({
	{ start_frame = ffi.types.i32 },
	{ end_frame = ffi.types.i32 },
	{ qscale = ffi.types.i32 },
	{ quality_factor = ffi.types.float },
})
export type RcOverride = typeof(RcOverride:new({}))

local AVCodecContext = ffi.struct({
	{ av_class = ffi.types.pointer },
	{ log_level_offset = ffi.types.i32 },
	{ codec_type = ffi.types.i32 },
	{ codec_id = ffi.types.i32 },
	{ codec_tag = ffi.types.u32 },
	{ bit_rate = ffi.types.i64 },
	{ flags = ffi.types.i32 },
	{ flags2 = ffi.types.i32 },
	{ extradata_size = ffi.types.i32 },
	{ time_base = ffi.types.pointer },
	{ pkt_timebase = ffi.types.pointer },
	{ framerate = ffi.types.pointer },
	{ delay = ffi.types.i32 },
	{ sample_aspect_ratio = ffi.types.pointer },
	{ pix_fmt = ffi.types.i32 },
	{ sw_pix_fmt = ffi.types.i32 },
	{ color_primaries = ffi.types.i32 },
	{ color_trc = ffi.types.i32 },
	{ colorspace = ffi.types.i32 },
	{ color_range = ffi.types.i32 },
	{ chroma_sample_location = ffi.types.i32 },
	{ field_order = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
	{ refs = ffi.types.i32 },
	{ has_b_frames = ffi.types.i32 },
	{ slice_flags = ffi.types.i32 },
	{ max_b_frames = ffi.types.i32 },
	{ b_quant_factor = ffi.types.float },
	{ b_quant_offset = ffi.types.float },
	{ i_quant_factor = ffi.types.float },
	{ i_quant_offset = ffi.types.float },
	{ lumi_masking = ffi.types.float },
	{ temporal_cplx_masking = ffi.types.float },
	{ spatial_cplx_masking = ffi.types.float },
	{ p_masking = ffi.types.float },
	{ dark_masking = ffi.types.float },
	{ nsse_weight = ffi.types.i32 },
	{ me_cmp = ffi.types.i32 },
	{ me_sub_cmp = ffi.types.i32 },
	{ mb_cmp = ffi.types.i32 },
	{ ildct_cmp = ffi.types.i32 },
	{ dia_size = ffi.types.i32 },
	{ last_predictor_count = ffi.types.i32 },
	{ me_pre_cmp = ffi.types.i32 },
	{ pre_dia_size = ffi.types.i32 },
	{ me_subpel_quality = ffi.types.i32 },
	{ me_range = ffi.types.i32 },
	{ mb_decision = ffi.types.i32 },
	{ intra_dc_precision = ffi.types.i32 },
	{ mb_lmin = ffi.types.i32 },
	{ mb_lmax = ffi.types.i32 },
	{ bidir_refine = ffi.types.i32 },
	{ keyint_min = ffi.types.i32 },
	{ gop_size = ffi.types.i32 },
	{ mv0_threshold = ffi.types.i32 },
	{ slices = ffi.types.i32 },
	{ sample_rate = ffi.types.i32 },
	{ sample_fmt = ffi.types.i32 },
	{ ch_layout = ffi.types.pointer },
	{ frame_size = ffi.types.i32 },
	{ block_align = ffi.types.i32 },
	{ cutoff = ffi.types.i32 },
	{ audio_service_type = ffi.types.i32 },
	{ request_sample_fmt = ffi.types.i32 },
	{ initial_padding = ffi.types.i32 },
	{ trailing_padding = ffi.types.i32 },
	{ seek_preroll = ffi.types.i32 },
	{ bit_rate_tolerance = ffi.types.i32 },
	{ global_quality = ffi.types.i32 },
	{ compression_level = ffi.types.i32 },
	{ qcompress = ffi.types.float },
	{ qblur = ffi.types.float },
	{ qmin = ffi.types.i32 },
	{ qmax = ffi.types.i32 },
	{ max_qdiff = ffi.types.i32 },
	{ rc_buffer_size = ffi.types.i32 },
	{ rc_override_count = ffi.types.i32 },
	{ rc_max_rate = ffi.types.i64 },
	{ rc_min_rate = ffi.types.i64 },
	{ rc_max_available_vbv_use = ffi.types.float },
	{ rc_min_vbv_overflow_use = ffi.types.float },
	{ rc_initial_buffer_occupancy = ffi.types.i32 },
	{ trellis = ffi.types.i32 },
	{ workaround_bugs = ffi.types.i32 },
	{ strict_std_compliance = ffi.types.i32 },
	{ error_concealment = ffi.types.i32 },
	{ debug = ffi.types.i32 },
	{ err_recognition = ffi.types.i32 },
	{ hwaccel_flags = ffi.types.i32 },
	{ extra_hw_frames = ffi.types.i32 },
	-- FIXME: Array size needs manual definition: AV_NUM_DATA_POINTERS
	-- { error = ffi.types.u64:array(AV_NUM_DATA_POINTERS) },
	{ dct_algo = ffi.types.i32 },
	{ idct_algo = ffi.types.i32 },
	{ bits_per_coded_sample = ffi.types.i32 },
	{ bits_per_raw_sample = ffi.types.i32 },
	{ thread_count = ffi.types.i32 },
	{ thread_type = ffi.types.i32 },
	{ active_thread_type = ffi.types.i32 },
	{ profile = ffi.types.i32 },
	{ level = ffi.types.i32 },
	{ properties = ffi.types.i32 },
	{ skip_loop_filter = ffi.types.i32 },
	{ skip_idct = ffi.types.i32 },
	{ skip_frame = ffi.types.i32 },
	{ skip_alpha = ffi.types.i32 },
	{ skip_top = ffi.types.i32 },
	{ skip_bottom = ffi.types.i32 },
	{ lowres = ffi.types.i32 },
	{ sub_charenc_mode = ffi.types.i32 },
	{ subtitle_header_size = ffi.types.i32 },
	{ nb_coded_side_data = ffi.types.i32 },
	{ export_side_data = ffi.types.i32 },
	{ max_pixels = ffi.types.i64 },
	{ apply_cropping = ffi.types.i32 },
	{ discard_damaged_percentage = ffi.types.i32 },
	{ max_samples = ffi.types.i64 },
	{ frame_num = ffi.types.i64 },
	{ nb_side_data_prefer_packet = ffi.types.pointer },
	{ nb_decoded_side_data = ffi.types.i32 },
})
export type AVCodecContext = typeof(AVCodecContext:new({}))

local AVHWAccel = ffi.struct({
	{ type = ffi.types.pointer },
	{ id = ffi.types.pointer },
	{ pix_fmt = ffi.types.pointer },
	{ capabilities = ffi.types.i32 },
})
export type AVHWAccel = typeof(AVHWAccel:new({}))

local AVSubtitleRect = ffi.struct({
	{ x = ffi.types.i32 },
	{ y = ffi.types.i32 },
	{ w = ffi.types.i32 },
	{ h = ffi.types.i32 },
	{ nb_colors = ffi.types.i32 },
	{ linesize = ffi.types.i32:array(4) },
	{ flags = ffi.types.i32 },
	{ type = ffi.types.pointer },
})
export type AVSubtitleRect = typeof(AVSubtitleRect:new({}))

local AVSubtitle = ffi.struct({
	{ format = ffi.types.u16 },
	{ start_display_time = ffi.types.u32 },
	{ end_display_time = ffi.types.u32 },
	{ num_rects = ffi.types.pointer },
	{ pts = ffi.types.i64 },
})
export type AVSubtitle = typeof(AVSubtitle:new({}))

local AVCodecParserContext = ffi.struct({
	{ frame_offset = ffi.types.i64 },
	{ cur_offset = ffi.types.i64 },
	{ next_frame_offset = ffi.types.i64 },
	{ pict_type = ffi.types.i32 },
	{ repeat_pict = ffi.types.i32 },
	{ pts = ffi.types.i64 },
	{ dts = ffi.types.i64 },
	{ last_pts = ffi.types.i64 },
	{ last_dts = ffi.types.i64 },
	{ fetch_timestamp = ffi.types.i32 },
	{ cur_frame_start_index = ffi.types.i32 },
	{ cur_frame_offset = ffi.types.i64:array(4) },
	{ cur_frame_pts = ffi.types.i64:array(4) },
	{ cur_frame_dts = ffi.types.i64:array(4) },
	{ flags = ffi.types.i32 },
	{ offset = ffi.types.i64 },
	{ cur_frame_end = ffi.types.i64:array(4) },
	{ key_frame = ffi.types.i32 },
	{ dts_sync_point = ffi.types.i32 },
	{ dts_ref_dts_delta = ffi.types.i32 },
	{ pts_dts_delta = ffi.types.i32 },
	{ cur_frame_pos = ffi.types.i64:array(4) },
	{ pos = ffi.types.i64 },
	{ last_pos = ffi.types.i64 },
	{ duration = ffi.types.i32 },
	{ field_order = ffi.types.pointer },
	{ picture_structure = ffi.types.pointer },
	{ output_picture_number = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
	{ coded_width = ffi.types.i32 },
	{ coded_height = ffi.types.i32 },
	{ format = ffi.types.i32 },
})
export type AVCodecParserContext = typeof(AVCodecParserContext:new({}))

local AVCodecParser = ffi.struct({
	{ codec_ids = ffi.types.i32:array(7) },
	{ priv_data_size = ffi.types.i32 },
})
export type AVCodecParser = typeof(AVCodecParser:new({}))

local AVDCT = ffi.struct({
	{ idct_permutation = ffi.types.u8:array(64) },
	{ dct_algo = ffi.types.i32 },
	{ idct_algo = ffi.types.i32 },
	{ bits_per_sample = ffi.types.i32 },
})
export type AVDCT = typeof(AVDCT:new({}))

local AVBSFContext = ffi.struct({
	{ time_base_in = ffi.types.pointer },
	{ time_base_out = ffi.types.pointer },
})
export type AVBSFContext = typeof(AVBSFContext:new({}))

local AVProfile = ffi.struct({
	{ profile = ffi.types.i32 },
})
export type AVProfile = typeof(AVProfile:new({}))

local AVCodec = ffi.struct({
	{ type = ffi.types.pointer },
	{ id = ffi.types.pointer },
	{ capabilities = ffi.types.i32 },
	{ max_lowres = ffi.types.u8 },
})
export type AVCodec = typeof(AVCodec:new({}))

local AVCodecHWConfig = ffi.struct({
	{ pix_fmt = ffi.types.pointer },
	{ methods = ffi.types.i32 },
	{ device_type = ffi.types.pointer },
})
export type AVCodecHWConfig = typeof(AVCodecHWConfig:new({}))

local AVCodecDescriptor = ffi.struct({
	{ id = ffi.types.pointer },
	{ type = ffi.types.pointer },
	{ props = ffi.types.i32 },
})
export type AVCodecDescriptor = typeof(AVCodecDescriptor:new({}))

local AVStream = ffi.struct({
	{ index = ffi.types.i32 },
	{ id = ffi.types.i32 },
	{ codecpar = ffi.types.pointer }, -- AVCodecParameters*
	{ nb_frames = ffi.types.i64 },
	{ start_time = ffi.types.i64 },
	{ duration = ffi.types.i64 },
})
export type AVStream = typeof(AVStream:new({}))

local AVFormatContext = ffi.struct({
	{ nb_streams = ffi.types.i32 },
	{ streams = ffi.types.pointer }, -- AVStream**
	{ duration = ffi.types.i64 },
})
export type AVFormatContext = typeof(AVFormatContext:new({}))

local AVCodecParameters = ffi.struct({
	{ codec_type = ffi.types.i32 }, -- offset 0 (enum, not pointer!)
	{ codec_id = ffi.types.i32 }, -- offset 4 (enum, not pointer!)
	{ codec_tag = ffi.types.u32 }, -- offset 8
	{ extradata_size = ffi.types.i32 }, -- offset 12

	{ extradata = ffi.types.pointer }, -- offset 16
	{ format = ffi.types.i32 }, -- offset 24
	{ bit_rate = ffi.types.i64 },
	{ bits_per_coded_sample = ffi.types.i32 },
	{ bits_per_raw_sample = ffi.types.i32 },
	{ profile = ffi.types.i32 },
	{ level = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
	{ sample_aspect_ratio = ffi.types.pointer },
	{ framerate = ffi.types.pointer },
	{ field_order = ffi.types.i32 }, -- enum, not pointer!
	{ color_range = ffi.types.i32 }, -- enum, not pointer!
	{ color_primaries = ffi.types.i32 }, -- enum, not pointer!
	{ color_trc = ffi.types.i32 }, -- enum, not pointer!
	{ color_space = ffi.types.i32 }, -- enum, not pointer!
	{ chroma_location = ffi.types.i32 }, -- enum, not pointer!
	{ video_delay = ffi.types.i32 },
	{ ch_layout = ffi.types.pointer }, -- Actually a struct, but pointer works
	{ sample_rate = ffi.types.i32 },
	{ block_align = ffi.types.i32 },
	{ frame_size = ffi.types.i32 },
	{ initial_padding = ffi.types.i32 },
	{ trailing_padding = ffi.types.i32 },
	{ seek_preroll = ffi.types.i32 },
})
export type AVCodecParameters = typeof(AVCodecParameters:new({}))

local AVD3D11VAContext = ffi.struct({
	{ surface_count = ffi.types.pointer },
	{ workaround = ffi.types.u64 },
	{ report_id = ffi.types.pointer },
	{ context_mutex = ffi.types.pointer },
})
export type AVD3D11VAContext = typeof(AVD3D11VAContext:new({}))

local AVPanScan = ffi.struct({
	{ id = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ height = ffi.types.i32 },
})
export type AVPanScan = typeof(AVPanScan:new({}))

local AVCPBProperties = ffi.struct({
	{ max_bitrate = ffi.types.i64 },
	{ min_bitrate = ffi.types.i64 },
	{ avg_bitrate = ffi.types.i64 },
	{ buffer_size = ffi.types.i64 },
	{ vbv_delay = ffi.types.u64 },
})
export type AVCPBProperties = typeof(AVCPBProperties:new({}))

local AVProducerReferenceTime = ffi.struct({
	{ wallclock = ffi.types.i64 },
	{ flags = ffi.types.i32 },
})
export type AVProducerReferenceTime = typeof(AVProducerReferenceTime:new({}))

local AVRTCPSenderReport = ffi.struct({
	{ ssrc = ffi.types.u32 },
	{ ntp_timestamp = ffi.types.u64 },
	{ rtp_timestamp = ffi.types.u32 },
	{ sender_nb_packets = ffi.types.u32 },
	{ sender_nb_bytes = ffi.types.u32 },
})
export type AVRTCPSenderReport = typeof(AVRTCPSenderReport:new({}))

local DiracVersionInfo = ffi.struct({
	{ major = ffi.types.i32 },
	{ minor = ffi.types.i32 },
})
export type DiracVersionInfo = typeof(DiracVersionInfo:new({}))

local AVDiracSeqHeader = ffi.struct({
	{ width = ffi.types.pointer },
	{ height = ffi.types.pointer },
	{ chroma_format = ffi.types.u8 },
	{ interlaced = ffi.types.u8 },
	{ top_field_first = ffi.types.u8 },
	{ frame_rate_index = ffi.types.u8 },
	{ aspect_ratio_index = ffi.types.u8 },
	{ clean_width = ffi.types.u16 },
	{ clean_height = ffi.types.u16 },
	{ clean_left_offset = ffi.types.u16 },
	{ clean_right_offset = ffi.types.u16 },
	{ pixel_range_index = ffi.types.u8 },
	{ color_spec_index = ffi.types.u8 },
	{ profile = ffi.types.i32 },
	{ level = ffi.types.i32 },
	{ framerate = ffi.types.pointer },
	{ sample_aspect_ratio = ffi.types.pointer },
	{ pix_fmt = ffi.types.pointer },
	{ color_range = ffi.types.pointer },
	{ color_primaries = ffi.types.pointer },
	{ color_trc = ffi.types.pointer },
	{ colorspace = ffi.types.pointer },
	{ version = DiracVersionInfo },
	{ bit_depth = ffi.types.i32 },
})
export type AVDiracSeqHeader = typeof(AVDiracSeqHeader:new({}))

local AVDVProfile = ffi.struct({
	{ dsf = ffi.types.i32 },
	{ video_stype = ffi.types.i32 },
	{ frame_size = ffi.types.i32 },
	{ difseg_size = ffi.types.i32 },
	{ n_difchan = ffi.types.i32 },
	{ time_base = ffi.types.pointer },
	{ ltc_divisor = ffi.types.i32 },
	{ height = ffi.types.i32 },
	{ width = ffi.types.i32 },
	{ sar = ffi.types.pointer:array(2) },
	{ pix_fmt = ffi.types.pointer },
	{ bpm = ffi.types.i32 },
	{ audio_stride = ffi.types.i32 },
	{ audio_min_samples = ffi.types.i32:array(3) },
	{ audio_samples_dist = ffi.types.i32:array(5) },
})
export type AVDVProfile = typeof(AVDVProfile:new({}))

local AVPacketSideData = ffi.struct({
	{ size = ffi.types.u64 },
	{ type = ffi.types.pointer },
})
export type AVPacketSideData = typeof(AVPacketSideData:new({}))

local AVPacket = ffi.struct({
	{ pts = ffi.types.i64 },
	{ dts = ffi.types.i64 },
	{ size = ffi.types.i32 },
	{ stream_index = ffi.types.i32 },
	{ flags = ffi.types.i32 },
	{ side_data_elems = ffi.types.i32 },
	{ duration = ffi.types.i64 },
	{ pos = ffi.types.i64 },
	{ time_base = ffi.types.pointer },
})
export type AVPacket = typeof(AVPacket:new({}))

local AVPacketList = ffi.struct({
	{ pkt = AVPacket },
})
export type AVPacketList = typeof(AVPacketList:new({}))

local AVQSVContext = ffi.struct({
	{ session = ffi.types.pointer },
	{ iopattern = ffi.types.i32 },
	{ nb_ext_buffers = ffi.types.i32 },
	{ opaque_alloc = ffi.types.i32 },
	{ nb_opaque_surfaces = ffi.types.i32 },
	{ opaque_alloc_type = ffi.types.i32 },
})
export type AVQSVContext = typeof(AVQSVContext:new({}))

local AVSmpte436mAncIterator = ffi.struct({
	{ anc_packets_left = ffi.types.u16 },
	{ size_left = ffi.types.i32 },
})
export type AVSmpte436mAncIterator = typeof(AVSmpte436mAncIterator:new({}))

local AVSmpte291mAnc8bit = ffi.struct({
	{ did = ffi.types.u8 },
	{ sdid_or_dbn = ffi.types.u8 },
	{ data_count = ffi.types.u8 },
	-- FIXME: Array size needs manual definition: 0xFF
	-- { payload = ffi.types.u8:array(0xFF) },
	{ checksum = ffi.types.u8 },
})
export type AVSmpte291mAnc8bit = typeof(AVSmpte291mAnc8bit:new({}))

local AVSmpte436mCodedAnc = ffi.struct({
	{ line_number = ffi.types.u16 },
	{ wrapping_type = ffi.types.pointer },
	{ payload_sample_coding = ffi.types.pointer },
	{ payload_sample_count = ffi.types.u16 },
	{ payload_array_length = ffi.types.u32 },
	-- FIXME: Array size needs manual definition: (((AV_SMPTE_436M_CODED_ANC_SAMPLE_CAPACITY + 2) / 3) * 4)
	-- { payload = ffi.types.u8:array((((AV_SMPTE_436M_CODED_ANC_SAMPLE_CAPACITY + 2) / 3) * 4)) },
})
export type AVSmpte436mCodedAnc = typeof(AVSmpte436mCodedAnc:new({}))

local AVVDPAUContext = ffi.struct({
	{ decoder = ffi.types.pointer },
	{ render2 = ffi.types.pointer },
})
export type AVVDPAUContext = typeof(AVVDPAUContext:new({}))

local AVVideotoolboxContext = ffi.struct({
	{ session = ffi.types.pointer },
	{ cv_pix_fmt_type = ffi.types.pointer },
	{ cm_fmt_desc = ffi.types.pointer },
	{ cm_codec_type = ffi.types.i32 },
})
export type AVVideotoolboxContext = typeof(AVVideotoolboxContext:new({}))

-- Function definitions
local funcs = {
	av_ac3_parse_header = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u8, ffi.types.u16 },
	},
	av_adts_header_parse = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u32, ffi.types.u8 } },
	avcodec_version = { returns = ffi.types.pointer, args = {} },
	avcodec_free_context = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avcodec_parameters_from_context = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_parameters_to_context = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_open2 = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	avsubtitle_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avcodec_default_get_buffer2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	avcodec_default_get_encode_buffer = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	avcodec_align_dimensions = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 } },
	avcodec_align_dimensions2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	avcodec_decode_subtitle2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	avcodec_send_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_receive_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_send_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_receive_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_get_hw_frames_parameters = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	avcodec_get_supported_config = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	av_parser_parse2 = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i64,
			ffi.types.i64,
			ffi.types.i64,
		},
	},
	av_parser_close = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avcodec_encode_subtitle = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u8, ffi.types.i32, ffi.types.pointer },
	},

	avcodec_pix_fmt_to_codec_tag = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avcodec_find_best_pix_fmt_of_list = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	avcodec_default_get_format = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	avcodec_string = {
		returns = ffi.types.void,
		args = { ffi.types.i8, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	avcodec_fill_audio_frame = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	avcodec_find_decoder = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	avcodec_alloc_context3 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	av_packet_alloc = { returns = ffi.types.pointer, args = {} },
	av_packet_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avcodec_flush_buffers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_get_audio_frame_duration = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_fast_padded_malloc = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.u64 } },
	av_fast_padded_mallocz = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.u64 } },
	avcodec_is_open = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avcodec_dct_init = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_bsf_alloc = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_init = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_bsf_send_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_receive_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_flush = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_bsf_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_bsf_list_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_bsf_list_append = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_list_append2 = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_bsf_list_finalize = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_list_parse_str = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_bsf_get_null_filter = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_codec_is_encoder = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_codec_is_decoder = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	avcodec_get_type = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	av_get_bits_per_sample = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_get_exact_bits_per_sample = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_get_pcm_codec = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	avcodec_parameters_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	avcodec_parameters_copy = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_get_audio_frame_duration2 = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_xiphlacing = { returns = ffi.types.i32, args = { ffi.types.u8, ffi.types.u32 } },
	av_dirac_parse_sequence_header = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	av_jni_set_java_vm = { returns = ffi.types.i32, args = {} },
	av_mediacodec_default_init = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	av_mediacodec_default_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_mediacodec_release_buffer = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_mediacodec_render_buffer_at_time = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i64 } },
	av_packet_side_data_remove = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	av_packet_side_data_free = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	av_packet_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_init_packet = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_new_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_shrink_packet = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	av_grow_packet = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	av_packet_from_data = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8, ffi.types.i32 } },
	av_packet_new_side_data = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	av_packet_add_side_data = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8, ffi.types.u64 },
	},
	av_packet_shrink_side_data = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	av_packet_get_side_data = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	av_packet_unpack_dictionary = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	av_packet_free_side_data = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_packet_ref = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_packet_unref = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_packet_move_ref = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	av_packet_copy_props = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	av_packet_make_refcounted = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_packet_make_writable = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	av_packet_rescale_ts = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	av_vorbis_parse_free = { returns = ffi.types.void, args = { ffi.types.pointer } },
	av_vorbis_parse_frame_flags = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	av_vorbis_parse_frame = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	av_vorbis_parse_reset = { returns = ffi.types.void, args = { ffi.types.pointer } },
}

local structs = {
	RcOverride = RcOverride,
	AVCodecContext = AVCodecContext,
	AVHWAccel = AVHWAccel,
	AVSubtitleRect = AVSubtitleRect,
	AVSubtitle = AVSubtitle,
	AVCodecParserContext = AVCodecParserContext,
	AVCodecParser = AVCodecParser,
	AVDCT = AVDCT,
	AVBSFContext = AVBSFContext,
	AVProfile = AVProfile,
	AVCodec = AVCodec,
	AVCodecHWConfig = AVCodecHWConfig,
	AVCodecDescriptor = AVCodecDescriptor,
	AVCodecParameters = AVCodecParameters,
	AVD3D11VAContext = AVD3D11VAContext,
	AVPanScan = AVPanScan,
	AVCPBProperties = AVCPBProperties,
	AVProducerReferenceTime = AVProducerReferenceTime,
	AVRTCPSenderReport = AVRTCPSenderReport,
	DiracVersionInfo = DiracVersionInfo,
	AVDiracSeqHeader = AVDiracSeqHeader,
	AVDVProfile = AVDVProfile,
	AVPacketSideData = AVPacketSideData,
	AVPacket = AVPacket,
	AVPacketList = AVPacketList,
	AVFormatContext = AVFormatContext,
	AVQSVContext = AVQSVContext,
	AVSmpte436mAncIterator = AVSmpte436mAncIterator,
	AVSmpte291mAnc8bit = AVSmpte291mAnc8bit,
	AVSmpte436mCodedAnc = AVSmpte436mCodedAnc,
	AVVDPAUContext = AVVDPAUContext,
	AVVideotoolboxContext = AVVideotoolboxContext,
}

return { funcs = funcs, structs = structs }
