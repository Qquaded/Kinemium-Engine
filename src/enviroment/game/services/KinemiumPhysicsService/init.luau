local Instance = require("@Instance")
local engine = require("@Kinemium.physics")
local Vector3 = require("@Vector3")

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local bodiesMap = {}

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal)
	local constraintsMap = {}
	local propTable = {
		GetBody = function(part)
			return bodiesMap[part]
		end,
		ApplyForce = function(body, force)
			engine:ApplyForce(body, force)
		end,
		ApplyImpulse = function(body, impulse)
			engine:ApplyImpulse(body, impulse)
		end,
		ApplyTorque = function(body, torque)
			engine:ApplyTorque(body, torque)
		end,
		RemoveBody = function(part)
			local body = bodiesMap[part]
			if body then
				for i, b in ipairs(engine.Bodies) do
					if b == body then
						table.remove(engine.Bodies, i)
						break
					end
				end
				bodiesMap[part] = nil
			end
		end,
		CreateWeldConstraint = function(partA, partB, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateWeldConstraint(bodyA, bodyB, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		CreateRopeConstraint = function(partA, partB, maxDistance, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateRopeConstraint(bodyA, bodyB, maxDistance, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		CreateRodConstraint = function(partA, partB, distance, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateRodConstraint(bodyA, bodyB, distance, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		CreateSpringConstraint = function(partA, partB, restLength, stiffness, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateSpringConstraint(bodyA, bodyB, restLength, stiffness, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		CreateHingeConstraint = function(partA, partB, axis, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateHingeConstraint(bodyA, bodyB, axis, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		CreateBallSocketConstraint = function(partA, partB, anchorA, anchorB)
			local bodyA = bodiesMap[partA]
			local bodyB = bodiesMap[partB]
			if bodyA and bodyB then
				local constraint = engine:CreateBallSocketConstraint(bodyA, bodyB, anchorA, anchorB)
				constraintsMap[constraint] = { partA, partB }
				return constraint
			end
		end,
		RemoveConstraint = function(constraint)
			engine:RemoveConstraint(constraint)
			constraintsMap[constraint] = nil
		end,
		SetGravity = function(gravity)
			engine.Gravity = gravity
		end,
		SetAirDrag = function(drag)
			engine.AirDrag = drag
		end,
	}
	KinemiumPhysicsService:SetProperties(propTable)

	--> create collidable body for Camera
	local camera = renderer.Kinemium_camera :: Instance

	local cameraBody = {
		Position = camera.Position,
		Velocity = Vector3.new(0, 0, 0),
		Size = Vector3.new(1, 2, 1),
		Mass = 1,
		IsStatic = false,
		IsKinematic = true,
		Restitution = 0,
		Friction = 0.5,
	}
	engine:RegisterBody(cameraBody)

	local lastPos = camera.Position

	local function updateCamera(dt)
		local currentPos = camera.Position

		cameraBody.Velocity = (currentPos - lastPos) / dt
		cameraBody.Position = currentPos

		lastPos = currentPos
	end

	renderer_signal:Connect(function(route, data)
		if route == "AddedPartToRenderPool" then
			if data.CanCollide == false then
				print("Part cancollide off, Not registering body.")
				return
			end
			local body = {
				Position = data.Position,
				Velocity = data.Velocity,
				Size = data.Size,
				Friction = data.Friction,
				Restitution = data.Restitution,
				Rotation = data.Rotation,
				Mass = data.Mass or 1,
				IsStatic = data.Anchored,
			}
			if data.Shape == "Ball" then
				body.Shape = "Sphere"
				body.Radius = data.Size.X + data.Size.Z
			end
			engine:RegisterBody(body)
			bodiesMap[data] = body
		elseif route == "RenderStepped" then
			local dt = data or 1 / 60
			engine:Step(dt)
			updateCamera(dt)

			for part, body in pairs(bodiesMap) do
				part.Position = body.Position
				part.Rotation = body.Rotation
				part.Orientation = body.Rotation
			end
		end
	end)

	renderer_signal:Fire("PhysicsEngine", KinemiumPhysicsService)
end

return KinemiumPhysicsService
