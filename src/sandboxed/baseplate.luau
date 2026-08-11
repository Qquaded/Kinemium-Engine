-- engine isnt server nor client? its in editor mode then!
if IsServer then
	return
end

if IsClient then
	return
end

local baseplate = Instance.new("Part")
baseplate.CFrame = CFrame.new(0, -8, 0)
baseplate.Size = Vector3.new(1000, 16, 1000)
baseplate.Name = "Baseplate"
baseplate.Material = Enum.Material.SmoothPlastic
baseplate.Parent = workspace
baseplate.Anchored = true

local spawnLocation = Instance.new("Part")
spawnLocation.CFrame = CFrame.new(0, 0, 0)
spawnLocation.Size = Vector3.new(6, 1, 6)
spawnLocation.Name = "SpawnLocation"
spawnLocation.Anchored = true
spawnLocation.Parent = workspace

local Decal = Instance.new("Decal")
Decal.Texture = "./src/assets/icon/spawn.png"
Decal.Parent = spawnLocation
