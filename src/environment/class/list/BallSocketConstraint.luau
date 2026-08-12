-- description: "Creates a ball-and-socket joint between two attachments."
local _Vector3 = require("@Vector3")
local _signal = require("@Kinemium.signal")
local Color3 = require("@Color3")

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(255, 255, 0),
	Radius = 0.1,
	Name = "BallSocketConstraint",
}

return {
	class = "BallSocketConstraint",

	callback = function(instance, renderer, datamodel) end,
}
