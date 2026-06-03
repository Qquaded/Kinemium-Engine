-- description: "Has a Binary String property."
local propTable = {
	BinaryString = "something binary. Scary!",
}

return {
	class = "BinaryStringValue",
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
