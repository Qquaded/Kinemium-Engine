local Serializer = require("./Serializer")

local SerializerAdapters = {}

local registered = false
local SQRT_HALF = math.sqrt(0.5)
local QUAT_SCALE = 511

local function packQuatComponent(value)
	if value > SQRT_HALF then
		value = SQRT_HALF
	elseif value < -SQRT_HALF then
		value = -SQRT_HALF
	end
	local scaled = math.floor(value / SQRT_HALF * QUAT_SCALE + 0.5)
	if scaled < 0 then
		scaled = scaled + 1024
	end
	return scaled
end

local function unpackQuatComponent(bits)
	if bits >= 512 then
		bits = bits - 1024
	end
	return bits / QUAT_SCALE * SQRT_HALF
end

local function packQuat(x, y, z, w)
	local ax, ay, az, aw = math.abs(x), math.abs(y), math.abs(z), math.abs(w)
	local maxVal = ax
	local idx = 0 -- x
	if ay > maxVal then
		maxVal = ay
		idx = 1 -- y
	end
	if az > maxVal then
		maxVal = az
		idx = 2 -- z
	end
	if aw > maxVal then
		maxVal = aw
		idx = 3 -- w
	end

	local signed
	if idx == 0 then
		signed = x
	elseif idx == 1 then
		signed = y
	elseif idx == 2 then
		signed = z
	else
		signed = w
	end
	if signed < 0 then
		x, y, z, w = -x, -y, -z, -w
	end

	local a, b, c
	if idx == 0 then
		a, b, c = y, z, w
	elseif idx == 1 then
		a, b, c = x, z, w
	elseif idx == 2 then
		a, b, c = x, y, w
	else
		a, b, c = x, y, z
	end

	local pa = packQuatComponent(a)
	local pb = packQuatComponent(b)
	local pc = packQuatComponent(c)

	return idx * 1073741824 + pa * 1048576 + pb * 1024 + pc
end

local function unpackQuat(packed)
	local idx = math.floor(packed / 1073741824) % 4
	local pa = math.floor(packed / 1048576) % 1024
	local pb = math.floor(packed / 1024) % 1024
	local pc = packed % 1024

	local a = unpackQuatComponent(pa)
	local b = unpackQuatComponent(pb)
	local c = unpackQuatComponent(pc)

	local dropSq = 1 - a * a - b * b - c * c
	local dropped = if dropSq > 0 then math.sqrt(dropSq) else 0

	if idx == 0 then
		return dropped, a, b, c
	elseif idx == 1 then
		return a, dropped, b, c
	elseif idx == 2 then
		return a, b, dropped, c
	else
		return a, b, c, dropped
	end
end

local function serializeVector3(value)
	local b = buffer.create(6)
	local x = math.clamp(math.round((value.X or 0) * 8), -32768, 32767)
	local y = math.clamp(math.round((value.Y or 0) * 8), -32768, 32767)
	local z = math.clamp(math.round((value.Z or 0) * 8), -32768, 32767)
	buffer.writei16(b, 0, x)
	buffer.writei16(b, 2, y)
	buffer.writei16(b, 4, z)
	return buffer.tostring(b)
end

local function deserializeVector3(str)
	local b = buffer.fromstring(str)
	return {
		type = "Vector3",
		__type = "Vector3",
		X = buffer.readi16(b, 0) / 8,
		Y = buffer.readi16(b, 2) / 8,
		Z = buffer.readi16(b, 4) / 8,
	}
end

local function serializeCFrame(value)
	local cf = value

	local pos = cf.Position or { X = 0, Y = 0, Z = 0 }
	local rot = cf.Rotation
	if not rot then
		error("CFrame adapter: value missing Rotation field")
	end

	local m11, m12, m13 = rot[1][1], rot[1][2], rot[1][3]
	local m21, m22, m23 = rot[2][1], rot[2][2], rot[2][3]
	local m31, m32, m33 = rot[3][1], rot[3][2], rot[3][3]

	local trace = m11 + m22 + m33
	local qx, qy, qz, qw
	if trace > 0 then
		local s = math.sqrt(trace + 1) * 2
		qw = 0.25 * s
		qx = (m32 - m23) / s
		qy = (m13 - m31) / s
		qz = (m21 - m12) / s
	elseif m11 > m22 and m11 > m33 then
		local s = math.sqrt(1 + m11 - m22 - m33) * 2
		qw = (m32 - m23) / s
		qx = 0.25 * s
		qy = (m12 + m21) / s
		qz = (m13 + m31) / s
	elseif m22 > m33 then
		local s = math.sqrt(1 + m22 - m11 - m33) * 2
		qw = (m13 - m31) / s
		qx = (m12 + m21) / s
		qy = 0.25 * s
		qz = (m23 + m32) / s
	else
		local s = math.sqrt(1 + m33 - m11 - m22) * 2
		qw = (m21 - m12) / s
		qx = (m13 + m31) / s
		qy = (m23 + m32) / s
		qz = 0.25 * s
	end

	local packed = packQuat(qx, qy, qz, qw)

	local b = buffer.create(10)
	local x = math.clamp(math.round((pos.X or 0) * 8), -32768, 32767)
	local y = math.clamp(math.round((pos.Y or 0) * 8), -32768, 32767)
	local z = math.clamp(math.round((pos.Z or 0) * 8), -32768, 32767)
	buffer.writei16(b, 0, x)
	buffer.writei16(b, 2, y)
	buffer.writei16(b, 4, z)
	buffer.writeu32(b, 6, packed)
	return buffer.tostring(b)
end

local function deserializeCFrame(str)
	local b = buffer.fromstring(str)
	local px = buffer.readi16(b, 0) / 8
	local py = buffer.readi16(b, 2) / 8
	local pz = buffer.readi16(b, 4) / 8
	local packed = buffer.readu32(b, 6)

	local x, y, z, w = unpackQuat(packed)

	local lenSq = x * x + y * y + z * z + w * w
	if lenSq > 0 then
		local inv = 1 / math.sqrt(lenSq)
		x, y, z, w = x * inv, y * inv, z * inv, w * inv
	end

	local xx, yy, zz = x * x, y * y, z * z
	local xy, xz, yz = x * y, x * z, y * z
	local wx, wy, wz = w * x, w * y, w * z

	local rot = {
		{ 1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy) },
		{ 2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx) },
		{ 2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy) },
	}

	return {
		type = "CFrame",
		__type = "CFrame",
		Position = {
			type = "Vector3",
			__type = "Vector3",
			X = px,
			Y = py,
			Z = pz,
		},
		Rotation = rot,
	}
end

function SerializerAdapters.EnsureRegistered()
	if registered then
		return
	end
	registered = true

	Serializer.RegisterType("Vector3", serializeVector3, deserializeVector3)
	Serializer.RegisterType("CFrame", serializeCFrame, deserializeCFrame)
end

function SerializerAdapters.IsRegistered()
	return registered
end

SerializerAdapters._packQuat = packQuat
SerializerAdapters._unpackQuat = unpackQuat

return SerializerAdapters
