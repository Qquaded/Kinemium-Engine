local Vector2 = require("@Vector2")

local UDim2 = { __type = "UDim2" }
UDim2.__index = UDim2

function UDim2.new(xScale, xOffset, yScale, yOffset)
	return setmetatable({
		X = { Scale = xScale or 0, Offset = xOffset or 0 },
		Y = { Scale = yScale or 0, Offset = yOffset or 0 },
	}, UDim2)
end

function UDim2:Lerp(other, alpha)
	return UDim2.new(
		self.X.Scale + (other.X.Scale - self.X.Scale) * alpha,
		self.X.Offset + (other.X.Offset - self.X.Offset) * alpha,
		self.Y.Scale + (other.Y.Scale - self.Y.Scale) * alpha,
		self.Y.Offset + (other.Y.Offset - self.Y.Offset) * alpha
	)
end

function UDim2.fromScale(x, y)
	return UDim2.new(x, 0, y, 0)
end

function UDim2.fromOffset(x, y)
	return UDim2.new(0, x, 0, y)
end

function UDim2:Round()
	self.X.Scale = math.floor(self.X.Scale + 0.5)
	self.Y.Scale = math.floor(self.Y.Scale + 0.5)
	self.X.Offset = math.floor(self.X.Offset + 0.5)
	self.Y.Offset = math.floor(self.Y.Offset + 0.5)
	return self
end

function UDim2:Floor()
	self.X.Offset = math.floor(self.X.Offset)
	self.Y.Offset = math.floor(self.Y.Offset)
	return self
end

function UDim2:ApplyAnchor(anchor, parentSize, absoluteSize)
	local px = parentSize.X * self.X.Scale + self.X.Offset
	local py = parentSize.Y * self.Y.Scale + self.Y.Offset

	return UDim2.fromOffset(px - absoluteSize.X * anchor.X, py - absoluteSize.Y * anchor.Y)
end

function UDim2:Min(other)
	return UDim2.new(
		math.min(self.X.Scale, other.X.Scale),
		math.min(self.X.Offset, other.X.Offset),
		math.min(self.Y.Scale, other.Y.Scale),
		math.min(self.Y.Offset, other.Y.Offset)
	)
end

function UDim2:Max(other)
	return UDim2.new(
		math.max(self.X.Scale, other.X.Scale),
		math.max(self.X.Offset, other.X.Offset),
		math.max(self.Y.Scale, other.Y.Scale),
		math.max(self.Y.Offset, other.Y.Offset)
	)
end

function UDim2:Expand(pixels)
	return UDim2.new(self.X.Scale, self.X.Offset - pixels, self.Y.Scale, self.Y.Offset - pixels)
end

function UDim2:Shrink(pixels)
	return UDim2.new(self.X.Scale, self.X.Offset + pixels, self.Y.Scale, self.Y.Offset + pixels)
end

function UDim2:MoveX(px)
	self.X.Offset += px
	return self
end

function UDim2:MoveY(px)
	self.Y.Offset += px
	return self
end

function UDim2:IsZero()
	return self.X.Scale == 0 and self.X.Offset == 0 and self.Y.Scale == 0 and self.Y.Offset == 0
end

function UDim2:MagnitudePixels()
	return math.sqrt(self.X.Offset ^ 2 + self.Y.Offset ^ 2)
end

function UDim2:ToPixels(referenceSize)
	return Vector2.new(self.X.Scale * referenceSize.X + self.X.Offset, self.Y.Scale * referenceSize.Y + self.Y.Offset)
end

function UDim2.FromPixels(pixels, referenceSize)
	return UDim2.new(pixels.X / referenceSize.X, 0, pixels.Y / referenceSize.Y, 0)
end

function UDim2:__tostring()
	return string.format("UDim2.new(%g, %g, %g, %g)", self.X.Scale, self.X.Offset, self.Y.Scale, self.Y.Offset)
end

function UDim2.__eq(a, b)
	return a.X.Scale == b.X.Scale and a.X.Offset == b.X.Offset and a.Y.Scale == b.Y.Scale and a.Y.Offset == b.Y.Offset
end

function UDim2.__add(a, b)
	return UDim2.new(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset)
end

function UDim2.__sub(a, b)
	return UDim2.new(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset)
end

function UDim2.__mul(a, b)
	if type(a) == "number" then
		return UDim2.new(b.X.Scale * a, b.X.Offset * a, b.Y.Scale * a, b.Y.Offset * a)
	elseif type(b) == "number" then
		return UDim2.new(a.X.Scale * b, a.X.Offset * b, a.Y.Scale * b, a.Y.Offset * b)
	else
		error("UDim2 multiplication only supports a number")
	end
end

function UDim2.__div(a, b)
	if type(b) ~= "number" then
		error("UDim2 division only supports a number")
	end
	return UDim2.new(a.X.Scale / b, a.X.Offset / b, a.Y.Scale / b, a.Y.Offset / b)
end

function UDim2:SetPixels(xPixels, yPixels)
	self.X.Offset = xPixels
	self.Y.Offset = yPixels
	self.X.Scale = 0
	self.Y.Scale = 0
	return self
end

function UDim2:MovePixels(vec)
	self.X.Offset = self.X.Offset + vec.X
	self.Y.Offset = self.Y.Offset + vec.Y
	return self
end

function UDim2:PixelDistanceTo(other)
	local dx = self.X.Offset - other.X.Offset
	local dy = self.Y.Offset - other.Y.Offset
	return Vector2.new(dx, dy)
end

function UDim2:LerpPixels(other, alpha)
	return UDim2.new(
		0,
		self.X.Offset + (other.X.Offset - self.X.Offset) * alpha,
		0,
		self.Y.Offset + (other.Y.Offset - self.Y.Offset) * alpha
	)
end

function UDim2:SnapToGrid(gridSizeX, gridSizeY)
	self.X.Offset = math.floor(self.X.Offset / gridSizeX + 0.5) * gridSizeX
	self.Y.Offset = math.floor(self.Y.Offset / gridSizeY + 0.5) * gridSizeY
	return self
end

function UDim2:ToPixelVector()
	return Vector2.new(self.X.Offset, self.Y.Offset)
end

function UDim2:ToTable()
	return {
		type = "UDim2",
		X = {
			Scale = self.X.Scale,
			Offset = self.X.Offset,
		},
		Y = {
			Scale = self.Y.Scale,
			Offset = self.Y.Offset,
		},
	}
end

function UDim2:ScaleOnly()
	return UDim2.new(self.X.Scale, 0, self.Y.Scale, 0)
end

function UDim2:OffsetOnly()
	return UDim2.new(0, self.X.Offset, 0, self.Y.Offset)
end

function UDim2:Invert()
	return UDim2.new(-self.X.Scale, -self.X.Offset, -self.Y.Scale, -self.Y.Offset)
end

function UDim2:AddOffset(vec)
	return UDim2.new(self.X.Scale, self.X.Offset + vec.X, self.Y.Scale, self.Y.Offset + vec.Y)
end

function UDim2:SubtractOffset(vec)
	return UDim2.new(self.X.Scale, self.X.Offset - vec.X, self.Y.Scale, self.Y.Offset - vec.Y)
end

function UDim2:MultiplyScale(factor)
	return UDim2.new(self.X.Scale * factor, self.X.Offset, self.Y.Scale * factor, self.Y.Offset)
end

function UDim2:DivideScale(factor)
	return UDim2.new(self.X.Scale / factor, self.X.Offset, self.Y.Scale / factor, self.Y.Offset)
end

function UDim2:ClampOffset(minX, maxX, minY, maxY)
	return UDim2.new(
		self.X.Scale,
		math.max(minX, math.min(maxX, self.X.Offset)),
		self.Y.Scale,
		math.max(minY, math.min(maxY, self.Y.Offset))
	)
end

function UDim2.FromTable(tbl)
	assert(tbl.type == "UDim2")
	return UDim2.new(tbl.X.Scale, tbl.X.Offset, tbl.Y.Scale, tbl.Y.Offset)
end

return UDim2
