local Quaternion = {}
Quaternion.__index = Quaternion

-- constructor
function Quaternion.new(x, y, z, w)
	return setmetatable({
		X = x or 0,
		Y = y or 0,
		Z = z or 0,
		W = w or 1,
	}, Quaternion)
end

function Quaternion.identity()
	return Quaternion.new(0, 0, 0, 1)
end

-- magnitude
function Quaternion:Magnitude()
	return math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z + self.W * self.W)
end

function Quaternion:Normalize()
	local mag = self:Magnitude()
	if mag == 0 then
		return Quaternion.identity()
	end
	return Quaternion.new(self.X / mag, self.Y / mag, self.Z / mag, self.W / mag)
end

-- axis angle
function Quaternion.fromAxisAngle(axis, angle)
	local half = angle * 0.5
	local s = math.sin(half)
	return Quaternion.new(axis.X * s, axis.Y * s, axis.Z * s, math.cos(half))
end

-- Euler XYZ (radians)
function Quaternion.fromEuler(x, y, z)
	local cx = math.cos(x * 0.5)
	local sx = math.sin(x * 0.5)
	local cy = math.cos(y * 0.5)
	local sy = math.sin(y * 0.5)
	local cz = math.cos(z * 0.5)
	local sz = math.sin(z * 0.5)

	return Quaternion.new(
		sx * cy * cz - cx * sy * sz,
		cx * sy * cz + sx * cy * sz,
		cx * cy * sz - sx * sy * cz,
		cx * cy * cz + sx * sy * sz
	)
end

-- multiplication (rotation combine)
function Quaternion.__mul(a, b)
	return Quaternion.new(
		a.W * b.X + a.X * b.W + a.Y * b.Z - a.Z * b.Y,
		a.W * b.Y - a.X * b.Z + a.Y * b.W + a.Z * b.X,
		a.W * b.Z + a.X * b.Y - a.Y * b.X + a.Z * b.W,
		a.W * b.W - a.X * b.X - a.Y * b.Y - a.Z * b.Z
	)
end

function Quaternion:Conjugate()
	return Quaternion.new(-self.X, -self.Y, -self.Z, self.W)
end

function Quaternion:Inverse()
	local magSq = self.X * self.X + self.Y * self.Y + self.Z * self.Z + self.W * self.W
	if magSq == 0 then
		return Quaternion.identity()
	end
	local conj = self:Conjugate()
	return Quaternion.new(conj.X / magSq, conj.Y / magSq, conj.Z / magSq, conj.W / magSq)
end

-- rotate vector3
function Quaternion:RotateVector(v)
	local qv = Quaternion.new(v.X, v.Y, v.Z, 0)
	local result = self * qv * self:Inverse()
	return {
		X = result.X,
		Y = result.Y,
		Z = result.Z,
	}
end

-- to 4x4 matrix (row major)
function Quaternion:ToMatrix4()
	local x, y, z, w = self.X, self.Y, self.Z, self.W

	local xx = x * x
	local yy = y * y
	local zz = z * z
	local xy = x * y
	local xz = x * z
	local yz = y * z
	local wx = w * x
	local wy = w * y
	local wz = w * z

	return {
		1 - 2 * (yy + zz),
		2 * (xy - wz),
		2 * (xz + wy),
		0,
		2 * (xy + wz),
		1 - 2 * (xx + zz),
		2 * (yz - wx),
		0,
		2 * (xz - wy),
		2 * (yz + wx),
		1 - 2 * (xx + yy),
		0,
		0,
		0,
		0,
		1,
	}
end

-- spherical interpolation
function Quaternion.slerp(a, b, t)
	local dot = a.X * b.X + a.Y * b.Y + a.Z * b.Z + a.W * b.W

	if dot < 0 then
		b = Quaternion.new(-b.X, -b.Y, -b.Z, -b.W)
		dot = -dot
	end

	if dot > 0.9995 then
		return Quaternion.new(
			a.X + t * (b.X - a.X),
			a.Y + t * (b.Y - a.Y),
			a.Z + t * (b.Z - a.Z),
			a.W + t * (b.W - a.W)
		)
			:Normalize()
	end

	local theta0 = math.acos(dot)
	local theta = theta0 * t
	local sinTheta = math.sin(theta)
	local sinTheta0 = math.sin(theta0)

	local s0 = math.cos(theta) - dot * sinTheta / sinTheta0
	local s1 = sinTheta / sinTheta0

	return Quaternion.new(s0 * a.X + s1 * b.X, s0 * a.Y + s1 * b.Y, s0 * a.Z + s1 * b.Z, s0 * a.W + s1 * b.W)
end

function Quaternion:__tostring()
	return string.format("Quaternion(%.5f, %.5f, %.5f, %.5f)", self.X, self.Y, self.Z, self.W)
end

function Quaternion:ToTable()
	return {
		type = "Quaternion",
		X = self.X,
		Y = self.Y,
		Z = self.Z,
		W = self.W,
	}
end

function Quaternion.FromTable(tbl)
	assert(tbl.type == "Quaternion", "Table is not a Quaternion")
	return Quaternion.new(tbl.X, tbl.Y, tbl.Z, tbl.W)
end

return Quaternion
