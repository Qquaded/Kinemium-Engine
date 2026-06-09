--[[
local ProfilerService = game:GetService("ProfilerService")
local ENGINE_PROFILER = ProfilerService.ENGINE_PROFILER

local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")
local lib = raylib.lib
local renderer = rlservice.GetRenderer()
local arect = require("@arect")

local aereon = require("@Aereon")
local gui = aereon.gui

local profilerGui = gui.profiler({
	profiler = ENGINE_PROFILER,
	x = 0,
	y = 0,
	width = 0,
	height = 0,
})

renderer.Pool.new("2d", function()
	profilerGui.render(lib.GetFrameTime())
	profilerGui.set("obj_rect", arect.new(0, 0, raylib.lib.GetRenderWidth(), raylib.lib.GetRenderHeight()))
end, 1048576)
--]]
