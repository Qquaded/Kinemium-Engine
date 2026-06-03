-- Impulse3D Soft Body Simulation
-- devcell
--
-- Simulates a network of mass-spring particles (e.g. cloth, jelly, rope).
-- Each SoftBody has a list of Particles and Springs. Springs exert Hooke's law
-- forces with velocity-based damping. Integration uses semi-implicit Euler.

local softbody = {
	pool = {},
}

local utility = require("./utility")
local Vector3Double = utility.Vector3Double

export type Vector3 = typeof(require("@Vector3"))
export type Vector3Double = typeof(Vector3Double.new(0, 0, 0))

-- Type Definitions

export type Particle = {
	position: Vector3Double,
	prevPos: Vector3Double, -- used for Verlet if needed
	velocity: Vector3Double,
	mass: number,
	invMass: number, -- 0 = pinned particle
	forces: { Vector3Double },
	pinned: boolean, -- if true, particle is immovable
}

export type Spring = {
	p1: number, -- particle index (1-based)
	p2: number,
	restLength: number,
	stiffness: number,
	damping: number,
	maxForce: number?, -- optional force clamp
	broken: boolean, -- if true, spring is ignored
	breakForce: number?, -- if spring force exceeds this, mark broken
}

export type SoftBody = {
	particles: { Particle },
	springs: { Spring },
	gravity: Vector3Double?, -- optional override; uses physics.gravity if nil
	restitution: number, -- floor bounce
	friction: number, -- floor friction
}

-- CRUD

softbody._lastId = 0

function softbody.new(data: SoftBody): number
	local clone = {
		particles = data.particles,
		springs = data.springs,
		gravity = data.gravity,
		restitution = data.restitution or 0.1,
		friction = data.friction or 0.7,
	}

	-- Initialise particle defaults
	for _, p in ipairs(clone.particles) do
		p.velocity = p.velocity or Vector3Double.new(0, 0, 0)
		p.prevPos = p.prevPos or Vector3Double.new(p.position.X, p.position.Y, p.position.Z)
		p.forces = p.forces or {}
		p.pinned = p.pinned or false
		p.mass = p.mass or 1
		p.invMass = p.pinned and 0 or ((p.mass > 0) and (1 / p.mass) or 0)
	end

	-- Initialise spring defaults
	for _, s in ipairs(clone.springs) do
		s.broken = s.broken or false
		s.stiffness = s.stiffness or 100
		s.damping = s.damping or 2
	end

	softbody._lastId += 1
	clone.id = softbody._lastId
	softbody.pool[softbody._lastId] = clone
	return clone.id
end

function softbody.get(id: number): SoftBody?
	return softbody.pool[id]
end

function softbody.remove(id: number)
	softbody.pool[id] = nil
end

function softbody.edit(id: number, changes: any): SoftBody?
	local sb = softbody.pool[id]
	if not sb then
		return nil
	end
	for k, v in pairs(changes) do
		sb[k] = v
	end
	return sb
end

function softbody.each(func: (number, SoftBody) -> ())
	for id, obj in pairs(softbody.pool) do
		func(id, obj)
	end
end

function softbody.clear()
	table.clear(softbody.pool)
	softbody._lastId = 0
end

-- Simulation

-- Step a single soft body by dt seconds.
-- gravity: Vector3Double (world gravity, passed in from physics module)
function softbody.step(id: number, dt: number, gravity: Vector3Double)
	local sb = softbody.pool[id]
	if not sb then
		return
	end

	local particles = sb.particles
	local springs = sb.springs
	local grav = sb.gravity or gravity

	--  1. Accumulate spring forces
	for _, spring in ipairs(springs) do
		if spring.broken then
			continue
		end

		local p1 = particles[spring.p1]
		local p2 = particles[spring.p2]
		if not p1 or not p2 then
			continue
		end

		local delta = p2.position - p1.position
		local dist = delta:Magnitude()
		if dist < 1e-9 then
			continue
		end

		local normal = delta / dist

		-- Hooke's law
		local displacement = dist - spring.restLength
		local springF = spring.stiffness * displacement

		-- Velocity damping along the spring axis
		local relVel = p2.velocity - p1.velocity
		local velProj = Vector3Double.dot(relVel, normal)
		local dampF = spring.damping * velProj

		local totalF = springF + dampF

		-- Break check
		if spring.breakForce and math.abs(totalF) > spring.breakForce then
			spring.broken = true
			continue
		end

		if spring.maxForce then
			totalF = math.clamp(totalF, -spring.maxForce, spring.maxForce)
		end

		local forceVec = normal * totalF

		-- Equal-and-opposite: F on p1 toward p2, F on p2 toward p1
		if not p1.pinned then
			p1.forces[#p1.forces + 1] = forceVec
		end
		if not p2.pinned then
			p2.forces[#p2.forces + 1] = -forceVec
		end
	end

	--  2. Integrate particles
	for _, p in ipairs(particles) do
		if p.pinned then
			table.clear(p.forces)
			continue
		end

		-- Sum forces
		local totalForce = grav * p.mass -- gravity
		for _, f in ipairs(p.forces) do
			totalForce = totalForce + f
		end
		table.clear(p.forces)

		-- Semi-implicit Euler: update velocity, then position
		local accel = totalForce * p.invMass
		p.velocity = p.velocity + accel * dt

		-- Light air damping
		p.velocity = p.velocity * 0.995

		p.prevPos = p.position
		p.position = p.position + p.velocity * dt

		--  3. Floor constraint
		if p.position.Y <= 0 then
			p.position = Vector3Double.new(p.position.X, 0, p.position.Z)
			if p.velocity.Y < 0 then
				p.velocity = Vector3Double.new(p.velocity.X, -p.velocity.Y * sb.restitution, p.velocity.Z)
			end
			-- Horizontal friction
			local drag = math.pow(1 - sb.friction, dt * 60)
			p.velocity = Vector3Double.new(p.velocity.X * drag, p.velocity.Y, p.velocity.Z * drag)
		end
	end
end

-- Step ALL soft bodies
function softbody.stepAll(dt: number, gravity: Vector3Double)
	for id, _ in pairs(softbody.pool) do
		softbody.step(id, dt, gravity)
	end
end

-- Utilities

-- Apply an impulse to a single particle (useful for user interaction)
function softbody.applyImpulse(id: number, particleIdx: number, impulse: Vector3Double)
	local sb = softbody.pool[id]
	if not sb then
		return
	end
	local p = sb.particles[particleIdx]
	if not p or p.pinned then
		return
	end
	p.velocity = p.velocity + impulse * p.invMass
end

-- Pin or unpin a particle
function softbody.setPin(id: number, particleIdx: number, pinned: boolean)
	local sb = softbody.pool[id]
	if not sb then
		return
	end
	local p = sb.particles[particleIdx]
	if not p then
		return
	end
	p.pinned = pinned
	p.invMass = pinned and 0 or ((p.mass > 0) and (1 / p.mass) or 0)
end

-- Get centre of mass of a soft body
function softbody.getCenterOfMass(id: number): Vector3Double?
	local sb = softbody.pool[id]
	if not sb then
		return nil
	end
	local totalMass = 0
	local com = Vector3Double.new(0, 0, 0)
	for _, p in ipairs(sb.particles) do
		totalMass += p.mass
		com = com + p.position * p.mass
	end
	return totalMass > 0 and com / totalMass or Vector3Double.new(0, 0, 0)
end

return softbody
