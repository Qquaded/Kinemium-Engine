-- description: "Represents a DoubleConstrainedValue in the environment."
local propTable = {
	ConstrainedValue = 0,
	MaxValue = 10,
	MinValue = 0,
	Value = 0,
}

return {
	class = "DoubleConstrainedValue",
	-- description: "Initializes the DoubleConstrainedValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		instance.Changed:Connect(function(property)
			if property == "Value" then
				local val = instance.Value
				local min = instance.MinValue
				local max = instance.MaxValue
				if val < min then
					instance.Value = min
				elseif val > max then
					instance.Value = max
				end
			end
		end)
		return instance
	end,
	-- description: "Inherits the properties of the DoubleConstrainedValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
