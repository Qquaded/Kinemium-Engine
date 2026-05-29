-- description: "Represents a NetworkController in the environment."
local propTable = {
	Enabled = true,
	AutoAssignOwnership = true,
	LockOwner = false,
	OwnershipRadius = 96,
	OwnershipReleaseRadius = 144,
	OwnershipTransferCooldown = 1.5,
	OwnershipVelocityThreshold = 0.75,
	OwnershipStealMargin = 16,
	ReplicatePhysics = true,
	ReplicateProperties = true,
	PropertyList = "",
	Name = "NetworkController",
}

return {
	class = "NetworkController",

	-- description: "Initializes the NetworkController instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,

	-- description: "Inherits the properties of the NetworkController class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
