local Octree = require("../environment/datatypes/Octree")
local Vector3 = require("../environment/datatypes/Vector3")

local testing = zune.testing
local expect = testing.expect

local function hasId(results, id)
	for _, obj in ipairs(results) do
		if obj.id == id then
			return true
		end
	end
	return false
end

testing.describe("Octree", function()
	testing.test("Insert and QueryAABB subset", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 64, 4, 8, 1.5)
		tree:Insert({ id = 1, position = Vector3.new(-10, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 2, position = Vector3.new(-5, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 3, position = Vector3.new(0, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 4, position = Vector3.new(5, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 5, position = Vector3.new(10, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })

		local found = tree:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(5, 1, 1))
		expect(hasId(found, 2)).toBeTruthy()
		expect(hasId(found, 3)).toBeTruthy()
		expect(hasId(found, 4)).toBeTruthy()
		expect(hasId(found, 1)).toBeFalsy()
		expect(hasId(found, 5)).toBeFalsy()
	end)

	testing.test("Remove excludes object from future queries", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 32, 4, 8, 1.5)
		tree:Insert({ id = 10, position = Vector3.new(1, 1, 1), size = Vector3.new(0.2, 0.2, 0.2) })
		expect(hasId(tree:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)), 10)).toBeTruthy()
		tree:Remove(10)
		expect(hasId(tree:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)), 10)).toBeFalsy()
	end)

	testing.test("Update moves object to new position", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 32, 4, 8, 1.5)
		tree:Insert({ id = 20, position = Vector3.new(-6, 0, 0), size = Vector3.new(0.2, 0.2, 0.2) })
		tree:Update({ id = 20, position = Vector3.new(6, 0, 0), size = Vector3.new(0.2, 0.2, 0.2) })

		expect(hasId(tree:QueryAABB(Vector3.new(-6, 0, 0), Vector3.new(0.5, 0.5, 0.5)), 20)).toBeFalsy()
		expect(hasId(tree:QueryAABB(Vector3.new(6, 0, 0), Vector3.new(0.5, 0.5, 0.5)), 20)).toBeTruthy()
	end)

	testing.test("Subdivision occurs after capacity is exceeded", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 32, 1, 4, 1.5)
		tree:Insert({ id = 31, position = Vector3.new(-4, -4, -4), size = Vector3.new(0.1, 0.1, 0.1) })
		tree:Insert({ id = 32, position = Vector3.new(4, 4, 4), size = Vector3.new(0.1, 0.1, 0.1) })
		expect(tree.root.children ~= nil).toBeTruthy()
		expect(#tree.root.children).toBe(8)
	end)

	testing.test("Boundary intersection includes edge-touching objects", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 32, 4, 8, 1.5)
		tree:Insert({ id = 40, position = Vector3.new(8, 0, 0), size = Vector3.new(0, 0, 0) })
		local found = tree:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(8, 1, 1))
		expect(hasId(found, 40)).toBeTruthy()
	end)

	testing.test("ToTable/FromTable roundtrip preserves query results", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 64, 3, 6, 1.5)
		tree:Insert({ id = 51, position = Vector3.new(-3, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 52, position = Vector3.new(0, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })
		tree:Insert({ id = 53, position = Vector3.new(3, 0, 0), size = Vector3.new(0.5, 0.5, 0.5) })

		local clone = Octree.FromTable(tree:ToTable())
		local found = clone:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(4, 1, 1))
		expect(hasId(found, 51)).toBeTruthy()
		expect(hasId(found, 52)).toBeTruthy()
		expect(hasId(found, 53)).toBeTruthy()
	end)

	testing.test("Clear removes all objects", function()
		local tree = Octree.new(Vector3.new(0, 0, 0), 32, 4, 8, 1.5)
		tree:Insert({ id = 60, position = Vector3.new(1, 1, 1), size = Vector3.new(0.1, 0.1, 0.1) })
		tree:Clear()
		local found = tree:QueryAABB(Vector3.new(0, 0, 0), Vector3.new(4, 4, 4))
		expect(#found).toBe(0)
	end)
end)
