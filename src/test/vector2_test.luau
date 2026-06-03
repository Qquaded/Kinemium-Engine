local Vector2 = require("../environment/datatypes/Vector2")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

local function expectVecNear(v, x, y, epsilon)
	expect(near(v.X, x, epsilon)).toBeTruthy()
	expect(near(v.Y, y, epsilon)).toBeTruthy()
end

testing.describe("Vector2", function()
	testing.test("Creation", function()
		local v = Vector2.new(3, 4)
		expect(v.X).toBe(3)
		expect(v.Y).toBe(4)
	end)

	testing.test("Creation defaults to zero", function()
		local v = Vector2.new()
		expect(v.X).toBe(0)
		expect(v.Y).toBe(0)
	end)

	testing.test("Magnitude", function()
		local v = Vector2.new(3, 4)
		expect(v:Magnitude()).toBe(5)
	end)

	testing.test("Magnitude of zero vector", function()
		local v = Vector2.new(0, 0)
		expect(v:Magnitude()).toBe(0)
	end)

	testing.test("Unit normalizes and preserves direction", function()
		local v = Vector2.new(5, 0):Unit()
		expectVecNear(v, 1, 0)
	end)

	testing.test("Unit of zero vector returns zero", function()
		local v = Vector2.new(0, 0):Unit()
		expectVecNear(v, 0, 0)
	end)

	testing.test("Dot product", function()
		local a = Vector2.new(1, 2)
		local b = Vector2.new(3, 4)
		expect(a:Dot(b)).toBe(11)
	end)

	testing.test("Arithmetic operators", function()
		local a = Vector2.new(1, 2)
		local b = Vector2.new(3, 4)
		expectVecNear(a + b, 4, 6)
		expectVecNear(b - a, 2, 2)
		expectVecNear(a * 2, 2, 4)
		expectVecNear(2 * a, 2, 4)
		expectVecNear(b / 2, 1.5, 2)
		expectVecNear(-a, -1, -2)
	end)

	testing.test("Distance", function()
		local a = Vector2.new(0, 0)
		local b = Vector2.new(3, 4)
		expect(a:Distance(b)).toBe(5)
	end)

	testing.test("Lerp midpoint", function()
		local a = Vector2.new(0, 0)
		local b = Vector2.new(10, 20)
		local v = a:Lerp(b, 0.5)
		expectVecNear(v, 5, 10)
	end)

	testing.test("Lerp endpoints", function()
		local a = Vector2.new(1, 2)
		local b = Vector2.new(3, 4)
		expectVecNear(a:Lerp(b, 0), 1, 2)
		expectVecNear(a:Lerp(b, 1), 3, 4)
	end)

	testing.test("Clone creates copy", function()
		local a = Vector2.new(1, 2)
		local b = a:Clone()
		expectVecNear(b, 1, 2)
		b.X = 5
		expect(a.X).toBe(1)
	end)

	testing.test("Constants", function()
		expectVecNear(Vector2.Zero, 0, 0)
		expectVecNear(Vector2.One, 1, 1)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Vector2.new(7, 8)
		local tbl = a:ToTable()
		local b = Vector2.FromTable(tbl)
		expectVecNear(b, 7, 8)
	end)

	testing.test("__tostring contains Vector2", function()
		expect(string.find(tostring(Vector2.new(1, 2)), "Vector2", 1, true) ~= nil).toBeTruthy()
	end)

	testing.test("__div errors on non-scalar divisor", function()
		local ok = pcall(function()
			return Vector2.new(1, 2) / Vector2.new(1, 1)
		end)
		expect(ok).toBeFalsy()
	end)
end)
