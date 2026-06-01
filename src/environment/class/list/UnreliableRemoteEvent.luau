-- description: "A remote event that sends data without guaranteeing delivery."
local signal = require("@Kinemium.signal")

return {
	class = "UnreliableRemoteEvent",
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
