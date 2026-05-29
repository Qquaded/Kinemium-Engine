-- description: "Represents an ArcHandles in the environment."
local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")
local lib, const, structs = raylib.lib, raylib.const, raylib.structs

local propTable = {
	Color = Color3.new(0.5, 0.5, 0.5),
	Adornee = nil,
	CastShadows = false,
	Name = "Handles",
}

-- description: "Tos vector."
-- args: "v: Vector3"
local function toVector(v)
	return vector.create(v.X, v.Y, v.Z)
end

-- description: "Draws the visual representation."
-- args: "center: number, radius: number, axis: Vector3, segments: number, color: number"
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

	-- description: "Initializes the ArcHandles instance."
	-- args: "instance: table, renderer: number"
	-- returns: "table"
	callback = function(instance, renderer)
		-- description: "Renders the component."
		-- args: "handles: table, renderer: number"
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

	-- description: "Inherits the properties of the ArcHandles class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
