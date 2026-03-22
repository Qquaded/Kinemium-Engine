-- Impulse3D
-- devcell

local Impulse3D = {}

local body, physics, utility, joints, softbody =
	require("./body"), require("./physics"), require("./utility"), require("./joints"), require("./softbody")

Impulse3D.body = body
Impulse3D.physics = physics
Impulse3D.joints = joints
Impulse3D.utility = utility
Impulse3D.softbody = softbody

-- Convenience API

-- Steps the entire simulation (rigid bodies + soft bodies)
function Impulse3D.Step(dt: number)
	-- Step rigid body physics
	physics.step(body, joints, dt)

	-- Step all soft bodies with the global gravity
	softbody.stepAll(dt, physics.gravity)
end

-- Resets all bodies, joints, accumulators, and contact state
function Impulse3D.Reset()
	physics.reset(body, joints)
	softbody.clear()
end

-- Convenience: cast a ray and return the closest hit (or nil)
function Impulse3D.Raycast(origin, direction, maxDist)
	return physics.raycast(body, origin, direction, maxDist)
end

-- Types

export type Impulse3D = typeof(Impulse3D)
return Impulse3D :: Impulse3D
