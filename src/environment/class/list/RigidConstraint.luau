-- description: "Represents a RigidConstraint in the environment."
local propTable = {
	Name = "RigidConstraint",
	BaseClass = "Kinemium.constraint",

	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = false,
}

return {
	class = "RigidConstraint",
	-- description: "Initializes the RigidConstraint instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the RigidConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
