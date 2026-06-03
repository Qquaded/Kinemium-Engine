-- description: "Has a Ray value."
local Ray = require("@Ray")
local Vector3 = require("@Vector3")

local propTable = {
	Value = Ray.new(Vector3.new(), Vector3.new(0,0,1)),
}

return {
	class = "RayValue",
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
