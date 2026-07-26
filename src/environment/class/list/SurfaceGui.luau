-- description: "Displays a 2D UI element on a 3D surface."
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local UDim2 = require("@UDim2")
local Enum = require("@EnumMap")
local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local raycast = require("@raycast")

local lib = adapter.lib
local const = adapter.const
local structs = adapter.structs

local propTable = {
	Name = "SurfaceGui",
	Enabled = true,
	Adornee = nil,
	Face = Enum.NormalId.Front,
	CanvasSize = Vector2.new(800, 600),
	PixelsPerStud = 50,
	SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
	AlwaysOnTop = false,
	LightInfluence = 1,
	Brightness = 1,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ZOffset = 0,
	Size = UDim2.new(0, 800, 0, 600),
	RenderOffset = Vector2.new(0, 0),
	Texture = nil,
	BaseClass = "UIContainer",
}

local function getAdornee(instance)
	if instance.Adornee then
		return instance.Adornee
	end
	return instance.Parent
end

local function getFaceSize(size, face)
	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return size.X, size.Y
	elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return size.Z, size.Y
	elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		return size.X, size.Z
	end
	return 1, 1
end

local function getFaceCorners(cf, size, face)
	local hX = size.X * 0.5
	local hY = size.Y * 0.5
	local hZ = size.Z * 0.5
	local pad = 0.005

	if face == Enum.NormalId.Front then
		return cf * Vector3.new(-hX, hY, -hZ - pad),
			cf * Vector3.new(hX, hY, -hZ - pad),
			cf * Vector3.new(hX, -hY, -hZ - pad),
			cf * Vector3.new(-hX, -hY, -hZ - pad)
	elseif face == Enum.NormalId.Back then
		return cf * Vector3.new(hX, hY, hZ + pad),
			cf * Vector3.new(-hX, hY, hZ + pad),
			cf * Vector3.new(-hX, -hY, hZ + pad),
			cf * Vector3.new(hX, -hY, hZ + pad)
	elseif face == Enum.NormalId.Left then
		return cf * Vector3.new(-hX - pad, hY, hZ),
			cf * Vector3.new(-hX - pad, hY, -hZ),
			cf * Vector3.new(-hX - pad, -hY, -hZ),
			cf * Vector3.new(-hX - pad, -hY, hZ)
	elseif face == Enum.NormalId.Right then
		return cf * Vector3.new(hX + pad, hY, -hZ),
			cf * Vector3.new(hX + pad, hY, hZ),
			cf * Vector3.new(hX + pad, -hY, hZ),
			cf * Vector3.new(hX + pad, -hY, -hZ)
	elseif face == Enum.NormalId.Top then
		return cf * Vector3.new(-hX, hY + pad, -hZ),
			cf * Vector3.new(hX, hY + pad, -hZ),
			cf * Vector3.new(hX, hY + pad, hZ),
			cf * Vector3.new(-hX, hY + pad, hZ)
	elseif face == Enum.NormalId.Bottom then
		return cf * Vector3.new(-hX, -hY - pad, hZ),
			cf * Vector3.new(hX, -hY - pad, hZ),
			cf * Vector3.new(hX, -hY - pad, -hZ),
			cf * Vector3.new(-hX, -hY - pad, -hZ)
	end
	return Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
end

local function resolveTextureSource(instance)
	if type(instance.Texture) == "table" and instance.Texture.ClassName == "EditableImage" then
		return instance.Texture
	end
	if type(instance.Texture) == "string" and instance.Texture ~= "" then
		return instance.Texture
	end
	return nil
end

local function loadTextureFromPath(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end
	path = zembed.AssetPath(path)

	local ok, data = pcall(zune.fs.readFileSync, path, true)
	if not ok or not data then
		return nil
	end

	local ext = lib.GetFileExtension(path)
	local okLoad, tex = pcall(lib.LoadTextureFromMemory, ext, data, buffer.len(data))
	if okLoad then
		return tex
	end

	return nil
end

local function loadTextureFromEditable(editableImage)
	if not editableImage or not editableImage._image then
		return nil
	end

	if editableImage._dirty then
		if editableImage._texture then
			lib.UnloadTexture(editableImage._texture)
		end
		editableImage._texture = lib.LoadTextureFromImage(editableImage._image)
		editableImage._dirty = false
	end

	return editableImage._texture
end

return {
	class = "SurfaceGui",

	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		local rtx = nil
		local rtxW = 0
		local rtxH = 0
		local render2dId = nil
		local render3dId = nil
		local staticTexture = nil
		local lastTextureSource = nil

		local function resetRenderTexture(width, height)
			local w = math.max(1, math.floor(width or 1))
			local h = math.max(1, math.floor(height or 1))
			if rtx then
				lib.UnloadRenderTexture(rtx)
			end
			rtx = lib.LoadRenderTexture(w, h)
			rtxW = w
			rtxH = h
			local tex = zune.mem.slice(rtx, structs.RenderTexture:offset("texture"), structs.Texture:size())
			lib.SetTextureFilter(tex, const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			lib.SetTextureWrap(tex, const.TextureWrap.TEXTURE_WRAP_CLAMP)
		end

		local function getCanvasSize()
			local w, h = 800, 600
			if instance.SizingMode == Enum.SurfaceGuiSizingMode.FixedSize then
				w = math.max(1, math.floor(instance.CanvasSize.X or 800))
				h = math.max(1, math.floor(instance.CanvasSize.Y or 600))
			elseif instance.SizingMode == Enum.SurfaceGuiSizingMode.PixelsPerStud then
				local adornee = getAdornee(instance)
				if adornee and adornee.Size then
					local fw, fh = getFaceSize(adornee.Size, instance.Face)
					w = math.max(1, math.floor(fw * (instance.PixelsPerStud or 50)))
					h = math.max(1, math.floor(fh * (instance.PixelsPerStud or 50)))
				end
			end
			return w, h
		end

		local function syncTexture(force)
			if _G.IsHeadless then
				return
			end

			local source = resolveTextureSource(instance)
			local hasChildren = false
			for _, child in pairs(instance:GetChildren()) do
				if child.render then
					hasChildren = true
					break
				end
			end

			if not force and source == lastTextureSource and not hasChildren then
				if type(source) == "table" and source.ClassName == "EditableImage" then
					if source._dirty or source._texture ~= lastTextureSource then
						-- continue to rebuild
					else
						return
					end
				else
					return
				end
			end

			lastTextureSource = source

			if hasChildren then
				if staticTexture then
					lib.UnloadTexture(staticTexture)
					staticTexture = nil
				end
				local w, h = getCanvasSize()
				if rtxW ~= w or rtxH ~= h then
					resetRenderTexture(w, h)
				end
			elseif source then
				if staticTexture then
					lib.UnloadTexture(staticTexture)
					staticTexture = nil
				end
				if type(source) == "table" and source.ClassName == "EditableImage" then
					staticTexture = loadTextureFromEditable(source)
				elseif type(source) == "string" then
					staticTexture = loadTextureFromPath(source)
				end
			else
				if staticTexture then
					lib.UnloadTexture(staticTexture)
					staticTexture = nil
				end
				local w, h = getCanvasSize()
				if rtxW ~= w or rtxH ~= h then
					resetRenderTexture(w, h)
				end
			end
		end

		resetRenderTexture(getCanvasSize())

		render2dId = renderer.Pool.new("2d", function()
			if not instance.Enabled then
				return
			end

			local w, h = getCanvasSize()
			if w <= 0 or h <= 0 then
				return
			end

			if rtxW ~= w or rtxH ~= h then
				resetRenderTexture(w, h)
			end

			lib.BeginTextureMode(rtx)
			lib.ClearBackground(const.BLANK)

			for _, child in pairs(instance:GetChildren()) do
				if child.render then
					child.render(lib, child, lib.GetFrameTime(), structs, renderer, datamodel)
				end
			end

			lib.EndTextureMode()
		end)

		render3dId = renderer.Pool.new("3d", function()
			syncTexture(false)

			if not instance.Enabled then
				return
			end

			local adornee = getAdornee(instance)
			if not adornee or not adornee.CFrame or not adornee.Size then
				return
			end

			local texId = nil
			if staticTexture then
				texId = staticTexture.id
			elseif rtx then
				local tex = zune.mem.slice(rtx, structs.RenderTexture:offset("texture"), structs.Texture:size())
				local texW = buffer.readi32(tex, 4)
				local texH = buffer.readi32(tex, 8)
				if texW <= 0 or texH <= 0 then
					return
				end
				texId = buffer.readu32(tex, 0)
			else
				return
			end

			if not texId then
				return
			end

			local tl, tr, br, bl = getFaceCorners(adornee.CFrame, adornee.Size, instance.Face)

			if instance.AlwaysOnTop then
				lib.rlDisableDepthTest()
			end

			lib.rlSetTexture(texId)
			lib.rlBegin(7) -- GL_QUADS
			lib.rlColor4ub(255, 255, 255, 255)

			lib.rlTexCoord2f(0, 1)
			lib.rlVertex3f(tl.X, tl.Y, tl.Z)
			lib.rlTexCoord2f(1, 1)
			lib.rlVertex3f(tr.X, tr.Y, tr.Z)
			lib.rlTexCoord2f(1, 0)
			lib.rlVertex3f(br.X, br.Y, br.Z)
			lib.rlTexCoord2f(0, 0)
			lib.rlVertex3f(bl.X, bl.Y, bl.Z)

			lib.rlEnd()
			lib.rlSetTexture(0)

			if instance.AlwaysOnTop then
				lib.rlEnableDepthTest()
			end
		end)

		instance.Changed:Connect(function(prop)
			if prop == "Texture" then
				syncTexture(true)
			elseif
				prop == "Adornee"
				or prop == "Face"
				or prop == "CanvasSize"
				or prop == "PixelsPerStud"
				or prop == "SizingMode"
			then
				local w, h = getCanvasSize()
				if rtxW ~= w or rtxH ~= h then
					resetRenderTexture(w, h)
				end
				instance.Size = UDim2.new(0, w, 0, h)
			end
		end)

		instance.Destroying:Connect(function()
			if render2dId then
				renderer.Pool.Destroy(render2dId)
			end
			if render3dId then
				renderer.Pool.Destroy(render3dId)
			end
			if rtx then
				lib.UnloadRenderTexture(rtx)
				rtx = nil
			end
			if staticTexture then
				lib.UnloadTexture(staticTexture)
				staticTexture = nil
			end
		end)

		-- description: "Gets the relative mouse position in the SurfaceGui."
		instance.GetRelativeMousePosition = function()
			local adornee = getAdornee(instance)
			if not adornee or not adornee.CFrame or not adornee.Size then
				return nil
			end

			local camera = datamodel and datamodel.Workspace and datamodel.Workspace.Camera
			if not camera or not camera._raylibcam then
				return nil
			end

			local rayInfo = raycast:GetMouseRay(camera._raylibcam)
			local ray = rayInfo.ray

			local tl, tr, _, bl = getFaceCorners(adornee.CFrame, adornee.Size, instance.Face)

			local normal = (tr - tl):Cross(bl - tl):Unit()
			local collision = lib.GetRayCollisionPlane(ray, tl, normal)

			if collision.hit == 1 then
				local p = Vector3.new(collision.point.x, collision.point.y, collision.point.z)
				local v = p - tl
				local xDir = (tr - tl)
				local yDir = (bl - tl)
				local xSize = xDir:Magnitude()
				local ySize = yDir:Magnitude()

				if xSize > 0 and ySize > 0 then
					local x = v:Dot(xDir:Unit()) / xSize
					local y = v:Dot(yDir:Unit()) / ySize

					if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
						return Vector2.new(x * instance.CanvasSize.X, y * instance.CanvasSize.Y)
					end
				end
			end
			return nil
		end

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
