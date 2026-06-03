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

function Impulse3D.Step(dt: number)
	physics.step(body, joints, dt)
	softbody.stepAll(dt, physics.gravity)
end
function Impulse3D.Reset()
	physics.reset(body, joints)
	softbody.clear()
end

function Impulse3D.Raycast(origin, direction, maxDist)
	return physics.raycast(body, origin, direction, maxDist)
end

export type Impulse3D = typeof(Impulse3D)
return Impulse3D :: Impulse3D
