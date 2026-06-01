-- description: "A real-time rendering effect that simulates bounced light by casting and sampling rays in screen space for indirect illumination."
local propTable = {
	SampleCount = 2,
	MaxRaySteps = 32,
	StepSize = 0.125,
	Thickness = 1.0,
	MaxDistance = 4.0,
	FadeStart = 8.0,
	FadeEnd = 16.0,
	DenoiseSteps = 5,
	Enabled = true,
	Name = "SSGIEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "SSGIEffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envssgi = r3d.structs.R3D_EnvSSGI:new({
			sampleCount = instance.SampleCount,
			maxRaySteps = instance.MaxRaySteps,
			stepSize = instance.StepSize,
			thickness = instance.Thickness,
			maxDistance = instance.MaxDistance,
			fadeStart = instance.FadeStart,
			fadeEnd = instance.FadeEnd,
			denoiseSteps = instance.DenoiseSteps,
			enabled = instance.Enabled and 1 or 0,
		})
		instance:SetMetadata("EffectObject", envssgi)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envssgi = r3d.structs.R3D_EnvSSGI:new({
				sampleCount = instance.SampleCount,
				maxRaySteps = instance.MaxRaySteps,
				stepSize = instance.StepSize,
				thickness = instance.Thickness,
				maxDistance = instance.MaxDistance,
				fadeStart = instance.FadeStart,
				fadeEnd = instance.FadeEnd,
				denoiseSteps = instance.DenoiseSteps,
				enabled = instance.Enabled and 1 or 0,
			})
			instance:SetMetadata("EffectObject", envssgi)
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
