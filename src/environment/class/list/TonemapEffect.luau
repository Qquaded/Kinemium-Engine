-- description: "Applies tonemapping to adjust the final rendered image's color and exposure."
local Enum = require("@EnumMap")

local propTable = {
	Mode = Enum.KinemiumTonemapMode.ACES, -- ACES, Reinhard, Filmic, Hejl, ACESFilmic
	Exposure = 1.0,
	White = 1.0,
	Enabled = true,
	Name = "TonemapEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "TonemapEffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envtonemap = r3d.structs.R3D_EnvTonemap:new({
			mode = instance.Enabled and instance.Mode.Value or 0,
			exposure = instance.Exposure,
			white = instance.White,
		})
		instance:SetMetadata("EffectObject", envtonemap)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envtonemap = r3d.structs.R3D_EnvTonemap:new({
				mode = instance.Enabled and instance.Mode.Value or 0,
				exposure = instance.Exposure,
				white = instance.White,
			})
			instance:SetMetadata("EffectObject", envtonemap)
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
