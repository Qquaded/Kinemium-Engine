-- description: "Represents an Atmosphere in the environment."
local Color3 = require("@Color3")

local propTable = {
	Name = "Atmosphere",
	BaseClass = "Kinemium.posteffect",

	Density = 0.3,
	Offset = 0,
	Color = Color3.new(0.5, 0.5, 0.5),
	Decay = Color3.new(0.5, 0.5, 0.5),
	Glare = 0,
	Haze = 0,
}

return {
	class = "Atmosphere",
	-- description: "Initializes the Atmosphere instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Atmosphere class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
