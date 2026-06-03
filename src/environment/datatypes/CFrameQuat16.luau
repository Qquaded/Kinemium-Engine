local CFrameQuat16 = {}
CFrameQuat16.__index = CFrameQuat16

local Vector3int16 = require("@Vector3int16")
local CFrame = require("@CFrame")

local MIN_INT16 = -32768
local MAX_INT16 = 32767
local SCALE = 32767

local function clampInt16(value)
	value = math.floor(value + 0.5)
	if value < MIN_INT16 then
		value = MIN_INT16
	elseif value > MAX_INT16 then
		value = MAX_INT16
	end
	return value
end

local function floatToInt16(v)
	return clampInt16(v * SCALE)
end

local function int16ToFloat(v)
	return v / SCALE
end

local function normalizeQuaternion(x, y, z, w)
	local mag = math.sqrt(x * x + y * y + z * z + w * w)
	if mag == 0 then
		return 0, 0, 0, 1
	end
	return x / mag, y / mag, z / mag, w / mag
end

function CFrameQuat16.new(px, py, pz, qx, qy, qz, qw)
	qx, qy, qz, qw = normalizeQuaternion(qx, qy, qz, qw)

	return setmetatable({
		Position = Vector3int16.new(px, py, pz),

		QX = floatToInt16(qx),
		QY = floatToInt16(qy),
		QZ = floatToInt16(qz),
		QW = floatToInt16(qw),
	}, CFrameQuat16)
end

function CFrameQuat16.fromCFrame(cf)
	local px, py, pz = cf.Position.X, cf.Position.Y, cf.Position.Z
	local qx, qy, qz, qw = cf:ToQuaternion()

	return CFrameQuat16.new(px, py, pz, qx, qy, qz, qw)
end

function CFrameQuat16:ToCFrame()
	local qx = int16ToFloat(self.QX)
	local qy = int16ToFloat(self.QY)
	local qz = int16ToFloat(self.QZ)
	local qw = int16ToFloat(self.QW)

	qx, qy, qz, qw = normalizeQuaternion(qx, qy, qz, qw)

	return CFrame.new(self.Position.X, self.Position.Y, self.Position.Z, qx, qy, qz, qw)
end

function CFrameQuat16:__tostring()
	return string.format(
		"CFrameQuat16(Pos=%s, Q=(%d,%d,%d,%d))",
		tostring(self.Position),
		self.QX,
		self.QY,
		self.QZ,
		self.QW
	)
end

function CFrameQuat16:ToTable()
	if not self.Position then
		return {}
	end
	return {
		type = "CFrameQuat16",
		Position = self.Position:ToTable(),
		QX = self.QX,
		QY = self.QY,
		QZ = self.QZ,
		QW = self.QW,
	}
end

function CFrameQuat16.FromTable(tbl)
	assert(tbl.type == "CFrameQuat16", "Table is not a CFrameQuat16")
	return CFrameQuat16.new(tbl.Position.X, tbl.Position.Y, tbl.Position.Z, tbl.QX, tbl.QY, tbl.QZ, tbl.QW)
end

return CFrameQuat16
