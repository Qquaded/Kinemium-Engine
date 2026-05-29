-- description: "Represents an UIAspectRatioConstraint in the environment."
local propTable = {
	Name = "UIAspectRatioConstraint",
	BaseClass = "Kinemium.uimodifier",

	AspectRatio = 1,
	AspectType = 1,
	DominantAxis = 1,
}

return {
	class = "UIAspectRatioConstraint",
	-- description: "Initializes the UIAspectRatioConstraint instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, same as other ui layout items

		return instance
	end,
	-- description: "Inherits the properties of the UIAspectRatioConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
