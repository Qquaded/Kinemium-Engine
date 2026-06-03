local net = zune.net
local Client = {}

local Serializer = require("./Serializer")

local onRecieveConnections = {}
local messageQueue = {}
local isQueueProcessing = false
local MAX_QUEUE_SIZE = 1000

local HEARTBEAT_INTERVAL = 5
local HEARTBEAT_TIMEOUT = 15
local MAX_WIRE_MESSAGE_SIZE = 256 * 1024
local MAX_LOGICAL_MESSAGE_SIZE = 256 * 1024 * 1024
-- Replay / clock-skew window for inbound messages (seconds). The previous
-- value of 300s allowed a 5-minute replay; this is tightened to a window
-- that still tolerates reasonable NTP drift.
local MESSAGE_TIMEOUT = 30
local MTU_SIZE = 1200
local ACK_TIMEOUT = 3
local MAX_RETRIES = 5
local FRAGMENT_TIMEOUT = 30
local MAX_FRAGMENT_COUNT = 262144
local MAX_SEQUENCE_WINDOW = 2048
local MAX_PROCESSED_RELIABLE_MESSAGES = 2048
local RATE_LIMIT_WINDOW_SECONDS = 1

local function createMessageId(prefix, sequence)
	return `{prefix}_{sequence}_{math.floor(os.clock() * 1000)}`
end

-- Ring-buffered dedup for inbound sequences. Previously this used
-- `table.insert` / `table.remove(tbl, 1)` which is O(n) per packet.
local function trackReceivedSequence(self, sequence)
	if type(sequence) ~= "number" then
		return true
	end

	local seen = self.ReceivedSequences
	if not seen then
		seen = {}
		self.ReceivedSequences = seen
	end

	local ring = self.ReceivedSequenceRing
	if not ring then
		ring = table.create(MAX_SEQUENCE_WINDOW, 0)
		self.ReceivedSequenceRing = ring
		self.ReceivedSequenceIndex = 0
		self.ReceivedSequenceCount = 0
	end

	if self.HighestReceivedSequence == nil then
		self.HighestReceivedSequence = -math.huge
	end

	if seen[sequence] then
		return false, "Duplicate message"
	end

	if
		self.HighestReceivedSequence ~= -math.huge
		and sequence <= self.HighestReceivedSequence - MAX_SEQUENCE_WINDOW
	then
		return false, "Sequence too old"
	end

	local idx = self.ReceivedSequenceIndex
	local evicted = ring[idx + 1]
	if evicted ~= nil and self.ReceivedSequenceCount >= MAX_SEQUENCE_WINDOW then
		seen[evicted] = nil
	end

	ring[idx + 1] = sequence
	seen[sequence] = true
	self.ReceivedSequenceIndex = (idx + 1) % MAX_SEQUENCE_WINDOW
	if self.ReceivedSequenceCount < MAX_SEQUENCE_WINDOW then
		self.ReceivedSequenceCount += 1
	end

	if sequence > self.HighestReceivedSequence then
		self.HighestReceivedSequence = sequence
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
local function rememberReliableMessage(self, messageId)
	if type(messageId) ~= "string" then
		return true
	end

	local seen = self.ProcessedReliableMessages
	if not seen then
		seen = {}
		self.ProcessedReliableMessages = seen
	end

	local ring = self.ProcessedReliableRing
	if not ring then
		ring = table.create(MAX_PROCESSED_RELIABLE_MESSAGES)
		self.ProcessedReliableRing = ring
		self.ProcessedReliableIndex = 0
		self.ProcessedReliableCount = 0
	end

	if seen[messageId] then
		return false
	end

	local idx = self.ProcessedReliableIndex
	local evicted = ring[idx + 1]
	if evicted ~= nil and self.ProcessedReliableCount >= MAX_PROCESSED_RELIABLE_MESSAGES then
		seen[evicted] = nil
	end

	ring[idx + 1] = messageId
	seen[messageId] = true
	self.ProcessedReliableIndex = (idx + 1) % MAX_PROCESSED_RELIABLE_MESSAGES
	if self.ProcessedReliableCount < MAX_PROCESSED_RELIABLE_MESSAGES then
		self.ProcessedReliableCount += 1
	end

	return true
end

local function resolveServerEndpoint(address, port)
	local ok, addresses = pcall(net.getAddressList, address, port)
	if not ok or type(addresses) ~= "table" or #addresses == 0 then
		return address
	end

	for _, entry in ipairs(addresses) do
		if entry.family == net.ADDRF.INET then
			return entry.address
		end
	end

	return address
end

function Client:Init(serverAddress, serverPort, authToken)
	if self.Socket then
		self:Disconnect()
	end

	serverAddress = serverAddress or "127.0.0.1"
	serverPort = serverPort or 1234

	local resolvedAddress = resolveServerEndpoint(serverAddress, serverPort)

	local socket = net.createSocket(
		net.ADDRF.INET,
		bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC),
		net.IPPROTO.UDP
	)

	socket:bindIp("0.0.0.0", 0)

	self.Socket = socket
	self.ServerAddress = resolvedAddress
	self.ServerPort = serverPort
	self.OriginalServerAddress = serverAddress
	self.AuthToken = authToken or self:GenerateToken()
	self.SessionId = nil
	self.IsAuthenticated = false
	self.LastHeartbeat = 0
	self.MessageSequence = 0
	self.ReceivedSequences = {}
	self.MaxMessagesPerSecond = 300
	self.PendingAcks = {}
	self.FragmentBuffer = {}
	self.ReliableQueue = {}
	self.ReceivedSequenceRing = nil
	self.ReceivedSequenceIndex = 0
	self.ReceivedSequenceCount = 0
	self.HighestReceivedSequence = -math.huge
	self.ProcessedReliableMessages = {}
	self.ProcessedReliableRing = nil
	self.ProcessedReliableIndex = 0
	self.ProcessedReliableCount = 0
	self.RateLimitRing = nil
	self.RateLimitIndex = 0
	self.RateLimitCount = 0
	self.RateLimitCapacity = 0
	self._reliableQueueRunning = false
	self._heartbeatRunning = false
	self._listenRunning = false

	onRecieveConnections = {}
	messageQueue = {}

	print(`Created client socket for {serverAddress} -> {resolvedAddress}`)
	return socket
end

function Client:GenerateToken()
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local token = ""
	for i = 1, 32 do
		local rand = math.random(1, #chars)
		token = token .. string.sub(chars, rand, rand)
	end
	return token
end

function Client:ValidateMessage(data)
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
		local accepted, err = trackReceivedSequence(self, data.sequence)
		if not accepted then
			return false, err
		end
	end

	if data.sessionId and self.SessionId and data.sessionId ~= self.SessionId then
		return false, "Invalid session"
	end

	return true
end

function Client:CheckRateLimit()
	local currentTime = os.clock()
	local capacity = self.MaxMessagesPerSecond

	local ring = self.RateLimitRing
	if not ring or self.RateLimitCapacity ~= capacity then
		-- Store new capacity before creating ring to prevent race condition
		self.RateLimitCapacity = capacity
		ring = table.create(capacity, 0)
		self.RateLimitRing = ring
		self.RateLimitIndex = 0
		self.RateLimitCount = 0
	end

	local idx = self.RateLimitIndex

	if self.RateLimitCount >= capacity then
		local oldest = ring[idx + 1]
		if oldest and currentTime - oldest < RATE_LIMIT_WINDOW_SECONDS then
			return false
		end
	end

	ring[idx + 1] = currentTime
	self.RateLimitIndex = (idx + 1) % capacity
	if self.RateLimitCount < capacity then
		self.RateLimitCount += 1
	end

	return true
end

function Client:FragmentMessage(data, messageId, serializedBuffer, reliable)
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
			`[KiNet][Client] Fragmenting {data.channel}:{data.kind} into {totalFragments} fragments ({buffer.len(buf)} bytes)`
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

function Client:ReassembleFragments(fragmentData)
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

	local now = os.clock()
	if now - (self._lastFragmentCleanup or 0) > 1 then
		self._lastFragmentCleanup = now
		cleanupFragmentBuffer(self.FragmentBuffer)
	end

	if not self.FragmentBuffer[msgId] then
		-- Check for potential memory exhaustion attack
		if fragmentData.totalFragments > 10000 then
			warn(`[KiNet][Client] Rejecting suspicious fragment request for {msgId}: {fragmentData.totalFragments} fragments`)
			return nil
		end
		
		self.FragmentBuffer[msgId] = {
			fragments = {},
			totalFragments = fragmentData.totalFragments,
			received = 0,
			totalBytes = 0,
			createdAt = os.clock(),
			lastUpdated = os.clock(),
		}
	end

	local fragmentState = self.FragmentBuffer[msgId]
	if fragmentState.totalFragments ~= fragmentData.totalFragments then
		self.FragmentBuffer[msgId] = nil
		return nil
	end

	fragmentState.lastUpdated = os.clock()

	if not fragmentState.fragments[fragmentData.fragmentIndex] then
		fragmentState.fragments[fragmentData.fragmentIndex] = fragmentData.data
		fragmentState.received = fragmentState.received + 1
		fragmentState.totalBytes += chunkLength
		if fragmentState.totalBytes > MAX_LOGICAL_MESSAGE_SIZE then
			self.FragmentBuffer[msgId] = nil
			warn(
				`[KiNet][Client] Dropping fragmented message {msgId} because it exceeds {MAX_LOGICAL_MESSAGE_SIZE} bytes`
			)
			return nil
		end
	else
		-- Duplicate fragment detected - potential replay attack
		warn(`[KiNet][Client] Duplicate fragment {fragmentData.fragmentIndex} for message {msgId}`)
		return nil
	end

	if fragmentState.received == fragmentState.totalFragments then
		local totalLength = 0
		for i = 0, fragmentState.totalFragments - 1 do
			if not fragmentState.fragments[i] then
				self.FragmentBuffer[msgId] = nil
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

		self.FragmentBuffer[msgId] = nil

		print(`[KiNet][Client] Reassembled fragmented message {msgId} ({fragmentState.totalFragments} fragments)`)

		local ok, decoded = pcall(Serializer.Deserialize, completeData)
		if not ok then
			warn(`[KiNet][Client] Failed to deserialize reassembled message {msgId}: {decoded}`)
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

function Client:SendReliable(data)
	local messageId = data.messageId or createMessageId("reliable", self.MessageSequence)
	data.messageId = messageId
	data.reliable = true
	data.timestamp = os.time()

	local ok, serialized = pcall(Serializer.Serialize, data)
	if not ok then
		warn(`[KiNet][Client] Failed to serialize reliable message {messageId}: {serialized}`)
		return
	end

	if buffer.len(serialized) > MAX_LOGICAL_MESSAGE_SIZE then
		warn(
			`[KiNet][Client] Reliable message {messageId} is {buffer.len(serialized)} bytes which exceeds the logical limit of {MAX_LOGICAL_MESSAGE_SIZE}`
		)
		return
	end

	local fragments = self:FragmentMessage(data, messageId, serialized, true)

	self.PendingAcks[messageId] = {
		fragments = fragments,
		attempts = 0,
		lastSent = os.clock(),
		channel = data.channel,
		kind = data.kind or data.type,
		fragmentCount = #fragments,
	}

	task.spawn(function()
		for i, fragment in ipairs(fragments) do
			if not self:SendRaw(fragment) then
				break
			end
			if i % 200 == 0 then
				task.wait()
			end
		end
	end)
end

function Client:SendRaw(data)
	if not self.Socket then
		return false
	end

	local bypassRateLimit = type(data) == "table"
		and (data.type == "ACK" or data.type == "HEARTBEAT" or data.type == "CONNECT" or data.type == "DISCONNECT" 
			or data.type == "AUTH_SUCCESS" or data.type == "AUTH_FAILED" or data.type == "SHUTDOWN"
			or data.type == "SNAPSHOT_ACK")  -- Include all critical protocol messages

	if not bypassRateLimit and not self:CheckRateLimit() then
		warn("Rate limit exceeded")
		return
	end

	-- Always refresh timestamp at send time so retries cannot become stale.
	data.timestamp = os.time()
	data.sequence = self.MessageSequence
	self.MessageSequence = self.MessageSequence + 1

	if self.SessionId then
		data.sessionId = self.SessionId
	end

	local buf = Serializer.Serialize(data)

	if buffer.len(buf) > MAX_WIRE_MESSAGE_SIZE then
		warn(
			`[KiNet][Client] Datagram too large: {buffer.len(buf)} bytes (max: {MAX_WIRE_MESSAGE_SIZE}) for {data.kind or data.type or "packet"}`
		)
		return false
	end

	self.Socket:sendMsg(self.ServerPort, self.ServerAddress, buf)
	return true
end

function Client:ProcessReliableQueue()
	if self._reliableQueueRunning then
		return
	end

	self._reliableQueueRunning = true
	task.spawn(function()
		while self._reliableQueueRunning do
			task.wait(0.1)

			local currentTime = os.clock()
			cleanupFragmentBuffer(self.FragmentBuffer, currentTime)

			for msgId, ackData in pairs(self.PendingAcks) do
				local dynamicTimeout = ACK_TIMEOUT + ((ackData.fragmentCount or 1) * 0.05)
				if currentTime - ackData.lastSent > dynamicTimeout then
					if ackData.attempts >= MAX_RETRIES then
						warn(
							`Message {msgId} failed after {MAX_RETRIES} retries (channel={ackData.channel or "?"}, kind={ackData.kind or "?"}, fragments={ackData.fragmentCount or 1})`
						)
						self.PendingAcks[msgId] = nil
					else
						ackData.attempts = ackData.attempts + 1
						ackData.lastSent = currentTime

						task.spawn(function()
							for i, fragment in ipairs(ackData.fragments) do
								if not self:SendRaw(fragment) then
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
	end)
end

function Client:OnShutdown(v)
	Client._OnShutdown = v
end

function Client:Connect(arguments)
	local displayAddress = self.OriginalServerAddress or self.ServerAddress
	log(`Connecting to server at {displayAddress}:{self.ServerPort}`)
	Client:Send({
		type = "CONNECT",
		authToken = self.AuthToken,
		arguments = arguments,
	})

	-- Retry connection if not authenticated
	task.spawn(function()
		local retries = 0
		local MAX_CONNECT_RETRIES = 15
		local CONNECT_RETRY_INTERVAL = 2

		while not Client.IsAuthenticated and retries < MAX_CONNECT_RETRIES do
			task.wait(CONNECT_RETRY_INTERVAL)
			if Client.IsAuthenticated or not Client.Socket then
				break
			end
			retries += 1
			log(`Connection retry {retries}/{MAX_CONNECT_RETRIES} to {displayAddress}:{self.ServerPort}`)
			Client:Send({
				type = "CONNECT",
				authToken = self.AuthToken,
				arguments = arguments,
			})
		end

		if not Client.IsAuthenticated and Client.Socket then
			warn(
				`[KiNet][Client] Failed to connect to {displayAddress}:{self.ServerPort} after {MAX_CONNECT_RETRIES} retries`
			)
		end
	end)
end

function Client:OnRecieve(callback)
	table.insert(onRecieveConnections, callback)

	if #onRecieveConnections == 1 and #messageQueue > 0 then
		print(`Processing {#messageQueue} queued messages`)
		for _, queuedMsg in ipairs(messageQueue) do
			task.spawn(function()
				callback(queuedMsg.addr, queuedMsg.data)
			end)
		end
		messageQueue = {} -- Clear queue
	end
end

function Client:Disconnect()
	local displayAddress = self.OriginalServerAddress or self.ServerAddress
	log(`Disconnecting from server at {displayAddress}:{self.ServerPort}`)
	if not self.Socket then
		return
	end

	if self.IsAuthenticated then
		Client:Send({
			type = "DISCONNECT",
			sessionId = self.SessionId,
		})
	end

	self._reliableQueueRunning = false
	self._heartbeatRunning = false
	self._monitorRunning = false
	self._listenRunning = false

	self.Socket:close()
	self.Socket = nil
	self.IsAuthenticated = false
	self.SessionId = nil
	self.PendingAcks = {}
	self.FragmentBuffer = {}
	self.ReliableQueue = {}
	self.ReceivedSequences = {}
	self.ReceivedSequenceRing = nil
	self.ReceivedSequenceIndex = 0
	self.ReceivedSequenceCount = 0
	self.HighestReceivedSequence = -math.huge
	self.ProcessedReliableMessages = {}
	self.ProcessedReliableRing = nil
	self.ProcessedReliableIndex = 0
	self.ProcessedReliableCount = 0
	self.RateLimitRing = nil
	self.RateLimitIndex = 0
	self.RateLimitCount = 0
	self.RateLimitCapacity = 0

	if Client._OnShutdown then
		Client._OnShutdown()
	end
end

function Client:Send(data, reliable)
	assert(self.Socket, "Socket not initialized, call :Init() first")

	if reliable then
		self:SendReliable(data)
	else
		data.reliable = false

		local ok, serialized = pcall(Serializer.Serialize, data)
		if not ok then
			warn(`[KiNet][Client] Failed to serialize message: {serialized}`)
			return
		end

		if buffer.len(serialized) > MAX_LOGICAL_MESSAGE_SIZE then
			warn(
				`[KiNet][Client] Message is {buffer.len(serialized)} bytes which exceeds the logical limit of {MAX_LOGICAL_MESSAGE_SIZE}`
			)
			return
		end

		if buffer.len(serialized) > MTU_SIZE then
			local messageId = data.messageId or createMessageId("fragmented", self.MessageSequence)
			data.messageId = messageId
			data.timestamp = data.timestamp or os.time()
			local largeOk, largeSerialized = pcall(Serializer.Serialize, data)
			if not largeOk then
				warn(`[KiNet][Client] Failed to serialize large fragmented message {messageId}: {largeSerialized}`)
				return
			end

			task.spawn(function()
				for i, fragment in ipairs(self:FragmentMessage(data, messageId, largeSerialized, false)) do
					if not self:SendRaw(fragment) then
						break
					end
					if i % 200 == 0 then
						task.wait()
					end
				end
			end)
			return
		end

		self:SendRaw(data)
	end
end

function Client._middleware(v, addr)
	if type(v) == "table" then
		if v.type == "ACK" then
			if Client.PendingAcks[v.messageId] then
				Client.PendingAcks[v.messageId] = nil
			end
			return
		end

		if v.type == "AUTH_SUCCESS" then
			Client.IsAuthenticated = true
			Client.SessionId = v.sessionId
			Client.LastHeartbeat = os.time()
			log(`Authenticated with session: {v.sessionId}`)
		end

		if v.type == "AUTH_FAILED" then
			warn("Authentication failed")
			Client:Disconnect()
		end

		if v.type == "DISCONNECT" then
			log(`Server requested disconnect`)
			Client:Disconnect()
		end

		if v.type == "SHUTDOWN" then
			log(`Server shutdown`)
			Client:Disconnect()
		end

		if v.type == "HEARTBEAT" then
			Client.LastHeartbeat = os.time()
		end
	elseif type(v) == "string" then
		if string.find(v, "DISCONNECT") then
			log(`Client disconnected at {addr}`)
			Client:Disconnect()
		end

		if string.find(v, "SHUTDOWN") then
			log(`Client shutdown at {addr}`)
			Client:Disconnect()
		end
	end
end

function Client:StartHeartbeat()
	if self._heartbeatRunning then
		return
	end

	self._heartbeatRunning = true
	task.spawn(function()
		while self._heartbeatRunning do
			task.wait(HEARTBEAT_INTERVAL)
			if Client.IsAuthenticated then
				Client:Send({
					type = "HEARTBEAT",
				})
			end
		end
	end)
end

function Client:StartHeartbeatMonitor()
	if self._monitorRunning then
		return
	end

	self._monitorRunning = true
	task.spawn(function()
		while self._monitorRunning do
			task.wait(HEARTBEAT_TIMEOUT / 2)
			if Client.IsAuthenticated and Client.LastHeartbeat > 0 then
				if os.time() - Client.LastHeartbeat > HEARTBEAT_TIMEOUT then
					warn(`[KiNet][Client] Server timed out`)
					Client:Disconnect()
				end
			end
		end
	end)
end

function Client:Listen()
	if self._listenRunning then
		return
	end

	self._listenRunning = true
	self:ProcessReliableQueue()
	self:StartHeartbeat()
	self:StartHeartbeatMonitor()

	task.spawn(function()
		while self._listenRunning do
			if not self.Socket then
				break
			end

			local success, addr, data = pcall(function()
				return self.Socket:recvMsg(MAX_WIRE_MESSAGE_SIZE)
			end)

			if not success then
				task.wait()
				continue
			end

			if data then
				local decodedOk, decoded = pcall(Serializer.Deserialize, data)
				if not decodedOk then
					warn(`[KiNet][Client] Failed to deserialize incoming packet: {decoded}`)
					continue
				end

				if decoded then
					if decoded.fragment then
						local fragmentMessageId = decoded.messageId
						local reassembled = self:ReassembleFragments(decoded)
						if reassembled then
							decoded = reassembled
							if decoded.reliable then
								self:SendRaw({
									type = "ACK",
									messageId = fragmentMessageId,
								})
							end
						else
							task.wait()
							continue
						end
					elseif decoded.reliable then
						self:SendRaw({
							type = "ACK",
							messageId = decoded.messageId,
						})
					end

					local valid, err = self:ValidateMessage(decoded)
					if not valid then
						warn(`Invalid message: {err}`)
						task.wait()
						continue
					end

					self.LastHeartbeat = os.time()

					if
						decoded.reliable
						and decoded.messageId
						and not rememberReliableMessage(self, decoded.messageId)
					then
						continue
					end

					Client._middleware(decoded, addr)

					if #onRecieveConnections == 0 then
						if #messageQueue < MAX_QUEUE_SIZE then
							table.insert(messageQueue, { addr = addr, data = decoded })
							print(`Queued message (queue size: {#messageQueue})`)
						else
							warn("Message queue full, dropping message")
						end
					else
						for _, v in pairs(onRecieveConnections) do
							task.spawn(function()
								v(addr, decoded)
							end)
						end
					end
				end
			end
		end
	end)
end

return Client
