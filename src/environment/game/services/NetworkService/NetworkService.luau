local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local NetworkService = Instance.new("NetworkService")

local gns = require("@gns")

NetworkService.InitRenderer = function(renderer, renderer_signal, datamodel)
	if IsHeadless == true then
		return
	end

	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true

		local KinemiumServer = require("@KinemiumServer")
		local KinemiumClient = require("@KinemiumClient")
		local address, port = GetFlagValue("address") or "127.0.0.1", GetFlagValue("port") or 1234

		if FlagExists("server") and not FlagExists("headless") then
			KinemiumServer = require("@KinemiumStudioServer")

			if address and port then
				print("Init studio server")
				KinemiumServer:Init(address, port, datamodel)
			end
		end

		if not FlagExists("headless") and not FlagExists("server") then
			KinemiumClient = require("@KinemiumStudioClient")

			if address and port then
				KinemiumClient:Init(address, port, datamodel)
			end
		end

		if FlagExists("server") then
			KinemiumServer:Init(address, port, datamodel)
		elseif FlagExists("client") then
			KinemiumClient:Init(address, port, datamodel)
		end

		NetworkService:SetProperties({})

		function NetworkService:InitStudioServer(address, port)
			KinemiumServer = require("@KinemiumStudioServer")
			KinemiumServer:Init(address, port, datamodel)
		end

		function NetworkService:InitStudioClient(address, port)
			KinemiumClient = require("@KinemiumStudioClient")
			KinemiumClient:Init(address, port, datamodel)
		end
	end)
end

return NetworkService
