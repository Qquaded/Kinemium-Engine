-- description: "Represents a user connected to the game."
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local baseProps = {
	Name = "Player",
	UserId = 0,
	Character = nil,
	Backpack = {},
	Team = nil,
	Health = 100,
	MaxHealth = 100,
	WalkSpeed = 16,
	JumpPower = 50,
	CameraMode = Enum.CameraMode.Classic,

	CameraMaxZoomDistance = 80,
	CameraMinZoomDistance = 0.1,
}

local function makeProps()
	local props = {}
	for key, value in pairs(baseProps) do
		props[key] = value
	end

	props.CharacterAdded = signal.new()
	props.CharacterRemoving = signal.new()

	return props
end

return {
	class = "Player",
	non_creatable = true,
	callback = function(instance, starterGui)
		if rawget(instance, "_playerCallbackInitialized") ~= true then
			rawset(instance, "_playerCallbackInitialized", true)
			instance:SetProperties(makeProps())
		end
		if starterGui and starterGui.ClassName == "StarterGui" then
			instance.PlayerGui = starterGui:Clone()
		end

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(makeProps()) do
			tble[prop] = val
		end
	end,
}
