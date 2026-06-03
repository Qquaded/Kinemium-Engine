-- description: "Creates a color effect for the Environment, Works if parented under Lighting."
local propTable = {
	Brightness = 0.0,
	Contrast = 1.0,
	Saturation = 1.0,
	Enabled = true,
	Name = "ColorEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "ColorEffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envcolor = r3d.structs.R3D_EnvColor:new({
			brightness = instance.Brightness,
			contrast = instance.Contrast,
			saturation = instance.Saturation,
		})
		instance:SetMetadata("EffectObject", envcolor)

		instance.Changed:Connect(function(property, value)
			envcolor = r3d.structs.R3D_EnvColor:new({
				brightness = instance.Brightness,
				contrast = instance.Contrast,
				saturation = instance.Saturation,
			})
			instance:SetMetadata("EffectObject", envcolor)
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
