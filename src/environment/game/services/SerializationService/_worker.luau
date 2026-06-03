local thread = zune.thread
local serde = zune.serde
local zstd = serde.zstd

local encoder = require("./_encoder")

local function decompress(str)
	local decompressed = zstd.decompress(str)
	return encoder.decode(decompressed)
end

local function compress(tbl)
	local encoded = encoder.encode(tbl)
	return zstd.compress(encoded, { level = 1 })
end

while true do
	local req = thread.receive()
	if not req then
		continue
	end

	if req.action == "decompress" then
		local ok, result = pcall(decompress, req.data)
		if ok then
			thread.send({ id = req.id, result = result })
		else
			thread.send({ id = req.id, error = tostring(result) })
		end
	elseif req.action == "compress" then
		local ok, result = pcall(compress, req.data)
		if ok then
			thread.send({ id = req.id, result = result })
		else
			thread.send({ id = req.id, error = tostring(result) })
		end
	end
end
