local Instance = require("@Instance")
local Registry = require("@InstanceRegistry")
local signal = require("@Kinemium.signal")

local Mouse = require("@Mouse")
local Player = require("@Player")
local Enum = require("@EnumMap")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local HumanoidClass = require("@Humanoid")

local Players = Instance.new("Players")
local runtimeRenderer = nil
local runtimeGame = nil

Players.PlayerAdded = signal.new()
Players.MaxPlayers = 20
Players.PlayerRemoving = signal.new()
Players._Intents = Enum.PluginIntents.Network

local playerRegistry = {}
Players.Players = playerRegistry

-- client
Players.LocalPlayer = nil
Players.SetupClient = false

if not IsServer then
	Players.SetupClient = true
end

Players.InitRenderer = function(renderer, signal, game)
	local function newObject(className, datamodel)
		local ok, created = pcall(Registry.new, className, renderer, game)
		if ok and created then
			return created
		end
		return Instance.new(className)
	end

	local function CreatePlayer(name, userId): Instance
		local player = newObject("Player", game)

		if not player.CharacterAdded or not player.CharacterRemoving then
			player = Player.callback(player)
		end

		player.Name = name
		player.UserId = userId
		player.Parent = Players
		player.Character = nil

		return player
	end

	local function ensureHumanoid(humanoid, datamodel)
		if humanoid and humanoid.ClassName == "Humanoid" and humanoid.CreateDefaultRig then
			return humanoid
		end

		humanoid = humanoid or Instance.new("Humanoid")
		if HumanoidClass and HumanoidClass.callback and not humanoid.CreateDefaultRig then
			HumanoidClass.callback(humanoid, runtimeRenderer, datamodel or runtimeGame)
		end
		return humanoid
	end

	local function assignCharacter(player, character)
		local previous = player.Character
		if previous and previous ~= character and player.CharacterRemoving then
			player.CharacterRemoving:Fire(previous)
		end

		player.Character = character

		if character and player.CharacterAdded then
			player.CharacterAdded:Fire(character)
		end
	end

	local function attachCharacterNetworkController(characterModel, player)
		local networkController = newObject("NetworkController", runtimeGame)
		networkController.Parent = characterModel

		characterModel.NetworkOwner = player
		characterModel.NetworkOwnerType = Enum.MachineNetworkOwner.Client

		return networkController
	end

	function Players:LoadCharacter(player, datamodel)
		print(`[Players] Loading character for {player.Name}...`)
		if not IsServer then
			print(`[Players] LoadCharacter ignored on client for {player.Name}`)
			return
		end

		local SpawnCFrame = CFrame.new(0, 50, 0)
		for _, part in pairs(datamodel.Workspace:GetChildren()) do
			if part.Name == "Spawn" then
				local partCF = part.CFrame
				SpawnCFrame = CFrame.new(partCF.Position.X, partCF.Position.Y + 10, partCF.Position.Z)
			end
		end

		local starterCharacter = datamodel.StarterPlayer.StarterCharacter
		local CharacterModel

		if starterCharacter then
			CharacterModel = starterCharacter:Clone()
			CharacterModel.Name = player.Name
			CharacterModel:SetAttribute("__characterUserId", player.UserId)
			attachCharacterNetworkController(CharacterModel, player)

			local humanoid = CharacterModel:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				humanoid = ensureHumanoid(newObject("Humanoid", datamodel), datamodel)
				humanoid.Parent = CharacterModel
			end
			humanoid.DisplayName = player.Name
			humanoid.WalkSpeed = player.WalkSpeed
			humanoid.JumpPower = player.JumpPower

			humanoid.Character = CharacterModel
			local root = CharacterModel:FindFirstChild("HumanoidRootPart") or CharacterModel.PrimaryPart
			if root then
				humanoid.RootPart = root
				root.CFrame = SpawnCFrame
			end

			humanoid:RestoreRig()

			CharacterModel.PrimaryPart = humanoid.RootPart or root
		else
			CharacterModel = newObject("Model", datamodel)
			CharacterModel.Name = player.Name
			CharacterModel:SetAttribute("__characterUserId", player.UserId)
			attachCharacterNetworkController(CharacterModel, player)

			local humanoid = ensureHumanoid(newObject("Humanoid", datamodel), datamodel)
			humanoid.DisplayName = player.Name
			humanoid.WalkSpeed = player.WalkSpeed
			humanoid.JumpPower = player.JumpPower
			humanoid.Parent = CharacterModel

			humanoid:CreateDefaultRig({
				Character = CharacterModel,
				SpawnCFrame = SpawnCFrame,
				ShirtColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
				PantsColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)),
				HeadColor = Color3.fromRGB(255, 204, 153),
				RootColor = Color3.new(0, 0, 0),
			})
			CharacterModel.PrimaryPart = humanoid.RootPart
		end

		CharacterModel.Parent = datamodel.Workspace
		assignCharacter(player, CharacterModel)
		return CharacterModel
	end

	function Players:AddPlayer(name, userId, datamodel, options)
		print(`[Players] Adding player {name} ({userId})...`)
		if #playerRegistry >= self.MaxPlayers then
			log("Max players reached!")
			return
		end
		local player = CreatePlayer(name, userId)
		table.insert(playerRegistry, player)

		if IsServer and not (options and options.noCharacter) then
			self:LoadCharacter(player, datamodel)
		end

		self.PlayerAdded:Fire(player)
		return player
	end

	function Players:RemovePlayer(player)
		for i, p in ipairs(playerRegistry) do
			if p == player then
				table.remove(playerRegistry, i)
				print(`[Players] Removed player {player.Name} (UserId: {player.UserId}) from registry`)
				break
			end
		end
		self.PlayerRemoving:Fire(player)
	end

	function Players:RemovePlayerByUserId(userId)
		for i, p in ipairs(playerRegistry) do
			if p.UserId == userId then
				table.remove(playerRegistry, i)
				print(`[Players] Removed player {p.Name} (UserId: {userId}) from registry by UserId`)
				self.PlayerRemoving:Fire(p)
				return true
			end
		end
		return false
	end

	function Players:GetPlayerFromCharacter(character)
		for _, player in ipairs(playerRegistry) do
			if player.Character == character then
				return player
			end
		end
		return nil
	end

	function Players:GetPlayerByName(name)
		for _, p in ipairs(playerRegistry) do
			if p.Name == name then
				return p
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.ClassName == "Player" and child.Name == name then
				return child
			end
		end
	end

	function Players:GetPlayerByUserId(userId)
		for _, p in ipairs(playerRegistry) do
			if p.UserId == userId then
				return p
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.ClassName == "Player" and child.UserId == userId then
				return child
			end
		end
	end

	function Players:GetPlayers()
		return playerRegistry
	end

	function Players:GetPlayerByClientAddress(address, port)
		for _, player in ipairs(playerRegistry) do
			if player.client and player.client.address == address and player.client.port == port then
				return player
			end
		end
		return nil
	end

	if Players.SetupClient == true then
		local name = GetFlagValue("username") or "Player"
		Players.LocalPlayer = CreatePlayer(name, 1)

		Players.LocalPlayer:SetProperties({
			GetMouse = function(self)
				if not self.MouseInstance then
					local mouse_instance = newObject("Mouse", game)
					if mouse_instance.ClassName ~= "Mouse" or not mouse_instance.Button1Down then
						mouse_instance = Mouse.callback(mouse_instance, renderer, game)
					end
					self.MouseInstance = mouse_instance
				end
				return self.MouseInstance
			end,
		})
	end
	return Players
end

return Players
