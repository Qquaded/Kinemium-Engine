local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")

local lib = raylib.lib
local structs = raylib.structs
local const = raylib.const

local propTable = {
	FieldOfView = 70,
	CFrame = CFrame.new(0, 0, 0),
	Roll = 0, -- degrees
	Name = "Camera",
	CameraType = Enum.CameraType.Orbital,
	CameraSubject = nil,
	Focus = CFrame.new(0, 0, 0),
}

return {
	class = "Camera",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		local function update()
			local cf = instance.CFrame
			local roll = math.rad(instance.Roll)

			local baseUp = Vector3.new(0, 1, 0)

			local cosR = math.cos(roll)
			local sinR = math.sin(roll)

			local forward = cf:GetLookVector()
			local right = forward:Cross(baseUp)
			local up = baseUp * cosR + right * sinR + forward * (forward:Dot(baseUp)) * (1 - cosR)

			local camera = structs.Camera3D:new({
				position = vector.create(cf.Position.X, cf.Position.Y, cf.Position.Z),
				target = vector.create(cf.Position.X + forward.X, cf.Position.Y + forward.Y, cf.Position.Z + forward.Z),
				up = vector.create(up.X, up.Y, up.Z),
				fovy = instance.FieldOfView,
				projection = const.CameraProjection.CAMERA_PERSPECTIVE,
			})
			return camera
		end

		instance._raylibcam = update()

		instance.Changed:Connect(function(prop)
			if instance.CameraType == Enum.CameraType.Scriptable then
				if prop == "CFrame" or prop == "Roll" or prop == "FieldOfView" then
					instance._raylibcam = update()
				end
				return
			end

			-- non-scriptable cameras update differently (later)
		end)

		local activeCamera = instance._raylibcam

		instance.Position = instance.CFrame.Position

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
