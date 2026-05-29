-- description: "Represents a RemoteEvent in the environment."
local signal = require("@Kinemium.signal")

return {
	class = "RemoteEvent",
	-- description: "Initializes the RemoteEvent instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
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
