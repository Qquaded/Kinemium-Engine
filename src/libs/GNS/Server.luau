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

local function log(...)
	--print(...)
end

local function clientKey(client)
	if client and client.hConn ~= nil then
		return tostring(client.hConn)
	end
	return `{client.address}:{client.port}`
end

local function toPointer(addr: number)
	local buf = buffer.create(8)
	buffer.writeu32(buf, 0, addr % 4294967296)
	buffer.writeu32(buf, 4, math.floor(addr / 4294967296))
	return ffi.ptrFromAddress(buf)
end

local function pointerToBuffer(ptr, size)
	local buf = buffer.create(size)
	for i = 0, size - 1 do
		buffer.writeu8(buf, i, ptr:readu8(i))
	end
	return buf
end

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

	local ipAddr = ffi.alloc(18)
	gns.lib.SteamAPI_SteamNetworkingIPAddr_ParseString(
		ipAddr,
		BufferUtils.stringToPtr(self.Address .. ":" .. tostring(self.Port))
	)

	local hListenSocket = gns.lib.SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP(state.sockets, ipAddr, 0, nil)
	local hListenSocketNum = tonumber(tostring(hListenSocket):match("0x[%da-fA-F]+") or "0", 16)

	self.Socket = hListenSocketNum

	local hPollGroup = gns.lib.SteamAPI_ISteamNetworkingSockets_CreatePollGroup(state.sockets)
	local hPollGroupNum = tonumber(tostring(hPollGroup):match("0x[%da-fA-F]+") or "0", 16)
	self.PollGroup = hPollGroupNum

	state.listenSockets[hListenSocketNum] = self
	state.InitEventLoop()
end

function Server:Listen()
	-- GNS event loop handles everything, so this is just a compatibility stub
end

function Server:HandleConnectionStatusChanged(hConn, eState, remoteAddress)
	if eState == 1 then -- Connecting
		gns.lib.SteamAPI_ISteamNetworkingSockets_AcceptConnection(state.sockets, toPointer(hConn))
		gns.lib.SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup(
			state.sockets,
			toPointer(hConn),
			toPointer(self.PollGroup)
		)

		local address, portStr = string.match(remoteAddress or "", "([^:]+):(%d+)")
		local port = tonumber(portStr) or 1234

		local client = {
			address = address or "unknown",
			port = port,
			hConn = hConn,
			authenticated = false,
			sessionId = nil,
		}

		self.ConnectedClients[clientKey(client)] = client
		self.ConnectedClientsByConn[hConn] = client
	elseif eState == 4 or eState == 5 then -- ClosedByPeer / ProblemDetectedLocally
		self:RemoveClient(hConn, "connection closed by peer or local problem")
	end
end

function Server:RemoveClient(hConn, reason)
	local client = self.ConnectedClientsByConn[hConn]
	if not client then
		return
	end

	self.ConnectedClients[clientKey(client)] = nil
	self.ConnectedClientsByConn[hConn] = nil

	gns.lib.SteamAPI_ISteamNetworkingSockets_CloseConnection(
		state.sockets,
		toPointer(hConn),
		0,
		BufferUtils.stringToPtr(reason or "shutdown"),
		false
	)

	if self._onClientRemoved then
		task.spawn(self._onClientRemoved, client)
	end
end

function Server:Poll()
	if not self.PollGroup then
		return
	end

	local ppOutMessages = ffi.alloc(128 * 8)
	local numMsgs = gns.lib.SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup(
		state.sockets,
		toPointer(self.PollGroup),
		ppOutMessages,
		128
	)

	local numMsgsNum = tonumber(tostring(numMsgs):match("0x[%da-fA-F]+") or "0", 16)
	if numMsgsNum > 0 then
		for i = 1, numMsgsNum do
			local pMsg = ppOutMessages:readptr((i - 1) * 8)
			if pMsg and pMsg ~= ffi.null then
				local m_pData = pMsg:readptr(0)
				local m_cbSize = pMsg:readi32(8)
				local m_conn = pMsg:readu32(12)

				local rawPayload = pointerToBuffer(m_pData, m_cbSize)

				gns.lib.SteamAPI_SteamNetworkingMessage_t_Release(pMsg)

				local ok, decoded = pcall(Serializer.Deserialize, rawPayload)
				if ok and decoded then
					if not SILENT_PACKET_TYPES[decoded.type or decoded.kind] then
						log(
							`[GNS][Server] Received message: type={decoded.type or decoded.kind or "?"}, size={m_cbSize} bytes from conn {m_conn}`
						)
					end
					self:HandlePacket(m_conn, decoded)
				else
					warn("[GNS][Server] Failed to deserialize message from conn:", m_conn)
				end
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
		client.authenticated = true
		client.sessionId = "gns_session_" .. tostring(hConn)

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

	if client.authenticated then
		for _, cb in ipairs(self.OnRecieveCallbacks) do
			task.spawn(cb, client, msg)
		end
	end
end

function Server:Send(client, data, reliable)
	if not client or not client.hConn then
		return false
	end
	local flags = reliable and 8 or 1

	local ok, serialized = pcall(Serializer.Serialize, data)
	if not ok then
		warn("[GNS][Server] Failed to serialize message:", serialized)
		return false
	end

	if not SILENT_PACKET_TYPES[data.type or data.kind] then
		log(
			`[GNS][Server] Sending message: type={data.type or data.kind or "?"}, size={buffer.len(serialized)} bytes, reliable={reliable} to {client.address}:{client.port}`
		)
	end

	local pData = ffi.alloc(buffer.len(serialized))
	pData:write(0, serialized, 0, buffer.len(serialized))

	local res = gns.lib.SteamAPI_ISteamNetworkingSockets_SendMessageToConnection(
		state.sockets,
		toPointer(client.hConn),
		pData,
		toPointer(buffer.len(serialized)),
		flags,
		nil
	)
	return tonumber(tostring(res):match("0x[%da-fA-F]+") or "0", 16) == 1
end

function Server:SendAll(data, reliable)
	for _, client in pairs(self.ConnectedClients) do
		self:Send(client, data, reliable)
	end
	return true
end

function Server:SendFiltered(data, reliable, filterFn)
	for _, client in pairs(self.ConnectedClients) do
		if filterFn(client) then
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

function Server:Shutdown()
	for hConn, client in pairs(self.ConnectedClientsByConn) do
		self:RemoveClient(hConn, "server shutdown")
	end

	if self.Socket then
		gns.lib.SteamAPI_ISteamNetworkingSockets_CloseListenSocket(state.sockets, toPointer(self.Socket))
		state.listenSockets[self.Socket] = nil
		self.Socket = nil
	end
end

function Server:IsClientConnected(client)
	if not client or not client.hConn then
		return false
	end
	return self.ConnectedClientsByConn[client.hConn] ~= nil
end

function Server:GetClientStats(client)
	return {
		pendingReliable = 0,
		pendingReliableFragments = 0,
	}
end

return Server
