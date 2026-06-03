local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local UserInputService = Instance.new("UserInputService")
local Vector2 = require("@Vector2")
UserInputService._Intents = Enum.PluginIntents.Input

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

	local prevMousePos = raylib.lib.GetMousePosition()

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
		end
	end)
end

return UserInputService
