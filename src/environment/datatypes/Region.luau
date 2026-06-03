local Region3 = {}
Region3.__index = Region3

local Vector3 = require("@Vector3")

function Region3.new(min, max)
	assert(min and max)
	local minPoint = Vector3.new(math.min(min.X, max.X), math.min(min.Y, max.Y), math.min(min.Z, max.Z))
	local maxPoint = Vector3.new(math.max(min.X, max.X), math.max(min.Y, max.Y), math.max(min.Z, max.Z))
	return setmetatable({ Min = minPoint, Max = maxPoint }, Region3)
end

function Region3:ExpandToGrid(gridSize)
	gridSize = gridSize or 4
	local min = Vector3.new(
		math.floor(self.Min.X / gridSize) * gridSize,
		math.floor(self.Min.Y / gridSize) * gridSize,
		math.floor(self.Min.Z / gridSize) * gridSize
	)
	local max = Vector3.new(
		math.ceil(self.Max.X / gridSize) * gridSize,
		math.ceil(self.Max.Y / gridSize) * gridSize,
		math.ceil(self.Max.Z / gridSize) * gridSize
	)
	return Region3.new(min, max)
end

function Region3:Contains(point)
	return point.X >= self.Min.X
		and point.X <= self.Max.X
		and point.Y >= self.Min.Y
		and point.Y <= self.Max.Y
		and point.Z >= self.Min.Z
		and point.Z <= self.Max.Z
end

function Region3:Union(other)
	local min = Vector3.new(
		math.min(self.Min.X, other.Min.X),
		math.min(self.Min.Y, other.Min.Y),
		math.min(self.Min.Z, other.Min.Z)
	)
	local max = Vector3.new(
		math.max(self.Max.X, other.Max.X),
		math.max(self.Max.Y, other.Max.Y),
		math.max(self.Max.Z, other.Max.Z)
	)
	return Region3.new(min, max)
end

function Region3:ToRegion3()
	return Region3.new(self.Min, self.Max)
end

function Region3:ToTable()
	return {
		type = "Region3",
		Min = self.Min:ToTable(),
		Max = self.Max:ToTable(),
	}
end

function Region3.FromTable(tbl)
	assert(tbl.type == "Region3")
	return Region3.new(Vector3.FromTable(tbl.Min), Vector3.FromTable(tbl.Max))
end

return Region3
