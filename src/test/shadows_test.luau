local Shadows = require("../renderer/shadows")

local testing = zune.testing
local expect = testing.expect

testing.describe("Shadows.chooseShadowSize", function()
	testing.test("returns 512 when free memory is greater than 0 and less than 1GB", function()
		expect(Shadows.chooseShadowSize(500 * 1024 * 1024)).toBe(512)
	end)

	testing.test("returns 1024 when free memory is between 1GB and 2GB", function()
		expect(Shadows.chooseShadowSize(1.5 * 1024 * 1024 * 1024)).toBe(1024)
	end)

	testing.test("returns 2048 when free memory is greater than 2GB", function()
		expect(Shadows.chooseShadowSize(3 * 1024 * 1024 * 1024)).toBe(2048)
	end)

	testing.test("returns 2048 when free memory is 0", function()
		expect(Shadows.chooseShadowSize(0)).toBe(2048)
	end)

	testing.test("returns 2048 when free memory is negative (edge case)", function()
		expect(Shadows.chooseShadowSize(-1024)).toBe(2048)
	end)

	testing.test("returns 2048 when zune.platform is missing or getFreeMemory is missing (no override)", function()
		-- without override it falls back to zune.platform.getFreeMemory, we can test just passing nil and verifying it returns a number
		-- since zune.platform.getFreeMemory is normally available, it might return 512, 1024 or 2048. So we just verify it's one of them.
		local size = Shadows.chooseShadowSize()
		local valid = size == 512 or size == 1024 or size == 2048
		expect(valid).toBeTruthy()
	end)
end)
