local Signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local Vector3 = require("@Vector3")
local raylib = require("@raylib")
local task = zune.task

local propTable = {
	SoundId = "./src/assets/sounds/bqqchickenalert.mp3",
	Volume = 1.0,
	Pitch = 1.0,
	Looped = false,
	Playing = false,
	TimePosition = 0,
	PlayOnRemove = false,
	IsLoaded = false,
	Name = "Sound",
	AudioBackend = Enum.AudioBackend.Raudio,

	IsStream = false,
	SoundGroup = nil,
	_effectiveVolume = 1.0,
	_fadeVolume = 1.0,

	Position = Vector3.new(0, 0, 0),
	Velocity = Vector3.new(0, 0, 0),
	Direction = Vector3.new(0, 0, -1),
	Up = Vector3.new(0, 1, 0),
	MinDistance = 10.0,
	MaxDistance = 1000.0,
	RollOffMode = 0, -- 0 = Linear, 1 = Inverse, 2 = InverseTapered
	Is3D = false,
}

return {
	class = "Sound",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		local function updateVolume()
			if not instance.IsLoaded then return end
			local groupVol = instance.SoundGroup and instance.SoundGroup.Volume or 1.0
			instance._effectiveVolume = instance.Volume * groupVol * instance._fadeVolume
			if instance.IsStream then
				raylib.lib.SetMusicVolume(instance._raylibSound, instance._effectiveVolume)
			else
				raylib.lib.SetSoundVolume(instance._raylibSound, instance._effectiveVolume)
			end
		end

		local function updatePitch()
			if not instance.IsLoaded then return end
			if instance.IsStream then
				raylib.lib.SetMusicPitch(instance._raylibSound, instance.Pitch)
			else
				raylib.lib.SetSoundPitch(instance._raylibSound, instance.Pitch)
			end
		end

		local function loadAudio()
			if instance._raylibSound then
				if instance.IsStream then
					raylib.lib.UnloadMusicStream(instance._raylibSound)
				else
					raylib.lib.UnloadSound(instance._raylibSound)
				end
				instance._raylibSound = nil
			end
			
			if instance.SoundId == "" then
				instance.IsLoaded = false
				return
			end
			
			if instance.IsStream then
				instance._raylibSound = raylib.lib.LoadMusicStream(instance.SoundId)
				-- MusicStreams are pointer/objects, but in FFI they return valid if loaded
				instance.IsLoaded = instance._raylibSound ~= nil
			else
				instance._raylibSound = raylib.lib.LoadSound(instance.SoundId)
				instance.IsLoaded = instance._raylibSound ~= nil
			end

			if instance.IsLoaded then
				updateVolume()
				updatePitch()
			else
				warn("Failed to load sound/stream: " .. instance.SoundId)
			end
		end

		loadAudio()

		local function fadeTo(targetFade, duration)
			if duration and duration > 0 then
				local startFade = instance._fadeVolume
				local startTime = os.clock()
				task.spawn(function()
					while true do
						local elapsed = os.clock() - startTime
						if elapsed >= duration then
							instance._fadeVolume = targetFade
							updateVolume()
							break
						end
						instance._fadeVolume = startFade + (targetFade - startFade) * (elapsed / duration)
						updateVolume()
						task.wait()
					end
				end)
			else
				instance._fadeVolume = targetFade
				updateVolume()
			end
		end

		instance.Play = function(self, fadeDuration)
			if self.IsLoaded and not self.Playing then
				fadeTo(1.0, fadeDuration)
				if self.IsStream then
					raylib.lib.PlayMusicStream(self._raylibSound)
				else
					raylib.lib.PlaySound(self._raylibSound)
				end
				self.Playing = true
				if self.Played then
					self.Played:Fire()
				end
			end
		end

		instance.Stop = function(self, fadeDuration)
			if self.IsLoaded then
				if fadeDuration and fadeDuration > 0 then
					fadeTo(0.0, fadeDuration)
					task.delay(fadeDuration, function()
						if self.Playing then
							if self.IsStream then raylib.lib.StopMusicStream(self._raylibSound) else raylib.lib.StopSound(self._raylibSound) end
							self.Playing = false
							self.TimePosition = 0
						end
					end)
				else
					if self.IsStream then raylib.lib.StopMusicStream(self._raylibSound) else raylib.lib.StopSound(self._raylibSound) end
					self.Playing = false
					self.TimePosition = 0
				end
			end
		end

		instance.Pause = function(self, fadeDuration)
			if self.IsLoaded then
				if fadeDuration and fadeDuration > 0 then
					fadeTo(0.0, fadeDuration)
					task.delay(fadeDuration, function()
						if self.IsStream then raylib.lib.PauseMusicStream(self._raylibSound) else raylib.lib.PauseSound(self._raylibSound) end
						self.Playing = false
					end)
				else
					if self.IsStream then raylib.lib.PauseMusicStream(self._raylibSound) else raylib.lib.PauseSound(self._raylibSound) end
					self.Playing = false
				end
			end
		end

		instance.Resume = function(self, fadeDuration)
			if self.IsLoaded then
				if self.IsStream then raylib.lib.ResumeMusicStream(self._raylibSound) else raylib.lib.ResumeSound(self._raylibSound) end
				self.Playing = true
				fadeTo(1.0, fadeDuration)
			end
		end

		instance.Changed:Connect(function(prop)
			if prop == "Volume" or prop == "SoundGroup" then
				updateVolume()
			elseif prop == "Pitch" then
				updatePitch()
			elseif prop == "SoundId" or prop == "IsStream" then
				loadAudio()
			end
		end)

		instance.Played = Signal.new()
		instance.Ended = Signal.new()

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
