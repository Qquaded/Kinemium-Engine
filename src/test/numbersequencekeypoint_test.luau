local NumberSequenceKeypoint = require("../environment/datatypes/NumberSequenceKeypoint")

local testing = zune.testing
local expect = testing.expect

testing.describe("NumberSequenceKeypoint", function()
	testing.test("Creation with valid arguments", function()
		local kp = NumberSequenceKeypoint.new(0.5, 1.5)
		expect(kp.Time).toBe(0.5)
		expect(kp.Value).toBe(1.5)
		expect(kp.ClassName).toBe("NumberSequenceKeypoint")
	end)

	testing.test("Creation with invalid time argument", function()
		local success, err = pcall(function()
			NumberSequenceKeypoint.new("0.5", 1.5)
		end)
		expect(success).toBeFalsy()
		expect(string.find(err, "bad argument #1 to 'NumberSequenceKeypoint.new' %(number expected%)") ~= nil).toBeTruthy()
	end)

	testing.test("Creation with invalid value argument", function()
		local success, err = pcall(function()
			NumberSequenceKeypoint.new(0.5, "1.5")
		end)
		expect(success).toBeFalsy()
		expect(string.find(err, "bad argument #2 to 'NumberSequenceKeypoint.new' %(number expected%)") ~= nil).toBeTruthy()
	end)

	testing.test("ToTable creates correct table", function()
		local kp = NumberSequenceKeypoint.new(0.2, 0.8)
		local tbl = kp:ToTable()
		expect(tbl.type).toBe("NumberSequenceKeypoint")
		expect(tbl.Time).toBe(0.2)
		expect(tbl.Value).toBe(0.8)
	end)

	testing.test("FromTable creates correct object", function()
		local tbl = {
			type = "NumberSequenceKeypoint",
			Time = 0.3,
			Value = 0.7,
		}
		local kp = NumberSequenceKeypoint.FromTable(tbl)
		expect(kp.Time).toBe(0.3)
		expect(kp.Value).toBe(0.7)
		expect(kp.ClassName).toBe("NumberSequenceKeypoint")
	end)

	testing.test("FromTable with invalid type", function()
		local tbl = {
			type = "WrongType",
			Time = 0.3,
			Value = 0.7,
		}
		local success = pcall(function()
			NumberSequenceKeypoint.FromTable(tbl)
		end)
		expect(success).toBeFalsy()
	end)
end)
