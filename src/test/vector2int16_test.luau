local Vector2int16 = require("../environment/datatypes/Vector2int16")
local Vector2 = require("../environment/datatypes/Vector2")

local testing = zune.testing
local expect = testing.expect

testing.describe("Vector2int16", function()
	testing.test("Creation", function()
		local v = Vector2int16.new(100, 200)
		expect(v.X).toBe(100)
		expect(v.Y).toBe(200)
	end)

	testing.test("Creation defaults to zero", function()
		local v = Vector2int16.new()
		expect(v.X).toBe(0)
		expect(v.Y).toBe(0)
	end)

	testing.test("Creation clamps to int16 range", function()
		local v = Vector2int16.new(40000, -40000)
		expect(v.X <= 32767 and v.X >= -32768).toBeTruthy()
		expect(v.Y <= 32767 and v.Y >= -32768).toBeTruthy()
	end)

	testing.test("Arithmetic operators", function()
		local a = Vector2int16.new(10, 20)
		local b = Vector2int16.new(5, 10)

		local sum = a + b
		expect(sum.X).toBe(15)
		expect(sum.Y).toBe(30)

		local diff = a - b
		expect(diff.X).toBe(5)
		expect(diff.Y).toBe(10)

		local mul = a * 2
		expect(mul.X).toBe(20)
		expect(mul.Y).toBe(40)

		local mulLeft = 3 * a
		expect(mulLeft.X).toBe(30)
		expect(mulLeft.Y).toBe(60)

		local div = a / 2
		expect(div.X).toBe(5)
		expect(div.Y).toBe(10)
	end)

	testing.test("Vector multiplication multiplies component-wise", function()
		local a = Vector2int16.new(2, 3)
		local b = Vector2int16.new(4, 5)
		local m = a * b
		expect(m.X).toBe(8)
		expect(m.Y).toBe(15)
	end)

	testing.test("Integer division with vector", function()
		local a = Vector2int16.new(10, 20)
		local b = Vector2int16.new(3, 4)
		local d = a / b
		expect(d.X).toBe(3)
		expect(d.Y).toBe(5)
	end)

	testing.test("ToVector2 converts to floating-point Vector2", function()
		local v = Vector2int16.new(100, 200)
		local v2 = v:ToVector2()
		expect(v2.X).toBe(100)
		expect(v2.Y).toBe(200)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Vector2int16.new(7, 8)
		local tbl = a:ToTable()
		local b = Vector2int16.FromTable(tbl)
		expect(b.X).toBe(7)
		expect(b.Y).toBe(8)
	end)

	testing.test("__tostring contains Vector2int16", function()
		expect(string.find(tostring(Vector2int16.new(1, 2)), "Vector2int16", 1, true) ~= nil).toBeTruthy()
	end)
end)
