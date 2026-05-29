-- description: "Represents a RemoteFunction in the environment."
return {
	class = "RemoteFunction",
	-- description: "Initializes the RemoteFunction instance."
	-- args: "instance: table"
	-- returns: "table"
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
