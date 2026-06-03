local Shared = require("./Shared")
local Enum = require("@EnumMap")

local NetworkOwnership = {}

local DEFAULT_OWNERSHIP_RADIUS = 96
local DEFAULT_OWNERSHIP_RELEASE_RADIUS = 144
local DEFAULT_TRANSFER_COOLDOWN = 1.5
local DEFAULT_VELOCITY_THRESHOLD = 0.75
local DEFAULT_STEAL_MARGIN = 16

local function isBasePart(object)
	return object ~= nil
		and (object.BaseClass == "BasePart" or object.ClassName == "Part" or object.ClassName == "MeshPart")
end

local function asNumber(value, fallback)
	if type(value) ~= "number" or value ~= value then
		return fallback
	end

	return value
end

local function getPartPosition(part)
	if part == nil then
		return nil
	end

	local cframe = part.CFrame
	if cframe and cframe.Position then
		return cframe.Position
	end

	return part.Position
end

local function findFirstBasePart(root)
	if root == nil then
		return nil
	end

	if isBasePart(root) then
		return root
	end

	if root.PrimaryPart and root.PrimaryPart.Parent ~= nil then
		return root.PrimaryPart
	end

	if root.FindFirstChild then
		local torso = root:FindFirstChild("Torso")
		if torso and isBasePart(torso) then
			return torso
		end
	end

	if root.GetDescendants then
		for _, descendant in ipairs(root:GetDescendants()) do
			if isBasePart(descendant) then
				return descendant
			end
		end
	end

	return nil
end

local function getEnabledController(root)
	if root == nil or root.FindFirstChildOfClass == nil then
		return nil
	end

	local controller = root:FindFirstChildOfClass("NetworkController")
	if controller and controller.Enabled ~= false then
		return controller
	end

	return nil
end

local function parsePropertyList(rawList)
	local whitelist = {}
	for prop in string.gmatch(rawList or "", "[^,%s]+") do
		whitelist[prop] = true
	end
	return whitelist
end

local function getLocalPlayer(game)
	if IsClient ~= true or not game or not game.GetService then
		return nil
	end

	local players = game:GetService("Players")
	return players and players.LocalPlayer or nil
end

local function matchesPlayerCharacter(root, player)
	if root == nil or player == nil then
		return false
	end

	if player.Character and player.Character == root then
		return true
	end

	if root.ClassName ~= "Model" then
		return false
	end

	local uid = root.GetAttribute and root:GetAttribute("__characterUserId")
	if type(uid) == "number" and uid == player.UserId then
		return true
	end

	return root.Name == player.Name
end

function NetworkOwnership.GetControllerRoot(object)
	local current = object
	while current do
		if current.ClassName == "Workspace" or current.ClassName == "DataModel" then
			break
		end
		local controller = getEnabledController(current)
		if controller then
			return current, controller
		end
		current = current.Parent
	end

	return nil, nil
end

function NetworkOwnership.GetController(object)
	local _, controller = NetworkOwnership.GetControllerRoot(object)
	return controller
end

function NetworkOwnership.GetAuthorityRoot(object)
	return select(1, NetworkOwnership.GetControllerRoot(object)) or object
end

function NetworkOwnership.IsStateAuthorityObject(object)
	local root, controller = NetworkOwnership.GetControllerRoot(object)
	return root == object and controller ~= nil and controller.ReplicatePhysics ~= false
end

--- True for BaseParts owned by the player that sit under a NetworkController with replicated physics
--- (e.g. HumanoidRootPart). IsStateAuthorityObject is only true for the controller *root* Model.
function NetworkOwnership.IsOwnedReplicatedPhysicsPart(object, player)
	if not object or not player then
		return false
	end
	if not isBasePart(object) then
		return false
	end
	if not NetworkOwnership.IsOwnedByPlayer(object, player) then
		return false
	end
	local _, controller = NetworkOwnership.GetControllerRoot(object)
	if controller ~= nil then
		return controller.ReplicatePhysics ~= false
	end

	return object.Anchored == false
end

function NetworkOwnership.IsOwnedByPlayer(object, player)
	if not object or not player then
		return false
	end

	local root = NetworkOwnership.GetAuthorityRoot(object)
	if root == nil then
		return false
	end

	if root.NetworkOwner == player then
		return true
	end

	return matchesPlayerCharacter(root, player)
end

function NetworkOwnership.GetOwningPlayer(object)
	local root = NetworkOwnership.GetAuthorityRoot(object)
	if not root then
		return nil
	end

	return root.NetworkOwner
end

function NetworkOwnership.GetWorldPosition(object)
	if object == nil then
		return nil
	end

	if isBasePart(object) then
		return getPartPosition(object)
	end

	local primary = findFirstBasePart(object)
	return getPartPosition(primary)
end

function NetworkOwnership.GetPlayerFocusPart(player)
	if not player then
		return nil
	end

	return findFirstBasePart(player.Character)
end

function NetworkOwnership.GetPlayerFocusPosition(player)
	return NetworkOwnership.GetWorldPosition(NetworkOwnership.GetPlayerFocusPart(player))
end

function NetworkOwnership.GetLinearSpeed(object)
	if object == nil then
		return 0
	end

	local root = NetworkOwnership.GetAuthorityRoot(object)
	local target = root
	if not isBasePart(target) then
		target = findFirstBasePart(target)
	end
	if not target then
		return 0
	end

	local linear = target.AssemblyLinearVelocity or target.Velocity
	if type(linear) == "table" and type(linear.Magnitude) == "function" then
		return linear:Magnitude()
	end

	return 0
end

function NetworkOwnership.GetAutoOwnershipConfig(object, controllerOverride)
	local root, controller = NetworkOwnership.GetControllerRoot(object)
	root = root or object
	controller = controllerOverride or controller

	local ownershipRadius = DEFAULT_OWNERSHIP_RADIUS
	local releaseRadius = DEFAULT_OWNERSHIP_RELEASE_RADIUS
	local transferCooldown = DEFAULT_TRANSFER_COOLDOWN
	local velocityThreshold = DEFAULT_VELOCITY_THRESHOLD
	local stealMargin = DEFAULT_STEAL_MARGIN

	if controller then
		ownershipRadius = math.max(0, asNumber(controller.OwnershipRadius, ownershipRadius))
		releaseRadius = math.max(ownershipRadius, asNumber(controller.OwnershipReleaseRadius, releaseRadius))
		transferCooldown = math.max(0, asNumber(controller.OwnershipTransferCooldown, transferCooldown))
		velocityThreshold = math.max(0, asNumber(controller.OwnershipVelocityThreshold, velocityThreshold))
		stealMargin = math.max(0, asNumber(controller.OwnershipStealMargin, stealMargin))
	end

	return {
		root = root,
		controller = controller,
		ownershipRadius = ownershipRadius,
		releaseRadius = releaseRadius,
		transferCooldown = transferCooldown,
		velocityThreshold = velocityThreshold,
		stealMargin = stealMargin,
	}
end

function NetworkOwnership.CanAutoAssignOwnership(object, controllerOverride)
	local config = NetworkOwnership.GetAutoOwnershipConfig(object, controllerOverride)
	local root = config.root
	local controller = config.controller
	if root == nil then
		return false
	end

	if controller then
		if controller.Enabled == false or controller.ReplicatePhysics == false then
			return false
		end

		if controller.AutoAssignOwnership == false or controller.LockOwner == true then
			return false
		end
	end

	if root.Anchored == true then
		return false
	end

	return NetworkOwnership.GetWorldPosition(root) ~= nil
end

function NetworkOwnership.SetOwner(object, player)
	local root = NetworkOwnership.GetAuthorityRoot(object)
	if root == nil then
		return false
	end

	root.NetworkOwner = player
	root.NetworkOwnerType = player and Enum.MachineNetworkOwner.Client or Enum.MachineNetworkOwner.Server
	return true
end

function NetworkOwnership.ClearOwner(object)
	return NetworkOwnership.SetOwner(object, nil)
end

function NetworkOwnership.GetConstraintParts(constraint)
	if not constraint then
		return nil, nil
	end

	local part0 = constraint.Part0
	local part1 = constraint.Part1

	if part0 == nil and constraint.Attachment0 then
		part0 = constraint.Attachment0.Parent
	end

	if part1 == nil and constraint.Attachment1 then
		part1 = constraint.Attachment1.Parent
	end

	return part0, part1
end

function NetworkOwnership.GetConstraintOwningPlayer(constraint)
	local part0, part1 = NetworkOwnership.GetConstraintParts(constraint)
	local owner0 = part0 and NetworkOwnership.GetOwningPlayer(part0) or nil
	local owner1 = part1 and NetworkOwnership.GetOwningPlayer(part1) or nil

	if owner0 and owner1 then
		if owner0 == owner1 then
			return owner0
		end
		return nil
	end

	return owner0 or owner1
end

function NetworkOwnership.ShouldSimulateConstraintForMachine(constraint, game)
	local part0, part1 = NetworkOwnership.GetConstraintParts(constraint)
	if not part0 or not part1 then
		return false
	end

	local owner0 = NetworkOwnership.GetOwningPlayer(part0)
	local owner1 = NetworkOwnership.GetOwningPlayer(part1)
	local authoritativeOwner

	if owner0 and owner1 then
		if owner0 == owner1 then
			authoritativeOwner = owner0
		else
			authoritativeOwner = false
		end
	else
		authoritativeOwner = owner0 or owner1
	end

	if authoritativeOwner == false or authoritativeOwner == nil then
		return IsServer == true
	end

	if IsClient ~= true then
		return false
	end

	local localPlayer = getLocalPlayer(game)
	return localPlayer ~= nil and localPlayer == authoritativeOwner
end

function NetworkOwnership.ShouldSimulatePhysicsForMachine(object, game)
	-- Editor/studio mode: neither server nor client, always simulate locally.
	-- This avoids expensive GetControllerRoot tree walks for every part every frame.
	if IsServer ~= true and IsClient ~= true then
		return true
	end

	local root, controller = NetworkOwnership.GetControllerRoot(object)
	local target = root or object
	if not target then
		return false
	end

	if controller and controller.ReplicatePhysics == false then
		return IsServer == true
	end

	local owner = target.NetworkOwner
	local localPlayer = getLocalPlayer(game)
	if owner == nil then
		if localPlayer and matchesPlayerCharacter(target, localPlayer) then
			return true
		end

		if IsServer == true and target.ClassName == "Model" and game and game.GetService then
			local ok, players = pcall(game.GetService, game, "Players")
			if ok and players then
				local matched = nil
				local uid = target.GetAttribute and target:GetAttribute("__characterUserId")
				if type(uid) == "number" and type(players.GetPlayerByUserId) == "function" then
					matched = players:GetPlayerByUserId(uid)
				end
				if not matched and type(players.GetPlayerByName) == "function" then
					matched = players:GetPlayerByName(target.Name)
				end
				if matched then
					return false
				end
			end
		end
		return IsServer == true
	end

	if IsClient ~= true or not game or not game.GetService then
		return false
	end

	return localPlayer ~= nil and (owner == localPlayer or matchesPlayerCharacter(target, localPlayer))
end

function NetworkOwnership.ShouldReplicateProperty(object, prop)
	local _, controller = NetworkOwnership.GetControllerRoot(object)
	if controller == nil or controller.ReplicateProperties == false then
		return false
	end
	if prop == "Parent" then
		return false
	end

	if not Shared.ShouldReplicatePropertyForObject(object, prop) then
		return false
	end

	local whitelist = parsePropertyList(controller.PropertyList)
	if next(whitelist) == nil then
		return true
	end

	return whitelist[prop] == true
end

return NetworkOwnership
