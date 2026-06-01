-- description: "Creates a Depth of Field effect in the Environment."
local propTable = {
	Mode = 1, -- R3D_DOF_ENABLED
	FocusPoint = 10.0,
	FocusScale = 1.0,
	MaxBlurSize = 20.0,
	Enabled = true,
	Name = "DOFEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "DOFEffect",

	callback = function(instance)
		local r3d = require("@r3d")

		instance:SetProperties(propTable)

		local envdof = r3d.structs.R3D_EnvDoF:new({
			mode = instance.Enabled and instance.Mode or 0,
			focusPoint = instance.FocusPoint,
			focusScale = instance.FocusScale,
			maxBlurSize = instance.MaxBlurSize,
		})
		instance:SetMetadata("EffectObject", envdof)

		instance.Changed:Connect(function(property, value)
			if property == "_r3deffect" then
				return
			end
			envdof = r3d.structs.R3D_EnvDoF:new({
				mode = instance.Enabled and instance.Mode or 0,
				focusPoint = instance.FocusPoint,
				focusScale = instance.FocusScale,
				maxBlurSize = instance.MaxBlurSize,
			})
			instance:SetMetadata("EffectObject", envdof)
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
