-- description: "A modifier class that scales the size of a GUI element."
local propTable = {
	Name = "UIScale",
	BaseClass = "Kinemium.uimodifier",

	Scale = 1,
}

return {
	class = "UIScale",
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
