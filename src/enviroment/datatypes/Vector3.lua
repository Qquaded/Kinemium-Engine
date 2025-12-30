-- vector3 implementation by devcell
local Vector3 = {}
Vector3.__index = Vector3

function Vector3.new(x, y, z)
	return setmetatable({
		X = x or 0,
		Y = y or 0,
		Z = z or 0,
	}, Vector3)
end

function Vector3:Magnitude()
	local x, y, z = self.X, self.Y, self.Z
	return math.sqrt(x * x + y * y + z * z)
end

function Vector3.Slerp(a, b, t)
	local v0 = a:Unit()
	local v1 = b:Unit()

	local dot = v0:Dot(v1)
	if dot > 1 then
		dot = 1
	end
	if dot < -1 then
		dot = -1
	end

	local theta = math.acos(dot)

	if theta < 1e-5 then
		return v0:Lerp(v1, t):Unit()
	end

	local sinTheta = math.sin(theta)
	local w0 = math.sin((1 - t) * theta) / sinTheta
	local w1 = math.sin(t * theta) / sinTheta

	return (v0 * w0 + v1 * w1):Unit()
end

function Vector3:Unit()
	local mag = self:Magnitude()
	if mag == 0 then
		return Vector3.new(0, 0, 0)
	end
	return Vector3.new(self.X / mag, self.Y / mag, self.Z / mag)
end

function Vector3:Dot(v)
	return self.X * v.X + self.Y * v.Y + self.Z * v.Z
end

function Vector3:Cross(v)
	return Vector3.new(self.Y * v.Z - self.Z * v.Y, self.Z * v.X - self.X * v.Z, self.X * v.Y - self.Y * v.X)
end

function Vector3:Lerp(v, alpha)
	return Vector3.new(
		self.X + (v.X - self.X) * alpha,
		self.Y + (v.Y - self.Y) * alpha,
		self.Z + (v.Z - self.Z) * alpha
	)
end

function Vector3:__tostring()
	return string.format("Vector3(%g, %g, %g)", self.X, self.Y, self.Z)
end

function Vector3.__add(a, b)
	return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function Vector3.__sub(a, b)
	return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function Vector3.__mul(a, b)
	if type(a) == "number" then
		return Vector3.new(a * b.X, a * b.Y, a * b.Z)
	elseif type(b) == "number" then
		return Vector3.new(a.X * b, a.Y * b, a.Z * b)
	end
	error("Vector3 * Vector3 is not allowed; multiplication is scalar only")
end

function Vector3.__div(a, b)
	if type(b) ~= "number" then
		error("Vector3 division only supports scalar division")
	end
	return Vector3.new(a.X / b, a.Y / b, a.Z / b)
end

function Vector3.__unm(a)
	return Vector3.new(-a.X, -a.Y, -a.Z)
end

function Vector3:ToTable()
	return {
		type = "Vector3",
		X = self.X,
		Y = self.Y,
		Z = self.Z,
	}
end

function Vector3.FromTable(tbl)
	assert(tbl.type == "Vector3")
	return Vector3.new(tbl.X, tbl.Y, tbl.Z)
end

return Vector3
