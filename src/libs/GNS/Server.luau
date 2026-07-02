local ffi = zune.ffi
local gns = require("@gns_ffi")
local state = require("@GNS/state")
local Serializer = require("@GNS/Serializer")
local BufferUtils = require("@bufferutils")
local task = zune.task

local Server = {}
Server.__index = Server

local SILENT_PACKET_TYPES = {
	patch_batch = true,
	snapshot = true,
	snapshot_ack = true,
	terrain_snapshot = true,
	ping = true,
}

local MAX_RECV_MESSAGES = 128
local POINTER_SIZE = ffi.types.pointer:size()

local function log(...)
	--print(...)
end

local function receiveCountToNumber(value): number
	if type(value) == "number" then
		return value
	end

	local hex = tostring(value):match("0x[%da-fA-F]+")
	if not hex then
		return 0
	end

	local unsigned = tonumber(hex, 16) or 0
	local low32 = unsigned % 4294967296
	if low32 >= 2147483648 then
		return low32 - 4294967296
	end
	return low32
end

local function handleToNumber(value): number
	if type(value) == "number" then
		return value
	end

	return tonumber(tostring(value):match("0x[%da-fA-F]+") or "0", 16)
end

local function clientKey(client)
	if client and client.hConn ~= nil then
		return tostring(client.hConn)
	end
	return `{client.address}:{client.port}`
end

local function pointerToBuffer(ptr, size)
	local buf = buffer.create(size)
	for i = 0, size - 1 do
		buffer.writeu8(buf, i, ptr:readu8(i))
	end
	return buf
end

-- SteamNetworkingMessage_t layout (64-bit):
--   offset  0: m_pData       (pointer, 8 bytes)
--   offset  8: m_cbSize      (i32,     4 bytes)
--   offset 12: m_conn        (u32,     4 bytes)
local MSG_OFFSET_PDATA = 0
local MSG_OFFSET_CBSIZE = 8
local MSG_OFFSET_CONN = 12

function Server.new()
	local self = setmetatable({
		Socket = nil,
		Address = nil,
		Port = nil,
		PollGroup = nil,
		ConnectedClients = {},
		ConnectedClientsByConn = {},
		OnRecieveCallbacks = {},
		_onClientConnectionRequest = nil,
		_onClientRemoved = nil,
		_onPreAuthMessage = nil,
	}, Server)
	return self
end

function Server:Init(address, port, allowedTokens)
	self.Address = address or "0.0.0.0"
	self.Port = port or 1234
	state.InitEventLoop()

	local ipAddr = ffi.alloc(18)
	gns.lib.SteamAPI_SteamNetworkingIPAddr_ParseString(
		ipAddr,
		BufferUtils.stringToPtr(self.Address .. ":" .. tostring(self.Port))
	)

	local hListenSocket = gns.lib.SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP(state.sockets, ipAddr, 0, nil)
	local hListenSocketNum = handleToNumber(hListenSocket)

	self.Socket = hListenSocketNum

	local hPollGroup = gns.lib.SteamAPI_ISteamNetworkingSockets_CreatePollGroup(state.sockets)
	local hPollGroupNum = handleToNumber(hPollGroup)
	self.PollGroup = hPollGroupNum

	state.listenSockets[hListenSocketNum] = self
end

function Server:Listen()
	-- GNS event loop handles everything; stub for API compatibility
end

function Server:HandleConnectionStatusChanged(hConn, eState, remoteAddress)
	if eState == 1 then -- Connecting: accept and add to pending (not yet authenticated)
		gns.lib.SteamAPI_ISteamNetworkingSockets_AcceptConnection(state.sockets, hConn)
		gns.lib.SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup(state.sockets, hConn, self.PollGroup)

		local address, portStr = string.match(remoteAddress or "", "([^:]+):(%d+)")
		local port = tonumber(portStr) or 0

		-- Store as pending only; not yet in ConnectedClients
		-- ConnectedClients is populated after AUTH (CONNECT message received)
		local client = {
			address = address or "unknown",
			port = port,
			hConn = hConn,
			authenticated = false,
			sessionId = nil,
		}

		self.ConnectedClientsByConn[hConn] = client
	elseif eState == 4 or eState == 5 then -- ClosedByPeer / ProblemDetectedLocally
		self:RemoveClient(hConn, "connection closed")
	end
end

function Server:RemoveClient(hConn, reason)
	local client = self.ConnectedClientsByConn[hConn]
	if not client then
		return
	end

	-- Only fire onClientRemoved if they were fully authenticated
	local wasAuthenticated = client.authenticated

	self.ConnectedClientsByConn[hConn] = nil
	if client.authenticated then
		self.ConnectedClients[clientKey(client)] = nil
	end

	gns.lib.SteamAPI_ISteamNetworkingSockets_CloseConnection(
		state.sockets,
		hConn,
		0,
		BufferUtils.stringToPtr(reason or "shutdown"),
		false
	)

	if wasAuthenticated and self._onClientRemoved then
		task.spawn(self._onClientRemoved, client)
	end
end

function Server:Poll()
	if not self.PollGroup then
		return
	end

	local ppOutMessages = ffi.alloc(MAX_RECV_MESSAGES * POINTER_SIZE)
	local numMsgs = gns.lib.SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup(
		state.sockets,
		self.PollGroup,
		ppOutMessages,
		MAX_RECV_MESSAGES
	)

	local numMsgsNum = receiveCountToNumber(numMsgs)
	if numMsgsNum <= 0 then
		return
	end

	numMsgsNum = math.min(numMsgsNum, MAX_RECV_MESSAGES)
	for i = 1, numMsgsNum do
		local pMsg = ppOutMessages:readptr((i - 1) * POINTER_SIZE)
		if pMsg and pMsg ~= ffi.null then
			local m_pData = pMsg:readptr(MSG_OFFSET_PDATA)
			local m_cbSize = pMsg:readi32(MSG_OFFSET_CBSIZE)
			local m_conn = pMsg:readu32(MSG_OFFSET_CONN)

			local rawPayload = pointerToBuffer(m_pData, m_cbSize)
			gns.lib.SteamAPI_SteamNetworkingMessage_t_Release(pMsg)

			local ok, decoded = pcall(Serializer.Deserialize, rawPayload)
			if ok and decoded then
				if not SILENT_PACKET_TYPES[decoded.type or decoded.kind] then
					log(`[GNS][Server] Recv: type={decoded.type or decoded.kind or "?"} size={m_cbSize} conn={m_conn}`)
				end
				self:HandlePacket(m_conn, decoded)
			else
				warn(`[GNS][Server] Failed to deserialize message from conn {m_conn}`)
			end
		end
	end
end

function Server:HandlePacket(hConn, msg)
	local client = self.ConnectedClientsByConn[hConn]
	if not client then
		return
	end

	if msg.type == "CONNECT" then
		-- Authenticate: move from pending into ConnectedClients
		client.authenticated = true
		client.sessionId = "gns_session_" .. tostring(hConn)
		self.ConnectedClients[clientKey(client)] = client

		self:Send(client, {
			type = "AUTH_SUCCESS",
			sessionId = client.sessionId,
		}, true)

		if self._onClientConnectionRequest then
			task.spawn(self._onClientConnectionRequest, client, msg.arguments)
		end
		return
	end

	if msg.type == "DISCONNECT" then
		self:RemoveClient(hConn, "client requested disconnect")
		return
	end

	if not client.authenticated then
		return
	end

	for _, cb in ipairs(self.OnRecieveCallbacks) do
		task.spawn(cb, client, msg)
	end
end

function Server:Send(client, data, reliable)
	if not client or not client.hConn then
		return false
	end

	-- k_nSteamNetworkingSend_Reliable = 8, Unreliable = 0
	local flags = reliable and 8 or 0

	local ok, serialized = pcall(Serializer.Serialize, data)
	if not ok then
		warn("[GNS][Server] Failed to serialize:", serialized)
		return false
	end

	if not SILENT_PACKET_TYPES[data.type or data.kind] then
		log(
			`[GNS][Server] Send: type={data.type or data.kind or "?"} size={buffer.len(serialized)} reliable={reliable}`
		)
	end

	local len = buffer.len(serialized)
	local pData = ffi.alloc(len)
	pData:write(0, serialized, 0, len)

	gns.lib.SteamAPI_ISteamNetworkingSockets_SendMessageToConnection(
		state.sockets,
		client.hConn,
		pData,
		len,
		flags,
		nil
	)
	return true
end

function Server:SendAll(data, reliable)
	for _, client in pairs(self.ConnectedClients) do
		if client.authenticated then
			self:Send(client, data, reliable)
		end
	end
	return true
end

function Server:SendFiltered(data, reliable, filterFn)
	for _, client in pairs(self.ConnectedClients) do
		if client.authenticated and (filterFn == nil or filterFn(client)) then
			self:Send(client, data, reliable)
		end
	end
	return true
end

function Server:OnClientConnectionRequest(callback)
	self._onClientConnectionRequest = callback
end

function Server:OnClientRemoved(callback)
	self._onClientRemoved = callback
end

function Server:OnRecieve(callback)
	table.insert(self.OnRecieveCallbacks, callback)
end

function Server:OnPreAuthMessage(callback)
	self._onPreAuthMessage = callback
end

function Server:IsClientConnected(client)
	if not client or not client.hConn then
		return false
	end
	local c = self.ConnectedClientsByConn[client.hConn]
	return c ~= nil and c.authenticated == true
end

function Server:GetClientStats(client)
	if not client or not client.hConn then
		return { pendingReliable = 0, pendingReliableFragments = 0 }
	end

	-- SteamNetConnectionRealTimeStatus_t: cbPendingReliable at offset 20 (i32)
	-- Layout: m_eState(4) m_nPing(4) m_flConnectionQualityLocal(4) m_flConnectionQualityRemote(4)
	--         m_flOutPacketsPerSec(4) m_flOutBytesPerSec(4) m_flInPacketsPerSec(4) m_flInBytesPerSec(4) -- 32
	--         wait no: use the documented offsets from isteamnetworkingsockets.h
	-- Simpler: allocate a zeroed struct and call GetConnectionRealTimeStatus with 0 lanes
	local statsSize = 128 -- safe overallocation for SteamNetConnectionRealTimeStatus_t
	local pStats = ffi.alloc(statsSize)
	for i = 0, statsSize - 1 do
		pStats:writeu8(i, 0)
	end

	local result = gns.lib.SteamAPI_ISteamNetworkingSockets_GetConnectionRealTimeStatus(
		state.sockets,
		client.hConn,
		pStats,
		0, -- nLanes = 0, no per-lane stats needed
		nil
	)

	local resultNum = handleToNumber(result)
	if resultNum ~= 1 then -- k_EResultOK = 1
		return { pendingReliable = 0, pendingReliableFragments = 0 }
	end

	-- SteamNetConnectionRealTimeStatus_t offsets (from steamnetworkingtypes.h):
	--   0:  m_eState                    (i32)
	--   4:  m_nPing                     (i32)
	--   8:  m_flConnectionQualityLocal  (f32)
	--  12:  m_flConnectionQualityRemote (f32)
	--  16:  m_flOutPacketsPerSec        (f32)
	--  20:  m_flOutBytesPerSec          (f32)
	--  24:  m_flInPacketsPerSec         (f32)
	--  28:  m_flInBytesPerSec           (f32)
	--  32:  m_nSendRateBytesPerSecond   (i32)
	--  36:  m_cbPendingUnreliable       (i32)
	--  40:  m_cbPendingReliable         (i32)
	--  44:  m_cbSentUnackedReliable     (i32)
	local cbPendingReliable = pStats:readi32(40)
	local cbSentUnackedReliable = pStats:readi32(44)

	return {
		pendingReliable = cbPendingReliable + cbSentUnackedReliable,
		pendingReliableFragments = 0, -- GNS handles fragmentation internally
	}
end

function Server:Shutdown()
	for hConn in pairs(self.ConnectedClientsByConn) do
		self:RemoveClient(hConn, "server shutdown")
	end

	if self.Socket then
		gns.lib.SteamAPI_ISteamNetworkingSockets_CloseListenSocket(state.sockets, self.Socket)
		state.listenSockets[self.Socket] = nil
		self.Socket = nil
	end

	if self.PollGroup then
		gns.lib.SteamAPI_ISteamNetworkingSockets_DestroyPollGroup(state.sockets, self.PollGroup)
		self.PollGroup = nil
	end
end

function Server:DisconnectClient(client, reason)
	if not client or not client.hConn then
		return false
	end
	self:RemoveClient(client.hConn, reason)
	return true
end

return Server
