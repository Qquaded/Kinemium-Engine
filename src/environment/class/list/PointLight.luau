-- description: "Represents a PointLight in the environment."
local Vector3 = require("@Vector3")
local Color3 = require("@Color3")

local r3d = require("@r3d")
local rlib = r3d.lib

local propTable = {
	Color = Color3.new(1, 1, 1),
	Brightness = 15, -- intensity of the light
	Range = 12, -- how far the light reaches
	CastShadow = false, -- casts shadows or not
	Enabled = true, -- whether the light is active
	Transparency = 0,
	Position = Vector3.new(0, 0, 0),
	DebugShape = false,
	Name = "PointLight",
	BaseClass = "Kinemium.light",
}

return {
	class = "PointLight",
	-- description: "Initializes the PointLight instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		local light = rlib.R3D_CreateLight(2) -- R3D_LIGHT_OMNI
		rlib.R3D_SetLightPosition(light, vector.create(instance.Position.X, instance.Position.Y, instance.Position.Z))
		rlib.R3D_SetLightColor(light, instance.Color:ToRaylib(instance.Transparency))
		rlib.R3D_SetLightEnergy(light, instance.Brightness)
		rlib.R3D_SetLightRange(light, instance.Range)
		rlib.R3D_SetLightActive(light, false)
		instance:SetMetadata("LightObject", light)

		if instance.CastShadow == true then
			rlib.R3D_EnableShadow(light)
		end

		instance.Destroying:Connect(function()
			rlib.R3D_DestroyLight(light)
		end)

		instance.Changed:Connect(function()
			if instance.Enabled == true then
				rlib.R3D_SetLightActive(light, true)
			end

			if instance.CastShadow == true then
				rlib.R3D_EnableShadow(light)
			else
				rlib.R3D_DisableShadow(light)
			end

			rlib.R3D_SetLightPosition(
				light,
				vector.create(instance.Position.X, instance.Position.Y, instance.Position.Z)
			)
			rlib.R3D_SetLightColor(light, instance.Color:ToRaylib(instance.Transparency))
			rlib.R3D_SetLightEnergy(light, instance.Brightness)
			rlib.R3D_SetLightRange(light, instance.Range)
		end)

		renderer.Pool.new("gizmo", function()
			if instance.DebugShape == true then
				rlib.R3D_DrawLightShape(light)
			end
		end)

		renderer.Hook.new("Renderstep", function()
			if instance.Parent and instance.Parent.CFrame then
				local newPos = instance.Parent.CFrame.Position
				local dx, dy, dz =
					newPos.X - instance.Position.X, newPos.Y - instance.Position.Y, newPos.Z - instance.Position.Z
				if dx * dx + dy * dy + dz * dz > 0.0001 then
					instance.Position = newPos
				end
			end
		end)

		return instance
	end,
	-- description: "Inherits the properties of the PointLight class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
