local Signal = require("../environment/datatypes/Signal")
local testing = zune.testing
local expect = testing.expect

testing.describe("Signal", function()
	testing.test("Creation", function()
		local sig = Signal.new()
		expect(sig).toBeTruthy()
	end)

	testing.test("Connect and Fire", function()
		local sig = Signal.new()
		local fired = false
		local value = nil

		sig:Connect(function(v)
			fired = true
			value = v
		end)

		sig:Fire("test_value")

		expect(fired).toBe(true)
		expect(value).toBe("test_value")
	end)

	testing.test("Disconnect", function()
		local sig = Signal.new()
		local count = 0

		local conn = sig:Connect(function()
			count = count + 1
		end)

		sig:Fire()
		expect(count).toBe(1)

		conn:Disconnect()

		sig:Fire()
		expect(count).toBe(1)
	end)
end)
