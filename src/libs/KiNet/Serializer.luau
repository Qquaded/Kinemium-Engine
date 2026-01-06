local Serializer = {}
local serde = zune.serde

local TYPE_NUMBER = 1
local TYPE_BOOLEAN = 2
local TYPE_STRING = 3
local TYPE_TABLE = 4
local TYPE_BUFFER = 5
local TYPE_NIL = 6
local TYPE_CUSTOM = 7

-- configuration
Serializer.CompressionEnabled = true
Serializer.MaxDepth = 100

-- custom type registry
local customTypes = {}
local nextTypeId = 1

-- register a custom type handler
function Serializer.RegisterType(typeName, serializer, deserializer)
	if customTypes[typeName] then
		error("Type already registered: " .. typeName)
	end

	local typeId = nextTypeId
	nextTypeId = nextTypeId + 1

	customTypes[typeName] = {
		id = typeId,
		serialize = serializer,
		deserialize = deserializer,
	}

	return typeId
end

-- get custom type by id
local function getCustomTypeById(id)
	for name, info in pairs(customTypes) do
		if info.id == id then
			return name, info
		end
	end
	return nil
end

-- write value with depth tracking and circular reference detection
local function writeValue(b, offset, value, depth, seen)
	depth = depth or 0
	seen = seen or {}

	if depth > Serializer.MaxDepth then
		error("Max depth exceeded - possible circular reference")
	end

	local t = type(value)

	if t == "nil" then
		buffer.writeu8(b, offset, TYPE_NIL)
		offset += 1
	elseif t == "number" then
		buffer.writeu8(b, offset, TYPE_NUMBER)
		offset += 1
		buffer.writef64(b, offset, value)
		offset += 8
	elseif t == "boolean" then
		buffer.writeu8(b, offset, TYPE_BOOLEAN)
		offset += 1
		buffer.writeu8(b, offset, value and 1 or 0)
		offset += 1
	elseif t == "string" then
		buffer.writeu8(b, offset, TYPE_STRING)
		offset += 1
		local len = #value
		buffer.writeu32(b, offset, len)
		offset += 4
		buffer.writestring(b, offset, value)
		offset += len
	elseif t == "table" then
		-- check if table is circularly referenced first
		if seen[value] then
			error("Circular reference detected")
		end

		-- check if this is a custom type
		local customTypeName = value.__type
		if customTypeName and customTypes[customTypeName] then
			local typeInfo = customTypes[customTypeName]
			buffer.writeu8(b, offset, TYPE_CUSTOM)
			offset += 1
			buffer.writeu32(b, offset, typeInfo.id)
			offset += 4

			-- serialize using custom handler
			local serialized = typeInfo.serialize(value)
			local len = #serialized
			buffer.writeu32(b, offset, len)
			offset += 4
			buffer.writestring(b, offset, serialized)
			offset += len
		else
			-- regular table - mark as seen for nested tables
			seen[value] = true

			buffer.writeu8(b, offset, TYPE_TABLE)
			offset += 1
			local count = 0
			for _ in pairs(value) do
				count += 1
			end
			buffer.writeu32(b, offset, count)
			offset += 4

			-- recursively serialize keys and values
			-- this will automatically detect and handle custom types in nested tables
			for k, v in pairs(value) do
				offset = writeValue(b, offset, k, depth + 1, seen)
				offset = writeValue(b, offset, v, depth + 1, seen)
			end

			seen[value] = nil
		end
	elseif t == "userdata" then
		buffer.writeu8(b, offset, TYPE_BUFFER)
		offset += 1
		local len = buffer.len(value)
		buffer.writeu32(b, offset, len)
		offset += 4
		buffer.copy(b, offset, value, 0, len)
		offset += len
	elseif t == "buffer" then
		buffer.writeu8(b, offset, TYPE_BUFFER)
		offset += 1
		local len = buffer.len(value)
		buffer.writeu32(b, offset, len)
		offset += 4
		buffer.copy(b, offset, value, 0, len)
		offset += len
	else
		error("Unsupported type: " .. t)
	end
	return offset
end

-- read value using buffer module functions
local function readValue(b, offset)
	local typeMarker = buffer.readu8(b, offset)
	offset += 1

	if typeMarker == TYPE_NIL then
		return nil, offset
	elseif typeMarker == TYPE_NUMBER then
		local num = buffer.readf64(b, offset)
		offset += 8
		return num, offset
	elseif typeMarker == TYPE_BOOLEAN then
		local val = buffer.readu8(b, offset) ~= 0
		offset += 1
		return val, offset
	elseif typeMarker == TYPE_STRING then
		local len = buffer.readu32(b, offset)
		offset += 4
		local str = buffer.readstring(b, offset, len)
		offset += len
		return str, offset
	elseif typeMarker == TYPE_TABLE then
		local count = buffer.readu32(b, offset)
		offset += 4
		local tbl = {}
		for _ = 1, count do
			local key
			key, offset = readValue(b, offset)
			local val
			val, offset = readValue(b, offset)
			tbl[key] = val
		end
		return tbl, offset
	elseif typeMarker == TYPE_BUFFER then
		local len = buffer.readu32(b, offset)
		offset += 4
		local buf = buffer.create(len)
		buffer.copy(buf, 0, b, offset, len)
		offset += len
		return buf, offset
	elseif typeMarker == TYPE_CUSTOM then
		local typeId = buffer.readu32(b, offset)
		offset += 4
		local len = buffer.readu32(b, offset)
		offset += 4
		local serialized = buffer.readstring(b, offset, len)
		offset += len

		local typeName, typeInfo = getCustomTypeById(typeId)
		if not typeInfo then
			error("Unknown custom type id: " .. tostring(typeId))
		end

		local value = typeInfo.deserialize(serialized)
		return value, offset
	else
		error("Unknown type marker: " .. tostring(typeMarker))
	end
end

-- estimate buffer size needed
local function estimateSize(value, depth)
	depth = depth or 0
	if depth > Serializer.MaxDepth then
		return 1
	end

	local t = type(value)
	if t == "nil" then
		return 1
	elseif t == "number" then
		return 9
	elseif t == "boolean" then
		return 2
	elseif t == "string" then
		return 5 + #value
	elseif t == "table" then
		local customTypeName = value.__type
		if customTypeName and customTypes[customTypeName] then
			local typeInfo = customTypes[customTypeName]
			local serialized = typeInfo.serialize(value)
			return 9 + #serialized
		else
			local size = 5
			for k, v in pairs(value) do
				size = size + estimateSize(k, depth + 1) + estimateSize(v, depth + 1)
			end
			return size
		end
	elseif t == "userdata" then
		return 5 + buffer.len(value)
	elseif t == "buffer" then
		return 5 + buffer.len(value)
	else
		return 1
	end
end

-- public functions
function Serializer.Serialize(value)
	local size = math.max(4096, estimateSize(value) * 2)
	local b = buffer.create(size)
	local finalOffset = writeValue(b, 0, value)

	-- trim buffer to actual size
	local trimmed = buffer.create(finalOffset)
	buffer.copy(trimmed, 0, b, 0, finalOffset)

	if Serializer.CompressionEnabled then
		return serde.zstd.compress(trimmed, {
			level = 9,
		})
	else
		return trimmed
	end
end

function Serializer.Deserialize(b)
	local decompressed
	if Serializer.CompressionEnabled then
		decompressed = serde.zstd.decompress(b)
	else
		decompressed = b
	end
	local value, _ = readValue(decompressed, 0)
	return value
end

-- utility function to clear all registered types
function Serializer.ClearTypes()
	customTypes = {}
	nextTypeId = 1
end

-- utility function to get all registered types
function Serializer.GetRegisteredTypes()
	local types = {}
	for name, info in pairs(customTypes) do
		types[name] = info.id
	end
	return types
end

return Serializer
