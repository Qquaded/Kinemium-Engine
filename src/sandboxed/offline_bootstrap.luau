-- offline_bootstrap.luau
-- Spawns a local character when running in offline client mode.
-- In offline mode there is no server, so we create the character directly on the client.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return
end

if not FlagExists("offline") then
	return
end

-- Wait for local player to be assigned
while not Players.LocalPlayer do
	task.wait()
end

local player = Players.LocalPlayer

log("[Offline] Spawning character for " .. tostring(player.Name))

local SHIRT_COLOR = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
local PANTS_COLOR = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
local HEAD_COLOR = Color3.fromRGB(255, 204, 153)

local CharacterModel = Instance.new("Model")
CharacterModel.Name = player.Name
CharacterModel:SetAttribute("__characterUserId", player.UserId)

-- Ownership must be established before the humanoid steps.
-- NetworkOwnership.ShouldSimulatePhysicsForMachine walks up from RootPart
-- looking for a NetworkController; without one it falls through to checking
-- RootPart.NetworkOwner (nil) and returns false  preventing all movement.
-- Setting NetworkOwner on the Model root and parenting a NetworkController
-- to it makes the ownership check resolve correctly for offline play.
CharacterModel.NetworkOwner = player
local networkController = Instance.new("NetworkController")
networkController.Parent = CharacterModel

local humanoid = Instance.new("Humanoid")
humanoid.DisplayName = player.Name
humanoid.WalkSpeed = player.WalkSpeed
humanoid.JumpPower = player.JumpPower
humanoid.JumpQueueWindow = 0.05
humanoid.Parent = CharacterModel

-- Find a spawn location if one exists
local SpawnCFrame = CFrame.new(0, 20, 0)
for _, part in pairs(workspace:GetChildren()) do
	if part.Name == "Spawn" and part.CFrame then
		local partCF = part.CFrame
		SpawnCFrame = CFrame.new(partCF.Position.X, partCF.Position.Y + 10, partCF.Position.Z)
		break
	end
end

humanoid:CreateDefaultRig({
	Character = CharacterModel,
	SpawnCFrame = SpawnCFrame,
	ShirtColor = SHIRT_COLOR,
	PantsColor = PANTS_COLOR,
	HeadColor = HEAD_COLOR,
	RootColor = Color3.new(0, 0, 0),
})
CharacterModel.PrimaryPart = humanoid.RootPart
CharacterModel.Parent = workspace

-- Assign the character to the local player and fire events
local previous = player.Character
if previous and previous ~= CharacterModel and player.CharacterRemoving then
	player.CharacterRemoving:Fire(previous)
end

player.Character = CharacterModel

if player.CharacterAdded then
	player.CharacterAdded:Fire(CharacterModel)
end

log("[Offline] Character spawned: " .. CharacterModel.Name)
