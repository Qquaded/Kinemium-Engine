local Instance = require("@Instance")
local UDim2 = require("@UDim2")
local Enum = require("@Enum")
local task = zune.task

local Box2DService = Instance.new("Box2DService")
Box2DService.ExplorerHidden = true
Box2DService._Intents = Enum.PluginIntents.Physics

local bufferUtils = require("@bufferUtils")
local box2d = require("@box2d")

local bodies = {} -- [GuiObject] = bodyData
local worlds = {} -- array of worldData
local worldsByObject = {} -- [World2D] = worldData

-- ============================================================================
-- FFI helpers
-- ============================================================================

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

-- ============================================================================
-- Object helpers
-- ============================================================================

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

-- ============================================================================
-- Shape material
-- ============================================================================

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

-- ============================================================================
-- Body lifecycle
-- ============================================================================

local function createBody(object, worldData)
	if not object.AbsoluteSize then
		return
	end

	local x = object.AbsoluteSize.X
	local y = object.AbsoluteSize.Y
	local motionType = object.Anchored == false and 2 or 0

	local posX = object.AbsolutePosition.X + x / 2
	local posY = object.AbsolutePosition.Y + y / 2

	local _, positionPtr = makeVec2(posX, posY)
	local _, rotationPtr = makeRot(math.rad(object.Rotation or 0))
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
	if not object or not object.AbsoluteSize then
		return
	end

	local pos = box2d.lib.b2Body_GetPosition(bodyData.bodyID)
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

	local rot = box2d.lib.b2Body_GetRotation(bodyData.bodyID)
	if rot ~= zune.ffi.null and object.Rotation ~= nil then
		local s = rot:readf32(0)
		local c = rot:readf32(4)
		object.Rotation = math.deg(math.atan2(s, c))
	end
	bodyData._ignoreChanges = false
end

-- ============================================================================
-- Body type & property changes
-- ============================================================================

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

-- ============================================================================
-- World body management
-- ============================================================================

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
	if not object then
		return false
	end
	if object == worldData.object then
		return false
	end
	if object.BaseClass == "UIContainer" then
		return false
	end
	if object.Parent ~= worldData.object then
		return false
	end
	if worldData.bodies[object] then
		return true
	end

	-- Can't register yet if AbsoluteSize hasn't been computed by the renderer
	if not object.AbsoluteSize then
		return false
	end

	local bodyData = createBody(object, worldData)
	if not bodyData then
		return false
	end

	worldData.bodies[object] = bodyData

	if worldData.object and worldData.object.Bodies then
		worldData.object.Bodies[object] = true
	end

	bodyData.connection = object.Changed:Connect(function(property)
		if bodyData._ignoreChanges then
			return
		end

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
		destroyBody(worldData, object)
	end)

	return true
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

-- ============================================================================
-- Per-frame body sync (shared between manual Step and RenderStepped)
-- ============================================================================

local function processWorld(worldData)
	-- Flush pending children whose AbsoluteSize is now available
	if worldData.pendingChildren then
		local stillPending = {}
		for _, child in ipairs(worldData.pendingChildren) do
			if child.Parent ~= worldData.object then
				-- removed before it could be registered, skip
			elseif not registerBody(worldData, child) then
				table.insert(stillPending, child)
			end
		end
		worldData.pendingChildren = stillPending
	end

	-- Sync registered bodies
	for _, body in pairs(worldData.bodies) do
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

-- ============================================================================
-- World settings
-- ============================================================================

local function resolveAllowSleep(worldObject)
	local allowSleep = worldObject.AllowSleep
	if allowSleep == nil then
		allowSleep = worldObject.enableSleep
	end
	return allowSleep
end

local function applyWorldSettings(worldData, property)
	local worldObject = worldData.object

	if property == "Gravity" or property == nil then
		local _, gravPtr = makeVec2(worldObject.Gravity.X or 0, worldObject.Gravity.Y or 981)
		box2d.lib.b2World_SetGravity(worldData.worldId, gravPtr)
	end

	if property == "enableSleep" or property == "AllowSleep" or property == nil then
		if box2d.lib.b2World_EnableSleeping then
			box2d.lib.b2World_EnableSleeping(worldData.worldId, resolveAllowSleep(worldObject) and 1 or 0)
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
			box2d.lib.b2World_SetMaximumLinearSpeed(worldData.worldId, worldObject.maximumLinearSpeed or 4000.0)
		end
	end
end

-- ============================================================================
-- InitRenderer (public entry point)
-- ============================================================================

Box2DService.InitRenderer = function(renderer, renderer_signal, game)
	Box2DService:SetProperties({
		lib = renderer.lib,
		const = renderer.const,
		structs = renderer.structs,

		init = function(World2D, body_update)
			local _, gravPtr = makeVec2(World2D.Gravity.X or 0, World2D.Gravity.Y or 981)

			local motionLocks = World2D.MotionLocks or {}
			local enableSleep = resolveAllowSleep(World2D)

			local wdef = box2d.structs.b2WorldDef:new({
				gravity = gravPtr,
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

			local worldId = box2d.lib.b2CreateWorld(wdef)
			if worldId == zune.ffi.null then
				error("Failed to create Box2D world")
			end

			local world_data = {
				worldId = worldId,
				object = World2D,
				body_update = body_update,
				bodies = {},
				connections = {},
				pendingChildren = {},
			}

			-- Replace previous world if re-initialized
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

			worldsByObject[World2D] = world_data
			World2D._world = world_data

			-- Register existing children (queue those not yet renderable)
			for _, child in pairs(World2D:GetChildren()) do
				if
					not registerBody(world_data, child)
					and child.Parent == World2D
					and child.BaseClass ~= "UIContainer"
				then
					table.insert(world_data.pendingChildren, child)
				end
			end

			-- Listen for new / removed children
			world_data.connections.childAdded = World2D.ChildAdded:Connect(function(child)
				if
					not registerBody(world_data, child)
					and child.Parent == World2D
					and child.BaseClass ~= "UIContainer"
				then
					table.insert(world_data.pendingChildren, child)
				end
			end)

			world_data.connections.childRemoved = World2D.ChildRemoved:Connect(function(child)
				destroyBody(world_data, child)
			end)

			-- React to world property changes
			world_data.connections.changed = World2D.Changed:Connect(function(property)
				applyWorldSettings(world_data, property)
			end)

			applyWorldSettings(world_data)

			-- Public API on the World2D object
			World2D.AddBody = function(_, body)
				if body and body.Parent ~= world_data.object then
					body.Parent = world_data.object
				end
				registerBody(world_data, body)
			end

			World2D.RemoveBody = function(_, body)
				destroyBody(world_data, body)
			end

			World2D.Clear = function()
				clearWorldBodies(world_data)
			end

			World2D.Step = function(_, dt)
				if not dt or dt <= 0 then
					return
				end
				box2d.lib.b2World_Step(world_data.worldId, dt, world_data.object.VelocityIterations or 4)
				world_data.object.ElapsedTime += dt
				processWorld(world_data)
			end

			return worldId
		end,
	})

	-- Automatic stepping on RenderStepped
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

			processWorld(world)
		end
	end)

	-- Cleanup on shutdown
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
