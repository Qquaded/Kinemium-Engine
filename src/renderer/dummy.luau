--!optimize 2
-- Headless Renderer Stub

local signal = require("@Kinemium.signal")
local meshlib = require("./mesh")
local shader = require("./shader")
local skybox = require("./skybox")

local mainSignal = signal.new()
local fontRegistry = {}
local renderPool3d = {}
local renderPool2d = {}
local callbackStep = {}
local guiRegistry = {}
local mouseProperties = {}
local global_registry = {}

local Kinemium_camera = { Name = "CurrentCamera", FieldOfView = 70 }

local runtimelib = {
	drawModel = function() end,
	loadMaterialOnModel = function() end,
	LoadShader = function() end,
	GetFont = function(name)
		return fontRegistry[name]
	end,
	SetMouseProperties = function(data)
		mouseProperties = data
	end,
	gbSet = function(property, value)
		global_registry[property] = value
	end,
	gbGet = function(property)
		return global_registry[property]
	end,
}

local function step(time)
	local delta = 0.016 -- dummy frame time (~60FPS)
	mainSignal:Fire("PreRender", delta)
	mainSignal:Fire("RenderStepped", delta)

	-- Call GUI and 3D/2D stacks without actual rendering
	for _, callback in pairs(callbackStep) do
		callback(runtimelib)
	end

	for _, gui in pairs(guiRegistry) do
		gui.render(runtimelib, gui.object(), time)
	end

	for _, v in pairs(renderPool3d) do
		v(runtimelib)
	end
	for _, v in pairs(renderPool2d) do
		v(runtimelib)
	end

	mainSignal:Fire("Heartbeat", delta)
end

local function run()
	local time = 0
	local dt = 1 / 120
	while true do
		step(time)
		time += dt
		task.wait(dt)
	end
end

return {
	Signal = mainSignal,
	AddToRegistry = function(data)
		table.insert(renderPool3d, data)
	end,
	GetPool3D = function()
		local results = {}
		for _, part in pairs(renderPool3d) do
			table.insert(results, part)
		end
		return results
	end,
	DatamodelObject = function(obj)
		game = obj
	end,
	Step = step,
	AddToGuiRenderingPool = function(object, renderFn)
		table.insert(guiRegistry, { object = object, render = renderFn })
		mainSignal:Fire("AddedGuiToRenderPool", object())
	end,
	Run = run,
	Kinemium_camera = Kinemium_camera,
	mesh = meshlib,
	runtimelib = runtimelib,
	Add3DStack = function(v)
		table.insert(renderPool3d, v)
	end,
	Add2DStack = function(v)
		table.insert(renderPool2d, v)
	end,
	add = function(self, v)
		table.insert(callbackStep, v)
	end,
	shader = shader,
	materialList = {},
	LoadFont = function(name, path)
		fontRegistry[name] = { path = path }
	end,
	GetFont = function(name)
		return fontRegistry[name]
	end,
	UnloadFont = function(name)
		fontRegistry[name] = nil
	end,
	gbSet = function(property, value)
		global_registry[property] = value
	end,
	gbGet = function(property)
		return global_registry[property]
	end,
	SetLightingService = function() end,
	mouseOverVector3 = function()
		return false
	end,
	meshlib = meshlib,
	skybox = skybox,
	readRayCollision = function()
		return { hit = 0 }
	end,
	SetMouseTargetFilter = function() end,
}
