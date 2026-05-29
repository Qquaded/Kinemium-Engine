-- description: "Represents a RayValue in the environment."
local Ray = require("@Ray")
local Vector3 = require("@Vector3")

local propTable = {
	Value = Ray.new(Vector3.new(), Vector3.new(0,0,1)),
}

return {
	class = "RayValue",
	-- description: "Initializes the RayValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the RayValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
