-- description: "Deprecated version of HingeConstraint"
local propTable = {
	Name = "Motor6D",
	BaseClass = "Kinemium.weld",

	DesireAngle = 0,
	CurrentAngle = 0,
	MaxVelocity = 0,
}

return {
	class = "Motor6D",
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, like HingeConstraint, this should be the same

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
