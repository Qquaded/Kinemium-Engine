local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local UserInputService = require("@UserInputService")
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local InputActionService = Instance.new("InputActionService")
local inputActions = {} -- [actionName] = { inputs?, callback?, values = { [player] = value } }
InputActionService.ExplorerHidden = true
InputActionService._Intents = Enum.PluginIntents.Input

local ActionBegan = signal.new()
local ActionEnded = signal.new()

function InputActionService:BindAction(actionName, callback, ...)
	local inputs = { ... }
	local prev = inputActions[actionName]
	inputActions[actionName] = {
		inputs = inputs,
		callback = callback,
		values = (prev and prev.values) or {},
	}
end

function InputActionService:GetActionValue(actionName, player)
	local action = inputActions[actionName]
	if not action or not action.values then
		return nil
	end
	return action.values[player or "LocalPlayer"]
end

function InputActionService:SetActionValue(actionName, player, value)
	local action = inputActions[actionName]
	if not action then
		action = {}
		inputActions[actionName] = action
	end
	if not action.values then
		action.values = {}
	end
	action.values[player or "LocalPlayer"] = value
end

function InputActionService:SetLocalMovementBasisYaw(yaw)
	self._localMovementBasisYaw = yaw
end

function InputActionService:SampleLocalInputs()
	local yaw = self._localMovementBasisYaw or 0
	local cameraBasis = CFrame.fromEulerAnglesYXZ(yaw, 0, 0)
	local f = cameraBasis:GetLookVector()
	local r = cameraBasis:GetRightVector()
	local flatF = Vector3.new(f.X, 0, f.Z)
	local flatR = Vector3.new(r.X, 0, r.Z)
	if flatF:Magnitude() > 1e-4 then
		flatF = flatF:Unit()
	end
	if flatR:Magnitude() > 1e-4 then
		flatR = flatR:Unit()
	end

	local moveInput = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveInput += Vector3.new(0, 0, -1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveInput += Vector3.new(0, 0, 1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveInput += Vector3.new(-1, 0, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveInput += Vector3.new(1, 0, 0)
	end
	if moveInput:Magnitude() > 1e-4 then
		moveInput = moveInput:Unit()
	end

	local worldMove = flatR * moveInput.X + flatF * -moveInput.Z

	return {
		MoveX = worldMove.X,
		MoveZ = worldMove.Z,
		Jump = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0,
		Sprint = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0,
		Crouch = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0,
	}
end

InputActionService:SetProperties({
	ActionBegan = ActionBegan,
	ActionEnded = ActionEnded,
	SetLocalMovementBasisYaw = InputActionService.SetLocalMovementBasisYaw,
	SampleLocalInputs = InputActionService.SampleLocalInputs,
})

return InputActionService
