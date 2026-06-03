-- description: "Highlights a 3d object with customizable color and transparency."
local Color3 = require("@Color3")
local raylib = require("@raylib")

local propTable = {
	Adornee = nil,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	OutlineTransparency = 1,
	FillColor = Color3.fromRGB(0, 174, 255),
	FillTransparency = 0.5,
}

return {
	class = "Highlight",

	callback = function(instance, renderer, datamodel)
		renderer.Pool.new("gizmo", function()
			local adornee = instance.Adornee
			if adornee and adornee.BaseClass == "BasePart" then
				local CFrame = adornee.CFrame
				local Pos = CFrame.Position
				local Size = adornee.Size
				raylib.lib.DrawCubeV(
					vector.create(Pos.X, Pos.Y, Pos.Z),
					vector.create(Size.X, Size.Y, Size.Z),
					instance.FillColor:ToRaylib(instance.FillTransparency)
				)
				raylib.lib.DrawCubeWiresV(
					vector.create(Pos.X, Pos.Y, Pos.Z),
					vector.create(Size.X, Size.Y, Size.Z),
					instance.OutlineColor:ToRaylib(instance.OutlineTransparency)
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
