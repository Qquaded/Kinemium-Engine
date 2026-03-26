local Instance = require("@Instance")
local UDim2 = require("@UDim2")
local task = zune.task

local Box2DService = Instance.new("Box2DService")
Box2DService.ExplorerHidden = true

local bufferUtils = require("@bufferUtils")

local box2d = require("@box2d")

local bodies = {} -- [GuiObject] = bodyData
local worlds = {} -- array of worldData
local worldsByObject = {} -- [World2D] = worldData

local function dbg(...)
	print("[Box2DService]", ...)
end

local function makeI32(value)
	local ptr = zune.ffi.create(zune.ffi.types.i32)
	ptr:writei32(0, value)
	return ptr
end

local function makeVec2(x, y)
	local grav = bufferUtils:vector2_32(x, y)
	return grav, zune.ffi.ptrFromAddress(grav)
end

local function makeRot(angleRad)
	local rot = box2d.structs.b2Rot:new({
		s = math.sin(angleRad),
		c = math.cos(angleRad),
	})
	return rot, zune.ffi.ptrFromAddress(rot)
end

local function getParentAbsPos(object)
	local parent = object.Parent
	if not parent then
		return 0, 0
	end
	if parent.AbsolutePosition then
		return parent.AbsolutePosition.X or 0, parent.AbsolutePosition.Y or 0
	end
	if parent.RenderOffset then
		return parent.RenderOffset.X or 0, parent.RenderOffset.Y or 0
	end
	return 0, 0
end

local function getAnchor(object)
	local anchor = object.AnchorPoint
	if not anchor then
		return 0, 0
	end
	return anchor.X or 0, anchor.Y or 0
end

local function isBodyCandidate(object, worldObject)
	if not object then
		return false
	end
	if object == worldObject then
		return false
	end
	if object.BaseClass == "UIContainer" then
		return false
	end
	if object.Parent ~= worldObject then
		return false
	end
	if not object.AbsoluteSize then
		return false
	end
	return true
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

local function applyShapeMaterial(object, shapeDef)
	if not shapeDef or shapeDef == zune.ffi.null then
		return
	end

	local density = object.Density
	if density ~= nil then
		shapeDef:writef32(box2d.structs.b2ShapeDef:offset("density"), density)
	end

	local friction = object.Friction
	if friction ~= nil then
		local offset = box2d.structs.b2ShapeDef:offset("material") + box2d.structs.b2SurfaceMaterial:offset("friction")
		shapeDef:writef32(offset, friction)
	end

	local restitution = object.Restitution
	if restitution ~= nil then
		local offset = box2d.structs.b2ShapeDef:offset("material")
			+ box2d.structs.b2SurfaceMaterial:offset("restitution")
		shapeDef:writef32(offset, restitution)
	end

	if object.IsSensor ~= nil then
		shapeDef:writeu8(box2d.structs.b2ShapeDef:offset("isSensor"), object.IsSensor and 1 or 0)
	end
end

local function createBody(object, worldData)
	if not object.AbsoluteSize then
		return
	end

	local x = object.AbsoluteSize.X
	local y = object.AbsoluteSize.Y

	local motionType = object.Anchored == false and 2 or 0

	local posX = object.AbsolutePosition.X + x / 2
	local posY = object.AbsolutePosition.Y + y / 2

	local position, positionPtr = makeVec2(posX, posY)
	local rotation, rotationPtr = makeRot(math.rad(object.Rotation or 0))
	local motionPtr = makeI32(motionType)

	local bodyDef = box2d.lib.b2DefaultBodyDef()
	bodyDef:writeptr(box2d.structs.b2BodyDef:offset("position"), positionPtr)
	bodyDef:writeptr(box2d.structs.b2BodyDef:offset("rotation"), rotationPtr)
	bodyDef:writeptr(box2d.structs.b2BodyDef:offset("type"), motionPtr)
	local allowSleep = worldData.object.AllowSleep
	if allowSleep == nil then
		allowSleep = worldData.object.enableSleep
	end
	bodyDef:writeu8(box2d.structs.b2BodyDef:offset("enableSleep"), allowSleep and 1 or 0)
	bodyDef:writeu8(box2d.structs.b2BodyDef:offset("isAwake"), 1)
	bodyDef:writeu8(box2d.structs.b2BodyDef:offset("isEnabled"), 1)

	local bodyID = box2d.lib.b2CreateBody(worldData.worldId, bodyDef)
	if bodyID == zune.ffi.null then
		return
	end

	local box = box2d.lib.b2MakeBox(x / 2, y / 2)
	local shapeDef = box2d.lib.b2DefaultShapeDef()
	applyShapeMaterial(object, shapeDef)
	local shapeID = box2d.lib.b2CreatePolygonShape(bodyID, shapeDef, box)

	object.BodyID = bodyID

	local data = {
		bodyID = bodyID,
		shapeID = shapeID,
		box = box,
		bodyDef = bodyDef,
		motionType = motionType,
		object = object,
		world = worldData,
		lastW = x,
		lastH = y,
	}

	bodies[object] = data
	return data
end

local function updateBodyShape(bodyData)
	local object = bodyData.object
	if not object or not object.AbsoluteSize then
		return false
	end

	local x = object.AbsoluteSize.X
	local y = object.AbsoluteSize.Y

	if bodyData.lastW == x and bodyData.lastH == y then
		return false
	end

	bodyData.lastW = x
	bodyData.lastH = y

	if bodyData.shapeID == zune.ffi.null then
		return false
	end

	local box = box2d.lib.b2MakeBox(x / 2, y / 2)
	bodyData.box = box

	if box2d.lib.b2Shape_SetPolygon then
		box2d.lib.b2Shape_SetPolygon(bodyData.shapeID, box)
	end

	if box2d.lib.b2Body_ApplyMassFromShapes and bodyData.motionType == 2 then
		box2d.lib.b2Body_ApplyMassFromShapes(bodyData.bodyID)
	end

	return true
end

local function syncBodyFromObject(bodyData)
	local object = bodyData.object
	if not object or not object.AbsolutePosition or not object.AbsoluteSize then
		return false
	end

	local x = object.AbsolutePosition.X + object.AbsoluteSize.X / 2
	local y = object.AbsolutePosition.Y + object.AbsoluteSize.Y / 2
	local _, posPtr = makeVec2(x, y)
	local _, rotPtr = makeRot(math.rad(object.Rotation or 0))

	box2d.lib.b2Body_SetTransform(bodyData.bodyID, posPtr, rotPtr)
	return true
end

local function updateObjectFromBody(bodyData)
	local object = bodyData.object
	print(object)
	if not object or not object.AbsoluteSize then
		return
	end

	local pos = box2d.lib.b2Body_GetPosition(bodyData.bodyID)
	print(pos)
	if pos == zune.ffi.null then
		return
	end

	local x = pos:readf32(0)
	local y = pos:readf32(4)

	local sizeX = object.AbsoluteSize.X
	local sizeY = object.AbsoluteSize.Y

	local parentAbsX, parentAbsY = getParentAbsPos(object)
	local anchorX, anchorY = getAnchor(object)

	local topLeftX = x - sizeX / 2
	local topLeftY = y - sizeY / 2

	local posX = topLeftX - parentAbsX + sizeX * anchorX
	local posY = topLeftY - parentAbsY + sizeY * anchorY

	local newPosition = UDim2.new(object.Position.X.Scale, posX, object.Position.Y.Scale, posY)
	bodyData._ignoreChanges = true
	bodyData.world.body_update(object, newPosition)
	print(object, newPosition)

	local rot = box2d.lib.b2Body_GetRotation(bodyData.bodyID)
	if rot ~= zune.ffi.null and object.Rotation ~= nil then
		local s = rot:readf32(0)
		local c = rot:readf32(4)
		local angle = math.deg(math.atan2(s, c))
		object.Rotation = angle
	end
	bodyData._ignoreChanges = false
end

local function setBodyType(bodyData, anchored)
	local newType = anchored == false and 2 or 0
	if bodyData.motionType == newType then
		return
	end
	bodyData.motionType = newType
	if box2d.lib.b2Body_SetType then
		box2d.lib.b2Body_SetType(bodyData.bodyID, makeI32(newType))
	end
	if box2d.lib.b2Body_SetAwake then
		box2d.lib.b2Body_SetAwake(bodyData.bodyID, 1)
	end
	if anchored == true then
		syncBodyFromObject(bodyData)
	end
end

local function destroyBody(worldData, object)
	local bodyData = worldData.bodies[object]
	if not bodyData then
		return
	end

	if bodyData.connection then
		bodyData.connection:Disconnect()
	end
	if bodyData.destroyConnection then
		bodyData.destroyConnection:Disconnect()
	end

	if bodyData.bodyID ~= zune.ffi.null then
		box2d.lib.b2DestroyBody(bodyData.bodyID)
	end

	worldData.bodies[object] = nil
	if worldData.object and worldData.object.Bodies then
		worldData.object.Bodies[object] = nil
	end
	bodies[object] = nil

	if object then
		object.BodyID = nil
	end
end

local function registerBody(worldData, object)
	dbg("Register attempt:", object)

	if not isBodyCandidate(object, worldData.object) then
		dbg("Rejected body:", object)
		return
	end

	if worldData.bodies[object] then
		dbg("Already registered:", object)
		return
	end

	local bodyData = createBody(object, worldData)
	if not bodyData then
		dbg("Failed to create body:", object)
		return
	end

	dbg("Body created:", object, "ID:", bodyData.bodyID)

	worldData.bodies[object] = bodyData

	if worldData.object and worldData.object.Bodies then
		worldData.object.Bodies[object] = true
	end

	bodyData.connection = object.Changed:Connect(function(property)
		if bodyData._ignoreChanges then
			return
		end

		dbg("Property changed:", object, property)

		if property == "Anchored" then
			setBodyType(bodyData, object.Anchored)
		elseif property == "Size" then
			bodyData._shapeDirty = true
		elseif property == "Position" or property == "Rotation" or property == "AnchorPoint" then
			bodyData._transformDirty = true
		elseif
			property == "Density"
			or property == "Friction"
			or property == "Restitution"
			or property == "IsSensor"
		then
			bodyData._shapeDirty = true
		end
	end)

	bodyData.destroyConnection = object.Destroying:Connect(function()
		dbg("Destroying body:", object)
		destroyBody(worldData, object)
	end)
end
local function clearWorldBodies(worldData)
	local toRemove = {}
	for object in pairs(worldData.bodies) do
		table.insert(toRemove, object)
	end
	for _, object in ipairs(toRemove) do
		destroyBody(worldData, object)
	end
end

local function applyWorldSettings(worldData, property)
	local worldObject = worldData.object

	if property == "Gravity" or property == nil then
		local _, gravPtr = makeVec2(worldObject.Gravity.X or 0, worldObject.Gravity.Y or -9.81)
		box2d.lib.b2World_SetGravity(worldData.worldId, gravPtr)
	end

	if property == "enableSleep" or property == "AllowSleep" or property == nil then
		if box2d.lib.b2World_EnableSleeping then
			local allowSleep = worldObject.AllowSleep
			if allowSleep == nil then
				allowSleep = worldObject.enableSleep
			end
			box2d.lib.b2World_EnableSleeping(worldData.worldId, allowSleep and 1 or 0)
		end
	end

	if property == "enableContinuous" or property == nil then
		if box2d.lib.b2World_EnableContinuous then
			box2d.lib.b2World_EnableContinuous(worldData.worldId, worldObject.enableContinuous and 1 or 0)
		end
	end

	if property == "restitutionThreshold" or property == nil then
		if box2d.lib.b2World_SetRestitutionThreshold then
			box2d.lib.b2World_SetRestitutionThreshold(worldData.worldId, worldObject.restitutionThreshold or 1.0)
		end
	end

	if property == "hitEventThreshold" or property == nil then
		if box2d.lib.b2World_SetHitEventThreshold then
			box2d.lib.b2World_SetHitEventThreshold(worldData.worldId, worldObject.hitEventThreshold or 0.0)
		end
	end

	if property == "maximumLinearSpeed" or property == nil then
		if box2d.lib.b2World_SetMaximumLinearSpeed then
			box2d.lib.b2World_SetMaximumLinearSpeed(worldData.worldId, worldObject.maximumLinearSpeed or 40.0)
		end
	end
end

Box2DService.InitRenderer = function(renderer, renderer_signal, game)
	Box2DService:SetProperties({
		lib = renderer.lib,
		const = renderer.const,
		structs = renderer.structs,
		init = function(World2D, body_update)
			local grav, ptr = makeVec2(World2D.Gravity.X or 0, World2D.Gravity.Y or -9.81)

			debugstep()
			local motionLocks = World2D.MotionLocks or {}
			local enableSleep = World2D.enableSleep
			if enableSleep == nil then
				enableSleep = World2D.AllowSleep
			end
			debugstep()
			local wdef = box2d.structs.b2WorldDef:new({
				gravity = ptr,
				restitutionThreshold = World2D.restitutionThreshold or 1.0,
				hitEventThreshold = World2D.hitEventThreshold or 0.0,
				contactHertz = World2D.contactHertz or 60.0,
				contactDampingRatio = World2D.contactDampingRatio or 1.0,
				maxContactPushSpeed = World2D.maxContactPushSpeed or 3.0,
				maximumLinearSpeed = World2D.maximumLinearSpeed or 40.0,
				frictionCallback = zune.ffi.null,
				restitutionCallback = zune.ffi.null,
				enableSleep = enableSleep and 1 or 0,
				motionLocks = box2d.structs.b2MotionLocks:new({
					linearX = motionLocks.LinearX or false,
					linearY = motionLocks.LinearY or false,
					angularZ = motionLocks.AngularZ or false,
				}),
				enableContinuous = World2D.enableContinuous and 1 or 0,
				workerCount = World2D.workerCount or 0,
				enqueueTask = zune.ffi.null,
				finishTask = zune.ffi.null,
				userTaskContext = zune.ffi.null,
				userData = zune.ffi.null,
				internalValue = 0x5A55A5A5,
			})
			debugstep()
			local worldId = box2d.lib.b2CreateWorld(wdef)
			print("created world!")
			if worldId == zune.ffi.null then
				error("Failed to create Box2D world")
			end
			debugstep()
			local world_data = {
				worldId = worldId,
				object = World2D,
				body_update = body_update,
				bodies = {},
				connections = {},
			}
			debugstep()
			local previous = worldsByObject[World2D]
			if previous then
				clearWorldBodies(previous)
				if previous.connections then
					for _, connection in pairs(previous.connections) do
						connection:Disconnect()
					end
				end
				if previous.worldId and previous.worldId ~= zune.ffi.null then
					box2d.lib.b2DestroyWorld(previous.worldId)
				end
				for i, w in pairs(worlds) do
					if w.object == World2D then
						worlds[i] = world_data
						break
					end
				end
			else
				table.insert(worlds, world_data)
			end
			debugstep()
			worldsByObject[World2D] = world_data
			World2D._world = world_data
			debugstep()
			local function waitForAbsolute(object)
				if object.BaseClass == "UIContainer" then
					return false
				end
				if object.AbsolutePosition then
					return true
				end
				repeat
					task.wait()
				until object.AbsolutePosition
				return true
			end
			debugstep()
			for _, object in pairs(World2D:GetChildren()) do
				if waitForAbsolute(object) then
					registerBody(world_data, object)
				end
			end
			debugstep()
			world_data.connections.childAdded = World2D.ChildAdded:Connect(function(child)
				dbg("Child added:", child)

				if waitForAbsolute(child) then
					dbg("Child ready, registering:", child)
					registerBody(world_data, child)
				else
					dbg("Child NOT ready:", child)
				end
			end)
			debugstep()
			world_data.connections.childRemoved = World2D.ChildRemoved:Connect(function(child)
				destroyBody(world_data, child)
			end)
			debugstep()
			world_data.connections.changed = World2D.Changed:Connect(function(property)
				applyWorldSettings(world_data, property)
			end)
			debugstep()
			applyWorldSettings(world_data)
			debugstep()
			World2D.AddBody = function(_, body)
				if body and body.Parent ~= world_data.object then
					body.Parent = world_data.object
				end
				registerBody(world_data, body)
			end
			debugstep()
			World2D.RemoveBody = function(_, body)
				destroyBody(world_data, body)
			end
			debugstep()
			World2D.Clear = function()
				clearWorldBodies(world_data)
			end
			debugstep()
			World2D.Step = function(_, dt)
				if not dt or dt <= 0 then
					return
				end

				box2d.lib.b2World_Step(world_data.worldId, dt, world_data.object.VelocityIterations or 4)
				world_data.object.ElapsedTime += dt
				for _, body in pairs(world_data.bodies) do
					if body._shapeDirty then
						if updateBodyShape(body) then
							body._shapeDirty = false
						end
					end
					if body._transformDirty then
						if syncBodyFromObject(body) then
							body._transformDirty = false
						end
					end
					if body.object and body.object.Anchored == true then
						syncBodyFromObject(body)
					else
						updateObjectFromBody(body)
					end
				end
			end
			debugstep()
			print("created world")
			return worldId
		end,
	})

	renderer_signal:Connect(function(route, dt)
		if route ~= "RenderStepped" then
			return
		end

		for _, world in pairs(worlds) do
			local worldObject = world.object
			if worldObject.Paused then
				continue
			end

			local scale = worldObject.TimeScale or 1
			local stepDt = (worldObject.FixedDeltaTime or dt) * scale
			if stepDt <= 0 then
				continue
			end

			if worldObject.FixedDeltaTime and worldObject.FixedDeltaTime > 0 then
				worldObject.Accumulator = (worldObject.Accumulator or 0) + dt * scale
				local maxSteps = 8
				local steps = 0
				while worldObject.Accumulator >= worldObject.FixedDeltaTime do
					box2d.lib.b2World_Step(
						world.worldId,
						worldObject.FixedDeltaTime,
						worldObject.VelocityIterations or 4
					)
					worldObject.Accumulator -= worldObject.FixedDeltaTime
					worldObject.ElapsedTime += worldObject.FixedDeltaTime
					steps += 1
					if steps >= maxSteps then
						worldObject.Accumulator = 0
						break
					end
				end
			else
				box2d.lib.b2World_Step(world.worldId, stepDt, worldObject.VelocityIterations or 4)
				worldObject.ElapsedTime += stepDt
			end

			for _, body in pairs(world.bodies) do
				if body._shapeDirty then
					if updateBodyShape(body) then
						body._shapeDirty = false
					end
				end
				if body._transformDirty then
					if syncBodyFromObject(body) then
						body._transformDirty = false
					end
				end

				if body.object and body.object.Anchored == true then
					syncBodyFromObject(body)
				else
					updateObjectFromBody(body)
				end
			end
		end
	end)

	table.insert(game.ShutdownCallbacks, function()
		for _, world in pairs(worlds) do
			clearWorldBodies(world)
			box2d.lib.b2DestroyWorld(world.worldId)
		end
		bodies = {}
		worlds = {}
		worldsByObject = {}
	end)
end

return Box2DService
