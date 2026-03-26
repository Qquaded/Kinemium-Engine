local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local UDim2 = require("@UDim2")
local raylib = require("@raylib")

local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

local propTable = {
	Name = "BillboardGui",
	Enabled = true,
	Camera = nil,
	Size = UDim2.new(0, 200, 0, 100),
	RenderOffset = Vector2.new(0, 0),
	Adornee = nil,
	StudsOffset = Vector3.new(0, 0, 0),
	StudsOffsetWorldSpace = Vector3.new(0, 0, 0),
	PixelsPerStud = 50,
	MaxDistance = 0,
	AlwaysOnTop = true,
	BaseClass = "UIContainer",
}

local function getReferenceSize()
	return Vector2.new(lib.GetRenderWidth(), lib.GetRenderHeight())
end

local function getSizePixels(instance)
	if not instance.Size then
		return Vector2.new(0, 0)
	end
	local reference = getReferenceSize()
	local size = instance.Size:ToPixels(reference)
	return Vector2.new(size.X, size.Y)
end

local function getAdornee(instance)
	if instance.Adornee then
		return instance.Adornee
	end
	return instance.Parent
end

local function getWorldPosition(adornee, offsetLocal, offsetWorld)
	if not adornee then
		return nil
	end

	local basePos = nil
	if adornee.CFrame and adornee.CFrame.Position then
		basePos = adornee.CFrame.Position
	elseif adornee.Position then
		basePos = adornee.Position
	end
	if not basePos then
		return nil
	end

	local pos = basePos
	if offsetLocal and adornee.CFrame and adornee.CFrame.VectorToWorldSpace then
		pos = pos + adornee.CFrame:VectorToWorldSpace(offsetLocal)
	end
	if offsetWorld then
		pos = pos + offsetWorld
	end

	return pos
end

return {
	class = "BillboardGui",

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

		resetRenderTexture(1, 1)

		render2dId = renderer.Pool.new("2d", function()
			if not instance.Enabled then
				return
			end

			local sizePixels = getSizePixels(instance)
			if sizePixels.X <= 0 or sizePixels.Y <= 0 then
				return
			end

			if rtxW ~= math.floor(sizePixels.X) or rtxH ~= math.floor(sizePixels.Y) then
				resetRenderTexture(sizePixels.X, sizePixels.Y)
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

		render3dId = renderer.Pool.new("gizmo", function()
			if not instance.Enabled then
				return
			end
			if not rtx then
				return
			end

			local camera = instance.Camera or (datamodel and datamodel.Workspace and datamodel.Workspace.Camera)
			if not camera or not camera._raylibcam then
				return
			end

			local adornee = getAdornee(instance)
			local pos = getWorldPosition(adornee, instance.StudsOffset, instance.StudsOffsetWorldSpace)
			if not pos then
				return
			end

			local maxDist = instance.MaxDistance or 0
			if maxDist > 0 and camera.Position then
				local dx = pos.X - camera.Position.X
				local dy = pos.Y - camera.Position.Y
				local dz = pos.Z - camera.Position.Z
				if (dx * dx + dy * dy + dz * dz) > (maxDist * maxDist) then
					return
				end
			end

			local tex = zune.mem.slice(rtx, structs.RenderTexture:offset("texture"), structs.Texture:size())
			local texW = buffer.readi32(tex, 4)
			local texH = buffer.readi32(tex, 8)
			if texW <= 0 or texH <= 0 then
				return
			end

			local pixelsPerStud = instance.PixelsPerStud or 50
			if pixelsPerStud <= 0 then
				pixelsPerStud = 50
			end
			local sizeWorld = Vector2.new(texW / pixelsPerStud, texH / pixelsPerStud)

			local source = structs.Rectangle:new({
				x = 0,
				y = 0,
				width = texW,
				height = -texH,
			})
			local origin = vector.create(sizeWorld.X * 0.5, sizeWorld.Y * 0.5, 0)
			local up = vector.create(0, 1, 0)

			if instance.AlwaysOnTop then
				lib.rlDisableDepthTest()
			end

			lib.DrawBillboardPro(
				camera._raylibcam,
				tex,
				source,
				vector.create(pos.X, pos.Y, pos.Z),
				up,
				vector.create(sizeWorld.X, sizeWorld.Y, 0),
				origin,
				0,
				const.WHITE
			)

			if instance.AlwaysOnTop then
				lib.rlEnableDepthTest()
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
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
