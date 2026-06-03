local net = zune.net
local platform = zune.platform

local Serializer = require("./Serializer")

local TCPServer = {}

TCPServer.ConnectedClients = {}
local onRecieveCallbacks = {}

local HEARTBEAT_TIMEOUT = 15
local MAX_MESSAGE_SIZE = 4 * 1024 * 1024
local MESSAGE_TIMEOUT = 10
local MAX_CLIENTS = 130
local MAX_MESSAGES_PER_CLIENT = 100
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

local function clientKey(client)
	return client.address .. ":" .. client.port
end

function TCPServer:Init(address, port, allowedTokens)
	local socket = net.createSocket(
		net.ADDRF.INET,
		bit32.bor(net.SOCKF.STREAM, if platform.os == "windows" then 0 else net.SOCKF.CLOEXEC),
		net.IPPROTO.TCP
	)

	address = address or "0.0.0.0"
	port = port or 1234

	socket:bindIp(address, port)
	socket:listen(128)

	TCPServer.Socket = socket
	TCPServer.Address = address
	TCPServer.Port = port
	TCPServer.AllowedTokens = allowedTokens or {}
	TCPServer.SessionCounter = 0
	TCPServer.BannedAddresses = {}
	TCPServer.MessageSequence = 0
	TCPServer._running = true

	log(`[TCPServer] Listening at {address}:{port}`)

	return socket
end

function TCPServer:GenerateSessionId()
	TCPServer.SessionCounter = TCPServer.SessionCounter + 1
	return `session_{TCPServer.SessionCounter}_{os.time()}`
end

function TCPServer:ValidateAuthToken(token)
	if #TCPServer.AllowedTokens == 0 then
		return true
	end

	for _, allowedToken in ipairs(TCPServer.AllowedTokens) do
		if token == allowedToken then
			return true
		end
	end

	return false
end

function TCPServer:OnClientConnectionRequest(callback)
	TCPServer._onClientConnectionRequest = callback
end

function TCPServer:ValidateMessage(data, client)
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
		if not client.lastSequence then
			client.lastSequence = data.sequence
		elseif data.sequence <= client.lastSequence then
			return false, "Invalid sequence"
		else
			client.lastSequence = data.sequence
		end
	end

	if data.sessionId and data.sessionId ~= client.sessionId then
		return false, "Invalid session"
	end

	return true
end

function TCPServer:CheckRateLimit(client)
	local currentTime = os.time()

	local ring = client.rateLimitRing
	if not ring then
		ring = table.create(MAX_MESSAGES_PER_CLIENT, 0)
		client.rateLimitRing = ring
		client.rateLimitIndex = 0
		client.rateLimitCount = 0
	end

	local idx = client.rateLimitIndex

	if client.rateLimitCount >= MAX_MESSAGES_PER_CLIENT then
		local oldest = ring[idx + 1]
		if oldest and currentTime - oldest < 1 then
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

function TCPServer:IsBanned(address)
	return TCPServer.BannedAddresses[address] ~= nil
end

function TCPServer:BanClient(address, reason)
	TCPServer.BannedAddresses[address] = {
		reason = reason or "Violation",
		timestamp = os.time(),
	}
	log(`[TCPServer] Banned client {address}: {reason}`)
end

function TCPServer:OnRecieve(callback)
	table.insert(onRecieveCallbacks, callback)
end

function TCPServer:OnNewClient(callback)
	self._onNewClient = callback
end

function TCPServer:OnClientRemoved(callback)
	self._onClientRemoved = callback
end

function TCPServer:SendRaw(client, data)
	data.timestamp = os.time()
	data.sessionId = client.sessionId

	local buf = Serializer.Serialize(data)

	if buffer.len(buf) > MAX_MESSAGE_SIZE then
		warn(`[TCPServer] Message too large: {buffer.len(buf)} bytes`)
		return
	end

	local ok, err = pcall(writeFramed, client.socket, buf)
	if not ok then
		warn(`[TCPServer] Send to {clientKey(client)} failed: {err}`)
	end
end

function TCPServer:SendReliable(client, data)
	local messageId = `reliable_{TCPServer.MessageSequence}_{clientKey(client)}`
	TCPServer.MessageSequence = TCPServer.MessageSequence + 1

	data.messageId = messageId
	data.reliable = true
	data.timestamp = os.time()

	if not client.pendingAcks then
		client.pendingAcks = {}
	end

	client.pendingAcks[messageId] = {
		data = data,
		attempts = 0,
		lastSent = os.clock(),
	}

	self:SendRaw(client, data)
end

function TCPServer:Send(client, data, reliable)
	if reliable then
		self:SendReliable(client, data)
	else
		self:SendRaw(client, data)
	end
end

function TCPServer:SendAll(data, reliable)
	local success, err = pcall(function()
		for key, client in pairs(TCPServer.ConnectedClients) do
			if client.authenticated then
				local sendSuccess, sendErr = pcall(function()
					self:Send(client, data, reliable)
				end)
				if not sendSuccess then
					warn(`[TCPServer] Failed to send to {key}: {sendErr}`)
				end
			end
		end
	end)

	if not success then
		warn(`[TCPServer] SendAll error: {err}`)
	end
end

function TCPServer:Shutdown()
	log(`[TCPServer] Shutting down server at {self.Address}:{self.Port}`)
	self._running = false
	if not self.Socket then
		return
	end
	TCPServer:SendAll({ type = "SHUTDOWN" })

	for key, client in pairs(TCPServer.ConnectedClients) do
		pcall(function()
			client.socket:close()
		end)
	end
	TCPServer.ConnectedClients = {}

	pcall(function()
		self.Socket:close()
	end)
end

function TCPServer:AuthenticateClient(key, clientSocket, authToken)
	if not self:ValidateAuthToken(authToken) then
		pcall(function()
			self:SendRaw({
				socket = clientSocket,
				sessionId = nil,
				address = key,
				port = 0,
			}, {
				type = "AUTH_FAILED",
				reason = "Invalid token",
			})
		end)
		return false
	end

	local sessionId = self:GenerateSessionId()

	TCPServer.ConnectedClients[key] = {
		socket = clientSocket,
		address = key,
		port = 0,
		sessionId = sessionId,
		authenticated = true,
		connectedAt = os.time(),
		lastHeartbeat = os.time(),
		lastSequence = nil,
		rateLimitWindow = {},
		pendingAcks = {},
	}

	self:SendRaw(TCPServer.ConnectedClients[key], {
		type = "AUTH_SUCCESS",
		sessionId = sessionId,
	})

	log(`[TCPServer] Client ({key}) authenticated with session: {sessionId}`)

	if TCPServer._onNewClient then
		TCPServer._onNewClient({ address = key, port = 0 })
	end

	return true, TCPServer.ConnectedClients[key]
end

function TCPServer._middleware(v, key)
	local client = TCPServer.ConnectedClients[key]

	if type(v) == "table" then
		if v.type == "ACK" then
			if client and client.pendingAcks and client.pendingAcks[v.messageId] then
				client.pendingAcks[v.messageId] = nil
			end
			return
		end

		if v.type == "CONNECT" then
			-- handled in listen loop
			return
		end

		if not client or not client.authenticated then
			warn(`[TCPServer] Unauthenticated message from {key}`)
			return
		end

		if not TCPServer:CheckRateLimit(client) then
			warn(`[TCPServer] Rate limit exceeded for {key}`)
			TCPServer:BanClient(key, "Rate limit exceeded")
			TCPServer:SendRaw(client, { type = "DISCONNECT", reason = "Rate limit" })
			pcall(function()
				client.socket:close()
			end)
			TCPServer.ConnectedClients[key] = nil
			return
		end

		local valid, err = TCPServer:ValidateMessage(v, client)
		if not valid then
			warn(`[TCPServer] Invalid message from {key}: {err}`)
			return
		end

		if v.type == "DISCONNECT" then
			pcall(function()
				client.socket:close()
			end)
			TCPServer.ConnectedClients[key] = nil
			log(`[TCPServer] Client ({key}) disconnected`)

			if TCPServer._onClientRemoved then
				TCPServer._onClientRemoved({ address = key, port = 0 })
			end
		end

		if v.type == "HEARTBEAT" then
			client.lastHeartbeat = os.time()
		end
	end
end

function TCPServer:StartHeartbeatMonitor()
	task.spawn(function()
		while self._running do
			task.wait(HEARTBEAT_TIMEOUT / 2)

			local currentTime = os.time()
			for key, client in pairs(TCPServer.ConnectedClients) do
				if client.authenticated then
					if currentTime - client.lastHeartbeat > HEARTBEAT_TIMEOUT then
						log(`[TCPServer] Client {key} timed out`)
						TCPServer:SendRaw(client, { type = "DISCONNECT", reason = "Timeout" })
						pcall(function()
							client.socket:close()
						end)
						TCPServer.ConnectedClients[key] = nil

						if TCPServer._onClientRemoved then
							TCPServer._onClientRemoved({ address = key, port = 0 })
						end
					end
				end
			end
		end
	end)
end

function TCPServer:ProcessReliableQueue()
	task.spawn(function()
		while self._running do
			task.wait(0.1)

			local currentTime = os.clock()

			for key, client in pairs(TCPServer.ConnectedClients) do
				if client.authenticated and client.pendingAcks then
					for msgId, ackData in pairs(client.pendingAcks) do
						if currentTime - ackData.lastSent > ACK_TIMEOUT then
							if ackData.attempts >= MAX_RETRIES then
								warn(`[TCPServer] Message {msgId} to {key} failed after {MAX_RETRIES} retries`)
								client.pendingAcks[msgId] = nil
							else
								ackData.attempts = ackData.attempts + 1
								ackData.lastSent = currentTime

								self:SendRaw(client, ackData.data)
							end
						end
					end
				end
			end
		end
	end)
end

local function handleClientConnection(self, clientSocket, addr)
	local key = tostring(addr)
	log(`[TCPServer] New TCP connection from {key}`)

	if self:IsBanned(key) then
		warn(`[TCPServer] Rejected banned client {key}`)
		pcall(function()
			clientSocket:close()
		end)
		return
	end

	-- Client read loop
	while self._running do
		local success, data = pcall(readFramed, clientSocket)

		if not success then
			log(`[TCPServer] Client {key} connection error: {data}`)
			break
		end

		if not data then
			log(`[TCPServer] Client {key} disconnected (EOF)`)
			break
		end

		local decoded = Serializer.Deserialize(data)
		if decoded then
			-- Handle CONNECT before middleware (needs special handling for TCP)
			if type(decoded) == "table" and decoded.type == "CONNECT" then
				local count = 0
				for _ in pairs(TCPServer.ConnectedClients) do
					count += 1
				end

				if count >= MAX_CLIENTS then
					warn(`[TCPServer] Max clients reached, rejecting {key}`)
					pcall(function()
						clientSocket:close()
					end)
					return
				end

				-- Store socket temporarily for auth
				local authSuccess, client = self:AuthenticateClient(key, clientSocket, decoded.authToken)
				if authSuccess and client then
					if TCPServer._onClientConnectionRequest then
						TCPServer._onClientConnectionRequest(client, decoded.arguments)
					end
				end
				continue
			end

			local client = TCPServer.ConnectedClients[key]

			if decoded.reliable and client then
				self:SendRaw(client, {
					type = "ACK",
					messageId = decoded.messageId,
				})
			end

			TCPServer._middleware(decoded, key)

			-- Re-fetch client in case middleware removed it
			client = TCPServer.ConnectedClients[key]

			if client and client.authenticated then
				for _, v in pairs(onRecieveCallbacks) do
					zune.task.spawn(function()
						v({ address = key, port = 0 }, decoded)
					end)
				end
			end
		end
		task.wait()
	end

	-- Cleanup on disconnect
	if TCPServer.ConnectedClients[key] then
		TCPServer.ConnectedClients[key] = nil
		log(`[TCPServer] Client {key} cleaned up`)

		if TCPServer._onClientRemoved then
			TCPServer._onClientRemoved({ address = key, port = 0 })
		end
	end
	pcall(function()
		clientSocket:close()
	end)
end

function TCPServer:Listen()
	assert(self.Socket, "[TCPServer] Socket not created, call :Init() first")

	self:StartHeartbeatMonitor()
	self:ProcessReliableQueue()

	task.spawn(function()
		while self._running do
			local ok, clientSocket = pcall(function()
				return self.Socket:accept()
			end)

			if ok and clientSocket then
				task.spawn(handleClientConnection, self, clientSocket, tostring(clientSocket))
			else
				task.wait()
			end
		end
	end)
end

return TCPServer
