-- description: "A constraint that maintains a specific aspect ratio for a UI element."
local propTable = {
	Name = "UIAspectRatioConstraint",
	BaseClass = "Kinemium.uimodifier",

	AspectRatio = 1,
	AspectType = 1,
	DominantAxis = 1,
}

return {
	class = "UIAspectRatioConstraint",
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, same as other ui layout items

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
