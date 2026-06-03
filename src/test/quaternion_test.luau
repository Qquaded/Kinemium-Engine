local Quaternion = require("../environment/datatypes/Quaternion")
local Vector3 = require("../environment/datatypes/Vector3")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

local function expectQuatNear(q, x, y, z, w, epsilon)
	expect(near(q.X, x, epsilon)).toBeTruthy()
	expect(near(q.Y, y, epsilon)).toBeTruthy()
	expect(near(q.Z, z, epsilon)).toBeTruthy()
	expect(near(q.W, w, epsilon)).toBeTruthy()
end

testing.describe("Quaternion", function()
	testing.test("Creation defaults and identity", function()
		local q = Quaternion.new()
		expectQuatNear(q, 0, 0, 0, 1)

		local identity = Quaternion.identity()
		expectQuatNear(identity, 0, 0, 0, 1)
	end)

	testing.test("Normalize and magnitude", function()
		local q = Quaternion.new(0, 0, 0, 2):Normalize()
		expect(near(q:Magnitude(), 1)).toBeTruthy()
		expectQuatNear(q, 0, 0, 0, 1)
	end)

	testing.test("identity * q and q * identity", function()
		local q = Quaternion.fromEuler(0.2, -0.4, 0.6)
		local identity = Quaternion.identity()
		local left = identity * q
		local right = q * identity
		expectQuatNear(left, q.X, q.Y, q.Z, q.W)
		expectQuatNear(right, q.X, q.Y, q.Z, q.W)
	end)

	testing.test("q * q:Inverse() ~= identity", function()
		local q = Quaternion.fromEuler(0.8, -0.3, 0.1)
		local inv = q:Inverse()
		local prod = q * inv
		expectQuatNear(prod, 0, 0, 0, 1, 1e-4)
	end)

	testing.test("fromAxisAngle rotates vector", function()
		local q = Quaternion.fromAxisAngle(Vector3.new(0, 0, 1), math.pi / 2)
		local rotated = q:RotateVector(Vector3.new(1, 0, 0))
		expect(near(rotated.X, 0, 1e-4)).toBeTruthy()
		expect(near(rotated.Y, 1, 1e-4)).toBeTruthy()
		expect(near(rotated.Z, 0, 1e-4)).toBeTruthy()
	end)

	testing.test("ToMatrix4 identity layout", function()
		local m = Quaternion.identity():ToMatrix4()
		expect(#m).toBe(16)
		expect(near(m[1], 1)).toBeTruthy()
		expect(near(m[6], 1)).toBeTruthy()
		expect(near(m[11], 1)).toBeTruthy()
		expect(near(m[16], 1)).toBeTruthy()
	end)

	testing.test("fromEuler to matrix rotates X by 90 deg", function()
		local m = Quaternion.fromEuler(math.pi / 2, 0, 0):ToMatrix4()
		expect(near(m[6], 0, 1e-4)).toBeTruthy()
		expect(near(m[7], -1, 1e-4)).toBeTruthy()
		expect(near(m[10], 1, 1e-4)).toBeTruthy()
		expect(near(m[11], 0, 1e-4)).toBeTruthy()
	end)

	testing.test("slerp endpoints", function()
		local a = Quaternion.fromEuler(0, 0, 0)
		local b = Quaternion.fromEuler(0, math.pi / 2, 0)
		local s0 = Quaternion.slerp(a, b, 0)
		local s1 = Quaternion.slerp(a, b, 1)
		expectQuatNear(s0, a.X, a.Y, a.Z, a.W, 1e-5)
		expectQuatNear(s1, b.X, b.Y, b.Z, b.W, 1e-5)
	end)

	testing.test("slerp handles antipodal input", function()
		local a = Quaternion.identity()
		local b = Quaternion.new(0, 0, 0, -1)
		local s = Quaternion.slerp(a, b, 0.5)
		expect(near(s.X, 0, 1e-4)).toBeTruthy()
		expect(near(s.Y, 0, 1e-4)).toBeTruthy()
		expect(near(s.Z, 0, 1e-4)).toBeTruthy()
		expect(near(math.abs(s.W), 1, 1e-4)).toBeTruthy()
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Quaternion.fromEuler(0.25, 0.5, -0.25)
		local tbl = a:ToTable()
		local b = Quaternion.FromTable(tbl)
		expectQuatNear(b, a.X, a.Y, a.Z, a.W, 1e-5)
	end)

	testing.test("__tostring contains type name", function()
		expect(string.find(tostring(Quaternion.identity()), "Quaternion", 1, true) ~= nil).toBeTruthy()
	end)
end)
