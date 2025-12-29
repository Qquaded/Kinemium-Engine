local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local baseplate = Instance.new("Part")
baseplate.CFrame = CFrame.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = game.Workspace

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
