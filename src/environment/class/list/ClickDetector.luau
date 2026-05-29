-- description: "Represents a ClickDetector in the environment."
local signal = require("@Kinemium.signal")

local propTable = {
	CursorIcon = "",
	CursorIconContent = "",
	MaxActivationDistance = 32,
}

return {
	class = "ClickDetector",

	-- description: "Initializes the ClickDetector instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality

		instance.MouseClick = signal.new()
		instance.MouseHoverEnter = signal.new()
		instance.MouseHoverLeave = signal.new()
		instance.RightMouseClick = signal.new()

		return instance
	end,

	-- description: "Inherits the properties of the ClickDetector class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
