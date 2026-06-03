local NumberRange = require("../environment/datatypes/NumberRange")

local testing = zune.testing
local expect = testing.expect

testing.describe("NumberRange", function()
	testing.test("Creation with no arguments", function()
		local range = NumberRange.new()
		expect(range.Min).toBe(0)
		expect(range.Max).toBe(0)
	end)

	testing.test("Creation with single argument", function()
		local range = NumberRange.new(5.5)
		expect(range.Min).toBe(5.5)
		expect(range.Max).toBe(5.5)
	end)

	testing.test("Creation with multiple arguments", function()
		local range = NumberRange.new(2.5, 7.5)
		expect(range.Min).toBe(2.5)
		expect(range.Max).toBe(7.5)
	end)

	testing.test("__tostring contains NumberRange", function()
		local range = NumberRange.new(1.2, 3.4)
		local str = tostring(range)
		expect(string.find(str, "NumberRange(1.2, 3.4)", 1, true) ~= nil).toBeTruthy()
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local a = NumberRange.new(10.5, 20.5)
		local tbl = a:ToTable()
		local b = NumberRange.FromTable(tbl)
		expect(b.Min).toBe(10.5)
		expect(b.Max).toBe(20.5)
	end)
end)
