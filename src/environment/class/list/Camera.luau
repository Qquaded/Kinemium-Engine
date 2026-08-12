-- description: "Defines the position, orientation, and rendering settings used to view the world."

local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local Vector2 = require("@Vector2")

_G.SecurityCapabilities = Enum.SecurityCapabilities.Internals

local propTable = {
	FieldOfView = 70,
	CFrame = CFrame.new(Vector3.new(3, 3, 3), Vector3.new(0, 0, 0)),
	Roll = 0, -- degrees
	Name = "Camera",
	CameraType = Enum.CameraType.Scriptable,
	CameraSubject = nil,
	Focus = CFrame.new(0, 0, 0),
}

local cameraSingleton = nil

return {
	class = "Camera",
	singleton = true,
	callback = function(instance, renderer)
		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
