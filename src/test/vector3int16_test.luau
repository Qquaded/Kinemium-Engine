local Vector3int16 = require("../environment/datatypes/Vector3int16")
local Vector3 = require("../environment/datatypes/Vector3")

local testing = zune.testing
local expect = testing.expect

testing.describe("Vector3int16", function()
	testing.test("Creation", function()
		local v = Vector3int16.new(100, 200, 300)
		expect(v.X).toBe(100)
		expect(v.Y).toBe(200)
		expect(v.Z).toBe(300)
	end)

	testing.test("Creation defaults to zero", function()
		local v = Vector3int16.new()
		expect(v.X).toBe(0)
		expect(v.Y).toBe(0)
		expect(v.Z).toBe(0)
	end)

	testing.test("Creation clamps to int16 range", function()
		local v = Vector3int16.new(40000, -40000, 0)
		expect(v.X <= 32767 and v.X >= -32768).toBeTruthy()
		expect(v.Y <= 32767 and v.Y >= -32768).toBeTruthy()
	end)

	testing.test("Arithmetic operators", function()
		local a = Vector3int16.new(10, 20, 30)
		local b = Vector3int16.new(5, 10, 15)

		local sum = a + b
		expect(sum.X).toBe(15)
		expect(sum.Y).toBe(30)
		expect(sum.Z).toBe(45)

		local diff = a - b
		expect(diff.X).toBe(5)
		expect(diff.Y).toBe(10)
		expect(diff.Z).toBe(15)

		local mul = a * 2
		expect(mul.X).toBe(20)
		expect(mul.Y).toBe(40)
		expect(mul.Z).toBe(60)

		local mulLeft = 3 * a
		expect(mulLeft.X).toBe(30)
		expect(mulLeft.Y).toBe(60)
		expect(mulLeft.Z).toBe(90)

		local div = a / 2
		expect(div.X).toBe(5)
		expect(div.Y).toBe(10)
		expect(div.Z).toBe(15)
	end)

	testing.test("Vector multiplication multiplies component-wise", function()
		local a = Vector3int16.new(2, 3, 4)
		local b = Vector3int16.new(5, 6, 7)
		local m = a * b
		expect(m.X).toBe(10)
		expect(m.Y).toBe(18)
		expect(m.Z).toBe(28)
	end)

	testing.test("Integer division with vector", function()
		local a = Vector3int16.new(10, 20, 30)
		local b = Vector3int16.new(3, 4, 5)
		local d = a / b
		expect(d.X).toBe(3)
		expect(d.Y).toBe(5)
		expect(d.Z).toBe(6)
	end)

	testing.test("ToVector3 converts to floating-point Vector3", function()
		local v = Vector3int16.new(100, 200, 300)
		local v3 = v:ToVector3()
		expect(v3.X).toBe(100)
		expect(v3.Y).toBe(200)
		expect(v3.Z).toBe(300)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Vector3int16.new(7, 8, 9)
		local tbl = a:ToTable()
		local b = Vector3int16.FromTable(tbl)
		expect(b.X).toBe(7)
		expect(b.Y).toBe(8)
		expect(b.Z).toBe(9)
	end)

	testing.test("__tostring contains Vector3int16", function()
		expect(string.find(tostring(Vector3int16.new(1, 2, 3)), "Vector3int16", 1, true) ~= nil).toBeTruthy()
	end)
end)
