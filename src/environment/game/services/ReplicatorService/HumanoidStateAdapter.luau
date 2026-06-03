local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local HumanoidStateAdapter = {}

local VELOCITY_QUANTIZATION = 8
local FACING_QUANTIZATION = 64

local function quantize(value, scale)
	return math.round((value or 0) * scale) / scale
end

local function vectorToTable(value, scale)
	if type(value) ~= "table" or type(value.X) ~= "number" then
		return nil
	end

	return {
		type = "Vector3",
		__type = "Vector3",
		X = quantize(value.X, scale),
		Y = quantize(value.Y, scale),
		Z = quantize(value.Z, scale),
	}
end

local function vecEqual(a, b, threshold)
	if a == nil and b == nil then
		return true
	end
	if a == nil or b == nil then
		return false
	end
	local av = Vector3.FromTable(a)
	local bv = Vector3.FromTable(b)
	return (av - bv):MagnitudeSquared() <= (threshold or 0.01)
end

function HumanoidStateAdapter.matches(object)
	return object and (object.class == "Humanoid" or object.ClassName == "Humanoid")
end

function HumanoidStateAdapter.capture(humanoid)
	local humanoidState = humanoid.State or 0
	if type(humanoidState) == "table" then
		humanoidState = humanoidState.Name or humanoidState.Value or 0
	end

	return {
		type = "Humanoid",
		id = humanoid.NetworkId,
		stance = humanoid.Stance or "default",
		state = humanoidState,
		sprinting = humanoid.Sprinting == true,
		crouching = humanoid.Crouching == true,
		velocity = vectorToTable(humanoid.MoveVelocity, VELOCITY_QUANTIZATION),
		facingDir = vectorToTable(humanoid.FacingDirection, FACING_QUANTIZATION),
	}
end

function HumanoidStateAdapter.apply(humanoid, state)
	if state.stance ~= nil then
		humanoid.Stance = state.stance
	end
	if state.state ~= nil then
		if type(state.state) == "string" and Enum.HumanoidStateType and Enum.HumanoidStateType[state.state] then
			humanoid.State = Enum.HumanoidStateType[state.state]
		else
			humanoid.State = state.state
		end
	end
	if state.sprinting ~= nil then
		humanoid.Sprinting = state.sprinting
	end
	if state.crouching ~= nil then
		humanoid.Crouching = state.crouching
	end
	if state.velocity then
		humanoid.MoveVelocity = Vector3.FromTable(state.velocity)
	end
	if state.facingDir then
		humanoid.FacingDirection = Vector3.FromTable(state.facingDir)
	end
end

function HumanoidStateAdapter.equals(a, b)
	if a.id ~= b.id then
		return false
	end
	if a.stance ~= b.stance then
		return false
	end
	if a.state ~= b.state then
		return false
	end
	if a.sprinting ~= b.sprinting then
		return false
	end
	if a.crouching ~= b.crouching then
		return false
	end
	if not vecEqual(a.velocity, b.velocity, 0.25) then
		return false
	end
	if not vecEqual(a.facingDir, b.facingDir, 0.01) then
		return false
	end
	return true
end

return HumanoidStateAdapter
