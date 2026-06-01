-- description: "Creates a fog effect in Lighting."
local Color3 = require("@Color3")
local Enum = require("@EnumMap")

local propTable = {
	Mode = Enum.KinemiumFogMode.Linear, -- Linear, Exponential, Exponential2
	Color = Color3.new(0.7, 0.7, 0.7),
	Start = 1.0,
	End = 100.0,
	Density = 0.1,
	SkyAffect = 0.5,
	Enabled = true,
	Name = "FogEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "FogEffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local color = instance.Color:ToRaylib(0)

		local envfog = r3d.structs.R3D_EnvFog:new({
			mode = instance.Enabled and instance.Mode.Value or 0,
			color = color,
			start = instance.Start,
			["end"] = instance.End,
			density = instance.Density,
			skyAffect = instance.SkyAffect,
		})
		instance:SetMetadata("EffectObject", envfog)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			local color = instance.Color:ToRaylib(0)

			envfog = r3d.structs.R3D_EnvFog:new({
				mode = instance.Enabled and instance.Mode.Value or 0,
				color = color,
				start = instance.Start,
				["end"] = instance.End,
				density = instance.Density,
				skyAffect = instance.SkyAffect,
			})
			instance:SetMetadata("EffectObject", envfog)
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
