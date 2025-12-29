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

local ScePadTriggerEffectOffParam = ffi.struct({
	{ padding = ffi.types.u8:array(48) },
})
export type ScePadTriggerEffectOffParam = typeof(ScePadTriggerEffectOffParam:new({}))

local ScePadTriggerEffectFeedbackParam = ffi.struct({
	{ position = ffi.types.u8 },
	{ strength = ffi.types.u8 },
	{ padding = ffi.types.u8:array(46) },
})
export type ScePadTriggerEffectFeedbackParam = typeof(ScePadTriggerEffectFeedbackParam:new({}))

local ScePadTriggerEffectWeaponParam = ffi.struct({
	{ startPosition = ffi.types.u8 },
	{ endPosition = ffi.types.u8 },
	{ strength = ffi.types.u8 },
	{ padding = ffi.types.u8:array(45) },
})
export type ScePadTriggerEffectWeaponParam = typeof(ScePadTriggerEffectWeaponParam:new({}))

local ScePadTriggerEffectVibrationParam = ffi.struct({
	{ position = ffi.types.u8 },
	{ amplitude = ffi.types.u8 },
	{ frequency = ffi.types.u8 },
	{ padding = ffi.types.u8:array(45) },
})
export type ScePadTriggerEffectVibrationParam = typeof(ScePadTriggerEffectVibrationParam:new({}))

local ScePadTriggerEffectMultiplePositionFeedbackParam = ffi.struct({
	{ strength = ffi.types.u8:array(10) },
	{ padding = ffi.types.u8:array(38) },
})
export type ScePadTriggerEffectMultiplePositionFeedbackParam =
	typeof(ScePadTriggerEffectMultiplePositionFeedbackParam:new({}))

local ScePadTriggerEffectSlopeFeedbackParam = ffi.struct({
	{ startPosition = ffi.types.u8 },
	{ endPosition = ffi.types.u8 },
	{ startStrength = ffi.types.u8 },
	{ endStrength = ffi.types.u8 },
	{ padding = ffi.types.u8:array(44) },
})
export type ScePadTriggerEffectSlopeFeedbackParam = typeof(ScePadTriggerEffectSlopeFeedbackParam:new({}))

local ScePadTriggerEffectMultiplePositionVibrationParam = ffi.struct({
	{ frequency = ffi.types.u8 },
	{ amplitude = ffi.types.u8:array(10) },
	{ padding = ffi.types.u8:array(37) },
})
export type ScePadTriggerEffectMultiplePositionVibrationParam =
	typeof(ScePadTriggerEffectMultiplePositionVibrationParam:new({}))

local ScePadTriggerEffectCommand = ffi.struct({
	{ mode = ffi.types.pointer },
	{ padding = ffi.types.u8:array(4) },
	{ commandData = ffi.types.pointer },
})
export type ScePadTriggerEffectCommand = typeof(ScePadTriggerEffectCommand:new({}))

local ScePadTriggerEffectParam = ffi.struct({
	{ triggerMask = ffi.types.u8 },
	{ padding = ffi.types.u8:array(7) },
	{ command = ScePadTriggerEffectCommand:array(2) },
})
export type ScePadTriggerEffectParam = typeof(ScePadTriggerEffectParam:new({}))

local ValvePackingSentinel_t = ffi.struct({
	{ m_u32 = ffi.types.pointer },
	{ m_u64 = ffi.types.pointer },
	{ m_u16 = ffi.types.pointer },
	{ m_d = ffi.types.double },
})
export type ValvePackingSentinel_t = typeof(ValvePackingSentinel_t:new({}))

local funcs = {
	SteamClient = { returns = ffi.types.pointer, args = {} },
	SteamAPI_InitFlat = { returns = ffi.types.pointer, args = { ffi.types.pointer } },

	SteamAPI_Shutdown = { returns = ffi.types.pointer, args = {} },
	SteamAPI_RestartAppIfNecessary = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ReleaseCurrentThreadMemory = { returns = ffi.types.pointer, args = {} },
	SteamAPI_WriteMiniDump = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SetMiniDumpComment = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_IsSteamRunning = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SetTryCatchCallbacks = { returns = ffi.types.void, args = { ffi.types.u8 } },
	SteamAPI_InitSafe = { returns = ffi.types.pointer, args = {} },
	SteamAPI_UseBreakpadCrashHandler = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.pointer,
		},
	},
	SteamAPI_SetBreakpadAppID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ManualDispatch_Init = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ManualDispatch_RunFrame = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ManualDispatch_GetNextCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ManualDispatch_FreeLastCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ManualDispatch_GetAPICallResult = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.u8 },
	},
	SteamInternal_SteamAPI_Init = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_RunCallbacks = { returns = ffi.types.pointer, args = {} },
	SteamGameServer_RunCallbacks = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamClient_CreateSteamPipe = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamClient_BReleaseSteamPipe = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_ConnectToGlobalUser = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_CreateLocalUser = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_ReleaseUser = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamUser = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamGameServer = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_SetLocalIPBinding = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamFriends = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamUtils = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamMatchmaking = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamMatchmakingServers = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamGenericInterface = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamUserStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamGameServerStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamApps = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamNetworking = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamRemoteStorage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamScreenshots = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetIPCCallCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamClient_SetWarningMessageHook = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_BShutdownIfAllPipesClosed = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamClient_GetISteamHTTP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamController = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamUGC = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamMusic = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamHTMLSurface = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamInventory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamVideo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamParentalSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamParties = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamClient_GetISteamRemotePlay = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamUser_v023 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamUser_GetHSteamUser = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_BLoggedOn = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_GetSteamID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_InitiateGameConnection_DEPRECATED = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
		},
	},
	SteamAPI_ISteamUser_TerminateGameConnection_DEPRECATED = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_TrackAppUsageEvent = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_GetUserDataFolder = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamUser_StartVoiceRecording = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_StopVoiceRecording = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_GetAvailableVoice = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_GetVoice = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUser_DecompressVoice = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUser_GetVoiceOptimalSampleRate = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_GetAuthSessionTicket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_GetAuthTicketForWebApi = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_BeginAuthSession = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_EndAuthSession = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUser_CancelAuthTicket = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUser_UserHasLicenseForApp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_BIsBehindNAT = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_AdvertiseGame = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_RequestEncryptedAppTicket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamUser_GetEncryptedAppTicket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_GetGameBadgeLevel = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u8 },
	},
	SteamAPI_ISteamUser_GetPlayerSteamLevel = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_RequestStoreAuthURL = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUser_BIsPhoneVerified = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_BIsTwoFactorEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_BIsPhoneIdentifying = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_BIsPhoneRequiringVerification = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_GetMarketEligibility = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_GetDurationControl = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUser_BSetDurationControlOnlineState = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamFriends_v018 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamFriends_GetPersonaName = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetPersonaState = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetFriendCount = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	SteamAPI_ISteamFriends_GetFriendByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetFriendRelationship = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendPersonaState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendPersonaName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendGamePlayed = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendPersonaNameHistory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetFriendSteamLevel = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetPlayerNickname = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendsGroupCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetFriendsGroupIDByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetFriendsGroupName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendsGroupMembersCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendsGroupMembersList = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_HasFriend = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetClanCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetClanByIndex = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	SteamAPI_ISteamFriends_GetClanName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanTag = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetClanActivityCounts = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_DownloadClanActivityCounts = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetFriendCountFromSource = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendFromSourceByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_IsUserInSource = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_SetInGameVoiceSpeaking = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlay = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlayToUser = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlayToWebPage = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlayToStore = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_SetPlayedWith = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamFriends_ActivateGameOverlayInviteDialog = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetSmallFriendAvatar = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetMediumFriendAvatar = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetLargeFriendAvatar = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_RequestUserInformation = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamFriends_RequestClanOfficerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanOwner = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanOfficerCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanOfficerByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_SetRichPresence = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ClearRichPresence = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetFriendRichPresence = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendRichPresenceKeyCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendRichPresenceKeyByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_RequestFriendRichPresence = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_InviteUserToGame = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetCoplayFriendCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamFriends_GetCoplayFriend = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_GetFriendCoplayTime = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendCoplayGame = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_JoinClanChatRoom = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_LeaveClanChatRoom = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanChatMemberCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetChatMemberByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamFriends_SendClanChatMessage = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetClanChatMessage = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamFriends_IsClanChatAdmin = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_IsClanChatWindowOpenInSteam = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_OpenClanChatWindowInSteam = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_CloseClanChatWindowInSteam = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_SetListenForFriendsMessages = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamFriends_ReplyToFriendMessage = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetFriendMessage = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamFriends_GetFollowerCount = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_IsFollowing = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_EnumerateFollowingList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_IsClanPublic = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamFriends_IsClanOfficialGameGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetNumChatsWithUnreadPriorityMessages = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlayRemotePlayTogetherInviteDialog = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_RegisterProtocolInOverlayBrowser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_ActivateGameOverlayInviteDialogConnectString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_RequestEquippedProfileItems = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_BHasEquippedProfileItem = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetProfileItemPropertyString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamFriends_GetProfileItemPropertyUint = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamUtils_v010 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerUtils_v010 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamUtils_GetSecondsSinceAppActive = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetSecondsSinceComputerActive = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetConnectedUniverse = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetServerRealTime = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetIPCountry = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetImageSize = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_GetImageRGBA = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamUtils_GetCurrentBatteryPower = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetAppID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_SetOverlayNotificationPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_IsAPICallCompleted = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_GetAPICallFailureReason = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_GetAPICallResult = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUtils_GetIPCCallCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_SetWarningMessageHook = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_IsOverlayEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_BOverlayNeedsPresent = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_CheckFileSignature = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_ShowGamepadTextInput = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUtils_GetEnteredGamepadTextLength = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_GetEnteredGamepadTextInput = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_GetSteamUILanguage = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_IsSteamRunningInVR = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_SetOverlayNotificationInset = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamUtils_IsSteamInBigPictureMode = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_StartVRDashboard = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_IsVRHeadsetStreamingEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_SetVRHeadsetStreamingEnabled = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUtils_IsSteamChinaLauncher = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_InitFilterText = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUtils_FilterText = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUtils_GetIPv6ConnectivityState = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUtils_IsSteamRunningOnSteamDeck = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_ShowFloatingGamepadTextInput = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamUtils_SetGameLauncherMode = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamUtils_DismissFloatingGamepadTextInput = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUtils_DismissGamepadTextInput = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamMatchmaking_v009 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamMatchmaking_GetFavoriteGameCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamMatchmaking_GetFavoriteGame = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamMatchmaking_AddFavoriteGame = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamMatchmaking_RemoveFavoriteGame = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamMatchmaking_RequestLobbyList = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListStringFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListNumericalFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListNearValueFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListFilterSlotsAvailable = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListDistanceFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListResultCountFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_AddRequestLobbyListCompatibleMembersFilter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_CreateLobby = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_JoinLobby = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_LeaveLobby = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_InviteUserToLobby = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetNumLobbyMembers = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyMemberByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyDataCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyDataByIndex = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamMatchmaking_DeleteLobbyData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyMemberData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyMemberData = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SendLobbyChatMsg = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyChatEntry = {
		returns = ffi.types.i32,
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
	SteamAPI_ISteamMatchmaking_RequestLobbyData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyGameServer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyGameServer = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyMemberLimit = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyMemberLimit = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyType = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyJoinable = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamMatchmaking_GetLobbyOwner = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLobbyOwner = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmaking_SetLinkedLobby = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServerListResponse_ServerResponded = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmakingServerListResponse_ServerFailedToRespond = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmakingServerListResponse_RefreshComplete = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingPingResponse_ServerResponded = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingPingResponse_ServerFailedToRespond = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingPlayersResponse_AddPlayerToList = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	SteamAPI_ISteamMatchmakingPlayersResponse_PlayersFailedToRespond = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingPlayersResponse_PlayersRefreshComplete = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingRulesResponse_RulesResponded = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingRulesResponse_RulesFailedToRespond = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingRulesResponse_RulesRefreshComplete = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_SteamMatchmakingServers_v002 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamMatchmakingServers_RequestInternetServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RequestLANServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RequestFriendsServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RequestFavoritesServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RequestHistoryServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RequestSpectatorServerList = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_ReleaseRequest = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_GetServerDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmakingServers_CancelQuery = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RefreshQuery = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_IsRefreshing = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_GetServerCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_RefreshServer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamMatchmakingServers_PingServer = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_PlayerDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_ServerRules = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamMatchmakingServers_CancelServerQuery = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamParties_v002 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamParties_GetNumActiveBeacons = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamParties_GetBeaconByIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_GetBeaconDetails = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamParties_JoinParty = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamParties_GetNumAvailableBeaconLocations = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_GetAvailableBeaconLocations = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_CreateBeacon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_OnReservationCompleted = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_CancelReservation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_ChangeNumOpenSlots = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParties_DestroyBeacon = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamParties_GetBeaconLocationData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_SteamRemoteStorage_v016 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamRemoteStorage_FileWrite = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileRead = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileWriteAsync = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileReadAsync = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileReadAsyncComplete = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileForget = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileDelete = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileShare = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_SetSyncPlatforms = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileWriteStreamOpen = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileWriteStreamWriteChunk = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileWriteStreamClose = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileWriteStreamCancel = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FileExists = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_FilePersisted = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetFileSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetFileTimestamp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetSyncPlatforms = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetFileCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_GetFileNameAndSize = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetQuota = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_IsCloudEnabledForAccount = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_IsCloudEnabledForApp = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_SetCloudEnabledForApp = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamRemoteStorage_UGCDownload = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetUGCDownloadProgress = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetUGCDetails = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamRemoteStorage_UGCRead = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamRemoteStorage_GetCachedUGCCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_GetCachedUGCHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_PublishWorkshopFile = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamRemoteStorage_CreatePublishedFileUpdateRequest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileFile = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFilePreviewFile = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileTitle = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileDescription = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileVisibility = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileTags = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_CommitPublishedFileUpdate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetPublishedFileDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_DeletePublishedFile = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_EnumerateUserPublishedFiles = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_SubscribePublishedFile = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_EnumerateUserSubscribedFiles = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UnsubscribePublishedFile = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdatePublishedFileSetChangeDescription = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetPublishedItemVoteDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_UpdateUserPublishedItemVote = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamRemoteStorage_GetUserPublishedItemVoteDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_EnumerateUserSharedWorkshopFiles = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_PublishVideo = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamRemoteStorage_SetUserPublishedFileAction = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_EnumeratePublishedFilesByUserAction = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_EnumeratePublishedWorkshopFiles = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamRemoteStorage_UGCDownloadToLocation = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_GetLocalFileChangeCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_GetLocalFileChange = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemoteStorage_BeginFileWriteBatch = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemoteStorage_EndFileWriteBatch = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamUserStats_v013 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamUserStats_GetStatInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetStatFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_SetStatInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_SetStatFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamUserStats_UpdateAvgRateStat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.double },
	},
	SteamAPI_ISteamUserStats_GetAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_SetAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_ClearAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetAchievementAndUnlockTime = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_StoreStats = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUserStats_GetAchievementIcon = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetAchievementDisplayAttribute = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_IndicateAchievementProgress = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetNumAchievements = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUserStats_GetAchievementName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_RequestUserStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetUserStatInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetUserStatFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetUserAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetUserAchievementAndUnlockTime = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_ResetAllStats = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamUserStats_FindOrCreateLeaderboard = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_FindLeaderboard = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetLeaderboardName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetLeaderboardEntryCount = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetLeaderboardSortMethod = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetLeaderboardDisplayType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_DownloadLeaderboardEntries = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamUserStats_DownloadLeaderboardEntriesForUsers = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamUserStats_GetDownloadedLeaderboardEntry = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamUserStats_UploadLeaderboardScore = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamUserStats_AttachLeaderboardUGC = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetNumberOfCurrentPlayers = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUserStats_RequestGlobalAchievementPercentages = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetMostAchievedAchievementInfo = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetNextMostAchievedAchievementInfo = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUserStats_GetAchievementAchievedPercent = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_RequestGlobalStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamUserStats_GetGlobalStatInt64 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetGlobalStatDouble = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetGlobalStatHistoryInt64 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetGlobalStatHistoryDouble = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetAchievementProgressLimitsInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUserStats_GetAchievementProgressLimitsFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamApps_v008 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamApps_BIsSubscribed = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsLowViolence = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsCybercafe = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsVACBanned = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_GetCurrentGameLanguage = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_GetAvailableGameLanguages = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsSubscribedApp = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsDlcInstalled = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_GetEarliestPurchaseUnixTime = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_BIsSubscribedFromFreeWeekend = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_GetDLCCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BGetDLCDataByIndex = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamApps_InstallDLC = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_UninstallDLC = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_RequestAppProofOfPurchaseKey = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetCurrentBetaName = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamApps_MarkContentCorrupt = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamApps_GetInstalledDepots = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetAppInstallDir = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_BIsAppInstalled = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_GetAppOwner = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_GetLaunchQueryParam = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetDlcDownloadProgress = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetAppBuildId = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_RequestAllProofOfPurchaseKeys = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_GetFileDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetLaunchCommandLine = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamApps_BIsSubscribedFromFamilySharing = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamApps_BIsTimedTrial = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_SetDlcContext = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamApps_GetNumBetas = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamApps_GetBetaInfo = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamApps_SetActiveBeta = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_SteamNetworking_v006 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerNetworking_v006 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworking_SendP2PPacket = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamNetworking_IsP2PPacketAvailable = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworking_ReadP2PPacket = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamNetworking_AcceptP2PSessionWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_CloseP2PSessionWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_CloseP2PChannelWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworking_GetP2PSessionState = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_AllowP2PPacketRelay = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_CreateListenSocket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_CreateP2PConnectionSocket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_CreateConnectionSocket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworking_DestroySocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_DestroyListenSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_SendDataOnSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworking_IsDataAvailableOnSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_RetrieveDataFromSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_IsDataAvailable = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_RetrieveData = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworking_GetSocketInfo = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworking_GetListenSocketInfo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_GetSocketConnectionType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworking_GetMaxPacketSize = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamScreenshots_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamScreenshots_WriteScreenshot = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamScreenshots_AddScreenshotToLibrary = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamScreenshots_TriggerScreenshot = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamScreenshots_HookScreenshots = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamScreenshots_SetLocation = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamScreenshots_TagUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamScreenshots_TagPublishedFile = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamScreenshots_IsScreenshotsHooked = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamScreenshots_AddVRScreenshotToLibrary = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamMusic_v001 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamMusic_BIsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_BIsPlaying = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_GetPlaybackStatus = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_Play = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_Pause = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_PlayPrevious = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_PlayNext = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamMusic_SetVolume = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	SteamAPI_ISteamMusic_GetVolume = { returns = ffi.types.float, args = { ffi.types.pointer } },
	SteamAPI_SteamHTTP_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerHTTP_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamHTTP_CreateHTTPRequest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestContextValue = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestNetworkActivityTimeout = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestHeaderValue = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestGetOrPostParameter = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SendHTTPRequest = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SendHTTPRequestAndStreamResponse = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_DeferHTTPRequest = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTTP_PrioritizeHTTPRequest = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPResponseHeaderSize = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPResponseHeaderValue = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPResponseBodySize = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPResponseBodyData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPStreamingResponseBodyData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_ReleaseHTTPRequest = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTTP_GetHTTPDownloadProgressPct = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestRawPostBody = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_CreateCookieContainer = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTTP_ReleaseCookieContainer = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetCookie = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestCookieContainer = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestUserAgentInfo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestRequiresVerifiedCertificate = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTTP_SetHTTPRequestAbsoluteTimeoutMS = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTTP_GetHTTPRequestWasTimedOut = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamInput_v006 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamInput_Init = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamInput_Shutdown = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamInput_SetInputActionManifestFilePath = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_RunFrame = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamInput_BWaitForData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u8, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_BNewDataAvailable = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamInput_GetConnectedControllers = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_EnableDeviceCallbacks = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamInput_EnableActionEventCallbacks = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetActionSetHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_ActivateActionSet = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetCurrentActionSet = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_ActivateActionSetLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_DeactivateActionSetLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_DeactivateAllActionSetLayers = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetActiveActionSetLayers = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetDigitalActionHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetDigitalActionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetDigitalActionOrigins = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetStringForDigitalActionName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetAnalogActionHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetAnalogActionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetAnalogActionOrigins = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetGlyphPNGForActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetGlyphSVGForActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetGlyphForActionOrigin_Legacy = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetStringForActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetStringForAnalogActionName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_StopAnalogActionMomentum = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetMotionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_TriggerVibration = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u16, ffi.types.u16 },
	},
	SteamAPI_ISteamInput_TriggerVibrationExtended = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u16, ffi.types.u16, ffi.types.u16, ffi.types.u16 },
	},
	SteamAPI_ISteamInput_TriggerSimpleHapticEvent = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i8,
			ffi.types.pointer,
			ffi.types.i8,
		},
	},
	SteamAPI_ISteamInput_SetLEDColor = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u32,
		},
	},
	SteamAPI_ISteamInput_Legacy_TriggerHapticPulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u16 },
	},
	SteamAPI_ISteamInput_Legacy_TriggerRepeatedHapticPulse = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u16,
			ffi.types.u16,
			ffi.types.u16,
			ffi.types.u32,
		},
	},
	SteamAPI_ISteamInput_ShowBindingPanel = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamInput_GetInputTypeForHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetControllerForGamepadIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamInput_GetGamepadIndexForController = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetStringForXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetGlyphForXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetActionOriginFromXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_TranslateActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetDeviceBindingRevision = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetRemotePlaySessionID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInput_GetSessionInputConfigurationSettings = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamInput_SetDualSenseTriggerEffect = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamController_v008 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamController_Init = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamController_Shutdown = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamController_RunFrame = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamController_GetConnectedControllers = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetActionSetHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_ActivateActionSet = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetCurrentActionSet = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_ActivateActionSetLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_DeactivateActionSetLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_DeactivateAllActionSetLayers = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetActiveActionSetLayers = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetDigitalActionHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetDigitalActionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetDigitalActionOrigins = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetAnalogActionHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetAnalogActionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetAnalogActionOrigins = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetGlyphForActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetStringForActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_StopAnalogActionMomentum = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetMotionData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_TriggerHapticPulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u16 },
	},
	SteamAPI_ISteamController_TriggerRepeatedHapticPulse = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u16,
			ffi.types.u16,
			ffi.types.u16,
			ffi.types.u32,
		},
	},
	SteamAPI_ISteamController_TriggerVibration = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u16, ffi.types.u16 },
	},
	SteamAPI_ISteamController_SetLEDColor = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u32,
		},
	},
	SteamAPI_ISteamController_ShowBindingPanel = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetInputTypeForHandle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetControllerForGamepadIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamController_GetGamepadIndexForController = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetStringForXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetGlyphForXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetActionOriginFromXboxOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_TranslateActionOrigin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamController_GetControllerBindingRevision = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamUGC_v021 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerUGC_v021 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamUGC_CreateQueryUserUGCRequest = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_CreateQueryAllUGCRequestPage = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_CreateQueryAllUGCRequestCursor = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_CreateQueryUGCDetailsRequest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SendQueryUGCRequest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCResult = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCNumTags = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCTag = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetQueryUGCTagDisplayName = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetQueryUGCPreviewURL = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCMetadata = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCChildren = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCStatistic = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCNumAdditionalPreviews = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCAdditionalPreview = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetQueryUGCNumKeyValueTags = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetQueryUGCKeyValueTag = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetQueryFirstUGCKeyValueTag = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetNumSupportedGameVersions = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetSupportedGameVersionData = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetQueryUGCContentDescriptors = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_ReleaseQueryUGCRequest = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddRequiredTag = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddRequiredTagGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddExcludedTag = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetReturnOnlyIDs = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnKeyValueTags = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnLongDescription = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnMetadata = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnChildren = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnAdditionalPreviews = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnTotalOnly = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetReturnPlaytimeStats = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetLanguage = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetAllowCachedResponse = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetAdminQuery = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetCloudFileNameFilter = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetMatchAnyTag = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetSearchText = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetRankedByTrendDays = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetTimeCreatedDateRange = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetTimeUpdatedDateRange = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddRequiredKeyValueTag = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RequestUGCDetails = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_CreateItem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_StartItemUpdate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemTitle = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemDescription = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemUpdateLanguage = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemMetadata = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemVisibility = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemTags = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetItemContent = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemPreview = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetAllowLegacyUpload = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_RemoveAllItemKeyValueTags = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveItemKeyValueTags = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddItemKeyValueTag = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddItemPreviewFile = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddItemPreviewVideo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_UpdateItemPreviewFile = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_UpdateItemPreviewVideo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveItemPreview = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddContentDescriptor = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveContentDescriptor = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetRequiredGameVersions = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SubmitItemUpdate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetItemUpdateProgress = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetUserItemVote = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_GetUserItemVote = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddItemToFavorites = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveItemFromFavorites = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SubscribeItem = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUGC_UnsubscribeItem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetNumSubscribedItems = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_GetSubscribedItems = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_GetItemState = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUGC_GetItemInstallInfo = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamUGC_GetItemDownloadInfo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_DownloadItem = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_BInitWorkshopForGameServer = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SuspendDownloads = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	SteamAPI_ISteamUGC_StartPlaytimeTracking = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_StopPlaytimeTracking = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_StopPlaytimeTrackingForAllItems = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUGC_AddDependency = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveDependency = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_AddAppDependency = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_RemoveAppDependency = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_GetAppDependencies = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_DeleteItem = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamUGC_ShowWorkshopEULA = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamUGC_GetWorkshopEULAStatus = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamUGC_GetUserContentDescriptorPreferences = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamUGC_SetItemsDisabledLocally = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamUGC_SetSubscriptionsLoadOrder = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamHTMLSurface_v005 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamHTMLSurface_Init = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_Shutdown = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_CreateBrowser = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_RemoveBrowser = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_LoadURL = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_SetSize = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_StopLoad = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_Reload = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_GoBack = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_GoForward = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_AddHeader = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_ExecuteJavascript = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_MouseUp = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_MouseDown = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_MouseDoubleClick = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_MouseMove = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamHTMLSurface_MouseWheel = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_KeyDown = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_KeyUp = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_KeyChar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_SetHorizontalScroll = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_SetVerticalScroll = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_SetKeyFocus = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_ViewSource = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_CopyToClipboard = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_PasteFromClipboard = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_Find = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_StopFind = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamHTMLSurface_GetLinkAtPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamHTMLSurface_SetCookie = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.u8,
		},
	},
	SteamAPI_ISteamHTMLSurface_SetPageScaleFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	SteamAPI_ISteamHTMLSurface_SetBackgroundMode = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_SetDPIScalingFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamHTMLSurface_OpenDeveloperTools = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamHTMLSurface_AllowStartRequest = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_JSDialogResponse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamHTMLSurface_FileLoadDialogResponse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamInventory_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerInventory_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamInventory_GetResultStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetResultItems = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetResultItemProperty = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamInventory_GetResultTimestamp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_CheckResultSteamID = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_DestroyResult = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetAllItems = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamInventory_GetItemsByID = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_SerializeResult = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_DeserializeResult = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamInventory_GenerateItems = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GrantPromoItems = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_AddPromoItem = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_AddPromoItems = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_ConsumeItem = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_ExchangeItems = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamInventory_TransferItemQuantity = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_SendItemDropHeartbeat = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamInventory_TriggerItemDrop = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_TradeItems = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamInventory_LoadItemDefinitions = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamInventory_GetItemDefinitionIDs = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetItemDefinitionProperty = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_RequestEligiblePromoItemDefinitionsIDs = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetEligiblePromoItemDefinitionIDs = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_StartPurchase = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_RequestPrices = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamInventory_GetNumItemsWithPrices = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamInventory_GetItemsWithPrices = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_GetItemPrice = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_StartUpdateProperties = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamInventory_RemoveProperty = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_SetPropertyString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_SetPropertyBool = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamInventory_SetPropertyInt64 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_SetPropertyFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamInventory_SubmitUpdateProperties = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamInventory_InspectItem = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamTimeline_v004 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamTimeline_SetTimelineTooltip = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamTimeline_ClearTimelineTooltip = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamTimeline_SetTimelineGameMode = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_AddInstantaneousTimelineEvent = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamTimeline_AddRangeTimelineEvent = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamTimeline_StartRangeTimelineEvent = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamTimeline_UpdateRangeTimelineEvent = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamTimeline_EndRangeTimelineEvent = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamTimeline_RemoveTimelineEvent = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_DoesEventRecordingExist = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_StartGamePhase = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamTimeline_EndGamePhase = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamTimeline_SetGamePhaseID = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_DoesGamePhaseRecordingExist = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_AddGamePhaseTag = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_SetGamePhaseAttribute = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_OpenOverlayToGamePhase = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamTimeline_OpenOverlayToTimelineEvent = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamVideo_v007 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamVideo_GetVideoURL = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamVideo_IsBroadcasting = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamVideo_GetOPFSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamVideo_GetOPFStringForApp = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamParentalSettings_v001 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamParentalSettings_BIsParentalLockEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamParentalSettings_BIsParentalLockLocked = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamParentalSettings_BIsAppBlocked = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParentalSettings_BIsAppInBlockList = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParentalSettings_BIsFeatureBlocked = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamParentalSettings_BIsFeatureInBlockList = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamRemotePlay_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamRemotePlay_GetSessionCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemotePlay_GetSessionID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamRemotePlay_GetSessionSteamID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_GetSessionClientName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_GetSessionClientFormFactor = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_BGetSessionClientResolution = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_ShowRemotePlayTogetherUI = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamRemotePlay_BSendRemotePlayTogetherInvite = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_BEnableRemotePlayTogetherDirectInput = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_DisableRemotePlayTogetherDirectInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_GetInput = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamRemotePlay_SetMouseVisibility = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamRemotePlay_SetMousePosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	SteamAPI_ISteamRemotePlay_CreateMouseCursor = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamRemotePlay_SetMouseCursor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingMessages_SteamAPI_v002 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerNetworkingMessages_SteamAPI_v002 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworkingMessages_SendMessageToUser = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
		},
	},
	SteamAPI_ISteamNetworkingMessages_ReceiveMessagesOnChannel = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingMessages_AcceptSessionWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingMessages_CloseSessionWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingMessages_CloseChannelWithUser = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingMessages_GetSessionConnectionInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingSockets_SteamAPI_v012 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_SteamGameServerNetworkingSockets_SteamAPI_v012 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateListenSocketP2P = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ConnectP2P = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_AcceptConnection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CloseConnection = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworkingSockets_CloseListenSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionUserData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionName = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionName = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_SendMessageToConnection = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingSockets_SendMessages = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_FlushMessagesOnConnection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionInfo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionRealTimeStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetDetailedConnectionStatus = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_GetListenSocketAddress = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateSocketPair = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingSockets_ConfigureConnectionLanes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetIdentity = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_InitAuthentication = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_GetAuthenticationStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreatePollGroup = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_DestroyPollGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_ReceivedRelayAuthTicket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_FindRelayAuthTicketForServer = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ConnectToHostedDedicatedServer = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerPort = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerPOPID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerAddress = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateHostedDedicatedServerListenSocket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetGameCoordinatorServerLogin = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ConnectP2PCustomSignaling = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetCertificateRequest = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetCertificate = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ResetIdentity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_RunCallbacks = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_BeginAsyncRequestFakeIP = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_GetFakeIP = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateListenSocketP2PFakeIP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetRemoteFakeIPForConnection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateFakeUDPPort = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_SteamNetworkingUtils_SteamAPI_v004 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworkingUtils_AllocateMessage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingUtils_InitRelayNetworkAccess = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingUtils_GetRelayNetworkStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetLocalPingLocation = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_EstimatePingTimeBetweenTwoLocations = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_EstimatePingTimeFromLocalHost = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_ConvertPingLocationToString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingUtils_ParsePingLocationString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_CheckPingDataUpToDate = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamNetworkingUtils_GetPingToDataCenter = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetDirectPingToPOP = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetPOPCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingUtils_GetPOPList = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingUtils_GetLocalTimestamp = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingUtils_SetDebugOutputFunction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_IsFakeIPv4 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetIPv4FakeIPType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetRealIdentityForFakeIP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValuePtr = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetConnectionStatusChanged = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetAuthenticationStatusChanged = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamRelayNetworkStatusChanged = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_FakeIPResult = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_MessagesSessionRequest = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_MessagesSessionFailed = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConfigValue = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingUtils_SetConfigValueStruct = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_GetConfigValue = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingUtils_GetConfigValueInfo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_IterateGenericEditableConfigValues = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworkingUtils_SteamNetworkingIPAddr_ToString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworkingUtils_SteamNetworkingIPAddr_ParseString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SteamNetworkingIPAddr_GetFakeIPType = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SteamNetworkingIdentity_ToString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SteamNetworkingIdentity_ParseString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamGameServer_v015 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamGameServer_SetProduct = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetGameDescription = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetModDir = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetDedicatedServer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamGameServer_LogOn = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamGameServer_LogOnAnonymous = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_LogOff = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_BLoggedOn = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_BSecure = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_GetSteamID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_WasRestartRequested = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetMaxPlayerCount = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamGameServer_SetBotPlayerCount = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamGameServer_SetServerName = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetMapName = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetPasswordProtected = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamGameServer_SetSpectatorPort = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetSpectatorServerName = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_ClearAllKeyValues = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetKeyValue = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetGameTags = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetGameData = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SetRegion = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_ISteamGameServer_SetAdvertiseServerActive = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamGameServer_GetAuthSessionTicket = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_BeginAuthSession = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_EndAuthSession = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_CancelAuthTicket = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_UserHasLicenseForApp = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_RequestUserGroupStatus = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_GetGameplayStats = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_GetServerReputation = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_GetPublicIP = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamGameServer_HandleIncomingPacket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_GetNextOutgoingPacket = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_AssociateWithClan = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_ComputeNewPlayerCompatibility = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SendUserConnectAndAuthenticate_DEPRECATED = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_CreateUnauthenticatedUserConnection = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_SendUserDisconnect_DEPRECATED = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServer_BUpdateUserData = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamGameServerStats_v001 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamGameServerStats_RequestUserStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_GetUserStatInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_GetUserStatFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_GetUserAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_SetUserStatInt32 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_SetUserStatFloat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamGameServerStats_UpdateUserAvgRateStat = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.double },
	},
	SteamAPI_ISteamGameServerStats_SetUserAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_ClearUserAchievement = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamGameServerStats_StoreUserStats = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingFakeUDPPort_DestroyFakeUDPPort = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingFakeUDPPort_SendMessageToFakeIP = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingFakeUDPPort_ReceiveMessages = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingFakeUDPPort_ScheduleCleanup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamIPAddress_t_IsSet = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_MatchMakingKeyValuePair_t_Construct = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_Construct = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_Init = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_servernetadr_t_GetQueryPort = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_SetQueryPort = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_servernetadr_t_GetConnectionPort = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_SetConnectionPort = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_servernetadr_t_GetIP = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_SetIP = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_servernetadr_t_GetConnectionAddressString = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_GetQueryAddressString = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_servernetadr_t_IsLessThan = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_servernetadr_t_Assign = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_gameserveritem_t_Construct = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_gameserveritem_t_GetName = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_gameserveritem_t_SetName = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_Clear = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_IsIPv6AllZeros = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_SetIPv6 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_SetIPv4 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_IsIPv4 = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_GetIPv4 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_SetIPv6LocalHost = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_IsLocalHost = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_ToString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_SteamNetworkingIPAddr_ParseString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_IsEqualTo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_GetFakeIPType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_IsFakeIP = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_Clear = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_IsInvalid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetSteamID = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetSteamID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetSteamID64 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetSteamID64 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetXboxPairwiseID = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetXboxPairwiseID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetPSNID = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetPSNID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetIPAddr = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetIPAddr = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetIPv4Addr = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetIPv4 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_GetFakeIPType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_IsFakeIP = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetLocalHost = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_IsLocalHost = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetGenericString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetGenericString = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetGenericBytes = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetGenericBytes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_IsEqualTo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_ToString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_ParseString = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingMessage_t_Release = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingConfigValue_t_SetInt32 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_SteamNetworkingConfigValue_t_SetInt64 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i64 },
	},
	SteamAPI_SteamNetworkingConfigValue_t_SetFloat = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_SteamNetworkingConfigValue_t_SetPtr = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingConfigValue_t_SetString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamDatagramHostedAddress_Clear = { returns = ffi.types.void, args = { ffi.types.pointer } },
	SteamAPI_SteamDatagramHostedAddress_GetPopID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamDatagramHostedAddress_SetDevAddress = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_GetHSteamPipe = { returns = ffi.types.pointer, args = {} },
	SteamAPI_GetHSteamUser = { returns = ffi.types.pointer, args = {} },
	SteamGameServer_GetHSteamPipe = { returns = ffi.types.pointer, args = {} },
	SteamGameServer_GetHSteamUser = { returns = ffi.types.pointer, args = {} },
	SteamInternal_ContextInit = { returns = ffi.types.pointer, args = {} },
	SteamInternal_CreateInterface = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamInternal_FindOrCreateUserInterface = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamInternal_FindOrCreateGameServerInterface = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_RegisterCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	SteamAPI_UnregisterCallback = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_RegisterCallResult = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamAPI_UnregisterCallResult = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	SteamGameServer_Shutdown = { returns = ffi.types.void, args = {} },
	SteamGameServer_BSecure = { returns = ffi.types.u8, args = {} },
	SteamGameServer_GetSteamID = { returns = ffi.types.pointer, args = {} },
	SteamInternal_GameServer_Init_V2 = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
}

local structs = {
	ScePadTriggerEffectOffParam = ScePadTriggerEffectOffParam,
	ScePadTriggerEffectFeedbackParam = ScePadTriggerEffectFeedbackParam,
	ScePadTriggerEffectWeaponParam = ScePadTriggerEffectWeaponParam,
	ScePadTriggerEffectVibrationParam = ScePadTriggerEffectVibrationParam,
	ScePadTriggerEffectMultiplePositionFeedbackParam = ScePadTriggerEffectMultiplePositionFeedbackParam,
	ScePadTriggerEffectSlopeFeedbackParam = ScePadTriggerEffectSlopeFeedbackParam,
	ScePadTriggerEffectMultiplePositionVibrationParam = ScePadTriggerEffectMultiplePositionVibrationParam,
	ScePadTriggerEffectCommand = ScePadTriggerEffectCommand,
	ScePadTriggerEffectParam = ScePadTriggerEffectParam,
	ValvePackingSentinel_t = ValvePackingSentinel_t,
}

return { funcs = funcs, structs = structs }
