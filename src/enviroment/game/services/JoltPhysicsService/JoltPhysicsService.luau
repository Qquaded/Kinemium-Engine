-- devcell
local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local ffi = zune.ffi
local jolt = require("@jolt")
local lib = jolt.lib
local Enum = require("@EnumMap")
local utils = require("@bufferutils")
local structs = jolt.structs

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local function log(...)
	print("[Physics]", ...)
end

local function roundVec3(v)
	local x = math.abs(v.X) < 1e-4 and 0 or v.X
	local y = math.abs(v.Y) < 1e-4 and 0 or v.Y
	local z = math.abs(v.Z) < 1e-4 and 0 or v.Z
	return Vector3.new(x, y, z)
end

local bodiesMap = {} -- Part -> BodyID (uint32)
local bodyPointerMap = {} -- Part -> BodyPointer (ffi.pointer)
local inverseMap = {} -- BodyID -> Part
local bodyConnections = {} -- Part -> RBXScriptConnection

local LAYER_NON_MOVING = 0 -- Static objects
local LAYER_MOVING = 1 -- Dynamic objects
local NUM_OBJECT_LAYERS = 2

local function isZero(v)
	if v == -0 then
		return true
	elseif v == 0 then
		return true
	end
	return false
end

local function ToJoltVec3(vec3)
	return {
		x = vec3.X,
		y = vec3.Y,
		z = vec3.Z,
	}
end

local function RVec3(x, y, z)
	local vec = structs.JPH_RVec3:new({})
	buffer.writef64(vec, 0, x)
	buffer.writef64(vec, 8, y)
	buffer.writef64(vec, 16, z)
	return vec
end

local function FromJoltVec3(jvec)
	return Vector3.new(jvec.x, jvec.y, jvec.z)
end

local function _CFrameToJolt(cf)
	return {
		pos = ToJoltVec3(cf.Position),
		rot = { x = 0, y = 0, z = 0, w = 1 }, -- Identity quaternion
	}
end

local function _debugBody(bodyInterface, bodyID, partName)
	local isActive = lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID)
	local isAdded = lib.JPH_BodyInterface_IsAdded(bodyInterface, bodyID)

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	lib.JPH_BodyInterface_GetPosition(bodyInterface, bodyID, position)

	local posX = position:readf64(0)
	local posY = position:readf64(8)
	local posZ = position:readf64(16)

	log(
		string.format(
			"[Physics Debug] %s: Active=%s, Added=%s, Pos=(%.2f, %.2f, %.2f)",
			partName,
			tostring(isActive == 1),
			tostring(isAdded == 1),
			posX,
			posY,
			posZ
		)
	)
end

local function buildShapeForPart(part, halfSize)
	if part.Shape == Enum.PartType.Block then
		local convexRadius = math.min(0.05, math.min(part.Size.X, part.Size.Y, part.Size.Z) * 0.1)
		return lib.JPH_BoxShape_Create(halfSize, convexRadius)
	elseif part.Shape == Enum.PartType.Ball then
		local radius = part.Size.X * 0.5
		return lib.JPH_SphereShape_Create(radius)
	end

	return lib.JPH_BoxShape_Create(halfSize, 0.05)
end

local function createBody(bodyInterface, part, motionType)
	local halfSize = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	halfSize:writef32(0, part.Size.X / 2)
	halfSize:writef32(4, part.Size.Y / 2)
	halfSize:writef32(8, part.Size.Z / 2)

	local shape = buildShapeForPart(part, halfSize)

	part.Position = part.CFrame.Position

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	position:writef64(0, part.Position.X)
	position:writef64(8, part.Position.Y)
	position:writef64(16, part.Position.Z)

	local rotation = ffi.alloc(structs.JPH_Quat:size(), structs.JPH_Quat:alignment())
	local rotX, rotY, rotZ, rotW = part.CFrame:ToQuaternion()
	rotation:writef32(0, rotX)
	rotation:writef32(4, rotY)
	rotation:writef32(8, rotZ)
	rotation:writef32(12, rotW)

	local layer = part.Anchored and LAYER_NON_MOVING or LAYER_MOVING

	local bodySettings = lib.JPH_BodyCreationSettings_Create3(shape, position, rotation, motionType, layer)
	lib.JPH_BodyCreationSettings_SetAllowSleeping(bodySettings, 1)

	local bodyPtr = lib.JPH_BodyInterface_CreateBody(bodyInterface, bodySettings)
	if bodyPtr == ffi.null then
		warn("[Physics] Failed to create body pointer for", part.Name)
		lib.JPH_BodyCreationSettings_Destroy(bodySettings)
		return
	end

	local bodyID = lib.JPH_Body_GetID(bodyPtr)
	local activation = (motionType == 2) and 0 or 1 -- JPH_Activation_Activate = 0, JPH_Activation_DontActivate = 1

	lib.JPH_BodyInterface_AddBody(bodyInterface, bodyID, activation)

	lib.JPH_BodyCreationSettings_Destroy(bodySettings)

	bodiesMap[part] = bodyID
	bodyPointerMap[part] = bodyPtr
	inverseMap[bodyID] = part

	--debugBody(bodyInterface, bodyID, part.Name)
	return bodyID
end

local function CalculateBodyPhysics(part, bodyInterface, bodyID)
	if part.Anchored then
		return
	end
	if lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID) == 0 then
		return
	end

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	local rotation = ffi.alloc(structs.JPH_Quat:size(), structs.JPH_Quat:alignment())

	lib.JPH_BodyInterface_GetPositionAndRotation(bodyInterface, bodyID, position, rotation)

	local posX = position:readf64(0)
	local posY = position:readf64(8)
	local posZ = position:readf64(16)

	local velocity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	local angular_vel = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())

	lib.JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)
	lib.JPH_BodyInterface_GetAngularVelocity(bodyInterface, bodyID, angular_vel)

	local velX = velocity:readf32(0)
	local velY = velocity:readf32(4)
	local velZ = velocity:readf32(8)

	local angvelX = angular_vel:readf32(0)
	local angvelY = angular_vel:readf32(4)
	local angvelZ = angular_vel:readf32(8)

	local rotX = rotation:readf32(0)
	local rotY = rotation:readf32(4)
	local rotZ = rotation:readf32(8)
	local rotW = rotation:readf32(12)

	local finalCF = CFrame.fromQuaternion(rotX, rotY, rotZ, rotW, roundVec3(Vector3.new(posX, posY, posZ)))
	local linearVelocity = roundVec3(Vector3.new(velX, velY, velZ))
	local angularVelocity = roundVec3(Vector3.new(angvelX, angvelY, angvelZ))

	return finalCF, linearVelocity, angularVelocity
end

local function setGravity(physicsSystem, v, wind)
	-- i HAVE to add the wind, its mandatory trust
	local gravity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	gravity:writef32(0, 0 + (wind and wind.X or 0)) -- X
	gravity:writef32(4, v + -(wind and wind.Y or 0)) -- Y
	gravity:writef32(8, 0 + (wind and wind.Z or 0)) -- Z
	lib.JPH_PhysicsSystem_SetGravity(physicsSystem, gravity)
end

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		repeat
			task.wait()
		until game.PlaytestService

		local _PlaytestService = game.PlaytestService

		local _contactListener = structs.JPH_ContactListener_Procs:new({
			OnContactValidate = ffi.closure({
				returns = ffi.types.i32, -- JPH_ValidateResult
				args = {
					ffi.types.pointer, -- body1 (JPH_Body*)
					ffi.types.pointer, -- body2 (JPH_Body*)
					ffi.types.pointer, -- baseOffset (JPH_RVec3*)
					ffi.types.pointer, -- collisionResult (JPH_CollideShapeResult*)
				},
			}, function(body1, body2, baseOffset, collisionResult)
				print("OnContactValidate")
				return utils:i32(1) -- JPH_ValidateResult_AcceptContact
			end),
			OnContactAdded = ffi.null,

			OnContactPersisted = ffi.null,

			OnContactRemoved = ffi.null,
		})

		log("[Physics] Initializing Jolt Physics...")

		local initSuccess = lib.JPH_Init()
		if initSuccess == 0 then
			error("[Physics] Failed to initialize Jolt")
		end
		log("[Physics] Jolt initialized")

		local broadPhaseLayerInterface =
			lib.JPH_BroadPhaseLayerInterfaceTable_Create(NUM_OBJECT_LAYERS, NUM_OBJECT_LAYERS)
		if broadPhaseLayerInterface == ffi.null then
			error("[Physics] Failed to create BroadPhaseLayerInterface")
		end

		lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_NON_MOVING, 0)
		lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_MOVING, 1)
		log("[Physics] BroadPhaseLayerInterface created")

		local objectLayerPairFilter = lib.JPH_ObjectLayerPairFilterTable_Create(NUM_OBJECT_LAYERS)
		if objectLayerPairFilter == ffi.null then
			error("[Physics] Failed to create ObjectLayerPairFilter")
		end

		lib.JPH_ObjectLayerPairFilterTable_DisableCollision(objectLayerPairFilter, LAYER_NON_MOVING, LAYER_NON_MOVING)
		lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_NON_MOVING, LAYER_MOVING)
		lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_MOVING, LAYER_NON_MOVING)
		lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_MOVING, LAYER_MOVING)

		log("[Physics] ObjectLayerPairFilter created")

		local objectVsBroadPhaseFilter = lib.JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
			broadPhaseLayerInterface,
			NUM_OBJECT_LAYERS,
			objectLayerPairFilter,
			NUM_OBJECT_LAYERS
		)
		if objectVsBroadPhaseFilter == ffi.null then
			error("[Physics] Failed to create ObjectVsBroadPhaseLayerFilter")
		end
		log("[Physics] ObjectVsBroadPhaseLayerFilter created")

		local physicsSystemSettings = structs.JPH_PhysicsSystemSettings:new({
			maxBodies = 102400,
			numBodyMutexes = 0,
			maxBodyPairs = 65536,
			maxContactConstraints = 10240,
			_padding = 0,
			broadPhaseLayerInterface = broadPhaseLayerInterface,
			objectLayerPairFilter = objectLayerPairFilter,
			objectVsBroadPhaseLayerFilter = objectVsBroadPhaseFilter,
		})

		local physicsSystem = lib.JPH_PhysicsSystem_Create(physicsSystemSettings)

		if physicsSystem == ffi.null then
			error("[Physics] Failed to create physics system")
		end

		log("[Physics] Physics system created and initialized")

		setGravity(physicsSystem, -9.81)
		log("[Physics] Gravity set")

		local bodyInterface = lib.JPH_PhysicsSystem_GetBodyInterface(physicsSystem)
		if bodyInterface == ffi.null then
			error("[Physics] Failed to get body interface")
		end
		log("[Physics] Body interface obtained")

		--local listenerPtr = lib.JPH_ContactListener_Create(ffi.null)
		--lib.JPH_ContactListener_SetProcs(contactListener)
		--lib.JPH_PhysicsSystem_SetContactListener(physicsSystem, listenerPtr)

		local _physicsState = {
			system = physicsSystem,
			bodyInterface = bodyInterface,
			broadPhaseLayerInterface = broadPhaseLayerInterface,
			objectLayerPairFilter = objectLayerPairFilter,
			objectVsBroadPhaseFilter = objectVsBroadPhaseFilter,
			LAYER_MOVING = LAYER_MOVING,
			LAYER_NON_MOVING = LAYER_NON_MOVING,
		}

		local config = structs.JPH_JobSystemConfig:new({
			context = 0,
			queueJob = ffi.null, -- Use Jolt's default
			queueJobs = ffi.null, -- Use Jolt's default
			maxConcurrency = 8, -- Number of threads
			maxBarriers = 8, -- Max barriers
		})

		local jobSystem = lib.JPH_JobSystemThreadPool_Create(config)
		if jobSystem == ffi.null then
			error("[Physics] Failed to create job system")
		end

		log("[Physics] Job system created")

		-- Use existing bodyInterface from line 285

		local function RemoveBody(part)
			local bodyID = bodiesMap[part]
			if bodyID then
				lib.JPH_BodyInterface_RemoveAndDestroyBody(bodyInterface, bodyID)
				bodiesMap[part] = nil
				bodyPointerMap[part] = nil
				inverseMap[bodyID] = nil
				if bodyConnections[part] then
					bodyConnections[part]:Disconnect()
					bodyConnections[part] = nil
				end
				log("[Physics] Destroyed body for part")
			end
		end

		local function CreateBodyForPart(part)
			if not part.CanCollide then
				return
			end

			local motion = 0
			if not part.Anchored then
				motion = 2
			elseif part.isKinematic then
				motion = 1
			else
				motion = 0
			end

			local oldBody = bodiesMap[part]
			if oldBody then
			else
				createBody(bodyInterface, part, motion)

				local connection = part.Changed:Connect(function(property)
					local bodyID = bodiesMap[part]
					if not bodyID then
						return
					end

					if property == "Size" or property == "Shape" then
						local halfSize = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
						halfSize:writef32(0, part.Size.X / 2)
						halfSize:writef32(4, part.Size.Y / 2)
						halfSize:writef32(8, part.Size.Z / 2)

						local newShape = buildShapeForPart(part, halfSize)
						if newShape ~= ffi.null then
							lib.JPH_BodyInterface_SetShape(bodyInterface, bodyID, newShape, 1, 1) -- updateMassProperties=1, activationMode=1 (Activate)
						end
					elseif property == "Anchored" then
						local newMotion = part.Anchored and 0 or 2
						local newLayer = part.Anchored and LAYER_NON_MOVING or LAYER_MOVING

						lib.JPH_BodyInterface_SetMotionType(bodyInterface, bodyID, newMotion, 1) -- activationMode=1 (Activate)
						lib.JPH_BodyInterface_SetObjectLayer(bodyInterface, bodyID, newLayer)
						lib.JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)
					elseif property == "Position" or property == "CFrame" then
						if part.Anchored then
							local pos_rvec =
								RVec3(part.CFrame.Position.X, part.CFrame.Position.Y, part.CFrame.Position.Z)

							local rot_quat = structs.JPH_Quat:new({})
							local x, y, z, w = part.CFrame:ToQuaternion()
							buffer.writef32(rot_quat, 0, x)
							buffer.writef32(rot_quat, 4, y)
							buffer.writef32(rot_quat, 8, z)
							buffer.writef32(rot_quat, 12, w)

							if lib.JPH_BodyInterface_SetPositionAndRotation then
								lib.JPH_BodyInterface_SetPositionAndRotation(
									bodyInterface,
									bodyID,
									pos_rvec,
									rot_quat,
									1
								)
							else
								lib.JPH_BodyInterface_SetPosition(bodyInterface, bodyID, pos_rvec, 1)
								lib.JPH_BodyInterface_SetRotation(bodyInterface, bodyID, rot_quat, 1)
							end
						end
					end
				end)

				bodyConnections[part] = connection
			end

			lib.JPH_PhysicsSystem_OptimizeBroadPhase(physicsSystem)
		end

		local propTable = {
			GetBody = function(part)
				return bodiesMap[part]
			end,

			UpdatePart = function(part)
				local body = bodiesMap[part]
				if not body then
					return
				end
				CalculateBodyPhysics(part, bodyInterface, body)
			end,

			AddBody = function(part)
				bodiesMap[part] = createBody(bodyInterface, part)
			end,

			Enabled = false,

			setGravity = function(value, wind)
				setGravity(physicsSystem, value, wind)
			end,

			ApplyImpulse = function(part, impulse)
				local bodyID = bodiesMap[part]
				if not bodyID then
					log("[Physics] ApplyImpulse: No body for part", part.Name)
					return
				end

				lib.JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)

				local _isActive = lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID)
				local jImpulse = structs.JPH_Vec3:new({ x = impulse.X, y = impulse.Y, z = impulse.Z })

				lib.JPH_BodyInterface_AddImpulse(bodyInterface, bodyID, jImpulse)
			end,

			ApplyForce = function(part, force, applicationPoint)
				local bodyID = bodiesMap[part]
				if not bodyID then
					return
				end

				lib.JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)

				local jForce = structs.JPH_Vec3:new({ x = force.X, y = force.Y, z = force.Z })
				local jPoint = RVec3(applicationPoint.X, applicationPoint.Y, applicationPoint.Z)

				local _success, _result = pcall(function(...)
					lib.JPH_BodyInterface_AddForce2(bodyInterface, bodyID, jForce, jPoint)
				end)
			end,

			CreateWeld = function(partA, partB)
				local bodyA = bodyPointerMap[partA]
				local bodyB = bodyPointerMap[partB]
				if not bodyA or not bodyB then
					return
				end

				local settings = structs.JPH_FixedConstraintSettings:new({
					autoDetectPoint = 1,
					space = 0,
				})

				local constraint = lib.JPH_FixedConstraint_Create(settings, bodyA, bodyB)
				lib.JPH_PhysicsSystem_AddConstraint(physicsSystem, constraint)
				return constraint
			end,

			SetVelocity = function(part, velocity)
				local bodyID = bodiesMap[part]
				if not bodyID then
					return
				end

				local jVel = structs.JPH_Vec3:new(ToJoltVec3(velocity))
				lib.JPH_BodyInterface_SetLinearVelocity(bodyInterface, bodyID, jVel)
			end,

			Unload = function()
				-- added this function for
				-- Memory purposes........
				for part, bodyID in pairs(bodiesMap) do
					local connection = bodyConnections[part]
					if connection then
						connection:Disconnect()
					end
					lib.JPH_BodyInterface_RemoveAndDestroyBody(bodyInterface, bodyID)
				end
				table.clear(bodyConnections)
				table.clear(bodiesMap)
				table.clear(bodyPointerMap)
				table.clear(inverseMap)

				lib.JPH_JobSystem_Destroy(jobSystem)
				lib.JPH_PhysicsSystem_Destroy(physicsSystem)
				lib.JPH_Shutdown()
			end,

			DeltatimeMultiplier = 1,

			GetBodies = function()
				return bodiesMap
			end,

			GetPhysicsBodyCount = function()
				local i = 0
				for _, v in pairs(bodiesMap) do
					i += 1
				end
				return i
			end,

			GetVelocity = function(part)
				local bodyID = bodiesMap[part]
				if not bodyID then
					return Vector3.new()
				end

				local velocity = structs.JPH_Vec3:new({ x = 0, y = 0, z = 0 })
				lib.JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)
				return FromJoltVec3(velocity)
			end,

			jolt = {
				lib = jolt.lib,
				structs = jolt.structs,
				physicsSystem = physicsSystem,
				jobSystem = jobSystem,
				bodyInterface = bodyInterface,
				broadPhaseLayerInterface = broadPhaseLayerInterface,
				objectVsBroadPhaseFilter,
				objectVsBroadPhaseFilter,
				ToJoltVec3 = ToJoltVec3,
				FromJoltVec3 = FromJoltVec3,
				RVec3 = RVec3,
			},
		}

		renderer.Hook.new("Renderstep", function(dt)
			KinemiumPhysicsService.Enabled = _PlaytestService.IsPlaytesting
			if KinemiumPhysicsService.Enabled == false then
				return
			end
			if
				game.Workspace.PhysicsEngine == Enum.PhysicsEngine.Jolt
				or game.Workspace.PhysicsEngine == Enum.PhysicsEngine.Default
			then
				setGravity(physicsSystem, game.Workspace.Gravity, game.Workspace.GlobalWind)

				--	local startTime = os.clock()
				local bodyCount = 0
				for _ in pairs(bodiesMap) do
					bodyCount += 1
				end

				renderer_signal:Fire("PrePhysics")
				lib.JPH_PhysicsSystem_Update(
					physicsSystem,
					dt,
					4 * KinemiumPhysicsService.DeltatimeMultiplier,
					jobSystem
				)
				renderer_signal:Fire("PhysicsF")

				local _loopStart = os.clock()
				for part, bodyID in pairs(bodiesMap) do
					if part.Anchored == true then
						-- set part cframe
						local pos_rvec = RVec3(part.CFrame.Position.X, part.CFrame.Position.Y, part.CFrame.Position.Z)

						local rot_quat = structs.JPH_Quat:new({})
						local x, y, z, w = part.CFrame:ToQuaternion()
						buffer.writef32(rot_quat, 0, x)
						buffer.writef32(rot_quat, 4, y)
						buffer.writef32(rot_quat, 8, z)
						buffer.writef32(rot_quat, 12, w)

						if lib.JPH_BodyInterface_SetPositionAndRotation then
							lib.JPH_BodyInterface_SetPositionAndRotation(bodyInterface, bodyID, pos_rvec, rot_quat, 1)
						else
							lib.JPH_BodyInterface_SetPosition(bodyInterface, bodyID, pos_rvec, 1)
							lib.JPH_BodyInterface_SetRotation(bodyInterface, bodyID, rot_quat, 1)
						end
						continue
					end

					local cf, linear, angular = CalculateBodyPhysics(part, bodyInterface, bodyID)

					if not cf then
						continue
					end

					if not part.Parent then
						log("Cannot calculate position without 3D renderer")
						continue
					end

					if not isZero(linear.X) or not isZero(linear.Y) or not isZero(linear.Z) then
						part.AssemblyLinearVelocity = linear
					end

					if not isZero(angular.X) or not isZero(angular.Y) or not isZero(angular.Z) then
						part.AssemblyAngularVelocity = angular
					end

					if cf ~= CFrame.new(0, 0, 0) then
						part.CFrame = cf
					end
				end
				--[[
			local loopEnd = os.clock()
			local totalEnd = os.clock()
			log(
				string.format(
					"[Physics] Update complete. Physics time: %.2fms, Loop time: %.2fms, Total: %.2fms",
					(loopStart - startTime) * 1000,
					(loopEnd - loopStart) * 1000,
					(totalEnd - startTime) * 1000
				)
			)
				--]]
			end
		end)

		renderer_signal:Connect(function(route, data)
			if route == "UpdatePart" or route == "AddedPartToRenderPool" then
				local pList = bodiesMap[data]
				if not pList then
					CreateBodyForPart(data)
				end
			elseif route == "RemovedPartFromRenderPool" then
				RemoveBody(data)
			end
		end)

		table.insert(game.ShutdownCallbacks, propTable.Unload)
		KinemiumPhysicsService:SetProperties(propTable)
	end)
end

return KinemiumPhysicsService
