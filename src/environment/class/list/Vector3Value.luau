-- description: "A value object that stores a 3D vector."
local Vector3 = require("@Vector3")

local propTable = {
	Value = Vector3.new(0, 0, 0),
}

return {
	class = "Vector3Value",
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
