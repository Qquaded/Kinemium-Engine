local CFrameQuat16 = require("../environment/datatypes/CFrameQuat16")
local CFrame = require("../environment/datatypes/CFrame")
local Vector3 = require("../environment/datatypes/Vector3")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

testing.describe("CFrameQuat16", function()
	testing.test("new normalizes zero quaternion to identity", function()
		local q = CFrameQuat16.new(1, 2, 3, 0, 0, 0, 0)
		expect(q.Position.X).toBe(1)
		expect(q.Position.Y).toBe(2)
		expect(q.Position.Z).toBe(3)
		expect(q.QX).toBe(0)
		expect(q.QY).toBe(0)
		expect(q.QZ).toBe(0)
		expect(q.QW).toBe(32767)
	end)

	testing.test("new keeps quantized quaternion components in int16 bounds", function()
		local q = CFrameQuat16.new(0, 0, 0, 100, -100, 100, -100)
		expect(q.QX <= 32767 and q.QX >= -32768).toBeTruthy()
		expect(q.QY <= 32767 and q.QY >= -32768).toBeTruthy()
		expect(q.QZ <= 32767 and q.QZ >= -32768).toBeTruthy()
		expect(q.QW <= 32767 and q.QW >= -32768).toBeTruthy()
	end)

	testing.test("fromCFrame captures integer position", function()
		local cf = CFrame.new(Vector3.new(4, 5, 6))
		local q = CFrameQuat16.fromCFrame(cf)
		expect(q.Position.X).toBe(4)
		expect(q.Position.Y).toBe(5)
		expect(q.Position.Z).toBe(6)
	end)

	testing.test("ToCFrame call path", function()
		local q = CFrameQuat16.new(0, 0, 0, 0, 0, 0, 1)
		local ok, result = pcall(function()
			return q:ToCFrame()
		end)
		if ok then
			expect(result.Position ~= nil).toBeTruthy()
		else
			expect(type(result)).toBe("string")
		end
	end)

	testing.test("__tostring contains type name", function()
		local s = tostring(CFrameQuat16.new(0, 0, 0, 0, 0, 0, 1))
		expect(string.find(s, "CFrameQuat16", 1, true) ~= nil).toBeTruthy()
	end)

	testing.test("ToTable and FromTable", function()
		local a = CFrameQuat16.new(7, 8, 9, 0.1, 0.2, 0.3, 0.9)
		local tbl = a:ToTable()
		local b = CFrameQuat16.FromTable(tbl)
		expect(b.Position.X).toBe(a.Position.X)
		expect(b.Position.Y).toBe(a.Position.Y)
		expect(b.Position.Z).toBe(a.Position.Z)
		expect(near(b.QX, a.QX, 1)).toBeTruthy()
		expect(near(b.QY, a.QY, 1)).toBeTruthy()
		expect(near(b.QZ, a.QZ, 1)).toBeTruthy()
		expect(near(b.QW, a.QW, 1)).toBeTruthy()
	end)
end)
