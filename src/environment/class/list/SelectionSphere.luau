-- description: "Represents a SelectionSphere in the environment."
local Color3 = require("@Color3")

local propTable = {
	Adornee = nil,
	Color3 = Color3.new(0.0666667, 0.611765, 0.941176),
	SurfaceColor3 = Color3.new(0.0666667, 0.611765, 0.941176),
	SurfaceTransparency = 1,
	Transparency = 0,
	Visible = true,
	Name = "SelectionSphere",
}

return {
	class = "SelectionSphere",

	-- description: "Initializes the SelectionSphere instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,

	-- description: "Inherits the properties of the SelectionSphere class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
