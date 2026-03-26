local net = zune.net
local platform = zune.platform

local Serializer = require("./Serializer")

local TCPClient = {}

local onRecieveConnections = {}
local messageQueue = {}
local MAX_QUEUE_SIZE = 1000

local HEARTBEAT_INTERVAL = 5
local MAX_MESSAGE_SIZE = 100000
local MESSAGE_TIMEOUT = 10
local ACK_TIMEOUT = 3
local MAX_RETRIES = 5

-- Length-prefix framing for TCP stream segmentation
local function writeFramed(socket, buf)
	local len = buffer.len(buf)
	local header = buffer.create(4)
	buffer.writeu32(header, 0, len)
	socket:send(header)
	socket:send(buf)
end

local function readFramed(socket)
	local headerBuf = socket:recv(4)
	if not headerBuf or buffer.len(headerBuf) < 4 then
		return nil
	end
	local len = buffer.readu32(headerBuf, 0)
	if len > MAX_MESSAGE_SIZE then
		return nil
	end
	local data = socket:recv(len)
	return data
end

function TCPClient:Init(serverAddress, serverPort, authToken)
	self.ServerAddress = serverAddress or "127.0.0.1"
	self.ServerPort = serverPort or 1234
	self.AuthToken = authToken or self:GenerateToken()
	self.SessionId = nil
	self.IsAuthenticated = false
	self.LastHeartbeat = 0
	self.MessageSequence = 0
	self.ReceivedSequences = {}
	self.RateLimitWindow = {}
	self.MaxMessagesPerSecond = 100
	self.PendingAcks = {}
	self.ReliableQueue = {}
	self.Socket = nil
	self._connected = false

	local socket = net.createSocket(
		net.ADDRF.INET,
		bit32.bor(net.SOCKF.STREAM, if platform.os == "windows" then 0 else net.SOCKF.CLOEXEC),
		net.IPPROTO.TCP
	)

	socket:connect(serverAddress, serverPort)

	self.Socket = socket
	self._connected = true

	print(`[TCPClient] Connected to {serverAddress}:{serverPort}`)
	return socket
end

function TCPClient:GenerateToken()
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local token = ""
	for i = 1, 32 do
		local rand = math.random(1, #chars)
		token = token .. string.sub(chars, rand, rand)
	end
	return token
end

function TCPClient:ValidateMessage(data)
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
		if self.ReceivedSequences[data.sequence] then
			return false, "Duplicate message"
		end
		self.ReceivedSequences[data.sequence] = true
	end

	if data.sessionId and self.SessionId and data.sessionId ~= self.SessionId then
		return false, "Invalid session"
	end

	return true
end

function TCPClient:CheckRateLimit()
	local currentTime = os.time()

	local filtered = {}
	for _, timestamp in ipairs(self.RateLimitWindow or {}) do
		if currentTime - timestamp < 1 then
			table.insert(filtered, timestamp)
		end
	end
	self.RateLimitWindow = filtered

	if #self.RateLimitWindow >= self.MaxMessagesPerSecond then
		return false
	end

	table.insert(self.RateLimitWindow, currentTime)
	return true
end

function TCPClient:SendReliable(data)
	local messageId = `reliable_{self.MessageSequence}`
	data.messageId = messageId
	data.reliable = true
	data.timestamp = os.time()

	self.PendingAcks[messageId] = {
		data = data,
		attempts = 0,
		lastSent = os.clock(),
	}

	self:SendRaw(data)
end

function TCPClient:SendRaw(data)
	if not self:CheckRateLimit() then
		warn("[TCPClient] Rate limit exceeded")
		return
	end

	if not self.Socket or not self._connected then
		warn("[TCPClient] Not connected")
		return
	end

	data.timestamp = os.time()
	data.sequence = self.MessageSequence
	self.MessageSequence = self.MessageSequence + 1

	if self.SessionId then
		data.sessionId = self.SessionId
	end

	local buf = Serializer.Serialize(data)

	if buffer.len(buf) > MAX_MESSAGE_SIZE then
		warn("[TCPClient] Message too large")
		return
	end

	local ok, err = pcall(writeFramed, self.Socket, buf)
	if not ok then
		warn(`[TCPClient] Send failed: {err}`)
		self._connected = false
	end
end

function TCPClient:ProcessReliableQueue()
	task.spawn(function()
		while self._connected do
			task.wait(0.1)

			local currentTime = os.clock()

			for msgId, ackData in pairs(self.PendingAcks) do
				if currentTime - ackData.lastSent > ACK_TIMEOUT then
					if ackData.attempts >= MAX_RETRIES then
						warn(`[TCPClient] Message {msgId} failed after {MAX_RETRIES} retries`)
						self.PendingAcks[msgId] = nil
					else
						ackData.attempts = ackData.attempts + 1
						ackData.lastSent = currentTime

						self:SendRaw(ackData.data)
					end
				end
			end
		end
	end)
end

function TCPClient:OnShutdown(v)
	TCPClient._OnShutdown = v
end

function TCPClient:Connect(arguments)
	log(`[TCPClient] Authenticating with server at {self.ServerAddress}:{self.ServerPort}`)
	TCPClient:Send({
		type = "CONNECT",
		authToken = self.AuthToken,
		arguments = arguments,
	})
end

function TCPClient:OnRecieve(callback)
	table.insert(onRecieveConnections, callback)

	if #onRecieveConnections == 1 and #messageQueue > 0 then
		print(`[TCPClient] Processing {#messageQueue} queued messages`)
		for _, queuedMsg in ipairs(messageQueue) do
			task.spawn(function()
				callback(queuedMsg.addr, queuedMsg.data)
			end)
		end
		messageQueue = {}
	end
end

function TCPClient:Disconnect()
	log(`[TCPClient] Disconnecting from server at {self.ServerAddress}:{self.ServerPort}`)
	if not self.Socket then
		return
	end

	if self.IsAuthenticated then
		pcall(function()
			TCPClient:Send({
				type = "DISCONNECT",
				sessionId = self.SessionId,
			})
		end)
	end

	self._connected = false
	pcall(function()
		self.Socket:close()
	end)
	self.IsAuthenticated = false
	self.SessionId = nil

	if TCPClient._OnShutdown then
		TCPClient._OnShutdown()
	end
end

function TCPClient:Send(data, reliable)
	assert(self.Socket, "[TCPClient] Socket not initialized, call :Init() first")

	if reliable then
		self:SendReliable(data)
	else
		self:SendRaw(data)
	end
end

function TCPClient._middleware(v, addr)
	if type(v) == "table" then
		if v.type == "ACK" then
			if TCPClient.PendingAcks[v.messageId] then
				TCPClient.PendingAcks[v.messageId] = nil
			end
			return
		end

		if v.type == "AUTH_SUCCESS" then
			TCPClient.IsAuthenticated = true
			TCPClient.SessionId = v.sessionId
			log(`[TCPClient] Authenticated with session: {v.sessionId}`)
		end

		if v.type == "AUTH_FAILED" then
			warn("[TCPClient] Authentication failed")
			TCPClient:Disconnect()
		end

		if v.type == "DISCONNECT" then
			log(`[TCPClient] Server requested disconnect`)
			TCPClient:Disconnect()
		end

		if v.type == "SHUTDOWN" then
			log(`[TCPClient] Server shutdown`)
			TCPClient:Disconnect()
		end

		if v.type == "HEARTBEAT" then
			TCPClient.LastHeartbeat = os.time()
		end
	elseif type(v) == "string" then
		if string.find(v, "DISCONNECT") then
			log(`[TCPClient] Disconnected`)
			TCPClient:Disconnect()
		end

		if string.find(v, "SHUTDOWN") then
			log(`[TCPClient] Server shutdown`)
			TCPClient:Disconnect()
		end
	end
end

function TCPClient:StartHeartbeat()
	task.spawn(function()
		while self._connected do
			task.wait(HEARTBEAT_INTERVAL)
			if TCPClient.IsAuthenticated and self._connected then
				TCPClient:Send({
					type = "HEARTBEAT",
				})
			end
		end
	end)
end

function TCPClient:Listen()
	self:ProcessReliableQueue()

	task.spawn(function()
		while self._connected do
			local success, data = pcall(readFramed, self.Socket)

			if not success then
				if data == "EOF" or data == "ConnectionResetByPeer" then
					log("[TCPClient] Connection closed by server")
					self:Disconnect()
					break
				end
				task.wait()
				continue
			end

			if data then
				local decoded = Serializer.Deserialize(data)

				if decoded then
					if decoded.reliable then
						self:SendRaw({
							type = "ACK",
							messageId = decoded.messageId,
						})
					end

					local valid, err = self:ValidateMessage(decoded)
					if not valid then
						warn(`[TCPClient] Invalid message: {err}`)
						task.wait()
						continue
					end

					TCPClient._middleware(decoded, {
						address = self.ServerAddress,
						port = self.ServerPort,
					})

					if #onRecieveConnections == 0 then
						if #messageQueue < MAX_QUEUE_SIZE then
							table.insert(messageQueue, {
								addr = { address = self.ServerAddress, port = self.ServerPort },
								data = decoded,
							})
						else
							warn("[TCPClient] Message queue full, dropping message")
						end
					else
						for _, v in pairs(onRecieveConnections) do
							task.spawn(function()
								v({ address = self.ServerAddress, port = self.ServerPort }, decoded)
							end)
						end
					end
				end
			end
			task.wait()
		end
	end)
end

return TCPClient
