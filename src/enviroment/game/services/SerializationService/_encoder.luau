local TableEncoder = {}

-- Type tags for serialization
local TAG_NIL = 0
local TAG_BOOL = 1
local TAG_NUMBER = 2
local TAG_STRING = 3
local TAG_TABLE = 4

-- Encode a value into a buffer
local function encodeValue(buf: buffer, offset: number, value: any): number
	local t = typeof(value)

	if value == nil then
		buffer.writeu8(buf, offset, TAG_NIL)
		return offset + 1
	elseif t == "boolean" then
		buffer.writeu8(buf, offset, TAG_BOOL)
		buffer.writeu8(buf, offset + 1, value and 1 or 0)
		return offset + 2
	elseif t == "number" then
		buffer.writeu8(buf, offset, TAG_NUMBER)
		buffer.writef64(buf, offset + 1, value)
		return offset + 9
	elseif t == "string" then
		buffer.writeu8(buf, offset, TAG_STRING)
		local len = #value
		buffer.writeu32(buf, offset + 1, len)
		buffer.writestring(buf, offset + 5, value)
		return offset + 5 + len
	elseif t == "table" then
		buffer.writeu8(buf, offset, TAG_TABLE)
		offset = offset + 1

		-- Write array part
		local arrayLen = #value
		buffer.writeu32(buf, offset, arrayLen)
		offset = offset + 4

		for i = 1, arrayLen do
			offset = encodeValue(buf, offset, value[i])
		end

		-- Count hash part (non-array keys)
		local hashCount = 0
		for k in pairs(value) do
			if type(k) ~= "number" or k < 1 or k > arrayLen or k % 1 ~= 0 then
				hashCount += 1
			end
		end

		-- Write hash part
		buffer.writeu32(buf, offset, hashCount)
		offset = offset + 4

		for k, v in pairs(value) do
			if type(k) ~= "number" or k < 1 or k > arrayLen or k % 1 ~= 0 then
				offset = encodeValue(buf, offset, k)
				offset = encodeValue(buf, offset, v)
			end
		end

		return offset
	else
		error("Unsupported type: " .. t)
	end
end

-- Decode a value from a buffer
local function decodeValue(buf: buffer, offset: number): (any, number)
	local tag = buffer.readu8(buf, offset)
	offset = offset + 1

	if tag == TAG_NIL then
		return nil, offset
	elseif tag == TAG_BOOL then
		local val = buffer.readu8(buf, offset) == 1
		return val, offset + 1
	elseif tag == TAG_NUMBER then
		local val = buffer.readf64(buf, offset)
		return val, offset + 8
	elseif tag == TAG_STRING then
		local len = buffer.readu32(buf, offset)
		offset = offset + 4
		local val = buffer.readstring(buf, offset, len)
		return val, offset + len
	elseif tag == TAG_TABLE then
		local t = {}

		-- Read array part
		local arrayLen = buffer.readu32(buf, offset)
		offset = offset + 4

		for i = 1, arrayLen do
			local val
			val, offset = decodeValue(buf, offset)
			t[i] = val
		end

		-- Read hash part
		local hashCount = buffer.readu32(buf, offset)
		offset = offset + 4

		for _ = 1, hashCount do
			local k, v
			k, offset = decodeValue(buf, offset)
			v, offset = decodeValue(buf, offset)
			t[k] = v
		end

		return t, offset
	else
		error("Invalid tag: " .. tag)
	end
end

local function calculateSize(value: any): number
	local t = typeof(value)

	if value == nil then
		return 1
	elseif t == "boolean" then
		return 2
	elseif t == "number" then
		return 9
	elseif t == "string" then
		return 5 + #value
	elseif t == "table" then
		local size = 1 + 4 -- tag + array length

		local arrayLen = #value
		for i = 1, arrayLen do
			size += calculateSize(value[i])
		end

		local hashCount = 0
		local hashSize = 0
		for k, v in pairs(value) do
			if type(k) ~= "number" or k < 1 or k > arrayLen or k % 1 ~= 0 then
				hashCount += 1
				hashSize += calculateSize(k) + calculateSize(v)
			end
		end

		size += 4 + hashSize -- hash count + hash data
		return size
	else
		error("Unsupported type: " .. t)
	end
end

function TableEncoder.encode(value: any): buffer
	local size = calculateSize(value)
	local buf = buffer.create(size)
	encodeValue(buf, 0, value)
	return buf
end

function TableEncoder.decode(buf: buffer): any
	local value, _ = decodeValue(buf, 0)
	return value
end

return TableEncoder
