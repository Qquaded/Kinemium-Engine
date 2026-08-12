-- description: "A 3d handle that can be rotated and appears under an Adornee."
local Vector3 = require("@Vector3")
local Color3 = require("@Color3")

local propTable = {
	Color = Color3.new(0.5, 0.5, 0.5),
	Adornee = nil,
	CastShadows = false,
	Name = "Handles",
}

local function toVector(v)
	return vector.create(v.X, v.Y, v.Z)
end

local function drawArcRing(center, radius, axis, segments, color)
	segments = segments or 64
	local step = (math.pi * 2) / segments

	local prevPoint = nil

	for i = 0, segments do
		local a = i * step
		local x = math.cos(a) * radius
		local y = math.sin(a) * radius

		local point
		if axis == "X" then
			point = center + Vector3.new(0, x, y)
		elseif axis == "Y" then
			point = center + Vector3.new(x, 0, y)
		elseif axis == "Z" then
			point = center + Vector3.new(x, y, 0)
		end

		if prevPoint then
			lib.DrawLine3D(toVector(prevPoint), toVector(point), color)
		end

		prevPoint = point
	end
end

return {
	class = "ArcHandles",

	callback = function(instance, renderer)
		propTable.render = function(handles, renderer)
			if handles.Adornee then
				local part = handles.Adornee

				local pos = part.Position
				local size = part.Size
				local scale = math.max(size.X, size.Y, size.Z) * 1.2

				local radius = scale * 0.9

				drawArcRing(pos, radius, "X", 64, const.RED)
				drawArcRing(pos, radius, "Y", 64, const.GREEN)
				drawArcRing(pos, radius, "Z", 64, const.BLUE)
			end
		end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
