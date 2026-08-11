local Vector2 = { __type = "Vector2" }
Vector2.__index = function(self, key)
	if key == "Magnitude" or key == "magnitude" then
		return math.sqrt(self.X * self.X + self.Y * self.Y)
	elseif key == "Unit" or key == "unit" then
		local mag = math.sqrt(self.X * self.X + self.Y * self.Y)
		if mag == 0 then
			return Vector2.new(0, 0)
		end
		return self / mag
	end

	return Vector2[key]
end

function Vector2.new(x, y)
	return setmetatable({
		X = x or 0,
		Y = y or 0,
	}, Vector2)
end

function Vector2.__add(a, b)
	return Vector2.new(a.X + b.X, a.Y + b.Y)
end

function Vector2.__sub(a, b)
	return Vector2.new(a.X - b.X, a.Y - b.Y)
end

function Vector2.__mul(a, b)
	if type(a) == "number" then
		return Vector2.new(a * b.X, a * b.Y)
	elseif type(b) == "number" then
		return Vector2.new(a.X * b, a.Y * b)
	elseif (type(a) == "table" and a.__type == "Vector2") and (type(b) == "table" and b.__type == "Vector2") then
		return Vector2.new(a.X * b.X, a.Y * b.Y)
	else
		error("Vector2 can only multiply by a number or another Vector2")
	end
end

function Vector2.__div(a, b)
	if type(b) == "number" then
		return Vector2.new(a.X / b, a.Y / b)
	else
		error("Vector2 can only divide by a number")
	end
end

function Vector2.__tostring(v)
	return string.format("Vector2(%f, %f)", v.X, v.Y)
end

function Vector2:Clone()
	return Vector2.new(self.X, self.Y)
end

function Vector2:Dot(other)
	return self.X * other.X + self.Y * other.Y
end

function Vector2:Distance(other)
	return (self - other).Magnitude
end

function Vector2:Lerp(target, alpha)
	return self + (target - self) * alpha
end

Vector2.Zero = Vector2.new(0, 0)
Vector2.One = Vector2.new(1, 1)

function Vector2:ToTable()
	return {
		type = "Vector2",
		X = self.X,
		Y = self.Y,
	}
end

function Vector2.FromTable(tbl)
	assert(tbl.type == "Vector2")
	return Vector2.new(tbl.X, tbl.Y)
end

return Vector2
