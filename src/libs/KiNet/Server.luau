local net = zune.net
local Server = {}

local Serializer = require("./Serializer")

Server.ConnectedClients = {}
local onRecieveCallbacks = {}

local HEARTBEAT_TIMEOUT = 25
local MAX_WIRE_MESSAGE_SIZE = 256 * 1024
local MAX_LOGICAL_MESSAGE_SIZE = 256 * 1024 * 1024
-- Replay / clock-skew window for inbound messages (seconds). The previous
-- value of 300s allowed a 5-minute replay; this is tightened to a window
-- that still tolerates reasonable NTP drift.
local MESSAGE_TIMEOUT = 30
local MAX_CLIENTS = 1000
local MAX_MESSAGES_PER_CLIENT = 1000
local RATE_LIMIT_WINDOW_SECONDS = 1
local MTU_SIZE = 1200
local ACK_TIMEOUT = 3
local MAX_RETRIES = 5
local FRAGMENT_TIMEOUT = 30
local MAX_FRAGMENT_COUNT = 262144
local MAX_SEQUENCE_WINDOW = 2048
local MAX_PROCESSED_RELIABLE_MESSAGES = 2048
local RELIABLE_BACKLOG_LIMIT = 256
local RELIABLE_IDLE_DISCONNECT_TIMEOUT = 18

local CONTROL_PACKET_TYPES = {
	ACK = true,
	AUTH_SUCCESS = true,
	AUTH_FAILED = true,
	DISCONNECT = true,
	SHUTDOWN = true,
}

local function clientKey(addr)
	return addr.address .. ":" .. addr.port
end

local function isControlPacket(data)
	return type(data) == "table" and data.type ~= nil and CONTROL_PACKET_TYPES[data.type] == true
end

local function countConnectedClients()
	local count = 0
	for _ in pairs(Server.ConnectedClients) do
		count += 1
	end
	return count
end

local function countPendingReliable(client, now)
	local count = 0
	local oldestAge = 0
	local highestAttempts = 0
	now = now or os.clock()

	for _, ackData in pairs(client and client.pendingAcks or {}) do
		count += 1
		oldestAge = math.max(oldestAge, now - (ackData.createdAt or ackData.lastSent or now))
		highestAttempts = math.max(highestAttempts, ackData.attempts or 0)
	end

	return count, oldestAge, highestAttempts
end

local function isTransientRecvError(err)
	err = tostring(err or "")
	return string.find(err, "ConnectionResetByPeer", 1, true) ~= nil
		or string.find(err, "ECONNRESET", 1, true) ~= nil
end

local function createMessageId(prefix, sequence, client)
	local suffix = client and clientKey(client) or "server"
	return `{prefix}_{sequence}_{suffix}_{math.floor(os.clock() * 1000)}`
end

-- Ring-buffered dedup for inbound sequences. Previously this used
-- `table.insert` / `table.remove(tbl, 1)` which is O(n) per packet.
local function trackClientSequence(client, sequence)
	if type(sequence) ~= "number" then
		return true
	end

	local seen = client.recentSequences
	if not seen then
		seen = {}
		client.recentSequences = seen
	end

	local ring = client.recentSequenceRing
	if not ring then
		-- Initialize ring buffer atomically
		ring = table.create(MAX_SEQUENCE_WINDOW, 0)
		client.recentSequenceRing = ring
		client.recentSequenceIndex = 0
		client.recentSequenceCount = 0
	end

	if client.highestSequence == nil then
		client.highestSequence = -math.huge
	end

	if seen[sequence] then
		return false, "Duplicate message"
	end

	if client.highestSequence ~= -math.huge and sequence <= client.highestSequence - MAX_SEQUENCE_WINDOW then
		return false, "Sequence too old"
	end

	local idx = client.recentSequenceIndex
	local evicted = ring[idx + 1]
	if evicted ~= nil and client.recentSequenceCount >= MAX_SEQUENCE_WINDOW then
		seen[evicted] = nil
	end

	ring[idx + 1] = sequence
	seen[sequence] = true
	client.recentSequenceIndex = (idx + 1) % MAX_SEQUENCE_WINDOW
	if client.recentSequenceCount < MAX_SEQUENCE_WINDOW then
		client.recentSequenceCount += 1
	end

	if sequence > client.highestSequence then
		client.highestSequence = sequence
	end

	return true
end

local function cleanupFragmentBuffer(fragmentBuffer, now)
	now = now or os.clock()
	for messageId, state in pairs(fragmentBuffer or {}) do
		if now - (state.lastUpdated or state.createdAt or now) > FRAGMENT_TIMEOUT then
			fragmentBuffer[messageId] = nil
		end
	end
end

-- Ring-buffered dedup for processed reliable message IDs.
local function rememberReliableMessage(client, messageId)
	if type(messageId) ~= "string" then
		return true
	end

	local seen = client.processedReliableMessages
	if not seen then
		seen = {}
		client.processedReliableMessages = seen
	end

	local ring = client.processedReliableRing
	if not ring then
		-- Initialize ring buffer atomically
		ring = table.create(MAX_PROCESSED_RELIABLE_MESSAGES)
		client.processedReliableRing = ring
		client.processedReliableIndex = 0
		client.processedReliableCount = 0
	end

	if seen[messageId] then
		return false
	end

	local idx = client.processedReliableIndex
	local evicted = ring[idx + 1]
	if evicted ~= nil and client.processedReliableCount >= MAX_PROCESSED_RELIABLE_MESSAGES then
		seen[evicted] = nil
	end

	ring[idx + 1] = messageId
	seen[messageId] = true
	client.processedReliableIndex = (idx + 1) % MAX_PROCESSED_RELIABLE_MESSAGES
	if client.processedReliableCount < MAX_PROCESSED_RELIABLE_MESSAGES then
		client.processedReliableCount += 1
	end

	return true
end

function Server:Init(address, port, allowedTokens)
	local socket = net.createSocket(
		net.ADDRF.INET,
		bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC),
		net.IPPROTO.UDP
	)

	address = address or "0.0.0.0"
	port = port or 1234

	socket:bindIp(address, port)
	Server.Socket = socket
	Server.Address = address
	Server.Port = port
	Server.AllowedTokens = allowedTokens or {}
	Server.SessionCounter = 0
	Server.BannedAddresses = {}
	Server.MessageSequence = 0

	log(`Created server socket at {address}:{port}`)

	return socket
end

function Server:GenerateSessionId()
	Server.SessionCounter = Server.SessionCounter + 1
	return `session_{Server.SessionCounter}_{os.time()}`
end

function Server:ValidateAuthToken(token)
	if #Server.AllowedTokens == 0 then
		return true
	end

	for _, allowedToken in ipairs(Server.AllowedTokens) do
		if token == allowedToken then
			return true
		end
	end

	return false
end

function Server:OnClientConnectionRequest(callback)
	Server._onClientConnectionRequest = callback
end

function Server:ValidateMessage(data, client)
	if type(data) ~= "table" then
		return false, "Invalid message format"
	end

	if not data.timestamp then
		return false, "Missing timestamp"
	end

	local currentTime = os.time()
	if math.abs(currentTime - data.timestamp) > MESSAGE_TIMEOUT then
		return false, "Message expired"
	end

	if data.sequence then
		local accepted, err = trackClientSequence(client, data.sequence)
		if not accepted then
			return false, err
		end
	end

	if data.sessionId and data.sessionId ~= client.sessionId then
		return false, "Invalid session"
	end

	return true
end

-- Ring-buffered rate limiter. Previously allocated a new array and copied
-- every live timestamp on each packet (O(n) per packet); this uses a fixed
-- ring of the last MAX_MESSAGES_PER_CLIENT timestamps and only looks at the
-- oldest slot.
function Server:CheckRateLimit(client)
	local currentTime = os.clock()

	local ring = client.rateLimitRing
	if not ring then
		-- Initialize ring buffer atomically
		ring = table.create(MAX_MESSAGES_PER_CLIENT, 0)
		client.rateLimitRing = ring
		client.rateLimitIndex = 0
		client.rateLimitCount = 0
	end

	local idx = client.rateLimitIndex

	if client.rateLimitCount >= MAX_MESSAGES_PER_CLIENT then
		-- Slot at idx is the oldest recorded timestamp. If it is still
		-- inside the rate-limit window, the client has exceeded the cap.
		local oldest = ring[idx + 1]
		if oldest and currentTime - oldest < RATE_LIMIT_WINDOW_SECONDS then
			return false
		end
	end

	ring[idx + 1] = currentTime
	client.rateLimitIndex = (idx + 1) % MAX_MESSAGES_PER_CLIENT
	if client.rateLimitCount < MAX_MESSAGES_PER_CLIENT then
		client.rateLimitCount += 1
	end

	return true
end

function Server:FragmentMessage(data, messageId, serializedBuffer, reliable)
	local buf = serializedBuffer or Serializer.Serialize(data)

	if buffer.len(buf) <= MTU_SIZE then
		return { data }
	end

	local totalFragments = math.ceil(buffer.len(buf) / MTU_SIZE)
	if totalFragments > MAX_FRAGMENT_COUNT then
		error(`Message {messageId} requires {totalFragments} fragments which exceeds the limit of {MAX_FRAGMENT_COUNT}`)
	end

	if data.kind then
		print(
			`[KiNet][Server] Fragmenting {data.channel}:{data.kind} for {messageId} into {totalFragments} fragments ({buffer.len(
				buf
			)} bytes)`
		)
	end

	local fragments = {}

	for i = 0, totalFragments - 1 do
		local startOffset = i * MTU_SIZE
		local chunkLength = math.min(MTU_SIZE, buffer.len(buf) - startOffset)
		local chunk = buffer.create(chunkLength)
		buffer.copy(chunk, 0, buf, startOffset, chunkLength)

		table.insert(fragments, {
			fragment = true,
			reliable = reliable == true,
			messageId = messageId,
			fragmentIndex = i,
			totalFragments = totalFragments,
			data = chunk,
		})
	end

	return fragments
end

function Server:ReassembleFragments(fragmentData, client)
	local msgId = fragmentData.messageId
	if type(msgId) ~= "string" then
		return nil
	end

	if
		type(fragmentData.totalFragments) ~= "number"
		or fragmentData.totalFragments < 1
		or fragmentData.totalFragments > MAX_FRAGMENT_COUNT
	then
		return nil
	end

	if
		type(fragmentData.fragmentIndex) ~= "number"
		or fragmentData.fragmentIndex < 0
		or fragmentData.fragmentIndex >= fragmentData.totalFragments
	then
		return nil
	end

	local chunkLengthOk, chunkLength = pcall(buffer.len, fragmentData.data)
	if not chunkLengthOk then
		return nil
	end

	cleanupFragmentBuffer(client.fragmentBuffer)

	if not client.fragmentBuffer then
		client.fragmentBuffer = {}
	end

	if not client.fragmentBuffer[msgId] then
		-- Check for potential memory exhaustion attack
		if fragmentData.totalFragments > 10000 then
			warn(`[KiNet][Server] Rejecting suspicious fragment request for {msgId}: {fragmentData.totalFragments} fragments`)
			return nil
		end
		
		client.fragmentBuffer[msgId] = {
			fragments = {},
			totalFragments = fragmentData.totalFragments,
			received = 0,
			totalBytes = 0,
			createdAt = os.clock(),
			lastUpdated = os.clock(),
		}
	end

	local fragmentState = client.fragmentBuffer[msgId]
	if fragmentState.totalFragments ~= fragmentData.totalFragments then
		client.fragmentBuffer[msgId] = nil
		return nil
	end

	fragmentState.lastUpdated = os.clock()

	if not fragmentState.fragments[fragmentData.fragmentIndex] then
		fragmentState.fragments[fragmentData.fragmentIndex] = fragmentData.data
		fragmentState.received = fragmentState.received + 1
		fragmentState.totalBytes += chunkLength
		if fragmentState.totalBytes > MAX_LOGICAL_MESSAGE_SIZE then
			client.fragmentBuffer[msgId] = nil
			warn(
				`[KiNet][Server] Dropping fragmented message {msgId} from {clientKey(client)} because it exceeds {MAX_LOGICAL_MESSAGE_SIZE} bytes`
			)
			return nil
		end
	else
		-- Duplicate fragment detected - potential replay attack
		warn(`[KiNet][Server] Duplicate fragment {fragmentData.fragmentIndex} for message {msgId} from {clientKey(client)}`)
		return nil
	end

	if fragmentState.received == fragmentState.totalFragments then
		local totalLength = 0
		for i = 0, fragmentState.totalFragments - 1 do
			if not fragmentState.fragments[i] then
				client.fragmentBuffer[msgId] = nil
				return nil
			end
			totalLength += buffer.len(fragmentState.fragments[i])
		end

		local completeData = buffer.create(totalLength)
		local writeOffset = 0
		for i = 0, fragmentState.totalFragments - 1 do
			local chunk = fragmentState.fragments[i]
			local chunkLength = buffer.len(chunk)
			buffer.copy(completeData, writeOffset, chunk, 0, chunkLength)
			writeOffset += chunkLength
		end

		client.fragmentBuffer[msgId] = nil

		print(
			`[KiNet][Server] Reassembled fragmented message {msgId} from {clientKey(client)} ({fragmentState.totalFragments} fragments)`
		)

		local ok, decoded = pcall(Serializer.Deserialize, completeData)
		if not ok then
			warn(`[KiNet][Server] Failed to deserialize reassembled message {msgId}: {decoded}`)
			return nil
		end

		-- Large logical messages can spend meaningful time in fragmentation
		-- and reassembly. Refresh the timestamp so validation measures the
		-- timeout window from successful reassembly instead of initial encode.
		decoded.timestamp = os.time()

		return decoded
	end

	return nil
end

function Server:IsBanned(address)
	return Server.BannedAddresses[address] ~= nil
end

function Server:BanClient(address, reason)
	Server.BannedAddresses[address] = {
		reason = reason or "Violation",
		timestamp = os.time(),
	}
	log(`Banned client {address}: {reason}`)
end

function Server:OnRecieve(callback)
	table.insert(onRecieveCallbacks, callback)
end

function Server:OnNewClient(callback)
	self._onNewClient = callback
end

function Server:OnClientRemoved(callback)
	self._onClientRemoved = callback
end

function Server:OnPreAuthMessage(callback)
	self._onPreAuthMessage = callback
end

function Server:RemoveClient(key, reason, quiet)
	local client = Server.ConnectedClients[key]
	if not client then
		return false
	end

	Server.ConnectedClients[key] = nil
	client.authenticated = false
	client.pendingAcks = {}
	client.fragmentBuffer = {}

	local message = `[KiNet][Server] Removing client {key}: {reason or "Disconnected"}`
	if quiet then
		log(message)
	else
		warn(message)
	end

	if Server._onClientRemoved then
		Server._onClientRemoved({
			address = client.address,
			port = client.port,
		})
	end

	return true
end

function Server:IsClientConnected(client)
	if not client then
		return false
	end

	local key = clientKey(client)
	return Server.ConnectedClients[key] == client and client.authenticated == true
end

function Server:GetClientStats(client)
	local now = os.clock()
	local pendingReliable, oldestReliableAge, highestReliableAttempts = countPendingReliable(client, now)

	return {
		connected = self:IsClientConnected(client),
		pendingReliable = pendingReliable,
		oldestReliableAge = oldestReliableAge,
		highestReliableAttempts = highestReliableAttempts,
	}
end

function Server:SendAll(data, reliable)
	local success, err = pcall(function()
		for key, client in pairs(Server.ConnectedClients) do
			if client.authenticated then
				local sendSuccess, sendErr = pcall(function()
					self:Send(client, data, reliable)
				end)
				if not sendSuccess then
					warn(`Failed to send to {key}: {sendErr}`)
				end
			end
		end
	end)

	if not success then
		warn(`SendAll error: {err}`)
		return false
	end

	return true
end

-- Send data to a subset of authenticated clients that pass a filter function.
-- filterFn receives the client key and the client table; return true to send.
function Server:SendFiltered(data, reliable, filterFn)
	local success, err = pcall(function()
		for key, client in pairs(Server.ConnectedClients) do
			if client.authenticated then
				if filterFn == nil or filterFn(key, client) then
					local sendSuccess, sendErr = pcall(function()
						self:Send(client, data, reliable)
					end)
					if not sendSuccess then
						warn(`Failed to send to {key}: {sendErr}`)
					end
				end
			end
		end
	end)

	if not success then
		warn(`SendFiltered error: {err}`)
		return false
	end

	return true
end

function Server:Shutdown()
	log(`Shutting down server at {self.Address}:{self.Port}`)
	if not self.Socket then
		return
	end
	Server:SendAll({ type = "SHUTDOWN" })
	self.Socket:close()
	self.Socket = nil
	Server.Socket = nil
end

function Server:SendReliable(client, data)
	if not self:IsClientConnected(client) then
		return false
	end

	local messageId = data.messageId or createMessageId("reliable", Server.MessageSequence, client)
	Server.MessageSequence = Server.MessageSequence + 1

	data.messageId = messageId
	data.reliable = true
	data.timestamp = os.time()

	local ok, serialized = pcall(Serializer.Serialize, data)
	if not ok then
		warn(`[KiNet][Server] Failed to serialize reliable message {messageId}: {serialized}`)
		return false
	end

	if buffer.len(serialized) > MAX_LOGICAL_MESSAGE_SIZE then
		warn(
			`[KiNet][Server] Reliable message {messageId} is {buffer.len(serialized)} bytes which exceeds the logical limit of {MAX_LOGICAL_MESSAGE_SIZE}`
		)
		return false
	end

	local fragments = self:FragmentMessage(data, messageId, serialized, true)

	if not client.pendingAcks then
		client.pendingAcks = {}
	end

	local now = os.clock()
	client.pendingAcks[messageId] = {
		fragments = fragments,
		attempts = 0,
		createdAt = now,
		lastSent = now,
		channel = data.channel,
		kind = data.kind or data.type,
		fragmentCount = #fragments,
	}

	task.spawn(function()
		for i, fragment in ipairs(fragments) do
			if not self:SendRaw(client, fragment) then
				break
			end
			if i % 200 == 0 then
				task.wait()
			end
		end
	end)

	return true
end

function Server:SendRaw(client, data)
	if not self.Socket or not client or not data then
		return false
	end

	if not isControlPacket(data) and not self:IsClientConnected(client) then
		return false
	end

	-- Always refresh timestamp at send time so retries cannot become stale.
	data.timestamp = os.time()
	data.sessionId = client.sessionId

	local ok, buf = pcall(Serializer.Serialize, data)
	if not ok then
		warn(`[KiNet][Server] Failed to serialize raw packet {data.kind or data.type or "packet"}: {buf}`)
		return false
	end

	if buffer.len(buf) > MAX_WIRE_MESSAGE_SIZE then
		warn(
			`[KiNet][Server] Datagram too large: {buffer.len(buf)} bytes (max: {MAX_WIRE_MESSAGE_SIZE}) for {data.kind or data.type or "packet"}`
		)
		return false
	end

	local sent, sendErr = pcall(function()
		self.Socket:sendMsg(tonumber(client.port), client.address, buf)
	end)
	if not sent then
		warn(`[KiNet][Server] sendMsg failed for {clientKey(client)}: {sendErr}`)
		return false
	end

	return true
end

function Server:Send(client, data, reliable)
	if reliable then
		return self:SendReliable(client, data)
	else
		if not self:IsClientConnected(client) then
			return false
		end

		data.reliable = false

		local ok, serialized = pcall(Serializer.Serialize, data)
		if not ok then
			warn(`[KiNet][Server] Failed to serialize message: {serialized}`)
			return false
		end

		if buffer.len(serialized) > MAX_LOGICAL_MESSAGE_SIZE then
			warn(
				`[KiNet][Server] Message is {buffer.len(serialized)} bytes which exceeds the logical limit of {MAX_LOGICAL_MESSAGE_SIZE}`
			)
			return false
		end

		if buffer.len(serialized) > MTU_SIZE then
			local messageId = data.messageId or createMessageId("fragmented", Server.MessageSequence, client)
			data.messageId = messageId
			data.timestamp = data.timestamp or os.time()
			local largeOk, largeSerialized = pcall(Serializer.Serialize, data)
			if not largeOk then
				warn(`[KiNet][Server] Failed to serialize large fragmented message {messageId}: {largeSerialized}`)
				return false
			end

			task.spawn(function()
				for i, fragment in ipairs(self:FragmentMessage(data, messageId, largeSerialized, false)) do
					if not self:SendRaw(client, fragment) then
						break
					end
					if i % 200 == 0 then
						task.wait()
					end
				end
			end)
			return true
		end

		return self:SendRaw(client, data)
	end
end

function Server:ProcessReliableQueue()
	task.spawn(function()
		while true do
			task.wait(0.1)
			if not self.Socket then
				break
			end

			local currentTime = os.clock()

			for key, client in pairs(Server.ConnectedClients) do
				if client.authenticated and client.pendingAcks then
					cleanupFragmentBuffer(client.fragmentBuffer, currentTime)
					local pendingCount, oldestPendingAge = countPendingReliable(client, currentTime)
					if pendingCount > RELIABLE_BACKLOG_LIMIT then
						self:RemoveClient(key, `reliable backlog exceeded ({pendingCount} pending messages)`)
						continue
					end
					if
						oldestPendingAge > RELIABLE_IDLE_DISCONNECT_TIMEOUT
						and currentTime - (client.lastPacketAt or client.connectedAtClock or currentTime)
							> RELIABLE_IDLE_DISCONNECT_TIMEOUT
					then
						self:RemoveClient(key, `reliable ACK timeout ({pendingCount} pending messages)`)
						continue
					end
					for msgId, ackData in pairs(client.pendingAcks) do
						local dynamicTimeout = ACK_TIMEOUT + ((ackData.fragmentCount or 1) * 0.05)
						if currentTime - ackData.lastSent > dynamicTimeout then
							if ackData.attempts >= MAX_RETRIES then
								self:RemoveClient(
									key,
									`reliable ACK timeout (channel={ackData.channel or "?"}, kind={ackData.kind or "?"}, fragments={ackData.fragmentCount or 1})`
								)
								break
							else
								ackData.attempts = ackData.attempts + 1
								ackData.lastSent = currentTime

								task.spawn(function()
									for i, fragment in ipairs(ackData.fragments) do
										if not self:SendRaw(client, fragment) then
											break
										end
										if i % 200 == 0 then
											task.wait()
										end
									end
								end)
							end
						end
					end
				end
			end
		end
	end)
end

function Server:AuthenticateClient(addr, authToken)
	if not self:ValidateAuthToken(authToken) then
		self:SendRaw({
			address = addr.address,
			port = addr.port,
		}, {
			type = "AUTH_FAILED",
			reason = "Invalid token",
		})
		return false
	end

	local key = clientKey(addr)

	local sessionId = self:GenerateSessionId()

	Server.ConnectedClients[key] = {
		address = addr.address,
		port = addr.port,
		sessionId = sessionId,
		authenticated = true,
		connectedAt = os.time(),
		connectedAtClock = os.clock(),
		lastHeartbeat = os.time(),
		lastPacketAt = os.clock(),
		lastSequence = nil,
		recentSequences = {},
		recentSequenceRing = nil,
		recentSequenceIndex = 0,
		recentSequenceCount = 0,
		highestSequence = -math.huge,
		processedReliableMessages = {},
		processedReliableRing = nil,
		processedReliableIndex = 0,
		processedReliableCount = 0,
		rateLimitRing = nil,
		rateLimitIndex = 0,
		rateLimitCount = 0,
		fragmentBuffer = {},
		pendingAcks = {},
	}

	self:SendRaw(Server.ConnectedClients[key], {
		type = "AUTH_SUCCESS",
		sessionId = sessionId,
	})

	log(`Client ({key}) authenticated with session: {sessionId}`)

	if Server._onNewClient then
		Server._onNewClient(addr)
	end

	return true, Server.ConnectedClients[key]
end

function Server._middleware(v, addr)
	local key = clientKey(addr)
	local client = Server.ConnectedClients[key]

	if Server:IsBanned(addr.address) then
		return
	end

	if type(v) == "table" then
		if v.type == "ACK" then
			if client then
				client.lastHeartbeat = os.time()
				client.lastPacketAt = os.clock()
				if client.pendingAcks and client.pendingAcks[v.messageId] then
					client.pendingAcks[v.messageId] = nil
				end
			end
			return
		end

		if v.type == "CONNECT" then
			local existingClient = Server.ConnectedClients[key]
			if existingClient and existingClient.authenticated then
				-- Client is already connected; re-send existing AUTH_SUCCESS
				-- (the previous one may have been lost over UDP)
				Server:SendRaw(existingClient, {
					type = "AUTH_SUCCESS",
					sessionId = existingClient.sessionId,
				})
				existingClient.lastHeartbeat = os.time()
				existingClient.lastPacketAt = os.clock()
				return
			end

			if countConnectedClients() >= MAX_CLIENTS then
				warn(`Max clients reached, rejecting {key}`)
				return
			end

			local success, client = Server:AuthenticateClient(addr, v.authToken)
			if success and client then
				if Server._onClientConnectionRequest then
					Server._onClientConnectionRequest(client, v.arguments)
				end
			end
			return
		end

		if not client and Server._onPreAuthMessage then
			local handled = Server._onPreAuthMessage(addr, v)
			if handled then
				return
			end
		end

		if not client or not client.authenticated then
			warn(`Unauthenticated message from {key}`)
			return
		end

		if not Server:CheckRateLimit(client) then
			warn(`Rate limit exceeded for {key}`)
			Server:BanClient(addr.address, "Rate limit exceeded")
			Server:SendRaw(client, { type = "DISCONNECT", reason = "Rate limit" })
			Server:RemoveClient(key, "rate limit exceeded")
			return
		end

		local valid, err = Server:ValidateMessage(v, client)
		if not valid then
			warn(`Invalid message from {key}: {err}`)
			return
		end

		-- Any valid message from the client keeps the session alive,
		-- not just explicit HEARTBEAT packets. This prevents timeouts
		-- when the client is actively sending owned-state or other data
		-- but a heartbeat UDP packet gets lost.
		client.lastHeartbeat = os.time()
		client.lastPacketAt = os.clock()

		if v.type == "DISCONNECT" then
			Server:RemoveClient(key, "client requested disconnect", true)
		end
	end
end

function Server:StartHeartbeatMonitor()
	task.spawn(function()
		while true do
			task.wait(HEARTBEAT_TIMEOUT / 2)
			if not self.Socket then
				break
			end

			local currentTime = os.time()
			for key, client in pairs(Server.ConnectedClients) do
				cleanupFragmentBuffer(client.fragmentBuffer, os.clock())
				if client.authenticated then
					if currentTime - client.lastHeartbeat > HEARTBEAT_TIMEOUT then
						Server:SendRaw(client, { type = "DISCONNECT", reason = "Timeout" })
						Server:RemoveClient(key, "heartbeat timeout", true)
					end
				end
			end
		end
	end)
end

function Server:Listen()
	assert(self.Socket, "Socket not created, call :Init() first")

	self:StartHeartbeatMonitor()
	self:ProcessReliableQueue()

	task.spawn(function()
		while true do
			if not self.Socket then
				break
			end

			local success, addr, data = pcall(function()
				return self.Socket:recvMsg(MAX_WIRE_MESSAGE_SIZE)
			end)

			if not success then
				if isTransientRecvError(addr) then
					task.wait(0.05)
				else
					warn(`[KiNet][Server] recvMsg failed: {addr}`)
					task.wait()
				end
				continue
			end

			if not data then
				task.wait()
				continue
			end

			if buffer.len(data) > MAX_WIRE_MESSAGE_SIZE then
				warn(`Message too large from {clientKey(addr)}`)
				task.wait()
				continue
			end

			local decodedOk, decoded = pcall(Serializer.Deserialize, data)
			if not decodedOk then
				warn(`[KiNet][Server] Failed to deserialize packet from {clientKey(addr)}: {decoded}`)
				continue
			end

			if decoded then
				local key = clientKey(addr)
				local client = Server.ConnectedClients[key]

				if decoded.fragment and client then
					local fragmentMessageId = decoded.messageId
					local reassembled = self:ReassembleFragments(decoded, client)
					if reassembled then
						decoded = reassembled
						if decoded.reliable then
							self:SendRaw(client, {
								type = "ACK",
								messageId = fragmentMessageId,
							})
						end
					else
						task.wait()
						continue
					end
				elseif decoded.reliable and client then
					self:SendRaw(client, {
						type = "ACK",
						messageId = decoded.messageId,
					})
				end

				if
					decoded.reliable
					and client
					and decoded.messageId
					and not rememberReliableMessage(client, decoded.messageId)
				then
					continue
				end

				Server._middleware(decoded, addr)

				client = Server.ConnectedClients[key]

				if client and client.authenticated then
					for _, v in pairs(onRecieveCallbacks) do
						zune.task.spawn(function()
							v(addr, decoded)
						end)
					end
				end
			end
		end
	end)
end

return Server
