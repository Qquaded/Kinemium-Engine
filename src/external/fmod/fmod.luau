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

local FMOD_CODEC_DESCRIPTION = ffi.struct({
	{ apiversion = ffi.types.i32 },
	{ version = ffi.types.i32 },
	{ defaultasstream = ffi.types.i32 },
	{ timeunits = ffi.types.pointer },
	{ open = ffi.types.pointer },
	{ close = ffi.types.pointer },
	{ read = ffi.types.pointer },
	{ getlength = ffi.types.pointer },
	{ setposition = ffi.types.pointer },
	{ getposition = ffi.types.pointer },
	{ soundcreate = ffi.types.pointer },
	{ getwaveformat = ffi.types.pointer },
})
export type FMOD_CODEC_DESCRIPTION = typeof(FMOD_CODEC_DESCRIPTION:new({}))

local FMOD_CODEC_STATE_FUNCTIONS = ffi.struct({
	{ metadata = ffi.types.pointer },
	{ alloc = ffi.types.pointer },
	{ free = ffi.types.pointer },
	{ log = ffi.types.pointer },
	{ read = ffi.types.pointer },
	{ seek = ffi.types.pointer },
	{ tell = ffi.types.pointer },
	{ size = ffi.types.pointer },
})
export type FMOD_CODEC_STATE_FUNCTIONS = typeof(FMOD_CODEC_STATE_FUNCTIONS:new({}))

local FMOD_VECTOR = ffi.struct({
	{ x = ffi.types.float },
	{ y = ffi.types.float },
	{ z = ffi.types.float },
})
export type FMOD_VECTOR = typeof(FMOD_VECTOR:new({}))

local FMOD_3D_ATTRIBUTES = ffi.struct({
	{ position = FMOD_VECTOR },
	{ velocity = FMOD_VECTOR },
	{ forward = FMOD_VECTOR },
	{ up = FMOD_VECTOR },
})
export type FMOD_3D_ATTRIBUTES = typeof(FMOD_3D_ATTRIBUTES:new({}))

local FMOD_GUID = ffi.struct({
	{ Data1 = ffi.types.i32 },
	{ Data2 = ffi.types.i16 },
	{ Data3 = ffi.types.i16 },
	{ Data4 = ffi.types.i8:array(8) },
})
export type FMOD_GUID = typeof(FMOD_GUID:new({}))

local FMOD_PLUGINLIST = ffi.struct({
	{ type = ffi.types.pointer },
})
export type FMOD_PLUGINLIST = typeof(FMOD_PLUGINLIST:new({}))

local FMOD_ADVANCEDSETTINGS = ffi.struct({
	{ cbSize = ffi.types.i32 },
	{ maxMPEGCodecs = ffi.types.i32 },
	{ maxADPCMCodecs = ffi.types.i32 },
	{ maxXMACodecs = ffi.types.i32 },
	{ maxVorbisCodecs = ffi.types.i32 },
	{ maxAT9Codecs = ffi.types.i32 },
	{ maxFADPCMCodecs = ffi.types.i32 },
	{ maxOpusCodecs = ffi.types.i32 },
	{ ASIONumChannels = ffi.types.i32 },
	{ vol0virtualvol = ffi.types.float },
	{ defaultDecodeBufferSize = ffi.types.i32 },
	{ profilePort = ffi.types.i16 },
	{ geometryMaxFadeTime = ffi.types.i32 },
	{ distanceFilterCenterFreq = ffi.types.float },
	{ reverb3Dinstance = ffi.types.i32 },
	{ DSPBufferPoolSize = ffi.types.i32 },
	{ resamplerMethod = ffi.types.pointer },
	{ randomSeed = ffi.types.i32 },
	{ maxConvolutionThreads = ffi.types.i32 },
	{ maxSpatialObjects = ffi.types.i32 },
})
export type FMOD_ADVANCEDSETTINGS = typeof(FMOD_ADVANCEDSETTINGS:new({}))

local FMOD_TAG = ffi.struct({
	{ type = ffi.types.pointer },
	{ datatype = ffi.types.pointer },
	{ datalen = ffi.types.i32 },
	{ updated = ffi.types.pointer },
})
export type FMOD_TAG = typeof(FMOD_TAG:new({}))

local FMOD_CREATESOUNDEXINFO = ffi.struct({
	{ cbsize = ffi.types.i32 },
	{ length = ffi.types.i32 },
	{ fileoffset = ffi.types.i32 },
	{ numchannels = ffi.types.i32 },
	{ defaultfrequency = ffi.types.i32 },
	{ format = ffi.types.pointer },
	{ decodebuffersize = ffi.types.i32 },
	{ initialsubsound = ffi.types.i32 },
	{ numsubsounds = ffi.types.i32 },
	{ inclusionlistnum = ffi.types.i32 },
	{ pcmreadcallback = ffi.types.pointer },
	{ pcmsetposcallback = ffi.types.pointer },
	{ nonblockcallback = ffi.types.pointer },
	{ maxpolyphony = ffi.types.i32 },
	{ suggestedsoundtype = ffi.types.pointer },
	{ fileuseropen = ffi.types.pointer },
	{ fileuserclose = ffi.types.pointer },
	{ fileuserread = ffi.types.pointer },
	{ fileuserseek = ffi.types.pointer },
	{ fileuserasyncread = ffi.types.pointer },
	{ fileuserasynccancel = ffi.types.pointer },
	{ filebuffersize = ffi.types.i32 },
	{ channelorder = ffi.types.pointer },
	{ initialseekposition = ffi.types.i32 },
	{ initialseekpostype = ffi.types.pointer },
	{ ignoresetfilesystem = ffi.types.i32 },
	{ audioqueuepolicy = ffi.types.i32 },
	{ minmidigranularity = ffi.types.i32 },
	{ nonblockthreadid = ffi.types.i32 },
})
export type FMOD_CREATESOUNDEXINFO = typeof(FMOD_CREATESOUNDEXINFO:new({}))

local FMOD_REVERB_PROPERTIES = ffi.struct({
	{ DecayTime = ffi.types.float },
	{ EarlyDelay = ffi.types.float },
	{ LateDelay = ffi.types.float },
	{ HFReference = ffi.types.float },
	{ HFDecayRatio = ffi.types.float },
	{ Diffusion = ffi.types.float },
	{ Density = ffi.types.float },
	{ LowShelfFrequency = ffi.types.float },
	{ LowShelfGain = ffi.types.float },
	{ HighCut = ffi.types.float },
	{ EarlyLateMix = ffi.types.float },
	{ WetLevel = ffi.types.float },
})
export type FMOD_REVERB_PROPERTIES = typeof(FMOD_REVERB_PROPERTIES:new({}))

local FMOD_ERRORCALLBACK_INFO = ffi.struct({
	{ result = ffi.types.pointer },
	{ instancetype = ffi.types.pointer },
})
export type FMOD_ERRORCALLBACK_INFO = typeof(FMOD_ERRORCALLBACK_INFO:new({}))

local FMOD_CPU_USAGE = ffi.struct({
	{ dsp = ffi.types.float },
	{ stream = ffi.types.float },
	{ geometry = ffi.types.float },
	{ update = ffi.types.float },
	{ convolution1 = ffi.types.float },
	{ convolution2 = ffi.types.float },
})
export type FMOD_CPU_USAGE = typeof(FMOD_CPU_USAGE:new({}))

local FMOD_DSP_DATA_PARAMETER_INFO = ffi.struct({
	{ length = ffi.types.i32 },
	{ index = ffi.types.i32 },
})
export type FMOD_DSP_DATA_PARAMETER_INFO = typeof(FMOD_DSP_DATA_PARAMETER_INFO:new({}))

local FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR = ffi.struct({
	{ numpoints = ffi.types.i32 },
})
export type FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR =
	typeof(FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR:new({}))

local FMOD_DSP_PARAMETER_FLOAT_MAPPING = ffi.struct({
	{ type = ffi.types.pointer },
	{ piecewiselinearmapping = FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR },
})
export type FMOD_DSP_PARAMETER_FLOAT_MAPPING = typeof(FMOD_DSP_PARAMETER_FLOAT_MAPPING:new({}))

local FMOD_DSP_PARAMETER_DESC_FLOAT = ffi.struct({
	{ min = ffi.types.float },
	{ max = ffi.types.float },
	{ defaultval = ffi.types.float },
	{ mapping = FMOD_DSP_PARAMETER_FLOAT_MAPPING },
})
export type FMOD_DSP_PARAMETER_DESC_FLOAT = typeof(FMOD_DSP_PARAMETER_DESC_FLOAT:new({}))

local FMOD_DSP_PARAMETER_DESC_INT = ffi.struct({
	{ min = ffi.types.i32 },
	{ max = ffi.types.i32 },
	{ defaultval = ffi.types.i32 },
	{ goestoinf = ffi.types.pointer },
	{ valuenames = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_DESC_INT = typeof(FMOD_DSP_PARAMETER_DESC_INT:new({}))

local FMOD_DSP_PARAMETER_DESC_BOOL = ffi.struct({
	{ defaultval = ffi.types.pointer },
	{ valuenames = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_DESC_BOOL = typeof(FMOD_DSP_PARAMETER_DESC_BOOL:new({}))

local FMOD_DSP_PARAMETER_DESC_DATA = ffi.struct({
	{ datatype = ffi.types.i32 },
})
export type FMOD_DSP_PARAMETER_DESC_DATA = typeof(FMOD_DSP_PARAMETER_DESC_DATA:new({}))

local FMOD_DSP_PARAMETER_OVERALLGAIN = ffi.struct({
	{ linear_gain = ffi.types.float },
	{ linear_gain_additive = ffi.types.float },
})
export type FMOD_DSP_PARAMETER_OVERALLGAIN = typeof(FMOD_DSP_PARAMETER_OVERALLGAIN:new({}))

local FMOD_DSP_PARAMETER_3DATTRIBUTES = ffi.struct({
	{ relative = ffi.types.pointer },
	{ absolute = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_3DATTRIBUTES = typeof(FMOD_DSP_PARAMETER_3DATTRIBUTES:new({}))

local FMOD_DSP_PARAMETER_3DATTRIBUTES_MULTI = ffi.struct({
	{ numlisteners = ffi.types.i32 },
	-- FIXME: Array size needs manual definition: FMOD_MAX_LISTENERS
	-- { relative = ffi.types.pointer:array(FMOD_MAX_LISTENERS) },
	-- FIXME: Array size needs manual definition: FMOD_MAX_LISTENERS
	-- { weight = ffi.types.float:array(FMOD_MAX_LISTENERS) },
	{ absolute = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_3DATTRIBUTES_MULTI = typeof(FMOD_DSP_PARAMETER_3DATTRIBUTES_MULTI:new({}))

local FMOD_DSP_PARAMETER_ATTENUATION_RANGE = ffi.struct({
	{ min = ffi.types.float },
	{ max = ffi.types.float },
})
export type FMOD_DSP_PARAMETER_ATTENUATION_RANGE = typeof(FMOD_DSP_PARAMETER_ATTENUATION_RANGE:new({}))

local FMOD_DSP_PARAMETER_SIDECHAIN = ffi.struct({
	{ sidechainenable = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_SIDECHAIN = typeof(FMOD_DSP_PARAMETER_SIDECHAIN:new({}))

local FMOD_DSP_PARAMETER_FFT = ffi.struct({
	{ length = ffi.types.i32 },
	{ numchannels = ffi.types.i32 },
})
export type FMOD_DSP_PARAMETER_FFT = typeof(FMOD_DSP_PARAMETER_FFT:new({}))

local FMOD_DSP_PARAMETER_DYNAMIC_RESPONSE = ffi.struct({
	{ numchannels = ffi.types.i32 },
	{ rms = ffi.types.float:array(32) },
})
export type FMOD_DSP_PARAMETER_DYNAMIC_RESPONSE = typeof(FMOD_DSP_PARAMETER_DYNAMIC_RESPONSE:new({}))

local FMOD_DSP_PARAMETER_FINITE_LENGTH = ffi.struct({
	{ finite = ffi.types.pointer },
})
export type FMOD_DSP_PARAMETER_FINITE_LENGTH = typeof(FMOD_DSP_PARAMETER_FINITE_LENGTH:new({}))

local FMOD_DSP_DESCRIPTION = ffi.struct({
	{ pluginsdkversion = ffi.types.i32 },
	{ name = ffi.types.i8:array(32) },
	{ version = ffi.types.i32 },
	{ numinputbuffers = ffi.types.i32 },
	{ numoutputbuffers = ffi.types.i32 },
	{ create = ffi.types.pointer },
	{ release = ffi.types.pointer },
	{ reset = ffi.types.pointer },
	{ read = ffi.types.pointer },
	{ process = ffi.types.pointer },
	{ setposition = ffi.types.pointer },
	{ numparameters = ffi.types.i32 },
	{ setparameterfloat = ffi.types.pointer },
	{ setparameterint = ffi.types.pointer },
	{ setparameterbool = ffi.types.pointer },
	{ setparameterdata = ffi.types.pointer },
	{ getparameterfloat = ffi.types.pointer },
	{ getparameterint = ffi.types.pointer },
	{ getparameterbool = ffi.types.pointer },
	{ getparameterdata = ffi.types.pointer },
	{ shouldiprocess = ffi.types.pointer },
	{ sys_register = ffi.types.pointer },
	{ sys_deregister = ffi.types.pointer },
	{ sys_mix = ffi.types.pointer },
})
export type FMOD_DSP_DESCRIPTION = typeof(FMOD_DSP_DESCRIPTION:new({}))

local FMOD_DSP_STATE_DFT_FUNCTIONS = ffi.struct({
	{ fftreal = ffi.types.pointer },
	{ inversefftreal = ffi.types.pointer },
})
export type FMOD_DSP_STATE_DFT_FUNCTIONS = typeof(FMOD_DSP_STATE_DFT_FUNCTIONS:new({}))

local FMOD_DSP_STATE_PAN_FUNCTIONS = ffi.struct({
	{ summonomatrix = ffi.types.pointer },
	{ sumstereomatrix = ffi.types.pointer },
	{ sumsurroundmatrix = ffi.types.pointer },
	{ summonotosurroundmatrix = ffi.types.pointer },
	{ sumstereotosurroundmatrix = ffi.types.pointer },
	{ getrolloffgain = ffi.types.pointer },
})
export type FMOD_DSP_STATE_PAN_FUNCTIONS = typeof(FMOD_DSP_STATE_PAN_FUNCTIONS:new({}))

local FMOD_DSP_STATE_FUNCTIONS = ffi.struct({
	{ alloc = ffi.types.pointer },
	{ realloc = ffi.types.pointer },
	{ free = ffi.types.pointer },
	{ getsamplerate = ffi.types.pointer },
	{ getblocksize = ffi.types.pointer },
	{ getspeakermode = ffi.types.pointer },
	{ getclock = ffi.types.pointer },
	{ getlistenerattributes = ffi.types.pointer },
	{ log = ffi.types.pointer },
	{ getuserdata = ffi.types.pointer },
})
export type FMOD_DSP_STATE_FUNCTIONS = typeof(FMOD_DSP_STATE_FUNCTIONS:new({}))

local FMOD_DSP_METERING_INFO = ffi.struct({
	{ numsamples = ffi.types.i32 },
	{ peaklevel = ffi.types.float:array(32) },
	{ rmslevel = ffi.types.float:array(32) },
	{ numchannels = ffi.types.i16 },
})
export type FMOD_DSP_METERING_INFO = typeof(FMOD_DSP_METERING_INFO:new({}))

local FMOD_DSP_LOUDNESS_METER_INFO_TYPE = ffi.struct({
	{ momentaryloudness = ffi.types.float },
	{ shorttermloudness = ffi.types.float },
	{ integratedloudness = ffi.types.float },
	{ loudness10thpercentile = ffi.types.float },
	{ loudness95thpercentile = ffi.types.float },
	{ loudnesshistogram = ffi.types.float:array(66) },
	{ maxtruepeak = ffi.types.float },
	{ maxmomentaryloudness = ffi.types.float },
})
export type FMOD_DSP_LOUDNESS_METER_INFO_TYPE = typeof(FMOD_DSP_LOUDNESS_METER_INFO_TYPE:new({}))

local FMOD_DSP_LOUDNESS_METER_WEIGHTING_TYPE = ffi.struct({
	{ channelweight = ffi.types.float:array(32) },
})
export type FMOD_DSP_LOUDNESS_METER_WEIGHTING_TYPE = typeof(FMOD_DSP_LOUDNESS_METER_WEIGHTING_TYPE:new({}))

local FMOD_OUTPUT_DESCRIPTION = ffi.struct({
	{ apiversion = ffi.types.i32 },
	{ version = ffi.types.i32 },
	{ method = ffi.types.pointer },
	{ getnumdrivers = ffi.types.pointer },
	{ getdriverinfo = ffi.types.pointer },
	{ init = ffi.types.pointer },
	{ start = ffi.types.pointer },
	{ stop = ffi.types.pointer },
	{ close = ffi.types.pointer },
	{ update = ffi.types.pointer },
	{ gethandle = ffi.types.pointer },
	{ mixer = ffi.types.pointer },
	{ object3dgetinfo = ffi.types.pointer },
	{ object3dalloc = ffi.types.pointer },
	{ object3dfree = ffi.types.pointer },
	{ object3dupdate = ffi.types.pointer },
	{ openport = ffi.types.pointer },
	{ closeport = ffi.types.pointer },
	{ devicelistchanged = ffi.types.pointer },
})
export type FMOD_OUTPUT_DESCRIPTION = typeof(FMOD_OUTPUT_DESCRIPTION:new({}))

-- Function definitions
local funcs = {
	FMOD_Memory_Initialize = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	FMOD_Memory_GetStats = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.i32, ffi.types.pointer } },
	FMOD_Debug_Initialize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_File_SetDiskBusy = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	FMOD_File_GetDiskBusy = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	FMOD_Thread_SetAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_Create = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FMOD_System_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_SetOutput = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetOutput = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetNumDrivers = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_GetDriverInfo = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	FMOD_System_SetDriver = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_GetDriver = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_SetSoftwareChannels = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_GetSoftwareChannels = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_SetSoftwareFormat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_System_GetSoftwareFormat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_System_SetDSPBufferSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.i32 },
	},
	FMOD_System_GetDSPBufferSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.i32 },
	},
	FMOD_System_SetFileSystem = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	FMOD_System_AttachFileSystem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_SetAdvancedSettings = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetAdvancedSettings = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_SetCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_SetPluginPath = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_LoadPlugin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_System_UnloadPlugin = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FMOD_System_GetNumNestedPlugins = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.i32 },
	},
	FMOD_System_GetNestedPlugin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.i32, ffi.types.u32 },
	},
	FMOD_System_GetNumPlugins = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_System_GetPluginHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	FMOD_System_GetPluginInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.u32 },
	},
	FMOD_System_SetOutputByPlugin = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FMOD_System_GetOutputByPlugin = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FMOD_System_CreateDSPByPlugin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_System_GetDSPInfoByPlugin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_System_RegisterCodec = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_System_RegisterDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	FMOD_System_RegisterOutput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	FMOD_System_Init = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_System_Close = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_Update = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_SetSpeakerPosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	FMOD_System_GetSpeakerPosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	FMOD_System_SetStreamBufferSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_System_GetStreamBufferSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_System_Set3DSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_System_Get3DSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_System_Set3DNumListeners = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_Get3DNumListeners = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_Set3DListenerAttributes = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	FMOD_System_Get3DListenerAttributes = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	FMOD_System_Set3DRolloffCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_MixerSuspend = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_MixerResume = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_GetDefaultMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_System_GetSpeakerModeChannels = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_System_GetVersion = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 } },
	FMOD_System_GetOutputHandle = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_GetChannelsPlaying = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_System_GetCPUUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetFileUsage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i64, ffi.types.i64, ffi.types.i64 },
	},
	FMOD_System_CreateSound = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- system
			ffi.types.pointer, -- name_or_data (file path as pointer to string)
			ffi.types.u32, -- mode (flags)
			ffi.types.pointer, -- exinfo
			ffi.types.pointer, -- sound (output)
		},
	},
	FMOD_System_CreateStream = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateDSPByType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateDSPConnection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateChannelGroup = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateSoundGroup = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_CreateReverb3D = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_PlaySound = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_PlayDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_GetChannel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_GetDSPInfoByType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_GetMasterChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetMasterSoundGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_AttachChannelGroupToPort = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_DetachChannelGroupFromPort = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_SetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_GetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_LockDSP = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_UnlockDSP = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_GetRecordNumDrivers = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_System_GetRecordDriverInfo = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i8,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	FMOD_System_GetRecordPosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	FMOD_System_RecordStart = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_System_RecordStop = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_IsRecording = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_CreateGeometry = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_SetGeometrySettings = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_System_GetGeometrySettings = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_System_LoadGeometry = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_System_GetGeometryOcclusion = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_System_SetNetworkProxy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_System_GetNetworkProxy = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_System_SetNetworkTimeout = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_GetNetworkTimeout = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_System_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_System_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Sound_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Sound_GetSystemObject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_Lock = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.u32,
			ffi.types.u32,
			ffi.types.u32,
		},
	},
	FMOD_Sound_Unlock = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_Sound_SetDefaults = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_Sound_GetDefaults = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_Sound_Set3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Sound_Get3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Sound_Set3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_Sound_Get3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_Sound_Set3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Sound_Get3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Sound_GetSubSound = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Sound_GetSubSoundParent = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_GetName = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32 } },
	FMOD_Sound_GetLength = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Sound_GetFormat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Sound_GetNumSubSounds = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Sound_GetNumTags = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 } },
	FMOD_Sound_GetTag = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Sound_GetOpenState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Sound_ReadData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_Sound_SeekData = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FMOD_Sound_SetSoundGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_GetSoundGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_GetNumSyncPoints = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Sound_GetSyncPoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Sound_GetSyncPointInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Sound_AddSyncPoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Sound_DeleteSyncPoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_SetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_GetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Sound_SetLoopCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Sound_GetLoopCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Sound_SetLoopPoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Sound_GetLoopPoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Sound_GetMusicNumChannels = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Sound_SetMusicChannelVolume = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Sound_GetMusicChannelVolume = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Sound_SetMusicSpeed = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Sound_GetMusicSpeed = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Sound_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Sound_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Channel_GetSystemObject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_Stop = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Channel_SetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_GetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetVolumeRamp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetVolumeRamp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetAudibility = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetPitch = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_GetPitch = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_SetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Channel_GetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Channel_SetLowPassGain = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_GetLowPassGain = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_SetCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_IsPlaying = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_SetPan = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetMixLevelsOutput = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},
	FMOD_Channel_SetMixLevelsInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_Channel_SetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Channel_GetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Channel_GetDSPClock = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	FMOD_Channel_SetDelay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer },
	},
	FMOD_Channel_GetDelay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer },
	},
	FMOD_Channel_AddFadePoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.float },
	},
	FMOD_Channel_SetFadePointRamp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.float },
	},
	FMOD_Channel_RemoveFadePoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	FMOD_Channel_GetFadePoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u64, ffi.types.float },
	},
	FMOD_Channel_GetDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Channel_AddDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Channel_RemoveDSP = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetNumDSPs = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Channel_SetDSPIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Channel_GetDSPIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Channel_Set3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Channel_Get3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Channel_Set3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Get3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Set3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Get3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Set3DConeOrientation = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_Get3DConeOrientation = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_Set3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Channel_Get3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Channel_Set3DOcclusion = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Get3DOcclusion = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Set3DSpread = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Get3DSpread = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Set3DLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Get3DLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Set3DDopplerLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Get3DDopplerLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_Set3DDistanceFilter = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_Get3DDistanceFilter = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Channel_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Channel_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Channel_SetFrequency = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_GetFrequency = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Channel_SetPriority = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Channel_GetPriority = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Channel_SetPosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Channel_GetPosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Channel_SetChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_SetLoopCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Channel_GetLoopCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Channel_SetLoopPoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Channel_GetLoopPoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FMOD_Channel_IsVirtual = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetCurrentSound = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Channel_GetIndex = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_ChannelGroup_GetSystemObject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_Stop = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_ChannelGroup_SetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_GetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_SetVolumeRamp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetVolumeRamp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetAudibility = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_SetPitch = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_GetPitch = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_SetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_SetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_ChannelGroup_GetReverbProperties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_ChannelGroup_SetLowPassGain = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_GetLowPassGain = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_SetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_SetCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_IsPlaying = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_SetPan = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_SetMixLevelsOutput = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
		},
	},
	FMOD_ChannelGroup_SetMixLevelsInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_ChannelGroup_SetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_ChannelGroup_GetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_ChannelGroup_GetDSPClock = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	FMOD_ChannelGroup_SetDelay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer },
	},
	FMOD_ChannelGroup_GetDelay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64, ffi.types.pointer },
	},
	FMOD_ChannelGroup_AddFadePoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.float },
	},
	FMOD_ChannelGroup_SetFadePointRamp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.float },
	},
	FMOD_ChannelGroup_RemoveFadePoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	FMOD_ChannelGroup_GetFadePoints = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u64, ffi.types.float },
	},
	FMOD_ChannelGroup_GetDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_ChannelGroup_AddDSP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_ChannelGroup_RemoveDSP = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetNumDSPs = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_ChannelGroup_SetDSPIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_ChannelGroup_GetDSPIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_ChannelGroup_Set3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_ChannelGroup_Get3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_ChannelGroup_Set3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Get3DMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Set3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Get3DConeSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Set3DConeOrientation = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_ChannelGroup_Get3DConeOrientation = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_ChannelGroup_Set3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_ChannelGroup_Get3DCustomRolloff = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_ChannelGroup_Set3DOcclusion = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Get3DOcclusion = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Set3DSpread = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Get3DSpread = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Set3DLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Get3DLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Set3DDopplerLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Get3DDopplerLevel = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_ChannelGroup_Set3DDistanceFilter = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_Get3DDistanceFilter = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_ChannelGroup_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_ChannelGroup_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_ChannelGroup_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_ChannelGroup_AddGroup = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_ChannelGroup_GetNumGroups = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_ChannelGroup_GetGroup = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_ChannelGroup_GetParentGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_ChannelGroup_GetName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_ChannelGroup_GetNumChannels = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_ChannelGroup_GetChannel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_SoundGroup_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_SoundGroup_GetSystemObject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_SoundGroup_SetMaxAudible = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_SoundGroup_GetMaxAudible = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_SoundGroup_SetMaxAudibleBehavior = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_SoundGroup_GetMaxAudibleBehavior = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_SoundGroup_SetMuteFadeSpeed = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_SoundGroup_GetMuteFadeSpeed = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_SoundGroup_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_SoundGroup_GetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_SoundGroup_Stop = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_SoundGroup_GetName = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32 } },
	FMOD_SoundGroup_GetNumSounds = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_SoundGroup_GetSound = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_SoundGroup_GetNumPlaying = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_SoundGroup_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_SoundGroup_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSP_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSP_GetSystemObject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_AddInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_AddInputPreallocated = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_DisconnectFrom = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_DisconnectAll = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetNumInputs = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_DSP_GetNumOutputs = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_DSP_GetInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetOutput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_SetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_GetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_SetBypass = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_GetBypass = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_SetWetDryMix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_DSP_GetWetDryMix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	FMOD_DSP_SetChannelFormat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_DSP_GetChannelFormat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_DSP_GetOutputChannelFormat = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	FMOD_DSP_Reset = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSP_SetCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_SetParameterFloat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_DSP_SetParameterInt = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_DSP_SetParameterBool = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_DSP_SetParameterData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	FMOD_DSP_GetParameterFloat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_DSP_GetParameterInt = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_DSP_GetParameterBool = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_DSP_GetParameterData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_DSP_GetNumParameters = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_DSP_GetParameterInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_DSP_GetDataParameterIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_DSP_ShowConfigDialog = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.u32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_DSP_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_GetIdle = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSP_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSP_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSP_SetMeteringEnabled = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetMeteringEnabled = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetMeteringInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_DSP_GetCPUUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 } },
	FMOD_DSPConnection_GetInput = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSPConnection_GetOutput = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSPConnection_SetMix = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_DSPConnection_GetMix = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_DSPConnection_SetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_DSPConnection_GetMixMatrix = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_DSPConnection_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_DSPConnection_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_DSPConnection_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Geometry_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Geometry_AddPolygon = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	FMOD_Geometry_GetNumPolygons = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Geometry_GetMaxPolygons = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Geometry_GetPolygonNumVertices = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Geometry_SetPolygonVertex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Geometry_GetPolygonVertex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Geometry_SetPolygonAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Geometry_GetPolygonAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Geometry_SetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_GetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_SetRotation = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Geometry_GetRotation = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Geometry_SetPosition = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_GetPosition = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_SetScale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_GetScale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Geometry_Save = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Geometry_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Geometry_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Reverb3D_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Reverb3D_Set3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Reverb3D_Get3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Reverb3D_SetProperties = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Reverb3D_GetProperties = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Reverb3D_SetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Reverb3D_GetActive = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Reverb3D_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Reverb3D_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
}

local structs = {
	FMOD_CODEC_DESCRIPTION = FMOD_CODEC_DESCRIPTION,
	FMOD_CODEC_STATE_FUNCTIONS = FMOD_CODEC_STATE_FUNCTIONS,
	FMOD_VECTOR = FMOD_VECTOR,
	FMOD_3D_ATTRIBUTES = FMOD_3D_ATTRIBUTES,
	FMOD_GUID = FMOD_GUID,
	FMOD_PLUGINLIST = FMOD_PLUGINLIST,
	FMOD_ADVANCEDSETTINGS = FMOD_ADVANCEDSETTINGS,
	FMOD_TAG = FMOD_TAG,
	FMOD_CREATESOUNDEXINFO = FMOD_CREATESOUNDEXINFO,
	FMOD_REVERB_PROPERTIES = FMOD_REVERB_PROPERTIES,
	FMOD_ERRORCALLBACK_INFO = FMOD_ERRORCALLBACK_INFO,
	FMOD_CPU_USAGE = FMOD_CPU_USAGE,
	FMOD_DSP_DATA_PARAMETER_INFO = FMOD_DSP_DATA_PARAMETER_INFO,
	FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR = FMOD_DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR,
	FMOD_DSP_PARAMETER_FLOAT_MAPPING = FMOD_DSP_PARAMETER_FLOAT_MAPPING,
	FMOD_DSP_PARAMETER_DESC_FLOAT = FMOD_DSP_PARAMETER_DESC_FLOAT,
	FMOD_DSP_PARAMETER_DESC_INT = FMOD_DSP_PARAMETER_DESC_INT,
	FMOD_DSP_PARAMETER_DESC_BOOL = FMOD_DSP_PARAMETER_DESC_BOOL,
	FMOD_DSP_PARAMETER_DESC_DATA = FMOD_DSP_PARAMETER_DESC_DATA,
	FMOD_DSP_PARAMETER_OVERALLGAIN = FMOD_DSP_PARAMETER_OVERALLGAIN,
	FMOD_DSP_PARAMETER_3DATTRIBUTES = FMOD_DSP_PARAMETER_3DATTRIBUTES,
	FMOD_DSP_PARAMETER_3DATTRIBUTES_MULTI = FMOD_DSP_PARAMETER_3DATTRIBUTES_MULTI,
	FMOD_DSP_PARAMETER_ATTENUATION_RANGE = FMOD_DSP_PARAMETER_ATTENUATION_RANGE,
	FMOD_DSP_PARAMETER_SIDECHAIN = FMOD_DSP_PARAMETER_SIDECHAIN,
	FMOD_DSP_PARAMETER_FFT = FMOD_DSP_PARAMETER_FFT,
	FMOD_DSP_PARAMETER_DYNAMIC_RESPONSE = FMOD_DSP_PARAMETER_DYNAMIC_RESPONSE,
	FMOD_DSP_PARAMETER_FINITE_LENGTH = FMOD_DSP_PARAMETER_FINITE_LENGTH,
	FMOD_DSP_DESCRIPTION = FMOD_DSP_DESCRIPTION,
	FMOD_DSP_STATE_DFT_FUNCTIONS = FMOD_DSP_STATE_DFT_FUNCTIONS,
	FMOD_DSP_STATE_PAN_FUNCTIONS = FMOD_DSP_STATE_PAN_FUNCTIONS,
	FMOD_DSP_STATE_FUNCTIONS = FMOD_DSP_STATE_FUNCTIONS,
	FMOD_DSP_METERING_INFO = FMOD_DSP_METERING_INFO,
	FMOD_DSP_LOUDNESS_METER_INFO_TYPE = FMOD_DSP_LOUDNESS_METER_INFO_TYPE,
	FMOD_DSP_LOUDNESS_METER_WEIGHTING_TYPE = FMOD_DSP_LOUDNESS_METER_WEIGHTING_TYPE,
	FMOD_OUTPUT_DESCRIPTION = FMOD_OUTPUT_DESCRIPTION,
}

return { funcs = funcs, structs = structs }
