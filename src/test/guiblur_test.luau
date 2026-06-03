local guiblur = require("../renderer/guiblur")
local testing = zune.testing
local expect = testing.expect

testing.describe("guiblur", function()
	testing.test("extract_texture returns table with id", function()
		local t = { id = "texture_id" }
		local result = guiblur._extract_texture(t)
		expect(result).toBe(t)
	end)
end)
