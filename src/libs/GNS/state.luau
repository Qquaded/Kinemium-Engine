local ffi = zune.ffi
local gns = require("@gns_ffi")
local task = zune.task

gns.lib.GameNetworkingSockets_Init(nil, nil)

local GNS_GlobalState = {
	sockets = gns.lib.SteamAPI_SteamNetworkingSockets_v009(),
	utils = gns.lib.SteamAPI_SteamNetworkingUtils_v003(),
	listenSockets = {},
	connections = {},
	activeClient = nil,
	activeClients = {},
	eventLoopStarted = false,
	connectionEvents = {},
}

local function log(...)
	print(...)
end

local function toPointer(addr: number)
	local buf = buffer.create(8)
	buffer.writeu32(buf, 0, addr % 4294967296)
	buffer.writeu32(buf, 4, math.floor(addr / 4294967296))
	return ffi.ptrFromAddress(buf)
end

local function getPtrAddress(ptr)
	return tonumber(tostring(ptr):match("0x[%da-fA-F]+") or "0", 16)
end

local function readCString(ptr)
	local bytes = {}
	local i = 0
	while true do
		local b = ptr:readu8(i)
		if b == 0 then
			break
		end
		table.insert(bytes, string.char(b))
		i = i + 1
	end
	return table.concat(bytes)
end

local statusCallbackClosure = ffi.closure({
	returns = ffi.types.void,
	args = { ffi.types.pointer },
}, function(pInfo)
	local hConn = pInfo:readu32(0)
	local eState = pInfo:readi32(184) -- m_eState is at 184
	local hListenSocket = pInfo:readu32(152) -- m_hListenSocket is at 152

	-- Safely read remote address on main thread context during callback
	local remoteAddress = ""
	if eState == 1 then -- Connecting
		local pAddrRemote = toPointer(getPtrAddress(pInfo) + 160)
		local buf = ffi.alloc(128)
		gns.lib.SteamAPI_SteamNetworkingIPAddr_ToString(pAddrRemote, buf, 128, true)
		remoteAddress = readCString(buf)
	end

	-- Queue event to prevent recursive reentrancy (C stack overflow)
	table.insert(GNS_GlobalState.connectionEvents, {
		hConn = hConn,
		eState = eState,
		hListenSocket = hListenSocket,
		remoteAddress = remoteAddress,
	})
end)

function GNS_GlobalState.InitEventLoop()
	if GNS_GlobalState.eventLoopStarted then
		return
	end
	GNS_GlobalState.eventLoopStarted = true

	-- Set outbound send buffer size to 15MB
	local sendBufSize = ffi.alloc(4)
	sendBufSize:writei32(0, 15 * 1024 * 1024)
	gns.lib.SteamAPI_ISteamNetworkingUtils_SetConfigValue(
		GNS_GlobalState.utils,
		toPointer(9), -- k_ESteamNetworkingConfig_SendBufferSize
		toPointer(1), -- k_ESteamNetworkingConfig_Global
		toPointer(0),
		toPointer(1), -- k_ESteamNetworkingConfig_Int32
		sendBufSize
	)

	-- Set receive buffer size to 20MB
	local recvBufSize = ffi.alloc(4)
	recvBufSize:writei32(0, 20 * 1024 * 1024)
	gns.lib.SteamAPI_ISteamNetworkingUtils_SetConfigValue(
		GNS_GlobalState.utils,
		toPointer(47), -- k_ESteamNetworkingConfig_RecvBufferSize
		toPointer(1), -- k_ESteamNetworkingConfig_Global
		toPointer(0),
		toPointer(1), -- k_ESteamNetworkingConfig_Int32
		recvBufSize
	)

	-- Set max incoming message size to 11MB
	local recvMaxMessage = ffi.alloc(4)
	recvMaxMessage:writei32(0, 11 * 1024 * 1024)
	gns.lib.SteamAPI_ISteamNetworkingUtils_SetConfigValue(
		GNS_GlobalState.utils,
		toPointer(49), -- k_ESteamNetworkingConfig_RecvMaxMessageSize
		toPointer(1), -- k_ESteamNetworkingConfig_Global
		toPointer(0),
		toPointer(1), -- k_ESteamNetworkingConfig_Int32
		recvMaxMessage
	)

	-- Register connection status callback (runs safely on main thread during RunCallbacks)
	gns.lib.SteamAPI_ISteamNetworkingUtils_SetGlobalCallback_SteamNetConnectionStatusChanged(
		GNS_GlobalState.utils,
		statusCallbackClosure
	)

	log("[GNS][State] Event loop successfully registered and native network parameters optimized globally.")

	task.spawn(function()
		while true do
			gns.lib.SteamAPI_ISteamNetworkingSockets_RunCallbacks(GNS_GlobalState.sockets)

			-- Process queued connection status events outside native callbacks
			local events = GNS_GlobalState.connectionEvents
			GNS_GlobalState.connectionEvents = {}

			for _, ev in ipairs(events) do
				log(
					`[GNS][Event] Connection status changed: hConn={ev.hConn}, eState={ev.eState}, hListenSocket={ev.hListenSocket}`
				)

				if ev.hListenSocket > 0 then
					local server = GNS_GlobalState.listenSockets[ev.hListenSocket]
					if server then
						server:HandleConnectionStatusChanged(ev.hConn, ev.eState, ev.remoteAddress)
					end
				else
					for _, client in pairs(GNS_GlobalState.activeClients) do
						if client and client.hConn == ev.hConn then
							client:HandleConnectionStatusChanged(ev.eState)
							break
						end
					end
				end
			end

			for _, server in pairs(GNS_GlobalState.listenSockets) do
				server:Poll()
			end

			for _, client in pairs(GNS_GlobalState.activeClients) do
				client:Poll()
			end

			task.wait(0.01)
		end
	end)
end

return GNS_GlobalState
