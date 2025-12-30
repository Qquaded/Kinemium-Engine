local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local enet = require("@enet")

local NetworkService = Instance.new("NetworkService")
NetworkService.ExplorerHidden = true

local toptr = zune.ffi.ptrFromAddress

local ENET_EVENT_TYPE_NONE = 0
local ENET_EVENT_TYPE_CONNECT = 1
local ENET_EVENT_TYPE_DISCONNECT = 2
local ENET_EVENT_TYPE_RECEIVE = 3

local task = zune.task

local function init()
	local init = enet.lib.enet_initialize()
	if init ~= 0 then
		error("Failed to initialize ENet, Code " .. init)
	end
end

init()
print("ENet initialized")

NetworkService.InitRenderer = function(renderer, renderer_signal, datamodel)
	NetworkService:SetProperties({
		Success = true,
		IsClientConnected = false,
	})

	function NetworkService:StartServer(port: number, maxPeers: number, channels: number)
		local address = enet.structs.ENetAddress:new({})
		buffer.writeu32(address, 0, 0) -- host = ENET_HOST_ANY
		buffer.writeu16(address, 4, port or 7777) -- port

		local server = enet.lib.enet_host_create(address, maxPeers or 32, channels or 2, 0, 0)
		assert(server ~= nil, "Failed to create ENet host")

		log("Started Kinemium Server on port " .. port)
		log(server)
		log(address)

		self.ServerHost = server
		return server
	end

	function NetworkService:StartClient(serverIP: string, port: number)
		local client = enet.lib.enet_host_create(nil, 1, 2, 0, 0)
		assert(client ~= nil, "Failed to initiate connection")

		local address = enet.structs.ENetAddress:new({
			host = nil,
			port = port or 7777,
		})

		enet.lib.enet_address_set_host_new(address, serverIP)

		-- enet_host_connect(client, &address, 2, 0);
		local peer = enet.lib.enet_host_connect(client, address, 2, 0)
		assert(peer ~= nil, "Failed to connect to server")

		local event = enet.structs.ENetEvent:new({})

		log("Peer")
		log(peer)

		log("Event")
		log(event)

		-- wait for client to load... (yes 5 seconds)
		task.wait(5)

		-- (enet_host_service(client, &event, 5000) > 0 &&
		local serviced = enet.lib.enet_host_service(client, event, 5000)
		print(serviced)
		if serviced > 0 then
			log("Client: Connected to server: " .. serverIP .. ":" .. port)
			NetworkService.IsClientConnected = true
		else
			log("Client: Failed to connect to server: " .. serverIP .. ":" .. port)
			NetworkService.IsClientConnected = false
		end

		log("Serviced")
		log(serviced)

		self.ClientHost = client
		self.ClientPeer = peer
		return client, peer
	end

	function NetworkService:Service(timeout)
		timeout = timeout or 0 -- milliseconds
		local event = enet.structs.ENetEvent:new({})

		-- comment for now until i come back to this
		-- please somebody help..
		--[[
		if self.ServerHost then
			while enet.lib.enet_host_service(self.ServerHost, event, timeout) > 0 do
				local etype = tonumber(event.type)
				if etype == ENET_EVENT_TYPE_CONNECT then
					print("Server: Client connected")
				elseif etype == ENET_EVENT_TYPE_RECEIVE then
					print("Server: Received packet")
					enet.lib.enet_packet_destroy(event.packet)
				elseif etype == ENET_EVENT_TYPE_DISCONNECT then
					print("Server: Client disconnected")
				end
			end
		end

		if self.ClientHost and self.IsClientConnected then
			while enet.lib.enet_host_service(self.ClientHost, event, timeout) > 0 do
				local etype = tonumber(event.type)
				if etype == ENET_EVENT_TYPE_CONNECT then
					print("Client: Connected to server")
				elseif etype == ENET_EVENT_TYPE_RECEIVE then
					print("Client: Received packet")
					enet.lib.enet_packet_destroy(event.packet)
				elseif etype == ENET_EVENT_TYPE_DISCONNECT then
					print("Client: Disconnected from server")
				end
			end
		end
		--]]
	end

	--[[
	if IsServer then
		log("Starting server..")
		NetworkService:StartServer(6767)
	elseif IsClient then
		log("Starting client..")
		NetworkService:StartClient("127.0.0.1", 6767)
	else
		log("Starting both server and client (for testing)..")
		NetworkService:StartServer(6767)
		NetworkService:StartClient("127.0.0.1", 6767)
	end

	renderer_signal:Connect(function(state)
		if state == "RenderStepped" then
			NetworkService:Service()
		end
	end)
	--]]
end

return NetworkService
