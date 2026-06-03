local Vector2int16 = {}
Vector2int16.__index = Vector2int16

local Vector2 = require("@Vector2")
local MIN_INT16 = -32768
local MAX_INT16 = 32767

local function clampInt16(value)
	value = math.floor(value)
	if value < MIN_INT16 then
		value = MIN_INT16 + (value - MIN_INT16) % 65536
	elseif value > MAX_INT16 then
		value = MIN_INT16 + (value - MIN_INT16) % 65536
	end
	return value
end

-- Constructor
function Vector2int16.new(x, y)
	return setmetatable({
		X = clampInt16(x or 0),
		Y = clampInt16(y or 0),
	}, Vector2int16)
end

Vector2int16.x = Vector2int16.X
Vector2int16.y = Vector2int16.Y

function Vector2int16.__add(a, b)
	return Vector2int16.new(a.X + b.X, a.Y + b.Y)
end

function Vector2int16.__sub(a, b)
	return Vector2int16.new(a.X - b.X, a.Y - b.Y)
end

function Vector2int16.__mul(a, b)
	if type(a) == "number" then
		return Vector2int16.new(a * b.X, a * b.Y)
	elseif type(b) == "number" then
		return Vector2int16.new(a.X * b, a.Y * b)
	else
		return Vector2int16.new(a.X * b.X, a.Y * b.Y)
	end
end

function Vector2int16.__div(a, b)
	if type(b) == "number" then
		return Vector2int16.new(a.X / b, a.Y / b)
	else
		return Vector2int16.new(math.floor(a.X / b.X), math.floor(a.Y / b.Y))
	end
end

function Vector2int16:__tostring()
	return string.format("Vector2int16(%d, %d)", self.X, self.Y)
end

function Vector2int16:ToVector2()
	return Vector2.new(self.X, self.Y)
end

function Vector2int16:ToTable()
	return {
		type = "Vector2int16",
		X = self.X,
		Y = self.Y,
	}
end

function Vector2int16.FromTable(tbl)
	assert(tbl.type == "Vector2int16", "Table is not a Vector2int16")
	return Vector2int16.new(tbl.X, tbl.Y)
end

return Vector2int16
