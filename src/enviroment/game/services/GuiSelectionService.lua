local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Vector3 = require("@Vector3")

local GuiSelectionService = Instance.new("GuiSelectionService")
local raylib = require("@raylib")
GuiSelectionService.ExplorerHidden = true

local function isMouseInRect(rect, mousePos)
	return mousePos.x >= rect.x
		and mousePos.x <= rect.x + rect.width
		and mousePos.y >= rect.y
		and mousePos.y <= rect.y + rect.height
end

local dragStart = nil
local dragging = false
local task = zune.task

local guiSelection = nil
local dragOffset = { x = 0, y = 0 }

local function HandleDragSelection(elements, renderer)
	local mouse = renderer.lib.GetMousePosition()
	local lib = renderer.lib

	print("hi")

	if lib.IsMouseButtonPressed(0) == 1 then
		dragStart = { x = mouse.x, y = mouse.y }
		dragging = true
		GuiSelectionService.CurrentSelection = {} -- reset
	end

	if dragging and dragStart then
		local dragEnd = { x = mouse.x, y = mouse.y }

		local minX, maxX = math.min(dragStart.x, dragEnd.x), math.max(dragStart.x, dragEnd.x)
		local minY, maxY = math.min(dragStart.y, dragEnd.y), math.max(dragStart.y, dragEnd.y)

		GuiSelectionService.CurrentSelection = {}
		for _, elem in ipairs(elements) do
			local r = elem.rect
			if r.x < maxX and r.x + r.width > minX and r.y < maxY and r.y + r.height > minY then
				table.insert(GuiSelectionService.CurrentSelection, elem.instance)
			end
		end

		renderer.lib.DrawRectangle(
			minX,
			minY,
			maxX - minX,
			maxY - minY,
			renderer.structs.Color:new({ r = 0, g = 0.4, b = 1, a = 0.3 })
		)
	end

	if dragging and lib.IsMouseButtonReleased(0) == 1 then
		dragging = false
		dragStart = nil
	end
end
GuiSelectionService.InitRenderer = function(renderer, signal, game)
	GuiSelectionService:SetProperties({
		CurrentlySelected = nil,
		elements = {},
		add = function(GuiObject)
			local element = {
				instance = GuiObject,
				rect = {
					x = GuiObject.AbsolutePosition.X,
					y = GuiObject.AbsolutePosition.Y,
					width = GuiObject.AbsoluteSize.X,
					height = GuiObject.AbsoluteSize.Y,
				},
			}

			GuiSelectionService.elements[GuiObject.UniqueId] = element
		end,
		step = function()
			HandleDragSelection(GuiSelectionService.elements, renderer)
		end,
	})
end

return GuiSelectionService
