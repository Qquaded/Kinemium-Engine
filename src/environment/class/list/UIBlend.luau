-- description: "Represents an UIBlend in the environment."
local propTable = {
	Mode = "Alpha",
	AffectSelf = true,
	AffectChildren = true,
	Enabled = true,
	Name = "UIBlend",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIBlend",
	-- description: "Initializes the UIBlend instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIBlend class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
