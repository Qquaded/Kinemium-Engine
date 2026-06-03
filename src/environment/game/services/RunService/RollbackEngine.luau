local RollbackEngine = {}
local history = {} -- [tick] = { [instance] = { property = value } }
local maxHistory = 120 -- ~2 seconds at 60Hz
local trackedInstances = {} -- instance = true

local trackedClasses = {
	BasePart = { "CFrame", "AssemblyLinearVelocity", "AssemblyAngularVelocity" },
	Humanoid = { "Jump", "Sit", "MoveDirection" },
}

function RollbackEngine:CaptureState(tick, instances)
	local data = {}
	local targetInstances = instances or trackedInstances
	for instance in pairs(targetInstances) do
		local class = instance.ClassName
		local props = trackedClasses[class]
		if not props and instance:IsA("BasePart") then
			props = trackedClasses.BasePart
		end

		if props then
			local state = {}
			for _, prop in ipairs(props) do
				state[prop] = instance[prop]
			end
			data[instance] = state
		end
	end
	history[tick] = data

	local oldestTick = tick - maxHistory
	if history[oldestTick] then
		history[oldestTick] = nil
	end
end

function RollbackEngine:SetTracked(instance, tracked)
	if tracked then
		trackedInstances[instance] = true
	else
		trackedInstances[instance] = nil
	end
end

function RollbackEngine:RestoreState(tick)
	local data = history[tick]
	if not data then
		return false
	end

	for instance, state in pairs(data) do
		for prop, value in pairs(state) do
			instance[prop] = value
		end
	end
	return true
end

function RollbackEngine:GetState(tick, instance)
	local data = history[tick]
	if not data then
		return nil
	end
	return data[instance]
end

return RollbackEngine
