local ffi = zune.ffi
local gns = require("@gns_ffi")
local state = require("@GNS/state")
local Serializer = require("@GNS/Serializer")
local BufferUtils = require("@bufferutils")
local task = zune.task

local Client = {}
Client.__index = Client

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

local function handle_toPointer(handle: number)
	local buf = ffi.alloc(8)
	buf:writeu32(0, handle % 4294967296)
	buf:writeu32(4, math.floor(handle / 4294967296))
	return buf
end

local function size_toPointer(size: number)
	local buf = ffi.alloc(4)
	buf:writeu32(0, size)
	return buf
end

local function pointerToBuffer(ptr, size)
	local buf = buffer.create(size)
	for i = 0, size - 1 do
		buffer.writeu8(buf, i, ptr:readu8(i))
	end
	return buf
end

-- SteamNetworkingMessage_t layout (64-bit):
--   offset  0: m_pData  (pointer, 8 bytes)
--   offset  8: m_cbSize (i32,     4 bytes)
--   offset 12: m_nFlags (i32,     4 bytes)
--   offset 16: m_conn   (u32,     4 bytes)
local MSG_OFFSET_PDATA = 0
local MSG_OFFSET_CBSIZE = 8

function Client.new()
	local self = setmetatable({
		Socket = nil,
		hConn = nil,
		ServerAddress = nil,
		ServerPort = nil,
		AuthToken = nil,
		IsAuthenticated = false,
		SessionId = nil,
		OnRecieveCallbacks = {},
		_OnShutdown = nil,
		ConnectArguments = nil,
		_connectAttemptId = 0,
		GnsConnected = false,
	}, Client)
	return self
end

local function openConnection(self)
	local ipAddr = ffi.alloc(18)
	gns.lib.SteamAPI_SteamNetworkingIPAddr_ParseString(
		ipAddr,
		BufferUtils.stringToPtr(self.ServerAddress .. ":" .. tostring(self.ServerPort))
	)

	local hConn = gns.lib.SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress(state.sockets, ipAddr, 0, nil)
	local hConnNum = tonumber(tostring(hConn):match("0x[%da-fA-F]+") or "0", 16)

	self.hConn = hConnNum
	self.Socket = hConnNum

	if hConnNum ~= 0 then
		state.activeClient = self
		state.activeClients[hConnNum] = self
	else
		warn(`[GNS][Client] ConnectByIPAddress failed for {self.ServerAddress}:{self.ServerPort}`)
	end

	state.InitEventLoop()
	return hConnNum ~= 0
end

function Client:Init(serverAddress, serverPort, authToken)
	self.ServerAddress = serverAddress or "127.0.0.1"
	self.ServerPort = serverPort or 1234
	self.AuthToken = authToken or "default_gns_token"
	self.IsAuthenticated = false
	self.GnsConnected = false
	openConnection(self)
end

function Client:Listen()
	-- GNS event loop handles everything; stub for API compatibility
end

function Client:Connect(arguments)
	self.ConnectArguments = arguments
	if self.GnsConnected and self.hConn then
		self:Send({
			type = "CONNECT",
			authToken = self.AuthToken,
			arguments = arguments,
		}, true)
	end

	self._connectAttemptId += 1
	local attemptId = self._connectAttemptId
	task.spawn(function()
		for attempt = 1, 5 do
			task.wait(2)
			if attemptId ~= self._connectAttemptId or self.IsAuthenticated then
				return
			end

			if not self.GnsConnected then
				if self.hConn then
					self:_CloseConnection("connect retry", true)
				end
				warn(`[GNS][Client] Connect retry {attempt} for {self.ServerAddress}:{self.ServerPort}`)
				openConnection(self)
			elseif self.ConnectArguments then
				self:Send({
					type = "CONNECT",
					authToken = self.AuthToken,
					arguments = self.ConnectArguments,
				}, true)
			end
		end

		if attemptId == self._connectAttemptId and not self.IsAuthenticated then
			warn(`[GNS][Client] Failed to authenticate after repeated retries`)
		end
	end)
end

function Client:HandleConnectionStatusChanged(eState)
	if eState == 3 then -- Connected
		self.GnsConnected = true
		if self.ConnectArguments then
			self:Send({
				type = "CONNECT",
				authToken = self.AuthToken,
				arguments = self.ConnectArguments,
			}, true)
		end
	elseif eState == 4 or eState == 5 then -- ClosedByPeer / ProblemDetectedLocally
		self.GnsConnected = false
		self:Disconnect()
	end
end

function Client:Poll()
	if not self.hConn then
		return
	end

	local ppOutMessages = ffi.alloc(128 * 8)
	local numMsgs = gns.lib.SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection(
		state.sockets,
		handle_toPointer(self.hConn),
		ppOutMessages,
		128
	)

	local numMsgsNum = tonumber(tostring(numMsgs):match("0x[%da-fA-F]+") or "0", 16)
	if numMsgsNum <= 0 then
		return
	end

	for i = 1, numMsgsNum do
		local pMsg = ppOutMessages:readptr((i - 1) * 8)
		if pMsg and pMsg ~= ffi.null then
			local m_pData = pMsg:readptr(MSG_OFFSET_PDATA)
			local m_cbSize = pMsg:readi32(MSG_OFFSET_CBSIZE)

			local rawPayload = pointerToBuffer(m_pData, m_cbSize)
			gns.lib.SteamAPI_SteamNetworkingMessage_t_Release(pMsg)

			local ok, decoded = pcall(Serializer.Deserialize, rawPayload)
			if ok and decoded then
				if not SILENT_PACKET_TYPES[decoded.type or decoded.kind] then
					log(`[GNS][Client] Recv: type={decoded.type or decoded.kind or "?"} size={m_cbSize}`)
				end
				self:HandlePacket(decoded)
			else
				warn("[GNS][Client] Failed to deserialize message from server")
			end
		end
	end
end

function Client:HandlePacket(msg)
	if msg.type == "AUTH_SUCCESS" then
		self.IsAuthenticated = true
		self.SessionId = msg.sessionId
		self._connectAttemptId += 1
	end

	if msg.type == "AUTH_FAILED" or msg.type == "DISCONNECT" or msg.type == "SHUTDOWN" then
		self:Disconnect()
	end

	for _, cb in ipairs(self.OnRecieveCallbacks) do
		task.spawn(cb, { address = self.ServerAddress, port = self.ServerPort }, msg)
	end
end

function Client:Send(data, reliable)
	if not self.hConn then
		return false
	end

	-- k_nSteamNetworkingSend_Reliable = 8, Unreliable = 0
	local flags = reliable and 8 or 0

	local ok, serialized = pcall(Serializer.Serialize, data)
	if not ok then
		warn("[GNS][Client] Failed to serialize:", serialized)
		return false
	end

	if not SILENT_PACKET_TYPES[data.type or data.kind] then
		log(
			`[GNS][Client] Send: type={data.type or data.kind or "?"} size={buffer.len(serialized)} reliable={reliable}`
		)
	end

	local len = buffer.len(serialized)
	local pData = ffi.alloc(len)
	pData:write(0, serialized, 0, len)

	gns.lib.SteamAPI_ISteamNetworkingSockets_SendMessageToConnection(
		state.sockets,
		handle_toPointer(self.hConn),
		pData,
		size_toPointer(len), -- fixed: 4-byte buffer containing the size, not toPointer(len)
		flags,
		nil
	)
	return true
end

function Client:OnRecieve(callback)
	table.insert(self.OnRecieveCallbacks, callback)
end

function Client:OnShutdown(callback)
	self._OnShutdown = callback
end

function Client:StartHeartbeat()
	-- GNS handles keepalives natively; stub for API compatibility
end

function Client:_CloseConnection(reason, suppressShutdown)
	if not self.hConn then
		return
	end

	local hConn = self.hConn
	state.activeClients[hConn] = nil
	if state.activeClient == self then
		state.activeClient = nil
	end

	self.hConn = nil
	self.Socket = nil
	self.IsAuthenticated = false
	self.SessionId = nil
	self.GnsConnected = false

	gns.lib.SteamAPI_ISteamNetworkingSockets_CloseConnection(
		state.sockets,
		handle_toPointer(hConn),
		0,
		BufferUtils.stringToPtr(reason or "disconnect"),
		false
	)

	if not suppressShutdown and self._OnShutdown then
		task.spawn(self._OnShutdown)
	end
end

function Client:Disconnect()
	self._connectAttemptId += 1
	self:_CloseConnection("disconnect", false)
end

return Client
