local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")
local Vector2 = require("@Vector2")

local lib = raylib.lib
local structs = raylib.structs
local const = raylib.const

local propTable = {
	FieldOfView = 70,
	CFrame = CFrame.new(Vector3.new(3, 3, 3), Vector3.new(0, 0, 0)),
	Roll = 0, -- degrees
	Name = "Camera",
	CameraType = Enum.CameraType.Scriptable,
	CameraSubject = nil,
	Focus = CFrame.new(0, 0, 0),
}

local cameraSingleton = nil

return {
	class = "Camera",
	singleton = true,
	callback = function(instance, renderer)
		if cameraSingleton and not cameraSingleton.Destroyed then
			if cameraSingleton.CFrame == nil or cameraSingleton.CFrame.Position == nil then
				cameraSingleton.CFrame = propTable.CFrame
			end
			if cameraSingleton.FieldOfView == nil then
				cameraSingleton.FieldOfView = propTable.FieldOfView
			end
			if cameraSingleton.CameraType == nil then
				cameraSingleton.CameraType = propTable.CameraType
			end
			return cameraSingleton
		end

		instance:SetProperties(propTable)

		cameraSingleton = instance

		if IsHeadless then
			return instance
		end

		local camera = structs.Camera3D:new({
			position = vector.create(0, 0, 0),
			target = vector.create(0, 0, 0),
			up = vector.create(0, 1, 0),
			fovy = instance.FieldOfView,
			projection = const.CameraProjection.CAMERA_PERSPECTIVE,
		})

		instance._raylibcam = camera

		local function syncRaylibCamera()
			local camCF = instance.CFrame
			if camCF == nil or camCF.Position == nil then
				camCF = propTable.CFrame
				if camCF == nil or camCF.Position == nil then
					return
				end
				instance.CFrame = camCF
			end
			local rollRad = math.rad(instance.Roll or 0)

			instance.Position = camCF.Position
			local dpiScale = lib.GetWindowScaleDPI()
			instance.ViewportSize = Vector2.new(lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y)

			if instance.CameraType == Enum.CameraType.Scriptable then
				-- position
				zune.mem.writeVector3(camera, 0, vector.create(camCF.Position.X, camCF.Position.Y, camCF.Position.Z))

				-- target
				local look = camCF:GetLookVector()
				zune.mem.writeVector3(
					camera,
					12,
					vector.create(camCF.Position.X + look.X, camCF.Position.Y + look.Y, camCF.Position.Z + look.Z)
				)

				-- up
				local baseUp = Vector3.new(0, 1, 0) -- hardcoded reference up

				-- apply roll around forward
				local cosR, sinR = math.cos(rollRad), math.sin(rollRad)
				local right = look:Cross(baseUp):Unit()
				local up = Vector3.new(
					baseUp.X * cosR + right.X * sinR,
					baseUp.Y * cosR + right.Y * sinR,
					baseUp.Z * cosR + right.Z * sinR
				)

				zune.mem.writeVector3(camera, 24, vector.create(up.X, up.Y, up.Z))

				-- fov
				buffer.writef32(camera, 36, instance.FieldOfView)
			end
		end

		syncRaylibCamera()
		renderer.Hook.new("Renderstep", syncRaylibCamera)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
