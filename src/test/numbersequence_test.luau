local NumberSequence = require("../environment/datatypes/NumberSequence")
local NumberSequenceKeypoint = require("../environment/datatypes/NumberSequenceKeypoint")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

testing.describe("NumberSequence", function()
	testing.test("Creation with constant value", function()
		local seq = NumberSequence.new(0.5)
		expect(#seq.Keypoints).toBe(2)
		expect(seq.Keypoints[1].Value).toBe(0.5)
		expect(seq.Keypoints[2].Value).toBe(0.5)
	end)

	testing.test("Creation with keypoints array", function()
		local kp1 = NumberSequenceKeypoint.new(0, 0)
		local kp2 = NumberSequenceKeypoint.new(1, 1)
		local seq = NumberSequence.new({ kp1, kp2 })
		expect(#seq.Keypoints).toBe(2)
	end)

	testing.test("Creation with variadic keypoints", function()
		local kp1 = NumberSequenceKeypoint.new(0, 0)
		local kp2 = NumberSequenceKeypoint.new(0.5, 1)
		local kp3 = NumberSequenceKeypoint.new(1, 0)
		local seq = NumberSequence.new(kp1, kp2, kp3)
		expect(#seq.Keypoints).toBe(3)
	end)

	testing.test("Creation sorts keypoints by time", function()
		local kp1 = NumberSequenceKeypoint.new(1, 1)
		local kp2 = NumberSequenceKeypoint.new(0, 0)
		local seq = NumberSequence.new({ kp1, kp2 })
		expect(seq.Keypoints[1].Time).toBe(0)
		expect(seq.Keypoints[2].Time).toBe(1)
	end)

	testing.test("Evaluate at start position", function()
		local seq = NumberSequence.new(0.5)
		expect(seq:Evaluate(0)).toBe(0.5)
	end)

	testing.test("Evaluate at end position", function()
		local seq = NumberSequence.new(0.5)
		expect(seq:Evaluate(1)).toBe(0.5)
	end)

	testing.test("Evaluate linear interpolation", function()
		local kp1 = NumberSequenceKeypoint.new(0, 0)
		local kp2 = NumberSequenceKeypoint.new(1, 1)
		local seq = NumberSequence.new({ kp1, kp2 })
		local v = seq:Evaluate(0.5)
		expect(near(v, 0.5)).toBeTruthy()
	end)

	testing.test("Evaluate with three keypoints", function()
		local kp1 = NumberSequenceKeypoint.new(0, 0)
		local kp2 = NumberSequenceKeypoint.new(0.5, 1)
		local kp3 = NumberSequenceKeypoint.new(1, 0)
		local seq = NumberSequence.new({ kp1, kp2, kp3 })

		expect(seq:Evaluate(0)).toBe(0)
		expect(seq:Evaluate(0.5)).toBe(1)
		expect(seq:Evaluate(1)).toBe(0)
	end)

	testing.test("Evaluate clamps to first value for t < 0", function()
		local kp1 = NumberSequenceKeypoint.new(0, 1)
		local kp2 = NumberSequenceKeypoint.new(1, 2)
		local seq = NumberSequence.new({ kp1, kp2 })
		expect(seq:Evaluate(-0.5)).toBe(1)
	end)

	testing.test("Evaluate clamps to last value for t > 1", function()
		local kp1 = NumberSequenceKeypoint.new(0, 1)
		local kp2 = NumberSequenceKeypoint.new(1, 2)
		local seq = NumberSequence.new({ kp1, kp2 })
		expect(seq:Evaluate(1.5)).toBe(2)
	end)

	testing.test("ToTable and FromTable roundtrip", function()
		local kp1 = NumberSequenceKeypoint.new(0, 0)
		local kp2 = NumberSequenceKeypoint.new(1, 1)
		local a = NumberSequence.new({ kp1, kp2 })
		local tbl = a:ToTable()
		local b = NumberSequence.FromTable(tbl)
		expect(#b.Keypoints).toBe(2)
	end)
end)
