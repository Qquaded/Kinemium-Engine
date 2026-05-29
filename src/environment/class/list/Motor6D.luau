-- description: "Represents a Motor6D in the environment."
local propTable = {
	Name = "Motor6D",
	BaseClass = "Kinemium.weld",

	DesireAngle = 0,
	CurrentAngle = 0,
	MaxVelocity = 0,
}

return {
	class = "Motor6D",
	-- description: "Initializes the Motor6D instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, like HingeConstraint, this should be the same

		return instance
	end,
	-- description: "Inherits the properties of the Motor6D class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
