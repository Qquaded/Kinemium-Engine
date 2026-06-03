-- description: "Has a Data table property that can be changed by the client or the server, and replicate."
local signal = require("@Kinemium.signal")

return {
	class = "RemoteData",
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
