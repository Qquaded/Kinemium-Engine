return function(objects, config, raylib)
	local cells = {}
	local cellRefs = {}
	local MergedCell = require("./cellItem")

	local arect = require("@arect")

	local defaults = {
		x = config.x or 0,
		y = config.y or 0,
		width = config.width or 800,
		cellHeight = config.cellHeight or 70,
		spacing = config.spacing or 0, -- Spacing between groups
		groupSpacing = config.groupSpacing or 20, -- Spacing between different groups
	}

	local props = {}
	local cellOffsets = {}

	local function createCell(cellConfig, position, yOffset)
		local cell = MergedCell(objects, {
			x = cellConfig.x or defaults.x,
			y = (cellConfig.y or defaults.y) + yOffset,
			width = cellConfig.width or defaults.width,
			height = cellConfig.height or defaults.cellHeight,

			propertyName = cellConfig.name or cellConfig.propertyName or "Property",
			propertyDescription = cellConfig.description or cellConfig.propertyDescription,
			propertyValue = cellConfig.value or cellConfig.propertyValue,
			font = cellConfig.font,
			roundness = 0.3,

			position = position,
			showSeparator = cellConfig.showSeparator,

			backgroundColor = cellConfig.backgroundColor,
			hoverColor = cellConfig.hoverColor,
			separatorColor = cellConfig.separatorColor,
			textColor = cellConfig.textColor,
			descriptionColor = cellConfig.descriptionColor,

			editorComponent = cellConfig.editor or cellConfig.editorComponent,
			editorWidth = cellConfig.editorWidth or 200,

			onValueChange = cellConfig.onValueChange,
			onClick = cellConfig.onClick,
		}, raylib)

		return cell
	end

	local currentY = 0

	for groupName, groupConfig in pairs(config) do
		if
			groupName == "x"
			or groupName == "y"
			or groupName == "width"
			or groupName == "cellHeight"
			or groupName == "spacing"
			or groupName == "groupSpacing"
		then
			continue
		end

		if type(groupConfig) == "table" then
			local groupCells = {}
			local groupItems = {}

			if groupConfig.items then
				groupItems = groupConfig.items
			elseif groupConfig[1] then
				groupItems = groupConfig
			else
				groupItems = { groupConfig }
			end

			local itemCount = #groupItems
			for i, itemConfig in ipairs(groupItems) do
				local position = "middle"
				if itemCount == 1 then
					position = "single"
				elseif i == 1 then
					position = "first"
				elseif i == itemCount then
					position = "last"
				end

				if itemConfig.showSeparator == nil then
					itemConfig.showSeparator = i < itemCount
				end

				local cell = createCell(itemConfig, position, currentY)
				table.insert(groupCells, cell)
				table.insert(cells, cell)
				cellOffsets[cell] = currentY

				local editorcomp = itemConfig.editor
				if editorcomp then
					props[cell] = editorcomp
				end

				currentY = currentY + (itemConfig.height or defaults.cellHeight)
			end

			-- Store reference to group
			cellRefs[groupName] = groupCells

			-- Add spacing after group
			currentY = currentY + (groupConfig.spacing or defaults.groupSpacing)
		end
	end

	local wrapper = {}
	local overallRect = arect.new(defaults.x, defaults.y, defaults.width, currentY)

	wrapper.set = function(prop, value)
		if prop == "obj_rect" then
			overallRect = value
			wrapper.setPosition(value.x, value.y)
		elseif prop == "width" then
			overallRect.width = value
			wrapper.setWidth(value)
		end
		return wrapper
	end

	wrapper.get = function(prop)
		if prop == "obj_rect" then
			return overallRect
		end
		return cellRefs[prop]
	end

	wrapper.render = function(dt)
		for _, cell in ipairs(cells) do
			cell.render(dt)
		end
		for cell, comp in pairs(props) do
			local r = cell.getRect()

			local editorX = r.x + r.width - (cell.editorWidth or 240) - (cell.padding or 10)
			local editorY = r.y + (r.height - 30) / 2
			local editorWidth = cell.editorWidth or 240
			local editorHeight = 30

			local new = arect.new(editorX, editorY, editorWidth, editorHeight)
			if comp.set then
				comp.set("obj_rect", new)
			else
				comp.obj_rect = new
			end

			if comp.render then
				comp.render(dt)
			elseif comp.drawWithExtras then
				comp:drawWithExtras(new.x, new.y, new.width, new.height)
			end
		end
	end

	wrapper.getAll = function()
		return cells
	end

	wrapper.setPosition = function(x, y)
		for _, cell in ipairs(cells) do
			local cellRect = cell.getRect()
			local offsetY = cellOffsets[cell] or 0
			cell.set("obj_rect", arect.new(x, y + offsetY, cellRect.width, cellRect.height))
		end
	end

	wrapper.SetAllCellProp = function(prop, value)
		for cell, comp in pairs(props) do
			cell.set(prop, value)
		end
	end

	wrapper.setWidth = function(width)
		for _, cell in ipairs(cells) do
			local cellRect = cell.getRect()
			cell.set("obj_rect", arect.new(cellRect.x, cellRect.y, width, cellRect.height))
		end
	end

	wrapper.setValue = function(groupName, index, value)
		local group = cellRefs[groupName]
		if group and group[index] then
			group[index].setPropertyValue(value)
		end
	end

	wrapper.getValue = function(groupName, index)
		local group = cellRefs[groupName]
		if group and group[index] then
			return group[index].getPropertyValue()
		end
		return nil
	end

	return wrapper
end
