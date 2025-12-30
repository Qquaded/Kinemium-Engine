local Signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local Vector3 = require("@Vector3")
local fmod = require("@fmod")

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

	Position = Vector3.new(0, 0, 0),
	Velocity = Vector3.new(0, 0, 0),
	Direction = Vector3.new(0, 0, -1),
	Up = Vector3.new(0, 1, 0),
	MinDistance = 1.0,
	MaxDistance = 10000.0,
	ConeInsideAngle = 360,
	ConeOutsideAngle = 360,
	ConeOutsideVolume = 1.0,
	Is3D = false,
}

return {
	class = "Sound",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		if instance.SoundId ~= "" then
			instance._raylibSound = renderer.lib.LoadSound(instance.SoundId)
			if instance._raylibSound then
				instance.IsLoaded = true
				renderer.lib.SetSoundVolume(instance._raylibSound, instance.Volume)
				renderer.lib.SetSoundPitch(instance._raylibSound, instance.Pitch)
			else
				print("Failed to load sound: " .. instance.SoundId)
			end
		end

		instance.Play = function(self)
			if self.IsLoaded and not self.Playing then
				renderer.lib.PlaySound(self._raylibSound)
				self.Playing = true
				if self.Played then
					self.Played:Fire()
				end
			end
		end

		instance.Stop = function(self)
			if self.IsLoaded then
				renderer.lib.StopSound(self._raylibSound)
				self.Playing = false
				self.TimePosition = 0
			end
		end

		instance.Pause = function(self)
			if self.IsLoaded then
				renderer.lib.PauseSound(self._raylibSound)
				self.Playing = false
			end
		end

		instance.Resume = function(self)
			if self.IsLoaded then
				renderer.lib.ResumeSound(self._raylibSound)
				self.Playing = true
			end
		end

		instance.Changed:Connect(function(prop)
			if prop == "Volume" and instance.IsLoaded then
				renderer.lib.SetSoundVolume(instance._raylibSound, instance.Volume)
			elseif prop == "Pitch" and instance.IsLoaded then
				renderer.lib.SetSoundPitch(instance._raylibSound, instance.Pitch)
			elseif prop == "SoundId" then
				if instance._raylibSound then
					renderer.lib.UnloadSound(instance._raylibSound)
				end
				instance._raylibSound = renderer.lib.LoadSound(instance.SoundId)
				instance.IsLoaded = instance._raylibSound ~= nil
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
