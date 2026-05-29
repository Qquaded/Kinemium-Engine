-- description: "Represents a PathfindingModifier in the environment."
local propTable = {
	Name = "PathfindingModifier",
	BaseClass = "Kinemium.instance",

	Label = "",
	PassThrough = false,
}

return {
	class = "PathfindingModifier",
	-- description: "Initializes the PathfindingModifier instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the PathfindingModifier class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
