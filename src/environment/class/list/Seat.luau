-- description: "A seat that can be occupied by a player."
local Part = require("@Part")

local propTable = {
	Name = "Seat",
	Disabled = false,
	Occupant = nil,
}

return {
	class = "Seat",
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
