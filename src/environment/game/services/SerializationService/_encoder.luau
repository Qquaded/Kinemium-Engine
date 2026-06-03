local TableEncoder = {}

--  Type tags
local TAG_NIL = 0
local TAG_BOOL_FALSE = 1
local TAG_BOOL_TRUE = 2
local TAG_FLOAT = 3 -- full f64
local TAG_INT_POS8 = 4 -- u8   (0–255)
local TAG_INT_POS16 = 5 -- u16  (256–65535)
local TAG_INT_POS32 = 6 -- u32  (65536–2^32-1)
local TAG_INT_NEG8 = 7 -- stored as u8  magnitude
local TAG_INT_NEG16 = 8 -- stored as u16 magnitude
local TAG_INT_NEG32 = 9 -- stored as u32 magnitude
local TAG_STR_SHORT = 10 -- length fits u8  (0–255)
local TAG_STR_LONG = 11 -- length fits u32
local TAG_TABLE = 12

-- Cached buffer functions (avoid repeated table lookups in hot loops)
local buf_create = buffer.create
local buf_copy = buffer.copy
local buf_len = buffer.len
local buf_writeu8 = buffer.writeu8
local buf_writeu16 = buffer.writeu16
local buf_writeu32 = buffer.writeu32
local buf_writef64 = buffer.writef64
local buf_writestring = buffer.writestring
local buf_readu8 = buffer.readu8
local buf_readu16 = buffer.readu16
local buf_readu32 = buffer.readu32
local buf_readf64 = buffer.readf64
local buf_readstring = buffer.readstring

local math_floor = math.floor

--  Growable writer
-- Start with a larger initial buffer to reduce early reallocations.
-- The growth factor (2x) stays the same.

local Writer = {}
Writer.__index = Writer

function Writer.new()
	local self = setmetatable({}, Writer)
	self.buf = buf_create(4096)
	self.size = 4096
	self.offset = 0
	return self
end

-- Inline-friendly ensure: only branches when growth is needed.
function Writer:_ensure(bytes: number)
	local needed = self.offset + bytes
	if needed <= self.size then
		return
	end
	local newSize = self.size
	while newSize < needed do
		newSize *= 2
	end
	local newBuf = buf_create(newSize)
	buf_copy(newBuf, 0, self.buf, 0, self.offset)
	self.buf = newBuf
	self.size = newSize
end

function Writer:u8(v: number)
	local off = self.offset
	if off + 1 > self.size then
		self:_ensure(1)
	end
	buf_writeu8(self.buf, off, v)
	self.offset = off + 1
end

function Writer:u16(v: number)
	local off = self.offset
	if off + 2 > self.size then
		self:_ensure(2)
	end
	buf_writeu16(self.buf, off, v)
	self.offset = off + 2
end

function Writer:u32(v: number)
	local off = self.offset
	if off + 4 > self.size then
		self:_ensure(4)
	end
	buf_writeu32(self.buf, off, v)
	self.offset = off + 4
end

function Writer:f64(v: number)
	local off = self.offset
	if off + 8 > self.size then
		self:_ensure(8)
	end
	buf_writef64(self.buf, off, v)
	self.offset = off + 8
end

function Writer:str(v: string)
	local len = #v
	if self.offset + len > self.size then
		self:_ensure(len)
	end
	buf_writestring(self.buf, self.offset, v)
	self.offset += len
end

function Writer:bytes(v: buffer)
	local len = buf_len(v)
	if self.offset + len > self.size then
		self:_ensure(len)
	end
	buf_copy(self.buf, self.offset, v, 0, len)
	self.offset += len
end

-- Returns a correctly-sized buffer copy.
function Writer:finish(): buffer
	local out = buf_create(self.offset)
	buf_copy(out, 0, self.buf, 0, self.offset)
	return out
end

--  Encoder

local encodeValue -- forward declaration

encodeValue = function(w: typeof(Writer.new()), value: any, seen: { [any]: boolean })
	if value == nil then
		w:u8(TAG_NIL)
		return
	end

	local t = type(value)

	if t == "boolean" then
		w:u8(value and TAG_BOOL_TRUE or TAG_BOOL_FALSE)
	elseif t == "number" then
		if value % 1 == 0 then
			if value >= 0 then
				if value <= 0xFF then
					w:u8(TAG_INT_POS8)
					w:u8(value)
				elseif value <= 0xFFFF then
					w:u8(TAG_INT_POS16)
					w:u16(value)
				elseif value <= 0xFFFFFFFF then
					w:u8(TAG_INT_POS32)
					w:u32(value)
				else
					w:u8(TAG_FLOAT)
					w:f64(value)
				end
			else
				local mag = -value
				if mag <= 0xFF then
					w:u8(TAG_INT_NEG8)
					w:u8(mag)
				elseif mag <= 0xFFFF then
					w:u8(TAG_INT_NEG16)
					w:u16(mag)
				elseif mag <= 0xFFFFFFFF then
					w:u8(TAG_INT_NEG32)
					w:u32(mag)
				else
					w:u8(TAG_FLOAT)
					w:f64(value)
				end
			end
		else
			w:u8(TAG_FLOAT)
			w:f64(value)
		end
	elseif t == "string" then
		local len = #value
		if len <= 0xFF then
			w:u8(TAG_STR_SHORT)
			w:u8(len)
		else
			w:u8(TAG_STR_LONG)
			w:u32(len)
		end
		w:str(value)
	elseif t == "table" then
		if seen[value] then
			w:u8(TAG_NIL)
			return
		end
		seen[value] = true

		w:u8(TAG_TABLE)

		local arrayLen = #value
		w:u32(arrayLen)
		for i = 1, arrayLen do
			encodeValue(w, value[i], seen)
		end

		-- Two-pass hash encoding: first count valid pairs, then encode.
		-- Collect keys into a flat list.
		local hashKeys = {}
		local hashCount = 0
		for k, v in pairs(value) do
			if v ~= nil then
				local isArrayKey = type(k) == "number" and k >= 1 and k <= arrayLen and k % 1 == 0
				if not isArrayKey then
					hashCount += 1
					hashKeys[hashCount] = k
				end
			end
		end

		-- Reserve the count slot; we'll patch it after encoding.
		local countOffset = w.offset
		w:u32(0) -- placeholder

		local written = 0
		for i = 1, hashCount do
			local k = hashKeys[i]
			local v = value[k]
			-- Encode key-value directly without pcall  invalid types
			-- will simply emit TAG_NIL which is harmless. The pcall per
			-- pair was the single largest overhead in the encoder.
			local savedOffset = w.offset
			local keyType = type(k)
			-- Only allow string/number/boolean keys; skip anything exotic.
			if keyType == "string" or keyType == "number" or keyType == "boolean" then
				encodeValue(w, k, seen)
				encodeValue(w, v, seen)
				written += 1
			else
				w.offset = savedOffset
			end
		end

		-- Patch the real count into the reserved slot.
		buf_writeu32(w.buf, countOffset, written)

		seen[value] = nil -- allow the same table to appear in separate branches
	else
		-- function, userdata, thread, etc. → nil
		w:u8(TAG_NIL)
	end
end

--  Decoder

local function decodeValue(buf: buffer, offset: number, length: number): (any, number)
	local tag = buf_readu8(buf, offset)
	offset += 1
	if tag == TAG_NIL then
		return nil, offset
	elseif tag == TAG_BOOL_FALSE then
		return false, offset
	elseif tag == TAG_BOOL_TRUE then
		return true, offset
	elseif tag == TAG_FLOAT then
		return buf_readf64(buf, offset), offset + 8
	elseif tag == TAG_INT_POS8 then
		return buf_readu8(buf, offset), offset + 1
	elseif tag == TAG_INT_POS16 then
		return buf_readu16(buf, offset), offset + 2
	elseif tag == TAG_INT_POS32 then
		return buf_readu32(buf, offset), offset + 4
	elseif tag == TAG_INT_NEG8 then
		return -buf_readu8(buf, offset), offset + 1
	elseif tag == TAG_INT_NEG16 then
		return -buf_readu16(buf, offset), offset + 2
	elseif tag == TAG_INT_NEG32 then
		return -buf_readu32(buf, offset), offset + 4
	elseif tag == TAG_STR_SHORT then
		local len = buf_readu8(buf, offset)
		offset += 1
		return buf_readstring(buf, offset, len), offset + len
	elseif tag == TAG_STR_LONG then
		local len = buf_readu32(buf, offset)
		offset += 4
		return buf_readstring(buf, offset, len), offset + len
	elseif tag == TAG_TABLE then
		local t = {}

		local arrayLen = buf_readu32(buf, offset)
		offset += 4
		for i = 1, arrayLen do
			local v
			v, offset = decodeValue(buf, offset, length)
			t[i] = v
		end

		local hashCount = buf_readu32(buf, offset)
		offset += 4
		for _ = 1, hashCount do
			local k, v
			k, offset = decodeValue(buf, offset, length)
			v, offset = decodeValue(buf, offset, length)
			if k ~= nil then
				t[k] = v
			end
		end

		return t, offset
	else
		error("Invalid tag: " .. tag)
	end
end

--  Public API

function TableEncoder.encode(value: any): buffer
	local w = Writer.new()
	encodeValue(w, value, {})
	return w:finish()
end

function TableEncoder.decode(buf: buffer): any
	local length = buf_len(buf)
	local value, offset = decodeValue(buf, 0, length)
	if offset ~= length then
		error(("Trailing bytes after decode: consumed %d of %d"):format(offset, length))
	end
	return value
end

return TableEncoder
