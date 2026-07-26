local ffi = zune.ffi
local adapter = require("@RaylibAdapter")

local function float_ptr(value: number): FFIPointer
	local ptr = ffi.create(ffi.types.float)
	ptr:writef32(0, value)
	return ptr
end

local function vec3_ptr(x: number, y: number, z: number): FFIPointer
	local ptr = ffi.create(ffi.types.float:array(3))
	ptr:writef32(0, x)
	ptr:writef32(4, y)
	ptr:writef32(8, z)
	return ptr
end

local function vec4_ptr(x, y, z, w)
	local arr = ffi.create(ffi.types.float:array(4))
	arr:writef32(0, x)
	arr:writef32(4, y)
	arr:writef32(8, z)
	arr:writef32(12, w)
	return arr
end

local function Vector3RotateByAxisAngle(v: adapter.Vector3, axis: adapter.Vector3, angle: number): adapter.Vector3
	local length = vector.magnitude(axis)
	if length == 0.0 then
		length = 1.0
	end
	local ilength = 1.0 / length
	axis *= vector.create(ilength, ilength, ilength)

	angle /= 2.0
	local a = math.sin(angle)
	local w = vector.create(axis.x * a, axis.y * a, axis.z * a)
	a = math.cos(angle)

	local wv = vector.create(w.y * v.z - w.z * v.y, w.z * v.x - w.x * v.z, w.x * v.y - w.y * v.x)
	local wwv = vector.create(w.y * wv.z - w.z * wv.y, w.z * wv.x - w.x * wv.z, w.x * wv.y - w.y * wv.x)

	a *= 2.0
	wv *= a
	wwv *= 2.0

	return v + wv + wwv
end

return {
	vec3_ptr = vec3_ptr,
	float_ptr = float_ptr,
	Vector3RotateByAxisAngle = Vector3RotateByAxisAngle,
	vec4_ptr = vec4_ptr,
}
