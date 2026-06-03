_G.log = function() end
_G.warn = function() end
_G.Color3 = {
	new = function()
		return {}
	end,
}
_G.IsHeadless = true

local testing = zune.testing
local expect = testing.expect

local impulse3d = require("@Impulse3D")
local physics = impulse3d.physics
local Vector3Double = impulse3d.utility.Vector3Double

testing.describe("Impulse3D physics.applyImpulse", function()
	testing.test("applies impulse to dynamic body", function()
		local body = {
			bodyType = "dynamic",
			velocity = Vector3Double.new(0, 0, 0),
			invMass = 2,
		}

		physics.applyImpulse(body, Vector3Double.new(1, 2, 3))

		expect(body.velocity.X).toBe(2)
		expect(body.velocity.Y).toBe(4)
		expect(body.velocity.Z).toBe(6)
	end)

	testing.test("does not apply impulse to static body", function()
		local body = {
			bodyType = "static",
			velocity = Vector3Double.new(0, 0, 0),
			invMass = 2,
		}

		physics.applyImpulse(body, Vector3Double.new(1, 2, 3))

		expect(body.velocity.X).toBe(0)
		expect(body.velocity.Y).toBe(0)
		expect(body.velocity.Z).toBe(0)
	end)

	testing.test("uses invMass of 1 if not provided", function()
		local body = {
			bodyType = "dynamic",
			velocity = Vector3Double.new(10, 10, 10),
		}

		physics.applyImpulse(body, Vector3Double.new(1, 2, 3))

		expect(body.velocity.X).toBe(11)
		expect(body.velocity.Y).toBe(12)
		expect(body.velocity.Z).toBe(13)
	end)
end)
