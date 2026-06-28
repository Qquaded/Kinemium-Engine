-- description: "Has a Value property which is a CFrame value, and is Customizable."
local CFrame = require("@CFrame")

local propTable = {
	Value = CFrame.new(0, 0, 0),
}

return {
	class = "CFrameValue",
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
