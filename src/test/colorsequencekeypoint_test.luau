local ColorSequenceKeypoint = require("../environment/datatypes/ColorSequenceKeypoint")
local Color3 = require("../environment/datatypes/Color3")

local testing = zune.testing
local expect = testing.expect

local function near(a, b, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(a - b) <= epsilon
end

local function expectColorNear(a, b, epsilon)
	expect(near(a.R, b.R, epsilon)).toBeTruthy()
	expect(near(a.G, b.G, epsilon)).toBeTruthy()
	expect(near(a.B, b.B, epsilon)).toBeTruthy()
end

testing.describe("ColorSequenceKeypoint", function()
	testing.test("Creation", function()
		local color = Color3.new(0.5, 0.25, 0.75)
		local kp = ColorSequenceKeypoint.new(0.5, color)
		expect(near(kp.Position, 0.5)).toBeTruthy()
		expectColorNear(kp.Color, color)
	end)

	testing.test("Creation validates position limits", function()
		local color = Color3.new(1, 1, 1)

		local ok1 = pcall(function()
			ColorSequenceKeypoint.new(-0.1, color)
		end)
		expect(ok1).toBeFalsy()

		local ok2 = pcall(function()
			ColorSequenceKeypoint.new(1.1, color)
		end)
		expect(ok2).toBeFalsy()
	end)

	testing.test("Creation validates color type", function()
		local ok = pcall(function()
			ColorSequenceKeypoint.new(0.5, "red")
		end)
		expect(ok).toBeFalsy()
	end)

	testing.test("Lerp", function()
		local kp1 = ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0))
		local kp2 = ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))

		local mid = kp1:Lerp(kp2, 0.5)
		expect(near(mid.Position, 0.5)).toBeTruthy()
		expect(near(mid.Color.R, 0.5)).toBeTruthy()
		expect(near(mid.Color.G, 0.5)).toBeTruthy()
		expect(near(mid.Color.B, 0.5)).toBeTruthy()

		local start = kp1:Lerp(kp2, 0)
		expect(near(start.Position, 0)).toBeTruthy()
		expectColorNear(start.Color, kp1.Color)

		local finish = kp1:Lerp(kp2, 1)
		expect(near(finish.Position, 1)).toBeTruthy()
		expectColorNear(finish.Color, kp2.Color)
	end)
end)
