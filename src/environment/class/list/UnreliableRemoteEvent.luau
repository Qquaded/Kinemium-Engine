-- description: "Represents an UnreliableRemoteEvent in the environment."
local signal = require("@Kinemium.signal")

return {
	class = "UnreliableRemoteEvent",
	-- description: "Initializes the UnreliableRemoteEvent instance."
	-- args: "instance: table, properties: table"
	-- returns: "table"
	callback = function(instance, properties)
		local clientEvent = signal.new()
		local serverEvent = signal.new()

		instance:SetProperties({
			OnClientEvent = clientEvent,
			OnServerEvent = serverEvent,
		})

		return instance
	end,
}
