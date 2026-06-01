-- description: "An editable mesh body that responds to forces by deforming its shape instead of remaining rigid."
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

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		renderer.EventBus:Fire("UpdateSoftBody", instance)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
