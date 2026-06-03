-- Impulse3D Physics Solver
-- devcell

local physics = {}

local Vector3, CFrame, Utility = require("@Vector3"), require("@CFrame"), require("./utility")
local Vector3Double = Utility.Vector3Double
local joints = require("./joints")
local Broadphase = require("./broadphase")

export type BodyManager = typeof(require("./body"))
export type JointManager = typeof(joints)
export type Vector3Double = typeof(Vector3Double.new(0, 0, 0))

physics.gravity = Vector3Double.new(0, -9.81, 0)
physics.wind_direction = Vector3Double.new(0, 0, 0)
physics.render = nil -- optional: (id, body, dt) -> ()
physics.hertz = 60
physics.substeps = 4
physics.accumulator = 0
physics.constraintIterations = 4
physics.jointWarmStarting = true
physics.broadphaseCellSize = 4

local _broadphase = Broadphase.new(physics.broadphaseCellSize)
local _activeContacts = {}

-- Helpers

local function canCollide(bodyA, bodyB): boolean
	if bodyA.bodyType == "static" and bodyB.bodyType == "static" then
		return false
	end
	-- Bitmask: A collides with B's group, and B collides with A's group
	local maskOk = (bit32.band(bodyA.collisionMask, bodyB.collisionGroup) ~= 0)
		and (bit32.band(bodyB.collisionMask, bodyA.collisionGroup) ~= 0)
	return maskOk
end

local function pairKey(a, b): number
	-- a < b guaranteed by broadphase
	return a * 1000000007 + b
end

local function resolveImpulse(bodyA, bodyB, normal, penetration)
	local relVel = bodyA.velocity - bodyB.velocity
	local velAlongNorm = Vector3Double.dot(relVel, normal)

	-- Only resolve if bodies are approaching
	if velAlongNorm > 0 then
		return
	end

	local restitution = math.min(bodyA.restitution, bodyB.restitution)
	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInvMass = invMassA + invMassB

	if totalInvMass < 1e-9 then
		return
	end

	-- Impulse scalar (correct mass weighting)
	local j = -(1 + restitution) * velAlongNorm / totalInvMass

	local impulse = normal * j

	if bodyA.bodyType ~= "static" then
		bodyA.velocity = bodyA.velocity + impulse * invMassA
	end
	if bodyB.bodyType ~= "static" then
		bodyB.velocity = bodyB.velocity - impulse * invMassB
	end

	-- Friction
	Utility.ResolveFriction(bodyA, bodyB, normal, j)

	-- Positional correction (Baumgarte-like, slop = 0.005)
	local SLOP = 0.005
	local CORRECTION = 0.4
	if penetration > SLOP then
		local corr = (penetration - SLOP) * CORRECTION / totalInvMass
		if bodyA.bodyType ~= "static" then
			bodyA.position = bodyA.position + normal * (corr * invMassA)
		end
		if bodyB.bodyType ~= "static" then
			bodyB.position = bodyB.position - normal * (corr * invMassB)
		end
	end
end

-- Collision Narrowphase

local function narrowphase(bodyA, bodyB)
	local shapeA = bodyA.shape or "box"
	local shapeB = bodyB.shape or "box"

	local normal, penetration

	if shapeA == "sphere" and shapeB == "sphere" then
		normal, penetration = Utility.resolveSphereSphere(bodyA, bodyB)
	elseif shapeA == "sphere" and shapeB == "box" then
		normal, penetration = Utility.resolveSpherAABB(bodyA, bodyB)
	elseif shapeA == "box" and shapeB == "sphere" then
		-- Flip normal direction for consistent convention
		local n, p = Utility.resolveSpherAABB(bodyB, bodyA)
		if n then
			normal, penetration = Vector3Double.neg(n), p
		end
	else
		-- Both boxes
		if
			not Utility.AABBOverlap(
				{ pos = bodyA.position, size = bodyA.size },
				{ pos = bodyB.position, size = bodyB.size }
			)
		then
			return nil
		end
		normal, penetration = Utility.resolveCollision(bodyA, bodyB)
	end

	if not normal or not penetration or penetration <= 0 then
		return nil
	end

	return normal, penetration
end

-- Step

function physics.step(body_manager: BodyManager, joint_manager: JointManager?, dt: number)
	dt = math.min(dt, 0.1)

	-- Re-create broadphase if cell size changed
	if _broadphase.cellSize ~= physics.broadphaseCellSize then
		_broadphase = Broadphase.new(physics.broadphaseCellSize)
	end

	physics.accumulator += dt

	local subDt = 1 / (physics.hertz * physics.substeps)

	while physics.accumulator >= subDt do
		physics.substep(body_manager, joint_manager, subDt)
		physics.accumulator -= subDt
	end
end

function physics.substep(body_manager: BodyManager, joint_manager: JointManager?, dt: number)
	--  1. Integrate forces & apply gravity/wind
	for id, body in pairs(body_manager.pool) do
		if body.isSleeping or body.bodyType ~= "dynamic" then
			continue
		end

		body.velocity = body.velocity + physics.gravity * dt
		body.velocity = body.velocity + physics.wind_direction * dt

		-- Air damping (frame-rate independent)
		local drag = math.pow(0.99, dt * physics.hertz)
		body.velocity = body.velocity * drag

		-- Accumulated forces
		if #body.forces > 0 then
			for _, force in ipairs(body.forces) do
				body.velocity = body.velocity + force * dt * (body.invMass or 1)
			end
			table.clear(body.forces)
		end
	end

	--  2. Kinematic bodies
	for id, body in pairs(body_manager.pool) do
		if body.isSleeping or body.bodyType ~= "kinematic" then
			continue
		end
		body.velocity = body.velocity * math.pow(0.99, dt * physics.hertz)
	end

	--  3. Integrate positions
	for id, body in pairs(body_manager.pool) do
		if body.isSleeping or body.bodyType == "static" then
			continue
		end
		body.position = body.position + body.velocity * dt

		-- Angular integration (skip if effectively zero)
		local avSq = Vector3Double.magnitudeSquared(body.angularVelocity)
		if avSq > 1e-10 then
			body.orientation = body.orientation
				* CFrame.fromEulerAnglesXYZ(
					body.angularVelocity.X * dt,
					body.angularVelocity.Y * dt,
					body.angularVelocity.Z * dt
				)
		end
	end

	--  4. Broadphase
	_broadphase:clear()
	for id, body in pairs(body_manager.pool) do
		if not body.isSleeping then
			local sz = (body.shape == "sphere") and Vector3Double.new(body.radius * 2, body.radius * 2, body.radius * 2)
				or body.size
			_broadphase:insert(id, body.position, sz)
		end
	end

	--  5. Narrowphase collision resolution
	local newContacts = {}

	for _, pair in ipairs(_broadphase:queryPairs()) do
		local idA, idB = pair[1], pair[2]
		local bodyA = body_manager.get(idA)
		local bodyB = body_manager.get(idB)

		if not bodyA or not bodyB then
			continue
		end
		if not canCollide(bodyA, bodyB) then
			continue
		end

		local normal, penetration = narrowphase(bodyA, bodyB)
		if not normal then
			continue
		end

		-- CCD guard: skip pairs where swept test would reject (already separated)
		-- (broadphase overlap already implies proximity; full CCD would be a separate pass)

		resolveImpulse(bodyA, bodyB, normal, penetration)

		-- Collision callbacks tracking
		local key = pairKey(idA, idB)
		newContacts[key] = { normal = normal, penetration = penetration, a = idA, b = idB }

		if _activeContacts[key] then
			-- stay
			if bodyA.onCollisionStay then
				bodyA.onCollisionStay(idA, idB, normal, penetration)
			end
			if bodyB.onCollisionStay then
				bodyB.onCollisionStay(idB, idA, -normal, penetration)
			end
		else
			-- enter
			if bodyA.onCollisionEnter then
				bodyA.onCollisionEnter(idA, idB, normal, penetration)
			end
			if bodyB.onCollisionEnter then
				bodyB.onCollisionEnter(idB, idA, -normal, penetration)
			end
		end
	end

	-- Fire exit callbacks for pairs that ended this frame
	for key, contact in pairs(_activeContacts) do
		if not newContacts[key] then
			local bodyA = body_manager.get(contact.a)
			local bodyB = body_manager.get(contact.b)
			if bodyA and bodyA.onCollisionExit then
				bodyA.onCollisionExit(contact.a, contact.b, contact.normal, contact.penetration)
			end
			if bodyB and bodyB.onCollisionExit then
				bodyB.onCollisionExit(contact.b, contact.a, -contact.normal, contact.penetration)
			end
		end
	end

	_activeContacts = newContacts

	--  6. Floor constraint
	for id, body in pairs(body_manager.pool) do
		if body.bodyType == "static" or body.isSleeping then
			continue
		end

		local floor
		if body.shape == "sphere" then
			floor = body.radius
		else
			floor = body.size.Y * 0.5
		end

		if body.position.Y - floor <= 0 then
			body.position = Vector3Double.new(body.position.X, floor, body.position.Z)
			local restitution = body.restitution or 0.3
			local friction = body.friction or 0.5

			if body.velocity.Y < 0 then
				body.velocity = Vector3Double.new(body.velocity.X, -body.velocity.Y * restitution, body.velocity.Z)
			end

			-- Horizontal friction against floor
			local drag = math.pow(1 - friction, dt * physics.hertz)
			body.velocity = Vector3Double.new(body.velocity.X * drag, body.velocity.Y, body.velocity.Z * drag)
		end
	end

	--  7. Solve joints
	if joint_manager then
		joints.solveAll(body_manager, dt, physics.constraintIterations)
	end

	--  8. Sleep state update
	for id, _ in pairs(body_manager.pool) do
		body_manager.updateSleepState(id, dt)
	end

	--  9. Render callback
	if physics.render then
		for id, body in pairs(body_manager.pool) do
			physics.render(id, body, dt)
		end
	end
end

-- Force / Impulse API

function physics.applyImpulse(body, impulse: Vector3Double)
	if body.bodyType == "static" then
		return
	end
	body.velocity = body.velocity + impulse * (body.invMass or 1)
end

function physics.applyForce(body, force: Vector3Double, dt: number)
	if body.bodyType == "static" then
		return
	end
	body.velocity = body.velocity + force * dt * (body.invMass or 1)
end

function physics.applyTorque(body, torque: Vector3Double, dt: number)
	if body.bodyType == "static" then
		return
	end
	body.angularVelocity = body.angularVelocity + torque * dt
end

-- Raycasting

export type RaycastResult = {
	bodyId: number,
	point: Vector3Double,
	normal: Vector3Double,
	t: number,
}

-- Casts a ray and returns the closest hit, or nil
function physics.raycast(
	body_manager: BodyManager,
	origin: Vector3Double,
	direction: Vector3Double,
	maxDist: number?
): RaycastResult?
	local maxT = maxDist or math.huge
	local dirUnit = direction:Unit()

	local bestT = maxT
	local bestResult: RaycastResult? = nil

	for id, body in pairs(body_manager.pool) do
		local hit, t, _, normal

		if body.shape == "sphere" then
			hit, t, normal = Utility.RaySphereIntersection(origin, dirUnit, body.position, body.radius)
		else
			hit, t, _, normal = Utility.RayAABBIntersection(origin, dirUnit, { pos = body.position, size = body.size })
		end

		if hit and t >= 0 and t < bestT then
			bestT = t
			bestResult = {
				bodyId = id,
				point = origin + dirUnit * t,
				normal = normal,
				t = t,
			}
		end
	end

	return bestResult
end

-- Reset

function physics.reset(body_manager: BodyManager, joint_manager: JointManager?)
	body_manager.clear()
	if joint_manager then
		joint_manager.clear()
	end
	physics.accumulator = 0
	table.clear(_activeContacts)
	_broadphase:clear()
end

return physics
