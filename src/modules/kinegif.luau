-- kinegif.luau
-- A pure Luau GIF decoder for Raylib/Kinemium
-- by devcell

local kinegif = {}
local lzw = require("./lzw")
local ffi = zune.ffi

export type Frame = {
	indices: buffer,
	colorTable: buffer,
	delay: number,
	transparentIndex: number?,
	disposalMethod: number,
	width: number,
	height: number,
}

export type Gif = {
	frames: { LoadedFrame },
	width: number,
	height: number,
	currentFrame: number,
	timer: number,
	paused: boolean,
	looping: boolean,
	finished: boolean,
	speed: number,
}

export type LoadedFrame = {
	texture: any, -- Raylib Texture2D
	delay: number, -- seconds
}

function kinegif.CreateFrames(path: string): { Frame }
	local rawGifBuf = zune.fs.readFile(path, true)

	-- validate magic
	local magic = ""
	for i = 0, 5 do
		magic ..= string.char(buffer.readu8(rawGifBuf, i))
	end
	assert(magic == "GIF87a" or magic == "GIF89a", `Not a valid GIF: got "{magic}"`)

	local offset = 6 -- skip header

	-- Logical Screen Descriptor
	local gifWidth = buffer.readu16(rawGifBuf, offset)
	local gifHeight = buffer.readu16(rawGifBuf, offset + 2)
	local packed = buffer.readu8(rawGifBuf, offset + 4)
	offset += 7

	-- read global color table
	local globalColorTable: buffer? = nil
	if bit32.band(packed, 0x80) ~= 0 then
		local gctSize = bit32.band(packed, 0x07)
		local byteLen = 3 * bit32.lshift(1, gctSize + 1)
		globalColorTable = buffer.create(byteLen)
		buffer.copy(globalColorTable, 0, rawGifBuf, offset, byteLen)
		offset += byteLen
	end

	local frames: { Frame } = {}
	local pendingDelay = 0
	local pendingTransparent: number? = nil
	local pendingDisposal = 0

	while offset < buffer.len(rawGifBuf) do
		local byte = buffer.readu8(rawGifBuf, offset)

		if byte == 0x3B then -- GIF trailer
			break
		elseif byte == 0x21 then -- extension
			local label = buffer.readu8(rawGifBuf, offset + 1)
			offset += 2

			if label == 0xF9 then -- Graphic Control Extension
				offset += 1 -- block size (always 4)
				local gcePacked = buffer.readu8(rawGifBuf, offset)
				local disposalMethod = bit32.band(bit32.rshift(gcePacked, 2), 0x07)

				offset += 1
				pendingDelay = buffer.readu16(rawGifBuf, offset)
				offset += 2
				local tIdx = buffer.readu8(rawGifBuf, offset)
				offset += 1
				offset += 1 -- block terminator
				if bit32.band(gcePacked, 0x01) ~= 0 then
					pendingTransparent = tIdx
				else
					pendingTransparent = nil
				end
				pendingDisposal = bit32.band(bit32.rshift(gcePacked, 2), 0x07) -- add this
			else
				-- skip unknown extension sub-blocks
				while true do
					local sz = buffer.readu8(rawGifBuf, offset)
					offset += 1
					if sz == 0 then
						break
					end
					offset += sz
				end
			end
		elseif byte == 0x2C then -- Image Descriptor
			offset += 1
			local frameWidth = buffer.readu16(rawGifBuf, offset + 4)
			local frameHeight = buffer.readu16(rawGifBuf, offset + 6)
			local imgPacked = buffer.readu8(rawGifBuf, offset + 8)
			offset += 9

			-- read local color table if present, else fall back to global
			local colorTable: buffer
			if bit32.band(imgPacked, 0x80) ~= 0 then
				local lctSize = bit32.band(imgPacked, 0x07)
				local byteLen = 3 * bit32.lshift(1, lctSize + 1)
				colorTable = buffer.create(byteLen)
				buffer.copy(colorTable, 0, rawGifBuf, offset, byteLen)
				offset += byteLen
			else
				assert(globalColorTable ~= nil, "No color table found for frame")
				colorTable = globalColorTable
			end

			local minCodeSize = buffer.readu8(rawGifBuf, offset)
			offset += 1

			-- read and flatten sub-blocks
			local chunks = {}
			while true do
				local blockSize = buffer.readu8(rawGifBuf, offset)
				offset += 1
				if blockSize == 0 then
					break
				end
				local chunk = buffer.create(blockSize)
				buffer.copy(chunk, 0, rawGifBuf, offset, blockSize)
				table.insert(chunks, chunk)
				offset += blockSize
			end

			local totalLen = 0
			for _, c in chunks do
				totalLen += buffer.len(c)
			end
			local data = buffer.create(totalLen)
			local pos = 0
			for _, c in chunks do
				buffer.copy(data, pos, c)
				pos += buffer.len(c)
			end

			local indices = lzw(data, minCodeSize)

			table.insert(frames, {
				indices = indices,
				colorTable = colorTable,
				delay = pendingDelay,
				transparentIndex = pendingTransparent,
				disposalMethod = pendingDisposal,
				width = frameWidth,
				height = frameHeight,
			})
			pendingDelay = 0
			pendingTransparent = nil
			pendingDisposal = 0

			pendingDelay = 0
			pendingTransparent = nil
		else
			offset += 1
		end
	end

	return frames
end

function kinegif.ToRGBA(frame: Frame): buffer
	local pixelCount = frame.width * frame.height
	local rgba = buffer.create(pixelCount * 4)

	for i = 0, pixelCount - 1 do
		local index = buffer.readu8(frame.indices, i)

		if frame.transparentIndex ~= nil and index == frame.transparentIndex then
			buffer.writeu8(rgba, i * 4 + 0, 0)
			buffer.writeu8(rgba, i * 4 + 1, 0)
			buffer.writeu8(rgba, i * 4 + 2, 0)
			buffer.writeu8(rgba, i * 4 + 3, 0)
		else
			local ctOffset = index * 3
			buffer.writeu8(rgba, i * 4 + 0, buffer.readu8(frame.colorTable, ctOffset + 0))
			buffer.writeu8(rgba, i * 4 + 1, buffer.readu8(frame.colorTable, ctOffset + 1))
			buffer.writeu8(rgba, i * 4 + 2, buffer.readu8(frame.colorTable, ctOffset + 2))
			buffer.writeu8(rgba, i * 4 + 3, 255)
		end
	end

	return rgba
end

function kinegif.GetTimestamp(gif: Gif): number
	local t = 0
	for i = 1, gif.currentFrame - 1 do
		t += gif.frames[i].delay
	end
	t += gif.timer
	return t
end

function kinegif.GetDuration(gif: Gif): number
	local total = 0
	for _, frame in gif.frames do
		total += frame.delay
	end
	return total
end

function kinegif.Load(path: string): Gif
	local adapter = require("@RaylibAdapter")
	local lib = adapter.lib

	local rawFrames = kinegif.CreateFrames(path)
	assert(#rawFrames > 0, `GIF has no frames: {path}`)

	local gif: Gif = {
		frames = {},
		width = rawFrames[1].width,
		height = rawFrames[1].height,
		currentFrame = 1,
		timer = 0,
		paused = false,
		looping = true,
		finished = false,
		speed = 1,
	}

	local canvasSize = rawFrames[1].width * rawFrames[1].height * 4
	local canvas = buffer.create(canvasSize) -- persistent canvas
	local prevCanvas = buffer.create(canvasSize) -- for disposal method 3

	for i, frame in rawFrames do
		local rgba = kinegif.ToRGBA(frame)

		-- save canvas state before drawing if next frame might need it (disposal 3)
		buffer.copy(prevCanvas, 0, canvas)

		-- composite this frame onto canvas based on disposal of PREVIOUS frame
		local prevDisposal = if i > 1 then rawFrames[i - 1].disposalMethod else 0

		if prevDisposal == 2 then
			-- restore to background: clear canvas first
			buffer.fill(canvas, 0, 0, canvasSize)
		elseif prevDisposal == 3 then
			-- restore to previous: roll back to prevCanvas state
			buffer.copy(canvas, 0, prevCanvas)
		end
		-- disposal 0/1: leave canvas as-is, just composite on top

		-- composite rgba onto canvas (respect transparency)
		local pixelCount = frame.width * frame.height
		for p = 0, pixelCount - 1 do
			local a = buffer.readu8(rgba, p * 4 + 3)
			if a > 0 then
				buffer.writeu8(canvas, p * 4 + 0, buffer.readu8(rgba, p * 4 + 0))
				buffer.writeu8(canvas, p * 4 + 1, buffer.readu8(rgba, p * 4 + 1))
				buffer.writeu8(canvas, p * 4 + 2, buffer.readu8(rgba, p * 4 + 2))
				buffer.writeu8(canvas, p * 4 + 3, a)
			end
		end

		-- upload composited canvas as texture
		local img = lib.GenImageColor(frame.width, frame.height, adapter.const.BLANK)
		local texture = lib.LoadTextureFromImage(img)
		lib.UnloadImage(img)

		local snapshot = buffer.create(canvasSize)
		buffer.copy(snapshot, 0, canvas)
		local ptr = ffi.dupe(snapshot)
		lib.UpdateTexture(texture, ptr)
		ffi.free(ptr)

		local delay = if frame.delay > 0 then frame.delay / 100 else 0.1
		table.insert(gif.frames, {
			texture = texture,
			delay = delay,
		})
	end

	return gif
end

function kinegif.Update(gif: Gif, dt: number)
	if gif.paused or gif.finished then
		return
	end

	gif.timer += dt * gif.speed
	local frame = gif.frames[gif.currentFrame]

	if gif.timer >= frame.delay then
		gif.timer -= frame.delay

		if gif.currentFrame == #gif.frames then
			if gif.looping then
				gif.currentFrame = 1
			else
				gif.finished = true
			end
		else
			gif.currentFrame += 1
		end
	end
end

function kinegif.Pause(gif: Gif)
	gif.paused = true
end

function kinegif.Resume(gif: Gif)
	gif.paused = false
end

function kinegif.SetSpeed(gif: Gif, scale: number)
	assert(scale > 0, "Speed scale must be positive")
	gif.speed = scale
end

function kinegif.SetLooping(gif: Gif, loop: boolean)
	gif.looping = loop
	-- if re-enabling looping, clear the finished flag
	if loop then
		gif.finished = false
	end
end

function kinegif.Seek(gif: Gif, timestamp: number)
	-- clamp to valid range
	local duration = 0
	for _, frame in gif.frames do
		duration += frame.delay
	end
	timestamp = math.clamp(timestamp, 0, duration)

	-- walk frames to find which one timestamp lands in
	local t = 0
	for i, frame in gif.frames do
		t += frame.delay
		if timestamp < t or i == #gif.frames then
			gif.currentFrame = i
			gif.timer = timestamp - (t - frame.delay)
			gif.finished = false
			return
		end
	end
end

function kinegif.Draw(gif: Gif, x: number, y: number, width: number?, height: number?, tint: any?)
	local adapter = require("@RaylibAdapter")
	local lib = adapter.lib
	local structs = adapter.structs
	local color = tint or adapter.const.WHITE

	local w = width or gif.width
	local h = height or gif.height

	local src = structs.Rectangle:new({ x = 0, y = 0, width = gif.width, height = gif.height })
	local dst = structs.Rectangle:new({ x = x, y = y, width = w, height = h })

	lib.DrawTexturePro(
		gif.frames[gif.currentFrame].texture,
		src,
		dst,
		vector.create(0, 0), -- origin
		0, -- rotation
		color
	)
end

function kinegif.Unload(gif: Gif)
	local lib = require("@raylib").lib
	for _, frame in gif.frames do
		lib.UnloadTexture(frame.texture)
	end
end

return kinegif
