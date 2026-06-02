local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HUDService = game:GetService("HUDService")

if RunService:IsServer() then
	return
end

if not RunService:IsClient() then
	return
end

local menuActive = false
local main_signal = Signal.new()

local manager = ReactPointer.new()

manager:setGroup("#runtime", {
	background = Color3.fromRGB(30, 30, 30),
	backgroundactive = Color3.fromRGB(36, 36, 36),
	secondarybackground = Color3.fromRGB(34, 34, 34),
	overlay = Color3.fromRGB(0, 0, 0),

	bgtransparency = 0.15,
	menuhovertransparency = 0.08,
	overlaytransparency = 0.6,
	overlayactivetransparency = 0.5,
	font = Enum.Font.DefaultEngineFont,

	buttontransparency = 0.1,
	buttonhovertransparency = 0.05,
	topbarbuttontransparency = 0.1,
	topbarbuttonhovertransparency = 0.05,
	topbarbuttonactivetransparency = 0.12,

	tabsbgtransparency = 0.2,
	windowtransparency = 0.12,
	windowhiddentransparency = 1,

	text = Color3.fromRGB(238, 238, 236),
	mutedtext = Color3.fromRGB(160, 160, 160),
	mutedtexttransparency = 0.2,

	accent = Color3.fromRGB(255, 255, 255),

	shadow = Color3.fromRGB(0, 0, 0),
	shadowtransparency = 0.92,
	windowshadowtransparency = 0.94,
	windowshadowblur = 4,

	chatinputtransparency = 0.1,
	chatinputcornerradius = 0.25,

	corner = UDim.new(0, 8),
	bubblecorner = UDim.new(0, 10),
	pillcorner = UDim.new(1, 0),
	squirclecorner = UDim.new(0, 6),
	squirclefull = UDim.new(1, 0),
	windowsquirclecorner = UDim.new(0, 8),
	squircleexponent = 1.6,

	damping = 6,
	frequency = 10,
	icondamping = 0.7,
	iconfrequency = 12,
})

ishared.ReactPointer = manager
ishared.CoreGuiSignal = ishared.CoreGuiSignal or main_signal
HUDService.AttachRuntime(manager)

local function runtime(key, fallback)
	local value = manager:get("#runtime", key)
	if value == nil then
		return fallback
	end
	return value
end

local function bindRuntime(object, props)
	for property, key in pairs(props) do
		manager:bind(object, property, "#runtime." .. key)
	end
end

local function bindCorner(corner, radiusKey)
	radiusKey = radiusKey or "corner"
	bindRuntime(corner, {
		CornerRadius = radiusKey,
		TopLeftRadius = radiusKey,
		TopRightRadius = radiusKey,
		BottomLeftRadius = radiusKey,
		BottomRightRadius = radiusKey,
	})
end

local function bindSquircle(squircle, config)
	config = config or {}
	local radiusKey = config.radiusKey or "squirclecorner"
	local fullKey = config.fullKey or "squirclefull"
	local exponentKey = config.exponentKey or "squircleexponent"

	bindRuntime(squircle, {
		CornerRadius = radiusKey,
		Exponent = exponentKey,
	})

	if config.fullTop ~= false then
		manager:bind(squircle, "TopLeftRadius", "#runtime." .. fullKey)
		manager:bind(squircle, "TopRightRadius", "#runtime." .. fullKey)
	end
	if config.fullBottom ~= false then
		manager:bind(squircle, "BottomLeftRadius", "#runtime." .. fullKey)
		manager:bind(squircle, "BottomRightRadius", "#runtime." .. fullKey)
	end
end

local function onRuntimeChange(keys, callback)
	for _, key in ipairs(keys) do
		manager:subscribe("#runtime", key, callback)
	end
end

local function springTarget(object, props, dampingKey, frequencyKey)
	Spring.target(object, runtime(dampingKey or "damping", 2), runtime(frequencyKey or "frequency", 5), props)
end

local transparencySpring =
	Spring.new(runtime("damping", 2), runtime("frequency", 5), "Number", runtime("buttontransparency", 0.3))
transparencySpring:Play()

local transparencyMenuSpring =
	Spring.new(runtime("damping", 2), runtime("frequency", 5), "Number", runtime("bgtransparency", 0.3))
transparencyMenuSpring:Play()

local backgroundTransparencySpring =
	Spring.new(runtime("damping", 2), runtime("frequency", 5), "Number", runtime("overlaytransparency", 1))
backgroundTransparencySpring:Play()

local menuHovered = false
local openButtonHovered = false

local Player = game:GetService("Players").LocalPlayer

local Gui = Instance.new("ScreenGui")
Gui.Name = "KinemiumCoreGui"
Gui.Parent = game.CoreGui

local backgroundFrame = Instance.new("Frame")
backgroundFrame.Name = "Background"
backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
backgroundFrame.BackgroundTransparency = 1
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.ZIndex = -1
backgroundFrame.Parent = Gui

local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Menu.Position = UDim2.new(0.5, 0, 0, 0)
Menu.AnchorPoint = Vector2.new(0.5, 0)
Menu.BackgroundTransparency = 0.3
Menu.Size = UDim2.new(0.3, 0, 0, 60)
Menu.Visible = false
Menu.Parent = Gui
bindRuntime(Menu, {
	BackgroundColor3 = "background",
})

local tabs = Instance.new("UITabs")
tabs.Tabs = {}
tabs.ActiveIndex = 1
tabs.BackgroundTransparency = 1
tabs.BackgroundColor3 = Color3.new(0, 0, 0)
tabs.TextSize = 20
tabs.Position = UDim2.new(0.5, 0, 0.5, 0)
tabs.AnchorPoint = Vector2.new(0.5, 0.5)
tabs.Size = UDim2.new(0.94, 0, 0.85, 0)
tabs.ActiveColor3 = Color3.new(1, 1, 1)
tabs.Parent = Menu
bindRuntime(tabs, {
	BackgroundColor3 = "background",
	BackgroundTransparency = "tabsbgtransparency",
	ActiveColor3 = "accent",
	TextColor3 = "text",
	Font = "font",
})

tabs:GetPropertyChangedSignal("ActiveIndex"):Connect(function()
	local tabName = tabs.Tabs[tabs.ActiveIndex]
	if tabName ~= nil then
		Route.handle("/" .. string.lower(tabName))
	end
end)

HUDService.AttachClient(main_signal, Gui)

local shadow2 = Instance.new("UIShadow")
shadow2.Transparency = 0.9
shadow2.Parent = Menu
bindRuntime(shadow2, {
	Color = "shadow",
	Transparency = "shadowtransparency",
})

local squircle2 = Instance.new("UISquircle")
squircle2.CornerRadius = UDim.new(0, 0)
squircle2.Exponent = 1
squircle2.BottomRightRadius = UDim.new(1, 0)
squircle2.BottomLeftRadius = UDim.new(1, 0)
squircle2.Parent = Menu
bindSquircle(squircle2, {
	fullTop = false,
	fullBottom = true,
})

local OpenMenuButton = Instance.new("TextButton")
OpenMenuButton.Text = ""
OpenMenuButton.TextTransparency = 1
OpenMenuButton.AutoButtonColor = false
OpenMenuButton.BackgroundColor3 = Color3.new(0, 0, 0)
OpenMenuButton.BackgroundTransparency = 0.3
OpenMenuButton.ZIndex = 10
OpenMenuButton.Size = UDim2.new(0, 70, 0, 70)
OpenMenuButton.Parent = Gui

local Topbar = Instance.new("CanvasGroup")
Topbar.Size = UDim2.new(0, 60, 0, 60)
Topbar.Position = UDim2.new(0, 80, 0, 10)
Topbar.BackgroundColor3 = Color3.new(0, 0, 0)
Topbar.AutomaticSize = Enum.AutomaticSize.X
Topbar.BackgroundTransparency = 0.3
Topbar.GroupTransparency = 1
Topbar.Visible = false
Topbar.Parent = Gui
bindRuntime(Topbar, {
	BackgroundColor3 = "background",
	BackgroundTransparency = "bgtransparency",
})

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = Topbar

local UIListLayoutTopbar = Instance.new("UIListLayout")
UIListLayoutTopbar.FillDirection = Enum.FillDirection.Horizontal
UIListLayoutTopbar.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTopbar.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayoutTopbar.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayoutTopbar.Parent = Topbar

local function check_transparency_topbar()
	if #Topbar:GetChildren() > 1 then
		Topbar.Visible = true

		springTarget(Topbar, {
			GroupTransparency = 0,
		})
	else
		springTarget(Topbar, {
			GroupTransparency = 1,
		})

		Topbar.Visible = false
	end
end

check_transparency_topbar()

Topbar.ChildAdded:Connect(function(a0: Instance)
	check_transparency_topbar()
end)

Topbar.ChildRemoved:Connect(function(a0: Instance)
	check_transparency_topbar()
end)

local function newTopbarButton(icon, routeName, callback, closed)
	local NewButton = Instance.new("TextButton")
	NewButton.Text = ""
	NewButton.BackgroundColor3 = Color3.new(0, 0, 0)
	NewButton.BackgroundTransparency = runtime("topbarbuttontransparency", 1)
	NewButton.AutoButtonColor = false
	NewButton.Size = UDim2.new(0, 40, 0, 40)
	NewButton.Parent = Topbar

	bindRuntime(NewButton, {
		BackgroundColor3 = "background",
	})

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(1, 0)
	ButtonCorner.Parent = NewButton
	bindCorner(ButtonCorner, "pillcorner")

	local iconLabel = Instance.new("ImageLabel")
	iconLabel.Image = `./src/assets/images/{icon}.png`
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
	iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	iconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	iconLabel.Parent = NewButton
	bindRuntime(iconLabel, {
		ImageColor3 = "text",
	})

	local hovered = false
	local active = false

	local function updateButtonTransparency()
		local transparencyKey = "topbarbuttontransparency"
		local fallback = 1

		if active then
			transparencyKey = "topbarbuttonactivetransparency"
			fallback = 0.35
		elseif hovered then
			transparencyKey = "topbarbuttonhovertransparency"
			fallback = 0.5
		end

		springTarget(NewButton, {
			BackgroundTransparency = runtime(transparencyKey, fallback),
		})
	end

	onRuntimeChange({
		"topbarbuttontransparency",
		"topbarbuttonhovertransparency",
		"topbarbuttonactivetransparency",
		"damping",
		"frequency",
	}, updateButtonTransparency)

	NewButton.MouseButton1Click:Connect(function()
		Route.handle(`/{string.lower(routeName)}`)
	end)

	NewButton.MouseEnter:Connect(function(a0: number, a1: number)
		hovered = true
		updateButtonTransparency()

		springTarget(iconLabel, {
			Size = UDim2.new(0.7, 0, 0.7, 0),
		}, "icondamping", "iconfrequency")
	end)

	NewButton.MouseLeave:Connect(function(a0: number, a1: number)
		hovered = false
		updateButtonTransparency()

		springTarget(iconLabel, {
			Size = UDim2.new(0.6, 0, 0.6, 0),
		}, "icondamping", "iconfrequency")
	end)

	Route.add(`/{string.lower(routeName)}`, function()
		if callback then
			callback()
		end
		active = true
		updateButtonTransparency()

		return function()
			if closed then
				closed()
			end
			active = false
			updateButtonTransparency()
		end
	end)

	updateButtonTransparency()

	return NewButton
end

local shadow4 = Instance.new("UIShadow")
shadow4.Transparency = 0.9
shadow4.Parent = Topbar
bindRuntime(shadow4, {
	Color = "shadow",
	Transparency = "shadowtransparency",
})

local topbarCorner = Instance.new("UICorner")
topbarCorner.CornerRadius = UDim.new(1, 0)
topbarCorner.Parent = Topbar
bindCorner(topbarCorner, "pillcorner")

local shadow = Instance.new("UIShadow")
shadow.Transparency = 0.9
shadow.Parent = OpenMenuButton
bindRuntime(shadow, {
	Color = "shadow",
	Transparency = "shadowtransparency",
})

local squircle = Instance.new("UISquircle")
squircle.CornerRadius = UDim.new(0, 0)
squircle.Exponent = 1
squircle.BottomRightRadius = UDim.new(1, 0)
squircle.Parent = OpenMenuButton
bindSquircle(squircle, {
	fullTop = false,
	fullBottom = false,
})
manager:bind(squircle, "BottomRightRadius", "#runtime.squirclefull")

local Icon = Instance.new("ImageLabel")
Icon.Image = "./src/assets/images/kinemium/Core.png"
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
Icon.Size = UDim2.new(0.8, 0, 0.8, 0)
Icon.BackgroundTransparency = 1
Icon.Parent = OpenMenuButton
bindRuntime(Icon, {
	ImageColor3 = "text",
})

local function syncRuntimeSprings()
	local damping = runtime("damping", 2)
	local frequency = runtime("frequency", 5)

	transparencySpring.d = damping
	transparencySpring.f = frequency
	transparencyMenuSpring.d = damping
	transparencyMenuSpring.f = frequency
	backgroundTransparencySpring.d = damping
	backgroundTransparencySpring.f = frequency
end

local function updateBackgroundTransparencyTarget()
	if menuActive then
		local transparencyKey = "overlayactivetransparency"
		backgroundTransparencySpring:set(runtime(transparencyKey, 0.5))
	else
		backgroundTransparencySpring:set(1) -- fully invisible when closed
	end
end

local function updateMenuTransparencyTarget()
	local transparencyKey = if menuHovered then "menuhovertransparency" else "bgtransparency"
	local fallback = if menuHovered then 0.5 else 0.3
	transparencyMenuSpring:set(runtime(transparencyKey, fallback))
end

local function updateOpenMenuButtonTransparency()
	local transparencyKey = if openButtonHovered then "buttonhovertransparency" else "buttontransparency"
	local fallback = if openButtonHovered then 0.5 else 0.3
	transparencySpring:set(runtime(transparencyKey, fallback))
end

local function updateMenuButtonVisuals()
	local topbarTransparency = if Topbar.Visible then 0 else 1

	if menuActive then
		springTarget(Topbar, {
			Position = UDim2.new(0, 80, 0, -100),
			GroupTransparency = 1,
		})

		springTarget(Icon, {
			Size = UDim2.new(0.6, 0, 0.6, 0),
			ImageColor3 = runtime("background", Color3.new(0, 0, 0)),
		}, "icondamping", "iconfrequency")

		springTarget(OpenMenuButton, {
			BackgroundColor3 = runtime("backgroundactive", Color3.new(1, 1, 1)),
			Size = UDim2.new(0, 50, 0, 50),
		})
	else
		springTarget(Topbar, {
			Position = UDim2.new(0, 80, 0, 10),
			GroupTransparency = topbarTransparency,
		})

		springTarget(Icon, {
			Size = UDim2.new(0.8, 0, 0.8, 0),
			ImageColor3 = runtime("text", Color3.new(1, 1, 1)),
		}, "icondamping", "iconfrequency")

		springTarget(OpenMenuButton, {
			BackgroundColor3 = runtime("background", Color3.new(0, 0, 0)),
			Size = UDim2.new(0, 70, 0, 70),
		})
	end
end

syncRuntimeSprings()
updateBackgroundTransparencyTarget()
updateMenuTransparencyTarget()
updateOpenMenuButtonTransparency()
updateMenuButtonVisuals()

onRuntimeChange({ "damping", "frequency" }, function()
	syncRuntimeSprings()
	updateMenuButtonVisuals()
end)
onRuntimeChange({ "overlaytransparency", "overlayactivetransparency" }, updateBackgroundTransparencyTarget)
onRuntimeChange({ "bgtransparency", "menuhovertransparency" }, updateMenuTransparencyTarget)
onRuntimeChange({ "buttontransparency", "buttonhovertransparency" }, updateOpenMenuButtonTransparency)
onRuntimeChange({ "background", "backgroundactive", "text", "icondamping", "iconfrequency" }, updateMenuButtonVisuals)

local function OpenMenu()
	local activeTabName = tabs.Tabs[tabs.ActiveIndex]
	if activeTabName ~= nil then
		Route.handle("/" .. string.lower(activeTabName))
	end

	Icon.Image = "./src/assets/images/burger.png"
	updateMenuButtonVisuals()
	updateMenuTransparencyTarget()
	updateBackgroundTransparencyTarget()
	Menu.Visible = true
	main_signal:Fire("OpenedSettings")
end

local function CloseMenu()
	Route.deselect()
	Menu.Visible = false
	Icon.Image = "./src/assets/images/kinemium/Core.png"
	updateMenuButtonVisuals()
	updateMenuTransparencyTarget()
	updateBackgroundTransparencyTarget()
	main_signal:Fire("ClosedSettings")
end

local function createWindow(title, callback)
	local window = Instance.new("CanvasGroup")
	window.Name = title
	window.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	window.Position = UDim2.new(0.5, 0, 0.6, 0)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.BackgroundTransparency = 0.2
	window.Size = UDim2.new(0.5, 0, 0.6, 0)
	window.Visible = false
	window.Parent = Gui
	bindRuntime(window, {
		BackgroundColor3 = "background",
	})

	local window_squircle = Instance.new("UISquircle")
	window_squircle.CornerRadius = UDim.new(0, 0)
	window_squircle.Exponent = 1
	window_squircle.BottomRightRadius = UDim.new(0.03, 0)
	window_squircle.BottomLeftRadius = UDim.new(0.03, 0)
	window_squircle.TopLeftRadius = UDim.new(0.03, 0)
	window_squircle.TopRightRadius = UDim.new(0.03, 0)
	window_squircle.Parent = window
	bindRuntime(window_squircle, {
		CornerRadius = "squirclecorner",
		Exponent = "squircleexponent",
		BottomRightRadius = "windowsquirclecorner",
		BottomLeftRadius = "windowsquirclecorner",
		TopLeftRadius = "windowsquirclecorner",
		TopRightRadius = "windowsquirclecorner",
	})

	local window_shadow = Instance.new("UIShadow")
	window_shadow.Transparency = 0.5
	window_shadow.Blur = 10
	window_shadow.Parent = window
	bindRuntime(window_shadow, {
		Color = "shadow",
		Transparency = "windowshadowtransparency",
		Blur = "windowshadowblur",
	})

	local window_list = Instance.new("UIListLayout")
	window_list.Padding = UDim.new(0, 10)
	window_list.FillDirection = Enum.FillDirection.Vertical
	window_list.Parent = window

	local window_title = Instance.new("TextLabel")
	window_title.Text = title
	window_title.TextColor3 = Color3.new(1, 1, 1)
	window_title.BackgroundTransparency = 1
	window_title.TextXAlignment = Enum.TextXAlignment.Left
	window_title.TextSize = 30
	window_title.Size = UDim2.new(1, -20, 0, 40)
	window_title.Parent = window
	bindRuntime(window_title, {
		TextColor3 = "text",
		Font = "font",
	})

	local window_padding = Instance.new("UIPadding")
	window_padding.Padding = UDim2.new(0, 10, 0, 10)
	window_padding.Parent = window

	Route.add(`/{string.lower(title)}`, function()
		window.Visible = true
		springTarget(window, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			GroupTransparency = 0,
			BackgroundTransparency = runtime("windowtransparency", 0.3),
		})

		return function()
			task.spawn(function()
				springTarget(window, {
					GroupTransparency = 1,
					BackgroundTransparency = runtime("windowhiddentransparency", 1),
					Position = UDim2.new(0.5, 0, 0.6, 0),
				})
				task.wait(0.1)
				window.Visible = false
			end)
		end
	end)

	if callback then
		callback(window)
	end

	return window
end

Route.deselect()

OpenMenuButton.MouseEnter:Connect(function()
	openButtonHovered = true
	updateOpenMenuButtonTransparency()
end)

OpenMenuButton.MouseLeave:Connect(function()
	openButtonHovered = false
	updateOpenMenuButtonTransparency()
end)

OpenMenuButton.MouseButton1Click:Connect(function(a0: InputObject)
	menuActive = not menuActive
	if menuActive then
		OpenMenu()
	else
		CloseMenu()
	end
end)

Menu.MouseEnter:Connect(function()
	menuHovered = true
	updateMenuTransparencyTarget()
end)

Menu.MouseLeave:Connect(function()
	menuHovered = false
	updateMenuTransparencyTarget()
end)

RunService.RenderStepped:Connect(function(dt)
	Spring.stepTargets(dt)

	if UserInputService:IsKeyReleased(Enum.KeyCode.Escape) then
		menuActive = not menuActive
		if menuActive then
			OpenMenu()
		else
			CloseMenu()
		end
	end
	backgroundFrame.BackgroundTransparency = backgroundTransparencySpring:step(dt)
	Menu.BackgroundTransparency = transparencyMenuSpring:step(dt)
	OpenMenuButton.BackgroundTransparency = transparencySpring:step(dt)
end)

main_signal:Connect(function(message, param, cb)
	if message == "OpenMenu" then
		menuActive = true
		OpenMenu()
	elseif message == "CloseMenu" then
		menuActive = false
		CloseMenu()
	elseif message == "ToggleMenu" then
		menuActive = not menuActive
		if menuActive then
			OpenMenu()
		else
			CloseMenu()
		end
	elseif message == "RemoveMenu" then
		Gui.Enabled = false
	elseif message == "DestroyMenu" then
		Gui:Destroy()
	elseif message == "EnableMenu" then
		Gui.Enabled = true
	elseif message == "OpenRoute" then
		Route.handle("/" .. param)
	elseif message == "CloseRoute" then
		Route.deselect()
	elseif message == "MakeWindow" then
		createWindow(param, cb)
		local newTabs = tabs.Tabs
		table.insert(newTabs, param)
		tabs.Tabs = newTabs -- reassign to trigger __newindex so UITabs re-renders
		if tabs.ActiveIndex == nil or tabs.ActiveIndex < 1 then
			tabs.ActiveIndex = 1
		end
	elseif message == "NewTopbarButton" then
		newTopbarButton(param.icon, param.routeName, param.open_callback, param.close_callback)
	end
end)
