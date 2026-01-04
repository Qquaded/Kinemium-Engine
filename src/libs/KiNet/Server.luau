local net = zune.net
local Server = {}

local Serializer = require("./Serializer")

Server.ConnectedClients = {}
local onRecieveCallbacks = {}

local function clientKey(addr)
	return addr.address .. ":" .. addr.port
end

function Server:Init(address, port)
	-- create server socket
	local socket = net.createSocket(
		net.ADDRF.INET, -- IPv4
		bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC), -- UDP
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

function Server:OnRecieve(callback)
	table.insert(onRecieveCallbacks, callback)
end

function Server:OnNewClient(callback)
	self._onNewClient = callback
end

function Server:OnClientRemoved(callback)
	self._onClientRemoved = callback
end

function Server:SendAll(data)
	for key, client in pairs(Server.ConnectedClients) do
		--print("Sending data to client", key)
		self:Send(client, data)
	end
end

function Server:Shutdown()
	log(`Shutting down server at {self.Address}:{self.Port}`)
	Server:SendAll({ type = "SHUTDOWN" })
	self.Socket:close()
end

function Server:Send(client, data)
	local buf = Serializer.Serialize(data)
	self.Socket:sendMsg(tonumber(client.port), client.address, buf)
end

function Server._middleware(v, addr)
	if type(v) == "table" then
		if v.type == "CONNECT" then
			local key = clientKey(addr)
			Server.ConnectedClients[key] = {
				address = addr.address,
				port = addr.port,
			}
			log(`Client ({key}) connected at {addr.address}`)

			if Server._onNewClient then
				Server._onNewClient(addr)
			end
		end

		-- detect client removed
		if v.type == "DISCONNECT" then
			Server.ConnectedClients[addr] = nil
			log(`Client ({clientKey(addr)}) disconnected at {addr.address}`)

			if Server._onClientRemoved then
				Server._onClientRemoved(addr)
			end
		end
	end
end

function Server:Listen()
	assert(self.Socket, "Socket not created, call :Init() first")

	task.spawn(function()
		while true do
			local addr, data = self.Socket:recvMsg()
			if not data then
				return
			end

			local decoded = Serializer.Deserialize(data)
			if decoded then
				Server._middleware(decoded, addr)

				for _, v in pairs(onRecieveCallbacks) do
					v(addr, decoded)
				end
			end
			task.wait()
		end
	end)
end

return Server
