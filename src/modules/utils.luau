local bufferUtils = { extract = {}, string = {} }

local box2d = require("@box2d")
local box2d_structs = box2d.structs
local const, structs, lib = adapter.const, adapter.structs, adapter.lib
local ffi = zune.ffi

local function getOfs(source, field)
	return source:offset(field)
end

-- Strings
function bufferUtils.stringToPtr(str)
	return ffi.dupe(buffer.fromstring(`{str}\0`))
end

function bufferUtils.string.ReadUTF16(outPath)
	local stringPtr = outPath:readptr(0)

	local bytes = {}
	local i = 0
	while true do
		local b1 = stringPtr:readu8(i)
		local b2 = stringPtr:readu8(i + 1)
		-- Stop at UTF-16 null terminator
		if b1 == 0 and b2 == 0 then
			break
		end
		-- Convert little-endian UTF-16 to codepoint
		local code = b1 + b2 * 256
		bytes[#bytes + 1] = utf8.char(code)
		i = i + 2
	end

	return table.concat(bytes)
end

function bufferUtils.WriteColorToBuffer(dest, offset, colorBuf)
	-- colorBuf is a buffer (4 bytes: R, G, B, A)
	-- dest is a Zune FFIPointer
	dest:writeu8(offset + 0, buffer.readu8(colorBuf, 0))
	dest:writeu8(offset + 1, buffer.readu8(colorBuf, 1))
	dest:writeu8(offset + 2, buffer.readu8(colorBuf, 2))
	dest:writeu8(offset + 3, buffer.readu8(colorBuf, 3))
end

function bufferUtils.string.ReadUTF8(outPath)
	local stringPtr = outPath:readptr(0)

	local bytes = {}
	local i = 0
	while true do
		local b = stringPtr:readu8(i)
		if b == 0 then
			break
		end -- null terminator
		bytes[#bytes + 1] = string.char(b)
		i = i + 1
	end

	return table.concat(bytes)
end

function bufferUtils.string.ReadOSBased(outPath)
	if zune.platform.os == "windows" then
		return bufferUtils.string.ReadUTF16(outPath)
	else
		return bufferUtils.string.ReadUTF8(outPath)
	end
end

-- ffi types
local function makeType(t)
	return function(...)
		local args = { ... }

		if #args == 1 then
			return { type = t, value = args[1] }
		end

		return { type = t, value = args }
	end
end

bufferUtils.typei8 = makeType("i8")
bufferUtils.typeu8 = makeType("u8")
bufferUtils.typei16 = makeType("i16")
bufferUtils.typeu16 = makeType("u16")
bufferUtils.typei32 = makeType("i32")
bufferUtils.typebool = makeType("bool")
bufferUtils.typeu32 = makeType("u32")
bufferUtils.typei64 = makeType("i64")
bufferUtils.typeu64 = makeType("u64")
bufferUtils.typefloat = makeType("float")
bufferUtils.typedouble = makeType("double")
bufferUtils.typepointer = makeType("pointer")
bufferUtils.typevector2_32 = makeType("vector2_32")
bufferUtils.typevector3_32 = makeType("vector3_32")

bufferUtils.pointersize = ffi.types.pointer:size()

function bufferUtils.wrap(object: buffer | FFIPointer, template: FFIStructureType)
	local wrapper = {}
	local changed = {}

	local mt = {}

	function wrapper:getptr(field, struct)
		local offset = template:offset(field)

		local sliced = zune.mem.slice(object, offset, struct:size())
		if sliced then
			return bufferUtils.wrap(sliced, struct)
		end
		return
	end

	function wrapper:read(field, valueType)
		local offset = template:offset(field)
		if not offset then
			error("Invalid field: " .. tostring(field))
		end

		if type(object) == "buffer" then
			if valueType == "i8" then
				return buffer.readi8(object, offset)
			elseif valueType == "u8" then
				return buffer.readu8(object, offset)
			elseif valueType == "i16" then
				return buffer.readi16(object, offset)
			elseif valueType == "u16" then
				return buffer.readu16(object, offset)
			elseif valueType == "i32" then
				return buffer.readi32(object, offset)
			elseif valueType == "u32" then
				return buffer.readu32(object, offset)
			elseif valueType == "float" then
				return buffer.readf32(object, offset)
			elseif valueType == "double" then
				return buffer.readf64(object, offset)
			elseif valueType == "bool" then
				return buffer.readu8(object, offset) ~= 0
			elseif valueType == "vector2_32" then
				return {
					buffer.readf32(object, offset),
					buffer.readf32(object, offset + 4),
				}
			elseif valueType == "vector3_32" then
				return {
					buffer.readf32(object, offset),
					buffer.readf32(object, offset + 4),
					buffer.readf32(object, offset + 8),
				}
			elseif valueType == "pointer" then
				return zune.mem.slice(object, offset, 8) -- x64
			end
		elseif typeof(object) == "FFIPointer" then
			if valueType == "i8" then
				return object:readi8(offset)
			elseif valueType == "u8" then
				return object:readu8(offset)
			elseif valueType == "i16" then
				return object:readi16(offset)
			elseif valueType == "u16" then
				return object:readu16(offset)
			elseif valueType == "i32" then
				return object:readi32(offset)
			elseif valueType == "u32" then
				return object:readu32(offset)
			elseif valueType == "i64" then
				return object:readi64(offset)
			elseif valueType == "u64" then
				return object:readu64(offset)
			elseif valueType == "float" then
				return object:readf32(offset)
			elseif valueType == "double" then
				return object:readf64(offset)
			elseif valueType == "bool" then
				return object:readu8(offset) ~= 0
			elseif valueType == "vector2_32" then
				return {
					object:readf32(offset),
					object:readf32(offset + 4),
				}
			elseif valueType == "vector3_32" then
				return {
					object:readf32(offset),
					object:readf32(offset + 4),
					object:readf32(offset + 8),
				}
			elseif valueType == "pointer" then
				return object:readptr(offset)
			end
		end

		error("Unsupported type: " .. tostring(valueType))
	end

	function wrapper:getraw()
		return object
	end

	function mt.__index(_, key)
		return changed[key]
	end

	function mt.__newindex(_, key, value)
		-- detect write
		changed[key] = true

		if type(value) == "table" then
			if value.type then
				local valueType = value.type
				local offset = template:offset(key)
				local v = value.value

				if type(object) == "buffer" then
					if valueType == "i8" then
						buffer.writei8(object, offset, v)
					elseif valueType == "u8" then
						buffer.writeu8(object, offset, v)
					elseif valueType == "i16" then
						buffer.writei16(object, offset, v)
					elseif valueType == "u16" then
						buffer.writeu16(object, offset, v)
					elseif valueType == "i32" then
						buffer.writei32(object, offset, v)
					elseif valueType == "u32" then
						buffer.writeu32(object, offset, v)
					elseif valueType == "float" then
						buffer.writef32(object, offset, v)
					elseif valueType == "double" then
						buffer.writef64(object, offset, v)
					elseif valueType == "bool" then
						local n = v and 1 or 0
						buffer.writeu8(object, offset, n)
					elseif valueType == "pointer" then
						buffer.copy(object, offset, v)
					elseif valueType == "vector2_32" then
						buffer.writef32(object, offset, v[1])
						buffer.writef32(object, offset + 4, v[2])
					elseif valueType == "vector3_32" then
						buffer.writef32(object, offset, v[1])
						buffer.writef32(object, offset + 4, v[2])
						buffer.writef32(object, offset + 8, v[3])
					end
				elseif typeof(object) == "FFIPointer" then
					if valueType == "i8" then
						object:writei8(offset, v)
					elseif valueType == "u8" then
						object:writeu8(offset, v)
					elseif valueType == "i16" then
						object:writei16(offset, v)
					elseif valueType == "u16" then
						object:writeu16(offset, v)
					elseif valueType == "i32" then
						object:writei32(offset, v)
					elseif valueType == "u32" then
						object:writeu32(offset, v)
					elseif valueType == "i64" then
						object:writei64(offset, v)
					elseif valueType == "u64" then
						object:writeu64(offset, v)
					elseif valueType == "float" then
						object:writef32(offset, v)
					elseif valueType == "double" then
						object:writef64(offset, v)
					elseif valueType == "bool" then
						object:writeu8(offset, v and 1 or 0)
					elseif valueType == "pointer" then
						object:writeptr(offset, v)
					elseif valueType == "vector2_32" then
						object:writef32(offset, v[1])
						object:writef32(offset + 4, v[2])
					elseif valueType == "vector3_32" then
						object:writef32(offset, v[1])
						object:writef32(offset + 4, v[2])
						object:writef32(offset + 8, v[3])
					end
				end
			end
		end
	end

	return setmetatable(wrapper, mt)
end

-- Shader
function bufferUtils.SetShaderLoc(shader, locIndex, value)
	-- Read the locs int* pointer stored at offset 8 in the Shader struct
	-- shader is a buffer, so we need to get an FFIPointer to it first
	local shaderPtr = zune.ffi.dupe(shader)
	local locsPtr = shaderPtr:readptr(8) -- locs is at offset 8
	locsPtr:writei32(29 * 4, value)
end

-- Unsigned integers
function bufferUtils:u8(number)
	local buf = buffer.create(1)
	buffer.writeu8(buf, 0, number)
	return buf
end

function bufferUtils:u16(number)
	local buf = buffer.create(2)
	buffer.writeu16(buf, 0, number)
	return buf
end

function bufferUtils:u32(number)
	local buf = buffer.create(4)
	buffer.writeu32(buf, 0, number)
	return buf
end

-- Signed integers
function bufferUtils:i8(number)
	local buf = buffer.create(1)
	buffer.writei8(buf, 0, number)
	return buf
end

function bufferUtils:i16(number)
	local buf = buffer.create(2)
	buffer.writei16(buf, 0, number)
	return buf
end

function bufferUtils:i32(number)
	local buf = buffer.create(4)
	buffer.writei32(buf, 0, number)
	return buf
end

function bufferUtils:float(number)
	local buf = buffer.create(4)
	buffer.writef32(buf, 0, number)
	return buf
end

function bufferUtils:double(number)
	local buf = buffer.create(8)
	buffer.writef64(buf, 0, number)
	return buf
end

-- Vectors
function bufferUtils:vector2_32(x, y)
	local buf = buffer.create(8)
	buffer.writef32(buf, 0, x)
	buffer.writef32(buf, 4, y)
	return buf
end

function bufferUtils:vector3_32(x, y, z)
	local buf = buffer.create(12)
	buffer.writef32(buf, 0, x)
	buffer.writef32(buf, 4, y)
	buffer.writef32(buf, 8, z)
	return buf
end

function bufferUtils:readi32(ptr)
	return ptr:readi32(0)
end

function bufferUtils:readhexa(ptr)
	local v = tostring(ptr)

	local hex = v:match("0x[%da-fA-F]+")
	if not hex then
		return nil
	end

	return tonumber(hex, 16)
end

function bufferUtils:readString(ptr)
	if not ptr or ptr == zune.ffi.null then
		return nil
	end

	-- ptr is char** → read the actual char* inside
	local strPtr = ptr:readptr(0)
	if not strPtr or strPtr == zune.ffi.null then
		return nil
	end

	local len = zune.mem.findScalar(strPtr, 0)
	if not len then
		return nil
	end

	local buf = zune.mem.slice(strPtr, 0, len)
	return buffer.tostring(buf)
end

function bufferUtils:readMesh(ptr: FFIPointer)
	--[[
	local Mesh = ffi.struct({
	{ vertexCount = int }, -- 0
	{ triangleCount = int }, -- 4
	{ vertices = ffi.types.pointer },
	{ texcoords = ffi.types.pointer },
	{ texcoords2 = ffi.types.pointer },
	{ normals = ffi.types.pointer },
	{ tangents = ffi.types.pointer },
	{ colors = ffi.types.pointer },
	{ indices = ffi.types.pointer },
	{ animVertices = ffi.types.pointer },
	{ animNormals = ffi.types.pointer },
	{ boneIds = ffi.types.pointer },
	{ boneWeights = ffi.types.pointer },
	{ vaoId = uint },
	{ vboId = ffi.types.pointer },
})
export type Mesh = typeof(Mesh:new({}))
	--]]

	local mesh = {
		vertexCount = ptr:readi32(getOfs(structs.Mesh, "vertexCount")),
		triangleCount = ptr:readi32(getOfs(structs.Mesh, "triangleCount")),
		vertices = ptr:readptr(getOfs(structs.Mesh, "vertices")),
		texcoords = ptr:readptr(getOfs(structs.Mesh, "texcoords")),
		texcoords2 = ptr:readptr(getOfs(structs.Mesh, "texcoords2")),
		normals = ptr:readptr(getOfs(structs.Mesh, "normals")),
		tangents = ptr:readptr(getOfs(structs.Mesh, "tangents")),
		colors = ptr:readptr(getOfs(structs.Mesh, "colors")),
		indices = ptr:readptr(getOfs(structs.Mesh, "indices")),
		animVertices = ptr:readptr(getOfs(structs.Mesh, "animVertices")),
		animNormals = ptr:readptr(getOfs(structs.Mesh, "animNormals")),
		boneIds = ptr:readptr(getOfs(structs.Mesh, "boneIds")),
		boneWeights = ptr:readptr(getOfs(structs.Mesh, "boneWeights")),
		vaoId = ptr:readu32(getOfs(structs.Mesh, "vaoId")),
		vboId = ptr:readptr(getOfs(structs.Mesh, "vboId")),
	}

	return mesh
end

function bufferUtils:fcall(func, expected)
	local result = func()
	local read = bufferUtils:readhexa(result)
	if read ~= expected then
		error("Expected " .. expected .. " but got " .. read .. " in FFI call\nOriginal string " .. tostring(result))
	end
	return result
end

function bufferUtils.extract.pointer(ptr)
	return ptr:readptr(0)
end

function bufferUtils.extract.texture(v)
	local texture = zune.mem.slice(v, structs.RenderTexture:offset("texture"), structs.Texture:size())
	return texture
end

function bufferUtils.extract.depth(v)
	local depth = zune.mem.slice(v, structs.RenderTexture:offset("depth"), structs.Texture:size())
	return depth
end

function bufferUtils.extract.maps(model, texture)
	local materials = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("materials"), 8))

	local maps = materials:readptr(structs.Material:offset("maps"))
	return maps
end

function bufferUtils.extract.material_shader(mainstruct, v)
	local Shader = zune.mem.slice(v, mainstruct:offset("shader"), structs.Shader:size())

	return Shader
end

function bufferUtils.extract.box2d_body_position(object, mainstruct)
	local pos = zune.mem.slice(object, mainstruct:offset("position"), box2d_structs.b2Vec2:size())
	return pos
end

function bufferUtils.extract.mesh_from_model(object)
	local meshes_ptr = zune.ffi.ptrFromAddress(zune.mem.slice(object, structs.Model:offset("meshes"), 8))
	local mesh_0_buf = meshes_ptr:read(0, buffer.create(structs.Mesh:size()), 0, structs.Mesh:size())
	return mesh_0_buf
end

function bufferUtils.extract.set(object, value, struct)
	object:write(0, value, 0, struct:size())
end

function bufferUtils.extract.setModelTexture(maps, texture)
	maps:write(0, texture, 0, structs.Texture:size())
end

function bufferUtils.extract.MaterialMap(object, material)
	local mapsPtr = zune.ffi.ptrFromAddress(zune.mem.slice(object, structs.Material:offset("maps"), 8))
	return mapsPtr
end

function bufferUtils.setMaterialColor(material, color)
	local maps = bufferUtils.extract.MaterialMap(material, structs.Material)
	maps:write(structs.MaterialMap:offset("color"), color, 0, structs.Color:size())
	return maps
end

-- quaternions

function bufferUtils.EulerDegToQuaternion(euler: any): (number, number, number, number)
	local rx = math.rad(euler.X)
	local ry = math.rad(euler.Y)
	local rz = math.rad(euler.Z)

	local cx, sx = math.cos(rx * 0.5), math.sin(rx * 0.5)
	local cy, sy = math.cos(ry * 0.5), math.sin(ry * 0.5)
	local cz, sz = math.cos(rz * 0.5), math.sin(rz * 0.5)

	local w = cz * cy * cx + sz * sy * sx
	local x = cz * cy * sx - sz * sy * cx
	local y = cz * sy * cx + sz * cy * sx
	local z = sz * cy * cx - cz * sy * sx

	local len = math.sqrt(x * x + y * y + z * z + w * w)
	if len > 0 then
		x, y, z, w = x / len, y / len, z / len, w / len
	else
		x, y, z, w = 0, 0, 0, 1
	end

	return x, y, z, w
end

function bufferUtils.GetMeshIndexFromModel(model, index)
	local meshes_ptr = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("meshes"), 8))
	local mesh_0_buf = meshes_ptr:read(0, buffer.create(structs.Mesh:size()), 0, structs.Mesh:size())
	return mesh_0_buf
end

function bufferUtils.SetModelTex(model, tex)
	local materials = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("materials"), 8))
	local maps = materials:readptr(structs.Material:offset("maps"))
	maps:write(0, tex, 0, structs.Texture:size())
end

function bufferUtils.EulerToAxisAngle(eulerDeg)
	local qx, qy, qz, qw = bufferUtils.EulerDegToQuaternion(eulerDeg)

	qw = math.max(-1, math.min(1, qw))
	local angleRad = 2 * math.acos(qw)

	local s2 = 1 - qw * qw
	if s2 < 1e-12 then
		return vector.create(1, 0, 0), 0
	end

	local s = math.sqrt(s2)
	local ax, ay, az = qx / s, qy / s, qz / s

	local alen = math.sqrt(ax * ax + ay * ay + az * az)
	if alen == 0 then
		return vector.create(1, 0, 0), 0
	end
	ax, ay, az = ax / alen, ay / alen, az / alen

	return vector.create(ax, ay, az), math.deg(angleRad)
end

return bufferUtils
