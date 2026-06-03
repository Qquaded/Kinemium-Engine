local Rect = require("../environment/datatypes/Rect")
local Vector2 = require("../environment/datatypes/Vector2")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

testing.describe("Rect", function()
	testing.test("Creation with Vector2", function()
		local r = Rect.new(Vector2.new(0, 0), Vector2.new(100, 50))
		expect(r.Min.X).toBe(0)
		expect(r.Min.Y).toBe(0)
		expect(r.Max.X).toBe(100)
		expect(r.Max.Y).toBe(50)
		expect(r.Width).toBe(100)
		expect(r.Height).toBe(50)
	end)

	testing.test("Creation defaults to zero vectors", function()
		local r = Rect.new()
		expect(r.Min.X).toBe(0)
		expect(r.Min.Y).toBe(0)
		expect(r.Max.X).toBe(0)
		expect(r.Max.Y).toBe(0)
	end)

	testing.test("fromCoords creates rect from coordinates", function()
		local r = Rect.fromCoords(10, 20, 110, 70)
		expect(r.Min.X).toBe(10)
		expect(r.Min.Y).toBe(20)
		expect(r.Max.X).toBe(110)
		expect(r.Max.Y).toBe(70)
		expect(r.Width).toBe(100)
		expect(r.Height).toBe(50)
	end)

	testing.test("fromCoords handles negative dimensions", function()
		local r = Rect.fromCoords(110, 70, 10, 20)
		expect(r.Min.X).toBe(10)
		expect(r.Min.Y).toBe(20)
		expect(r.Max.X).toBe(110)
		expect(r.Max.Y).toBe(70)
		expect(r.Width).toBe(100)
		expect(r.Height).toBe(50)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Rect.new(Vector2.new(10, 20), Vector2.new(110, 70))
		local tbl = a:ToTable()
		local b = Rect.FromTable(tbl)
		expect(b.Min.X).toBe(10)
		expect(b.Min.Y).toBe(20)
		expect(b.Max.X).toBe(110)
		expect(b.Max.Y).toBe(70)
	end)
end)
