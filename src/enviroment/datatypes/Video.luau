local Video = {}
Video.__index = Video
Video.ClassName = "Video"

local ffi = zune.ffi

function Video.new(url, length, framerate)
	local sail = require("@sail")
	assert(type(url) == "string", "Video URL must be a string")

	local self = setmetatable({}, Video)
	self.Url = url

	-- Get codec info
	local codecInfoPtr = ffi.alloc(8)
	local ret = sail.lib.sail_codec_info_from_path(url, codecInfoPtr)
	if ret ~= 0 then
		error("Failed to get codec info for " .. url)
	end
	local codecInfo = codecInfoPtr:readptr(0)

	-- Alloc load options
	local loadOptionsPtr = ffi.alloc(8)
	ret = sail.common.lib.sail_alloc_load_options(loadOptionsPtr)
	print(ret)
	if ret ~= 0 then
		error("Failed to alloc load options")
	end
	local loadOptions = loadOptionsPtr:readptr(0)

	-- Alloc tuning hash_map
	local tuningPtr = ffi.alloc(8)
	ret = sail.common.lib.sail_alloc_hash_map(tuningPtr)
	if ret ~= 0 then
		sail.common.lib.sail_destroy_load_options(loadOptions)
		error("Failed to alloc tuning")
	end
	local tuning = tuningPtr:readptr(0)

	-- Set tuning for first frame
	ret = sail.common.lib.sail_put_hash_map_string(tuning, "video-seek-time", "0")
	print(ret)
	if ret ~= 0 then
		sail.common.lib.sail_destroy_hash_map(tuning)
		sail.common.lib.sail_destroy_load_options(loadOptions)
		error("Failed to set tuning")
	end

	-- Set tuning in load options
	loadOptions:writeptr(8, tuning)

	-- Start loading
	print("loading")
	local statePtr = ffi.alloc(8)
	ret = sail.lib.sail_start_loading_from_file_with_options(url, codecInfo, loadOptions, statePtr)
	print("buh")
	print(ret)
	if ret ~= 0 then
		sail.common.lib.sail_destroy_hash_map(tuning)
		sail.common.lib.sail_destroy_load_options(loadOptions)
		error("Failed to start loading")
	end
	local state = statePtr:readptr(0)
	print("stopped")

	-- Load first frame
	local imagePtr = ffi.alloc(8)
	ret = sail.lib.sail_load_next_frame(state, imagePtr)
	if ret ~= 0 then
		sail.lib.sail_stop_loading(state)
		sail.common.lib.sail_destroy_hash_map(tuning)
		sail.common.lib.sail_destroy_load_options(loadOptions)
		error("Failed to load first frame")
	end
	local image = imagePtr:readptr(0)

	-- Get properties
	self.Width = image:readu32(8)
	self.Height = image:readu32(12)

	-- Default values
	self.Framerate = framerate or 30
	self.Length = length or 0

	-- Override with provided
	if framerate then
		self.Framerate = framerate
	end
	if length then
		self.Length = length
	end

	-- Store internals
	self._sail_state = state
	self._sail_loadOptions = loadOptions
	self._sail_tuning = tuning
	self._sail_codecInfo = codecInfo
	self._sail_imagePtr = imagePtr

	-- Playback state
	self._isPlaying = false
	self._currentTime = 0
	self._isEnded = false
	self._lastFrameTime = 0

	print(self.Width, self.Height, self.Framerate, self.Length, self._sail_imagePtr)

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
