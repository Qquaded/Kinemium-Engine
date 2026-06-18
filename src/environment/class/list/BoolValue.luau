-- description: "Has a Value property which is a Boolean, and is Customizable."
local propTable = {
	Value = false,
}

return {
	class = "BoolValue",
	callback = function(instance)
		instance:SetProperties(propTable)

		-- this was easy real
		instance:SetBarrier("Value", function(new)
			if type(new) ~= "boolean" then
				print("New value isnt a boolean")
				return false
			end
			return true
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
