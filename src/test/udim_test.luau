local UDim = require("../environment/datatypes/UDim")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

testing.describe("UDim", function()
	testing.test("Creation", function()
		local u = UDim.new(0.5, 100)
		expect(u.Scale).toBe(0.5)
		expect(u.Offset).toBe(100)
	end)

	testing.test("Creation defaults to zero", function()
		local u = UDim.new()
		expect(u.Scale).toBe(0)
		expect(u.Offset).toBe(0)
	end)

	testing.test("Arithmetic operators", function()
		local a = UDim.new(0.2, 50)
		local b = UDim.new(0.3, 150)
		local sum = a + b
		expect(near(sum.Scale, 0.5)).toBeTruthy()
		expect(sum.Offset).toBe(200)

		local diff = b - a
		expect(near(diff.Scale, 0.1)).toBeTruthy()
		expect(diff.Offset).toBe(100)

		local mul = a * 2
		expect(near(mul.Scale, 0.4)).toBeTruthy()
		expect(mul.Offset).toBe(100)

		local mulLeft = 3 * b
		expect(near(mulLeft.Scale, 0.9)).toBeTruthy()
		expect(mulLeft.Offset).toBe(450)

		local div = b / 2
		expect(near(div.Scale, 0.15)).toBeTruthy()
		expect(div.Offset).toBe(75)
	end)

	testing.test("ToPixels calculation", function()
		local u = UDim.new(0.5, 100)
		expect(u:ToPixels(200)).toBe(200)
		expect(u:ToPixels(0)).toBe(100)
	end)

	testing.test("Clone creates copy", function()
		local a = UDim.new(0.5, 100)
		local b = a:Clone()
		expect(b.Scale).toBe(0.5)
		expect(b.Offset).toBe(100)
		b.Scale = 0.8
		expect(a.Scale).toBe(0.5)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = UDim.new(0.25, 50)
		local tbl = a:ToTable()
		local b = UDim.FromTable(tbl)
		expect(b.Scale).toBe(0.25)
		expect(b.Offset).toBe(50)
	end)

	testing.test("__tostring contains UDim", function()
		expect(string.find(tostring(UDim.new(0.5, 100)), "UDim", 1, true) ~= nil).toBeTruthy()
	end)

	testing.test("__div errors on non-scalar divisor", function()
		local ok = pcall(function()
			return UDim.new(1, 2) / UDim.new(1, 1)
		end)
		expect(ok).toBeFalsy()
	end)
end)
