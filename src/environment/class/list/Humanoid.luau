-- description: "Main character controller."
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

local propTable = {
	AutoRotate = true,
	WalkSpeed = 16,
	JumpPower = 50,
	JumpHeight = 7.2,
	HipHeight = 2,
	MaxHealth = 100,
	Health = 100,
	DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer,
	NameDisplayDistance = 100,
	HealthDisplayDistance = 100,
	HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged,
	RigType = Enum.RigType.Rig15,
	PlatformStand = false,
	Sit = false,
	UseJumpPower = true,
}

return {
	class = "Humanoid",

	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
