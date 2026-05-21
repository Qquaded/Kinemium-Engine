local Serializer = {}
local serde = zune.serde

local TYPE_NUMBER = 1
local TYPE_BOOLEAN = 2
local TYPE_STRING = 3
local TYPE_TABLE = 4
local TYPE_BUFFER = 5
local TYPE_NIL = 6
local TYPE_CUSTOM = 7
local TYPE_INT = 8

local MAX_SAFE_INT = 2 ^ 53

local KNOWN_STRINGS = {
	"cframe",
	"position",
	"velocity",
	"objects",
	"entries",
	"updates",
	"object",
	"args",
	"kind",
	"timestamp",
	"sessionId",
	"messageId",
	"reliable",
	"type",
	"NetworkId",
	"ClassName",
	"Name",
	"Parent",
	"CFrame",
	"Vector3",
	"FireClient",
	"FireAllClients",
	"FireClients",
	"Color3",
	"BrickColor",
	"Material",
	"Transparency",
	"Reflectance",
	"Size",
	"SizeOffset",
	"Position",
	"Rotation",
	"Text",
	"TextColor3",
	"BackgroundColor3",
	"BackgroundTransparency",
	"Visible",
	"Enabled",
	"Value",
	"Anchored",
	"CanCollide",
	"Massless",
	"RootPriority",
	"State",
	"WalkSpeed",
	"JumpPower",
	"Health",
	"MaxHealth",
	"Color",
	"LightEmission",
	"LightInfluence",
	"Texture",
	"ZOffset",
	"Rate",
	"RotSpeed",
	"Speed",
	"SpreadAngle",
	"Acceleration",
	"EmissionDirection",
	"Lifetime",
	"id",
	"states",
	"tick",
	"baseTick",
	"lastProcessedOwnedStateSequence",
	"ownerNetId",
	"linear",
	"angular",
	"force",
	"target",
	"stance",
	"state",
	"sprinting",
	"crouching",
	"facingDir",
	"channel",
	"payload",
	"fragment",
	"fragmentIndex",
	"totalFragments",
	"reset",
	"chunks",
	"blobFingerprint",
	"netIds",
}
local KNOWN_STRING_TO_ID = {}
for i, str in ipairs(KNOWN_STRINGS) do
	KNOWN_STRING_TO_ID[str] = i
end
local TYPE_KNOWN_STRING = 9

-- configuration
Serializer.CompressionEnabled = true
Serializer.MaxDepth = 100

-- custom type registry
local customTypes = {}
local customTypesById = {}
local nextTypeId = 1

-- register a custom type handler
function Serializer.RegisterType(typeName, serializer, deserializer)
	if customTypes[typeName] then
		error("Type already registered: " .. typeName)
	end

	local typeId = nextTypeId
	nextTypeId = nextTypeId + 1

	local info = {
		id = typeId,
		name = typeName,
		serialize = serializer,
		deserialize = deserializer,
	}

	customTypes[typeName] = info
	customTypesById[typeId] = info

	return typeId
end

-- O(1) lookup by id
local function getCustomTypeById(id)
	local info = customTypesById[id]
	if info then
		return info.name, info
	end
	return nil
end

-- zigzag + 7-bit varint for integers up to 2^53
local function writeVarint(b, offset, value)
	local u
	if value < 0 then
		u = (-value - 1) * 2 + 1
	else
		u = value * 2
	end
	while u >= 128 do
		buffer.writeu8(b, offset, (u % 128) + 128)
		offset += 1
		u = math.floor(u / 128)
	end
	buffer.writeu8(b, offset, u)
	return offset + 1
end

local function readVarint(b, offset)
	local result = 0
	local shift = 1
	while true do
		local byteValue = buffer.readu8(b, offset)
		offset += 1
		if byteValue < 128 then
			result = result + byteValue * shift
			break
		else
			result = result + (byteValue - 128) * shift
			shift = shift * 128
		end
	end
	if result % 2 == 1 then
		return -((result + 1) / 2), offset
	else
		return result / 2, offset
	end
end

-- classify a number as an integer we can varint-encode
local function isCompactInt(value)
	return value == value -- not NaN
		and value > -MAX_SAFE_INT
		and value < MAX_SAFE_INT
		and value % 1 == 0
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
		if isCompactInt(value) then
			buffer.writeu8(b, offset, TYPE_INT)
			offset += 1
			offset = writeVarint(b, offset, value)
		else
			buffer.writeu8(b, offset, TYPE_NUMBER)
			offset += 1
			buffer.writef64(b, offset, value)
			offset += 8
		end
	elseif t == "boolean" then
		buffer.writeu8(b, offset, TYPE_BOOLEAN)
		offset += 1
		buffer.writeu8(b, offset, value and 1 or 0)
		offset += 1
	elseif t == "string" then
		local id = KNOWN_STRING_TO_ID[value]
		if id then
			buffer.writeu8(b, offset, TYPE_KNOWN_STRING)
			offset += 1
			buffer.writeu16(b, offset, id)
			offset += 2
		else
			buffer.writeu8(b, offset, TYPE_STRING)
			offset += 1
			local len = #value
			buffer.writeu32(b, offset, len)
			offset += 4
			buffer.writestring(b, offset, value)
			offset += len
		end
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
			-- backpatch the count after we've written all entries, so we
			-- only iterate the table once instead of twice.
			local countOffset = offset
			offset += 4

			local count = 0
			for k, v in pairs(value) do
				offset = writeValue(b, offset, k, depth + 1, seen)
				offset = writeValue(b, offset, v, depth + 1, seen)
				count += 1
			end
			buffer.writeu32(b, countOffset, count)

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
	elseif typeMarker == TYPE_INT then
		return readVarint(b, offset)
	elseif typeMarker == TYPE_NUMBER then
		local num = buffer.readf64(b, offset)
		offset += 8
		return num, offset
	elseif typeMarker == TYPE_BOOLEAN then
		local val = buffer.readu8(b, offset) ~= 0
		offset += 1
		return val, offset
	elseif typeMarker == TYPE_KNOWN_STRING then
		local id = buffer.readu16(b, offset)
		offset += 2
		local str = KNOWN_STRINGS[id]
		if not str then
			error("Unknown known string id: " .. tostring(id))
		end
		return str, offset
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
		-- worst case: tag (1) + 10 varint bytes, or tag (1) + 8 for f64.
		return 11
	elseif t == "boolean" then
		return 2
	elseif t == "string" then
		if KNOWN_STRING_TO_ID[value] then
			return 3 -- 1 byte type + 2 bytes ID
		else
			return 5 + #value
		end
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
	-- Use a growable buffer approach to avoid underestimation errors.
	-- Start with a reasonable default and double when needed.
	local capacity = math.max(4096, estimateSize(value))
	local b = buffer.create(capacity)
	local finalOffset

	-- writeValue may exceed our estimate for deeply nested structures or
	-- large embedded buffers.  Retry with a larger allocation on failure.
	local retries = 0
	while retries < 8 do
		local ok, result = pcall(writeValue, b, 0, value)
		if ok then
			finalOffset = result
			break
		end

		-- Buffer was too small  double the capacity and retry.
		retries += 1
		capacity = capacity * 2
		b = buffer.create(capacity)
	end

	if not finalOffset then
		error("Serializer.Serialize: failed to serialize after retries (payload too large or circular)")
	end

	-- trim buffer to actual size
	local trimmed = buffer.create(finalOffset)
	buffer.copy(trimmed, 0, b, 0, finalOffset)

	if Serializer.CompressionEnabled then
		return serde.zstd.compress(trimmed, {
			level = 3,
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
	customTypesById = {}
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
