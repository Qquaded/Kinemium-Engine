-- description: "Represents a CFrameValue in the environment."
local CFrame = require("@CFrame")

local propTable = {
	Value = CFrame.new(0, 0, 0),
}

return {
	class = "CFrameValue",
	non_creatable = true,
	-- description: "Initializes the CFrameValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the CFrameValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
