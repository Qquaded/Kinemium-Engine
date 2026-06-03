_G.log = function() end
_G.warn = function() end

local Registry = require("../environment/class/Registry")
local test = zune.testing

local rendererMock = {
	Pool = { new = function() end },
	Hook = { new = function() end },
}
local datamodelMock = {
	GetService = function()
		return {
			jolt = { lib = {}, physicsSystem = {} },
			CreateWeld = function()
				return {}
			end,
		}
	end,
}

local cloneProbeCallbacks = 0
Registry.createclass({
	class = "CloneProbe",
	callback = function(instance)
		cloneProbeCallbacks += 1
		instance.RuntimeReady = true
		instance.Value = "default"
		instance.Changed:Connect(function(property, value)
			if property == "Value" then
				instance.LastValue = value
			end
		end)
		return instance
	end,
})

test.test("Weld creation", function()
	local weld = Registry.new("Weld", rendererMock, datamodelMock)
	assert(weld.Name == "Weld")
	assert(weld.Enabled == true)
end)

test.test("SurfaceLight creation", function()
	local surfaceLight = Registry.new("SurfaceLight", rendererMock, datamodelMock)
	assert(surfaceLight.Name == "SurfaceLight")
	assert(surfaceLight.Angle == 90)
end)

test.test("SpotLight creation", function()
	local spotLight = Registry.new("SpotLight", rendererMock, datamodelMock)
	assert(spotLight.Name == "SpotLight")
	assert(spotLight.Angle == 90)
end)

test.test("Can create Configuration", function()
	local inst = Registry.new("Configuration", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("Configuration")
	test.expect(inst.Name).toBe("Configuration")
end)

test.test("Can create SpawnLocation", function()
	local inst = Registry.new("SpawnLocation", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("SpawnLocation")
end)

test.test("Can create Seat", function()
	local inst = Registry.new("Seat", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("Seat")
end)

test.test("Can create VehicleSeat", function()
	local inst = Registry.new("VehicleSeat", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("VehicleSeat")
end)

test.test("Can create WedgePart", function()
	local inst = Registry.new("WedgePart", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("WedgePart")
end)

test.test("Can create CornerWedgePart", function()
	local inst = Registry.new("CornerWedgePart", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("CornerWedgePart")
end)

test.test("Can create TrussPart", function()
	local inst = Registry.new("TrussPart", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("TrussPart")
end)

test.test("Can create SurfaceGui", function()
	local inst = Registry.new("SurfaceGui", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("SurfaceGui")
end)

test.test("Can create DoubleConstrainedValue", function()
	local inst = Registry.new("DoubleConstrainedValue", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("DoubleConstrainedValue")
end)

test.test("Can create IntConstrainedValue", function()
	local inst = Registry.new("IntConstrainedValue", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("IntConstrainedValue")
end)

test.test("Can create Accessory", function()
	local inst = Registry.new("Accessory", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("Accessory")
end)

test.test("Can create AlignPosition", function()
	local inst = Registry.new("AlignPosition", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("AlignPosition")
end)

test.test("Can create AlignOrientation", function()
	local inst = Registry.new("AlignOrientation", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("AlignOrientation")
end)

test.test("Can create LineForce", function()
	local inst = Registry.new("LineForce", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("LineForce")
end)

test.test("Can create Torque", function()
	local inst = Registry.new("Torque", rendererMock, datamodelMock, true)
	test.expect(inst.ClassName).toBe("Torque")
end)

test.test("Clone initializes class callback and preserves copied properties", function()
	local inst = Registry.new("CloneProbe", rendererMock, datamodelMock, true)
	inst.Value = "custom"

	local clone = inst:Clone()
	test.expect(clone.RuntimeReady).toBe(true)
	test.expect(clone.Value).toBe("custom")
	assert(cloneProbeCallbacks >= 2)

	clone.Value = "changed"
	test.expect(clone.LastValue).toBe("changed")
end)
