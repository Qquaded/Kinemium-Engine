-- Impulse3D Joint & Constraint System
-- devcell

local joints = {
	pool = {},
}

local utility = require("./utility")
local Vector3Double = utility.Vector3Double

export type Vector3Double = typeof(Vector3Double.new(0, 0, 0))

-- Baumgarte stabilization coefficient
local BAUMGARTE = 0.1

-- Type Definitions

export type Joint = {
	bodyA: number,
	bodyB: number,
	anchorA: Vector3Double,
	anchorB: Vector3Double,
	enabled: boolean,
}

export type HingeJoint = Joint & {
	type: "hinge",
	axis: Vector3Double,
	limits: { min: number, max: number }?,
	motor: { speed: number, torque: number }?,
}

export type SpringJoint = Joint & {
	type: "spring",
	restLength: number,
	stiffness: number,
	damping: number,
	maxForce: number?, -- optional clamp
}

export type FixedJoint = Joint & {
	type: "fixed",
}

export type BallJoint = Joint & {
	type: "ball",
	limits: { twistMin: number, twistMax: number, swingMin: number, swingMax: number }?,
}

export type SliderJoint = Joint & {
	type: "slider",
	axis: Vector3Double,
	limits: { min: number, max: number }?,
	motor: { speed: number, force: number }?,
}

export type WheelJoint = Joint & {
	type: "wheel",
	axis: Vector3Double,
	suspension: { restLength: number, stiffness: number, damping: number },
	motor: { speed: number, torque: number }?,
	brake: { torque: number }?,
}

export type PistonJoint = Joint & {
	type: "piston",
	axis: Vector3Double,
	limits: { min: number, max: number }?,
	motor: { speed: number, force: number, torque: number }?,
}

export type UniversalJoint = Joint & {
	type: "universal",
	axis1: Vector3Double,
	axis2: Vector3Double,
}

export type AnyJoint =
	HingeJoint
	| SpringJoint
	| FixedJoint
	| BallJoint
	| SliderJoint
	| WheelJoint
	| PistonJoint
	| UniversalJoint

-- CRUD

joints._lastId = 0

function joints.new(data: AnyJoint): number
	local clone = table.clone(data)
	joints._lastId += 1
	clone.id = joints._lastId
	clone.enabled = data.enabled ~= false -- default true
	joints.pool[joints._lastId] = clone
	return clone.id
end

function joints.get(id: number): AnyJoint?
	return joints.pool[id]
end

function joints.remove(id: number)
	joints.pool[id] = nil
end

function joints.edit(id: number, changes: any): AnyJoint?
	local j = joints.pool[id]
	if not j then
		return nil
	end
	for k, v in pairs(changes) do
		j[k] = v
	end
	return j
end

function joints.each(func: (number, AnyJoint) -> ())
	for id, joint in pairs(joints.pool) do
		func(id, joint)
	end
end

function joints.clear()
	table.clear(joints.pool)
	joints._lastId = 0
end

-- Internal helpers

-- Shared positional constraint impulse, weighted by invMass
local function applyPositionalConstraint(bodyA, bodyB, worldAnchorA, worldAnchorB, dt)
	local delta = worldAnchorB - worldAnchorA
	local distance = delta.Magnitude

	if distance <= 0.001 then
		return
	end

	local normal = delta / distance
	local relVel = bodyB.velocity - bodyA.velocity
	local velAlong = Vector3Double.dot(relVel, normal)

	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInv = invMassA + invMassB

	if totalInv < 1e-9 then
		return
	end

	local bias = distance * BAUMGARTE / dt
	local impulse = normal * (velAlong + bias) / totalInv

	if bodyA.bodyType ~= "static" then
		bodyA.velocity = bodyA.velocity + impulse * invMassA
	end
	if bodyB.bodyType ~= "static" then
		bodyB.velocity = bodyB.velocity - impulse * invMassB
	end
end

-- Constraint Solvers

function joints.solveHinge(joint: HingeJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end

	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB

	applyPositionalConstraint(bodyA, bodyB, worldAnchorA, worldAnchorB, dt)

	-- Motor torque
	if joint.motor then
		local torqueImpulse = joint.axis * joint.motor.torque * dt
		if bodyB.bodyType ~= "static" then
			bodyB.angularVelocity = bodyB.angularVelocity + torqueImpulse * (bodyB.invMass or 1)
		end
		if bodyA.bodyType ~= "static" then
			bodyA.angularVelocity = bodyA.angularVelocity - torqueImpulse * (bodyA.invMass or 1)
		end
	end
end

function joints.solveSpring(joint: SpringJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end

	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB

	local delta = worldAnchorB - worldAnchorA
	local distance = delta.Magnitude
	local normal = distance > 1e-9 and delta / distance or Vector3Double.new(0, 0, 0)

	local displacement = distance - joint.restLength
	local springForce = -joint.stiffness * displacement

	local relVel = bodyB.velocity - bodyA.velocity
	local velAlong = Vector3Double.dot(relVel, normal)
	local dampForce = -joint.damping * velAlong

	local totalForce = springForce + dampForce
	if joint.maxForce then
		totalForce = math.clamp(totalForce, -joint.maxForce, joint.maxForce)
	end

	if distance < 1e-9 then
		return
	end

	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInv = invMassA + invMassB
	if totalInv < 1e-9 then
		return
	end

	local impulse = normal * totalForce * dt

	if bodyA.bodyType ~= "static" then
		bodyA.velocity = bodyA.velocity + impulse * invMassA
	end
	if bodyB.bodyType ~= "static" then
		bodyB.velocity = bodyB.velocity - impulse * invMassB
	end
end

function joints.solveFixed(joint: FixedJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end
	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB
	applyPositionalConstraint(bodyA, bodyB, worldAnchorA, worldAnchorB, dt)

	-- Angular constraint: damp relative angular velocity
	local angRelVel = bodyB.angularVelocity - bodyA.angularVelocity
	local angCorr = angRelVel * 0.5
	if bodyA.bodyType ~= "static" then
		bodyA.angularVelocity = bodyA.angularVelocity + angCorr
	end
	if bodyB.bodyType ~= "static" then
		bodyB.angularVelocity = bodyB.angularVelocity - angCorr
	end
end

function joints.solveBall(joint: BallJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end
	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB
	applyPositionalConstraint(bodyA, bodyB, worldAnchorA, worldAnchorB, dt)
end

function joints.solveSlider(joint: SliderJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end

	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB

	local delta = worldAnchorB - worldAnchorA
	local projection = Vector3Double.dot(delta, joint.axis)

	-- Apply optional limits
	if joint.limits then
		projection = math.clamp(projection, joint.limits.min, joint.limits.max)
	end

	local targetPos = worldAnchorA + joint.axis * projection
	local constraintDelta = worldAnchorB - targetPos
	local distance = constraintDelta.Magnitude

	if distance > 0.001 then
		local invMassA = bodyA.invMass or 0
		local invMassB = bodyB.invMass or 0
		local totalInv = invMassA + invMassB
		if totalInv >= 1e-9 then
			local normal = constraintDelta / distance
			local relVel = bodyB.velocity - bodyA.velocity
			local velAlong = Vector3Double.dot(relVel, normal)
			local bias = distance * BAUMGARTE / dt
			local impulse = normal * (velAlong + bias) / totalInv

			if bodyA.bodyType ~= "static" then
				bodyA.velocity = bodyA.velocity + impulse * invMassA
			end
			if bodyB.bodyType ~= "static" then
				bodyB.velocity = bodyB.velocity - impulse * invMassB
			end
		end
	end

	-- Motor
	if joint.motor then
		local invMassA = bodyA.invMass or 0
		local invMassB = bodyB.invMass or 0
		local totalInv = invMassA + invMassB
		if totalInv >= 1e-9 then
			local motorImpulse = joint.axis * joint.motor.force * dt
			if bodyB.bodyType ~= "static" then
				bodyB.velocity = bodyB.velocity + motorImpulse * invMassB
			end
			if bodyA.bodyType ~= "static" then
				bodyA.velocity = bodyA.velocity - motorImpulse * invMassA
			end
		end
	end
end

function joints.solveWheel(joint: WheelJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end

	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB

	local delta = worldAnchorB - worldAnchorA
	local compression = Vector3Double.dot(delta, joint.axis)
	local displacement = joint.suspension.restLength - compression

	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInv = invMassA + invMassB

	if displacement > 0 and totalInv >= 1e-9 then
		local relVelAxis = Vector3Double.dot(bodyB.velocity - bodyA.velocity, joint.axis)
		local springForce = displacement * joint.suspension.stiffness
		local dampForce = -relVelAxis * joint.suspension.damping
		local totalForce = springForce + dampForce

		local impulse = joint.axis * totalForce * dt

		if bodyB.bodyType ~= "static" then
			bodyB.velocity = bodyB.velocity + impulse * invMassB
		end
		if bodyA.bodyType ~= "static" then
			bodyA.velocity = bodyA.velocity - impulse * invMassA
		end
	end

	-- Motor torque
	if joint.motor then
		local torqueAxis = Vector3Double.new(-joint.axis.Z, 0, joint.axis.X)
		if torqueAxis.Magnitude > 1e-9 then
			torqueAxis = torqueAxis.Unit
			local torqueImpulse = torqueAxis * joint.motor.torque * dt
			if bodyB.bodyType ~= "static" then
				bodyB.angularVelocity = bodyB.angularVelocity + torqueImpulse * (invMassB > 0 and invMassB or 1)
			end
		end
	end

	-- Brake
	if joint.brake then
		local brakeForce = joint.brake.torque * dt
		local av = bodyB.angularVelocity
		local avMag = av.Magnitude
		if avMag > 1e-9 then
			local brakeImpulse = av / avMag * math.min(brakeForce, avMag)
			if bodyB.bodyType ~= "static" then
				bodyB.angularVelocity = bodyB.angularVelocity - brakeImpulse
			end
		end
	end
end

function joints.solvePiston(joint: PistonJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end

	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB

	local delta = worldAnchorB - worldAnchorA
	local projection = Vector3Double.dot(delta, joint.axis)

	if joint.limits then
		projection = math.clamp(projection, joint.limits.min, joint.limits.max)
	end

	local targetPos = worldAnchorA + joint.axis * projection
	local constraintDelta = worldAnchorB - targetPos
	local distance = constraintDelta.Magnitude

	local invMassA = bodyA.invMass or 0
	local invMassB = bodyB.invMass or 0
	local totalInv = invMassA + invMassB

	if distance > 0.001 and totalInv >= 1e-9 then
		local normal = constraintDelta / distance
		local relVel = bodyB.velocity - bodyA.velocity
		local velAlong = Vector3Double.dot(relVel, normal)
		local bias = distance * BAUMGARTE / dt
		local impulse = normal * (velAlong + bias) / totalInv

		if bodyA.bodyType ~= "static" then
			bodyA.velocity = bodyA.velocity + impulse * invMassA
		end
		if bodyB.bodyType ~= "static" then
			bodyB.velocity = bodyB.velocity - impulse * invMassB
		end
	end

	-- Motor (linear + angular)
	if joint.motor and totalInv >= 1e-9 then
		local linearImpulse = joint.axis * joint.motor.force * dt
		if bodyB.bodyType ~= "static" then
			bodyB.velocity = bodyB.velocity + linearImpulse * invMassB
		end
		if bodyA.bodyType ~= "static" then
			bodyA.velocity = bodyA.velocity - linearImpulse * invMassA
		end

		local torqueImpulse = joint.axis * joint.motor.torque * dt
		if bodyB.bodyType ~= "static" then
			bodyB.angularVelocity = bodyB.angularVelocity + torqueImpulse * (invMassB > 0 and invMassB or 1)
		end
	end
end

function joints.solveUniversal(joint: UniversalJoint, bodyA: any, bodyB: any, dt: number)
	if not joint.enabled then
		return
	end
	local worldAnchorA = bodyA.position + joint.anchorA
	local worldAnchorB = bodyB.position + joint.anchorB
	applyPositionalConstraint(bodyA, bodyB, worldAnchorA, worldAnchorB, dt)
end

-- Solve All

function joints.solveAll(bodyManager: any, dt: number, iterations: number)
	iterations = (iterations and iterations >= 1) and iterations or 4

	for _ = 1, iterations do
		for id, joint in pairs(joints.pool) do
			if not joint.enabled then
				continue
			end

			local bodyA = bodyManager.get(joint.bodyA)
			local bodyB = bodyManager.get(joint.bodyB)

			if not bodyA or not bodyB then
				continue
			end

			if joint.type == "hinge" then
				joints.solveHinge(joint, bodyA, bodyB, dt)
			elseif joint.type == "spring" then
				joints.solveSpring(joint, bodyA, bodyB, dt)
			elseif joint.type == "fixed" then
				joints.solveFixed(joint, bodyA, bodyB, dt)
			elseif joint.type == "ball" then
				joints.solveBall(joint, bodyA, bodyB, dt)
			elseif joint.type == "slider" then
				joints.solveSlider(joint, bodyA, bodyB, dt)
			elseif joint.type == "wheel" then
				joints.solveWheel(joint, bodyA, bodyB, dt)
			elseif joint.type == "piston" then
				joints.solvePiston(joint, bodyA, bodyB, dt)
			elseif joint.type == "universal" then
				joints.solveUniversal(joint, bodyA, bodyB, dt)
			end
		end
	end
end

return joints
