-- description: "Creates bloom for the environment, Parented under Lighting."
local Enum = require("@EnumMap")

local propTable = {
	Mode = Enum.KinemiumBloomMode.Mix,
	Levels = 0.5,
	Intensity = 0.05,
	Threshold = 0.6,
	SoftThreshold = 0.5,
	FilterRadius = 1.0,
	Enabled = true,
	Name = "BloomEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "BloomEffect",
	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envBloom = r3d.structs.R3D_EnvBloom:new({
			mode = instance.Enabled and instance.Mode.Value or 0,
			levels = instance.Levels,
			intensity = instance.Intensity,
			threshold = instance.Threshold,
			softThreshold = instance.SoftThreshold,
			filterRadius = instance.FilterRadius,
		})
		instance:SetMetadata("EffectObject", envBloom)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envBloom = r3d.structs.R3D_EnvBloom:new({
				mode = instance.Enabled and instance.Mode.Value or 0,
				levels = instance.Levels,
				intensity = instance.Intensity,
				threshold = instance.Threshold,
				softThreshold = instance.SoftThreshold,
				filterRadius = instance.FilterRadius,
			})
			instance:SetMetadata("EffectObject", envBloom)
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
