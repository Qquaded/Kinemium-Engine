-- description: "Represents an Animation in the environment."
local propTable = {
	AnimationId = "",
}

return {
	class = "Animation",
	-- description: "Initializes the Animation instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Animation class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
