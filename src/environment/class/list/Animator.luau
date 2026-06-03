-- description: "Manages animation playback, blending, and control for animated objects."
local signal = require("@Kinemium.signal")

-- description: "Copies."
-- args: "tbl: table"
local function copy(tbl)
	local out = {}
	for k, v in pairs(tbl or {}) do
		out[k] = v
	end
	return out
end

-- description: "Merges pose."
-- args: "basePose: any, layerPose: any"
local function mergePose(basePose, layerPose)
	if type(layerPose) ~= "table" then
		return basePose
	end

	for bindingName, bindingPose in pairs(layerPose) do
		if type(bindingPose) == "table" and type(bindingPose.ToTable) ~= "function" then
			local target = basePose[bindingName]
			if type(target) ~= "table" or type(target.ToTable) == "function" then
				target = {}
				basePose[bindingName] = target
			end
			for segmentName, segmentPose in pairs(bindingPose) do
				target[segmentName] = segmentPose
			end
		else
			basePose[bindingName] = bindingPose
		end
	end

	return basePose
end

local propTable = {
	Name = "Animator",
	Clock = 0,
	SpeedScale = 1,
	UseDefaultAnimations = true,
	PoseProvider = nil,
	DefaultProvider = nil,
	-- NOTE: PoseLayers, State, and AnimationPlayed are intentionally
	-- NOT in this shared table; they are created fresh per instance below.
}

return {
	class = "Animator",
	callback = function(instance)
		instance:SetProperties(propTable)
		instance.AnimationPlayed = signal.new()
		instance.PoseLayers = {}
		instance.State = {}

		-- description: "Sets the Pose Provider."
		-- args: "provider: number"
		function instance:SetPoseProvider(provider)
			instance.PoseProvider = provider
		end

		-- description: "Adds a pose layer."
		-- args: "name: string, layer: number"
		function instance:AddPoseLayer(name, layer)
			local layers = copy(instance.PoseLayers)
			layers[name] = layer
			instance.PoseLayers = layers
		end

		-- description: "Removes a pose layer."
		-- args: "name: string"
		function instance:RemovePoseLayer(name)
			local layers = copy(instance.PoseLayers)
			layers[name] = nil
			instance.PoseLayers = layers
		end

		-- description: "Sets the Default Provider."
		-- args: "provider: number"
		function instance:SetDefaultProvider(provider)
			instance.DefaultProvider = provider
		end

		-- description: "Resets clock."
		-- args: "value: number"
		function instance:ResetClock(value)
			instance.Clock = value or 0
		end

		-- description: "Advances."
		-- args: "dt: number"
		function instance:Advance(dt)
			dt = type(dt) == "number" and dt or 0
			local newClock = (instance.Clock or 0) + dt * (instance.SpeedScale or 1)
			instance.Clock = newClock
			return newClock
		end

		-- description: "Sets the State Value."
		-- args: "key: number, value: number"
		function instance:SetStateValue(key, value)
			local stateTable = copy(instance.State)
			stateTable[key] = value
			instance.State = stateTable
		end

		-- description: "Gets the Stat eValue."
		-- args: "key: number"
		function instance:GetStateValue(key)
			local stateTable = instance.State or {}
			return stateTable[key]
		end

		-- description: "Gets the Pose."
		-- args: "target: table, context: table"
		function instance:GetPose(target, context)
			local pose = instance._cachedPose
			if not pose then
				pose = {}
				instance._cachedPose = pose
			else
				for k, v in pairs(pose) do
					if type(v) == "table" and type(v.ToTable) ~= "function" then
						table.clear(v)
					else
						pose[k] = nil
					end
				end
			end

			local defaultProvider = instance.DefaultProvider
			if instance.UseDefaultAnimations ~= false and type(defaultProvider) == "function" then
				pose = mergePose(pose, defaultProvider(instance, target, context))
			end

			local provider = instance.PoseProvider
			if type(provider) == "function" then
				pose = mergePose(pose, provider(instance, target, context))
			end

			for _, layer in pairs(instance.PoseLayers or {}) do
				if type(layer) == "function" then
					pose = mergePose(pose, layer(instance, target, context))
				elseif type(layer) == "table" then
					pose = mergePose(pose, layer)
				end
			end

			return pose
		end

		-- description: "Steps animation."
		-- args: "target: table, context: table"
		function instance:StepAnimation(target, context)
			local runtimeContext
			if type(context) == "table" then
				runtimeContext = context
			else
				runtimeContext = {}
			end

			if runtimeContext.advanceClock ~= false then
				instance:Advance(runtimeContext.dt or 0)
			end

			if runtimeContext.clock == nil then
				runtimeContext.clock = instance.Clock
			end
			runtimeContext.animatorState = instance.State

			local pose = instance:GetPose(target, runtimeContext)
			instance.AnimationPlayed:Fire(target, runtimeContext, pose)
			return pose
		end

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
