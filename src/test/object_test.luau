local Object = require("../modules/Aereon/component/objects/Object")
local testing = zune.testing
local expect = testing.expect

testing.describe("Object", function()
	testing.test("Creation with default name", function()
		local obj = Object.new()
		expect(obj.Name).toBe("Object")
		expect(obj.Parent).toBe(nil)
		expect(type(obj.Children)).toBe("table")
	end)

	testing.test("Creation with custom name", function()
		local obj = Object.new("MyObject")
		expect(obj.Name).toBe("MyObject")
		expect(obj.Parent).toBe(nil)
		expect(type(obj.Children)).toBe("table")
	end)
end)
