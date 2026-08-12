local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local RollbackEngine = require("@RollbackEngine")

local RunService = Instance.new("RunService")
RunService._Intents = Enum.PluginIntents.Threading

local RenderStepped = signal.new()
local Heartbeat = signal.new()
local Stepped = signal.new()
local PreRender = signal.new()
local PreGuiRender = signal.new()
local GuiRender = signal.new()

local renderBindings = {}
local sortedRenderBindings = {}
local renderBindingsDirty = false

function RunService:BindToRenderStep(name, priority, callback)
	renderBindings[name] = { priority = priority, callback = callback }
	renderBindingsDirty = true
end

function RunService:UnbindFromRenderStep(name)
	renderBindings[name] = nil
	renderBindingsDirty = true
end

local simulationBindings = {}
local predictedInstances = {}
local currentTick = 0
local SIMULATION_DT = 1 / 60
local accumulator = 0

function RunService:BindToSimulation(callback, frequency)
	table.insert(simulationBindings, callback)
end

function RunService:GetSimulationBindings()
	return simulationBindings
end

function RunService:GetSimulationTick()
	return currentTick
end

function RunService:GetSimulationDT()
	return SIMULATION_DT
end

function RunService:PerformRollback(rollbackTick)
	if not RollbackEngine:RestoreState(rollbackTick) then
		return
	end

	local targetTick = currentTick
	currentTick = rollbackTick

	while currentTick < targetTick do
		currentTick += 1
		for _, callback in ipairs(simulationBindings) do
			callback(SIMULATION_DT)
		end

		local predicted = RunService:GetPredictedInstances()
		RollbackEngine:CaptureState(currentTick, predicted)
	end
end

function RunService:SetPredictionMode(context, mode)
	if type(context) == "table" then
		rawset(context, "_predictionMode", mode)
		if mode == Enum.PredictionMode.On or mode == Enum.PredictionMode.Automatic then
			predictedInstances[context] = true
		else
			predictedInstances[context] = nil
		end
	end
end

function RunService:GetPredictedInstances()
	local list = {}
	for instance in pairs(predictedInstances) do
		if instance.Parent then
			table.insert(list, instance)
		else
			predictedInstances[instance] = nil
		end
	end
	return list
end

function RunService:GetPredictionStatus(context)
	if type(context) == "table" then
		local mode = rawget(context, "_predictionMode") or Enum.PredictionMode.Automatic
		if mode == Enum.PredictionMode.Off then
			return Enum.PredictionStatus.NotPredicted
		end
	end
	return Enum.PredictionStatus.Predicted
end

local function runRenderBindings(dt)
	if renderBindingsDirty then
		table.clear(sortedRenderBindings)
		for _, data in pairs(renderBindings) do
			table.insert(sortedRenderBindings, data)
		end
		table.sort(sortedRenderBindings, function(a, b)
			return a.priority < b.priority
		end)
		renderBindingsDirty = false
	end

	for _, binding in ipairs(sortedRenderBindings) do
		binding.callback(dt)
	end
end

local status = {
	IsClient = true,
	IsServer = false,
	IsStudio = true,
	IsRunMode = false,
	IsRunning = false,
	IsEdit = true,
	IsPaused = false,
}

local scheduled = {}

RunService.InitRenderer = function(renderer, renderer_signal)
	RunService:SetProperties({
		RenderStepped = RenderStepped,
		Heartbeat = Heartbeat,
		Stepped = Stepped,
		GuiRender = GuiRender,
		PreRender = PreRender,
		PreGuiRender = PreGuiRender,

		IsClient = function()
			return IsClient
		end,
		IsServer = function()
			return IsServer
		end,
		IsStudio = function()
			return status.IsStudio
		end,
		IsRunMode = function()
			return status.IsRunMode
		end,
		IsRunning = function()
			return status.IsRunning
		end,
		IsEdit = function()
			return status.IsEdit
		end,
	})

	renderer_signal:Connect(function(route, dt)
		if route == "RenderStepped" then
			RenderStepped:Fire(dt)
			runRenderBindings(dt)
		elseif route == "PreRender" then
			PreRender:Fire(dt)
		elseif route == "Heartbeat" then
			if not status.IsPaused then
				Heartbeat:Fire(dt)

				accumulator += dt
				while accumulator >= SIMULATION_DT do
					currentTick += 1
					for _, callback in ipairs(simulationBindings) do
						callback(SIMULATION_DT)
					end

					local predicted = RunService:GetPredictedInstances()
					RollbackEngine:CaptureState(currentTick, predicted)

					accumulator -= SIMULATION_DT
				end
			end
		elseif route == "Stepped" then
			if not status.IsPaused then
				Stepped:Fire(dt)
			end
		elseif route == "GuiRender" then
			GuiRender:Fire(dt)
		elseif route == "PreGuiRender" then
			PreGuiRender:Fire(dt)
		end
	end)
end

function RunService:Pause()
	status.IsPaused = true
end

function RunService:Resume()
	status.IsPaused = false
end

function RunService:IsPaused()
	return status.IsPaused
end

function RunService:SetSchedulerFPS(fps)
	local dt = 1 / fps
	local last = os.clock()
	return function()
		local now = os.clock()
		local elapsed = now - last
		if elapsed < dt then
			return false
		end
		last = now
		return true
	end
end

return RunService
