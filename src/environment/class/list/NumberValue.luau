-- description: "Has a number value."
local propTable = {
	Value = 0,
}

return {
	class = "NumberValue",

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
