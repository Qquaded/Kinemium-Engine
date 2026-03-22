-- Impulse3D Body Manager
-- devcell

local body = {
	pool = {},
}

local Vector3 = require("@Vector3")
local utility = require("./utility")
local Vector3Double = utility.Vector3Double

export type Vector3 = typeof(require("@Vector3"))
export type Vector3Double = typeof(Vector3Double.new(0, 0, 0))

export type BodyType = "static" | "dynamic" | "kinematic"
export type BodyShape = "box" | "sphere"

export type CollisionCallback = (selfId: number, otherId: number, normal: Vector3Double, penetration: number) -> ()

export type Body = {
	-- Shape
	shape: BodyShape, -- "box" (default) or "sphere"
	size: Vector3Double, -- half-extents for box; ignored for sphere
	radius: number, -- used when shape == "sphere"

	-- Transform
	position: Vector3Double,
	orientation: CFrame,

	-- Dynamics
	velocity: Vector3Double,
	angularVelocity: Vector3Double,
	forces: { Vector3Double },

	-- Mass / Material
	mass: number, -- 0 = infinite (static)
	invMass: number, -- cached 1/mass; 0 for static/infinite
	restitution: number, -- bounciness [0..1]
	friction: number, -- surface friction coefficient [0..1]

	-- Collision filtering
	collisionGroup: number, -- bitmask: which group this body belongs to
	collisionMask: number, -- bitmask: which groups this body collides with

	-- Sleep
	isSleeping: boolean,
	sleepTimer: number,
	linearVelocityThreshold: number,
	angularVelocityThreshold: number,

	-- Continuous Collision Detection
	ccdEnabled: boolean,

	-- Type
	bodyType: BodyType,

	-- Callbacks (optional)
	onCollisionEnter: CollisionCallback?,
	onCollisionStay: CollisionCallback?,
	onCollisionExit: CollisionCallback?,

	-- Internal
	id: number,
}

body._lastId = 0

function body.new(data: Body): number
	local clone = table.clone(data)
	body._lastId += 1
	clone.id = body._lastId

	-- Body type
	clone.bodyType = data.bodyType or "dynamic"

	-- Shape defaults
	clone.shape = data.shape or "box"
	if clone.shape == "sphere" then
		clone.radius = data.radius or 0.5
		clone.size = Vector3Double.new(clone.radius * 2, clone.radius * 2, clone.radius * 2)
	else
		clone.size = data.size or Vector3Double.new(1, 1, 1)
	end

	-- Transform defaults
	clone.position = data.position or Vector3Double.new(0, 0, 0)
	clone.orientation = data.orientation or CFrame.new()
	clone.velocity = data.velocity or Vector3Double.new(0, 0, 0)
	clone.angularVelocity = data.angularVelocity or Vector3Double.new(0, 0, 0)
	clone.forces = data.forces or {}

	-- Mass / Material
	if clone.bodyType == "static" then
		clone.mass = 0
		clone.invMass = 0
	else
		clone.mass = data.mass or 1
		clone.invMass = (clone.mass > 0) and (1 / clone.mass) or 0
	end
	clone.restitution = data.restitution ~= nil and data.restitution or 0.3
	clone.friction = data.friction ~= nil and data.friction or 0.5

	-- Collision filtering (default: group 1, collide with everything)
	clone.collisionGroup = data.collisionGroup or 1
	clone.collisionMask = data.collisionMask ~= nil and data.collisionMask or 0xFFFFFF

	-- Sleep
	clone.isSleeping = false
	clone.sleepTimer = 0
	clone.linearVelocityThreshold = data.linearVelocityThreshold or 0.01
	clone.angularVelocityThreshold = data.angularVelocityThreshold or 0.01

	-- CCD
	clone.ccdEnabled = data.ccdEnabled or false

	body.pool[body._lastId] = clone
	return clone.id
end

-- CRUD

function body.get(id: number): Body?
	return body.pool[id]
end

function body.remove(id: number)
	body.pool[id] = nil
end

function body.edit(id: number, changes: any): Body?
	local b = body.pool[id]
	if not b then
		return nil
	end
	for k, v in pairs(changes) do
		b[k] = v
	end
	-- Re-cache invMass if mass changed
	if changes.mass ~= nil then
		b.invMass = (b.mass > 0) and (1 / b.mass) or 0
	end
	return b
end

function body.each(func: (number, Body) -> ())
	for id, obj in pairs(body.pool) do
		func(id, obj)
	end
end

-- Sleep

-- Fix: wakeUp no longer zeros velocity — preserves motion continuity
function body.wakeUp(id: number)
	local b = body.pool[id]
	if b and b.isSleeping then
		b.isSleeping = false
		b.sleepTimer = 0
	end
end

function body.putToSleep(id: number)
	local b = body.pool[id]
	if b and not b.isSleeping then
		b.isSleeping = true
		b.sleepTimer = 0
		b.velocity = Vector3Double.new(0, 0, 0)
		b.angularVelocity = Vector3Double.new(0, 0, 0)
	end
end

function body.updateSleepState(id: number, dt: number)
	local b = body.pool[id]
	if not b or b.bodyType == "static" then
		return
	end

	local linSq = Vector3Double.magnitudeSquared(b.velocity)
	local angSq = Vector3Double.magnitudeSquared(b.angularVelocity)
	local linTh = b.linearVelocityThreshold
	local angTh = b.angularVelocityThreshold

	local shouldSleep = linSq < linTh * linTh and angSq < angTh * angTh

	if shouldSleep then
		b.sleepTimer += dt
		if b.sleepTimer > 2.0 then
			body.putToSleep(id)
		end
	else
		if b.isSleeping then
			body.wakeUp(id)
		end
		b.sleepTimer = 0
	end
end

function body.isAwake(id: number): boolean
	local b = body.pool[id]
	return b ~= nil and not b.isSleeping
end

-- Pool Management

-- Resets the entire body pool (used by physics.reset)
function body.clear()
	table.clear(body.pool)
	body._lastId = 0
end

-- Returns the count of bodies currently in the pool
function body.count(): number
	local n = 0
	for _ in pairs(body.pool) do
		n += 1
	end
	return n
end

return body
