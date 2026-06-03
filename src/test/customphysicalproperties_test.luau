local CustomPhysicalProperties = require("../environment/datatypes/CustomPhysicalProperties")

local testing = zune.testing
local expect = testing.expect

testing.describe("CustomPhysicalProperties", function()
	testing.test("Creation defaults", function()
		local props = CustomPhysicalProperties.new()
		expect(props.Density).toBe(0.7)
		expect(props.Friction).toBe(0.3)
		expect(props.Elasticity).toBe(0.5)
		expect(props.FrictionWeight).toBe(1.0)
		expect(props.ElasticityWeight).toBe(1.0)
	end)

	testing.test("Creation with custom values", function()
		local props = CustomPhysicalProperties.new(2.0, 0.8, 0.9, 0.4, 0.6)
		expect(props.Density).toBe(2.0)
		expect(props.Friction).toBe(0.8)
		expect(props.Elasticity).toBe(0.9)
		expect(props.FrictionWeight).toBe(0.4)
		expect(props.ElasticityWeight).toBe(0.6)
	end)
end)
