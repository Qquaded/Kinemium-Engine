-- description: "Renders GUI Children in a 3D Environment."
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local UDim2 = require("@UDim2")

local propTable = {
	Name = "BillboardGui",
	Enabled = true,
	Camera = nil,
	Size = UDim2.new(0, 200, 0, 100),
	RenderOffset = Vector2.new(0, 0),
	Adornee = nil,
	StudsOffset = Vector3.new(0, 0, 0),
	StudsOffsetWorldSpace = Vector3.new(0, 0, 0),
	PixelsPerStud = 50,
	MaxDistance = 0,
	AlwaysOnTop = true,
	BaseClass = "UIContainer",
}

return {

	class = "BillboardGui",

	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
