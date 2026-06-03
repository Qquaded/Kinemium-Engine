-- vector3 implementation by devcell
local Vector3 = { __type = "Vector3" }
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

function Vector3:ToZuneVector()
	return vector.create(self.X, self.Y, self.Z)
end

function Vector3:ToBuffer()
	local buf = buffer.create(12)
	buffer.writef32(buf, 0, self.X)
	buffer.writef32(buf, 4, self.Y)
	buffer.writef32(buf, 8, self.Z)
	return buf
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
	assert(a.X and a.Y and a.Z, "Left operand is not a Vector3")
	assert(b.X and b.Y and b.Z, "Right operand is not a Vector3")
	return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function Vector3.__mul(a, b)
	if type(a) == "number" then
		return Vector3.new(a * b.X, a * b.Y, a * b.Z)
	elseif type(b) == "number" then
		return Vector3.new(a.X * b, a.Y * b, a.Z * b)
	elseif type(a) == "table" and type(b) == "table" and a.__type == "Vector3" and b.__type == "Vector3" then
		return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
	end
	error("Vector3 multiplication requires a scalar or another Vector3")
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

function Vector3:MagnitudeSquared()
	return self.X * self.X + self.Y * self.Y + self.Z * self.Z
end

function Vector3:Distance(v)
	return (self - v):Magnitude()
end

function Vector3:DistanceSquared(v)
	return (self - v):MagnitudeSquared()
end

function Vector3:ClampMagnitude(maxLength)
	local mag = self:Magnitude()
	if mag > maxLength then
		return self:Unit() * maxLength
	end
	return self
end

function Vector3:RotateByMatrix(matrix)
	local x = self.X * matrix[1][1] + self.Y * matrix[1][2] + self.Z * matrix[1][3]
	local y = self.X * matrix[2][1] + self.Y * matrix[2][2] + self.Z * matrix[2][3]
	local z = self.X * matrix[3][1] + self.Y * matrix[3][2] + self.Z * matrix[3][3]
	return Vector3.new(x, y, z)
end

function Vector3.RotationMatrix(axis, angle)
	axis = axis:Unit()
	local c = math.cos(angle)
	local s = math.sin(angle)
	local t = 1 - c
	local x, y, z = axis.X, axis.Y, axis.Z
	return {
		{ t * x * x + c, t * x * y - s * z, t * x * z + s * y },
		{ t * x * y + s * z, t * y * y + c, t * y * z - s * x },
		{ t * x * z - s * y, t * y * z + s * x, t * z * z + c },
	}
end

function Vector3:DirectionToLength(target, length)
	return (target - self):Unit() * length
end

function Vector3:LookAt(target, up)
	up = up or Vector3.new(0, 1, 0)
	local forward = (target - self):Unit()
	local right = up:Cross(forward):Unit()
	local realUp = forward:Cross(right)
	return {
		right = right,
		up = realUp,
		forward = forward,
	}
end

function Vector3:RotateEuler(pitch, yaw, roll)
	local cp, sp = math.cos(pitch), math.sin(pitch)
	local cy, sy = math.cos(yaw), math.sin(yaw)
	local cr, sr = math.cos(roll), math.sin(roll)

	local m = {
		{ cy * cr + sy * sp * sr, sr * cp, -sy * cr + cy * sp * sr },
		{ -cy * sr + sy * sp * cr, cr * cp, sr * sy + cy * sp * cr },
		{ sy * cp, -sp, cy * cp },
	}

	return self:RotateByMatrix(m)
end

function Vector3:IsZero(epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(self.X) < epsilon and math.abs(self.Y) < epsilon and math.abs(self.Z) < epsilon
end

function Vector3:RotateAroundAxis(axis, angle)
	axis = axis:Unit()
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local dot = self:Dot(axis)

	local term1 = self * cosA
	local term2 = axis:Cross(self) * sinA
	local term3 = axis * dot * (1 - cosA)

	return term1 + term2 + term3
end

function Vector3:RotateTowards(target, maxAngle)
	local current = self:Unit()
	local targetUnit = target:Unit()
	local angle = current:Angle(targetUnit)
	if angle <= maxAngle then
		return targetUnit * self:Magnitude()
	end
	local axis = current:Cross(targetUnit)
	if axis:Magnitude() < 1e-5 then
		axis = Vector3.RandomUnit():Cross(current)
	end
	return self:RotateAroundAxis(axis, maxAngle)
end

function Vector3:ToEulerAngles()
	local pitch = math.atan2(self.Y, math.sqrt(self.X * self.X + self.Z * self.Z))
	local yaw = math.atan2(-self.X, -self.Z)
	local roll = 0
	return pitch, yaw, roll
end

function Vector3:Project(onto)
	local ontoUnit = onto:Unit()
	return ontoUnit * self:Dot(ontoUnit)
end

function Vector3:Angle(v)
	local dot = self:Unit():Dot(v:Unit())
	return math.acos(math.clamp(dot, -1, 1))
end

function Vector3:Reflect(normal)
	return self - normal * 2 * self:Dot(normal)
end

function Vector3:Round()
	return Vector3.new(math.round(self.X), math.round(self.Y), math.round(self.Z))
end

function Vector3:Abs()
	return Vector3.new(math.abs(self.X), math.abs(self.Y), math.abs(self.Z))
end

function Vector3:Min(v)
	return Vector3.new(math.min(self.X, v.X), math.min(self.Y, v.Y), math.min(self.Z, v.Z))
end

function Vector3:Max(v)
	return Vector3.new(math.max(self.X, v.X), math.max(self.Y, v.Y), math.max(self.Z, v.Z))
end

function Vector3:Equals(v, epsilon)
	epsilon = epsilon or 1e-5
	return math.abs(self.X - v.X) < epsilon and math.abs(self.Y - v.Y) < epsilon and math.abs(self.Z - v.Z) < epsilon
end

function Vector3.RandomUnit()
	local theta = math.random() * 2 * math.pi
	local phi = math.acos(2 * math.random() - 1)
	local x = math.sin(phi) * math.cos(theta)
	local y = math.sin(phi) * math.sin(theta)
	local z = math.cos(phi)
	return Vector3.new(x, y, z)
end

function Vector3:DirectionTo(v)
	return (v - self):Unit()
end

function Vector3:ToTable()
	return {
		type = "Vector3",

		__type = "Vector3",
		X = self.X,
		Y = self.Y,
		Z = self.Z,
	}
end

function Vector3.FromTable(tbl)
	assert(tbl.type == "Vector3" or tbl.__type == "Vector3")
	return Vector3.new(tbl.X, tbl.Y, tbl.Z)
end

Vector3.zero = Vector3.new(0, 0, 0)
Vector3.one = Vector3.new(1, 1, 1)

return Vector3
