local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")
local MouseCursor = require("@Kinemium.MouseCursor")
local lib = raylib.lib
local renderer = rlservice.GetRenderer()
local aereon = require("@Aereon")
local gui = aereon.gui
local rect = require("@Arect")
local transparent = Color3.new(1, 1, 1):ToRaylib(0.5)

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local ProjectLoaderService = game:GetService("ProjectLoaderService")
local FileDialogService = game:GetService("FileDialogService")
local ProjectSyncService = game:GetService("ProjectSyncService")
local RBXModelImporter = game:GetService("RBXModelImporter")
local project_prompt_active = false

local fs = Filesystem

local vend = KinemiumFontService.GetDefaultFont()
local boldFont = KinemiumFontService.GetBoldFont()
local arect = require("@arect")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local defaultKinemiumIcon = "./src/assets/images/kinemium/KinemiumWhite.png"
local logoIcon = KinemiumIconLoader.ToTexture(defaultKinemiumIcon)

local SecondaryBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor
local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

KinemiumIconLoader.new("Add", "./src/assets/images/plus.png")

local addIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Add"))

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)
local gameiconPath

local projectSearchBox
local projectFilterDropdown
local projectSearchText = ""
local projectFilter = "All"
local projectEntries = {}

KinemiumIconLoader.new("Folder", "./src/assets/images/icons/Folder.png")
KinemiumIconLoader.new("Project", "./src/assets/images/icons/DataModel.png")
KinemiumIconLoader.new("Path", "./src/assets/images/icons/Attachment.png")

local folderIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Folder"))
local projectIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Project"))
local pathIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Path"))

local projects = ProjectLoaderService.GetProjects() or {}

local generated_card_projects = {}

local function applyProjectFilter()
	local query = string.lower(projectSearchText or "")
	local now = os.time()
	for _, entry in ipairs(projectEntries) do
		local projectData = entry.project
		local name = string.lower(projectData.name or "")
		local path = string.lower(projectData.path or "")
		local matchesSearch = query == "" or string.find(name, query, 1, true) or string.find(path, query, 1, true)
		local isRecent = projectData.last_opened and (now - projectData.last_opened) <= (7 * 24 * 60 * 60)
		local matchesFilter = true
		if projectFilter == "Recent" then
			matchesFilter = isRecent
		elseif projectFilter == "Older" then
			matchesFilter = not isRecent
		end
		entry.card.set("visible", matchesSearch and matchesFilter)
	end
end

local cardStack = gui.vstack({
	spacing = 10,
	padding = 0,
	autoSize = true,
	backgroundColor = Color3.new(0, 0, 0),
	backgroundTransparency = 1,
})

local scrollArea = gui.scrollable({
	child = cardStack,
	scrollbarWidth = 8,
	scrollbarColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarHoverColor = StudioThemeService.SelectedTheme.Accent,
	scrollbarBackground = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

local function generateProjectCards()
	projects = ProjectLoaderService.GetProjects() or {}

	for _, projectData in pairs(projects) do
		-- if projectData.path already has a card, skip it
		if generated_card_projects[projectData.path] then
			continue
		end
		generated_card_projects[projectData.path] = true

		local icon

		if projectData.icon then
			icon = KinemiumIconLoader.ToTexture(projectData.icon)
		else
			icon = logoIcon
		end
		local stat = fs.stat(projectData.path)
		if stat.kind == "none" then
			continue
		end
		local card = gui.projectCard({
			comp = "projectCard",
			x = 0,
			y = 0,
			width = screenx - 135,
			title = projectData.name,
			subtext = "Edited on " .. os.date("%Y-%m-%d %H:%M:%S", projectData.last_opened),
			tags = { "son", "im crine" },
			backgroundColor = SecondaryBackgroundColor,
			icon = icon,
			font = vend,
			zindex = 3,
			onClick = function()
				if project_prompt_active then
					return
				end
				ishared.GameName = projectData.name
				ishared.FolderPath = projectData.path
				ishared.GameIcon = projectData.icon
				ishared.EnableHomescreen = false
				ProjectSyncService:StartSyncing(ishared.FolderPath)
				renderer:SetDimension("3D")
			end,
		})

		cardStack.add(card)
		table.insert(projectEntries, { project = projectData, card = card })
	end
end

local gameNameInput = textbox.new({
	multiline = false,
	placeholder = "Enter..",
	fontSize = 16,
	font = vend,
	maxLength = 56,
})

local projectPath = textbox.new({
	multiline = false,
	placeholder = "Enter path...",
	fontSize = 16,
	font = vend,
	maxLength = 56,
})

local dimension = gui.dropdown({
	x = 0,
	y = 0,
	width = 200,
	height = 30,

	options = { "2D", "3D" },
	font = vend,
	selectedIndex = 2,

	onSelect = function(index, value)
		print("Selected:", index, value)
	end,
})

local group
group = aereon.create({

	-- addition
	addButton = {
		comp = "imageButton",
		image = addIcon,
		y = 110,
		x = screenx - 50,
		width = 30,
		height = 30,
		zindex = 3,

		onClick = function()
			project_prompt_active = true
			group.newProjectPrompt.show()
		end,
	},

	newProjectPrompt = {
		comp = "prompt",
		visible = false,
		width = 600,
		height = 250,
		bodyHeight = 400,
		font = vend,
		backgroundColor = SecondaryBackgroundColor,
		title = "Create New Project",
		onClose = function()
			project_prompt_active = false
		end,
		buttons = {
			{
				text = "Create Project",
				width = 140,
				color = StudioThemeService.SelectedTheme.Accent,
				onClick = function()
					project_prompt_active = false
					local gnInput = gameNameInput:getText()
					local projInput = projectPath:getText()
					local path = "./src/projects/" .. gnInput

					if gnInput == "" then
						return
					end

					if projInput == "" then
						if fs.stat(path).kind ~= "none" then
							return
						end
						fs.makeDir(path)
						projInput = path
					end

					ishared.GameName = gnInput
					ishared.FolderPath = projInput
					ishared.GameIcon = gameiconPath
					ProjectLoaderService.NewProject(ishared.GameName, ishared.FolderPath, gameiconPath)
					ProjectSyncService:StartSyncing(ishared.FolderPath)
					ishared.EnableHomescreen = false
					renderer:SetDimension("3D")

					if ishared.RBXLPlacefile then
						local file = ishared.RBXLPlacefile
						if file then
							current_place_imported = file

							local converted = RBXModelImporter.ImportPlaceFile(file)

							-- expected structure:
							-- { Service = {children = raw}}
							if converted then
								for service, children in pairs(converted) do
									local service_object = game:GetService(service)
									if service_object then
										for _, child in pairs(children) do
											if child then
												child.Parent = service_object
											end
										end
									end
								end
							end
						end
					end

					generateProjectCards()
					applyProjectFilter()
				end,
			},
		},
		bodyRenderer = function(dt, x, y, width, height)
			-- Logo Container
			local logoBg = SecondaryBackgroundColor:ToRaylib(0.2)
			local logoSize = 180
			local logoX = x + 10
			local logoY = y + 10
			local logoRect = rect.new(logoX, logoY, logoSize, logoSize)

			-- Draw logo background
			raylib.lib.DrawRectangleRounded(rect:translate(logoRect), 0.1, 12, logoBg)

			-- Import button (stub)
			if not group.importButton then
				group.importButton = gui.imageTextButton({
					text = "Import RBXL/RBXLX",
					icon = folderIcon,
					font = vend,
					fontSize = 14,
					backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
					hoverColor = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
					pressColor = StudioThemeService.SelectedTheme.Accent,
					textColor = StudioThemeService.SelectedTheme.TextColor,
					rounded = { 0.2, 6 },
					onClick = function()
						local file = FileDialogService.RequestFile({
							{ name = "Place file", extensions = { "rbxl", "rbxlx" } },
						})

						ishared.RBXLPlacefile = file
					end,
				})
			end
			local importW, importH = 240, 28
			local importX = x + 10
			local importY = y + height - importH - 10
			group.importButton.set("obj_rect", arect.new(importX, importY, importW, importH))
			group.importButton.render(dt)

			local iconRectSource = rect.new(0, 0, logoIcon.x, logoIcon.y)
			local iconPadding = 20
			local iconDisplayRect = rect.new(
				logoX + iconPadding,
				logoY + iconPadding,
				logoSize - iconPadding * 2,
				logoSize - iconPadding * 2
			)

			local isLogoHovered = rect.MouseIsInRect(logoRect)
			local tint = isLogoHovered and transparent or raylib.const.WHITE

			lib.DrawTexturePro(
				logoIcon.texture,
				rect:translate(iconRectSource),
				rect:translate(iconDisplayRect),
				vector.create(0, 0),
				0,
				tint
			)

			if isLogoHovered then
				MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
				lib.DrawTextEx(
					vend,
					"CHANGE ICON",
					vector.create(logoX + 45, logoY + logoSize / 2 - 8),
					14,
					1,
					raylib.const.WHITE
				)
			end

			rect.Button(logoRect, function()
				local imagePath = FileDialogService.RequestFile({
					{ name = "Images", extensions = { "png", "jpg", "jpeg", "bmp" } },
					{ name = "All Files", extensions = { "*" } },
				})
				if imagePath then
					logoIcon = KinemiumIconLoader.ToTexture(imagePath)
					gameiconPath = imagePath
				end
			end)

			-- Input Fields Section
			local inputX = x + logoSize + 40
			local inputW = width - logoSize - 50

			-- Game Name
			lib.DrawTexturePro(
				projectIcon.texture,
				rect.new(0, 0, projectIcon.x, projectIcon.y).rect,
				rect.new(inputX, y - 2, 20, 20).rect,
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
			lib.DrawTextEx(vend, "Game Name", vector.create(inputX + 28, y), 16, 1, raylib.const.WHITE)
			gameNameInput:drawWithExtras(inputX, y + 30, inputW, 45)

			-- Project Path
			lib.DrawTexturePro(
				folderIcon.texture,
				rect.new(0, 0, folderIcon.x, folderIcon.y).rect,
				rect.new(inputX, y + 98, 20, 20).rect,
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
			lib.DrawTextEx(vend, "Project Path", vector.create(inputX + 28, y + 100), 16, 1, raylib.const.WHITE)
			projectPath:drawWithExtras(inputX, y + 130, inputW - 40, 45)

			-- Path Explorer Button
			local explorerRect = rect.new(inputX + inputW - 30, y + 130, 30, 45)
			local isExplorerHovered = rect.MouseIsInRect(explorerRect)
			raylib.lib.DrawRectangleRounded(
				rect:translate(explorerRect),
				0.2,
				8,
				isExplorerHovered and StudioThemeService.SelectedTheme.Accent:ToRaylib(0.2)
					or SecondaryBackgroundColor:ToRaylib(0)
			)
			lib.DrawTexturePro(
				pathIcon.texture,
				rect.new(0, 0, 16, 16).rect,
				rect.new(explorerRect.x + 7, explorerRect.y + 14, 16, 16).rect,
				vector.create(0, 0),
				0,
				isExplorerHovered and raylib.const.WHITE or transparent
			)

			rect.Button(explorerRect, function()
				local projectPathStr = FileDialogService.RequestFolder({
					{ name = "Kinemium Project", extensions = { "kproj" } },
					{ name = "All Files", extensions = { "*" } },
				})
				if projectPathStr then
					projectPath:setText(projectPathStr)
				end
			end)

			-- Dimension
			lib.DrawTextEx(vend, "Dimension", vector.create(inputX, y + 200), 16, 1, raylib.const.WHITE)
			dimension.set("obj_rect", rect.new(inputX, y + 230, inputW, 40))
			dimension.render(dt)
		end,
		zindex = 5,
	},
})

repeat
	task.wait()
until ishared.Home

generateProjectCards()
applyProjectFilter()

ishared.Home.pages["Projects"] = function(dt, alpha, slideOffset)
	local fade = function(col, a)
		return col:ToRaylib(1 - (a or 1) * alpha)
	end

	if ishared.Home.activePage ~= "Projects" and ishared.Home.previousPage ~= "Projects" then
		return
	end

	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	local startX = 100
	local headerY = 80 + slideOffset
	local controlsY = headerY + 90
	local searchHeight = 32
	local dropdownWidth = 180
	local gap = 12

	group.addButton.set("obj_rect", arect.new(screenx - 50, 110 + slideOffset, 30, 30))
	group.newProjectPrompt.set("obj_rect", arect.new(0, 0, 600, 250))
	group.render(dt, { "newProjectPrompt" })

	if vend then
		raylib.lib.DrawTextEx(
			boldFont,
			"Projects",
			vector.create(startX, headerY),
			42,
			1,
			fade(StudioThemeService.SelectedTheme.TextColor, 1)
		)
		raylib.lib.DrawTextEx(
			vend,
			"Manage and open your Kinemium Engine projects",
			vector.create(startX, headerY + 50),
			18,
			1,
			fade(StudioThemeService.SelectedTheme.SecondaryTextColor, 1)
		)
	end

	-- Search + Filter
	if not projectSearchBox then
		projectSearchBox = textbox.new({
			padding = 8,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			textColor = StudioThemeService.SelectedTheme.TextColor,
			placeholderColor = StudioThemeService.SelectedTheme.SecondaryTextColor,
			cornerRadius = 0.2,
			BackgroundTransparency = 0,
			BorderTransparency = 1,
			placeholder = "Search projects...",
			fontSize = 14,
			escapeBlurs = false,
			blurOnSubmit = false,
			onChange = function(text)
				projectSearchText = text or ""
				applyProjectFilter()
			end,
		})
	end

	local searchWidth = screenx - 170 - dropdownWidth - gap
	projectSearchBox:drawWithExtras(startX, controlsY + slideOffset, searchWidth, searchHeight)
	local currentSearch = projectSearchBox:getText() or ""
	if currentSearch ~= projectSearchText then
		projectSearchText = currentSearch
		applyProjectFilter()
	end

	if not projectFilterDropdown then
		projectFilterDropdown = gui.dropdown({
			x = startX + searchWidth + gap,
			y = controlsY + slideOffset,
			width = dropdownWidth,
			height = searchHeight,
			options = { "All", "Recent", "Older" },
			font = vend,
			selectedIndex = 1,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			hoverColor = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
			textColor = StudioThemeService.SelectedTheme.TextColor,
			borderTransparency = 1,
			onSelect = function(index, value)
				projectFilter = value or "All"
				applyProjectFilter()
			end,
			onExpand = function()
				if group.newProjectPrompt.get("visible") then
					return
				end
				project_prompt_active = projectFilterDropdown.get("expanded")
			end,
			onCollapse = function()
				if group.newProjectPrompt.get("visible") then
					return
				end
				project_prompt_active = projectFilterDropdown.get("expanded")
			end,
		})
	end
	projectFilterDropdown.set(
		"obj_rect",
		arect.new(startX + searchWidth + gap, controlsY + slideOffset, dropdownWidth, searchHeight)
	)

	-- Render scroll area
	local scrollY = controlsY + searchHeight + 16 + slideOffset
	scrollArea.set("obj_rect", arect.new(100, scrollY, screenx - 170, screeny - (scrollY + 50)))
	cardStack.set("width", screenx - 180) -- Adjust stack width for scrollbar
	scrollArea.render(dt)

	projectFilterDropdown.render(dt)

	group.newProjectPrompt.render(dt)
end
