-- description: "Has an Object value."
local propTable = {
	Value = nil,
}

return {
	class = "ObjectValue",

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
