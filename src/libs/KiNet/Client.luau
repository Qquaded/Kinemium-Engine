local net = zune.net
local Client = {}

local Serializer = require("./Serializer")

function Client:Init(serverAddress, serverPort)
	local socket = net.createSocket(
		net.ADDRF.INET, -- IPv4
		net.SOCKF.DGRAM, -- UDP
		net.IPPROTO.UDP -- UDP protocol
	)

	socket:bindIp("0.0.0.0", 0)

	self.Socket = socket
	self.ServerAddress = serverAddress or "0.0.0.0"
	self.ServerPort = serverPort or 1234

	print(`Created client socket!`)
	return socket
end

function Client:OnShutdown(v)
	Client._OnShutdown = v
end

function Client:Connect()
	log(`Connecting to server at {self.ServerAddress}:{self.ServerPort}`)
	Client:Send({
		type = `CONNECT`,
	})
end

function Client:Disconnect()
	log(`Disconnecting from server at {self.ServerAddress}:{self.ServerPort}`)
	self.Socket:close()
	if Client._OnShutdown then
		Client._OnShutdown()
	end
end

function Client:Send(data)
	assert(self.Socket, "Socket not initialized, call :Init() first")
	local buf = Serializer.Serialize(data)
	self.Socket:sendMsg(self.ServerPort, self.ServerAddress, buf)
end

function Client._middleware(v, addr)
	if type(v) == "string" then
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

function Client:Service(callback)
	assert(self.Socket, "Socket not initialized, call :Init() first")
	local addr, data = self.Socket:recvMsg()
	if data and callback then
		local decoded = Serializer.Deserialize(data)
		if decoded then
			callback(addr, decoded)
		end
	end
end

return Client
