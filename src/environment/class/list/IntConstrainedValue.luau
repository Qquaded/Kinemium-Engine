-- description: "Has a configurable Int Constrained Value."
local propTable = {
	Name = "IntConstrainedValue",
	Value = 0,
	MaxValue = 10,
	MinValue = 0,
}

return {
	class = "IntConstrainedValue",

	callback = function(instance)
		instance:SetProperties(propTable)
		instance.Changed:Connect(function(property)
			if property == "Value" then
				local val = math.floor(instance.Value)
				local min = instance.MinValue
				local max = instance.MaxValue
				if val < min then
					val = min
				elseif val > max then
					val = max
				end
				if val ~= instance.Value then
					instance.Value = val
				end
			end
		end)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
