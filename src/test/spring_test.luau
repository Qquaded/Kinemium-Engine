local Spring = require("../environment/datatypes/Spring")
local Vector3 = require("../environment/datatypes/Vector3")
local CFrame = require("../environment/datatypes/CFrame")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-3
	return math.abs(a - b) <= epsilon
end

testing.describe("Spring", function()
	testing.test("Number spring basic controls", function()
		local s = Spring.new(1, 6, "Number", 0)
		s:set(10)
		expect(s.target).toBe(10)

		local before = s:step(1 / 60)
		expect(before).toBe(0) -- not running

		s:Play()
		local after = s:step(1 / 60)
		expect(after > 0).toBeTruthy()

		s:Pause()
		local paused = s.value
		s:step(1 / 60)
		expect(s.value).toBe(paused)

		s:shove(3)
		expect(s.velocity).toBe(3)

		s:Stop()
		expect(s.running).toBeFalsy()
		expect(s.velocity).toBe(0)

		s:setValue(4)
		expect(s.value).toBe(4)
		expect(s.target).toBe(4)
		expect(s.velocity).toBe(0)
	end)

	testing.test("Critically damped converges without overshoot in simple case", function()
		local s = Spring.new(1, 5, "Number", 0)
		s:set(1)
		s:Play()
		local overshot = false
		for _ = 1, 180 do
			local v = s:step(1 / 60)
			if v > 1 then
				overshot = true
			end
		end
		expect(near(s.value, 1, 0.02)).toBeTruthy()
		expect(overshot).toBeFalsy()
	end)

	testing.test("Underdamped can overshoot target", function()
		local s = Spring.new(0.2, 4, "Number", 0)
		s:set(1)
		s:Play()
		local overshot = false
		for _ = 1, 240 do
			local v = s:step(1 / 120)
			if v > 1 then
				overshot = true
				break
			end
		end
		expect(overshot).toBeTruthy()
	end)

	testing.test("Overdamped converges slower than critical at same frequency", function()
		local critical = Spring.new(1, 5, "Number", 0)
		local overdamped = Spring.new(2, 5, "Number", 0)
		critical:set(1)
		overdamped:set(1)
		critical:Play()
		overdamped:Play()
		for _ = 1, 24 do
			critical:step(1 / 120)
			overdamped:step(1 / 120)
		end
		local criticalErr = math.abs(critical.value - 1)
		local overdampedErr = math.abs(overdamped.value - 1)
		expect(overdampedErr > criticalErr).toBeTruthy()
	end)

	testing.test("Vector3 spring steps and Stop resets velocity", function()
		local s = Spring.new(1, 6, "Vector3", Vector3.new(0, 0, 0))
		s:set(Vector3.new(10, 0, 0))
		s:Play()
		local v = s:step(1 / 60)
		expect(v.X > 0).toBeTruthy()
		expect(v.Y).toBe(0)
		expect(v.Z).toBe(0)
		s:Stop()
		expect(s.velocity.X).toBe(0)
		expect(s.velocity.Y).toBe(0)
		expect(s.velocity.Z).toBe(0)
	end)

	testing.test("CFrame spring branch currently errors on subtraction path", function()
		local s = Spring.new(1, 6, "CFrame", CFrame.new(0, 0, 0))
		s:set(CFrame.new(10, 0, 0))
		s:Play()
		local ok, err = pcall(function()
			s:step(1 / 60)
		end)
		expect(ok).toBeFalsy()
		expect(type(err)).toBe("string")
	end)

	testing.test("ToTable with Vector3 values returns typed table", function()
		local s = Spring.new(1, 6, "Vector3", Vector3.new(1, 2, 3))
		local tbl = s:ToTable()
		expect(tbl.type).toBe("Spring")
		expect(tbl.typeName).toBe("Vector3")
		expect(tbl.value.type).toBe("Vector3")
	end)

	testing.test("FromTable accepts object fields", function()
		local tbl = {
			type = "Spring",
			d = 1,
			f = 6,
			typeName = "Vector3",
			value = Vector3.new(1, 2, 3),
			velocity = Vector3.new(0, 0, 0),
			target = Vector3.new(4, 5, 6),
			running = true,
		}
		local s = Spring.FromTable(tbl)
		expect(s.typeName).toBe("Vector3")
		expect(s.value.X).toBe(1)
		expect(s.target.Z).toBe(6)
		expect(s.running).toBeTruthy()
	end)

	testing.test("Unsupported type currently errors", function()
		local ok = pcall(function()
			Spring.new(1, 6, "UDim2", nil)
		end)
		expect(ok).toBeFalsy()
	end)
end)
