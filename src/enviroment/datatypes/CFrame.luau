local Vector3 = require("./Vector3")

local CFrame = {}
CFrame.__index = CFrame

local CF_EPSILON = 1e-6

local function isFinite(n)
	return n == n and n ~= math.huge and n ~= -math.huge
end

local function mulRotation(a, b)
	local r = {}
	for i = 1, 3 do
		r[i] = {}
		for j = 1, 3 do
			r[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j]
		end
	end
	return r
end

function CFrame.new(...)
	local args = { ... }
	local self = setmetatable({}, CFrame)

	self.Rotation = {
		{ 1, 0, 0 },
		{ 0, 1, 0 },
		{ 0, 0, 1 },
	}

	if #args == 1 then
		self.Position = args[1]
	elseif #args == 3 then
		self.Position = Vector3.new(args[1], args[2], args[3])
	elseif #args == 2 then
		local pos, target = args[1], args[2]
		local z = (pos - target)
		local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
		z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
		local up = Vector3.new(0, 1, 0)
		local x = up:Cross(z)
		local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
		x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
		local y = z:Cross(x)
		self.Position = pos
		self.Rotation = {
			{ x.X, y.X, z.X },
			{ x.Y, y.Y, z.Y },
			{ x.Z, y.Z, z.Z },
		}
	elseif #args == 12 then
		self.Position = Vector3.new(args[1], args[2], args[3])
		self.Rotation = {
			{ args[4], args[5], args[6] },
			{ args[7], args[8], args[9] },
			{ args[10], args[11], args[12] },
		}
	else
		error("Invalid CFrame.new arguments")
	end

	return self
end

function CFrame:ToQuaternion()
	local r = self.Rotation

	-- Calculate trace
	local trace = r[1][1] + r[2][2] + r[3][3]

	if trace > 0 then
		local s = math.sqrt(trace + 1.0) * 2 -- s = 4 * qw
		local w = 0.25 * s
		local x = (r[3][2] - r[2][3]) / s
		local y = (r[1][3] - r[3][1]) / s
		local z = (r[2][1] - r[1][2]) / s
		return x, y, z, w
	elseif r[1][1] > r[2][2] and r[1][1] > r[3][3] then
		local s = math.sqrt(1.0 + r[1][1] - r[2][2] - r[3][3]) * 2 -- s = 4 * qx
		local w = (r[3][2] - r[2][3]) / s
		local x = 0.25 * s
		local y = (r[1][2] + r[2][1]) / s
		local z = (r[1][3] + r[3][1]) / s
		return x, y, z, w
	elseif r[2][2] > r[3][3] then
		local s = math.sqrt(1.0 + r[2][2] - r[1][1] - r[3][3]) * 2 -- s = 4 * qy
		local w = (r[1][3] - r[3][1]) / s
		local x = (r[1][2] + r[2][1]) / s
		local y = 0.25 * s
		local z = (r[2][3] + r[3][2]) / s
		return x, y, z, w
	else
		local s = math.sqrt(1.0 + r[3][3] - r[1][1] - r[2][2]) * 2 -- s = 4 * qz
		local w = (r[2][1] - r[1][2]) / s
		local x = (r[1][3] + r[3][1]) / s
		local y = (r[2][3] + r[3][2]) / s
		local z = 0.25 * s
		return x, y, z, w
	end
end

function CFrame.__mul(a, b)
	local pos = a.Position
		+ Vector3.new(
			a.Rotation[1][1] * b.Position.X + a.Rotation[1][2] * b.Position.Y + a.Rotation[1][3] * b.Position.Z,
			a.Rotation[2][1] * b.Position.X + a.Rotation[2][2] * b.Position.Y + a.Rotation[2][3] * b.Position.Z,
			a.Rotation[3][1] * b.Position.X + a.Rotation[3][2] * b.Position.Y + a.Rotation[3][3] * b.Position.Z
		)
	local rot = mulRotation(a.Rotation, b.Rotation)
	local cf = CFrame.new(pos)
	cf.Rotation = rot
	return cf
end

function CFrame:Inverse()
	local rT = {}
	for i = 1, 3 do
		rT[i] = {}
		for j = 1, 3 do
			rT[i][j] = self.Rotation[j][i]
		end
	end
	local invPos = Vector3.new(
		-(rT[1][1] * self.Position.X + rT[1][2] * self.Position.Y + rT[1][3] * self.Position.Z),
		-(rT[2][1] * self.Position.X + rT[2][2] * self.Position.Y + rT[2][3] * self.Position.Z),
		-(rT[3][1] * self.Position.X + rT[3][2] * self.Position.Y + rT[3][3] * self.Position.Z)
	)
	local cf = CFrame.new(invPos)
	cf.Rotation = rT
	return cf
end

function CFrame:Lerp(target, alpha)
	return self:Slerp(target, alpha)
end

function CFrame:PointToWorldSpace(point)
	return self.Position
		+ Vector3.new(
			self.Rotation[1][1] * point.X + self.Rotation[1][2] * point.Y + self.Rotation[1][3] * point.Z,
			self.Rotation[2][1] * point.X + self.Rotation[2][2] * point.Y + self.Rotation[2][3] * point.Z,
			self.Rotation[3][1] * point.X + self.Rotation[3][2] * point.Y + self.Rotation[3][3] * point.Z
		)
end

function CFrame:ToWorldSpace(cf)
	return self * cf
end

function CFrame.lookAt(pos, target, up)
	up = up or Vector3.new(0, 1, 0)
	local z = (pos - target)
	local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
	z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
	if math.abs(up:Dot(z)) > 0.999 then
		up = Vector3.new(0, 0, 1)
	end

	local x = up:Cross(z)
	local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
	x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
	local y = z:Cross(x)
	local cf = CFrame.new(pos)
	cf.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}

	return cf
end

-- Get rotation components (XVector, YVector, ZVector)
function CFrame:GetComponents()
	return self.Position.X,
		self.Position.Y,
		self.Position.Z,
		self.Rotation[1][1],
		self.Rotation[1][2],
		self.Rotation[1][3],
		self.Rotation[2][1],
		self.Rotation[2][2],
		self.Rotation[2][3],
		self.Rotation[3][1],
		self.Rotation[3][2],
		self.Rotation[3][3]
end

function CFrame:GetRightVector()
	return Vector3.new(self.Rotation[1][1], self.Rotation[2][1], self.Rotation[3][1])
end

function CFrame:GetUpVector()
	return Vector3.new(self.Rotation[1][2], self.Rotation[2][2], self.Rotation[3][2])
end

function CFrame:GetLookVector()
	return Vector3.new(-self.Rotation[1][3], -self.Rotation[2][3], -self.Rotation[3][3])
end

function CFrame:IsSamePosition(other, epsilon)
	epsilon = epsilon or 1e-6
	local d = self.Position - other.Position
	return d.X * d.X + d.Y * d.Y + d.Z * d.Z <= epsilon * epsilon
end

function CFrame:IsSameRotation(other, epsilon)
	epsilon = epsilon or 1e-6
	for i = 1, 3 do
		for j = 1, 3 do
			if math.abs(self.Rotation[i][j] - other.Rotation[i][j]) > epsilon then
				return false
			end
		end
	end
	return true
end

function CFrame:IsSameTransform(other, epsilon)
	epsilon = epsilon or 1e-6
	return self:IsSamePosition(other, epsilon) and self:IsSameRotation(other, epsilon)
end

function CFrame:PointToObjectSpace(point)
	local rel = point - self.Position
	return Vector3.new(
		self.Rotation[1][1] * rel.X + self.Rotation[2][1] * rel.Y + self.Rotation[3][1] * rel.Z,
		self.Rotation[1][2] * rel.X + self.Rotation[2][2] * rel.Y + self.Rotation[3][2] * rel.Z,
		self.Rotation[1][3] * rel.X + self.Rotation[2][3] * rel.Y + self.Rotation[3][3] * rel.Z
	)
end

function CFrame:GetPosition()
	return self.Position
end

function CFrame:GetRotation()
	return self.Rotation
end

function CFrame:Orthonormalize()
	local x = self:GetRightVector()
	local y = self:GetUpVector()

	x = x:Unit()
	y = (y - x * x:Dot(y)):Unit()
	local z = x:Cross(y)

	self.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}
	return self
end

function CFrame:FastInverse()
	local r = self.Rotation
	local t = self.Position

	local rT = {
		{ r[1][1], r[2][1], r[3][1] },
		{ r[1][2], r[2][2], r[3][2] },
		{ r[1][3], r[2][3], r[3][3] },
	}

	local invPos = Vector3.new(
		-(rT[1][1] * t.X + rT[1][2] * t.Y + rT[1][3] * t.Z),
		-(rT[2][1] * t.X + rT[2][2] * t.Y + rT[2][3] * t.Z),
		-(rT[3][1] * t.X + rT[3][2] * t.Y + rT[3][3] * t.Z)
	)

	local cf = CFrame.new(invPos)
	cf.Rotation = rT
	return cf
end

function CFrame:DistanceTo(other)
	return (self.Position - other.Position):Magnitude()
end

function CFrame:IsClose(other, epsilon)
	epsilon = epsilon or 1e-4

	if (self.Position - other.Position):Magnitude() > epsilon then
		return false
	end

	for i = 1, 3 do
		for j = 1, 3 do
			if math.abs(self.Rotation[i][j] - other.Rotation[i][j]) > epsilon then
				return false
			end
		end
	end

	return true
end

function CFrame:TransformPoint(point)
	return self:PointToWorldSpace(point)
end

function CFrame:TransformVector(vec)
	return self:VectorToWorldSpace(vec)
end

function CFrame:WithPosition(pos)
	local cf = CFrame.new(pos)
	cf.Rotation = self.Rotation
	return cf
end

function CFrame:WithRotation(rot)
	local cf = CFrame.new(self.Position)
	cf.Rotation = rot
	return cf
end

function CFrame:GetAxes()
	return Vector3.new(self.Rotation[1][1], self.Rotation[2][1], self.Rotation[3][1]),
		Vector3.new(self.Rotation[1][2], self.Rotation[2][2], self.Rotation[3][2]),
		Vector3.new(self.Rotation[1][3], self.Rotation[2][3], self.Rotation[3][3])
end

function CFrame:GetBasisVectors()
	local right = Vector3.new(self.Rotation[1][1], self.Rotation[2][1], self.Rotation[3][1])
	local up = Vector3.new(self.Rotation[1][2], self.Rotation[2][2], self.Rotation[3][2])
	local look = Vector3.new(-self.Rotation[1][3], -self.Rotation[2][3], -self.Rotation[3][3])
	return right, up, look
end

function CFrame:FacingDirection(dir, up)
	up = up or Vector3.new(0, 1, 0)
	dir = dir:Unit()

	local x = up:Cross(dir):Unit()
	local y = dir:Cross(x)

	local cf = CFrame.new(self.Position)
	cf.Rotation = {
		{ x.X, y.X, -dir.X },
		{ x.Y, y.Y, -dir.Y },
		{ x.Z, y.Z, -dir.Z },
	}
	return cf
end

function CFrame:RotateAroundAxis(axis, angle)
	return self * CFrame.fromAxisAngle(axis, angle)
end

function CFrame:RotateAroundPoint(point, axis, angle)
	return CFrame.new(point) * CFrame.fromAxisAngle(axis, angle) * CFrame.new(-point) * self
end

function CFrame.ProjectPointOntoPlane(point, normal)
	normal = normal:Unit()
	return point - normal * (point:Dot(normal))
end

function CFrame:Mirror(normal)
	normal = normal:Unit()
	local p = self.Position
	local reflectedPos = p - normal * (2 * p:Dot(normal))

	local r = self.Rotation
	for i = 1, 3 do
		local v = Vector3.new(r[1][i], r[2][i], r[3][i])
		v = v - normal * (2 * v:Dot(normal))
		r[1][i], r[2][i], r[3][i] = v.X, v.Y, v.Z
	end

	local cf = CFrame.new(reflectedPos)
	cf.Rotation = r
	return cf
end

function CFrame:ClampPosition(min, max)
	local p = self.Position
	return CFrame.new(
		Vector3.new(math.clamp(p.X, min.X, max.X), math.clamp(p.Y, min.Y, max.Y), math.clamp(p.Z, min.Z, max.Z))
	)
end

function CFrame:Delta(other)
	return self:FastInverse() * other
end

function CFrame:ApproximatelyIdentity(epsilon)
	epsilon = epsilon or 1e-5

	if self.Position:Magnitude() > epsilon then
		return false
	end

	local r = self.Rotation
	return math.abs(r[1][1] - 1) < epsilon and math.abs(r[2][2] - 1) < epsilon and math.abs(r[3][3] - 1) < epsilon
end

function CFrame:GetYawPitchRoll()
	local r = self.Rotation

	local pitch = math.asin(-r[2][3])
	local yaw, roll

	if math.abs(math.cos(pitch)) > 1e-6 then
		yaw = math.atan2(r[1][3], r[3][3])
		roll = math.atan2(r[2][1], r[2][2])
	else
		yaw = 0
		roll = math.atan2(-r[3][1], r[1][1])
	end

	return yaw, pitch, roll
end

function CFrame:WithYawPitchRoll(yaw, pitch, roll)
	return CFrame.new(self.Position) * CFrame.fromEulerAnglesYXZ(yaw, pitch, roll)
end

function CFrame:FlattenY()
	local look = self:GetLookVector()
	look = Vector3.new(look.X, 0, look.Z)

	if look:Magnitude() < 1e-6 then
		return self
	end

	return CFrame.lookAt(self.Position, self.Position + look)
end

function CFrame:IsFinite()
	local p = self.Position
	if not (isFinite(p.X) and isFinite(p.Y) and isFinite(p.Z)) then
		return false
	end

	for i = 1, 3 do
		for j = 1, 3 do
			if not isFinite(self.Rotation[i][j]) then
				return false
			end
		end
	end

	return true
end

function CFrame:ToObjectSpace(cf)
	return self:Inverse() * cf
end

function CFrame:VectorToWorldSpace(vec)
	return Vector3.new(
		self.Rotation[1][1] * vec.X + self.Rotation[1][2] * vec.Y + self.Rotation[1][3] * vec.Z,
		self.Rotation[2][1] * vec.X + self.Rotation[2][2] * vec.Y + self.Rotation[2][3] * vec.Z,
		self.Rotation[3][1] * vec.X + self.Rotation[3][2] * vec.Y + self.Rotation[3][3] * vec.Z
	)
end

function CFrame:VectorToObjectSpace(vec)
	return Vector3.new(
		self.Rotation[1][1] * vec.X + self.Rotation[2][1] * vec.Y + self.Rotation[3][1] * vec.Z,
		self.Rotation[1][2] * vec.X + self.Rotation[2][2] * vec.Y + self.Rotation[3][2] * vec.Z,
		self.Rotation[1][3] * vec.X + self.Rotation[2][3] * vec.Y + self.Rotation[3][3] * vec.Z
	)
end

function CFrame.fromEulerAnglesXYZ(x, y, z)
	return CFrame.Angles(x, y, z)
end

function CFrame.fromEulerAnglesYXZ(y, x, z)
	local cx, sx = math.cos(x), math.sin(x)
	local cy, sy = math.cos(y), math.sin(y)
	local cz, sz = math.cos(z), math.sin(z)

	local rot = {
		{ cy * cz + sy * sx * sz, -cy * sz + sy * sx * cz, sy * cx },
		{ cx * sz, cx * cz, -sx },
		{ -sy * cz + cy * sx * sz, sy * sz + cy * sx * cz, cy * cx },
	}

	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame.fromAxisAngle(axis, angle)
	local c, s = math.cos(angle), math.sin(angle)
	local t = 1 - c
	local x, y, z = axis.X, axis.Y, axis.Z
	local mag = math.sqrt(x * x + y * y + z * z)
	x, y, z = x / mag, y / mag, z / mag

	local rot = {
		{ t * x * x + c, t * x * y - s * z, t * x * z + s * y },
		{ t * x * y + s * z, t * y * y + c, t * y * z - s * x },
		{ t * x * z - s * y, t * y * z + s * x, t * z * z + c },
	}

	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame.__add(a, b)
	error("Use :Add() instead of + for CFrame operations")
end

function CFrame.__sub(a, b)
	if type(b) == "table" and b.__type == "Vector3" then
		return CFrame.new(a.Position - b)
	elseif type(b) == "table" and b.__type == "CFrame" then
		return CFrame.new(a.Position - b.Position, a.Rotation)
	end
	error("Cannot subtract " .. b.__type .. " from CFrame")
end

function CFrame.__eq(a, b)
	-- fast reject
	if not a or not b then
		return false
	end

	-- position compare (epsilon)
	local dp = a.Position - b.Position
	if dp.X * dp.X + dp.Y * dp.Y + dp.Z * dp.Z > CF_EPSILON * CF_EPSILON then
		return false
	end

	-- rotation compare (epsilon)
	for i = 1, 3 do
		for j = 1, 3 do
			if math.abs(a.Rotation[i][j] - b.Rotation[i][j]) > CF_EPSILON then
				return false
			end
		end
	end

	return true
end

function CFrame.fromMatrix(pos, x, y, z)
	local cf = CFrame.new(pos)
	cf.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}
	return cf
end

function CFrame:ToEulerAnglesXYZ()
	local r = self.Rotation
	local x, y, z

	if r[3][1] < 1 then
		if r[3][1] > -1 then
			y = math.asin(r[3][1])
			x = math.atan2(-r[3][2], r[3][3])
			z = math.atan2(-r[2][1], r[1][1])
		else
			y = -math.pi / 2
			x = -math.atan2(r[2][3], r[2][2])
			z = 0
		end
	else
		y = math.pi / 2
		x = math.atan2(r[2][3], r[2][2])
		z = 0
	end

	return x, y, z
end

function CFrame:Sanitize()
	if not self:IsFinite() then
		self.Position = Vector3.new(0, 0, 0)
		self.Rotation = {
			{ 1, 0, 0 },
			{ 0, 1, 0 },
			{ 0, 0, 1 },
		}
	end
	return self:Orthonormalize()
end

function CFrame:MoveLocal(offset)
	return CFrame.new(self:PointToWorldSpace(offset)) * CFrame.new(Vector3.new(0, 0, 0))
end

function CFrame:TranslateLocal(x, y, z)
	return self * CFrame.new(Vector3.new(x, y, z))
end

function CFrame:AlignUp(normal)
	local look = self:GetLookVector()
	local right = normal:Cross(look):Unit()
	local up = look:Cross(right)

	local cf = CFrame.new(self.Position)
	cf.Rotation = {
		{ right.X, up.X, -look.X },
		{ right.Y, up.Y, -look.Y },
		{ right.Z, up.Z, -look.Z },
	}
	return cf
end

function CFrame:SnapPosition(grid)
	local p = self.Position
	return CFrame.new(
		Vector3.new(
			math.floor(p.X / grid + 0.5) * grid,
			math.floor(p.Y / grid + 0.5) * grid,
			math.floor(p.Z / grid + 0.5) * grid
		)
	)
end

function CFrame:SnapRotation(step)
	local x, y, z = self:ToEulerAnglesXYZ()
	x = math.floor(x / step + 0.5) * step
	y = math.floor(y / step + 0.5) * step
	z = math.floor(z / step + 0.5) * step
	return CFrame.new(self.Position) * CFrame.Angles(x, y, z)
end

function CFrame:ToRelative(parent)
	return parent:FastInverse() * self
end

function CFrame.FromRelative(parent, relative)
	return parent * relative
end

function CFrame:Slerp(target, alpha)
	-- position lerp
	local p0 = self.Position
	local p1 = target.Position
	local pos = Vector3.new(p0.X + (p1.X - p0.X) * alpha, p0.Y + (p1.Y - p0.Y) * alpha, p0.Z + (p1.Z - p0.Z) * alpha)

	-- rotation slerp (quaternion)
	local x0, y0, z0, w0 = self:ToQuaternion()
	local x1, y1, z1, w1 = target:ToQuaternion()

	-- dot product
	local dot = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1

	-- take shortest path
	if dot < 0 then
		dot = -dot
		x1, y1, z1, w1 = -x1, -y1, -z1, -w1
	end

	local x, y, z, w

	if dot > 0.9995 then
		-- nearly identical: fall back to nlerp
		x = x0 + (x1 - x0) * alpha
		y = y0 + (y1 - y0) * alpha
		z = z0 + (z1 - z0) * alpha
		w = w0 + (w1 - w0) * alpha
	else
		local theta0 = math.acos(dot)
		local sinTheta0 = math.sin(theta0)

		local theta = theta0 * alpha
		local sinTheta = math.sin(theta)

		local s0 = math.cos(theta) - dot * sinTheta / sinTheta0
		local s1 = sinTheta / sinTheta0

		x = x0 * s0 + x1 * s1
		y = y0 * s0 + y1 * s1
		z = z0 * s0 + z1 * s1
		w = w0 * s0 + w1 * s1
	end

	return CFrame.fromQuaternion(x, y, z, w, pos)
end

function CFrame.Angles(x, y, z)
	local cx, sx = math.cos(x), math.sin(x)
	local cy, sy = math.cos(y), math.sin(y)
	local cz, sz = math.cos(z), math.sin(z)

	local rotX = {
		{ 1, 0, 0 },
		{ 0, cx, sx },
		{ 0, -sx, cx },
	}

	local rotY = {
		{ cy, 0, sy },
		{ 0, 1, 0 },
		{ -sy, 0, cy },
	}

	local rotZ = {
		{ cz, -sz, 0 },
		{ sz, cz, 0 },
		{ 0, 0, 1 },
	}

	local rot = mulRotation(rotZ, mulRotation(rotY, rotX))
	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame:__tostring()
	return ("CFrame.new(%s, %s, %s)"):format(self.Position.X, self.Position.Y, self.Position.Z)
end

function CFrame:ToTable()
	return {
		type = "CFrame",
		Position = self.Position:ToTable(),
		Rotation = self.Rotation,
	}
end

function CFrame.FromTable(tbl)
	assert(tbl.type == "CFrame")
	local cf = CFrame.new(Vector3.FromTable(tbl.Position))
	cf.Rotation = tbl.Rotation
	return cf
end

function CFrame:ToRaylibMatrixScale(scale, structs)
	local r = self.Rotation
	local p = self.Position
	scale = scale or { X = 1, Y = 1, Z = 1 }

	return structs.Matrix:new({
		m0 = r[1][1] * scale.X,
		m1 = r[2][1] * scale.X,
		m2 = r[3][1] * scale.X,
		m3 = 0,

		m4 = r[1][2] * scale.Y,
		m5 = r[2][2] * scale.Y,
		m6 = r[3][2] * scale.Y,
		m7 = 0,

		m8 = r[1][3] * scale.Z,
		m9 = r[2][3] * scale.Z,
		m10 = r[3][3] * scale.Z,
		m11 = 0,

		m12 = p.X,
		m13 = p.Y,
		m14 = p.Z,
		m15 = 1,
	})
end

function CFrame:Add(other)
	return CFrame.new(self.Position + other.Position):WithRotation(self.Rotation)
end

function CFrame:AddPosition(vec)
	return CFrame.new(self.Position + vec):WithRotation(self.Rotation)
end

function CFrame:AddRotation(other)
	local rot = mulRotation(self.Rotation, other.Rotation)
	return self:WithRotation(rot)
end

function CFrame.fromQuaternion(x, y, z, w, pos)
	local len = math.sqrt(x * x + y * y + z * z + w * w)
	x, y, z, w = x / len, y / len, z / len, w / len

	local xx, yy, zz = x * x, y * y, z * z
	local xy, xz, yz = x * y, x * z, y * z
	local wx, wy, wz = w * x, w * y, w * z

	local m00 = 1 - 2 * (yy + zz)
	local m01 = 2 * (xy - wz)
	local m02 = 2 * (xz + wy)

	local m10 = 2 * (xy + wz)
	local m11 = 1 - 2 * (xx + zz)
	local m12 = 2 * (yz - wx)

	local m20 = 2 * (xz - wy)
	local m21 = 2 * (yz + wx)
	local m22 = 1 - 2 * (xx + yy)

	local right = Vector3.new(m00, m10, m20)
	local up = Vector3.new(m01, m11, m21)
	local look = Vector3.new(-m02, -m12, -m22)

	return CFrame.fromMatrix(pos, right, up, look)
end

function CFrame:GetMatrixData(scale)
	local r = self.Rotation
	local p = self.Position

	scale = scale or Vector3.new(1, 1, 1)

	if scale then
		return {
			m0 = r[1][1] * scale.X,
			m1 = r[2][1] * scale.X,
			m2 = r[3][1] * scale.X,
			m3 = 0,

			m4 = r[1][2] * scale.Y,
			m5 = r[2][2] * scale.Y,
			m6 = r[3][2] * scale.Y,
			m7 = 0,

			m8 = r[1][3] * scale.Z,
			m9 = r[2][3] * scale.Z,
			m10 = r[3][3] * scale.Z,
			m11 = 0,

			m12 = p.X,
			m13 = p.Y,
			m14 = p.Z,
			m15 = 1,
		}
	else
		return {
			m0 = r[1][1],
			m1 = r[2][1],
			m2 = r[3][1],
			m3 = 0,

			m4 = r[1][2],
			m5 = r[2][2],
			m6 = r[3][2],
			m7 = 0,

			m8 = r[1][3],
			m9 = r[2][3],
			m10 = r[3][3],
			m11 = 0,

			m12 = p.X,
			m13 = p.Y,
			m14 = p.Z,
			m15 = 1,
		}
	end
end

function CFrame:ToRaylibMatrix(structs)
	return structs.Matrix:new(CFrame:GetMatrixData())
end

CFrame.identity = CFrame.new(0, 0, 0)

function CFrame.fromOrientation(rx, ry, rz)
	local cx, cy, cz = math.cos(rx), math.cos(ry), math.cos(rz)
	local sx, sy, sz = math.sin(rx), math.sin(ry), math.sin(rz)

	local m00 = cy * cz
	local m01 = sx * sy * cz - cx * sz
	local m02 = cx * sy * cz + sx * sz

	local m10 = cy * sz
	local m11 = sx * sy * sz + cx * cz
	local m12 = cx * sy * sz - sx * cz

	local m20 = -sy
	local m21 = sx * cy
	local m22 = cx * cy

	-- Pos X, Y, Z, and rotation matrix components
	return CFrame.new(0, 0, 0, m00, m01, m02, m10, m11, m12, m20, m21, m22)
end

function CFrame:ToOrientation()
	local r = self.Rotation
	local m00, m10, m20 = r[1][1], r[2][1], r[3][1]
	local m21 = r[3][2]
	local m22 = r[3][3]

	local rx = math.atan2(m21, m22)
	local ry = math.asin(math.clamp(-m20, -1, 1))
	local rz = math.atan2(m10, m00)

	return rx, ry, rz
end

function CFrame:components()
	return self:GetComponents()
end

function CFrame.__unm(a)
	local r = a.Rotation
	return CFrame.new(
		-a.Position.X,
		-a.Position.Y,
		-a.Position.Z,
		r[1][1],
		r[1][2],
		r[1][3],
		r[2][1],
		r[2][2],
		r[2][3],
		r[3][1],
		r[3][2],
		r[3][3]
	)
end

function CFrame:Dot(other)
	return self.Position:Dot(other.Position)
end

function CFrame:Determinant()
	local r = self.Rotation
	return r[1][1] * (r[2][2] * r[3][3] - r[2][3] * r[3][2])
		- r[1][2] * (r[2][1] * r[3][3] - r[2][3] * r[3][1])
		+ r[1][3] * (r[2][1] * r[3][2] - r[2][2] * r[3][1])
end

return CFrame
