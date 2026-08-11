-- description: "A 2D GUI object that displays an image."
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Rect = require("@Rect")
local _Enum = require("@EnumMap")
local GuiObject = require("@GuiObject")
local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local util = require("@kineshader")
local lib = adapter.lib
local structs = adapter.structs
local SHADER_FLOAT = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
local SHADER_VEC2 = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
local SHADER_VEC4 = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
local SHADER_INT = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_INT

local imageGuiShader
local imageGuiLocs = {}

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
	ScaleType = _Enum.ScaleType.Stretch,
	SliceCenter = Rect.new(0, 0, 0, 0),
	SliceScale = 1,
	Name = "ImageLabel",
	Visible = true,
	ZIndex = 1,

	_cached = nil,
	_suppressGuiBg = true,
	_suppressGuiStroke = true,
}

propTable.render = function(lib, object, dt, _, renderer)
	if not imageGuiShader then
		imageGuiShader = lib.LoadShader(nil, zembed.AssetPath("kineasset://shaders/image_gui.fs"))
		imageGuiLocs.bgColor = lib.GetShaderLocation(imageGuiShader, "bgColor")
		imageGuiLocs.bgTransparency = lib.GetShaderLocation(imageGuiShader, "bgTransparency")
		imageGuiLocs.strokeColor = lib.GetShaderLocation(imageGuiShader, "strokeColor")
		imageGuiLocs.strokeThickness = lib.GetShaderLocation(imageGuiShader, "strokeThickness")
		imageGuiLocs.cornerRadius = lib.GetShaderLocation(imageGuiShader, "cornerRadius")

		imageGuiLocs.scaleType = lib.GetShaderLocation(imageGuiShader, "scaleType")
		imageGuiLocs.elemSize = lib.GetShaderLocation(imageGuiShader, "elemSize")
		imageGuiLocs.texSize = lib.GetShaderLocation(imageGuiShader, "texSize")
		imageGuiLocs.sliceCenter = lib.GetShaderLocation(imageGuiShader, "sliceCenter")
		imageGuiLocs.sliceScale = lib.GetShaderLocation(imageGuiShader, "sliceScale")
	end
	local framePos, frameSize = GuiObject.render(lib, object, dt, _, renderer)
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
			x = framePos.X + frameSize.X / 2,
			y = framePos.Y + frameSize.Y / 2,
			width = frameSize.X,
			height = frameSize.Y,
		})

		if object.ImageTransparency ~= 1 then
			local imageAlpha = math.clamp(1 - (object.ImageTransparency or 0), 0, 1)
			local rcol = structs.Color:new({
				r = object.ImageColor3.R * 255,
				g = object.ImageColor3.G * 255,
				b = object.ImageColor3.B * 255,
				a = math.floor(imageAlpha * 255),
			})

			local stroke, corner
			for _, child in ipairs(object:GetChildren()) do
				if child.ClassName == "UIStroke" then
					stroke = child
				elseif child.ClassName == "UICorner" then
					corner = child
				end
			end

			local minDim = math.min(frameSize.X, frameSize.Y)

			local cornerRadiusUV = 0.0
			if corner then
				local px = corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset
				cornerRadiusUV = math.clamp(px / math.max(minDim, 1), 0, 0.5)
			end

			local strokeThicknessUV = 0.0
			local strokeR, strokeG, strokeB, strokeA = 0, 0, 0, 0
			if stroke and stroke.Transparency ~= 1 then
				strokeThicknessUV = math.clamp((stroke.Thickness or 1) / math.max(minDim, 1), 0, 0.5)
				strokeR = stroke.Color.R
				strokeG = stroke.Color.G
				strokeB = stroke.Color.B
				strokeA = math.clamp(1 - (stroke.Transparency or 0), 0, 1)
			end

			local bgR = object.BackgroundColor3.R
			local bgG = object.BackgroundColor3.G
			local bgB = object.BackgroundColor3.B
			local bgTransparency = math.clamp(object.BackgroundTransparency or 0, 0, 1)

			local activeShader = (object.Shader and object.Shader._shader) or imageGuiShader
			lib.BeginShaderMode(activeShader)

			if activeShader == imageGuiShader then
				-- vec4: bgColor
				local bgPtr = util.SetShaderValueRaw(imageGuiShader, "bgColor", { bgR, bgG, bgB, 1.0 }, SHADER_VEC4)
				if bgPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.bgColor, bgPtr, SHADER_VEC4)
				end
				-- float: bgTransparency
				local btPtr = util.SetShaderValueRaw(imageGuiShader, "bgTransparency", bgTransparency, SHADER_FLOAT)
				if btPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.bgTransparency, btPtr, SHADER_FLOAT)
				end
				-- vec4: strokeColor
				local scPtr = util.SetShaderValueRaw(
					imageGuiShader,
					"strokeColor",
					{ strokeR, strokeG, strokeB, strokeA },
					SHADER_VEC4
				)
				if scPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.strokeColor, scPtr, SHADER_VEC4)
				end
				-- float: strokeThickness
				local stPtr = util.SetShaderValueRaw(imageGuiShader, "strokeThickness", strokeThicknessUV, SHADER_FLOAT)
				if stPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.strokeThickness, stPtr, SHADER_FLOAT)
				end
				-- float: cornerRadius
				local crPtr = util.SetShaderValueRaw(imageGuiShader, "cornerRadius", cornerRadiusUV, SHADER_FLOAT)
				if crPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.cornerRadius, crPtr, SHADER_FLOAT)
				end

				-- int: scaleType
				local scaleTypeVal = (object.ScaleType == _Enum.ScaleType.Slice) and 1 or 0
				local stPtr = util.SetShaderValueRaw(imageGuiShader, "scaleType", scaleTypeVal, SHADER_INT)
				if stPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.scaleType, stPtr, SHADER_INT)
				end

				-- vec2: elemSize
				local esPtr =
					util.SetShaderValueRaw(imageGuiShader, "elemSize", { frameSize.X, frameSize.Y }, SHADER_VEC2)
				if esPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.elemSize, esPtr, SHADER_VEC2)
				end

				-- vec2: texSize
				local tsPtr = util.SetShaderValueRaw(imageGuiShader, "texSize", { size.x, size.y }, SHADER_VEC2)
				if tsPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.texSize, tsPtr, SHADER_VEC2)
				end

				-- vec4: sliceCenter
				local sc = object.SliceCenter or Rect.new(0, 0, 0, 0)
				local scPtr = util.SetShaderValueRaw(
					imageGuiShader,
					"sliceCenter",
					{ sc.Min.X, sc.Min.Y, sc.Max.X, sc.Max.Y },
					SHADER_VEC4
				)
				if scPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.sliceCenter, scPtr, SHADER_VEC4)
				end

				-- float: sliceScale
				local ssPtr = util.SetShaderValueRaw(imageGuiShader, "sliceScale", object.SliceScale or 1, SHADER_FLOAT)
				if ssPtr then
					lib.SetShaderValue(imageGuiShader, imageGuiLocs.sliceScale, ssPtr, SHADER_FLOAT)
				end
			end

			lib.DrawTexturePro(object._cached, rec, dest, vector.create(frameSize.X / 2, frameSize.Y / 2), object.Rotation or 0, rcol)
			lib.EndShaderMode()
		end
	end

	if didBlend then
		lib.EndBlendMode()
	end

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

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
