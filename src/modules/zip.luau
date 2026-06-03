--!strict
--!optimize 2
--!native

local mem = zune.mem
local flate = zune.serde.flate

local zip = {}

local EOCD_SIGNATURE = buffer.fromstring("\x50\x4b\x05\x06")

local function findEOCD(buf: buffer, len: number)
	local maxSearch = math.min(len, 65557) -- EOCD max size window
	return mem.findPos(buf, len - maxSearch, EOCD_SIGNATURE)
end

function zip.is(buf: buffer): boolean
	local len = buffer.len(buf)
	if len < 22 then
		return false
	end
	return mem.findPos(buf, len - 22, EOCD_SIGNATURE) ~= nil
end

function zip.read(buf: buffer): { [string]: buffer }
	local len = buffer.len(buf)
	local files: { [string]: buffer } = {}

	local eocd_offset = findEOCD(buf, len)
	if not eocd_offset then
		error("Invalid ZIP file", 0)
	end

	local central_dir_offset = buffer.readu32(buf, eocd_offset + 16)
	local central_dir_size = buffer.readu32(buf, eocd_offset + 12)

	local offset = central_dir_offset
	while offset < central_dir_offset + central_dir_size do
		if buffer.readu32(buf, offset) ~= 0x02014b50 then
			break
		end

		local compression = buffer.readu16(buf, offset + 10)
		local compressed_size = buffer.readu32(buf, offset + 20)
		local name_len = buffer.readu16(buf, offset + 28)
		local extra_len = buffer.readu16(buf, offset + 30)
		local comment_len = buffer.readu16(buf, offset + 32)
		local local_header_offset = buffer.readu32(buf, offset + 42)

		local name = buffer.readstring(buf, offset + 46, name_len)

		local local_extra_len = buffer.readu16(buf, local_header_offset + 28)
		local data_offset = local_header_offset + 30 + name_len + local_extra_len

		if data_offset + compressed_size > len then
			break
		end

		local compressed_data = buffer.create(compressed_size)
		buffer.copy(compressed_data, 0, buf, data_offset, compressed_size)

		local decompressed: buffer
		if compression == 8 then
			decompressed = flate.decompress(compressed_data)
		elseif compression == 0 then
			decompressed = compressed_data
		else
			decompressed = buffer.create(0)
		end

		files[name] = decompressed

		offset = offset + 46 + name_len + extra_len + comment_len
	end

	return files
end

return zip
