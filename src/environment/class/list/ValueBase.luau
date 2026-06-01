-- description: "A base class for value-based objects in the environment."
local propTable = {
	Value = nil,
}

return {
	class = "ValueBase",
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
