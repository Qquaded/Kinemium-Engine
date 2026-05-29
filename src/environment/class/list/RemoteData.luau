-- description: "Represents a RemoteData in the environment."
local signal = require("@Kinemium.signal")

return {
	class = "RemoteData",
	-- description: "Initializes the RemoteData instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		local dataChanged = signal.new()

		instance:SetProperties({
			Data = nil,
			DataChanged = dataChanged,
		})

		instance:GetPropertyChangedSignal("Data"):Connect(function(value)
			dataChanged:Fire(value)
		end)

		return instance
	end,
}
