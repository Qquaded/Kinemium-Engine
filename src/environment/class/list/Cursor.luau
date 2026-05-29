-- description: "Represents a Cursor in the environment."
local GuiObject = require("@GuiObject")

local raylib = require("@raylib")
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

-- description: "Generates cursor images."
-- args: "object: table"
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
					object._cache[string.gsub(name, ".cur", "")] = raylib.lib.LoadTexture(newFilePath)
				end
                --]]
			elseif string.find(name, ".png") and not _G.IsHeadless then
				local filePath = fs.path.join(iconpack_path, name)
				object._cache[string.gsub(name, ".png", "")] = raylib.lib.LoadTexture(filePath)
			end
		end
	end
end

GuiObject.inherit(propTable)

-- description: "Renders the component."
-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
propTable.render = function(lib, object, dt, structs, renderer)
	raylib.lib.HideCursor()

	if not object._cache then
		return
	end
	local pos = raylib.lib.GetMousePosition()
	local arrow = object._cache.arrow
	local sizex, sizey = buffer.readi32(arrow, 4), buffer.readi32(arrow, 8)
	local objectSize = object.Size

	--raylib.lib.DrawTexturePro(texture: buffer, source: buffer, dest: buffer, origin: vector, rotation: number, tint: buffer)
	raylib.lib.DrawTexturePro(
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
		raylib.const.WHITE
	)
end

return {
	class = "Cursor",
	render = propTable.render,
	-- description: "Initializes the Cursor instance."
	-- args: "instance: table, renderer: number"
	-- returns: "table"
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
	-- description: "Inherits the properties of the Cursor class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
