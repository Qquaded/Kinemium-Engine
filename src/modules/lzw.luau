local function decodeLZW(data: buffer, minCodeSize: number): buffer
	local clearCode = bit32.lshift(1, minCodeSize)
	local eodCode = clearCode + 1

	-- Build initial dictionary
	local function buildDict()
		local dict = {}
		for i = 0, clearCode - 1 do
			dict[i] = buffer.create(1)
			buffer.writeu8(dict[i], 0, i)
		end
		return dict
	end

	local dict = buildDict()
	local nextCode = eodCode + 1
	local codeSize = minCodeSize + 1

	local output = {}
	local bitBuf = 0
	local bitCount = 0
	local bytePos = 0
	local dataLen = buffer.len(data)

	local function readCode(): number?
		while bitCount < codeSize do
			if bytePos >= dataLen then
				return nil
			end
			bitBuf = bitBuf + bit32.lshift(buffer.readu8(data, bytePos), bitCount)
			bytePos += 1
			bitCount += 8
		end
		local code = bit32.band(bitBuf, bit32.lshift(1, codeSize) - 1)
		bitBuf = bit32.rshift(bitBuf, codeSize)
		bitCount -= codeSize
		return code
	end

	local prevEntry: buffer? = nil

	while true do
		local code = readCode()
		if code == nil or code == eodCode then
			break
		end

		if code == clearCode then
			dict = buildDict()
			nextCode = eodCode + 1
			codeSize = minCodeSize + 1
			prevEntry = nil
			continue
		end

		local entry: buffer
		if dict[code] then
			entry = dict[code]
		elseif code == nextCode and prevEntry then
			-- Special case: code not yet in dict
			local first = buffer.readu8(prevEntry, 0)
			entry = buffer.create(buffer.len(prevEntry) + 1)
			buffer.copy(entry, 0, prevEntry)
			buffer.writeu8(entry, buffer.len(prevEntry), first)
		else
			error(`Invalid LZW code: {code}`)
		end

		table.insert(output, entry)

		if prevEntry then
			local newEntry = buffer.create(buffer.len(prevEntry) + 1)
			buffer.copy(newEntry, 0, prevEntry)
			buffer.writeu8(newEntry, buffer.len(prevEntry), buffer.readu8(entry, 0))
			dict[nextCode] = newEntry
			nextCode += 1

			-- Grow code size when dict fills up the current bit width
			if nextCode == bit32.lshift(1, codeSize) and codeSize < 12 then
				codeSize += 1
			end
		end

		prevEntry = entry
	end

	-- Flatten output buffers into one
	local totalLen = 0
	for _, b in output do
		totalLen += buffer.len(b)
	end

	local result = buffer.create(totalLen)
	local offset = 0
	for _, b in output do
		buffer.copy(result, offset, b)
		offset += buffer.len(b)
	end

	return result
end

return decodeLZW
