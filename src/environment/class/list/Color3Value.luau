-- description: "Has a Value property which is a Color3."
local Color3 = require("@Color3")

local propTable = {
	Value = Color3.new(0, 0, 0),
}

return {
	class = "Color3Value",
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
