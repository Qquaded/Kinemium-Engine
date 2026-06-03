--!strict
--!native
--!optimize 2

-- https://github.com/RiskoZoSlovenska/llz4/blob/4527c372c90e77c20d237e3cf0af84e13b060598/llz4.luau
-- modified by Sythivo

--[[
MIT License

Copyright (c) 2025 RiskoZoSlovenska

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local band, lshift, rshift = bit32.band, bit32.lshift, bit32.rshift

local MIN_MATCH = 4 -- A sequence is 3 bytes, so it has to encode at least 4 to have any use
local MIN_LENGTH = 13
local MIN_TRAILING_LITERALS = 5
local MISS_COUNTER_BITS = 6 -- Lower values = the step is incremented sooner
local HASH_SHIFT = 32 - 16  -- 32 - # of bits in the hash
local MAX_DISTANCE = 0xFFFF -- Maximum offset that can fit into two bytes

local COMPRESSION_GROWTH = 1 + 1/255 -- Asymptotic growth ratio of incompressible data
local BUFFER_SIZE_PADDING = 16
local DEFAULT_BUFFER_SIZE = 512 * 1024^1 -- 512 KiB
local DEFAULT_MAX_BUFFER_SIZE = 2^31 -- BIG

local LIT_COUNT_BITS = 4
local LIT_COUNT_MASK = lshift(1, LIT_COUNT_BITS) - 1
local MATCH_LEN_BITS = 4
local MATCH_LEN_MASK = lshift(1, MATCH_LEN_BITS) - 1


local function checkType(value, typ, argNum, funcName: string?)
	local actual = typeof(value)
	assert(actual == typ, `bad argument #{argNum} to '{funcName}' ({typ} expected, got {actual})`)
end

local function checkData(data, dataStart, dataLen, funcName: string?)
	checkType(data, "buffer", 1, funcName)
	checkType(dataStart, "number", 2, funcName)
	checkType(dataLen, "number", 3, funcName)
	assert(dataStart >= 0, "dataStart cannot be negative")
	assert(dataLen >= 0, "dataLen cannot be negative")
	assert(dataStart + dataLen <= buffer.len(data), "data range not in buffer")
end

local function checkAcceleration(acceleration: number?, argNum, funcName)
	acceleration = acceleration or 1
	checkType(acceleration, "number", argNum, funcName)
	assert(acceleration >= 1 and (acceleration :: number) % 1 == 0, "acceleration must be an integer >= 1")
	return acceleration
end

--[[=
	Compresses a portion of a buffer using the LZ4 block format.

	@param buffer data The buffer containing the data to compress.
	@param number dataStart The offset at which the data to compress starts.
	@param number dataLen The length, in bytes, of the data to compress.
	@param number? acceleration A positive integer, defaults to 1. Higher values
	  may increase the compression speed, especially on incompressible data, at
	  the cost of compression efficiency.

	@return buffer A buffer containing the compressed data at offset 0.
	@return number The length of the compressed data.
]]
local function compressBuffer(data, dataStart, dataLen, acceleration: number?)
	checkData(data, dataStart, dataLen, "compressBuffer")
	acceleration = checkAcceleration(acceleration, 4, "compressBuffer")

	local hashTable = {}
	local out, outNext = buffer.create(math.ceil(dataLen * COMPRESSION_GROWTH) + BUFFER_SIZE_PADDING), 0

	local pos = dataStart -- 0-indexed
	local nextUnencodedPos = pos -- Sometimes called the "anchor" in other implementations

	if dataLen >= MIN_LENGTH then
		-- The lower MISS_COUNTER_BITS bits are the miss counter, upper bits are the step. The step
		-- starts at `acceleration` and increments every time the miss counter overflows.
		local stepAndMissCounterInit = lshift(acceleration :: number, MISS_COUNTER_BITS)
		local stepAndMissCounter = stepAndMissCounterInit

		while pos + MIN_MATCH < dataLen - MIN_TRAILING_LITERALS do
			local sequence = buffer.readu32(data, pos)
			local hash = rshift(sequence * 2654435761, HASH_SHIFT)
			-- ^ This is awfully simple for a hash function, but it's fast and seems to give pretty good results. The
			-- magic constant was taken from https://github.com/lz4/lz4/blob/836decd8a898475dcd21ed46768157f4420c9dd2/lib/lz4.c#L782

			-- Check and update match
			local matchPos = hashTable[hash]
			hashTable[hash] = pos

			-- Determine if there is a match in range
			if not matchPos or pos - matchPos > MAX_DISTANCE or buffer.readu32(data, matchPos) ~= sequence then
				pos = pos + rshift(stepAndMissCounter, MISS_COUNTER_BITS) -- Extract and add the step part
				stepAndMissCounter = stepAndMissCounter + 1
				continue
			end

			stepAndMissCounter = stepAndMissCounterInit

			-- Calculate literal count and offset
			local literalCount = pos - nextUnencodedPos
			local matchOffset = pos - matchPos

			-- Try to extend backwards
			while literalCount > 0 and matchPos > 0 and buffer.readu8(data, pos - 1) == buffer.readu8(data, matchPos - 1) do
				literalCount = literalCount - 1
				pos = pos - 1
				matchPos = matchPos - 1
			end

			-- Skip the 4 bytes we already matched
			pos = pos + MIN_MATCH
			matchPos = matchPos + MIN_MATCH

			-- Determine match length
			-- NOTE: matchLength does not include minMatch; it is added during decoding
			local matchLength = pos
			while pos < dataLen - MIN_TRAILING_LITERALS and buffer.readu8(data, pos) == buffer.readu8(data, matchPos) do
				pos = pos + 1
				matchPos = matchPos + 1
			end
			matchLength = pos - matchLength

			-- Write token
			local literalCountHalf = (literalCount < LIT_COUNT_MASK) and literalCount or LIT_COUNT_MASK
			local matchLenHalf = (matchLength < MATCH_LEN_MASK) and matchLength or MATCH_LEN_MASK
			local token = lshift(literalCountHalf, MATCH_LEN_BITS) + matchLenHalf
			buffer.writeu8(out, outNext, token)
			outNext = outNext + 1

			-- Write literal count
			local remaining = literalCount - LIT_COUNT_MASK
			while remaining >= 0xFF do
				buffer.writeu8(out, outNext, 0xFF)
				outNext = outNext + 1
				remaining = remaining - 0xFF
			end
			if remaining >= 0 then
				buffer.writeu8(out, outNext, remaining)
				outNext = outNext + 1
			end

			-- Write literals
			buffer.copy(out, outNext, data, nextUnencodedPos, literalCount)
			outNext = outNext + literalCount

			-- Write offset (little-endian)
			buffer.writeu16(out, outNext, matchOffset)
			outNext = outNext + 2

			-- Write match length
			remaining = matchLength - MATCH_LEN_MASK
			while remaining >= 0xFF do
				buffer.writeu8(out, outNext, 0xFF)
				outNext = outNext + 1
				remaining = remaining - 0xFF
			end
			if remaining >= 0 then
				buffer.writeu8(out, outNext, remaining)
				outNext = outNext + 1
			end

			-- Move the anchor
			nextUnencodedPos = pos
		end
	end

	-- Write remaining token (only literals, match length is 0)
	local literalCount = dataLen - nextUnencodedPos
	local token = lshift((literalCount < LIT_COUNT_MASK) and literalCount or LIT_COUNT_MASK, MATCH_LEN_BITS)
	buffer.writeu8(out, outNext, token)
	outNext = outNext + 1

	-- Write remaining literal count
	local remaining = literalCount - LIT_COUNT_MASK
	while remaining >= 0xFF do
		buffer.writeu8(out, outNext, 0xFF)
		outNext = outNext + 1
		remaining = remaining - 0xFF
	end
	if remaining >= 0 then
		buffer.writeu8(out, outNext, remaining)
		outNext = outNext + 1
	end

	-- Write remaining literals
	buffer.copy(out, outNext, data, nextUnencodedPos)
	outNext = outNext + (dataLen - nextUnencodedPos)

	return out, outNext
end

--[[=
	Compresses a string using the LZ4 block format.

	@param string data The string to compress.
	@param number? acceleration A positive integer, defaults to 1. Higher values
	  may increase the compression speed, especially on incompressible data, at
	  the cost of compression efficiency.
	@return string The compressed data as a string.
]]
local function compressString(str: string, acceleration: number?)
	checkType(str, "string", 1, "compressString")
	acceleration = checkAcceleration(acceleration, 2, "compressString")

	local buf, len = compressBuffer(buffer.fromstring(str), 0, #str, acceleration)
	return buffer.readstring(buf, 0, len)
end


local function expandBuffer(out, maxLen): (buffer?, string | number)
	local curLen = buffer.len(out)
	if curLen >= maxLen then
		return nil, "maximum decompressed length was exceeded"
	end
	local newLen = math.min(maxLen, curLen * 2)
	local newOut = buffer.create(newLen)
	buffer.copy(newOut, 0, out)
	return newOut, newLen
end

--[[=
	Decompresses a portion of a buffer that was compressed using the LZ4 block
	format. If any issue is encountered during decompression, this function will
	throw an error; call via `pcall()` when processing untrusted input.

	@param buffer data The buffer which contains the compressed data.
	@param number dataStart The offset at which the compressed data starts.
	@param number dataLen The length, in bytes, of the compressed data.
	@param number? decompressedLen If positive, gives the exact size of the
	  output buffer; an error will be thrown if the decompressed data doesn't
	  fit into the buffer. If negative, the output buffer will be dynamically
	  resized up to the argument's absolute value; an error will be thrown if
	  the decompressed data doesn't fit into the specified size. If omitted, the
	  output buffer will be dynamically resized with no upper bound.

	@return buffer A buffer containing the decompressed data at offset 0.
	@return number The length of the decompressed data.
]]
local function decompressBuffer(data, dataStart, dataLen, decompressedLen: number?)
	checkData(data, dataStart, dataLen)
	decompressedLen = decompressedLen or -DEFAULT_MAX_BUFFER_SIZE
	checkType(decompressedLen, "number", 4, "decompressBuffer")

	local maxLen = math.abs(decompressedLen :: number)
	local outLen: number = if (decompressedLen >= 0) then decompressedLen :: number else DEFAULT_BUFFER_SIZE
	local out, outNext = buffer.create(outLen), 0

	local pos = 0 -- 0-indexed
	while pos < dataLen do
		local token = buffer.readu8(data, pos)
		pos = pos + 1

		-- Literals --
		local literalCount = rshift(token, MATCH_LEN_BITS)

		-- Read literal count
		if literalCount == LIT_COUNT_MASK then
			repeat
				local lenPart = buffer.readu8(data, pos)
				pos = pos + 1
				literalCount = literalCount + lenPart
			until lenPart < 0xFF
		end

		while outNext + literalCount > outLen do
			local res, len = expandBuffer(out, maxLen)
			if not res then
				error(len)
			end
			out, outLen = res, len :: any
		end

		-- Copy literals (if any)
		buffer.copy(out, outNext, data, pos, literalCount)
		outNext = outNext + literalCount
		pos = pos + literalCount

		if pos >= dataLen then
			break -- This was the last sequence (which has no match part)
		end

		-- Match --
		local matchLength = band(token, MATCH_LEN_MASK)
		local matchOffset = buffer.readu16(data, pos)
		pos = pos + 2

		-- Read match length
		if matchLength == MATCH_LEN_MASK then
			repeat
				local lenPart = buffer.readu8(data, pos)
				pos = pos + 1
				matchLength = matchLength + lenPart
			until lenPart < 0xFF
		end

		matchLength = matchLength + MIN_MATCH

		while outNext + matchLength > outLen do
			local res, len = expandBuffer(out, maxLen)
			if not res then
				error(len)
			end
			out, outLen = res, len :: any
		end

		-- Copy match
		while matchLength > matchOffset do
			buffer.copy(out, outNext, out, outNext - matchOffset, matchOffset)
			outNext = outNext + matchOffset
			matchLength = matchLength - matchOffset
		end

		buffer.copy(out, outNext, out, outNext - matchOffset, matchLength)
		outNext = outNext + matchLength
	end

	return out, outNext
end

--[[=
	Decompresses a string that was compressed using the LZ4 block format,
	optionally specifying a maximum decompressed length. If any issue is
	encountered during decompression, this function will throw an error; call
	via `pcall()` when processing untrusted input.

	@param string data The string to decompress.
	@param number? decompressedLen If positive, gives the exact size of the
	  output buffer; an error will be thrown if the decompressed data doesn't
	  fit into the buffer. If negative, the output buffer will be dynamically
	  resized up to the argument's absolute value; an error will be thrown if
	  the decompressed data doesn't fit into the specified size. If omitted, the
	  output buffer will be dynamically resized with no upper bound.
	@return string The decompressed string.
]]
local function decompressString(str, decompressedLen)
	checkType(str, "string", 1, "decompressString")
	decompressedLen = decompressedLen or -DEFAULT_MAX_BUFFER_SIZE
	checkType(decompressedLen, "number", 4, "decompressBuffer")

	local buf, len = decompressBuffer(buffer.fromstring(str), 0, #str)
	return buffer.readstring(buf, 0, len)
end

return {
    compress = function(src: buffer | string): buffer | string
        local isBuffer = type(src) == "buffer";
        local compressed = compressString(if (isBuffer) then buffer.tostring(src::buffer) else src::string);
        if (isBuffer) then
            return buffer.fromstring(compressed)
        end
        return compressed
    end::any,
    decompress = function(src: buffer | string, len: number): buffer | string
        local isBuffer = type(src) == "buffer";
        local decompressed = decompressString(if (isBuffer) then buffer.tostring(src::buffer) else src::string, len);
        if (isBuffer) then
            return buffer.fromstring(decompressed)
        end
        return decompressed
    end::any,
    compressFrame = function(...)
        error("Not implemented")
    end::any,
    decompressFrame = function(...)
        error("Not implemented")
    end::any,
}
