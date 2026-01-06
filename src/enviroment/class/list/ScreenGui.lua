local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local UDim = require("@UDim")
local signal = require("@Kinemium.signal")
local Vector2 = require("@Vector2")

return {
	class = "ScreenGui",

	callback = function(instance, renderer)
		local lib = renderer.lib

		instance:SetProperties({
			Name = "ScreenGui",
			Enabled = true,
			GravityY = -50,
			GravityX = 0,
			PhysicsEnabled = false,
			ZIndexBehavior = "Sibling",
			render = function(lib, object)
				object.Size = UDim2.new(0, lib.GetRenderWidth(), 0, lib.GetRenderHeight())
			end,
			ResetOnSpawn = true,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, lib.GetRenderWidth(), 0, lib.GetRenderHeight()),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
		})

		return instance
	end,
}
