local Color3 = require("@Color3")

local ColorSequenceKeypoint = {}
ColorSequenceKeypoint.__index = ColorSequenceKeypoint

function ColorSequenceKeypoint.new(position, color)
	assert(type(position) == "number" and position >= 0 and position <= 1, "Position must be between 0 and 1")
	assert(getmetatable(color) == Color3, "Color must be a Color3 instance")

	return setmetatable({
		Position = position,
		Color = color,
	}, ColorSequenceKeypoint)
end

function ColorSequenceKeypoint:Lerp(other, alpha)
	assert(getmetatable(other) == ColorSequenceKeypoint, "Other must be a ColorSequenceKeypoint")
	local r = self.Color.R + (other.Color.R - self.Color.R) * alpha
	local g = self.Color.G + (other.Color.G - self.Color.G) * alpha
	local b = self.Color.B + (other.Color.B - self.Color.B) * alpha
	local color = Color3.new(r, g, b)
	local pos = self.Position + (other.Position - self.Position) * alpha
	return ColorSequenceKeypoint.new(pos, color)
end

function ColorSequenceKeypoint:__tostring()
	return string.format(
		"ColorSequenceKeypoint.new(%g, Color3.new(%g,%g,%g))",
		self.Position,
		self.Color.R,
		self.Color.G,
		self.Color.B
	)
end

function ColorSequenceKeypoint:ToTable()
	return {
		type = "ColorSequenceKeypoint",
		Position = self.Position,
		Color = self.Color:ToTable(),
	}
end

function ColorSequenceKeypoint.FromTable(tbl)
	assert(tbl.type == "ColorSequenceKeypoint")
	return ColorSequenceKeypoint.new(tbl.Position, Color3.FromTable(tbl.Color))
end

return ColorSequenceKeypoint
