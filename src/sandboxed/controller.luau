local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local InputActionService = game:GetService("InputActionService")

if RunService:IsServer() then
	return
end

if not RunService:IsClient() then
	return
end

local CAM_SENS = 0.35
local CAM_MIN_Y = -80
local CAM_MAX_Y = 80
local CAM_ZOOM_MIN = 0.1
local CAM_ZOOM_MAX = 50
local CAM_ZOOM_MUL = 1.15
local CAM_SENS_FP = 0.35

local ZERO = Vector3.new(0, 0, 0)

local function flushDelta()
	UserInputService:GetMouseDelta()
end

local CharacterModel
while not Players.LocalPlayer do
	task.wait()
end

local player = Players.LocalPlayer

if game.MultiplayerMode == Enum.MultiplayerMode.SinglePlayer and not RunService:IsClient() then
	CharacterModel = Instance.new("Model")
	CharacterModel.Name = player.Name
	CharacterModel.Parent = workspace

	local SHIRT_COLOR = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	local PANTS_COLOR = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	local HEAD_COLOR = Color3.fromRGB(255, 204, 153)

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = player.Name
	humanoid.WalkSpeed = player.WalkSpeed
	humanoid.JumpPower = player.JumpPower
	humanoid.JumpQueueWindow = 0.05
	humanoid.Parent = CharacterModel

	local networkController = Instance.new("NetworkController")
	networkController.Parent = CharacterModel

	humanoid:CreateDefaultRig({
		Character = CharacterModel,
		SpawnCFrame = CFrame.new(0, 20, 0),
		ShirtColor = SHIRT_COLOR,
		PantsColor = PANTS_COLOR,
		HeadColor = HEAD_COLOR,
		RootColor = Color3.new(0, 0, 0),
	})
	CharacterModel.PrimaryPart = humanoid.RootPart
end

local function findCharacterModelForPlayer(player)
	if not player then
		return nil
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if child.ClassName == "Model" and child.FindFirstChildOfClass then
			local humanoid = child:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local uid = child.GetAttribute and child:GetAttribute("__characterUserId")
				if type(uid) == "number" and uid == player.UserId then
					return child
				end
			end
		end
	end
	local byName = workspace:FindFirstChild(player.Name)
	if byName and byName.ClassName == "Model" and byName.FindFirstChildOfClass then
		if byName:FindFirstChildOfClass("Humanoid") then
			return byName
		end
	end
	return nil
end

local function resolveCharacter(player)
	local character = player.Character or findCharacterModelForPlayer(player)
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.RootPart then
		return nil
	end

	return character, humanoid
end

local zoomDist = 12
local character
local humanoid
local rootPart
local yaw
local pitch
local smoothCamPos
local rayParams = RaycastParams.new()

local function bindCharacter(nextCharacter, nextHumanoid)
	character = nextCharacter
	humanoid = nextHumanoid
	rootPart = humanoid.RootPart

	local rootLook = rootPart.CFrame:GetLookVector()
	yaw = math.atan2(-rootLook.X, -rootLook.Z)
	pitch = math.rad(15)
	smoothCamPos = rootPart.CFrame.Position + Vector3.new(0, 8, zoomDist)
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character }
end

local localPlayer = Players.LocalPlayer
while not localPlayer do
	task.wait()
	localPlayer = Players.LocalPlayer
end

character, humanoid = resolveCharacter(localPlayer)
while not character do
	task.wait()
	character, humanoid = resolveCharacter(localPlayer)
end
game.StopCameraInput = true

bindCharacter(character, humanoid)

local cursorDisabled = false

local function setCursorDisabled(disabled)
	if disabled == cursorDisabled then
		return
	end
	cursorDisabled = disabled
	if disabled then
		UserInputService:DisableCursor()
	else
		UserInputService:EnableCursor()
	end
end

UserInputService.MouseWheel:Connect(function(input)
	local delta = input and input.Delta or 0
	if delta > 0 then
		zoomDist = math.max(CAM_ZOOM_MIN, zoomDist / CAM_ZOOM_MUL)
	elseif delta < 0 then
		zoomDist = math.min(CAM_ZOOM_MAX, zoomDist * CAM_ZOOM_MUL)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local delta = UserInputService:GetMouseDelta()

	CAM_ZOOM_MIN = localPlayer.CameraMinZoomDistance
	CAM_ZOOM_MAX = localPlayer.CameraMaxZoomDistance

	if
		not character
		or not humanoid
		or character.Parent == nil
		or humanoid.Parent == nil
		or humanoid.RootPart == nil
	then
		local nextCharacter, nextHumanoid = resolveCharacter(localPlayer)
		if not nextCharacter then
			return
		end

		bindCharacter(nextCharacter, nextHumanoid)
	end

	rootPart = humanoid.RootPart or rootPart
	if not rootPart or rootPart.Parent == nil then
		return
	end

	local camera = workspace.Camera
	if not camera then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local isFirstPerson = zoomDist <= 0.5
	local rmb = UserInputService:IsMouseButtonDown(Enum.MouseButton.Right)

	local sens = isFirstPerson and CAM_SENS_FP or CAM_SENS

	if isFirstPerson or rmb then
		setCursorDisabled(true)
		yaw = yaw - math.rad(delta.X * sens)
		pitch = math.clamp(pitch - math.rad(delta.Y * sens), math.rad(CAM_MIN_Y), math.rad(CAM_MAX_Y))
	else
		setCursorDisabled(false)
		flushDelta()
	end

	local camRot = CFrame.fromEulerAnglesYXZ(yaw, pitch, 0)

	if isFirstPerson then
		local firstPersonPos = head.CFrame.Position + Vector3.new(0, 1, 0)
		smoothCamPos = firstPersonPos

		camera.CFrame = CFrame.new(firstPersonPos) * camRot
		rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.fromEulerAnglesYXZ(yaw, 0, 0)

		character.Head.Transparency = 1

		humanoid.TurnSpeed = 999
		humanoid:Face(Vector3.new(-math.sin(yaw), 0, -math.cos(yaw)))

		localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		localPlayer.CameraMode = Enum.CameraMode.Classic

		local focusPos = head.CFrame.Position
		local camOffset = camRot * Vector3.new(0, 0, zoomDist)
		local targetCamPos = focusPos + camOffset

		local rayVector = targetCamPos - focusPos
		local finalCamPos = targetCamPos
		if rayVector:Magnitude() > 1e-4 then
			local camHit = workspace:Raycast(focusPos, rayVector, rayParams)
			if camHit then
				finalCamPos = focusPos + rayVector:Unit() * math.max(camHit.Distance - 0.3, 0.1)
			end
		end

		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name == "HumanoidRootPart" then
					continue
				end
				part.Transparency = 0
			end
		end

		camera.CFrame = CFrame.new(finalCamPos, focusPos)

		humanoid.TurnSpeed = 18
		humanoid:ClearFacingDirection()
	end

	local moveInput = ZERO
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

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		humanoid:RequestJump()
	end

	if moveInput:Magnitude() > 1e-4 then
		moveInput = moveInput:Unit()
	end

	InputActionService:SetLocalMovementBasisYaw(yaw)
	local cameraBasis = CFrame.fromEulerAnglesYXZ(yaw, 0, 0)
	humanoid:MoveRelative(moveInput, cameraBasis)
	humanoid:SetSprinting(UserInputService:IsKeyDown(Enum.KeyCode.LeftShift))
end)
