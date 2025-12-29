local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

local propTable = {
	Position = Vector3.new(0, 0, 0),
	Orientation = Vector3.new(0, 0, 0),
	Rotation = Vector3.new(0, 0, 0),
	CFrame = CFrame.new(0, 0, 0),
	Axis = Vector3.new(1, 0, 0),
	SecondaryAxis = Vector3.new(0, 1, 0),
	Visible = true,
	WorldPosition = Vector3.new(0, 0, 0),
	WorldOrientation = Vector3.new(0, 0, 0),
	WorldRotation = Vector3.new(0, 0, 0),
	WorldCFrame = CFrame.new(0, 0, 0),
	WorldAxis = Vector3.new(1, 0, 0),
	WorldSecondaryAxis = Vector3.new(0, 1, 0),
	Name = "Attachment",
	ElapsedTime = 0,
}

return {
	class = "Attachment",

	callback = function(instance)
		propTable.render = function(part, camera, lib) end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
