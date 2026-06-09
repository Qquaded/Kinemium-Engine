local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkService = game:GetService("NetworkService")
local KinemiumRaylib = game:GetService("KinemiumRaylib")

if RunService:IsServer() or not RunService:IsClient() then
	return
end

local Arclib = require("@Arc")
local Arc = Arclib:init(KinemiumRaylib.GetRenderer(), game)

local server_address = GetFlagValue("address") or "127.0.0.1"
local server_port = GetFlagValue("port") or "1234"

local info, err = NetworkService:Ping(server_address, server_port)

print("loading_screen started")
while not Players.LocalPlayer do
	task.wait()
end
print("loading_screen got player")
local player = Players.LocalPlayer

local displayLines = {}

if info then
	local serverName = info.name or "Unknown Server"
	local motd = info.motd or ""
	local latency = info.latency or "?"
	local resolvedAddr = info.resolvedAddress or server_address

	table.insert(displayLines, serverName)
	if motd ~= "" then
		table.insert(displayLines, motd)
	end
	table.insert(displayLines, "")

	table.insert(displayLines, `Connecting to {resolvedAddr}:{server_port}`)

	table.insert(displayLines, `Latency: {latency}ms`)

	if info.players then
		local online = info.players.online or 0
		local max = info.players.max or "?"
		table.insert(displayLines, `Players: {online}/{max}`)
	end

	if info.server then
		if info.server.uptime then
			local uptime = info.server.uptime
			local minutes = math.floor(uptime / 60)
			local seconds = uptime % 60
			if minutes > 0 then
				table.insert(displayLines, `Uptime: {minutes}m {seconds}s`)
			else
				table.insert(displayLines, `Uptime: {seconds}s`)
			end
		end
		if info.server.tickRate then
			table.insert(displayLines, `Tick Rate: {info.server.tickRate}hz`)
		end
	end

	table.insert(displayLines, "")
	table.insert(displayLines, "Loading World...")
else
	table.insert(displayLines, `Connecting to {server_address}:{server_port}`)
	if err then
		table.insert(displayLines, `({err})`)
	end
	table.insert(displayLines, "")
	table.insert(displayLines, "Loading World...")
end

local fullText = table.concat(displayLines, "\n")

local screenGui = Arc.ScreenGui({
	Name = "LoadingScreen",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ZIndex = 999,

	Arc.Frame({
		Name = "Background",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),

		Arc.TextLabel({
			Name = "TitleText",
			Text = (info and info.name) or "Kinemium Server",
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 0.25, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 42,
			BackgroundTransparency = 1,
		}),

		Arc.TextLabel({
			Name = "StatsText",
			Text = fullText,
			Size = UDim2.new(0.6, 0, 0.4, 0),
			Position = UDim2.new(0.2, 0, 0.35, 0),
			TextColor3 = Color3.fromRGB(200, 200, 210),
			TextSize = 20,
			BackgroundTransparency = 1,
		}),

		Arc.UILoadingSpinner({
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 20, 1, -20),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 30, 0, 30),
		}),

		Arc.TextLabel({
			Name = "LoadingIndicator",
			Text = "Waiting for server...",
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.new(0, 0, 0.85, 0),
			TextColor3 = Color3.fromRGB(140, 140, 160),
			TextSize = 18,
			BackgroundTransparency = 1,
		}),
	}),
})

print(screenGui)
screenGui.Parent = player.PlayerGui

local background = screenGui.Background
local loadingLabel = background.LoadingIndicator

task.spawn(function()
	local dots = 0
	while screenGui.Parent do
		dots = (dots % 3) + 1
		loadingLabel.Text = "Waiting for server" .. string.rep(".", dots)
		task.wait(0.5)
	end
end)

print("[loading_screen] Waiting for player.Character...")
print(`[loading_screen]   player = {player.Name}, UserId = {player.UserId}`)
print(`[loading_screen]   player.Character = {tostring(player.Character)}`)
print(`[loading_screen]   player.CharacterAdded = {tostring(player.CharacterAdded)}`)

if player.CharacterAdded then
	player.CharacterAdded:Connect(function(char)
		print(`[loading_screen] CharacterAdded fired: {tostring(char)}`)
	end)
end

local waitStart = os.clock()
repeat
	task.wait(0.5)
	local elapsed = os.clock() - waitStart
	if elapsed > 2 and math.floor(elapsed) % 3 == 0 then
		print(
			`[loading_screen] Still waiting for Character... elapsed={string.format("%.1f", elapsed)}s, Character={tostring(
				player.Character
			)}`
		)
	end
until player.Character
screenGui:Destroy()
print(`[loading_screen] finished  Character loaded: {tostring(player.Character)}`)
