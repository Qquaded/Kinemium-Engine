-- description: "Allows clients and the server to invoke functions across the network and receive a response."
return {
	class = "RemoteFunction",
	callback = function(instance)
		instance:SetProperties({
			OnClientInvoke = nil,
			OnServerInvoke = nil,
			InvokeTimeout = 10,
			-- InvokeServer and InvokeClient are injected by the networking bridge
		})

		return instance
	end,
}
