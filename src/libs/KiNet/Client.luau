local net = zune.net
local Client = {}

local Serializer = require("./Serializer")

local onRecieveConnections = {}

function Client:Init(serverAddress, serverPort)
	local socket = net.createSocket(
		net.ADDRF.INET, -- IPv4
		bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC), -- UDP
		net.IPPROTO.UDP -- UDP protocol
	)

	socket:bindIp("127.0.0.1", 0)

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

function Client:OnRecieve(callback)
	table.insert(onRecieveConnections, callback)
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

function Client:Listen()
	task.spawn(function()
		while true do
			local success, addr, data = pcall(function()
				return self.Socket:recvMsg(100000)
			end)

			if not success then
				task.wait()
				continue
			end

			if data then
				local decoded = Serializer.Deserialize(data)
				if decoded then
					Client._middleware(decoded, addr)

					for _, v in pairs(onRecieveConnections) do
						v(addr, decoded)
					end
				end
			end
			task.wait()
		end
	end)
end

return Client
