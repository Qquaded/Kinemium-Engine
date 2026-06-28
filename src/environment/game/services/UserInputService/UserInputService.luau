local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local UserInputService = Instance.new("UserInputService")
local Vector2 = require("@Vector2")
UserInputService._Intents = Enum.PluginIntents.Input

local MAX_GAMEPADS = 4
local GAMEPAD_AXIS_DEADZONE = 0.1
local GAMEPAD_BUTTONS = {
	-- D-pad
	{ Name = "DPadUp", Value = 1 },
	{ Name = "DPadRight", Value = 2 },
	{ Name = "DPadDown", Value = 3 },
	{ Name = "DPadLeft", Value = 4 },
	-- Face buttons (Xbox layout)
	{ Name = "ButtonY", Value = 5 },
	{ Name = "ButtonB", Value = 6 },
	{ Name = "ButtonA", Value = 7 },
	{ Name = "ButtonX", Value = 8 },
	-- Bumpers/Triggers
	{ Name = "ButtonLB", Value = 9 },
	{ Name = "ButtonLT", Value = 10 },
	{ Name = "ButtonRB", Value = 11 },
	{ Name = "ButtonRT", Value = 12 },
	-- Menu buttons
	{ Name = "ButtonSelect", Value = 13 },
	{ Name = "ButtonStart", Value = 15 },
	-- Thumbsticks
	{ Name = "ButtonL3", Value = 16 },
	{ Name = "ButtonR3", Value = 17 },
}

local InputBegan = signal.new()
local InputEnded = signal.new()
local MouseMoved = signal.new()
local MouseWheel = signal.new()

local raylib = require("@raylib")

local active_keys = {} -- [keyValue: number] = true | nil

UserInputService.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless then
		UserInputService:SetProperties({})
		return
	end

	local active_gamepad_buttons = {}

	local Enum = require("@EnumMap")
	local lib = renderer.Raylib.lib

	local valueToKeyCode = {}
	for name, value in pairs(Enum.KeyCode) do
		valueToKeyCode[value] = { Name = name, Value = value }
	end

	local function findSuitable(value: number)
		return valueToKeyCode[value]
	end

	UserInputService:SetProperties({
		InputBegan = InputBegan,
		InputEnded = InputEnded,
		MouseMoved = MouseMoved,
		MouseWheel = MouseWheel,
		GetCharPressed = lib.GetCharPressed,
		TouchEnabled = false,
		GamepadEnabled = false,
	})

	function UserInputService:EnableKey(keys: { { Name: string, Value: number } })
		for _, key in pairs(keys) do
			renderer:WatchKey(key.Value)
		end
		return {
			Disable = function()
				for _, key in pairs(keys) do
					renderer:StopWatchingKey(key.Value)
				end
			end,
		}
	end

	function UserInputService:GetConnectedGamepads(): { Enum.UserInputType }
		local result = {}
		for i = 0, MAX_GAMEPADS - 1 do
			if lib.IsGamepadAvailable(i) == 1 then
				local en = Enum.UserInputType[`Gamepad{i + 1}`]
				if en then
					table.insert(result, en)
				end
			end
		end
		return result
	end

	function UserInputService:IsGamepadConnected(gamepadType: Enum.UserInputType): boolean
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return false
		end
		return lib.IsGamepadAvailable(index - 1) == 1
	end

	function UserInputService:IsGamepadButtonDown(gamepadType: Enum.UserInputType, button: Enum.KeyCode): boolean
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return false
		end
		return lib.IsGamepadButtonDown(index - 1, button.Value) == 1
	end

	function UserInputService:IsGamepadButtonPressed(gamepadType: Enum.UserInputType, button: Enum.KeyCode): boolean
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return false
		end
		return lib.IsGamepadButtonPressed(index - 1, button.Value) == 1
	end

	function UserInputService:IsGamepadButtonReleased(gamepadType: Enum.UserInputType, button: Enum.KeyCode): boolean
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return false
		end
		return lib.IsGamepadButtonReleased(index - 1, button.Value) == 1
	end

	function UserInputService:GetGamepadAxisMovement(gamepadType: Enum.UserInputType, axis: Enum.GamepadAxis): number
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return 0
		end
		local raw = lib.GetGamepadAxisMovement(index - 1, axis.Value)
		return math.abs(raw) > GAMEPAD_AXIS_DEADZONE and raw or 0
	end

	function UserInputService:GetGamepadName(gamepadType: Enum.UserInputType): string?
		local index = tonumber(gamepadType.Name:match("Gamepad(%d+)"))
		if not index then
			return nil
		end
		if lib.IsGamepadAvailable(index - 1) == 0 then
			return nil
		end
		return lib.GetGamepadName(index - 1) -- should return string
	end

	function UserInputService:BindCombo(keys: {}, callback: () -> ())
		InputBegan:Connect(function()
			for _, key in pairs(keys) do
				if lib.IsKeyDown(key.Value) ~= 1 then
					return
				end
			end
			callback()
		end)
	end

	function UserInputService:GetOS()
		if zune.platform.os == "windows" then
			return Enum.Platform.Windows
		elseif zune.platform.os == "linux" then
			return Enum.Platform.Linux
		elseif zune.platform.os == "freebsd" then
			return Enum.Platform.FreeBSD
		elseif zune.platform.os == "macos" then
			return Enum.Platform.OSX
		end
	end

	--function UserInputService:GetDeviceType() end

	function UserInputService:GetKeysDown()
		local keysDown = {}
		for value, keyItem in pairs(valueToKeyCode) do
			if lib.IsKeyDown(value) == 1 then
				table.insert(keysDown, keyItem)
			end
		end
		return keysDown
	end

	function UserInputService:GetStringPressed()
		local code = lib.GetCharPressed()
		if code ~= 0 then
			return string.char(code)
		end
		return nil
	end

	function UserInputService:GetMouseDelta()
		local delta = raylib.lib.GetMouseDelta()
		return Vector2.new(delta.X, delta.Y)
	end

	function UserInputService:IsKeyDown(key)
		return lib.IsKeyDown(key.Value) == 1
	end

	function UserInputService:IsKeyPressed(key)
		return lib.IsKeyPressed(key.Value) == 1
	end

	function UserInputService:IsKeyReleased(key)
		return lib.IsKeyReleased(key.Value) == 1
	end

	function UserInputService:IsMouseButtonDown(button)
		return lib.IsMouseButtonDown(button.Value) == 1
	end

	function UserInputService:IsMouseButtonPressed(button)
		return lib.IsMouseButtonPressed(button.Value) == 1
	end

	function UserInputService:IsMouseButtonReleased(button)
		return lib.IsMouseButtonReleased(button.Value) == 1
	end

	function UserInputService:SetMousePosition(position: Vector2)
		lib.SetMousePosition(position.X, position.Y)
	end

	function UserInputService:GetWindowDimensions()
		return Vector2.new(lib.GetRenderWidth(), lib.GetRenderHeight())
	end

	function UserInputService:DisableCursor()
		lib.DisableCursor()
	end

	function UserInputService:EnableCursor()
		lib.EnableCursor()
	end

	function UserInputService:GetMousePosition()
		local mousePos = raylib.lib.GetMousePosition()
		return Vector2.new(mousePos.X, mousePos.Y)
	end

	function UserInputService:GetScreenDimensions()
		return Vector2.new(lib.GetScreenWidth(), lib.GetScreenHeight())
	end

	renderer_signal:Connect(function(route, data)
		if route == "IsKeyDown" then
			if active_keys[data] then
				return
			end
			local key = findSuitable(data)
			if key then
				active_keys[data] = true
				InputBegan:Fire({
					KeyCode = key,
					UserInputType = Enum.UserInputType.Keyboard,
					UserInputState = Enum.UserInputState.Begin,
				})
			end
		elseif route == "IsKeyReleased" then
			active_keys[data] = nil
			local key = findSuitable(data)
			if key then
				InputEnded:Fire({
					KeyCode = key,
					UserInputType = Enum.UserInputType.Keyboard,
					UserInputState = Enum.UserInputState.End,
				})
			end
		elseif route == "MouseMoved" then
			MouseMoved:Fire({
				UserInputType = Enum.UserInputType.MouseMovement,
				Delta = data,
			})
		elseif route == "MouseWheel" then
			MouseWheel:Fire({
				UserInputType = Enum.UserInputType.MouseWheel,
				Delta = data,
			})
		elseif route == "GamepadPoll" then
			for i = 0, MAX_GAMEPADS - 1 do
				if lib.IsGamepadAvailable(i) == 1 then
					local gamepadType = Enum.UserInputType[`Gamepad{i + 1}`]
					if not gamepadType then
						continue
					end

					for _, button in pairs(GAMEPAD_BUTTONS) do
						local key = `{i}_{button.Value}`

						if lib.IsGamepadButtonDown(i, button.Value) == 1 then
							if not active_gamepad_buttons[key] then
								active_gamepad_buttons[key] = true
								InputBegan:Fire({
									KeyCode = button,
									UserInputType = gamepadType,
									UserInputState = Enum.UserInputState.Begin,
								})
							end
						else
							if active_gamepad_buttons[key] then
								active_gamepad_buttons[key] = nil
								InputEnded:Fire({
									KeyCode = button,
									UserInputType = gamepadType,
									UserInputState = Enum.UserInputState.End,
								})
							end
						end
					end
				end
			end
		end
	end)
end

return UserInputService
