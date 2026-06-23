local ffi = zune.ffi

-- Type aliases for FFI
type int = number
type float = number
type bool = boolean
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)

export type Fns = {
	GameNetworkingSockets_Init: (pIdentity: FFIPointer, errMsg: FFIPointer) -> FFIPointer,
	GameNetworkingSockets_Kill: () -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_AcceptConnection: (self: FFIPointer, hConn: int) -> int,
	SteamAPI_ISteamNetworkingSockets_CloseConnection: (
		self: FFIPointer,
		hPeer: int,
		nReason: int,
		pszDebug: cstring,
		bEnableLinger: bool
	) -> bool,
	SteamAPI_ISteamNetworkingSockets_CloseListenSocket: (self: FFIPointer, hSocket: int) -> bool,
	SteamAPI_ISteamNetworkingSockets_ConfigureConnectionLanes: (
		self: FFIPointer,
		hConn: FFIPointer,
		nNumLanes: int,
		pLanePriorities: int,
		pLaneWeights: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress: (
		self: FFIPointer,
		address: FFIPointer,
		nOptions: int,
		pOptions: FFIPointer
	) -> int,
	SteamAPI_ISteamNetworkingSockets_ConnectP2P: (
		self: FFIPointer,
		identityRemote: FFIPointer,
		nRemoteVirtualPort: int,
		nOptions: int,
		pOptions: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_ConnectP2PCustomSignaling: (
		self: FFIPointer,
		pSignaling: FFIPointer,
		pPeerIdentity: FFIPointer,
		nRemoteVirtualPort: int,
		nOptions: int,
		pOptions: FFIPointer
	) -> FFIPointer,

	SteamAPI_ISteamNetworkingSockets_CreateCustomSignaling: (
		ctx: any,
		fnSendSignal: FFIPointer,
		fnRelease: FFIPointer
	) -> FFIPointer,

	SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP: (
		self: FFIPointer,
		localAddress: FFIPointer,
		nOptions: int,
		pOptions: FFIPointer
	) -> int,
	SteamAPI_ISteamNetworkingSockets_CreateListenSocketP2P: (
		self: FFIPointer,
		nLocalVirtualPort: int,
		nOptions: int,
		pOptions: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_CreatePollGroup: (self: FFIPointer) -> int,
	SteamAPI_ISteamNetworkingSockets_CreateSocketPair: (
		self: FFIPointer,
		pOutConnection1: FFIPointer,
		pOutConnection2: FFIPointer,
		bUseNetworkLoopback: bool,
		pIdentity1: FFIPointer,
		pIdentity2: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_DestroyPollGroup: (self: FFIPointer, hPollGroup: int) -> bool,
	SteamAPI_ISteamNetworkingSockets_FlushMessagesOnConnection: (self: FFIPointer, hConn: int) -> int,
	SteamAPI_ISteamNetworkingSockets_GetAuthenticationStatus: (self: FFIPointer, pDetails: FFIPointer) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_GetCertificateRequest: (
		self: FFIPointer,
		pcbBlob: FFIPointer,
		pBlob: FFIPointer,
		errMsg: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_GetConnectionInfo: (
		self: FFIPointer,
		hConn: int,
		pInfo: FFIPointer
	) -> bool,
	SteamAPI_ISteamNetworkingSockets_GetConnectionName: (
		self: FFIPointer,
		hPeer: FFIPointer,
		pszName: cstring,
		nMaxLen: int
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_GetConnectionRealTimeStatus: (
		self: FFIPointer,
		hConn: int,
		pStats: FFIPointer,
		nLanes: int,
		pLanes: FFIPointer
	) -> int,
	SteamAPI_ISteamNetworkingSockets_GetConnectionUserData: (self: FFIPointer, hPeer: FFIPointer) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_GetDetailedConnectionStatus: (
		self: FFIPointer,
		hConn: FFIPointer,
		pszBuf: cstring,
		cbBuf: int
	) -> FFIPointer,

	SteamAPI_ISteamNetworkingSockets_GetIdentity: (self: FFIPointer, pIdentity: FFIPointer) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_GetListenSocketAddress: (
		self: FFIPointer,
		hSocket: FFIPointer,
		address: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_InitAuthentication: (self: FFIPointer) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection: (
		self: FFIPointer,
		hConn: int,
		ppOutMessages: FFIPointer,
		nMaxMessages: int
	) -> int,
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup: (
		self: FFIPointer,
		hPollGroup: int,
		ppOutMessages: FFIPointer,
		nMaxMessages: int
	) -> int,
	SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal: (
		self: FFIPointer,
		pMsg: FFIPointer,
		cbMsg: int,
		pContext: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal2: (
		self: FFIPointer,
		pMsg: FFIPointer,
		cbMsg: int,
		ctx: any,
		fnOnConnectRequest: FFIPointer,
		fnSendRejectionSignal: FFIPointer
	) -> FFIPointer,

	SteamAPI_ISteamNetworkingSockets_RunCallbacks: (self: FFIPointer) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_SendMessageToConnection: (
		self: FFIPointer,
		hConn: int,
		pData: FFIPointer,
		cbData: int,
		nSendFlags: int,
		pOutMessageNumber: FFIPointer
	) -> int,
	SteamAPI_ISteamNetworkingSockets_SendMessages: (
		self: FFIPointer,
		nMessages: int,
		pMessages: FFIPointer,
		pOutMessageNumberOrResult: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_SetCertificate: (
		self: FFIPointer,
		pCertificate: FFIPointer,
		cbCertificate: int,
		errMsg: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_SetConnectionName: (
		self: FFIPointer,
		hPeer: FFIPointer,
		pszName: cstring
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup: (
		self: FFIPointer,
		hConn: int,
		hPollGroup: int
	) -> bool,
	SteamAPI_ISteamNetworkingSockets_SetConnectionUserData: (
		self: FFIPointer,
		hPeer: FFIPointer,
		nUserData: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_AllocateMessage: (self: FFIPointer, cbAllocateBuffer: int) -> FFIPointer,

	SteamAPI_ISteamNetworkingUtils_GetConfigValue: (
		self: FFIPointer,
		eValue: FFIPointer,
		eScopeType: FFIPointer,
		scopeObj: FFIPointer,
		pOutDataType: FFIPointer,
		pResult: FFIPointer,
		cbResult: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_GetConfigValueInfo: (
		self: FFIPointer,
		eValue: FFIPointer,
		pOutDataType: FFIPointer,
		pOutScope: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_GetLocalTimestamp: (self: FFIPointer) -> FFIPointer,

	SteamAPI_ISteamNetworkingUtils_IterateGenericEditableConfigValues: (
		self: FFIPointer,
		eCurrent: FFIPointer,
		bEnumerateDevVars: bool
	) -> FFIPointer,

	SteamAPI_ISteamNetworkingUtils_SetConfigValue: (
		self: FFIPointer,
		eValue: FFIPointer,
		eScopeType: FFIPointer,
		scopeObj: FFIPointer,
		eDataType: FFIPointer,
		pArg: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetConfigValueStruct: (
		self: FFIPointer,
		opt: FFIPointer,
		eScopeType: FFIPointer,
		scopeObj: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueFloat: (
		self: FFIPointer,
		hConn: FFIPointer,
		eValue: FFIPointer,
		val: float
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueInt32: (
		self: FFIPointer,
		hConn: FFIPointer,
		eValue: FFIPointer,
		val: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueString: (
		self: FFIPointer,
		hConn: FFIPointer,
		eValue: FFIPointer,
		val: cstring
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetDebugOutputFunction: (
		self: FFIPointer,
		eDetailLevel: FFIPointer,
		pfnFunc: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetAuthenticationStatusChanged: (
		self: FFIPointer,
		fnCallback: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetConnectionStatusChanged: (
		self: FFIPointer,
		fnCallback: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamRelayNetworkStatusChanged: (
		self: FFIPointer,
		fnCallback: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueFloat: (
		self: FFIPointer,
		eValue: FFIPointer,
		val: float
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueInt32: (
		self: FFIPointer,
		eValue: FFIPointer,
		val: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValuePtr: (
		self: FFIPointer,
		eValue: FFIPointer,
		val: FFIPointer
	) -> FFIPointer,
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueString: (
		self: FFIPointer,
		eValue: FFIPointer,
		val: cstring
	) -> FFIPointer,
	SteamAPI_SteamDatagramHostedAddress_Clear: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamDatagramHostedAddress_SetDevAddress: (
		self: FFIPointer,
		nIP: FFIPointer,
		nPort: FFIPointer,
		popid: FFIPointer
	) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_Clear: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_GetIPv4: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_IsEqualTo: (self: FFIPointer, x: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_IsIPv4: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_IsIPv6AllZeros: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_IsLocalHost: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_ParseString: (self: FFIPointer, pszStr: int) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_SetIPv4: (self: FFIPointer, nIP: FFIPointer, nPort: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_SetIPv6: (self: FFIPointer, ipv6: FFIPointer, nPort: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_SetIPv6LocalHost: (self: FFIPointer, nPort: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIPAddr_ToString: (self: FFIPointer, buf: int, cbBuf: int, bWithPort: bool) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_Clear: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetGenericBytes: (self: FFIPointer, cbLen: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetGenericString: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetIPAddr: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetSteamID: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetSteamID64: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_GetXboxPairwiseID: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_IsEqualTo: (self: FFIPointer, x: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_IsInvalid: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_IsLocalHost: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_ParseString: (self: FFIPointer, sizeofIdentity: int, pszStr: int) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetGenericBytes: (
		self: FFIPointer,
		data: FFIPointer,
		cbLen: FFIPointer
	) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetGenericString: (self: FFIPointer, pszString: cstring) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetIPAddr: (self: FFIPointer, addr: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetLocalHost: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetSteamID: (self: FFIPointer, steamID: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetSteamID64: (self: FFIPointer, steamID: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_SetXboxPairwiseID: (self: FFIPointer, pszString: cstring) -> FFIPointer,
	SteamAPI_SteamNetworkingIdentity_ToString: (self: FFIPointer, buf: int, cbBuf: int) -> FFIPointer,
	SteamAPI_SteamNetworkingMessage_t_Release: (self: FFIPointer) -> FFIPointer,
	SteamAPI_SteamNetworkingSockets_v009: () -> FFIPointer,
	SteamAPI_SteamNetworkingUtils_v003: () -> FFIPointer,
	SteamNetworkingSockets_SetLockWaitWarningThreshold: (usecThreshold: FFIPointer) -> FFIPointer,
}

local funcs = {
	SteamAPI_SteamNetworkingSockets_v009 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress = {
		returns = ffi.types.u32,
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
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	SteamAPI_ISteamNetworkingSockets_CloseConnection = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.i32, ffi.types.pointer, ffi.types.u8 },
	},
	SteamAPI_ISteamNetworkingSockets_CloseListenSocket = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionUserData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionName = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_SendMessageToConnection = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},
	SteamAPI_ISteamNetworkingSockets_SendMessages = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_FlushMessagesOnConnection = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionInfo = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetConnectionRealTimeStatus = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetDetailedConnectionStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	SteamAPI_ISteamNetworkingSockets_GetListenSocketAddress = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreateSocketPair = {
		returns = ffi.types.pointer,
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
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetIdentity = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_InitAuthentication = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_GetAuthenticationStatus = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_CreatePollGroup = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_DestroyPollGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.i32 },
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
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_GetCertificateRequest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_SetCertificate = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_RunCallbacks = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingUtils_v003 = { returns = ffi.types.pointer, args = {} },
	SteamAPI_ISteamNetworkingUtils_AllocateMessage = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	SteamAPI_ISteamNetworkingUtils_GetLocalTimestamp = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingUtils_SetDebugOutputFunction = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueInt32 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueFloat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValuePtr = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueInt32 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueFloat = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetConnectionStatusChanged = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetAuthenticationStatusChanged = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamRelayNetworkStatusChanged = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingUtils_SetConfigValue = {
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
	SteamAPI_ISteamNetworkingUtils_SetConfigValueStruct = {
		returns = ffi.types.pointer,
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
	SteamAPI_SteamNetworkingIPAddr_Clear = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_IsIPv6AllZeros = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_SetIPv6 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_SetIPv4 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_IsIPv4 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_GetIPv4 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_SetIPv6LocalHost = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_IsLocalHost = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIPAddr_IsEqualTo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIPAddr_ToString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.u8 },
	},
	SteamAPI_SteamNetworkingIPAddr_ParseString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_Clear = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_IsInvalid = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetSteamID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetSteamID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetSteamID64 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetSteamID64 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetXboxPairwiseID = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetXboxPairwiseID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetIPAddr = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetIPAddr = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetLocalHost = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_IsLocalHost = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetGenericString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetGenericString = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_SteamNetworkingIdentity_SetGenericBytes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_GetGenericBytes = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_IsEqualTo = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingIdentity_ToString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	SteamAPI_SteamNetworkingIdentity_ParseString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer },
	},
	SteamAPI_SteamNetworkingMessage_t_Release = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	SteamAPI_ISteamNetworkingSockets_CreateCustomSignaling = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal2 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	GameNetworkingSockets_Init = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	GameNetworkingSockets_Kill = { returns = ffi.types.pointer, args = {} },
	SteamNetworkingSockets_SetLockWaitWarningThreshold = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
}

return funcs
