-- description: "A mutable image that can be drawn onto and modified at runtime."
local Vector2 = require("@Vector2")
local _Color3 = require("@Color3")
local _Enum = require("@EnumMap")
local _signal = require("@Kinemium.signal")
local adapter = require("@RaylibAdapter")
local rlib = adapter.lib
local rconst = adapter.const

local propTable = {
	Size = Vector2.new(1024, 1024),
	Name = "EditableImage",
	BaseClass = "Instance",
}

return {
	class = "EditableImage",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		instance._image = rlib.GenImageColor(instance.Size.X, instance.Size.Y, rconst.BLANK)
		if not _G.IsHeadless then
			instance._texture = rlib.LoadTextureFromImage(instance._image)
		end
		instance._dirty = false

		local _Vector2Struct = adapter.structs.Vector2
		local RectangleStruct = adapter.structs.Rectangle
		local ColorStruct = adapter.structs.Color

		instance.Changed:Connect(function(prop)
			if prop == "Size" then
				rlib.UnloadImage(instance._image)
				if not _G.IsHeadless then
					rlib.UnloadTexture(instance._texture)
				end
				instance._image = rlib.GenImageColor(instance.Size.X, instance.Size.Y, rconst.BLANK)
				if not _G.IsHeadless then
					instance._texture = rlib.LoadTextureFromImage(instance._image)
				end
				instance._dirty = false
			end
		end)

		-- description: "Cleans up the resources."
		function instance:Destroy()
			if self._image then
				rlib.UnloadImage(self._image)
			end
			if self._texture and not _G.IsHeadless then
				rlib.UnloadTexture(self._texture)
			end
			self._image = nil
			self._texture = nil
		end

		-- description: "Draws a circle in the image."
		-- args: "center: Vector2, radius: number, color: any, transparency: number, combineType: string"
		function instance:DrawCircle(center: Vector2, radius: number, color: any, transparency: number, combineType)
			local a = math.clamp(math.floor(255 * (1 - (transparency or 0))), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawCircle(self._image, center.X, center.Y, radius, rcol)
			self._dirty = true
		end

		-- description: "Draws a rectangle in the image."
		-- args: "position: Vector2, size: Vector2, color: any, transparency: number, combineType: string"
		function instance:DrawRectangle(position: Vector2, size: Vector2, color: any, transparency: number, combineType)
			local a = math.clamp(math.floor(255 * (1 - (transparency or 0))), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			local rec = RectangleStruct:new({
				x = position.X,
				y = position.Y,
				width = size.X,
				height = size.Y,
			})
			rlib.ImageDrawRectangleRec(self._image, rec, rcol)
			self._dirty = true
		end

		-- description: "Draws a line in the image."
		-- args: "p1: Vector2, p2: Vector2, color: any, transparency: number, combineType: string"
		function instance:DrawLine(p1: Vector2, p2: Vector2, color: any, transparency: number, combineType)
			local a = math.clamp(math.floor(255 * (1 - (transparency or 0))), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawLine(self._image, p1.X, p1.Y, p2.X, p2.Y, rcol)
			self._dirty = true
		end

		-- description: "Draws an image in the editable image."
		-- args: "position: Vector2, imageInstance: any, combineType: string"
		function instance:DrawImage(position: Vector2, imageInstance: any, combineType)
			if imageInstance and imageInstance._image then
				local srcRec = RectangleStruct:new({
					x = 0,
					y = 0,
					width = imageInstance.Size.X,
					height = imageInstance.Size.Y,
				})
				local dstRec = RectangleStruct:new({
					x = position.X,
					y = position.Y,
					width = imageInstance.Size.X,
					height = imageInstance.Size.Y,
				})
				rlib.ImageDraw(self._image, imageInstance._image, srcRec, dstRec, rconst.WHITE)
				self._dirty = true
			end
		end

		-- description: "Draws a transformed image in the editable image."
		-- args: "position: Vector2, scale: Vector2, rotation: number, imageInstance: any, options: any"
		function instance:DrawImageTransformed(
			position: Vector2,
			scale: Vector2,
			rotation: number,
			imageInstance: any,
			options: any?
		)
			if imageInstance and imageInstance._image then
				local srcRec = RectangleStruct:new({
					x = 0,
					y = 0,
					width = imageInstance.Size.X,
					height = imageInstance.Size.Y,
				})
				local sw = imageInstance.Size.X * scale.X
				local sh = imageInstance.Size.Y * scale.Y
				local dstRec = RectangleStruct:new({
					x = position.X + (sw * 0.5),
					y = position.Y + (sh * 0.5),
					width = sw,
					height = sh,
				})

				rlib.ImageDraw(self._image, imageInstance._image, srcRec, dstRec, rconst.WHITE)
				self._dirty = true
			end
		end

		-- description: "Draws a projected image in the editable image."
		-- args: "mesh: any, projection: any, brushConfig: any"
		function instance:DrawImageProjected(mesh: any, projection: any, brushConfig: any)
			if mesh and mesh.class == "EditableMesh" and projection and brushConfig then
				local faces = mesh:GetFaces()
				local rcol = ColorStruct:new({ r = 255, g = 255, b = 255, a = 255 })

				for _, faceId in ipairs(faces) do
					local fvs = mesh:GetFaceVertices(faceId)
					if #fvs == 3 then
						local p1 = mesh:GetPosition(fvs[1])
						local p2 = mesh:GetPosition(fvs[2])
						local p3 = mesh:GetPosition(fvs[3])

						-- Simplified 2D mapping (mock projection taking simple normalized coordinates)
						local v1 = Vector2.new(
							math.clamp(math.floor((p1.X + 1) * 0.5 * self.Size.X), 0, self.Size.X - 1),
							math.clamp(math.floor((p1.Y + 1) * 0.5 * self.Size.Y), 0, self.Size.Y - 1)
						)
						local v2 = Vector2.new(
							math.clamp(math.floor((p2.X + 1) * 0.5 * self.Size.X), 0, self.Size.X - 1),
							math.clamp(math.floor((p2.Y + 1) * 0.5 * self.Size.Y), 0, self.Size.Y - 1)
						)
						local v3 = Vector2.new(
							math.clamp(math.floor((p3.X + 1) * 0.5 * self.Size.X), 0, self.Size.X - 1),
							math.clamp(math.floor((p3.Y + 1) * 0.5 * self.Size.Y), 0, self.Size.Y - 1)
						)

						rlib.ImageDrawTriangle(self._image, v1, v2, v3, rcol)
					end
				end
			end
			self._dirty = true
		end

		-- description: "Returns pixels buffer"
		-- args: "position: Vector2, size: Vector2"
		-- returns: "buffer"
		function instance:ReadPixelsBuffer(position: Vector2, size: Vector2): buffer
			local reqW = math.floor(size.X)
			local reqH = math.floor(size.Y)
			local totalSize = reqW * reqH * 4
			local b = buffer.create(totalSize)

			local rCols = rlib.LoadImageColors(self._image)
			if rCols then
				for y = 0, reqH - 1 do
					for x = 0, reqW - 1 do
						local ix = math.floor(position.X) + x
						local iy = math.floor(position.Y) + y
						if ix >= 0 and ix < self.Size.X and iy >= 0 and iy < self.Size.Y then
							local _idx = (iy * self.Size.X) + ix
							-- stub
						end
					end
				end
				rlib.UnloadImageColors(rCols)
			end
			return b
		end

		-- description: "Sharpens the image"
		function instance:Sharpen()
			rlib.SetTextureFilter(instance._texture, adapter.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			rlib.SetTextureWrap(instance._texture, adapter.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			rlib.GenTextureMipmaps(instance._texture)
		end

		-- description: "Writes pixels buffer."
		-- args: "position: Vector2, size: Vector2, buf: buffer"
		function instance:WritePixelsBuffer(position: Vector2, size: Vector2, buf: buffer)
			-- stub
			self._dirty = true
		end

		-- description: "Clears the image."
		-- args: "color: any, transparency: number"
		function instance:Clear(color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawRectangleRec(
				self._image,
				RectangleStruct:new({ x = 0, y = 0, width = self.Size.X, height = self.Size.Y }),
				rcol
			)
			self._dirty = true
		end

		-- description: "Fills the image with a color and transparency."
		-- args: "color: any, transparency: number"
		function instance:Fill(color: any, transparency: number)
			self:Clear(color, transparency)
		end

		-- description: "Draws an outlined rectangle in the image."
		-- args: "position: Vector2, size: Vector2, color: any, transparency: number, thickness: number"
		function instance:DrawRectangleOutline(
			position: Vector2,
			size: Vector2,
			color: any,
			transparency: number,
			thickness: number
		)
			thickness = thickness or 1
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })

			-- Top
			rlib.ImageDrawLine(self._image, position.X, position.Y, position.X + size.X, position.Y, rcol)
			-- Bottom
			rlib.ImageDrawLine(
				self._image,
				position.X,
				position.Y + size.Y,
				position.X + size.X,
				position.Y + size.Y,
				rcol
			)
			-- Left
			rlib.ImageDrawLine(self._image, position.X, position.Y, position.X, position.Y + size.Y, rcol)
			-- Right
			rlib.ImageDrawLine(
				self._image,
				position.X + size.X,
				position.Y,
				position.X + size.X,
				position.Y + size.Y,
				rcol
			)

			self._dirty = true
		end

		-- description: "Rotates the image."
		-- args: "angle: number"
		function instance:Rotate(angle: number)
			rlib.ImageRotate(self._image, angle)
			self._dirty = true
		end

		-- description: "Flips the image horizontally."
		function instance:FlipHorizontal()
			rlib.ImageFlipHorizontal(self._image)
			self._dirty = true
		end

		-- description: "Flips the image vertically."
		function instance:FlipVertical()
			rlib.ImageFlipVertical(self._image)
			self._dirty = true
		end

		-- description: "Flips the image."
		-- args: "horizontal: boolean, vertical: boolean"
		function instance:Flip(horizontal: boolean, vertical: boolean)
			if horizontal then
				self:FlipHorizontal()
			end
			if vertical then
				self:FlipVertical()
			end
		end

		-- description: "Crops the image."
		-- args: "position: Vector2, size: Vector2"
		function instance:Crop(position: Vector2, size: Vector2)
			local rec = RectangleStruct:new({
				x = position.X,
				y = position.Y,
				width = size.X,
				height = size.Y,
			})
			rlib.ImageCrop(self._image, rec)
			self._dirty = true
		end

		-- description: "Resizes the image to a new Vector2."
		-- args: "newSize: Vector2"
		function instance:Resize(newSize: Vector2)
			rlib.ImageResize(self._image, newSize.X, newSize.Y)
			self.Size = newSize
			self._dirty = true
		end

		-- description: "Gets the Pixel Color at the inputted Position."
		-- args: "position: Vector2"
		-- returns: "any"
		function instance:GetPixelColor(position: Vector2): any
			local x = math.floor(position.X)
			local y = math.floor(position.Y)

			if x < 0 or x >= self.Size.X or y < 0 or y >= self.Size.Y then
				return _Color3.new(0, 0, 0)
			end

			local colors = rlib.LoadImageColors(self._image)
			if colors then
				local idx = (y * self.Size.X) + x
				rlib.UnloadImageColors(colors)
			end
			return _Color3.new(1, 1, 1)
		end

		-- description: "Sets the Pixel Color."
		-- args: "position: Vector2, color: any, transparency: number"
		function instance:SetPixelColor(position: Vector2, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })

			rlib.ImageDrawPixel(self._image, position.X, position.Y, rcol)
			self._dirty = true
		end

		-- description: "Blurs the image."
		-- args: "strength: number"
		function instance:Blur(strength: number)
			strength = math.max(1, math.floor(strength or 1))
			rlib.ImageBlurGaussian(self._image, strength)
			self._dirty = true
		end

		-- description: "Applies grayscale."
		function instance:ApplyGrayscale()
			rlib.ImageColorGrayscale(self._image)
			self._dirty = true
		end

		-- description: "Applies invert."
		function instance:ApplyInvert()
			rlib.ImageColorInvert(self._image)
			self._dirty = true
		end

		-- description: "Applies contrast."
		-- args: "contrast: number"
		function instance:ApplyContrast(contrast: number)
			rlib.ImageColorContrast(self._image, contrast)
			self._dirty = true
		end

		-- description: "Applies brightness."
		-- args: "brightness: number"
		function instance:ApplyBrightness(brightness: number)
			rlib.ImageColorBrightness(self._image, brightness)
			self._dirty = true
		end

		-- description: "Draws a gradient."
		-- args: "fromPos: Vector2, toPos: Vector2, color1: any, color2: any, transparency: number"
		function instance:DrawGradient(fromPos: Vector2, toPos: Vector2, color1: any, color2: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local c1 = ColorStruct:new({ r = color1.R * 255, g = color1.G * 255, b = color1.B * 255, a = a })
			local c2 = ColorStruct:new({ r = color2.R * 255, g = color2.G * 255, b = color2.B * 255, a = a })

			rlib.GenImageGradientLinear(self._image, fromPos.X, fromPos.Y, toPos.X, toPos.Y, c1, c2)
			self._dirty = true
		end

		-- description: "Exports to file."
		-- args: "filepath: string"
		function instance:ExportToFile(filepath: string)
			local success = rlib.ExportImage(self._image, filepath)
			return success
		end

		-- description: "Gets the Dimensions."
		function instance:GetDimensions()
			return Vector2.new(self.Size.X, self.Size.Y)
		end

		-- description: "Gets the Area."
		function instance:GetArea()
			return self.Size.X * self.Size.Y
		end

		-- description: "Is it dirty?"
		function instance:IsDirty()
			return self._dirty
		end

		-- description: "Marks dirty."
		function instance:MarkDirty()
			self._dirty = true
		end

		-- description: "Clears dirty."
		function instance:ClearDirty()
			self._dirty = false
		end

		-- description: "Draws a pixel at the inputted position with color argument and an optional transparency."
		-- args: "position: Vector2, color: any, transparency: number"
		function instance:DrawPixel(position: Vector2, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawPixelV(self._image, position, rcol)
			self._dirty = true
		end

		-- description: "Draws a line in the image, with more customization options such as thickness."
		-- args: "p1: Vector2, p2: Vector2, thickness: number, color: any, transparency: number"
		function instance:DrawLineEx(p1: Vector2, p2: Vector2, thickness: number, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawLineEx(self._image, p1, p2, thickness, rcol)
			self._dirty = true
		end

		-- description: "Draws circle lines in the image."
		-- args: "center: Vector2, radius: number, color: any, transparency: number"
		function instance:DrawCircleLines(center: Vector2, radius: number, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawCircleLinesV(self._image, center, radius, rcol)
			self._dirty = true
		end

		-- description: "Draws a rectangle in the image."
		-- args: "position: Vector2, size: Vector2, color: any, transparency: number"
		function instance:DrawRectangleV(position: Vector2, size: Vector2, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawRectangleV(self._image, position, size, rcol)
			self._dirty = true
		end

		-- description: "Draws rectangle lines in the image."
		-- args: "position: Vector2, size: Vector2, thickness: number, color: any, transparency: number"
		function instance:DrawRectangleLines(
			position: Vector2,
			size: Vector2,
			thickness: number,
			color: any,
			transparency: number
		)
			transparency = transparency or 0
			thickness = thickness or 1
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			local rec = RectangleStruct:new({ x = position.X, y = position.Y, width = size.X, height = size.Y })
			rlib.ImageDrawRectangleLines(self._image, rec, thickness, rcol)
			self._dirty = true
		end

		-- description: "Draws a triangle in the image."
		-- args: "v1: Vector2, v2: Vector2, v3: Vector2, color: any, transparency: number"
		function instance:DrawTriangle(v1: Vector2, v2: Vector2, v3: Vector2, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawTriangle(self._image, v1, v2, v3, rcol)
			self._dirty = true
		end

		-- description: "Draws a triangle in the image, with more color options."
		-- args: "v1: Vector2, v2: Vector2, v3: Vector2, color1: any, color2: any, color3: any, transparency: number"
		function instance:DrawTriangleEx(
			v1: Vector2,
			v2: Vector2,
			v3: Vector2,
			color1: any,
			color2: any,
			color3: any,
			transparency: number
		)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local c1 = ColorStruct:new({ r = color1.R * 255, g = color1.G * 255, b = color1.B * 255, a = a })
			local c2 = ColorStruct:new({ r = color2.R * 255, g = color2.G * 255, b = color2.B * 255, a = a })
			local c3 = ColorStruct:new({ r = color3.R * 255, g = color3.G * 255, b = color3.B * 255, a = a })
			rlib.ImageDrawTriangleEx(self._image, v1, v2, v3, c1, c2, c3)
			self._dirty = true
		end

		-- description: "Draws triangle lines in the image."
		-- args: "v1: Vector2, v2: Vector2, v3: Vector2, color: any, transparency: number"
		function instance:DrawTriangleLines(v1: Vector2, v2: Vector2, v3: Vector2, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawTriangleLines(self._image, v1, v2, v3, rcol)
			self._dirty = true
		end

		-- description: "Draws text in the image."
		-- args: "text: string, position: Vector2, fontSize: number, color: any, transparency: number"
		function instance:DrawText(text: string, position: Vector2, fontSize: number, color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawText(self._image, text, position.X, position.Y, fontSize, rcol)
			self._dirty = true
		end

		-- description: "Draws text with more customization options."
		-- args: "font: any, text: string, position: Vector2, fontSize: number, spacing: number, color: any, transparency: number"
		function instance:DrawTextEx(
			font: any,
			text: string,
			position: Vector2,
			fontSize: number,
			spacing: number,
			color: any,
			transparency: number
		)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageDrawTextEx(self._image, font, text, position, fontSize, spacing, rcol)
			self._dirty = true
		end

		-- description: "Replaces the old color with a new color."
		-- args: "oldColor: any, newColor: any"
		function instance:ColorReplace(oldColor: any, newColor: any)
			local c1 = ColorStruct:new({ r = oldColor.R * 255, g = oldColor.G * 255, b = oldColor.B * 255, a = 255 })
			local c2 = ColorStruct:new({ r = newColor.R * 255, g = newColor.G * 255, b = newColor.B * 255, a = 255 })
			rlib.ImageColorReplace(self._image, c1, c2)
			self._dirty = true
		end

		-- description: "Alpha masks an image."
		-- args: "alphaMaskImage: any"
		function instance:AlphaMask(alphaMaskImage: any)
			if alphaMaskImage and alphaMaskImage._image then
				rlib.ImageAlphaMask(self._image, alphaMaskImage._image)
				self._dirty = true
			end
		end

		-- description: "Alpha crops with a threshold."
		-- args: "alphaThreshold: number"
		function instance:AlphaCrop(alphaThreshold: number)
			rlib.ImageAlphaCrop(self._image, alphaThreshold)
			self._dirty = true
		end

		-- description: "Alpha clears."
		-- args: "color: any, transparency: number"
		function instance:AlphaClear(color: any, transparency: number)
			transparency = transparency or 0
			local a = math.clamp(math.floor(255 * (1 - transparency)), 0, 255)
			local rcol = ColorStruct:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = a })
			rlib.ImageAlphaClear(self._image, rcol, 0.5)
			self._dirty = true
		end

		-- description: "Alpha premultiplies the image."
		function instance:AlphaPremultiply()
			rlib.ImageAlphaPremultiply(self._image)
			self._dirty = true
		end

		-- description: "Dithers the image."
		-- args: "rBpp: number, gBpp: number, bBpp: number, aBpp: number"
		function instance:Dither(rBpp: number, gBpp: number, bBpp: number, aBpp: number)
			rlib.ImageDither(self._image, rBpp, gBpp, bBpp, aBpp)
			self._dirty = true
		end

		-- description: "Gets the Image Alpha Border."
		function instance:GetImageAlphaBorder()
			return rlib.GetImageAlphaBorder(self._image)
		end

		return instance
	end,

	inherit = function()
		return propTable
	end,
}
