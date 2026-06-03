local Axes = {}
Axes.__index = Axes

function Axes.new(x, y, z, top, bottom, left, right, front, back)
	return setmetatable({
		X = x or false,
		Y = y or false,
		Z = z or false,
		Top = top or false,
		Bottom = bottom or false,
		Left = left or false,
		Right = right or false,
		Front = front or false,
		Back = back or false,
	}, Axes)
end

function Axes:ToTable()
	return {
		type = "Axes",
		X = self.X,
		Y = self.Y,
		Z = self.Z,
		Top = self.Top,
		Bottom = self.Bottom,
		Left = self.Left,
		Right = self.Right,
		Front = self.Front,
		Back = self.Back,
	}
end

function Axes.FromTable(tbl)
	assert(tbl.type == "Axes")
	return Axes.new(tbl.X, tbl.Y, tbl.Z, tbl.Top, tbl.Bottom, tbl.Left, tbl.Right, tbl.Front, tbl.Back)
end

return Axes
