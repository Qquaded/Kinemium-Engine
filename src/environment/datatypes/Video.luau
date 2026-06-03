local Video = {}
Video.__index = Video
Video.ClassName = "Video"

local ffi = zune.ffi

function Video.new(url, length, framerate)
	--TODO: Implement functionality using FFmpeg

	return self
end

function Video:Clone()
	return Video.new(self.Url, self.Length, self.Framerate)
end

function Video:Equals(other)
	return getmetatable(other) == Video
		and self.Url == other.Url
		and self.Length == other.Length
		and self.Framerate == other.Framerate
end

function Video:__tostring()
	return string.format("Video(%s, Length=%d, FPS=%d)", self.Url, self.Length, self.Framerate)
end

function Video:Play()
	if not self._ffmpg_codecContext then
		warn("Video not properly initialized")
		return false
	end

	self._isPlaying = true
	self._currentTime = 0
	self._lastFrameTime = os.clock()

	return true
end

function Video:Pause()
	self._isPlaying = false
end

function Video:Stop()
	self._isPlaying = false
	self._currentTime = 0
	self._isEnded = false
end

function Video:Seek(seconds)
	seconds = math.clamp(seconds, 0, self.Length)
	self._currentTime = seconds
	self._isEnded = false
	return true
end

function Video:Update(deltaTime)
	if not self._isPlaying or self._isEnded then
		return nil
	end

	self._currentTime = self._currentTime + deltaTime

	if self._currentTime >= self.Length then
		self._isPlaying = false
		self._isEnded = true
		return nil
	end

	-- Decode a frame at current time
	return self:_decodeFrameAtTime(self._currentTime)
end

function Video:_decodeFrameAtTime(seconds)
	-- Stop current loading
	sail.lib.sail_stop_loading(self._sail_state)

	-- Clear tuning
	sail.common.lib.sail_clear_hash_map(self._sail_tuning)

	-- Set new time
	local timeMs = math.floor(seconds * 1000)
	sail.common.lib.sail_put_hash_map_string(self._sail_tuning, "video-seek-time", tostring(timeMs))

	-- Restart loading
	local statePtr = buffer.create(8)
	local ret = sail.lib.sail_start_loading_from_file_with_options(
		self.Url,
		self._sail_codecInfo,
		self._sail_loadOptions,
		statePtr
	)
	if ret ~= 0 then
		return nil
	end
	self._sail_state = statePtr:readptr(0)

	-- Load frame
	ret = sail.lib.sail_load_next_frame(self._sail_state, self._sail_imagePtr)
	if ret ~= 0 then
		return nil
	end

	local image = self._sail_imagePtr:readptr(0)
	return image
end

function Video:GetCurrentFrame()
	return self:_decodeFrameAtTime(self._currentTime)
end

function Video:GetFrameAtTime(seconds)
	local frame = math.clamp(math.floor(seconds * self.Framerate), 0, self.Length * self.Framerate)
	return frame
end

function Video:GetPixelData()
	local image = self:_decodeFrameAtTime(self._currentTime)
	if not image then
		return nil, 0
	end

	local pixelData = image:readptr(0)
	local size = self.Width * self.Height * 4 -- RGBA

	return pixelData, size
end

function Video:GetFrameData()
	return self:_decodeFrameAtTime(self._currentTime)
end

function Video:Destroy()
	if self._sail_state then
		sail.lib.sail_stop_loading(self._sail_state)
		self._sail_state = nil
	end
	if self._sail_loadOptions then
		sail.common.lib.sail_destroy_load_options(self._sail_loadOptions)
		self._sail_loadOptions = nil
	end
	if self._sail_tuning then
		sail.common.lib.sail_destroy_hash_map(self._sail_tuning)
		self._sail_tuning = nil
	end
end

function Video:IsPlaying()
	return self._isPlaying == true
end

function Video:IsEnded()
	return self._isEnded == true
end

function Video:GetCurrentTime()
	return self._currentTime or 0
end

function Video:GetDuration()
	return self.Length
end

setmetatable(Video, {
	__call = function(_, ...)
		return Video.new(...)
	end,
})
return Video
