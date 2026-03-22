local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const

local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")

local MOUSE_SENSITIVITY = 0.003
local MOVE_SPEED = 10

local camCF = CFrame.new(0, 5, 10) -- initial camera CFrame

local function UpdateFreecam(delta: number, Kinemium_camera)
	-- handle cursor locking
	if lib.IsMouseButtonPressed(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.DisableCursor()
		lib.SetMousePosition(lib.GetRenderWidth() // 2, lib.GetRenderHeight() // 2)
	end
	if lib.IsMouseButtonReleased(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.EnableCursor()
	end

	-- rotate camera with mouse
	if lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		local md = lib.GetMouseDelta()

		lib.SetMousePosition(lib.GetRenderWidth() // 2, lib.GetRenderHeight() // 2)

		local yaw = -md.x * MOUSE_SENSITIVITY
		local pitch = -md.y * MOUSE_SENSITIVITY

		-- get current rotation as yaw/pitch/roll
		local cy, cp, cr = camCF:GetYawPitchRoll() -- yaw, pitch, roll

		-- add mouse delta
		cy = cy + yaw
		cp = cp + pitch

		-- clamp pitch to avoid flipping
		local limit = math.rad(89)
		cp = math.max(-limit, math.min(limit, cp))

		-- rebuild rotation matrix
		local newRot = CFrame.fromEulerAnglesYXZ(cy, cp, cr).Rotation

		-- apply rotation while keeping position
		camCF = CFrame.new(camCF.Position):WithRotation(newRot)
	end

	-- movement input
	local forward = camCF:GetLookVector()
	local right = camCF:GetRightVector()
	local up = Vector3.new(0, 1, 0)

	local sideway = (lib.IsKeyDown(const.KeyboardKey.KEY_D) - lib.IsKeyDown(const.KeyboardKey.KEY_A))
		+ (lib.IsKeyDown(const.KeyboardKey.KEY_RIGHT) - lib.IsKeyDown(const.KeyboardKey.KEY_LEFT))
	local forwardInput = (lib.IsKeyDown(const.KeyboardKey.KEY_W) - lib.IsKeyDown(const.KeyboardKey.KEY_S))
		+ (lib.IsKeyDown(const.KeyboardKey.KEY_UP) - lib.IsKeyDown(const.KeyboardKey.KEY_DOWN))
	local vertical = lib.IsKeyDown(const.KeyboardKey.KEY_SPACE) - lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT)
	local wheelMove = lib.GetMouseWheelMove()

	local move = (forward * forwardInput + right * sideway + up * vertical + forward * (wheelMove * 5.0))
		* MOVE_SPEED
		* delta
	local targetCF = CFrame.new(camCF.Position + move):WithRotation(camCF.Rotation)
	camCF = targetCF

	local target = camCF.Position + camCF:GetLookVector()

	Kinemium_camera.CFrame = camCF
	Kinemium_camera.Position = camCF.Position

	return camCF.Position, target
end

return {
	Update = UpdateFreecam,

	SetSpeed = function(v)
		MOVE_SPEED = v
	end,

	SetSensitivity = function(v)
		MOUSE_SENSITIVITY = v
	end,

	GetPos = function()
		return camCF.Position
	end,

	ToVectorShader = function()
		return { camCF.Position.X, camCF.Position.Y, camCF.Position.Z }
	end,

	SetCFrame = function(cf)
		camCF = cf
	end,

	GetCFrame = function()
		return camCF
	end,
}
