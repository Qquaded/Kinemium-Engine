-- description: "Enables asynchronous communication between the client and server."
local signal = require("@Kinemium.signal")

return {
	class = "RemoteEvent",
	callback = function(instance, renderer, datamodel)
		local OnClientEvent = signal.new()
		local OnServerEvent = signal.new()

		instance:SetProperties({
			OnClientEvent = OnClientEvent,
			OnServerEvent = OnServerEvent,
			-- FireServer, FireClient, FireAllClients are injected by the networking bridge
		})

		return instance
	end,	
}
