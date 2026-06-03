-- description: "Applies snapping behavior to an object, and is Deprecated."
local propTable = {
	Name = "Snap",
}

return {
	class = "Snap",

	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
