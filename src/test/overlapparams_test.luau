_G.log = function(...) end

local Enum = require("@EnumMap")
local OverlapParams = require("@OverlapParams")

local testing = zune.testing
local expect = testing.expect

testing.describe("OverlapParams", function()
	testing.test("Creation with default values", function()
		local op = OverlapParams.new()
		expect(op.FilterDescendantsInstances).toBeDefined()
		expect(#op.FilterDescendantsInstances).toBe(0)
		expect(op.FilterType).toBe(Enum.RaycastFilterType.Exclude)
		expect(op.MaxParts).toBe(0)
		expect(op.CollisionGroup).toBe("Default")
	end)

	testing.test("AddToFilter with single instance", function()
		local op = OverlapParams.new()
		-- We use a userdata or something not type "table" to mimic single instance
		-- because the method checks `type(instances) == "table"`
		-- If we pass a table, it thinks it's an array of instances.
		local instance = "TestPart1"
		op:AddToFilter(instance)

		expect(#op.FilterDescendantsInstances).toBe(1)
		expect(op.FilterDescendantsInstances[1]).toBe("TestPart1")
	end)

	testing.test("AddToFilter with table of instances", function()
		local op = OverlapParams.new()
		local instance1 = "TestPart1"
		local instance2 = "TestPart2"
		op:AddToFilter({instance1, instance2})

		expect(#op.FilterDescendantsInstances).toBe(2)
		expect(op.FilterDescendantsInstances[1]).toBe("TestPart1")
		expect(op.FilterDescendantsInstances[2]).toBe("TestPart2")
	end)

	testing.test("ToTable serialization", function()
		local op = OverlapParams.new()
		op.MaxParts = 5
		op.CollisionGroup = "CustomGroup"
		op.FilterType = Enum.RaycastFilterType.Include

		local instance1 = "TestPart1"
		op:AddToFilter(instance1)

		local tbl = op:ToTable()
		expect(tbl.type).toBe("OverlapParams")
		expect(tbl.MaxParts).toBe(5)
		expect(tbl.CollisionGroup).toBe("CustomGroup")
		expect(tbl.FilterType).toBe(Enum.RaycastFilterType.Include)
		expect(#tbl.FilterDescendantsInstances).toBe(1)
		expect(tbl.FilterDescendantsInstances[1]).toBe("TestPart1")
	end)

	testing.test("FromTable deserialization", function()
		local tbl = {
			type = "OverlapParams",
			FilterDescendantsInstances = { "TestPart1" },
			FilterType = Enum.RaycastFilterType.Include,
			MaxParts = 10,
			CollisionGroup = "CustomGroup2",
		}

		local op = OverlapParams.FromTable(tbl)
		expect(op.MaxParts).toBe(10)
		expect(op.CollisionGroup).toBe("CustomGroup2")
		expect(op.FilterType).toBe(Enum.RaycastFilterType.Include)
		expect(#op.FilterDescendantsInstances).toBe(1)
		expect(op.FilterDescendantsInstances[1]).toBe("TestPart1")
	end)

	testing.test("FromTable handles missing fields with defaults", function()
		local tbl = {
			type = "OverlapParams",
		}

		local op = OverlapParams.FromTable(tbl)
		expect(#op.FilterDescendantsInstances).toBe(0)
		expect(op.FilterType).toBe(Enum.RaycastFilterType.Exclude)
		expect(op.MaxParts).toBe(0)
		expect(op.CollisionGroup).toBe("Default")
	end)

	testing.test("FromTable asserts on invalid type", function()
		local ok = pcall(function()
			OverlapParams.FromTable({ type = "WrongType" })
		end)
		expect(ok).toBeFalsy()
	end)
end)