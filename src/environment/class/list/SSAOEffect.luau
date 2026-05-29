-- description: "Represents a SSAOEffect in the environment."
local propTable = {
	SampleCount = 16,
	Intensity = 5,
	Power = 5,
	Radius = 1,
	Bias = 0.02,
	Enabled = true,
	Name = "SSAOEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "SSAOEffect",

	-- description: "Initializes the SSAOEffect instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envssao = r3d.structs.R3D_EnvSSAO:new({
			sampleCount = instance.SampleCount,
			intensity = instance.Intensity,
			power = instance.Power,
			radius = instance.Radius,
			bias = instance.Bias,
			enabled = instance.Enabled and 1 or 0,
		})
		instance:SetMetadata("EffectObject", envssao)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envssao = r3d.structs.R3D_EnvSSAO:new({
				sampleCount = instance.SampleCount,
				intensity = instance.Intensity,
				power = instance.Power,
				radius = instance.Radius,
				bias = instance.Bias,
				enabled = instance.Enabled and 1 or 0,
			})
			instance:SetMetadata("EffectObject", envssao)
		end)

		return instance
	end,
	-- description: "Inherits the properties of the SSAOEffect class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
