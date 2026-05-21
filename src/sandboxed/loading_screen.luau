local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkService = game:GetService("NetworkService")

if RunService:IsServer() or not RunService:IsClient() then
	return
end

local server_address = GetFlagValue("address") or "127.0.0.1"
local server_port = GetFlagValue("port") or "1234"

local info, err = NetworkService:Ping(server_address, server_port)

print("loading_screen started")
while not Players.LocalPlayer do
	task.wait()
end
print("loading_screen got player")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ZIndex = 999
screenGui.Parent = player.PlayerGui

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
background.Parent = screenGui

local displayLines = {}

print(info)

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

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleText"
titleLabel.Text = (info and info.name) or "Kinemium Server"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0.25, 0)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 42
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = background

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsText"
statsLabel.Text = fullText
statsLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
statsLabel.Position = UDim2.new(0.2, 0, 0.35, 0)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
statsLabel.TextSize = 20
statsLabel.BackgroundTransparency = 1
statsLabel.Parent = background

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Name = "LoadingIndicator"
loadingLabel.Text = "Waiting for server..."
loadingLabel.Size = UDim2.new(1, 0, 0, 40)
loadingLabel.Position = UDim2.new(0, 0, 0.85, 0)
loadingLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
loadingLabel.TextSize = 18
loadingLabel.BackgroundTransparency = 1
loadingLabel.Parent = background

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
