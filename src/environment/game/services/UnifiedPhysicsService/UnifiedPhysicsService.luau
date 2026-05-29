local Instance = require("@Instance")
local Enum = require("@EnumMap")

local UnifiedPhysicsService = Instance.new("UnifiedPhysicsService")
UnifiedPhysicsService.ExplorerHidden = true
UnifiedPhysicsService._Intents = Enum.PluginIntents.Physics

local engines = {}
local activeEngineName = nil
local activeEngineHandler = nil
local datamodel_ref = nil

function UnifiedPhysicsService:RegisterEngine(name, handler)
	engines[name] = handler
end

function UnifiedPhysicsService:SetPrimaryEngine(name)
	if activeEngineName == name then
		return
	end
	local newHandler = engines[name]
	if not newHandler then
		warn("[UPS] Attempted to set unknown physics engine: " .. tostring(name))
		return
	end

	-- Teardown old engine
	if activeEngineHandler then
		if activeEngineHandler.Unload then
			pcall(activeEngineHandler.Unload)
		end
		for k, v in pairs(activeEngineHandler) do
			if type(v) == "function" then
				UnifiedPhysicsService._props[k] = nil
			end
		end
	end

	activeEngineName = name
	activeEngineHandler = newHandler

	-- Map new functions
	for k, v in pairs(newHandler) do
		if type(v) == "function" then
			UnifiedPhysicsService._props[k] = v
		end
	end

	-- Reconstruction Sweep
	if datamodel_ref then
		for _, descendant in ipairs(datamodel_ref:GetDescendants()) do
			if descendant.BaseClass == "BasePart" then
				if activeEngineHandler.AddBody then
					activeEngineHandler.AddBody(descendant)
				end
			end
		end

		for _, descendant in ipairs(datamodel_ref:GetDescendants()) do
			if descendant.ClassName and descendant.ClassName:match("Constraint$") then
				if descendant.Enabled ~= nil then
					local state = descendant.Enabled
					descendant.Enabled = not state
					descendant.Enabled = state
				end
			end
		end
	end

	print("[UPS] Active Physics Engine set to: " .. name)
end

function UnifiedPhysicsService:GetPrimaryEngineName()
	return activeEngineName
end

UnifiedPhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	datamodel_ref = game

	renderer_signal:Connect(function(route, data)
		if activeEngineHandler and activeEngineHandler.HandleRendererSignal then
			activeEngineHandler.HandleRendererSignal(route, data)
		else
			if route == "UpdatePart" or route == "AddedPartToRenderPool" then
				if activeEngineHandler and activeEngineHandler.UpdatePart then
					activeEngineHandler.UpdatePart(data)
				elseif activeEngineHandler and activeEngineHandler.AddBody and route == "AddedPartToRenderPool" then
					activeEngineHandler.AddBody(data)
				end
			elseif route == "RemovedPartFromRenderPool" then
				if activeEngineHandler and activeEngineHandler.RemoveBody then
					activeEngineHandler.RemoveBody(data)
				end
			elseif route == "UpdateSoftBody" then
				if activeEngineHandler and activeEngineHandler.UpdateSoftBody then
					activeEngineHandler.UpdateSoftBody(data)
				end
			end
		end
	end)

	if engines["Jolt"] and not activeEngineName then
		UnifiedPhysicsService:SetPrimaryEngine("Jolt")
	end
end

return UnifiedPhysicsService
