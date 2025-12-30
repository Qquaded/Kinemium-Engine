local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local CFrame = require("@CFrame")

local propTable = {
	Position = Vector3.new(0, 0, 0),
	Direction = Vector3.new(0, 0, 0),
	Color = Color3.new(1, 1, 1),
	Brightness = 1, -- intensity of the light
	Range = 10, -- how far the light reaches
	Shadows = true, -- casts shadows or not
	Enabled = true, -- whether the light is active
	Name = "PointLight",
	BaseClass = "Kinemium.light",
	CFrame = CFrame.new(0, 0, 0),
}

return {
	class = "PointLight",
	callback = function(instance, renderer, datamodel)
		local Lighting = datamodel:GetService("Lighting")
		local Kilights = Lighting.kilight

		propTable.Update = function()
			Lighting.RemoveLight(instance.UniqueId)
			Lighting.AddLight(
				instance.UniqueId,
				Kilights.LIGHT_POINT,
				vector.create(instance.Position.X, instance.Position.Y, instance.Position.Z),
				vector.create(instance.Direction.X, instance.Direction.Y, instance.Direction.Z),
				{
					r = instance.Color.R * instance.Brightness,
					g = instance.Color.G * instance.Brightness,
					b = instance.Color.B * instance.Brightness,
					a = 255,
				},
				Lighting.kilight_shader_def
			)
		end

		instance:SetProperties(propTable)

		instance.Changed:Connect(function(prop)
			if prop == "Position" or prop == "Direction" or prop == "Color" or prop == "Brightness" then
				instance.Update()
			end
		end)
		instance.Update()

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
