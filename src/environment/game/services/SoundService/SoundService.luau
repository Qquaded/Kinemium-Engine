local Instance = require("@Instance")
local Enum = require("@EnumMap")

local SoundService = Instance.new("SoundService")
SoundService.ExplorerHidden = true
SoundService._Intents = Enum.PluginIntents.Audio

SoundService.InitRenderer = function(renderer, renderer_signal, datamodel)
	SoundService.GlobalVolume = 1.0

	renderer.Pool.new("3d", function()
		local workspace = datamodel:GetService("Workspace")
		if not workspace then
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local camPos = camera.CFrame.Position
		local camRight = camera.CFrame:GetRightVector()

		for _, obj in pairs(datamodel:GetDescendants()) do
			if obj.class == "Sound" and obj.Playing and obj.IsLoaded then
				if obj.IsStream then
					--adapter.lib.UpdateMusicStream(obj._raylibSound)
				end

				if obj.Is3D then
					local pos = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position or obj.Position
					local dist = (pos - camPos):Magnitude()

					local attenuation = 1.0
					if dist < obj.MinDistance then
						attenuation = 1.0
					elseif dist > obj.MaxDistance then
						attenuation = 0.0
					else
						if obj.RollOffMode == 0 then -- Linear
							attenuation = 1.0 - ((dist - obj.MinDistance) / (obj.MaxDistance - obj.MinDistance))
						elseif obj.RollOffMode == 1 then -- Inverse
							attenuation = obj.MinDistance / dist
						elseif obj.RollOffMode == 2 then -- InverseTapered
							attenuation = obj.MinDistance / (dist + obj.MinDistance)
						end
					end

					local dirToSound = (pos - camPos):Unit()
					local rightDot = camRight:Dot(dirToSound)
					-- pan: 0 = left, 1 = right, 0.5 = center
					local pan = (rightDot + 1) / 2

					local groupVol = obj.SoundGroup and obj.SoundGroup.Volume or 1.0
					local finalVol = obj.Volume * groupVol * obj._fadeVolume * attenuation * SoundService.GlobalVolume

					if obj.IsStream then
						--adapter.lib.SetMusicVolume(obj._raylibSound, finalVol)
						--adapter.lib.SetMusicPan(obj._raylibSound, pan)
					else
						--adapter.lib.SetSoundVolume(obj._raylibSound, finalVol)
						--adapter.lib.SetSoundPan(obj._raylibSound, pan)
					end
				else
					local groupVol = obj.SoundGroup and obj.SoundGroup.Volume or 1.0
					local finalVol = obj.Volume * groupVol * obj._fadeVolume * SoundService.GlobalVolume

					if obj.IsStream then
						--adapter.lib.SetMusicVolume(obj._raylibSound, finalVol)
						--adapter.lib.SetMusicPan(obj._raylibSound, 0.5)
					else
						--adapter.lib.SetSoundVolume(obj._raylibSound, finalVol)
						--adapter.lib.SetSoundPan(obj._raylibSound, 0.5)
					end
				end
			end
		end
	end)
end

return SoundService
