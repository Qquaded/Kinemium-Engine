-- description: "Detects user clicks on a 3D object."
local signal = require("@Kinemium.signal")

local propTable = {
	CursorIcon = "",
	CursorIconContent = "",
	MaxActivationDistance = 32,
}

return {
	class = "ClickDetector",
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality

		instance.MouseClick = signal.new()
		instance.MouseHoverEnter = signal.new()
		instance.MouseHoverLeave = signal.new()
		instance.RightMouseClick = signal.new()

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
