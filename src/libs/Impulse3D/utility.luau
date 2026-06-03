-- Impulse3D Utility
-- devcell

local PhysicsUtils = {}
local Vector3 = require("@Vector3")

-- Vector3Double

export type Vector3Double = {
	X: number,
	Y: number,
	Z: number,
	Magnitude: number,
	Unit: Vector3Double,
}

local Vector3Double = {}

local Vector3Double_mt = {
	__add = function(a, b)
		return Vector3Double.add(a, b)
	end,
	__sub = function(a, b)
		return Vector3Double.sub(a, b)
	end,
	__mul = function(a, b)
		if type(a) == "number" then
			return Vector3Double.mul(b, a)
		else
			return Vector3Double.mul(a, b)
		end
	end,
	__div = function(a, b)
		return Vector3Double.div(a, b)
	end,
	__unm = function(a)
		return Vector3Double.neg(a)
	end,
	__tostring = function(a)
		return string.format("<%g, %g, %g>", a.X, a.Y, a.Z)
	end,
	__index = function(vec, key)
		if key == "Magnitude" then
			return math.sqrt(vec.X ^ 2 + vec.Y ^ 2 + vec.Z ^ 2)
		elseif key == "Unit" then
			local mag = math.sqrt(vec.X ^ 2 + vec.Y ^ 2 + vec.Z ^ 2)
			if mag > 1e-9 then
				return Vector3Double.new(vec.X / mag, vec.Y / mag, vec.Z / mag)
			else
				return Vector3Double.new(0, 0, 0)
			end
		else
			return Vector3Double[key]
		end
	end,
}

function Vector3Double.new(x: number, y: number, z: number): Vector3Double
	local vec = {
		X = x or 0,
		Y = y or 0,
		Z = z or 0,
	}
	setmetatable(vec, Vector3Double_mt)
	return vec
end

function Vector3Double.fromVector3(vec: Vector3): Vector3Double
	return Vector3Double.new(vec.X, vec.Y, vec.Z)
end

function Vector3Double.toVector3(vec: Vector3Double): Vector3
	return Vector3.new(vec.X, vec.Y, vec.Z)
end

function Vector3Double.add(a: Vector3Double, b: Vector3Double): Vector3Double
	return Vector3Double.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function Vector3Double.sub(a: Vector3Double, b: Vector3Double): Vector3Double
	return Vector3Double.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function Vector3Double.mul(vec: Vector3Double, scalar: number): Vector3Double
	return Vector3Double.new(vec.X * scalar, vec.Y * scalar, vec.Z * scalar)
end

function Vector3Double.div(vec: Vector3Double, scalar: number): Vector3Double
	local inv = 1 / scalar
	return Vector3Double.new(vec.X * inv, vec.Y * inv, vec.Z * inv)
end

function Vector3Double.dot(a: Vector3Double, b: Vector3Double): number
	return a.X * b.X + a.Y * b.Y + a.Z * b.Z
end

function Vector3Double.cross(a: Vector3Double, b: Vector3Double): Vector3Double
	return Vector3Double.new(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
end

function Vector3Double.neg(vec: Vector3Double): Vector3Double
	return Vector3Double.new(-vec.X, -vec.Y, -vec.Z)
end

function Vector3Double.abs(vec: Vector3Double): Vector3Double
	return Vector3Double.new(math.abs(vec.X), math.abs(vec.Y), math.abs(vec.Z))
end

-- Linear interpolation
function Vector3Double.lerp(a: Vector3Double, b: Vector3Double, t: number): Vector3Double
	local s = 1 - t
	return Vector3Double.new(a.X * s + b.X * t, a.Y * s + b.Y * t, a.Z * s + b.Z * t)
end

-- Component-wise clamp
function Vector3Double.clamp(vec: Vector3Double, minV: Vector3Double, maxV: Vector3Double): Vector3Double
	return Vector3Double.new(
		math.clamp(vec.X, minV.X, maxV.X),
		math.clamp(vec.Y, minV.Y, maxV.Y),
		math.clamp(vec.Z, minV.Z, maxV.Z)
	)
end

-- Squared magnitude (avoids sqrt when only comparing distances)
function Vector3Double.magnitudeSquared(vec: Vector3Double): number
	return vec.X ^ 2 + vec.Y ^ 2 + vec.Z ^ 2
end

setmetatable(Vector3Double, {
	__call = function(_, x, y, z)
		return Vector3Double.new(x, y, z)
	end,
})

PhysicsUtils.Vector3Double = Vector3Double

-- AABB Utilities

function PhysicsUtils.AABBOverlap(box1, box2): boolean
	local h1x, h1y, h1z = box1.size.X * 0.5, box1.size.Y * 0.5, box1.size.Z * 0.5
	local h2x, h2y, h2z = box2.size.X * 0.5, box2.size.Y * 0.5, box2.size.Z * 0.5

	return math.abs(box1.pos.X - box2.pos.X) <= h1x + h2x
		and math.abs(box1.pos.Y - box2.pos.Y) <= h1y + h2y
		and math.abs(box1.pos.Z - box2.pos.Z) <= h1z + h2z
end

function PhysicsUtils.getAABBBounds(pos, size)
	local halfSize = size * 0.5
	return pos - halfSize, pos + halfSize
end

-- Returns (normal pointing from other→body, penetration depth)
function PhysicsUtils.resolveCollision(body, other)
	local b1min, b1max = PhysicsUtils.getAABBBounds(body.position, body.size)
	local b2min, b2max = PhysicsUtils.getAABBBounds(other.position, other.size)

	local overlapX = math.min(b1max.X - b2min.X, b2max.X - b1min.X)
	local overlapY = math.min(b1max.Y - b2min.Y, b2max.Y - b1min.Y)
	local overlapZ = math.min(b1max.Z - b2min.Z, b2max.Z - b1min.Z)

	local minOverlap = math.min(overlapX, overlapY, overlapZ)
	local normal: Vector3Double
	local penetration: number

	if minOverlap == overlapX then
		normal = Vector3Double.new(body.position.X > other.position.X and 1 or -1, 0, 0)
		penetration = overlapX
	elseif minOverlap == overlapY then
		normal = Vector3Double.new(0, body.position.Y > other.position.Y and 1 or -1, 0)
		penetration = overlapY
	else
		normal = Vector3Double.new(0, 0, body.position.Z > other.position.Z and 1 or -1)
		penetration = overlapZ
	end

	return normal, penetration
end

-- Sphere Utilities

function PhysicsUtils.SphereOverlap(sphere1, sphere2): boolean
	local dx = sphere1.pos.X - sphere2.pos.X
	local dy = sphere1.pos.Y - sphere2.pos.Y
	local dz = sphere1.pos.Z - sphere2.pos.Z
	local radiusSum = sphere1.radius + sphere2.radius
	return dx * dx + dy * dy + dz * dz <= radiusSum * radiusSum
end

-- Fixed: closest point computed with Vector3Double, not raw Vector3
function PhysicsUtils.SphereAABBOverlap(sphere, box): boolean
	local bmin = box.pos - box.size * 0.5
	local bmax = box.pos + box.size * 0.5

	local cx = math.max(bmin.X, math.min(sphere.pos.X, bmax.X))
	local cy = math.max(bmin.Y, math.min(sphere.pos.Y, bmax.Y))
	local cz = math.max(bmin.Z, math.min(sphere.pos.Z, bmax.Z))

	local dx = sphere.pos.X - cx
	local dy = sphere.pos.Y - cy
	local dz = sphere.pos.Z - cz
	return dx * dx + dy * dy + dz * dz <= sphere.radius * sphere.radius
end

-- Resolves sphere vs sphere; returns (normal from B→A, penetration)
function PhysicsUtils.resolveSphereSphere(bodyA, bodyB)
	local delta = bodyA.position - bodyB.position
	local distSq = Vector3Double.magnitudeSquared(delta)
	local radiusSum = bodyA.radius + bodyB.radius

	if distSq < 1e-12 then
		return Vector3Double.new(0, 1, 0), radiusSum
	end

	local dist = math.sqrt(distSq)
	local normal = delta / dist
	local penetration = radiusSum - dist
	return normal, penetration
end

-- Resolves sphere vs AABB; returns (normal pointing from AABB→sphere, penetration) or nil
function PhysicsUtils.resolveSpherAABB(sphere, box)
	local bmin = box.position - box.size * 0.5
	local bmax = box.position + box.size * 0.5

	local cx = math.max(bmin.X, math.min(sphere.position.X, bmax.X))
	local cy = math.max(bmin.Y, math.min(sphere.position.Y, bmax.Y))
	local cz = math.max(bmin.Z, math.min(sphere.position.Z, bmax.Z))

	local dx = sphere.position.X - cx
	local dy = sphere.position.Y - cy
	local dz = sphere.position.Z - cz
	local distSq = dx * dx + dy * dy + dz * dz

	if distSq >= sphere.radius * sphere.radius then
		return nil
	end

	local dist = math.sqrt(distSq)
	if dist < 1e-9 then
		return Vector3Double.new(0, 1, 0), sphere.radius
	end

	local normal = Vector3Double.new(dx / dist, dy / dist, dz / dist)
	return normal, sphere.radius - dist
end

-- Ray Casting

-- Intersect ray with AABB; returns (hit, tEnter, tExit, normal)
function PhysicsUtils.RayAABBIntersection(rayOrigin, rayDir, box)
	local bmin = box.pos - box.size * 0.5
	local bmax = box.pos + box.size * 0.5

	local tminX, tmaxX
	if math.abs(rayDir.X) < 1e-9 then
		if rayOrigin.X < bmin.X or rayOrigin.X > bmax.X then
			return false, 0, 0, nil
		end
		tminX, tmaxX = -math.huge, math.huge
	else
		tminX = (bmin.X - rayOrigin.X) / rayDir.X
		tmaxX = (bmax.X - rayOrigin.X) / rayDir.X
		if tminX > tmaxX then
			tminX, tmaxX = tmaxX, tminX
		end
	end

	local tminY, tmaxY
	if math.abs(rayDir.Y) < 1e-9 then
		if rayOrigin.Y < bmin.Y or rayOrigin.Y > bmax.Y then
			return false, 0, 0, nil
		end
		tminY, tmaxY = -math.huge, math.huge
	else
		tminY = (bmin.Y - rayOrigin.Y) / rayDir.Y
		tmaxY = (bmax.Y - rayOrigin.Y) / rayDir.Y
		if tminY > tmaxY then
			tminY, tmaxY = tmaxY, tminY
		end
	end

	local tminZ, tmaxZ
	if math.abs(rayDir.Z) < 1e-9 then
		if rayOrigin.Z < bmin.Z or rayOrigin.Z > bmax.Z then
			return false, 0, 0, nil
		end
		tminZ, tmaxZ = -math.huge, math.huge
	else
		tminZ = (bmin.Z - rayOrigin.Z) / rayDir.Z
		tmaxZ = (bmax.Z - rayOrigin.Z) / rayDir.Z
		if tminZ > tmaxZ then
			tminZ, tmaxZ = tmaxZ, tminZ
		end
	end

	local tEnter = math.max(tminX, tminY, tminZ)
	local tExit = math.min(tmaxX, tmaxY, tmaxZ)

	if tEnter > tExit or tExit < 0 then
		return false, 0, 0, nil
	end

	local t = tEnter >= 0 and tEnter or tExit
	local hitPoint = rayOrigin + rayDir * t

	-- Compute face normal
	local normal
	if tEnter == tminX then
		normal = Vector3Double.new(rayDir.X < 0 and 1 or -1, 0, 0)
	elseif tEnter == tminY then
		normal = Vector3Double.new(0, rayDir.Y < 0 and 1 or -1, 0)
	else
		normal = Vector3Double.new(0, 0, rayDir.Z < 0 and 1 or -1)
	end

	return true, t, tExit, normal
end

-- Intersect ray with sphere; returns (hit, t, normal)
function PhysicsUtils.RaySphereIntersection(rayOrigin, rayDir, spherePos, radius)
	local oc = rayOrigin - spherePos
	local a = Vector3Double.dot(rayDir, rayDir)
	local b = 2 * Vector3Double.dot(oc, rayDir)
	local c = Vector3Double.dot(oc, oc) - radius * radius
	local disc = b * b - 4 * a * c

	if disc < 0 then
		return false, 0, nil
	end

	local sqrtDisc = math.sqrt(disc)
	local t = (-b - sqrtDisc) / (2 * a)
	if t < 0 then
		t = (-b + sqrtDisc) / (2 * a)
	end
	if t < 0 then
		return false, 0, nil
	end

	local hitPoint = rayOrigin + rayDir * t
	local normal = (hitPoint - spherePos):Unit()
	return true, t, normal
end

-- Misc. Geometry

function PhysicsUtils.PointInAABB(point, box): boolean
	local bmin = box.pos - box.size * 0.5
	local bmax = box.pos + box.size * 0.5
	return point.X >= bmin.X
		and point.X <= bmax.X
		and point.Y >= bmin.Y
		and point.Y <= bmax.Y
		and point.Z >= bmin.Z
		and point.Z <= bmax.Z
end

function PhysicsUtils.BoxInertia(mass, size)
	local w, h, d = size.X, size.Y, size.Z
	local k = mass / 12
	return k * (h * h + d * d), k * (w * w + d * d), k * (w * w + h * h)
end

function PhysicsUtils.CenterOfMass(bodies)
	local totalMass = 0
	local com = Vector3Double.new(0, 0, 0)
	for _, body in ipairs(bodies) do
		local mass = body.mass or 1
		totalMass += mass
		com = com + body.position * mass
	end
	return totalMass > 0 and com / totalMass or Vector3Double.new(0, 0, 0)
end

function PhysicsUtils.ClampMagnitude(vec, maxMagnitude)
	local magSq = Vector3Double.magnitudeSquared(vec)
	if magSq > maxMagnitude * maxMagnitude then
		return vec / math.sqrt(magSq) * maxMagnitude
	end
	return vec
end

function PhysicsUtils.Reflect(velocity, normal)
	return velocity - normal * (2 * Vector3Double.dot(velocity, normal))
end

-- Fixed: use Vector3Double.abs instead of non-existent :Abs() method
function PhysicsUtils.SweepAABB(box, moveVec, other): boolean
	local absMove = Vector3Double.abs(moveVec)
	local expandedBox = {
		pos = box.pos + moveVec * 0.5,
		size = box.size + absMove,
	}
	return PhysicsUtils.AABBOverlap(expandedBox, other)
end

-- Fixed: use body.angularVelocity assignment, not +=
function PhysicsUtils.ApplyTorque(body, torque, dt)
	body.angularVelocity = body.angularVelocity + torque * dt
end

-- Friction resolved using the combined friction of two bodies
function PhysicsUtils.ResolveFriction(bodyA, bodyB, normal, impulseJ)
	local relVel = bodyA.velocity - bodyB.velocity
	local tangent = relVel - normal * Vector3Double.dot(relVel, normal)
	local tangentMag = tangent.Magnitude

	if tangentMag < 1e-9 then
		return
	end

	tangent = tangent / tangentMag
	local mu = (bodyA.friction or 0.5) * (bodyB.friction or 0.5)
	local frictionImpulse = math.min(mu * math.abs(impulseJ), tangentMag)

	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInvMass = invMassA + invMassB
	if totalInvMass < 1e-9 then
		return
	end

	local impulse = tangent * frictionImpulse
	if bodyA.bodyType ~= "static" then
		bodyA.velocity = bodyA.velocity - impulse * invMassA / totalInvMass
	end
	if bodyB.bodyType ~= "static" then
		bodyB.velocity = bodyB.velocity + impulse * invMassB / totalInvMass
	end
end

return PhysicsUtils
