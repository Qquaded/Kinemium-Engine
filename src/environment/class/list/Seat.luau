-- description: "Represents a Seat in the environment."
local Part = require("./Part")

local propTable = {
	Name = "Seat",
	Disabled = false,
	Occupant = nil,
}

return {
	class = "Seat",
	-- description: "Initializes the Seat instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
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
			if instance.Disabled or instance.Occupant then return end
			local humanoid = hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and humanoid.SeatPart == nil and humanoid:GetState() ~= Enum.HumanoidStateType.Seated and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				instance.Occupant = humanoid
				humanoid.SeatPart = instance
			end
		end)

		return instance
	end,
	-- description: "Inherits the properties of the Seat class."
	-- args: "tble: table"
	inherit = function(tble)
		Part.inherit(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
