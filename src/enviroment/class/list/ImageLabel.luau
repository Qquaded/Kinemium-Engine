local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local _Enum = require("@EnumMap")
local GuiObject = require("@GuiObject")
local raylib = require("@raylib")
local lib = raylib.lib

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	Image = "./src/assets/images/placeholder.png",
	ImageColor3 = Color3.new(1, 1, 1),
	ImageTransparency = 0,
	--ScaleType = Enum.ScaleType.Stretch,
	--SliceCenter = Rect.new(0, 0, 0, 0),
	--SliceScale = 1,
	Name = "ImageLabel",
	Visible = true,
	ZIndex = 1,

	_cached = nil,
}

propTable.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize = GuiObject.render(lib, object, dt, structs, renderer)

	if type(object.Image) == "table" and object.Image.ClassName == "EditableImage" then
		local eImage = object.Image

		if eImage._dirty then
			lib.UnloadTexture(eImage._texture)
			eImage._texture = lib.LoadTextureFromImage(eImage._image)
			eImage._dirty = false
		end

		local tex = eImage._texture
		if tex then
			local rec = structs.Rectangle:new({
				x = 0,
				y = 0,
				width = eImage.Size.X,
				height = eImage.Size.Y,
			})
			local dest = structs.Rectangle:new({
				x = framePos.X,
				y = framePos.Y,
				width = frameSize.X,
				height = frameSize.Y,
			})

			if object.ImageTransparency ~= 1 then
				local a = math.clamp(math.floor(255 * (1 - (object.ImageTransparency or 0))), 0, 255)
				local rcol = structs.Color:new({
					r = object.ImageColor3.R * 255,
					g = object.ImageColor3.G * 255,
					b = object.ImageColor3.B * 255,
					a = a,
				})

				lib.DrawTexturePro(
					tex,
					rec,
					dest,
					vector.create(0, 0), -- origin top-left
					object.Rotation or 0,
					rcol
				)
			end
		end
	elseif object._cached then
		local size = vector.create(buffer.readi32(object._cached, 4), buffer.readi32(object._cached, 8))

		local rec = structs.Rectangle:new({
			x = 0,
			y = 0,
			width = size.x,
			height = size.y,
		})

		local dest = structs.Rectangle:new({
			x = framePos.X,
			y = framePos.Y,
			width = frameSize.X,
			height = frameSize.Y,
		})

		if object.ImageTransparency ~= 1 then
			local a = math.clamp(math.floor(255 * (1 - (object.ImageTransparency or 0))), 0, 255)
			local rcol = structs.Color:new({
				r = object.ImageColor3.R * 255,
				g = object.ImageColor3.G * 255,
				b = object.ImageColor3.B * 255,
				a = a,
			})

			lib.DrawTexturePro(
				object._cached,
				rec,
				dest,
				vector.create(0, 0), -- origin top-left
				object.Rotation or 0,
				rcol
			)
		end
	end

	return framePos, frameSize, object._cached
end

GuiObject.inherit(propTable)

return {
	class = "ImageLabel",
	render = propTable.render,
	callback = function(instance, renderer)
		if type(instance.Image) == "string" then
			instance._cached = lib.LoadTexture(instance.Image)
			lib.SetTextureFilter(instance._cached, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			lib.SetTextureWrap(instance._cached, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			lib.GenTextureMipmaps(instance._cached)
		end

		instance.Changed:Connect(function(property)
			if property == "Image" then
				if type(instance.Image) == "string" then
					if instance._cached then
						lib.UnloadTexture(instance._cached)
					end
					instance._cached = lib.LoadTexture(instance.Image)
					lib.SetTextureFilter(instance._cached, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
					lib.SetTextureWrap(instance._cached, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
					lib.GenTextureMipmaps(instance._cached)
				else
					-- Drop cached string representation backing if swapping to an editable map type
					if instance._cached then
						lib.UnloadTexture(instance._cached)
						instance._cached = nil
					end
				end
			end
		end)

		instance:SetProperties(propTable)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
