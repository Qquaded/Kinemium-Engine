local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local KiNet = require("@KiNet")

local NetworkService = Instance.new("NetworkService")
NetworkService.ExplorerHidden = true

local task = zune.task

NetworkService.InitRenderer = function(renderer, renderer_signal, datamodel)
	NetworkService:SetProperties({
		Success = true,
		IsClientConnected = false,
		KiNet = KiNet,
	})

	function NetworkService:StartServer(address, port)
		KiNet.Server:Init(address, port)
	end

	function NetworkService:StartClient(address, port)
		KiNet.Client:Init(address, port)
		--KiNet.Client:Init("127.0.0.1", 1234)
	end

	function NetworkService:Service(timeout) end

	if IsServer then
		local port = tonumber(GetFlagValue("port"))
		local address = GetFlagValue("address")
		if port and address then
			log(`Starting server at {address}:{port}`)
			NetworkService:StartServer(address, port)
		end
	elseif IsClient then
		local port = tonumber(GetFlagValue("port"))
		local address = GetFlagValue("address")
		if port and address then
			log(`Starting client at {address}:{port}`)
			NetworkService:StartClient(address, port)
			KiNet.Client:Connect()
		end
	elseif FlagExists("live") then
		log(`Starting live client and server at 127.0.0.1:1234`)
		NetworkService:StartServer()
		NetworkService:StartClient("127.0.0.1", 1234)
		KiNet.Client:Connect()
	end

	KiNet.Server:OnMessage(function(address, message)
		log(address, message)
	end)

	renderer_signal:Connect(function(route)
		if route == "RenderStepped" then
			if KiNet.Server.Socket then
				KiNet.Server:Service()
			end
			if KiNet.Client.Socket then
				KiNet.Client:Service()
			end
		end
	end)

	table.insert(datamodel.ShutdownCallbacks, function()
		if KiNet.Client then
			KiNet.Client:Disconnect()
		end
		if KiNet.Server then
			KiNet.Server:Shutdown()
		end
	end)
end

return NetworkService
