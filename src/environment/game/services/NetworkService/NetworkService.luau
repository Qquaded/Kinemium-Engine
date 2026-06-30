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

		if FlagExists("server") then
			local address, port = GetFlagValue("address") or "127.0.0.1", GetFlagValue("port") or 1234

			KinemiumServer:Init(address, port, datamodel)
		elseif FlagExists("client") then
			local address, port = GetFlagValue("address") or "127.0.0.1", GetFlagValue("port") or 1234

			KinemiumClient:Init(address, port, datamodel)
		end

		NetworkService:SetProperties({})
	end)
end

return NetworkService
