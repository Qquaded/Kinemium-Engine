-- description: "Has a string value."
local propTable = {
	Value = "",
}

return {
	class = "StringValue",
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
