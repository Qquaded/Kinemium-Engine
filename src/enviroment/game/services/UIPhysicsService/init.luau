local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local UDim2 = require("@UDim2")
local task = zune.task

local UIPhysicsService = Instance.new("UIPhysicsService")
UIPhysicsService.ExplorerHidden = true

local box2d = require("@box2d")
local utils = require("@bufferutils")

local bodies = {}
local worlds = {}

--[[
    /// The body simulation type.
    /// Each body is one of these three types. The type determines how the body behaves in the simulation.
    /// @ingroup body
    typedef enum b2BodyType
    {
        /// zero mass, zero velocity, may be manually moved
        b2_staticBody = 0,

        /// zero mass, velocity set by user, moved by solver
        b2_kinematicBody = 1,

        /// positive mass, velocity determined by forces, moved by solver
        b2_dynamicBody = 2,

        /// number of body types
        b2_bodyTypeCount,
    } b2BodyType;
--]]

local function createBody(object, worldId)
	if not object.AbsoluteSize then
		return
	end
	local x = object.AbsoluteSize.X
	local y = object.AbsoluteSize.Y

	print(x, y)

	local motionType = object.Anchored == false and 2 or 0

	local position = box2d.structs.b2Vec2:new({ x = utils:float(x / 2), y = utils:float(y / 2) })

	local bodyDef = box2d.lib.b2DefaultBodyDef()
	buffer.copy(bodyDef, box2d.structs.b2BodyDef:offset("position"), position, 0, box2d.structs.b2Vec2:size())
	buffer.writei32(bodyDef, box2d.structs.b2BodyDef:offset("type"), motionType)

	local bodyID = box2d.lib.b2CreateBody(worldId, bodyDef)
	local box = box2d.lib.b2MakeBox(x / 2, y / 2)

	local groundShapeDef = box2d.lib.b2DefaultShapeDef()
	box2d.lib.b2CreatePolygonShape(bodyID, groundShapeDef, box)

	log(
		`Created body ${object.Name} with stats \nBodyID: ${bodyID} \nMotionType: ${motionType} \nPosition: ${position}\nBox: ${box}\nGroundShapeDef: ${groundShapeDef}`
	)
	object.BodyID = bodyID
	table.insert(bodies, { bodyID = bodyID, box = box, bodyDef = bodyDef, motionType = motionType, object = object })
end

UIPhysicsService.InitRenderer = function(renderer, renderer_signal)
	UIPhysicsService:SetProperties({
		lib = renderer.lib,
		const = renderer.const,
		structs = renderer.structs,
		init = function(ScreenGui)
			local box2d = require("@box2d")

			local grav = box2d.structs.b2Vec2:new({
				x = ScreenGui.GravityX or 0,
				y = ScreenGui.GravityY or -9.81,
			})
			local ptr = zune.ffi.ptrFromAddress(grav)

			local wdef = box2d.structs.b2WorldDef:new({
				gravity = ptr,
				restitutionThreshold = 1.0,
				hitEventThreshold = 0.0,
				contactHertz = 60.0,
				contactDampingRatio = 1.0,
				maxContactPushSpeed = 3.0,
				maximumLinearSpeed = 40.0,
				frictionCallback = zune.ffi.null,
				restitutionCallback = zune.ffi.null,
				enableSleep = 1,
				motionLocks = box2d.structs.b2MotionLocks:new({
					linearX = false,
					linearY = false,
					angularZ = false,
				}),
				enableContinuous = 1,
				workerCount = 0,
				enqueueTask = zune.ffi.null,
				finishTask = zune.ffi.null,
				userTaskContext = zune.ffi.null,
				userData = zune.ffi.null,
				internalValue = 0x5A55A5A5,
			})

			local worldId = box2d.lib.b2CreateWorld(wdef)
			print("World created:", worldId ~= zune.ffi.null)
			print("World pointer:", worldId)

			if worldId == zune.ffi.null then
				error("Failed to create Box2D world")
			end

			task.wait(2)
			for _, object in pairs(ScreenGui:GetChildren()) do
				createBody(object, worldId)
			end

			table.insert(worlds, worldId)

			return worldId
		end,
	})

	renderer_signal:Connect(function(route, dt)
		if route == "RenderStepped" then
			for _, world in pairs(worlds) do
				print("Updating world")
				box2d.lib.b2World_Step(world, dt, 4)

				for _, body in pairs(bodies) do
					local position = box2d.lib.b2Body_GetPosition(body.bodyID)

					local x = buffer.readf32(position, 0)
					local y = buffer.readf32(position, 4)
					print(x, y)
					body.object.Position = UDim2.new(body.object.Position.X.Scale, x, body.object.Position.Y.Scale, y)
				end
			end
		end
	end)
end

return UIPhysicsService
