-- description: "A rendering technique that simulates reflections using screen-space ray marching."
local propTable = {
	MaxRaySteps = 64,
	BinarySteps = 5,
	StepSize = 0.125,
	Thickness = 1.0,
	MaxDistance = 100.0,
	EdgeFade = 0.1,
	Enabled = true,
	Name = "SSREffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "SSREffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envssr = r3d.structs.R3D_EnvSSR:new({
			maxRaySteps = instance.MaxRaySteps,
			binarySteps = instance.BinarySteps,
			stepSize = instance.StepSize,
			thickness = instance.Thickness,
			maxDistance = instance.MaxDistance,
			edgeFade = instance.EdgeFade,
			enabled = instance.Enabled and 1 or 0,
		})
		instance:SetMetadata("EffectObject", envssr)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envssr = r3d.structs.R3D_EnvSSR:new({
				maxRaySteps = instance.MaxRaySteps,
				binarySteps = instance.BinarySteps,
				stepSize = instance.StepSize,
				thickness = instance.Thickness,
				maxDistance = instance.MaxDistance,
				edgeFade = instance.EdgeFade,
				enabled = instance.Enabled and 1 or 0,
			})
			instance:SetMetadata("EffectObject", envssr)
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
