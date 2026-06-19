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

local texture = Instance.new("Texture")
texture.Face = Enum.NormalId.Top
texture.Texture = "./src/assets/materials/uncompressed/debug/albedo.png"
texture.Parent = baseplate

local SpawnLocation = Instance.new("SpawnLocation")
SpawnLocation.Anchored = true
SpawnLocation.CFrame = CFrame.new(0, 3, 0)
SpawnLocation.Size = Vector3.new(1, 1, 1)
SpawnLocation.Parent = workspace

local Part = Instance.new("Part")
Part.CFrame = CFrame.new(0, 0, 0)
Part.Size = Vector3.new(5, 0.5, 5)
Part.Anchored = true
Part.Color = Color3.new(1, 1, 1)
Part.Material = Enum.Material.SmoothPlastic
Part.Parent = workspace

local Decal = Instance.new("Decal")
Decal.Face = Enum.NormalId.Top
Decal.ColorMapContent = "./src/assets/icon/spawn.png"
Decal.Wrap = true
Decal.Parent = Part
