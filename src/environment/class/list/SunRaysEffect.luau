-- description: "Represents a SunRaysEffect in the environment."
local propTable = {
	Name = "SunRaysEffect",
	BaseClass = "Kinemium.posteffect",

	Intensity = 0.25,
	Spread = 0.1,
}

return {
	class = "SunRaysEffect",
	-- description: "Initializes the SunRaysEffect instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the SunRaysEffect class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
