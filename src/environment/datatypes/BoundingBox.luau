local BoundingBox = {}
BoundingBox.__index = BoundingBox

local Vector3 = require("@Vector3")

function BoundingBox.new(min, max)
	assert(min and max, "BoundingBox requires min and max Vector3")
	return setmetatable({
		Min = min,
		Max = max,
	}, BoundingBox)
end

function BoundingBox.empty()
	local inf = math.huge
	return BoundingBox.new(Vector3.new(inf, inf, inf), Vector3.new(-inf, -inf, -inf))
end

function BoundingBox:Encapsulate(point)
	self.Min = Vector3.new(math.min(self.Min.X, point.X), math.min(self.Min.Y, point.Y), math.min(self.Min.Z, point.Z))
	self.Max = Vector3.new(math.max(self.Max.X, point.X), math.max(self.Max.Y, point.Y), math.max(self.Max.Z, point.Z))
end

function BoundingBox:Contains(point)
	return point.X >= self.Min.X
		and point.X <= self.Max.X
		and point.Y >= self.Min.Y
		and point.Y <= self.Max.Y
		and point.Z >= self.Min.Z
		and point.Z <= self.Max.Z
end

function BoundingBox:Intersects(other)
	return self.Min.X <= other.Max.X
		and self.Max.X >= other.Min.X
		and self.Min.Y <= other.Max.Y
		and self.Max.Y >= other.Min.Y
		and self.Min.Z <= other.Max.Z
		and self.Max.Z >= other.Min.Z
end

function BoundingBox:Center()
	return (self.Min + self.Max) / 2
end

function BoundingBox:Size()
	return self.Max - self.Min
end

function BoundingBox:Lerp(other, alpha)
	return BoundingBox.new(self.Min + (other.Min - self.Min) * alpha, self.Max + (other.Max - self.Max) * alpha)
end

function BoundingBox:__tostring()
	return string.format("BoundingBox(Min=%s, Max=%s)", tostring(self.Min), tostring(self.Max))
end

function BoundingBox:ToTable()
	return {
		type = "BoundingBox",
		Min = self.Min:ToTable(),
		Max = self.Max:ToTable(),
	}
end

function BoundingBox.FromTable(tbl)
	assert(tbl.type == "BoundingBox")
	return BoundingBox.new(Vector3.FromTable(tbl.Min), Vector3.FromTable(tbl.Max))
end

return BoundingBox
