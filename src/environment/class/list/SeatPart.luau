-- description: "A seat that can be occupied by a player."
local Vector3 = require("@Vector3")
local Part = require("@Part")
local Enum = require("@EnumMap")

local propTable = {
	Disabled = false,
	Occupant = nil,
	Name = "Seat",
	BaseClass = "BasePart",
	IsSeat = true,
}

Part.inherit(propTable)

return {
	class = "SeatPart",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)
		instance:SetMetadata("IsMovable", true)

		local KinemiumPhysicsService = game and game:GetService("UnifiedPhysicsService") or nil
		-- description: "Applies a physics impulse to the object."
		-- args: "self: table, v: Vector3"
		instance.ApplyImpulse = function(self, v)
			if KinemiumPhysicsService then
				KinemiumPhysicsService.ApplyImpulse(instance, v)
			end
		end

		renderer.EventBus:Fire("UpdatePart", instance)

		local syncingTransform = false

		local function syncFromCFrame(cf)
			if not cf or not cf.Position then
				return
			end
			local rx, ry, rz = cf:ToOrientation()
			local props = rawget(instance, "_props")
			if not props then
				return
			end
			props.Position = cf.Position
			props.Orientation = Vector3.new(rx, ry, rz)
			props.Rotation = props.Orientation
		end

		local function syncFromPosition(position)
			if not position then
				return
			end
			local props = rawget(instance, "_props")
			if not props or not props.CFrame then
				return
			end
			props.CFrame = props.CFrame:WithPosition(position)
		end

		instance.Changed:Connect(function(property, value)
			if syncingTransform then
				return
			end
			if property == "CFrame" then
				syncingTransform = true
				syncFromCFrame(value)
				syncingTransform = false
			elseif property == "Position" then
				syncingTransform = true
				syncFromPosition(value)
				syncingTransform = false
			elseif property == "Parent" then
				renderer.EventBus:Fire("UpdatePart", instance)
			end
		end)

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
	inherit = function(t)
		Part.inherit(t)
		for k, v in pairs(propTable) do
			t[k] = v
		end
	end,
}
