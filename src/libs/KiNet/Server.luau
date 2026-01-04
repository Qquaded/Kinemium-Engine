local net = zune.net
local Server = {}

local Serializer = require("./Serializer")

Server.ConnectedClients = {}

function Server:Init(address, port)
	-- create server socket
	local socket = net.createSocket(
		net.ADDRF.INET, -- IPv4
		net.SOCKF.DGRAM, -- UDP
		net.IPPROTO.UDP -- UDP protocol
	)

	address = address or "0.0.0.0"
	port = port or 1234

	socket:bindIp(address, port)
	Server.Socket = socket
	Server.Address = address
	Server.Port = port

	log(`Created server socket at {address}:{port}`)

	return socket
end

function Server:OnMessage(callback)
	self._onMessage = callback
end

function Server:OnNewClient(callback)
	self._onNewClient = callback
end

function Server:OnClientRemoved(callback)
	self._onClientRemoved = callback
end

function Server:Shutdown()
	log(`Shutting down server at {self.Address}:{self.Port}`)
	for client in pairs(Server.ConnectedClients) do
		self:Send(client, { type = "SHUTDOWN" })
	end
	self.Socket:close()
end

function Server:Send(client, data)
	assert(self.Socket, "Socket not created, call :Init() first")
	assert(client, "Client not found")

	local buf = Serializer.Serialize(data)

	self.Socket:sendMsg(client.port, client.address, buf)
end

function Server._middleware(v, addr)
	if type(v) == "table" then
		if v.type == "CONNECT" then
			Server.ConnectedClients[addr] = true
			log(`Client connected at {addr.address}`)

			if Server._onNewClient then
				Server._onNewClient(addr)
			end
		end

		-- detect client removed
		if v.type == "DISCONNECT" then
			Server.ConnectedClients[addr] = nil
			log(`Client disconnected at {addr.address}`)

			if Server._onClientRemoved then
				Server._onClientRemoved(addr)
			end
		end
	end
end

function Server:Service()
	assert(self.Socket, "Socket not created, call :Init() first")

	while true do
		local addr, data = self.Socket:recvMsg()
		if not data then
			break
		end

		if self._onMessage then
			local decoded = Serializer.Deserialize(data)
			if decoded then
				Server._middleware(decoded, addr)
				self._onMessage(addr, decoded)
			end
		end
	end
end

return Server
