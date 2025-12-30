local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local task = zune.task

local UIPhysicsService = Instance.new("UIPhysicsService")
UIPhysicsService.ExplorerHidden = true

local box2d = require("@box2d")
local utils = require("@bufferutils")
local toptr = zune.ffi.ptrFromAddress

local function b2Rot_new(angle)
	local cosVal = math.cos(angle)
	local sinVal = math.sin(angle)
	return box2d.structs.b2Rot:new({ c = utils:float(cosVal), s = utils:float(sinVal) })
end

local function getResults(ptr, size)
	-- ptr = ffi pointer
	-- size = number of bytes to inspect (optional)

	size = size or 32

	print("FFI ptr:", ptr)

	for i = 0, 16 do
		local offset = i
		print(string.format("f64[%d] @ %d = %.6f", i, offset, ptr:readf64(offset)))
	end

	for i = 0, 20 do
		local offset = i
		print(string.format("u32[%d] @ %d = %.6f", i, offset, ptr:readu32(offset)))
	end

	for i = 0, 22 do
		local offset = i
		print(string.format("u16[%d] @ %d = %.6f", i, offset, ptr:readu16(offset)))
	end

	for i = 0, 20 do
		local offset = i
		print(string.format("i32[%d] @ %d = %.6f", i, offset, ptr:readi32(offset)))
	end

	for i = 0, 22 do
		local offset = i
		print(string.format("i16[%d] @ %d = %.6f", i, offset, ptr:readi16(offset)))
	end

	for i = 0, 23 do
		local offset = i
		print(string.format("i8[%d] @ %d = %.6f", i, offset, ptr:readi8(offset)))
	end

	print("\nRaw bytes:")
	for i = 0, size - 1 do
		print(string.format("%02d: %02X", i, ptr:readu8(i)))
	end
end

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
	print(1)
	if not object.AbsoluteSize then
		return
	end
	local x = object.AbsoluteSize.X
	local y = object.AbsoluteSize.Y

	local rotation = object.Rotation
	print(2)
	local body_pos = box2d.structs.b2Vec2:new({
		x = x,
		y = y,
	})

	local body_rot = b2Rot_new(object.Rotation)

	local motionType = object.Anchored == true and 2 or 0
	print(4)
	--[[
        local b2BodyDef = ffi.struct({
            { type = ffi.types.pointer },
            { position = ffi.types.pointer },
            { rotation = ffi.types.pointer },
            { linearVelocity = ffi.types.pointer },
            { angularVelocity = ffi.types.float },
            { linearDamping = ffi.types.float },
            { angularDamping = ffi.types.float },
            { gravityScale = ffi.types.float },
            { sleepThreshold = ffi.types.float },
            { name = ffi.types.pointer },
            { userData = ffi.types.pointer },
            { enableSleep = ffi.types.u8 },
            { isAwake = ffi.types.u8 },
            { fixedRotation = ffi.types.u8 },
            { isBullet = ffi.types.u8 },
            { isEnabled = ffi.types.u8 },
            { allowFastRotation = ffi.types.u8 },
            { internalValue = ffi.types.i32 },
        })
        export type b2BodyDef = typeof(b2BodyDef:new({}))
    --]]

	print(5)
	local bodyDef = box2d.lib.b2DefaultBodyDef()
	--[[local bodyDef = box2d.structs.b2BodyDef:new({
		type = motionType,
		position = toptr(body_pos),
		rotation = toptr(body_rot),
		angularVelocity = utils:float(0),
		linearDamping = utils:float(0),
		angularDamping = utils:float(0),
		gravityScale = utils:float(1),
		sleepThreshold = utils:float(0.05),
		enableSleep = utils:u8(0),
		isAwake = utils:u8(1),
		fixedRotation = utils:u8(0),
		isBullet = utils:u8(0),
		isEnabled = utils:u8(1),
		allowFastRotation = utils:u8(0),
		internalValue = utils:i32(0x5A55A5A5), -- Box2D's secret cookie
	})
		--]]

	print("created!!!!!!")

	print(7)
	print(worldId, bodyDef)
	local bodyID = box2d.lib.b2CreateBody(worldId, bodyDef)
	print(8)
	local box = box2d.lib.b2MakeBox(x / 2, y / 2)
	print(9)

	print(10)
	local groundShapeDef = box2d.lib.b2DefaultShapeDef()
	box2d.lib.b2CreatePolygonShape(bodyID, groundShapeDef, box)
end

UIPhysicsService.InitRenderer = function(renderer, renderer_signal)
	UIPhysicsService:SetProperties({
		lib = renderer.lib,
		const = renderer.const,
		structs = renderer.structs,
		init = function(ScreenGui)
			print("Physics is Enabled!")
			print(1)
			ScreenGui.bodies = {}

			local box2d = require("@box2d")

			print(2)
			-- Create gravity vector
			local grav = box2d.structs.b2Vec2:new({
				x = ScreenGui.GravityX or 0,
				y = ScreenGui.GravityY or -9.81,
			})
			local ptr = zune.ffi.ptrFromAddress(grav)

			print(3)
			local ffi = zune.ffi

			print(4)
			--[[
                local b2WorldDef = ffi.struct({
                    { gravity = ffi.types.pointer },
                    { restitutionThreshold = ffi.types.float },
                    { hitEventThreshold = ffi.types.float },
                    { contactHertz = ffi.types.float },
                    { contactDampingRatio = ffi.types.float },
                    { maxContactPushSpeed = ffi.types.float },
                    { maximumLinearSpeed = ffi.types.float },
                    { frictionCallback = ffi.types.pointer },
                    { restitutionCallback = ffi.types.pointer },
                    { enableSleep = ffi.types.u8 },
                    { enableContinuous = ffi.types.u8 },
                    { workerCount = ffi.types.i32 },
                    { enqueueTask = ffi.types.pointer },
                    { finishTask = ffi.types.pointer },
                    { userTaskContext = ffi.types.pointer },
                    { userData = ffi.types.pointer },
                    { internalValue = ffi.types.i32 },
                })
                export type b2WorldDef = typeof(b2WorldDef:new({}))
				            --]]

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

			print(4)
			-- Create world with custom definition
			local worldId = box2d.lib.b2CreateWorld(wdef)
			print("World created:", worldId ~= zune.ffi.null)
			print("World pointer:", worldId)

			if worldId == zune.ffi.null then
				error("Failed to create Box2D world")
			end

			print(5)
			print(worldId)

			task.wait(2)
			for _, object in pairs(ScreenGui:GetChildren()) do
				print(6)
				print("swing round")
				createBody(object, worldId)
			end

			return worldId
		end,
	})
end

return UIPhysicsService
