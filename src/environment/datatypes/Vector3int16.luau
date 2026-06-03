local Vector3int16 = {}
Vector3int16.__index = Vector3int16

local Vector3 = require("@Vector3")

local MIN_INT16 = -32768
local MAX_INT16 = 32767
local RANGE = 65536

local function clampInt16(value: number): number
	value = math.floor(value)
	if value >= MIN_INT16 and value <= MAX_INT16 then
		return value
	end
	return ((value - MIN_INT16) % RANGE) + MIN_INT16
end

function Vector3int16.new(x: number?, y: number?, z: number?): Vector3int16
	return setmetatable({
		X = clampInt16(x or 0),
		Y = clampInt16(y or 0),
		Z = clampInt16(z or 0),
	}, Vector3int16)
end

Vector3int16.zero = Vector3int16.new(0, 0, 0)

function Vector3int16:__index(key: string): any
	if key == "x" then
		return self.X
	elseif key == "y" then
		return self.Y
	elseif key == "z" then
		return self.Z
	end
	return Vector3int16[key]
end

function Vector3int16.__add(a: Vector3int16, b: Vector3int16): Vector3int16
	return Vector3int16.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function Vector3int16.__sub(a: Vector3int16, b: Vector3int16): Vector3int16
	return Vector3int16.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function Vector3int16.__unm(a: Vector3int16): Vector3int16
	return Vector3int16.new(-a.X, -a.Y, -a.Z)
end

function Vector3int16.__mul(a: Vector3int16 | number, b: Vector3int16 | number): Vector3int16
	if type(a) == "number" then
		return Vector3int16.new(a * (b :: Vector3int16).X, a * (b :: Vector3int16).Y, a * (b :: Vector3int16).Z)
	elseif type(b) == "number" then
		return Vector3int16.new((a :: Vector3int16).X * b, (a :: Vector3int16).Y * b, (a :: Vector3int16).Z * b)
	else
		local av, bv = a :: Vector3int16, b :: Vector3int16
		return Vector3int16.new(av.X * bv.X, av.Y * bv.Y, av.Z * bv.Z)
	end
end

function Vector3int16.__div(a: Vector3int16, b: Vector3int16 | number): Vector3int16
	if type(b) == "number" then
		return Vector3int16.new(a.X / b, a.Y / b, a.Z / b)
	else
		local bv = b :: Vector3int16
		return Vector3int16.new(a.X / bv.X, a.Y / bv.Y, a.Z / bv.Z)
		-- Note: clampInt16 already floors, so no explicit math.floor needed here.
	end
end

function Vector3int16.__eq(a: Vector3int16, b: Vector3int16): boolean
	return a.X == b.X and a.Y == b.Y and a.Z == b.Z
end

function Vector3int16:__tostring(): string
	return string.format("%d, %d, %d", self.X, self.Y, self.Z)
end

function Vector3int16:ToVector3(): Vector3
	return Vector3.new(self.X, self.Y, self.Z)
end

function Vector3int16:Abs(): Vector3int16
	return Vector3int16.new(math.abs(self.X), math.abs(self.Y), math.abs(self.Z))
end

function Vector3int16:Dot(other: Vector3int16): number
	return self.X * other.X + self.Y * other.Y + self.Z * other.Z
end

function Vector3int16:Length(): number
	return math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)
end

function Vector3int16:ToTable(): { type: string, X: number, Y: number, Z: number }
	return { type = "Vector3int16", X = self.X, Y = self.Y, Z = self.Z }
end

function Vector3int16.FromTable(tbl: { type: string, X: number, Y: number, Z: number }): Vector3int16
	assert(tbl.type == "Vector3int16", "Table is not a Vector3int16")
	return Vector3int16.new(tbl.X, tbl.Y, tbl.Z)
end

export type Vector3int16 = typeof(Vector3int16.new())

return Vector3int16
