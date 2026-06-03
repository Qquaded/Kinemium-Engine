local Vector3 = require("@Vector3")

local Ray = {}
Ray.__index = Ray

function Ray.new(origin, direction)
	assert(getmetatable(origin) == Vector3, "Origin must be a Vector3")
	assert(getmetatable(direction) == Vector3, "Direction must be a Vector3")

	local self = setmetatable({}, Ray)
	self.Origin = origin
	self.Direction = direction
	return self
end

function Ray:Unit()
	return self.Direction:Unit()
end

function Ray:PointAt(t)
	return self.Origin + (self.Direction * t)
end

function Ray:DistanceToPoint(point)
	local ap = point - self.Origin
	local t = ap:Dot(self:Unit())
	local closest = self:PointAt(t)
	return (point - closest):Magnitude()
end

function Ray:ToTable()
	return {
		type = "Ray",
		Origin = self.Origin:ToTable(),
		Direction = self.Direction:ToTable(),
	}
end

function Ray.FromTable(tbl)
	assert(tbl.type == "Ray")
	return Ray.new(Vector3.FromTable(tbl.Origin), Vector3.FromTable(tbl.Direction))
end

return Ray
