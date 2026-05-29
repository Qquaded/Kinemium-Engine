-- description: "Represents an AngularVelocity in the environment."
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
	-- description: "Initializes the AngularVelocity instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the AngularVelocity class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
