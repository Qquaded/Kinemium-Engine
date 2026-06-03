local Random = require("../environment/datatypes/Random")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

testing.describe("Random", function()
	testing.test("Creation with seed", function()
		local r = Random.new(12345)
		expect(r ~= nil).toBeTruthy()
	end)

	testing.test("Creation without seed", function()
		local r = Random.new()
		expect(r ~= nil).toBeTruthy()
	end)

	testing.test("NextInteger returns integers in range", function()
		local r = Random.new(42)
		local val = r:NextInteger(1, 10)
		expect(val >= 1).toBeTruthy()
		expect(val <= 10).toBeTruthy()
		expect(type(val)).toBe("number")
	end)

	testing.test("NextInteger same seed produces same sequence", function()
		local r1 = Random.new(12345)
		local r2 = Random.new(12345)
		for _ = 1, 10 do
			local v1 = r1:NextInteger(1, 100)
			local v2 = r2:NextInteger(1, 100)
			expect(v1).toBe(v2)
		end
	end)

	testing.test("NextNumber returns number in default range", function()
		local r = Random.new(42)
		local val = r:NextNumber()
		expect(val >= 0).toBeTruthy()
		expect(val <= 1).toBeTruthy()
	end)

	testing.test("NextNumber returns number in custom range", function()
		local r = Random.new(42)
		local val = r:NextNumber(5, 10)
		expect(val >= 5).toBeTruthy()
		expect(val <= 10).toBeTruthy()
	end)

	testing.test("NextUnitVector returns normalized vector", function()
		local r = Random.new(42)
		local vec = r:NextUnitVector()
		local mag = math.sqrt(vec.X * vec.X + vec.Y * vec.Y + vec.Z * vec.Z)
		expect(near(mag, 1, 1e-5)).toBeTruthy()
	end)

	testing.test("ToTable returns type info", function()
		local r = Random.new(42)
		local tbl = r:ToTable()
		expect(tbl.type).toBe("Random")
	end)

	testing.test("FromTable creates new Random", function()
		local r1 = Random.new(42)
		local tbl = r1:ToTable()
		local r2 = Random.FromTable(tbl)
		expect(r2 ~= nil).toBeTruthy()
	end)
end)
