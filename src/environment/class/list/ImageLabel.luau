-- description: "A 2D GUI object that displays an image."
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local _Enum = require("@EnumMap")
local GuiObject = require("@GuiObject")
local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local lib = adapter.lib

local roundedShader

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	Image = "./src/assets/images/placeholder.png",
	ImageColor3 = Color3.new(1, 1, 1),
	ImageTransparency = 0,
	Shader = nil,
	--ScaleType = Enum.ScaleType.Stretch,
	--SliceCenter = Rect.new(0, 0, 0, 0),
	--SliceScale = 1,
	Name = "ImageLabel",
	Visible = true,
	ZIndex = 1,

	_cached = nil,
}

propTable.render = function(lib, object, dt, structs, renderer)
	if not roundedShader then
		roundedShader = lib.LoadShader(nil, zembed.AssetPath("kineasset://shaders/rounded.fs"))
	end
	local framePos, frameSize = GuiObject.render(lib, object, dt, structs, renderer)
	if not framePos or not frameSize then
		return
	end

	local blend = object:FindFirstChildOfClass("UIBlend")
	local didBlend = false
	if blend and blend.Enabled ~= false and blend.AffectSelf ~= false then
		lib.BeginBlendMode(GuiObject.resolveBlendMode(raylib, blend.Mode))
		didBlend = true
	end

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

				if object.Shader and object.Shader._shader then
					adapter.lib.BeginShaderMode(object.Shader._shader)
				end
				lib.DrawTexturePro(
					object._cached,
					rec,
					dest,
					vector.create(0, 0), -- origin top-left
					object.Rotation or 0,
					rcol
				)
				if object.Shader and object.Shader._shader then
					adapter.lib.EndShaderMode()
				end
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

			if object.Shader and object.Shader._shader then
				adapter.lib.BeginShaderMode(object.Shader._shader)
			end
			lib.DrawTexturePro(
				object._cached,
				rec,
				dest,
				vector.create(0, 0), -- origin top-left
				object.Rotation or 0,
				rcol
			)
			if object.Shader and object.Shader._shader then
				adapter.lib.EndShaderMode()
			end
		end
	end

	if didBlend then
		lib.EndBlendMode()
	end

	return framePos, frameSize, object._cached
end

GuiObject.inherit(propTable)

return {
	class = "ImageLabel",
	render = propTable.render,
	callback = function(instance, renderer)
		if type(instance.Image) == "string" and not _G.IsHeadless then
			instance._cached = lib.LoadTexture(zembed.AssetPath(instance.Image))
			lib.SetTextureFilter(instance._cached, adapter.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			lib.SetTextureWrap(instance._cached, adapter.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			lib.GenTextureMipmaps(instance._cached)
		end

		instance.Changed:Connect(function(property)
			if property == "Image" then
				if type(instance.Image) == "string" and not _G.IsHeadless then
					if instance._cached then
						lib.UnloadTexture(instance._cached)
					end
					instance._cached = lib.LoadTexture(zembed.AssetPath(instance.Image))
					lib.SetTextureFilter(instance._cached, adapter.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
					lib.SetTextureWrap(instance._cached, adapter.const.TextureWrap.TEXTURE_WRAP_CLAMP)
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

		instance.Destroying:Connect(function()
			if instance._cached then
				lib.UnloadTexture(instance._cached)
				instance._cached = nil
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
