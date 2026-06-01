-- description: "Applies angular velocity to the parent's physics body."
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local propTable = {
	AngularVelocity = Vector3.new(0, 0, 0),
	MaxTorque = 10000,
	ReactionTorqueEnabled = false,
	RelativeTo = Enum.ActuatorRelativeTo.Attachment0,
}

return {
	class = "AngularVelocity",
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
