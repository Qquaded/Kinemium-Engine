local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local baseplate = Instance.new("Part")
baseplate.CFrame = CFrame.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = game.Workspace

local ShadowPart = Instance.new("Part")
ShadowPart.Anchored = true
ShadowPart.CFrame = CFrame.new(0, 10, 0)
ShadowPart.Size = Vector3.new(4, 4, 4)
ShadowPart.Parent = workspace

--[[
local part = Instance.new("Part")

task.wait(2)
part.Anchored = false
part.Parent = workspace

local attach = Instance.new("Attachment")
attach.Position = part
attach.Parent = part

local VectorForce = Instance.new("VectorForce")
VectorForce.Force = Vector3.new(0, 5, 0)
VectorForce.Attachment0 = attach
VectorForce.Parent = attach

local lightTest = Instance.new("Part")
lightTest.Size = Vector3.new(1, 1, 1)
lightTest.CFrame = CFrame.new(0, 10, 0)
lightTest.Color = Color3.new(1, 1, 1)
lightTest.Anchored = true
lightTest.Parent = workspace

local PointLight = Instance.new("PointLight")
PointLight.Color = Color3.new(1, 0, 0)
PointLight.Intensity = 100
PointLight.Range = 10
PointLight.Position = Vector3.new(0, -5, 0)
PointLight.Parent = lightTest

local angle = 0
local radius = 10
local speed = 2

RunService.Heartbeat:Connect(function(dt)
	angle = angle + speed * dt
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	local newPos = Vector3.new(x, 10, z)

	lightTest.CFrame = CFrame.new(newPos)
	PointLight.Brightness = math.random()
	PointLight.Position = newPos
end)
--]]

local fileService = game:GetService("KineFileService")

--[[
local success, result = pcall(function()
	local savedGame = fileService.Save("MyAwesomeGame.kine")
	if savedGame then
		print("Game saved successfully!")

		savedGame:ToExe()
		print("Executable built as KinemiumRuntime.exe")
	end
end)

if not success then
	print(result)
end
--]]
