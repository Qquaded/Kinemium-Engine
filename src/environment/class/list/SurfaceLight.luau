-- description: "A light that emits from a surface."
local a = require("@Vector3")
local b = require("@Color3")
local c = require("@EnumMap")

local d = require("@r3d")
local e = d.lib

local f = {
	Angle = 90,
	Face = c.NormalId.Front,
	Color = b.new(1, 1, 1),
	Brightness = 15,
	Range = 12,
	CastShadow = false,
	Enabled = true,
	Transparency = 0,
	Position = a.new(0, 0, 0),
	DebugShape = false,
	Name = "SurfaceLight",
	BaseClass = "Kinemium.light",
}

return {
	class = "SurfaceLight",

	callback = function(g, h, i)
		g:SetProperties(f)

		if _G.IsHeadless or not h then
			return g
		end

		local j = e.R3D_CreateLight(1)
		e.R3D_SetLightPosition(j, vector.create(g.Position.X, g.Position.Y, g.Position.Z))
		e.R3D_SetLightColor(j, g.Color:ToRaylib(g.Transparency))
		e.R3D_SetLightEnergy(j, g.Brightness)
		e.R3D_SetLightOuterCutOff(j, g.Angle)
		e.R3D_SetLightRange(j, g.Range)
		e.R3D_SetLightActive(j, false)
		g:SetMetadata("LightObject", j)

		if g.CastShadow == true then
			e.R3D_EnableShadow(j)
		end

		g.Destroying:Connect(function()
			e.R3D_DestroyLight(j)
		end)

		g.Changed:Connect(function()
			if g.Enabled == true then
				e.R3D_SetLightActive(j, true)
			end

			if g.CastShadow == true then
				e.R3D_EnableShadow(j)
			else
				e.R3D_DisableShadow(j)
			end

			e.R3D_SetLightPosition(j, vector.create(g.Position.X, g.Position.Y, g.Position.Z))
			e.R3D_SetLightColor(j, g.Color:ToRaylib(g.Transparency))
			e.R3D_SetLightEnergy(j, g.Brightness)
			e.R3D_SetLightOuterCutOff(j, g.Angle)
			e.R3D_SetLightRange(j, g.Range)
		end)

		h.Pool.new("gizmo", function()
			if g.DebugShape == true then
				e.R3D_DrawLightShape(j)
			end
		end)

		h.Hook.new("Renderstep", function()
			if g.Parent and g.Parent.CFrame then
				local newPos = g.Parent.CFrame.Position
				local dx, dy, dz = newPos.X - g.Position.X, newPos.Y - g.Position.Y, newPos.Z - g.Position.Z
				if dx * dx + dy * dy + dz * dz > 0.0001 then
					g.Position = newPos
				end
				local k = g.Parent.CFrame:GetLookVector()
				if g.Face == c.NormalId.Top then
					k = g.Parent.CFrame:GetUpVector()
				elseif g.Face == c.NormalId.Bottom then
					k = -g.Parent.CFrame:GetUpVector()
				elseif g.Face == c.NormalId.Right then
					k = g.Parent.CFrame:GetRightVector()
				elseif g.Face == c.NormalId.Left then
					k = -g.Parent.CFrame:GetRightVector()
				elseif g.Face == c.NormalId.Back then
					k = -g.Parent.CFrame:GetLookVector()
				end
				e.R3D_SetLightDirection(j, vector.create(k.X, k.Y, k.Z))
			end
		end)

		return g
	end,

	inherit = function(g)
		for h, i in pairs(f) do
			g[h] = i
		end
	end,
}
