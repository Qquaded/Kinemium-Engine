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

local FMOD_STUDIO_BANK_INFO = ffi.struct({
	{ size = ffi.types.i32 },
	{ userdatalength = ffi.types.i32 },
	{ opencallback = ffi.types.pointer },
	{ closecallback = ffi.types.pointer },
	{ readcallback = ffi.types.pointer },
	{ seekcallback = ffi.types.pointer },
})
export type FMOD_STUDIO_BANK_INFO = typeof(FMOD_STUDIO_BANK_INFO:new({}))

local FMOD_STUDIO_PARAMETER_ID = ffi.struct({
	{ data1 = ffi.types.i32 },
	{ data2 = ffi.types.i32 },
})
export type FMOD_STUDIO_PARAMETER_ID = typeof(FMOD_STUDIO_PARAMETER_ID:new({}))

local FMOD_STUDIO_PARAMETER_DESCRIPTION = ffi.struct({
	{ id = FMOD_STUDIO_PARAMETER_ID },
	{ minimum = ffi.types.float },
	{ maximum = ffi.types.float },
	{ defaultvalue = ffi.types.float },
	{ type = ffi.types.pointer },
	{ flags = ffi.types.pointer },
	{ guid = ffi.types.pointer },
})
export type FMOD_STUDIO_PARAMETER_DESCRIPTION = typeof(FMOD_STUDIO_PARAMETER_DESCRIPTION:new({}))

local FMOD_STUDIO_PROGRAMMER_SOUND_PROPERTIES = ffi.struct({
	{ subsoundIndex = ffi.types.i32 },
})
export type FMOD_STUDIO_PROGRAMMER_SOUND_PROPERTIES = typeof(FMOD_STUDIO_PROGRAMMER_SOUND_PROPERTIES:new({}))

local FMOD_STUDIO_TIMELINE_MARKER_PROPERTIES = ffi.struct({
	{ position = ffi.types.i32 },
})
export type FMOD_STUDIO_TIMELINE_MARKER_PROPERTIES = typeof(FMOD_STUDIO_TIMELINE_MARKER_PROPERTIES:new({}))

local FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES = ffi.struct({
	{ bar = ffi.types.i32 },
	{ beat = ffi.types.i32 },
	{ position = ffi.types.i32 },
	{ tempo = ffi.types.float },
	{ timesignatureupper = ffi.types.i32 },
	{ timesignaturelower = ffi.types.i32 },
})
export type FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES = typeof(FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES:new({}))

local FMOD_STUDIO_TIMELINE_NESTED_BEAT_PROPERTIES = ffi.struct({
	{ eventid = ffi.types.pointer },
	{ properties = FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES },
})
export type FMOD_STUDIO_TIMELINE_NESTED_BEAT_PROPERTIES = typeof(FMOD_STUDIO_TIMELINE_NESTED_BEAT_PROPERTIES:new({}))

local FMOD_STUDIO_ADVANCEDSETTINGS = ffi.struct({
	{ cbsize = ffi.types.i32 },
	{ commandqueuesize = ffi.types.i32 },
	{ handleinitialsize = ffi.types.i32 },
	{ studioupdateperiod = ffi.types.i32 },
	{ idlesampledatapoolsize = ffi.types.i32 },
	{ streamingscheduledelay = ffi.types.i32 },
	{ encryptionkey = ffi.types.pointer },
})
export type FMOD_STUDIO_ADVANCEDSETTINGS = typeof(FMOD_STUDIO_ADVANCEDSETTINGS:new({}))

local FMOD_STUDIO_CPU_USAGE = ffi.struct({
	{ update = ffi.types.float },
})
export type FMOD_STUDIO_CPU_USAGE = typeof(FMOD_STUDIO_CPU_USAGE:new({}))

local FMOD_STUDIO_BUFFER_INFO = ffi.struct({
	{ currentusage = ffi.types.i32 },
	{ peakusage = ffi.types.i32 },
	{ capacity = ffi.types.i32 },
	{ stallcount = ffi.types.i32 },
	{ stalltime = ffi.types.float },
})
export type FMOD_STUDIO_BUFFER_INFO = typeof(FMOD_STUDIO_BUFFER_INFO:new({}))

local FMOD_STUDIO_BUFFER_USAGE = ffi.struct({
	{ studiocommandqueue = FMOD_STUDIO_BUFFER_INFO },
	{ studiohandle = FMOD_STUDIO_BUFFER_INFO },
})
export type FMOD_STUDIO_BUFFER_USAGE = typeof(FMOD_STUDIO_BUFFER_USAGE:new({}))

local FMOD_STUDIO_SOUND_INFO = ffi.struct({
	{ mode = ffi.types.pointer },
	{ exinfo = ffi.types.pointer },
	{ subsoundindex = ffi.types.i32 },
})
export type FMOD_STUDIO_SOUND_INFO = typeof(FMOD_STUDIO_SOUND_INFO:new({}))

local FMOD_STUDIO_COMMAND_INFO = ffi.struct({
	{ parentcommandindex = ffi.types.i32 },
	{ framenumber = ffi.types.i32 },
	{ frametime = ffi.types.float },
	{ instancetype = ffi.types.pointer },
	{ outputtype = ffi.types.pointer },
	{ instancehandle = ffi.types.i32 },
	{ outputhandle = ffi.types.i32 },
})
export type FMOD_STUDIO_COMMAND_INFO = typeof(FMOD_STUDIO_COMMAND_INFO:new({}))

local FMOD_STUDIO_MEMORY_USAGE = ffi.struct({
	{ exclusive = ffi.types.i32 },
	{ inclusive = ffi.types.i32 },
	{ sampledata = ffi.types.i32 },
})
export type FMOD_STUDIO_MEMORY_USAGE = typeof(FMOD_STUDIO_MEMORY_USAGE:new({}))

-- Function definitions
local funcs = {
	FMOD_Studio_ParseID = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_System_Create = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_SetAdvancedSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetAdvancedSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_Initialize = {
		returns = ffi.types.pointer,
		args = { ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_Update = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_GetCoreSystem = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_System_GetEvent = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetVCA = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBank = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetEventByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBusByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetVCAByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBankByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetSoundInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetParameterDescriptionByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetParameterDescriptionByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetParameterLabelByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_GetParameterLabelByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_GetParameterByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_System_SetParameterByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Studio_System_SetParameterByIDWithLabel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_SetParametersByIDs = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Studio_System_GetParameterByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_System_SetParameterByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Studio_System_SetParameterByNameWithLabel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_LookupID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_LookupPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_GetNumListeners = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_System_SetNumListeners = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_System_GetListenerAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_SetListenerAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetListenerWeight = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Studio_System_SetListenerWeight = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Studio_System_LoadBankFile = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_LoadBankMemory = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	FMOD_Studio_System_LoadBankCustom = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_RegisterPlugin = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_System_UnregisterPlugin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_UnloadAll = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_FlushCommands = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_FlushSampleLoading = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_StartCommandCapture = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_StopCommandCapture = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_LoadCommandReplay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBankCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_System_GetBankList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_GetParameterDescriptionCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_System_GetParameterDescriptionList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_System_GetCPUUsage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_GetBufferUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_System_ResetBufferUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_SetCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_System_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_System_GetMemoryUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_EventDescription_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventDescription_GetID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetParameterDescriptionCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetParameterDescriptionByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetParameterDescriptionByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetParameterDescriptionByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetParameterLabelByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetParameterLabelByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetParameterLabelByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetUserPropertyCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetUserPropertyByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetUserProperty = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetLength = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventDescription_GetSoundSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float },
	},
	FMOD_Studio_EventDescription_IsSnapshot = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_IsOneshot = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_IsStream = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_Is3D = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_EventDescription_IsDopplerEnabled = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_HasSustainPoint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_CreateInstance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetInstanceCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_GetInstanceList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_EventDescription_LoadSampleData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventDescription_UnloadSampleData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventDescription_GetSampleLoadingState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_ReleaseAllInstances = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventDescription_SetCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_GetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	FMOD_Studio_EventDescription_SetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventInstance_GetDescription = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetSystem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetVolume = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Studio_EventInstance_GetPitch = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetPitch = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Studio_EventInstance_Get3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_Set3DAttributes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetListenerMask = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	FMOD_Studio_EventInstance_SetListenerMask = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	FMOD_Studio_EventInstance_GetProperty = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetProperty = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	FMOD_Studio_EventInstance_GetReverbLevel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetReverbLevel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Studio_EventInstance_GetPaused = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_SetPaused = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_Start = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventInstance_Stop = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_EventInstance_GetTimelinePosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventInstance_SetTimelinePosition = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_EventInstance_GetPlaybackState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetChannelGroup = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetMinMaxDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventInstance_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventInstance_IsVirtual = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetParameterByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetParameterByName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_SetParameterByNameWithLabel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetParameterByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_EventInstance_SetParameterByID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_SetParameterByIDWithLabel = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_SetParametersByIDs = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_KeyOff = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_EventInstance_SetCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_SetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	FMOD_Studio_EventInstance_GetCPUUsage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_Studio_EventInstance_GetMemoryUsage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_Bus_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bus_GetID = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_GetPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bus_GetVolume = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_Bus_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Studio_Bus_GetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_SetPaused = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_GetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_SetMute = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_StopAllEvents = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_GetPortIndex = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_SetPortIndex = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_LockChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bus_UnlockChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bus_GetChannelGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bus_GetCPUUsage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	FMOD_Studio_Bus_GetMemoryUsage = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_VCA_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_VCA_GetID = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_VCA_GetPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_VCA_GetVolume = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	FMOD_Studio_VCA_SetVolume = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Studio_Bank_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bank_GetID = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bank_GetPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bank_Unload = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bank_LoadSampleData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bank_UnloadSampleData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bank_GetLoadingState = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	FMOD_Studio_Bank_GetSampleLoadingState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_Bank_GetStringCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_Bank_GetStringInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i8, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bank_GetEventCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_Bank_GetEventList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bank_GetBusCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_Bank_GetBusList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bank_GetVCACount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	FMOD_Studio_Bank_GetVCAList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	FMOD_Studio_Bank_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_Bank_SetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_CommandReplay_IsValid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_CommandReplay_GetSystem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_GetLength = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	FMOD_Studio_CommandReplay_GetCommandCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_CommandReplay_GetCommandInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_GetCommandString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i8, ffi.types.i32 },
	},
	FMOD_Studio_CommandReplay_GetCommandAtTime = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.i32 },
	},
	FMOD_Studio_CommandReplay_SetBankPath = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_Start = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_CommandReplay_Stop = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_CommandReplay_SeekToTime = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float },
	},
	FMOD_Studio_CommandReplay_SeekToCommand = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	FMOD_Studio_CommandReplay_GetPaused = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_SetPaused = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_GetPlaybackState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_GetCurrentCommand = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	FMOD_Studio_CommandReplay_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FMOD_Studio_CommandReplay_SetFrameCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_SetLoadBankCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_SetCreateInstanceCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_GetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	FMOD_Studio_CommandReplay_SetUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
}

local structs = {
	FMOD_STUDIO_BANK_INFO = FMOD_STUDIO_BANK_INFO,
	FMOD_STUDIO_PARAMETER_ID = FMOD_STUDIO_PARAMETER_ID,
	FMOD_STUDIO_PARAMETER_DESCRIPTION = FMOD_STUDIO_PARAMETER_DESCRIPTION,
	FMOD_STUDIO_PROGRAMMER_SOUND_PROPERTIES = FMOD_STUDIO_PROGRAMMER_SOUND_PROPERTIES,
	FMOD_STUDIO_TIMELINE_MARKER_PROPERTIES = FMOD_STUDIO_TIMELINE_MARKER_PROPERTIES,
	FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES = FMOD_STUDIO_TIMELINE_BEAT_PROPERTIES,
	FMOD_STUDIO_TIMELINE_NESTED_BEAT_PROPERTIES = FMOD_STUDIO_TIMELINE_NESTED_BEAT_PROPERTIES,
	FMOD_STUDIO_ADVANCEDSETTINGS = FMOD_STUDIO_ADVANCEDSETTINGS,
	FMOD_STUDIO_CPU_USAGE = FMOD_STUDIO_CPU_USAGE,
	FMOD_STUDIO_BUFFER_INFO = FMOD_STUDIO_BUFFER_INFO,
	FMOD_STUDIO_BUFFER_USAGE = FMOD_STUDIO_BUFFER_USAGE,
	FMOD_STUDIO_SOUND_INFO = FMOD_STUDIO_SOUND_INFO,
	FMOD_STUDIO_COMMAND_INFO = FMOD_STUDIO_COMMAND_INFO,
	FMOD_STUDIO_MEMORY_USAGE = FMOD_STUDIO_MEMORY_USAGE,
}

return { funcs = funcs, structs = structs }
