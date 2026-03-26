local logic = require("@Kinemium.2dbutton")

local Frame = require("@Frame")
local GuiObject = require("@GuiObject")
local raylib = require("@raylib")
local utils = require("@bufferutils")
local r3d = require("@r3d")

local rlib = r3d.lib
local r3dstructs = r3d.structs

local sharedMeshlib = nil
local sharedPreloadedMeshes = nil
local sharedWorkspace = nil

local function ensurePreloaded()
	if sharedPreloadedMeshes or not sharedMeshlib then
		return
	end
	sharedPreloadedMeshes = sharedMeshlib.PreloadStandardMeshes()
end

local function resetRenderTexture(object, width, height)
	local w = math.max(1, math.floor(width or 1))
	local h = math.max(1, math.floor(height or 1))
	if object._rendertexture then
		raylib.lib.UnloadRenderTexture(object._rendertexture)
	end
	local rtx = raylib.lib.LoadRenderTexture(w, h)
	object._rendertexture = rtx
	object._rtWidth = w
	object._rtHeight = h
	local tex = utils.extract.texture(rtx)
	raylib.lib.SetTextureFilter(tex, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
	raylib.lib.SetTextureWrap(tex, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
end

local function getRenderableMesh(part)
	if part:IsA("MeshPart") then
		if part.MeshObject and part.MeshObject._meshgenHandle then
			return part.MeshObject._meshgenHandle
		end
		return nil
	end
	if not sharedPreloadedMeshes or not part.Shape or not part.Shape.Value then
		return nil
	end
	local meshData = sharedPreloadedMeshes[part.Shape.Value]
	return meshData and meshData[2] or nil
end

local function buildMaterial(part)
	local materialName = part.Material and part.Material.Value
	local matData = nil
	if sharedWorkspace and sharedWorkspace.loadMaterial and materialName then
		matData = sharedWorkspace.loadMaterial(materialName)
	end
	if not matData or not matData.material then
		matData = { material = rlib.R3D_GetDefaultMaterial() }
	end

	local tmpAlbedo = buffer.create(r3dstructs.R3D_AlbedoMap:size())
	buffer.copy(
		tmpAlbedo,
		0,
		matData.material,
		r3dstructs.R3D_Material:offset("albedo"),
		r3dstructs.R3D_AlbedoMap:size()
	)
	buffer.copy(tmpAlbedo, r3dstructs.R3D_AlbedoMap:offset("color"), part.Color:ToRaylib(part.Transparency or 0))

	local tmpMaterial = buffer.create(r3dstructs.R3D_Material:size())
	buffer.copy(tmpMaterial, 0, matData.material, 0, r3dstructs.R3D_Material:size())
	buffer.copy(tmpMaterial, r3dstructs.R3D_Material:offset("albedo"), tmpAlbedo)
	buffer.writei32(tmpMaterial, r3dstructs.R3D_Material:offset("transparencyMode"), 1)
	buffer.writei32(tmpMaterial, r3dstructs.R3D_Material:offset("cullMode"), 1)

	local size = part.Size
	if size then
		buffer.writef32(tmpMaterial, r3dstructs.R3D_Material:offset("uvScale"), size.X)
		buffer.writef32(tmpMaterial, r3dstructs.R3D_Material:offset("uvScale") + 4, size.Z)
	end

	return tmpMaterial
end

local propTable = {
	Camera = nil,
	Name = "ViewportFrame",
}
Frame.inherit(propTable)

return {
	class = "ViewportFrame",
	callback = function(instance, renderer, datamodel)
		sharedMeshlib = sharedMeshlib or (renderer and renderer.Mesh or nil)
		sharedWorkspace = sharedWorkspace or (datamodel and datamodel.Workspace or nil)

		propTable.render = function(lib, object, dt, structs, renderer)
			if not object.Visible then
				return
			end

			ensurePreloaded()

			local framePos, frameSize = GuiObject.render(lib, object, dt, structs, renderer)
			if not framePos or not frameSize then
				return
			end

			local width = math.max(1, math.floor(frameSize.X or 1))
			local height = math.max(1, math.floor(frameSize.Y or 1))

			local rtx = object._rendertexture
			if not rtx or object._rtWidth ~= width or object._rtHeight ~= height then
				resetRenderTexture(object, width, height)
				rtx = object._rendertexture
			end

			local camera = object.Camera
			if rtx and camera and camera._raylibcam then
				lib.BeginTextureMode(rtx)
				lib.ClearBackground(raylib.const.BLANK)
				lib.EndTextureMode()

				rlib.R3D_BeginEx(rtx, camera._raylibcam)
				for _, child in pairs(object:GetDescendants()) do
					if child:IsA("Part") or child:IsA("MeshPart") then
						if not child.CFrame or not child.Size then
							continue
						end
						local mesh = getRenderableMesh(child)
						if mesh then
							local material = buildMaterial(child)
							local matrix = child.CFrame:ToRaylibMatrixScale(child.Size, raylib.structs)
							rlib.R3D_DrawMeshPro(mesh, material, matrix)
						end
					end
				end
				rlib.R3D_End()

				local tex = utils.extract.texture(rtx)
				local source = structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height })
				local dest = structs.Rectangle:new({
					x = framePos.X,
					y = framePos.Y,
					width = frameSize.X,
					height = frameSize.Y,
				})

				lib.DrawTexturePro(tex, source, dest, vector.create(0, 0), 0, raylib.const.WHITE)
			end

			GuiObject.renderChildren(lib, object, dt, structs, renderer)
			return framePos, frameSize
		end

		instance:SetProperties(propTable)

		resetRenderTexture(instance, 1, 1)

		instance.Changed:Connect(function(prop)
			if prop == "Size" then
				local AbsoluteSize = instance.AbsoluteSize
				if AbsoluteSize then
					resetRenderTexture(instance, AbsoluteSize.X or 1, AbsoluteSize.Y or 1)
				end
			end
		end)

		instance.Destroying:Connect(function()
			if instance._rendertexture then
				raylib.lib.UnloadRenderTexture(instance._rendertexture)
				instance._rendertexture = nil
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
