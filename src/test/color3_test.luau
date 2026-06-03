local Color3 = require("../environment/datatypes/Color3")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

local function expectColorNear(a, b, epsilon)
	expect(near(a.R, b.R, epsilon)).toBeTruthy()
	expect(near(a.G, b.G, epsilon)).toBeTruthy()
	expect(near(a.B, b.B, epsilon)).toBeTruthy()
end

testing.describe("Color3", function()
	testing.test("Creation", function()
		local c = Color3.new(0.5, 0.25, 0.75)
		expect(near(c.R, 0.5)).toBeTruthy()
		expect(near(c.G, 0.25)).toBeTruthy()
		expect(near(c.B, 0.75)).toBeTruthy()
	end)

	testing.test("Creation clamps values", function()
		local c = Color3.new(1.5, -0.5, 0.5)
		expect(c.R).toBe(1)
		expect(c.G).toBe(0)
		expect(near(c.B, 0.5)).toBeTruthy()
	end)

	testing.test("Creation defaults to zero", function()
		local c = Color3.new()
		expect(c.R).toBe(0)
		expect(c.G).toBe(0)
		expect(c.B).toBe(0)
	end)

	testing.test("fromRGB creates from 0-255 values", function()
		local c = Color3.fromRGB(255, 128, 64)
		expect(near(c.R, 1)).toBeTruthy()
		expect(near(c.G, 0.502)).toBeTruthy()
		expect(near(c.B, 0.251)).toBeTruthy()
	end)

	testing.test("ToRGB returns 0-255 values", function()
		local c = Color3.new(1, 0.5, 0.25)
		local r, g, b = c:ToRGB()
		expect(r).toBe(255)
		expect(g).toBe(128)
		expect(b).toBe(64)
	end)

	testing.test("fromHSV and ToHSV roundtrip", function()
		local c = Color3.fromHSV(0.5, 0.75, 1)
		local h, s, v = c:ToHSV()
		expect(near(h, 0.5, 0.01)).toBeTruthy()
		expect(near(s, 0.75, 0.01)).toBeTruthy()
		expect(near(v, 1, 0.01)).toBeTruthy()
	end)

	testing.test("Lerp midpoint", function()
		local a = Color3.new(0, 0, 0)
		local b = Color3.new(1, 1, 1)
		local l = a:Lerp(b, 0.5)
		expect(near(l.R, 0.5)).toBeTruthy()
		expect(near(l.G, 0.5)).toBeTruthy()
		expect(near(l.B, 0.5)).toBeTruthy()
	end)

	testing.test("Lerp endpoints", function()
		local a = Color3.new(0.1, 0.2, 0.3)
		local b = Color3.new(0.5, 0.6, 0.7)
		expectColorNear(a:Lerp(b, 0), a)
		expectColorNear(a:Lerp(b, 1), b)
	end)

	testing.test("Arithmetic operators", function()
		local a = Color3.new(0.2, 0.3, 0.4)
		local b = Color3.new(0.1, 0.1, 0.1)

		local sum = a + b
		expect(near(sum.R, 0.3)).toBeTruthy()
		expect(near(sum.G, 0.4)).toBeTruthy()
		expect(near(sum.B, 0.5)).toBeTruthy()

		local diff = a - b
		expect(near(diff.R, 0.1)).toBeTruthy()
		expect(near(diff.G, 0.2)).toBeTruthy()
		expect(near(diff.B, 0.3)).toBeTruthy()

		local mul = a * 2
		expect(near(mul.R, 0.4)).toBeTruthy()
		expect(near(mul.G, 0.6)).toBeTruthy()
		expect(near(mul.B, 0.8)).toBeTruthy()

		local mulLeft = 2 * a
		expect(near(mulLeft.R, 0.4)).toBeTruthy()
		expect(near(mulLeft.G, 0.6)).toBeTruthy()
		expect(near(mulLeft.B, 0.8)).toBeTruthy()

		local div = a / 2
		expect(near(div.R, 0.1)).toBeTruthy()
		expect(near(div.G, 0.15)).toBeTruthy()
		expect(near(div.B, 0.2)).toBeTruthy()

		local neg = -a
		expect(near(neg.R, -0.2)).toBeTruthy()
		expect(near(neg.G, -0.3)).toBeTruthy()
		expect(near(neg.B, -0.4)).toBeTruthy()
	end)

	testing.test("Dot product", function()
		local a = Color3.new(1, 0, 0)
		local b = Color3.new(0, 1, 0)
		expect(a:Dot(b)).toBe(0)

		local c = Color3.new(0.5, 0.5, 0)
		local d = Color3.new(0.5, 0.5, 0)
		expect(near(c:Dot(d), 0.5)).toBeTruthy()
	end)

	testing.test("Magnitude", function()
		local c = Color3.new(3, 4, 0)
		expect(near(c:Magnitude(), 5)).toBeTruthy()
	end)

	testing.test("Unit normalizes", function()
		local c = Color3.new(5, 0, 0):Unit()
		expect(near(c.R, 1)).toBeTruthy()
		expect(c.G).toBe(0)
		expect(c.B).toBe(0)
	end)

	testing.test("Clamp keeps values in 0-1 range", function()
		local c = Color3.new(1.5, -0.5, 0.5):Clamp()
		expect(c.R).toBe(1)
		expect(c.G).toBe(0)
		expect(near(c.B, 0.5)).toBeTruthy()
	end)

	testing.test("Invert reverses colors", function()
		local c = Color3.new(0.2, 0.5, 0.8):Invert()
		expect(near(c.R, 0.8)).toBeTruthy()
		expect(near(c.G, 0.5)).toBeTruthy()
		expect(near(c.B, 0.2)).toBeTruthy()
	end)

	testing.test("fromHex parses hex color", function()
		local c = Color3.fromHex("FF8040")
		expect(near(c.R, 1)).toBeTruthy()
		expect(near(c.G, 0.502)).toBeTruthy()
		expect(near(c.B, 0.251)).toBeTruthy()
	end)

	testing.test("fromHex with hash parses hex color", function()
		local c = Color3.fromHex("#FF8040")
		expect(near(c.R, 1)).toBeTruthy()
		expect(near(c.G, 0.502)).toBeTruthy()
		expect(near(c.B, 0.251)).toBeTruthy()
	end)

	testing.test("ToHex returns hex string", function()
		local c = Color3.new(1, 0.5, 0.25)
		local hex = c:ToHex()
		expect(hex).toBe("#FF8040")
	end)

	testing.test("ToGrayscale calculates luminance", function()
		local c = Color3.new(1, 0, 0)
		local g = c:ToGrayscale()
		expect(near(g.R, 0.299)).toBeTruthy()
		expect(near(g.G, 0.299)).toBeTruthy()
		expect(near(g.B, 0.299)).toBeTruthy()
	end)

	testing.test("AdjustBrightness shifts all channels", function()
		local c = Color3.new(0.2, 0.3, 0.4):AdjustBrightness(0.1)
		expect(near(c.R, 0.3)).toBeTruthy()
		expect(near(c.G, 0.4)).toBeTruthy()
		expect(near(c.B, 0.5)).toBeTruthy()
	end)

	testing.test("AdjustContrast increases contrast", function()
		local c = Color3.new(0.5, 0.5, 0.5):AdjustContrast(1)
		expect(near(c.R, 0.5)).toBeTruthy()
		expect(near(c.G, 0.5)).toBeTruthy()
		expect(near(c.B, 0.5)).toBeTruthy()
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Color3.new(0.25, 0.5, 0.75)
		local tbl = a:ToTable()
		local b = Color3.FromTable(tbl)
		expectColorNear(a, b)
	end)

	testing.test("__eq compares equality", function()
		local a = Color3.new(0.5, 0.25, 0.75)
		local b = Color3.new(0.5, 0.25, 0.75)
		local c = Color3.new(0.5, 0.26, 0.75)
		expect((a == b)).toBeTruthy()
		expect((a == c)).toBeFalsy()
	end)

	testing.test("__tostring contains Color3", function()
		expect(string.find(tostring(Color3.new(0.5, 0.25, 0.75)), "Color3", 1, true) ~= nil).toBeTruthy()
	end)
end)
