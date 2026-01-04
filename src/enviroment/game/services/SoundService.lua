local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local utils = require("@bufferutils")

local SoundService = Instance.new("SoundService")
SoundService.ExplorerHidden = true

local ffi = zune.ffi

local fmod = require("@fmod")

SoundService.InitRenderer = function(renderer, renderer_signal, game)
	--[[
	local result = ffi.create(ffi.types.pointer) -- create empty pointer
	local systemPtr = ffi.create(ffi.types.pointer)

	-- create system
	result = utils:fcall(function()
		return fmod.fmod.FMOD_System_Create(systemPtr, 0)
	end, fmod.const.FMOD_OK)

	-- init fmod studio
	result = fmod.studio.FMOD_Studio_System_Initialize(512, fmod.const.FMOD_DEFAULT, fmod.const.FMOD_INIT_NORMAL, 0)
	renderer_signal:Connect(function(route)
		if route == "RenderStepped" then
			fmod.fmod.FMOD_System_Update(systemPtr)
		end
	end)

	table.insert(game.ShutdownCallbacks, function()
		fmod.fmod.FMOD_System_Close(systemPtr)
		fmod.fmod.FMOD_System_Release(systemPtr)
	end)
    --]]
end

return SoundService
