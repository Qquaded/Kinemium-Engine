-- description: "Represents a Smoke in the environment."
local Color3 = require("@Color3")

local propTable = {
	Color = Color3.new(1, 1, 1),
	Enabled = true,
	LocalTransparencyModifier = 0,
	Opacity = 0,
	RiseVelocity = 0,
	Size = 0,
	TimeScale = 1,
	Name = "Smoke",
	BaseClass = "Instance",
}

return {
	class = "Smoke",

	-- description: "Initializes the Smoke instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the Smoke class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
