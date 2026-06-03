local Vector2 = require("./Vector2")

local CFrame2D = {}
CFrame2D.__index = CFrame2D

local CF2_EPSILON = 1e-6

local function isFinite(n)
	return n == n and n ~= math.huge and n ~= -math.huge
end

-- rotation matrix from angle
local function rotMatrix(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return {
		{ c, -s },
		{ s, c },
	}
end

local function mulRotation(a, b)
	return {
		{
			a[1][1] * b[1][1] + a[1][2] * b[2][1],
			a[1][1] * b[1][2] + a[1][2] * b[2][2],
		},
		{
			a[2][1] * b[1][1] + a[2][2] * b[2][1],
			a[2][1] * b[1][2] + a[2][2] * b[2][2],
		},
	}
end

-- constructors
function CFrame2D.new(...)
	local args = { ... }
	local self = setmetatable({}, CFrame2D)

	self.Position = Vector2.new(0, 0)
	self.Rotation = rotMatrix(0)

	if #args == 1 then
		self.Position = args[1]
	elseif #args == 2 then
		self.Position = Vector2.new(args[1], args[2])
	elseif #args == 3 then
		local pos, target = args[1], args[2]
		local dir = (target - pos):Unit()
		local angle = math.atan2(dir.Y, dir.X)
		self.Position = pos
		self.Rotation = rotMatrix(angle)
	else
		error("Invalid CFrame2D.new arguments")
	end

	return self
end

-- multiplication (composition)
function CFrame2D.__mul(a, b)
	local rp = b.Position
	local r = a.Rotation

	local pos = a.Position + Vector2.new(r[1][1] * rp.X + r[1][2] * rp.Y, r[2][1] * rp.X + r[2][2] * rp.Y)

	local rot = mulRotation(a.Rotation, b.Rotation)

	local cf = CFrame2D.new(pos)
	cf.Rotation = rot
	return cf
end

-- inverse
function CFrame2D:Inverse()
	local r = self.Rotation
	local rT = {
		{ r[1][1], r[2][1] },
		{ r[1][2], r[2][2] },
	}

	local p = self.Position
	local invPos = Vector2.new(-(rT[1][1] * p.X + rT[1][2] * p.Y), -(rT[2][1] * p.X + rT[2][2] * p.Y))

	local cf = CFrame2D.new(invPos)
	cf.Rotation = rT
	return cf
end

-- point transforms
function CFrame2D:PointToWorldSpace(point)
	local r = self.Rotation
	return self.Position + Vector2.new(r[1][1] * point.X + r[1][2] * point.Y, r[2][1] * point.X + r[2][2] * point.Y)
end

function CFrame2D:PointToObjectSpace(point)
	local rel = point - self.Position
	local r = self.Rotation
	return Vector2.new(r[1][1] * rel.X + r[2][1] * rel.Y, r[1][2] * rel.X + r[2][2] * rel.Y)
end

-- lerp
function CFrame2D:Lerp(target, alpha)
	local p0, p1 = self.Position, target.Position
	local pos = Vector2.new(p0.X + (p1.X - p0.X) * alpha, p0.Y + (p1.Y - p0.Y) * alpha)

	local a0 = self:GetAngle()
	local a1 = target:GetAngle()

	local da = math.atan2(math.sin(a1 - a0), math.cos(a1 - a0))
	local angle = a0 + da * alpha

	return CFrame2D.fromAngle(pos, angle)
end

-- helpers
function CFrame2D.fromAngle(pos, angle)
	local cf = CFrame2D.new(pos)
	cf.Rotation = rotMatrix(angle)
	return cf
end

function CFrame2D:GetAngle()
	return math.atan2(self.Rotation[2][1], self.Rotation[1][1])
end

function CFrame2D:GetRightVector()
	return Vector2.new(self.Rotation[1][1], self.Rotation[2][1])
end

function CFrame2D:GetUpVector()
	return Vector2.new(self.Rotation[1][2], self.Rotation[2][2])
end

function CFrame2D:IsFinite()
	local p = self.Position
	if not (isFinite(p.X) and isFinite(p.Y)) then
		return false
	end

	for i = 1, 2 do
		for j = 1, 2 do
			if not isFinite(self.Rotation[i][j]) then
				return false
			end
		end
	end

	return true
end

function CFrame2D.__eq(a, b)
	if not a or not b then
		return false
	end

	local dp = a.Position - b.Position
	if dp.X * dp.X + dp.Y * dp.Y > CF2_EPSILON * CF2_EPSILON then
		return false
	end

	for i = 1, 2 do
		for j = 1, 2 do
			if math.abs(a.Rotation[i][j] - b.Rotation[i][j]) > CF2_EPSILON then
				return false
			end
		end
	end

	return true
end

function CFrame2D:ToRelative(parent)
	return parent:Inverse() * self
end

function CFrame2D.FromRelative(parent, relative)
	return parent * relative
end

function CFrame2D:__tostring()
	return ("CFrame2D.new(%s, %s)"):format(self.Position.X, self.Position.Y)
end

function CFrame2D:ToTable()
	return {
		type = "CFrame2D",
		Position = self.Position:ToTable(),
		Rotation = self.Rotation,
	}
end

function CFrame2D.FromTable(tbl)
	assert(tbl.type == "CFrame2D", "Table is not a CFrame2D")
	local cf = CFrame2D.new(Vector2.FromTable(tbl.Position))
	cf.Rotation = tbl.Rotation
	return cf
end

return CFrame2D
