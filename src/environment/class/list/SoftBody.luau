-- description: "Represents a SoftBody in the environment."
local signal = require("@Kinemium.signal")

local propTable = {
	Name = "SoftBody",
	BaseClass = "Instance",

	Mesh = nil,
	Pressure = 0.0,
	Stiffness = 1.0,
	BendingStiffness = 0.5,
	LinearDamping = 0.1,
	Friction = 0.5,
	Restitution = 0.1,

	CanCollide = true,
	CollisionGroup = "Default",
	Anchored = false,

	Touched = signal.new(),
}

return {
	class = "SoftBody",

	-- description: "Initializes the SoftBody instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		-- TODO: Softbody handled by UPS

		renderer.EventBus:Fire("UpdateSoftBody", instance)

		return instance
	end,

	-- description: "Inherits the properties of the SoftBody class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
