local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local raylib = require("@raylib")
local lib = raylib.lib
local aereon = import("@Aereon")

local gui = aereon.gui

local KinemiumFontService = game:GetService("KinemiumFontService")
local HttpService = game:GetService("HttpService")
local Color3 = require("@Color3")

local vend = KinemiumFontService.GetDefaultFont()
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local logoPath = "./src/assets/images/icons/vanilla3/kinemium/KinemiumWhite.png"
local kilLogo = KinemiumIconLoader.ToTexture(logoPath)

KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/ArrowRight.png")
local arrowRightTex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowRight"))

local activePluginPage = nil

-- Shared callback — toolbox can override to open plugin in a new window instead
ishared.onPluginCardClick = function(pluginId)
	activePluginPage = pluginId
end

local StudioThemeService = game:GetService("StudioThemeService")

local boldFont = KinemiumFontService.GetBoldFont()
local TextBoxClass = aereon.textbox(StudioThemeService.SelectedTheme, game)
local marketplaceSearchBox
local marketplaceFilterDropdown
local marketplaceSearchText = ""
local marketplaceFilter = "All"
local marketplaceEntries = {}
local marketplaceFilterOptions = { "All" }
local detailText = "Loading plugins..."

local function rebuildMarketplaceFilterOptions()
	local options = { "All" }
	local seen = {}
	for _, entry in ipairs(marketplaceEntries) do
		local manifest = entry.plugin.manifest or {}
		local keywords = manifest.keywords or {}
		local category = keywords[1] or "Plugin"
		if not seen[category] then
			seen[category] = true
			table.insert(options, category)
		end
	end
	marketplaceFilterOptions = options
	if marketplaceFilterDropdown then
		marketplaceFilterDropdown.set("options", options)
		local idx = 1
		for i, opt in ipairs(options) do
			if opt == marketplaceFilter then
				idx = i
				break
			end
		end
		marketplaceFilterDropdown.set("selectedIndex", idx)
	end
end

local function applyMarketplaceFilter()
	local query = string.lower(marketplaceSearchText or "")
	for _, entry in ipairs(marketplaceEntries) do
		local manifest = entry.plugin.manifest or {}
		local name = string.lower(manifest.name or "")
		local desc = string.lower(manifest.description or "")
		local keywords = manifest.keywords or {}
		local category = keywords[1] or "Plugin"
		local matchesFilter = marketplaceFilter == "All" or category == marketplaceFilter
		local matchesSearch = query == "" or string.find(name, query, 1, true) or string.find(desc, query, 1, true)
		entry.card.set("visible", matchesFilter and matchesSearch)
	end
end

local function createCard(plugin, textureData, thumbnailData)
	local manifest = plugin.manifest
	local card = gui.itemcard({
		x = 0,
		y = 0,
		width = 320,
		height = 320,
		rounded = { 0.05, 12 },

		flexGrow = 1,
		minWidth = 200,
		maxWidth = 400,
		aspectRatio = 1,

		title = manifest.name,
		description = manifest.description or "No description provided.",
		downloads = "0",
		likes = "0",
		category = manifest.keywords and manifest.keywords[1] or "Plugin",
		icon = textureData,
		bannerImage = thumbnailData,

		font = vend,

		backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		darkBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		textColor = StudioThemeService.SelectedTheme.TextColor,
		dimTextColor = StudioThemeService.SelectedTheme.SecondaryTextColor,
		categoryColor = StudioThemeService.SelectedTheme.Accent,

		onClick = function()
			ishared.onPluginCardClick(plugin.manifest.id)
		end,
	})

	return card
end

local function createPage(plugin, textureData, thumbnailData)
	local manifest = plugin.manifest
	local modcard
	modcard = gui.modcard({
		x = 20,
		y = 20,
		width = 1360,
		height = 860,
		font = vend,
		boldFont = boldFont,

		title = manifest.name,
		description = manifest.description or "",
		downloads = "0",
		likes = "0",
		category = manifest.keywords and manifest.keywords[1] or "Plugin",

		sections = {
			{ type = "heading", text = manifest.name },
			{ type = "text", text = manifest.description or "No description provided." },
		},

		compatibility = {
			game = "Kinemium Engine",
			versions = { "1.0.0" },
		},
		platforms = { "Any" },
		environments = { "Client-side", "Server-side" },
		backgroundTransparency = 1,

		accent = StudioThemeService.SelectedTheme.Accent,
		tabBarBg = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		pageBg = StudioThemeService.SelectedTheme.BackgroundColor,
		headerBg = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		iconBg = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		text = StudioThemeService.SelectedTheme.TextColor,
		muted = StudioThemeService.SelectedTheme.SecondaryTextColor,
		bg = StudioThemeService.SelectedTheme.BackgroundColor,
		lightText = StudioThemeService.SelectedTheme.LightText,
		sidebarBg = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		buttonBg = StudioThemeService.SelectedTheme.Accent,
		buttonBgHover = StudioThemeService.SelectedTheme.Accent,
		white = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,

		icon = textureData,
		bannerImage = thumbnailData,

		onDownload = function()
			modcard.set("downloadText", "Installing..")

			local success, result = game.PluginLoader.DownloadPlugin(plugin.manifest, true)
			if success then
				modcard.set("downloadText", "Installed")
			end
		end,
	})
	return modcard
end

local pages = {}

local plugins
local isLoadingPlugins = false

local function getImageExt(path)
	if type(path) ~= "string" then
		return ".png"
	end
	local ext = path:match("(%.[%a%d]+)$")
	return ext or ".png"
end

local function fetchRemoteTexture(url, ext)
	if type(url) ~= "string" or url == "" then
		return nil
	end
	local ok, body = pcall(HttpService.GetAsync, HttpService, url, {
		["User-Agent"] = "Kinemium-Engine",
	})
	if not ok or type(body) ~= "string" or #body == 0 then
		return nil
	end
	return KinemiumIconLoader.ToTextureBuffer(buffer.fromstring(body), ext or getImageExt(url))
end

local marketplaceFlex = gui.flex({
	direction = "row",
	flexWrap = "wrap",
	gap = 24,
	alignItems = "stretch",
	padding = { left = 0, right = 0, top = 0, bottom = 0 },
	autoHeight = true,
	backgroundColor = Color3.new(0, 0, 0),
	backgroundTransparency = 1,
})

local scrollArea = gui.scrollable({
	child = marketplaceFlex,
	scrollbarWidth = 8,
	scrollbarColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarHoverColor = StudioThemeService.SelectedTheme.Accent,
	scrollbarBackground = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

repeat
	task.wait()
until ishared.Home

local function loadPlugins()
	if not plugins and not isLoadingPlugins then
		isLoadingPlugins = true
		task.spawn(function()
			plugins, result = game.PluginLoader.GetPluginsMarketplace()

			if not plugins then
				isLoadingPlugins = false
				detailText = result
				return
			end

			for _, plugin in pairs(plugins) do
				local textureData
				if plugin.icon then
					textureData = KinemiumIconLoader.ToTextureBuffer(plugin.icon, plugin.manifest.icon or ".png")
				end
				if not textureData then
					textureData = kilLogo
				end

				local thumbnailData
				if plugin.thumbnail then
					thumbnailData =
						KinemiumIconLoader.ToTextureBuffer(plugin.thumbnail, plugin.manifest.thumbnail or ".png")
				end

				local card = createCard(plugin, textureData, thumbnailData)
				local page = createPage(plugin, textureData, thumbnailData)
				card.set("font", vend)
				marketplaceFlex.add(card)
				pages[plugin.manifest.id] = page
				table.insert(marketplaceEntries, { plugin = plugin, card = card })
				rebuildMarketplaceFilterOptions()
				applyMarketplaceFilter()

				if not plugin.icon and plugin.iconUrl then
					task.spawn(function()
						local iconTexture =
							fetchRemoteTexture(plugin.iconUrl, plugin.manifest.icon or getImageExt(plugin.iconUrl))
						if iconTexture then
							card.set("icon", iconTexture)
							page.set("icon", iconTexture)
						end
					end)
				end

				if not plugin.thumbnail and plugin.thumbnailUrl then
					task.spawn(function()
						local thumbTexture = fetchRemoteTexture(
							plugin.thumbnailUrl,
							plugin.manifest.thumbnail or getImageExt(plugin.thumbnailUrl)
						)
						if thumbTexture then
							card.set("bannerImage", thumbTexture)
							page.set("bannerImage", thumbTexture)
						end
					end)
				end

				task.wait()
			end
			rebuildMarketplaceFilterOptions()
			applyMarketplaceFilter()
			isLoadingPlugins = false
		end)
	end
end

game.EngineSignal:Connect(function(prop)
	if prop == "LoadPlugins" then
		loadPlugins()
	end
end)

local arect = require("@arect")

ishared.marketplacePage = scrollArea
ishared.marketplacePages = pages

-- Back button for plugin detail page
local backButton = gui.imageButton({
	x = 0,
	y = 0,
	width = 32,
	height = 32,
	backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	hoverColor = StudioThemeService.SelectedTheme.Accent,
	pressColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	imageTransparency = 0,
	imageScale = 0.55,
	rounded = { 0.25, 6 },
	shadowLayers = 3,
	shadowOffsetY = 2,
	shadowSpread = 2,
	onClick = function()
		activePluginPage = nil
	end,
})

ishared.Home.pages["Marketplace"] = function(dt, alpha, slideOffset)
	local fade = function(col, a)
		return col:ToRaylib(1 - (a or 1) * alpha)
	end

	if ishared.Home.activePage ~= "Marketplace" and ishared.Home.previousPage ~= "Marketplace" then
		return
	end
	loadPlugins()

	local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	if not plugins and marketplaceFlex.get("children") and #marketplaceFlex.get("children") == 0 then
		if vend then
			raylib.lib.DrawTextEx(
				boldFont,
				"Plugin Marketplace",
				vector.create(100, 80 + slideOffset),
				32,
				1,
				fade(StudioThemeService.SelectedTheme.TextColor, 1)
			)
			raylib.lib.DrawTextEx(
				vend,
				detailText,
				vector.create(100, 120 + slideOffset),
				16,
				1,
				fade(StudioThemeService.SelectedTheme.SecondaryTextColor, 1)
			)
		end
		return
	end

	if activePluginPage then
		local page = pages[activePluginPage]
		local pageX = 96
		local pageY = 80 + slideOffset
		local pageW = screenx - 100
		local pageH = screeny - 100

		-- Back button at top-left
		local backBtnSize = 32
		local backBtnX = pageX
		local backBtnY = pageY
		backButton.set("obj_rect", arect.new(backBtnX, backBtnY, backBtnSize, backBtnSize))
		backButton.set("backgroundColor", StudioThemeService.SelectedTheme.SecondaryBackgroundColor)
		backButton.set("hoverColor", StudioThemeService.SelectedTheme.Accent)
		backButton.render(dt)

		-- Draw flipped arrow (ArrowRight with negative source width = ArrowLeft)
		if arrowRightTex then
			local arrowPad = 10
			local arrowSize = backBtnSize - arrowPad * 2
			lib.DrawTexturePro(
				arrowRightTex.texture,
				raylib.structs.Rectangle:new({
					x = arrowRightTex.x,
					y = 0,
					width = -arrowRightTex.x,
					height = arrowRightTex.y,
				}),
				raylib.structs.Rectangle:new({
					x = backBtnX + arrowPad,
					y = backBtnY + arrowPad,
					width = arrowSize,
					height = arrowSize,
				}),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end

		-- Shift page content down below the back button
		if page then
			page.set("obj_rect", arect.new(pageX, pageY + backBtnSize + 8, pageW, pageH - backBtnSize - 8))
			page.render(dt)
		end

		return
	end

	local startX = 100
	local headerY = 80 + slideOffset
	local headerDesc = 120 + slideOffset
	local controlsY = headerDesc + 24
	local searchHeight = 32
	local dropdownWidth = 180
	local gap = 12

	if vend then
		raylib.lib.DrawTextEx(
			boldFont,
			"Plugin Marketplace",
			vector.create(startX, headerY),
			32,
			1,
			fade(StudioThemeService.SelectedTheme.TextColor, 1)
		)
		raylib.lib.DrawTextEx(
			vend,
			"Discover tools and extensions for Kinemium Engine",
			vector.create(startX, headerDesc),
			16,
			1,
			fade(StudioThemeService.SelectedTheme.SecondaryTextColor, 1)
		)
	end

	-- Search + Filter
	if not marketplaceSearchBox then
		marketplaceSearchBox = TextBoxClass.new({
			padding = 8,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			textColor = StudioThemeService.SelectedTheme.TextColor,
			placeholderColor = StudioThemeService.SelectedTheme.SecondaryTextColor,
			cornerRadius = 0.2,
			BackgroundTransparency = 0,
			BorderTransparency = 1,
			placeholder = "Search plugins...",
			fontSize = 14,
			escapeBlurs = false,
			blurOnSubmit = false,
			onChange = function(text)
				marketplaceSearchText = text or ""
				applyMarketplaceFilter()
			end,
		})
	end

	local searchWidth = screenx - 170 - dropdownWidth - gap
	marketplaceSearchBox:drawWithExtras(startX, controlsY, searchWidth, searchHeight)
	local currentSearch = marketplaceSearchBox:getText() or ""
	if currentSearch ~= marketplaceSearchText then
		marketplaceSearchText = currentSearch
		applyMarketplaceFilter()
	end

	if not marketplaceFilterDropdown then
		marketplaceFilterDropdown = gui.dropdown({
			x = startX + searchWidth + gap,
			y = controlsY,
			width = dropdownWidth,
			height = searchHeight,
			options = marketplaceFilterOptions,
			font = vend,
			selectedIndex = 1,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			hoverColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			textColor = StudioThemeService.SelectedTheme.TextColor,
			borderTransparency = 1,
			onSelect = function(index, value)
				marketplaceFilter = value or "All"
				applyMarketplaceFilter()
			end,
		})
	end
	marketplaceFilterDropdown.set(
		"obj_rect",
		arect.new(startX + searchWidth + gap, controlsY, dropdownWidth, searchHeight)
	)
	vend = KinemiumFontService.GetDefaultFontSmall()

	-- Render scroll area
	local scrollY = controlsY + searchHeight + 16
	local scrollRect = arect.new(startX, scrollY, screenx - 170, screeny - (scrollY + 50))
	scrollArea.set("obj_rect", scrollRect)
	marketplaceFlex.set("width", scrollRect.width)
	scrollArea.render(dt)
	boldFont = KinemiumFontService.GetBoldFont()

	for _, entry in ipairs(marketplaceEntries) do
		entry.card.set("font", vend)
		local page = pages[entry.plugin.manifest.id]
		if page then
			page.set("font", vend)
		end
	end

	marketplaceFilterDropdown.render(dt)
end
