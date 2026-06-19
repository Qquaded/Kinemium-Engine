-- description: "Defines the position, orientation, and rendering settings used to view the world."

local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")
local Vector2 = require("@Vector2")

_G.SecurityCapabilities = Enum.SecurityCapabilities.Internals

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

			-- sync props to actual Camera object
			-- position
			zune.mem.writeVector3(camera, 0, vector.create(camCF.Position.X, camCF.Position.Y, camCF.Position.Z))

			-- target
			local look = camCF:GetLookVector()
			zune.mem.writeVector3(
				camera,
				12,
				camCF + look
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

			if instance.CameraType == Enum.CameraType.Scriptable then
				-- we aren't gonna do anything here, the user script will control it
			elseif instance.CameraType == Enum.CameraType.Orbital then
				if not instance._orbital then
					local startPos = (instance.CFrame and instance.CFrame.Position) or Vector3.new(3, 3, 3)
					local subject = instance.CameraSubject
					local pivot = (subject and subject:IsA("BasePart") and subject.Position) or Vector3.new(0, 0, 0)
					local offset = startPos - pivot
					local r = offset:Magnitude()
					if r < 0.1 then
						r = 8
					end

					instance._orbital = {
						yaw = math.atan2(-offset.X, -offset.Z),
						pitch = math.asin(math.clamp(offset.Y / r, -1, 1)),
						radius = r,
					}
				end

				local orb = instance._orbital
				local subject = instance.CameraSubject
				local pivot = (subject and subject.Position) or Vector3.new(0, 0, 0)

				local delta = lib.GetMouseDelta()
				local rmb = lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_RIGHT)
				local wheel = lib.GetMouseWheelMove()

				if rmb then
					orb.yaw = orb.yaw - math.rad(delta.x * 0.35)
					orb.pitch = math.clamp(orb.pitch - math.rad(delta.y * 0.35), math.rad(-80), math.rad(80))
				end

				if wheel ~= 0 then
					local CAM_ZOOM_MUL = 1.15
					if wheel > 0 then
						orb.radius = math.max(1, orb.radius / CAM_ZOOM_MUL)
					else
						orb.radius = math.min(200, orb.radius * CAM_ZOOM_MUL)
					end
				end

				local cosP = math.cos(orb.pitch)
				local camOffset = Vector3.new(
					orb.radius * cosP * -math.sin(orb.yaw),
					orb.radius * math.sin(orb.pitch),
					orb.radius * cosP * -math.cos(orb.yaw)
				)

				instance.Focus = CFrame.new(pivot)
				instance.CFrame = CFrame.new(pivot + camOffset, pivot)
			elseif instance.CameraType == Enum.CameraType.Follow then
				if not instance._follow then
					local startPos = (instance.CFrame and instance.CFrame.Position) or Vector3.new(3, 3, 3)
					local subject = instance.CameraSubject
					local pivot = (subject and subject.Position) or Vector3.new(0, 0, 0)
					local offset = startPos - pivot
					local r = offset:Magnitude()
					if r < 0.1 then
						r = 8
					end

					instance._follow = {
						yaw = math.atan2(-offset.X, -offset.Z),
						pitch = math.asin(math.clamp(offset.Y / r, -1, 1)),
						radius = r,
						lastPivot = pivot,
					}
				end

				local flw = instance._follow
				local subject = instance.CameraSubject
				local pivot = (subject and subject.Position) or Vector3.new(0, 0, 0)

				local delta = lib.GetMouseDelta()
				local rmb = lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_RIGHT)
				local wheel = lib.GetMouseWheelMove()

				if rmb then
					flw.yaw = flw.yaw - math.rad(delta.x * 0.35)
					flw.pitch = math.clamp(flw.pitch - math.rad(delta.y * 0.35), math.rad(-80), math.rad(80))
					flw.lastPivot = pivot
				else
					local subjectCF = subject and subject.CFrame
					if subjectCF then
						look = subjectCF:GetLookVector()
						local subjectYaw = math.atan2(-look.X, -look.Z)

						local moved = (pivot - flw.lastPivot):Magnitude()
						if moved > 0.01 then
							local diff = subjectYaw - flw.yaw
							diff = ((diff + math.pi) % (2 * math.pi)) - math.pi
							flw.yaw = flw.yaw + diff * math.min(dt * 3, 1)
						end
					end
					flw.lastPivot = pivot
				end

				if wheel ~= 0 then
					local CAM_ZOOM_MUL = 1.15
					if wheel > 0 then
						flw.radius = math.max(1, flw.radius / CAM_ZOOM_MUL)
					else
						flw.radius = math.min(200, flw.radius * CAM_ZOOM_MUL)
					end
				end

				local cosP = math.cos(flw.pitch)
				local camOffset = Vector3.new(
					flw.radius * cosP * -math.sin(flw.yaw),
					flw.radius * math.sin(flw.pitch),
					flw.radius * cosP * -math.cos(flw.yaw)
				)

				instance.Focus = CFrame.new(pivot)
				instance.CFrame = CFrame.new(pivot + camOffset, pivot)
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
