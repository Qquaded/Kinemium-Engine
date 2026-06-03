local Plugin = game:GetService("Plugin")
local lib = require("@raylib").lib
local structs = require("@raylib").structs
local Color3 = require("@Color3")
local Vector3 = require("@Vector3")

local Selection = game:GetService("Selection")
local FileDialogService = game:GetService("FileDialogService")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

repeat
	task.wait()
until ishared.NewToolbarElement
local NewToolbarElement = ishared.NewToolbarElement
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local r3d = require("@r3d")
local meshgen = require("@meshgen")

local WINDOW_W = 700
local WINDOW_H = 470
local PANEL_W = 240
local VIEWPORT_PADDING = 10
local VIEWPORT_X = PANEL_W + VIEWPORT_PADDING
local VIEWPORT_Y = VIEWPORT_PADDING
local VIEWPORT_W = WINDOW_W - PANEL_W - VIEWPORT_PADDING * 2
local VIEWPORT_H = WINDOW_H - VIEWPORT_PADDING * 6

local enabled = false

local gui = Plugin:CreateDockWidgetPluginGui("MeshImporter", {
	Title = "Mesh Importer",
	FloatingSize = { Width = WINDOW_W, Height = WINDOW_H },
	ContentPaddingX = 0,
	ContentPaddingY = 0,
	Visible = false,
})

local importSettings = {
	path = "",
	scale = 1.0,
	smoothNormals = false,
	flipUVs = false,
	selectedFormat = 1,
}

--  Left Panel Background

gui:AddRenderCallback(function(dt, win, baseX, baseY)
	-- left panel bg
	lib.DrawRectangle(baseX, baseY, PANEL_W, WINDOW_H, structs.Color:new({ r = 28, g = 28, b = 32, a = 0 }))

	-- viewport bg + border
	lib.DrawRectangle(
		baseX + VIEWPORT_X - 2,
		baseY + VIEWPORT_Y - 2,
		VIEWPORT_W + 4,
		VIEWPORT_H + 4,
		structs.Color:new({ r = 18, g = 18, b = 22, a = 255 })
	)
	lib.DrawRectangle(
		baseX + VIEWPORT_X,
		baseY + VIEWPORT_Y,
		VIEWPORT_W,
		VIEWPORT_H,
		structs.Color:new({ r = 22, g = 22, b = 26, a = 255 })
	)

	-- viewport label when empty
	if importSettings.path == "" then
		local text = "No mesh loaded"
		local fontSize = 14
		local textW = lib.MeasureText(text, fontSize)
		lib.DrawText(
			text,
			baseX + VIEWPORT_X + (VIEWPORT_W - textW) // 2,
			baseY + VIEWPORT_Y + VIEWPORT_H // 2 - fontSize // 2,
			fontSize,
			structs.Color:new({ r = 80, g = 80, b = 90, a = 255 })
		)
	end

	-- viewport border overlay (drawn on top so 3D content doesn't bleed)
	lib.DrawRectangleLinesEx(
		structs.Rectangle:new({
			x = baseX + VIEWPORT_X,
			y = baseY + VIEWPORT_Y,
			width = VIEWPORT_W,
			height = VIEWPORT_H,
		}),
		1,
		structs.Color:new({ r = 55, g = 55, b = 65, a = 255 })
	)

	-- viewport corner label
	lib.DrawText(
		"Preview",
		baseX + VIEWPORT_X + 8,
		baseY + VIEWPORT_Y + 8,
		11,
		structs.Color:new({ r = 90, g = 90, b = 105, a = 255 })
	)
end, -1) -- order -1 so it draws before widgets

--  Left Panel Widgets

local PAD = 12 -- left panel inner padding
local W = PANEL_W - PAD * 2
local y = 0

local function nextY(height, gap)
	local cur = y
	y = y + height + (gap or 8)
	return cur
end

-- Section: File
gui:CreateLabel({ Text = "File", x = PAD, y = nextY(14, 4), width = W, height = 14, fontSize = 11 })

local pathInputY = nextY(32, 10)
local pathInput = gui:CreateTextInput({
	x = PAD,
	y = pathInputY,
	width = W - 38,
	height = 32,
	placeholder = "path/to/mesh.obj",
	onSubmit = function(text)
		importSettings.path = text
	end,
})

gui:CreateButton({
	Text = "...",
	x = PAD + W - 34,
	y = pathInputY,
	width = 34,
	height = 32,
	Activated = function()
		local filePath = FileDialogService.RequestFile({
			{ name = "Mesh Files", extensions = { "obj", "gltf", "glb", "fbx", "stl" } },
			{ name = "All Files", extensions = { "*" } },
		})
		if filePath and filePath ~= "" then
			pathInput:SetText(filePath)
			importSettings.path = filePath
		end
	end,
})

-- Section: Format
gui:CreateLabel({ Text = "Format", x = PAD, y = nextY(14, 4), width = W, height = 14, fontSize = 11 })

local formatDropdown = gui:CreateDropdown({
	x = PAD,
	y = nextY(32, 10),
	width = W,
	height = 32,
	options = { "OBJ", "GLTF", "FBX", "STL" },
	selectedIndex = 1,
	onSelect = function(index)
		importSettings.selectedFormat = index
	end,
})

-- Section: Scale
gui:CreateLabel({ Text = "Scale", x = PAD, y = nextY(14, 4), width = W, height = 14, fontSize = 11 })

local scaleSlider = gui:CreateSlider({
	x = PAD,
	y = nextY(28, 2),
	width = W,
	height = 28,
	value = 1.0,
	min = 0.01,
	max = 10.0,
	onChanged = function(v)
		importSettings.scale = v
	end,
})

local scaleValueLabel = gui:CreateLabel({
	Text = "1.00",
	x = PAD,
	y = nextY(14, 10),
	width = W,
	height = 14,
	fontSize = 11,
})

scaleSlider.Changed:Connect(function(v)
	scaleValueLabel:SetText(("%.2f"):format(v))
end)

-- Section: Options
gui:CreateLabel({ Text = "Options", x = PAD, y = nextY(14, 6), width = W, height = 14, fontSize = 11 })

gui:CreateLabel({ Text = "Smooth Normals", x = PAD, y = nextY(13, 3), width = W, height = 13, fontSize = 11 })
local smoothToggle = gui:CreateSwitch({
	x = PAD,
	y = nextY(28, 8),
	width = W,
	height = 28,
	value = false,
	onChanged = function(v)
		importSettings.smoothNormals = v
	end,
})

gui:CreateLabel({ Text = "Flip UVs", x = PAD, y = nextY(13, 3), width = W, height = 13, fontSize = 11 })
local flipToggle = gui:CreateSwitch({
	x = PAD,
	y = nextY(28, 14),
	width = W,
	height = 28,
	value = false,
	onChanged = function(v)
		importSettings.flipUVs = v
	end,
})

--  Progress bar

local progressBar = gui:CreateProgressBar({
	x = PAD,
	y = nextY(8, 4),
	width = W,
	height = 8,
	progress = 0,
	visible = false,
})

local statusLabel = gui:CreateLabel({
	Text = "",
	x = PAD,
	y = nextY(13, 10),
	width = W,
	height = 13,
	fontSize = 10,
})

--  Buttons

local importButton = gui:CreateButton({
	Text = "Import",
	x = PAD,
	y = nextY(32, 6),
	width = W,
	height = 32,
	Activated = function()
		if importSettings.path == "" then
			statusLabel:SetText("No file path set.")
			return
		end

		progressBar:Set("visible", true)
		progressBar:SetProgress(0)
		statusLabel:SetText("Importing...")

		task.spawn(function()
			for i = 1, 20 do
				task.wait(0.04)
				progressBar:SetProgress(i / 20)
			end

			local R3D_IMPORT_MESH_DATA = 1
			local R3D_Model = r3d.lib.R3D_LoadModelEx(importSettings.path, R3D_IMPORT_MESH_DATA)
			local meshCount = buffer.readi32(R3D_Model, r3d.structs.R3D_Model:offset("meshCount"))

			if meshCount == 0 then
				print("No meshes found in model")
				return
			end

			local file_name = string.match(importSettings.path, "([^/\\]+)%.%w+$")

			local parentFolder = Instance.new("Folder")
			parentFolder.Name = file_name

			local selected = Selection.Get()[1]
			parentFolder.Parent = selected or game.Workspace

			for i = 0, meshCount - 1 do
				local mesh = meshgen.extractModelMesh(R3D_Model, i)
				if not mesh then
					continue
				end

				local aabb = mesh.aabb
				local size = Vector3.new(
					(aabb.max.x - aabb.min.x) * importSettings.scale,
					(aabb.max.y - aabb.min.y) * importSettings.scale,
					(aabb.max.z - aabb.min.z) * importSettings.scale
				)
				local center = Vector3.new(
					(aabb.min.x + aabb.max.x) / 2 * importSettings.scale,
					(aabb.min.y + aabb.max.y) / 2 * importSettings.scale,
					(aabb.min.z + aabb.max.z) / 2 * importSettings.scale
				)

				local new = Instance.new("MeshPart")
				new.Name = if meshCount > 1 then file_name .. "_" .. i else file_name
				new.MeshObject = mesh
				new.Size = size
				new.CFrame = CFrame.new(center)
				new.Anchored = true
				new.Transparency = 0
				new.Parent = parentFolder
			end

			statusLabel:SetText("Done.")
			progressBar:Set("visible", false)
		end)
	end,
})

gui:CreateButton({
	Text = "Reset",
	x = PAD,
	y = nextY(28, 0),
	width = W,
	height = 28,
	Activated = function()
		pathInput:SetText("")
		formatDropdown:SetValue(1)
		scaleSlider:SetValue(1.0)
		scaleValueLabel:SetText("1.00")
		smoothToggle:SetValue(false)
		flipToggle:SetValue(false)
		progressBar:Set("visible", false)
		statusLabel:SetText("")
		importSettings = { path = "", scale = 1.0, smoothNormals = false, flipUVs = false, selectedFormat = 1 }
	end,
})

function gui:GetViewportRect()
	local ox, oy = self:GetContentOrigin()
	return {
		x = ox + VIEWPORT_X,
		y = oy + VIEWPORT_Y,
		width = VIEWPORT_W,
		height = VIEWPORT_H,
	}
end

gui:Hide()

NewToolbarElement:Fire("Tools", "MeshImporter", {
	type = "ImageButton",
	text = "Mesh Importer",
	callback = function(element, rect)
		enabled = not enabled

		if enabled then
			gui:Show()
		else
			gui:Hide()
		end
	end,
	hoverTransparency = 0.5,
	hoverColor = Color3.new(0, 0, 0),
	roundness = 0.2,
	texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/EditableMesh.png"),
})

return gui
