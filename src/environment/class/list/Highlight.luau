-- description: "Highlights a 3d object with customizable color and transparency."
local Color3 = require("@Color3")
local adapter = require("@RaylibAdapter").lib

local propTable = {
	Adornee = nil,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	OutlineTransparency = 1,
	OutlineThickness = 1.0,
	FillColor = Color3.fromRGB(0, 174, 255),
	FillTransparency = 0.5,
}

local function drawRotatedCube(rl, cf, size, color, fill, outlineThickness)
	local p = cf.Position
	local qx, qy, qz, qw = cf:ToQuaternion()
	qw = math.clamp(qw, -1, 1)
	local angle = math.deg(2 * math.acos(qw))
	local s = math.sqrt(1 - qw * qw)
	local ax, ay, az
	if s < 0.001 then
		ax, ay, az = 1, 0, 0
	else
		ax, ay, az = qx / s, qy / s, qz / s
	end
	adapter.rlPushMatrix()
	adapter.rlTranslatef(p.X, p.Y, p.Z)
	adapter.rlRotatef(angle, ax, ay, az)
	adapter.DrawCubeV(vector.create(0, 0, 0), vector.create(size.X, size.Y, size.Z), fill)
	adapter.rlSetLineWidth(outlineThickness or 1.0)
	adapter.DrawCubeWiresV(vector.create(0, 0, 0), vector.create(size.X, size.Y, size.Z), color)
	adapter.rlSetLineWidth(1.0) -- reset after
	adapter.rlPopMatrix()
end

return {
	class = "Highlight",

	callback = function(instance, renderer, datamodel)
		renderer.Pool.new("gizmo", function()
			local adornee = instance.Adornee
			if adornee and adornee.BaseClass == "BasePart" then
				local CFrame = adornee.CFrame
				if not CFrame then
					return
				end

				local Size = adornee.Size

				drawRotatedCube(
					adapter.lib,
					CFrame,
					Size,
					instance.OutlineColor:ToRaylib(instance.OutlineTransparency),
					instance.FillColor:ToRaylib(instance.FillTransparency),
					instance.OutlineThickness
				)
			end
		end)

		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Highlight class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
