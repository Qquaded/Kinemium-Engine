local BrickColor = require("@BrickColor")

local testing = zune.testing
local expect = testing.expect

local function expectColor3Near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	expect(math.abs(a.R - b.R) <= epsilon).toBeTruthy()
	expect(math.abs(a.G - b.G) <= epsilon).toBeTruthy()
	expect(math.abs(a.B - b.B) <= epsilon).toBeTruthy()
end

testing.describe("BrickColor", function()
	testing.test("Basic color getters", function()
		expect(BrickColor.White()).toBeTruthy()
		expect(BrickColor.Gray()).toBeTruthy()
		expect(BrickColor.DarkGray()).toBeTruthy()
		expect(BrickColor.Black()).toBeTruthy()
		expect(BrickColor.Red()).toBeTruthy()
		expect(BrickColor.Yellow()).toBeTruthy()
		expect(BrickColor.Green()).toBeTruthy()
		expect(BrickColor.Blue()).toBeTruthy()
	end)

	testing.test("new from name", function()
		local bc = BrickColor.new("Bright red")
		expect(bc.Name).toBe("Bright red")
		expect(bc.Number).toBe(21)
	end)

	testing.test("new errors on invalid name", function()
		local ok = pcall(function()
			BrickColor.new("NonExistentColorName")
		end)
		expect(ok).toBeFalsy()
	end)

	testing.test("palette from id", function()
		local bc = BrickColor.palette(21)
		expect(bc.Name).toBe("Bright red")
		expect(bc.Number).toBe(21)
	end)

	testing.test("palette errors on invalid id", function()
		local ok = pcall(function()
			BrickColor.palette(-1)
		end)
		expect(ok).toBeFalsy()
	end)

	testing.test("fromColor3 finds closest color", function()
		local redBC = BrickColor.new("Bright red")
		local foundBC = BrickColor.fromColor3(redBC.Color)
		expect(foundBC.Name).toBe("Bright red")
		expect(foundBC.Number).toBe(21)

		local whiteBC = BrickColor.new("White")
		local foundWhite = BrickColor.fromColor3(whiteBC.Color)
		expect(foundWhite.Name).toBe("White")
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local bc = BrickColor.new("Bright red")
		local tbl = bc:ToTable()
		local bc2 = BrickColor.FromTable(tbl)
		expect(bc2.Name).toBe("Bright red")
		expect(bc2.Number).toBe(21)
		expectColor3Near(bc.Color, bc2.Color)
	end)
end)
