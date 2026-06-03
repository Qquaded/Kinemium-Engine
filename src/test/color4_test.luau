local Color4 = require("../environment/datatypes/Color4")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

local function expectColor4Near(a, b, epsilon)
	expect(near(a.R, b.R, epsilon)).toBeTruthy()
	expect(near(a.G, b.G, epsilon)).toBeTruthy()
	expect(near(a.B, b.B, epsilon)).toBeTruthy()
	expect(near(a.A, b.A, epsilon)).toBeTruthy()
end

testing.describe("Color4", function()
	testing.test("Creation", function()
		local c = Color4.new(0.5, 0.25, 0.75, 0.8)
		expect(near(c.R, 0.5)).toBeTruthy()
		expect(near(c.G, 0.25)).toBeTruthy()
		expect(near(c.B, 0.75)).toBeTruthy()
		expect(near(c.A, 0.8)).toBeTruthy()
	end)

	testing.test("Creation clamps values", function()
		local c = Color4.new(1.5, -0.5, 0.5, 1.5)
		expect(c.R).toBe(1)
		expect(c.G).toBe(0)
		expect(near(c.B, 0.5)).toBeTruthy()
		expect(c.A).toBe(1)
	end)

	testing.test("Creation defaults alpha to 1", function()
		local c = Color4.new(0.5, 0.25, 0.75)
		expect(near(c.R, 0.5)).toBeTruthy()
		expect(near(c.G, 0.25)).toBeTruthy()
		expect(near(c.B, 0.75)).toBeTruthy()
		expect(c.A).toBe(1)
	end)

	testing.test("Creation defaults all to zero", function()
		local c = Color4.new()
		expect(c.R).toBe(0)
		expect(c.G).toBe(0)
		expect(c.B).toBe(0)
		expect(c.A).toBe(1)
	end)

	testing.test("fromRGB creates from 0-255 values", function()
		local c = Color4.fromRGB(255, 128, 64, 192)
		expect(near(c.R, 1)).toBeTruthy()
		expect(near(c.G, 0.502)).toBeTruthy()
		expect(near(c.B, 0.251)).toBeTruthy()
		expect(near(c.A, 0.753)).toBeTruthy()
	end)

	testing.test("ToRGBA returns 0-255 values", function()
		local c = Color4.new(1, 0.5, 0.25, 0.75)
		local r, g, b, a = c:ToRGBA()
		expect(r).toBe(255)
		expect(g).toBe(128)
		expect(b).toBe(64)
		expect(a).toBe(191)
	end)

	testing.test("Clamp keeps values in 0-1 range", function()
		local c = Color4.new(1.5, -0.5, 0.5, 1.5):Clamp()
		expect(c.R).toBe(1)
		expect(c.G).toBe(0)
		expect(near(c.B, 0.5)).toBeTruthy()
		expect(c.A).toBe(1)
	end)

	testing.test("PremultiplyAlpha multiplies RGB by A", function()
		local c = Color4.new(0.5, 0.5, 0.5, 0.5):PremultiplyAlpha()
		expect(near(c.R, 0.25)).toBeTruthy()
		expect(near(c.G, 0.25)).toBeTruthy()
		expect(near(c.B, 0.25)).toBeTruthy()
		expect(near(c.A, 0.5)).toBeTruthy()
	end)

	testing.test("Lerp midpoint", function()
		local a = Color4.new(0, 0, 0, 0)
		local b = Color4.new(1, 1, 1, 1)
		local l = a:Lerp(b, 0.5)
		expect(near(l.R, 0.5)).toBeTruthy()
		expect(near(l.G, 0.5)).toBeTruthy()
		expect(near(l.B, 0.5)).toBeTruthy()
		expect(near(l.A, 0.5)).toBeTruthy()
	end)

	testing.test("Lerp endpoints", function()
		local a = Color4.new(0.1, 0.2, 0.3, 0.4)
		local b = Color4.new(0.5, 0.6, 0.7, 0.8)
		expectColor4Near(a:Lerp(b, 0), a)
		expectColor4Near(a:Lerp(b, 1), b)
	end)

	testing.test("Arithmetic operators", function()
		local a = Color4.new(0.2, 0.3, 0.4, 0.5)
		local b = Color4.new(0.1, 0.1, 0.1, 0.1)

		local sum = a + b
		expect(near(sum.R, 0.3)).toBeTruthy()
		expect(near(sum.G, 0.4)).toBeTruthy()
		expect(near(sum.B, 0.5)).toBeTruthy()
		expect(near(sum.A, 0.6)).toBeTruthy()

		local diff = a - b
		expect(near(diff.R, 0.1)).toBeTruthy()
		expect(near(diff.G, 0.2)).toBeTruthy()
		expect(near(diff.B, 0.3)).toBeTruthy()
		expect(near(diff.A, 0.4)).toBeTruthy()

		local mul = a * 2
		expect(near(mul.R, 0.4)).toBeTruthy()
		expect(near(mul.G, 0.6)).toBeTruthy()
		expect(near(mul.B, 0.8)).toBeTruthy()
		expect(near(mul.A, 1)).toBeTruthy()

		local div = a / 2
		expect(near(div.R, 0.1)).toBeTruthy()
		expect(near(div.G, 0.15)).toBeTruthy()
		expect(near(div.B, 0.2)).toBeTruthy()
		expect(near(div.A, 0.25)).toBeTruthy()

		local neg = -a
		expect(near(neg.R, -0.2)).toBeTruthy()
		expect(near(neg.G, -0.3)).toBeTruthy()
		expect(near(neg.B, -0.4)).toBeTruthy()
		expect(near(neg.A, -0.5)).toBeTruthy()
	end)

	testing.test("Luminance calculates perceived brightness", function()
		local c = Color4.new(1, 0, 0, 1)
		expect(near(c:Luminance(), 0.2126)).toBeTruthy()
	end)

	testing.test("Multiply multiplies component-wise", function()
		local a = Color4.new(0.5, 0.5, 0.5, 0.5)
		local b = Color4.new(0.5, 0.5, 0.5, 0.5)
		local m = a:Multiply(b)
		expect(near(m.R, 0.25)).toBeTruthy()
		expect(near(m.G, 0.25)).toBeTruthy()
		expect(near(m.B, 0.25)).toBeTruthy()
		expect(near(m.A, 0.25)).toBeTruthy()
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = Color4.new(0.25, 0.5, 0.75, 0.8)
		local tbl = a:ToTable()
		local b = Color4.FromTable(tbl)
		expectColor4Near(a, b)
	end)

	testing.test("__eq compares equality with epsilon", function()
		local a = Color4.new(0.5, 0.25, 0.75, 0.8)
		local b = Color4.new(0.5 + 1e-6, 0.25, 0.75, 0.8)
		expect((a == b)).toBeTruthy()
	end)

	testing.test("__tostring contains Color4", function()
		expect(string.find(tostring(Color4.new(0.5, 0.25, 0.75, 0.8)), "Color4", 1, true) ~= nil).toBeTruthy()
	end)
end)
