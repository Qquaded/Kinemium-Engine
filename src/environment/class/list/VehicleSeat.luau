-- description: "A seat that can be occupied by a player to control a vehicle."
local Part = require("@Part")

local Color3 = require("@Color3")
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local propTable = {
	Name = "Seat",
	Disabled = false,
	Occupant = nil,
	Throttle = 0,
	Steer = 0,
	HeadsUpDisplay = true,
	MaxSpeed = 25,
	Torque = 10,
	TurnSpeed = 1,
	IsSeat = true,

	Color = Color3.new(0, 0.105882, 0.168627),
	Material = Enum.Material.SmoothPlastic,
	Size = Vector3.new(4, 2, 4),
}

Part.inherit(propTable)

return {
	class = "VehicleSeat",

	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		for prop, val in pairs(propTable) do
			local props = rawget(instance, "_props")
			if props then
				props[prop] = val
			else
				instance[prop] = val
			end
		end

		instance.Touched:Connect(function(hit)
			if instance.Disabled or instance.Occupant then
				return
			end
			local humanoid = hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if
				humanoid
				and humanoid.Health > 0
				and humanoid.SeatPart == nil
				and humanoid:GetState() ~= Enum.HumanoidStateType.Seated
				and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
			then
				instance.Occupant = humanoid
				humanoid.SeatPart = instance
			end
		end)

		return instance
	end,
	inherit = function(tble)
		Part.inherit(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
