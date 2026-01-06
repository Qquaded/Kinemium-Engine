local net = zune.net
local Client = {}

local Serializer = require("./Serializer")

local onRecieveConnections = {}

local HEARTBEAT_INTERVAL = 5
local MAX_MESSAGE_SIZE = 100000
local MESSAGE_TIMEOUT = 10
local MTU_SIZE = 1400
local ACK_TIMEOUT = 3
local MAX_RETRIES = 5

function Client:Init(serverAddress, serverPort, authToken)
	local socket = net.createSocket(
		net.ADDRF.INET,
		bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC),
		net.IPPROTO.UDP
	)

	socket:bindIp("127.0.0.1", 0)

	self.Socket = socket
	self.ServerAddress = serverAddress or "0.0.0.0"
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
	self.FragmentBuffer = {}
	self.ReliableQueue = {}

	print(`Created client socket with auth token`)
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

function Client:CheckRateLimit()
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

function Client:FragmentMessage(data, messageId)
	local buf = Serializer.Serialize(data)

	if buffer.len(buf) <= MTU_SIZE then
		return { {
			fragment = false,
			data = data,
		} }
	end

	local fragments = {}
	local totalFragments = math.ceil(buffer.len(buf) / MTU_SIZE)

	for i = 0, totalFragments - 1 do
		local start = i * MTU_SIZE + 1
		local stop = math.min((i + 1) * MTU_SIZE, buffer.len(buf))
		local chunk = string.sub(buf, start, stop)

		table.insert(fragments, {
			fragment = true,
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

	if not self.FragmentBuffer[msgId] then
		self.FragmentBuffer[msgId] = {
			fragments = {},
			totalFragments = fragmentData.totalFragments,
			received = 0,
		}
	end

	local buffer = self.FragmentBuffer[msgId]

	if not buffer.fragments[fragmentData.fragmentIndex] then
		buffer.fragments[fragmentData.fragmentIndex] = fragmentData.data
		buffer.received = buffer.received + 1
	end

	if buffer.received == buffer.totalFragments then
		local completeData = ""
		for i = 0, buffer.totalFragments - 1 do
			completeData = completeData .. buffer.fragments[i]
		end

		self.FragmentBuffer[msgId] = nil

		return Serializer.Deserialize(completeData)
	end

	return nil
end

function Client:SendReliable(data)
	local messageId = `reliable_{self.MessageSequence}`
	data.messageId = messageId
	data.reliable = true
	data.timestamp = os.time()

	local fragments = self:FragmentMessage(data, messageId)

	self.PendingAcks[messageId] = {
		fragments = fragments,
		attempts = 0,
		lastSent = os.clock(),
	}

	for _, fragment in ipairs(fragments) do
		self:SendRaw(fragment)
	end
end

function Client:SendRaw(data)
	if not self:CheckRateLimit() then
		warn("Rate limit exceeded")
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
		warn("Message too large")
		return
	end

	self.Socket:sendMsg(self.ServerPort, self.ServerAddress, buf)
end

function Client:ProcessReliableQueue()
	task.spawn(function()
		while true do
			task.wait(0.1)

			local currentTime = os.clock()

			for msgId, ackData in pairs(self.PendingAcks) do
				if currentTime - ackData.lastSent > ACK_TIMEOUT then
					if ackData.attempts >= MAX_RETRIES then
						warn(`Message {msgId} failed after {MAX_RETRIES} retries`)
						self.PendingAcks[msgId] = nil
					else
						ackData.attempts = ackData.attempts + 1
						ackData.lastSent = currentTime

						for _, fragment in ipairs(ackData.fragments) do
							self:SendRaw(fragment)
						end
					end
				end
			end
		end
	end)
end

function Client:OnShutdown(v)
	Client._OnShutdown = v
end

function Client:Connect()
	log(`Connecting to server at {self.ServerAddress}:{self.ServerPort}`)
	Client:Send({
		type = "CONNECT",
		authToken = self.AuthToken,
	})
end

function Client:OnRecieve(callback)
	table.insert(onRecieveConnections, callback)
end

function Client:Disconnect()
	log(`Disconnecting from server at {self.ServerAddress}:{self.ServerPort}`)

	if self.IsAuthenticated then
		Client:Send({
			type = "DISCONNECT",
			sessionId = self.SessionId,
		})
	end

	self.Socket:close()
	self.IsAuthenticated = false
	self.SessionId = nil

	if Client._OnShutdown then
		Client._OnShutdown()
	end
end

function Client:Send(data, reliable)
	assert(self.Socket, "Socket not initialized, call :Init() first")

	if reliable then
		self:SendReliable(data)
	else
		self:SendRaw(data)
	end
end

function Client._middleware(v, addr)
	if type(v) == "table" then
		if v.type == "ACK" then
			if self.PendingAcks[v.messageId] then
				self.PendingAcks[v.messageId] = nil
			end
			return
		end

		if v.type == "AUTH_SUCCESS" then
			Client.IsAuthenticated = true
			Client.SessionId = v.sessionId
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
	task.spawn(function()
		while true do
			task.wait(HEARTBEAT_INTERVAL)
			if Client.IsAuthenticated then
				Client:Send({
					type = "HEARTBEAT",
				})
			end
		end
	end)
end

function Client:Listen()
	self:ProcessReliableQueue()

	task.spawn(function()
		while true do
			local success, addr, data = pcall(function()
				return self.Socket:recvMsg(MAX_MESSAGE_SIZE)
			end)

			if not success then
				task.wait()
				continue
			end

			if data then
				local decoded = Serializer.Deserialize(data)
				if decoded then
					if decoded.fragment then
						if decoded.reliable then
							self:SendRaw({
								type = "ACK",
								messageId = decoded.messageId,
							})
						end

						local reassembled = self:ReassembleFragments(decoded)
						if reassembled then
							decoded = reassembled
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

					Client._middleware(decoded, addr)

					for _, v in pairs(onRecieveConnections) do
						task.spawn(function()
							v(addr, decoded)
						end)
					end
				end
			end
			task.wait()
		end
	end)
end

return Client
