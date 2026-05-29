-- description: "Represents a BallSocketConstraint in the environment."
local _Vector3 = require("@Vector3")
local _signal = require("@Kinemium.signal")
local _state = require("@State")
local Color3 = require("@Color3")
local NetworkOwnership = require("../../game/services/ReplicatorService/NetworkOwnership")

local raylib = require("@raylib")
local rl = raylib.lib

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

	-- description: "Initializes the BallSocketConstraint instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")
		instance:SetProperties(propTable)

		local _activeConstraint = nil

		-- description: "Cleans up the resources."
		local function cleanup()
			if _activeConstraint then
				local jolt = KinemiumPhysicsService.jolt
				if jolt and jolt.lib and jolt.physicsSystem then
					jolt.lib.JPH_PhysicsSystem_RemoveConstraint(jolt.physicsSystem, _activeConstraint)
				end
				_activeConstraint = nil
			end
		end

		-- description: "Rebuilds the state."
		local function rebuild()
			cleanup()

			if not instance.Enabled then
				return
			end

			local att0 = instance.Attachment0
			local att1 = instance.Attachment1

			if not att0 or not att1 then
				return
			end

			local part0 = att0.Parent
			local part1 = att1.Parent

			if not part0 or not part1 then
				return
			end

			if not NetworkOwnership.ShouldSimulateConstraintForMachine(instance, datamodel) then
				return
			end

			if not KinemiumPhysicsService.GetBody(part0) or not KinemiumPhysicsService.GetBody(part1) then
				task.defer(rebuild)
				return
			end

			local wPos0 = part0.CFrame * att0.Position
			local wPos1 = part1.CFrame * att1.Position

			_activeConstraint = KinemiumPhysicsService.CreateBallSocket(part0, part1, wPos0, wPos1)

			-- description: "Ons part changed."
			-- args: "prop: any"
			local function onPartChanged(prop)
				if prop == "Anchored" then
					task.defer(rebuild)
				end
			end

			if _activeConstraint then
				if part0 then
					part0.Changed:Connect(onPartChanged)
				end
				if part1 then
					part1.Changed:Connect(onPartChanged)
				end
			else
				task.defer(rebuild)
			end
		end

		-- description: "Draws the visual representation."
		local function drawGizmo()
			if not instance.Visible then
				return
			end
			local att0 = instance.Attachment0
			if not att0 or not att0.Parent then
				return
			end

			local wPos = att0.Parent.CFrame * att0.Position
			local color = instance.Color
			local rlColor = raylib.structs.Color:new({
				r = color.R * 255,
				g = color.G * 255,
				b = color.B * 255,
				a = 200,
			})

			rl.DrawSphere(vector.create(wPos.X, wPos.Y, wPos.Z), instance.Radius, rlColor)
		end

		instance.Changed:Connect(function(prop)
			if prop == "Attachment0" or prop == "Attachment1" or prop == "Enabled" then
				rebuild()
			end
		end)

		renderer.Pool.new("gizmo", function()
			drawGizmo()
		end)

		task.spawn(rebuild)

		return instance
	end,
}
