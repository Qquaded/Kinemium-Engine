-- description: "Controls the appearance and behavior of the mouse cursor in the user interface."
local GuiObject = require("@GuiObject")

local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")

local fs = zune.fs

local propTable = {
	Name = "Cursor",
	IconPack = "./src/assets/icon/cursor",
	Size = Vector2.new(42, 42),
	Color = Color3.new(1, 1, 1),
	Transparency = 0,
}

local function generateCursorImages(object)
	object._cache = {}
	local iconpack_path = zembed.AssetPath(object.IconPack)

	local entries = fs.entries(iconpack_path)

	for _, file in pairs(entries) do
		local kind = file.kind
		local name = file.name

		if kind == "file" then
			if string.find(name, ".cur") then
				--[[
				local filePath = iconpack_path .. "/" .. name
				local content = fs.readFile(filePath, true)
				if content then
					local newFilePath = string.gsub(filePath, name, "")
					newFilePath = newFilePath .. string.gsub(name, ".cur", ".png")
					fs.writeFile(newFilePath, content)
					object._cache[string.gsub(name, ".cur", "")] = adapter.lib.LoadTexture(newFilePath)
				end
                --]]
			elseif string.find(name, ".png") and not _G.IsHeadless then
				local filePath = fs.path.join(iconpack_path, name)
				object._cache[string.gsub(name, ".png", "")] = adapter.lib.LoadTexture(filePath)
			end
		end
	end
end

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	adapter.lib.HideCursor()

	if not object._cache then
		return
	end
	local pos = adapter.lib.GetMousePosition()
	local arrow = object._cache.arrow
	local sizex, sizey = buffer.readi32(arrow, 4), buffer.readi32(arrow, 8)
	local objectSize = object.Size

	--adapter.lib.DrawTexturePro(texture: buffer, source: buffer, dest: buffer, origin: vector, rotation: number, tint: buffer)
	adapter.lib.DrawTexturePro(
		arrow,
		structs.Rectangle:new({ x = 0, y = 0, width = sizex, height = sizey }),
		structs.Rectangle:new({
			x = pos.x,
			y = pos.y,
			width = objectSize.X,
			height = objectSize.Y,
		}),
		vector.create(0, 0),
		0,
		adapter.const.WHITE
	)
end

return {
	class = "Cursor",
	render = propTable.render,

	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		generateCursorImages(instance)

		instance.Changed:Connect(function(property)
			if property == "IconPack" then
				generateCursorImages(instance)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
