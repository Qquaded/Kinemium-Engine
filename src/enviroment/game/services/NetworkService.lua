local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local NetworkService = Instance.new("NetworkService")
NetworkService.ExplorerHidden = true

NetworkService.InitRenderer = function(renderer, renderer_signal)
	NetworkService:SetProperties({})
end

function NetworkService:StartServer(port: number, maxPeers: number, channels: number)
	local enet = require("@enet")

	local address = enet.structs.ENetAddress:new({
		host = nil,
		port = port or 1234,
	})
	address.host = nil -- nil = bind to any host
	address.port = port or 1234

	local host = enet.lib.enet_host_create(
		address,
		maxPeers or 32, -- max number of peers
		channels or 2, -- channels
		0, -- incoming bandwidth (0 = unlimited)
		0 -- outgoing bandwidth (0 = unlimited)
	)

	assert(host ~= nil, "Failed to create ENet host")

	self.ServerHost = host
	return host
end

return NetworkService
