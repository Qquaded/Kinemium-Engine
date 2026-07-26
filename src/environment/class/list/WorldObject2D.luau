-- description: "A 2d world object."

local CFrame2D = require("@CFrame2D")
local Vector2 = require("@Vector2")

local propTable = {
	CFrame = CFrame2D.new(0, 0),
	Size = Vector2.new(100, 100),
	Visible = true,
	Enabled = true,
}

return {
	class = "WorldObject2D",

	callback = function(instance)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
