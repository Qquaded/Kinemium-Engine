local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")
local jolt = require("@jolt")

local raylib = require("@raylib")
local rl = raylib.lib

local propTable = {
	Attachment0 = nil,

	Force = Vector3.new(0, 50, 1999),
	RelativeTo = Enum.ActuatorRelativeTo.World,

	Enabled = true,
	Name = "VectorForce",
	ElapsedTime = 0,
}

return {
	class = "VectorForce",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local PhysicsService = game:GetService("PhysicsService")

		local function updateArrow()
			if not instance.Enabled or not instance.Attachment0 then
				return
			end

			local attach = instance.Attachment0
			if attach and attach:IsA("Attachment") then
				local parent = attach.Parent
				if parent:IsA("Part") or parent:IsA("MeshPart") then
					local force = instance.Force
					local magnitude = force:Magnitude()

					if magnitude > 0 then
						local direction = force:Unit()
						local position = parent.CFrame.Position

						local arrowLength = math.min(magnitude / 20, 20) * 5
						local endPos = position + (direction * arrowLength)

						rl.DrawCylinderEx(
							vector.create(position.X, position.Y, position.Z),
							vector.create(endPos.X, endPos.Y, endPos.Z),
							0.1,
							0.1,
							8,
							raylib.structs.Color:new({ r = 0, g = 0, b = 255, a = 255 })
						)

						rl.DrawCubeWiresV(
							vector.create(position.X, position.Y, position.Z),
							vector.create(parent.Size.X, parent.Size.Y, parent.Size.Z),
							raylib.structs.Color:new({ r = 0, g = 0, b = 255, a = 255 })
						)
					end
				end
			end
		end

		renderer.Signal:Connect(function(route)
			if route == "PrePhysics" then
				if not instance.Enabled then
					return
				end
				local attach = instance.Attachment0
				if attach and attach:IsA("Attachment") then
					local parent = attach.Parent
					if parent:IsA("Part") or parent:IsA("MeshPart") then
						PhysicsService.ApplyForce(parent, instance.Force, attach.CFrame.Position)
					end
				end
			end
		end)

		renderer.Add3DStack(function()
			updateArrow()
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
