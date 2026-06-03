local RaycastParams = require("../environment/datatypes/RaycastParams")

local testing = zune.testing
local expect = testing.expect

testing.describe("RaycastParams", function()
	testing.test("Creation with new() sets correct default values", function()
		local rp = RaycastParams.new()

		expect(type(rp.FilterDescendantsInstances)).toBe("table")
		expect(#rp.FilterDescendantsInstances).toBe(0)
		expect(rp.FilterType).toBe(0) -- Enum.RaycastFilterType.Whitelist
		expect(rp.IgnoreWater).toBeFalsy()
		expect(rp.CollisionGroup).toBe("Default")
		expect(rp.RespectCanCollide).toBeFalsy()
		expect(rp.BruteForceAllSlow).toBeFalsy()
		expect(rp.VisualizeRay).toBeFalsy()

		expect(type(rp.ExcludeInstances)).toBe("table")
		expect(#rp.ExcludeInstances).toBe(0)
		expect(type(rp.IncludeInstances)).toBe("table")
		expect(#rp.IncludeInstances).toBe(0)
	end)

	testing.test("AddToFilter adds a single instance", function()
		local rp = RaycastParams.new()
		-- We use a string here because in Luau, typeof(table) == "table"
		-- The method treats tables as an array of instances.
		local instance1 = "MockInstance1"

		rp:AddToFilter(instance1)

		expect(#rp.FilterDescendantsInstances).toBe(1)
		expect(rp.FilterDescendantsInstances[1]).toBe(instance1)
	end)

	testing.test("AddToFilter adds multiple instances", function()
		local rp = RaycastParams.new()
		local instance1 = "MockInstance1"
		local instance2 = "MockInstance2"

		rp:AddToFilter({instance1, instance2})

		expect(#rp.FilterDescendantsInstances).toBe(2)
		expect(rp.FilterDescendantsInstances[1]).toBe(instance1)
		expect(rp.FilterDescendantsInstances[2]).toBe(instance2)
	end)

	testing.test("ToTable converts properties properly", function()
		local rp = RaycastParams.new()
		rp.IgnoreWater = true
		rp.FilterType = 1 -- Blacklist
		local instance1 = "MockInstance1"
		rp:AddToFilter(instance1)

		local tbl = rp:ToTable()

		expect(tbl.type).toBe("RaycastParams")
		expect(tbl.IgnoreWater).toBeTruthy()
		expect(tbl.FilterType).toBe(1)
		expect(tbl.CollisionGroup).toBe("Default")
		expect(#tbl.FilterDescendantsInstances).toBe(1)
		expect(tbl.FilterDescendantsInstances[1]).toBe(instance1)

		-- verify array was actually copied
		rp.FilterDescendantsInstances[1] = nil
		expect(tbl.FilterDescendantsInstances[1]).toBe(instance1)
	end)

	testing.test("FromTable reconstitutes object correctly", function()
		local instance1 = "MockInstance1"
		local tbl = {
			type = "RaycastParams",
			FilterDescendantsInstances = { instance1 },
			FilterType = 1,
			IgnoreWater = true,
			CollisionGroup = "CustomGroup",
			RespectCanCollide = true,
			BruteForceAllSlow = true,
			VisualizeRay = true,
			ExcludeInstances = { instance1 },
			IncludeInstances = { instance1 }
		}

		local rp = RaycastParams.FromTable(tbl)

		expect(rp.IgnoreWater).toBeTruthy()
		expect(rp.FilterType).toBe(1)
		expect(rp.CollisionGroup).toBe("CustomGroup")
		expect(rp.RespectCanCollide).toBeTruthy()
		expect(rp.BruteForceAllSlow).toBeTruthy()
		expect(rp.VisualizeRay).toBeTruthy()

		expect(#rp.FilterDescendantsInstances).toBe(1)
		expect(rp.FilterDescendantsInstances[1]).toBe(instance1)

		-- verify array was deeply copied
		tbl.FilterDescendantsInstances[1] = nil
		expect(rp.FilterDescendantsInstances[1]).toBe(instance1)
	end)

	testing.test("FromTable errors on invalid input", function()
		local ok1 = pcall(function() RaycastParams.FromTable(nil) end)
		expect(ok1).toBeFalsy()

		local ok2 = pcall(function() RaycastParams.FromTable({ type = "WrongType" }) end)
		expect(ok2).toBeFalsy()
	end)
end)
