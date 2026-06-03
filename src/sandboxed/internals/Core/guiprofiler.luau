--[[
local ProfilerService = game:GetService("ProfilerService")
local ENGINE_PROFILER = ProfilerService.ENGINE_PROFILER

local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")
local lib = raylib.lib
local renderer = rlservice.GetRenderer()

local aereon = require("@Aereon")
local gui = aereon.gui

local profilerGui = gui.profiler({
	profiler = ENGINE_PROFILER,
})

renderer.AddGuiStack(function()
	profilerGui.render(lib.GetFrameTime())
end)
--]]
