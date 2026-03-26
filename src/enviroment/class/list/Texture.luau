local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local r3d = require("@r3d")
local raylib = require("@raylib")

local rlib = r3d.lib
local r3dstructs = r3d.structs
local ffi = zune.ffi
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

local propTable = {
	Transparency = 0,
	Color3 = Color3.new(1, 1, 1),
	Texture = "./src/assets/images/placeholder.png",
	Face = Enum.NormalId.Top,
	StudsPerTileU = 1,
	StudsPerTileV = 1,
	OffsetStudsU = 0,
	OffsetStudsV = 0,
	Adornee = nil,
	Position = Vector3.new(0, 0, 0),
	Wrap = false,
	Depth = 0.1,
	NormalThreshold = 0,
	FadeWidth = 0,
}

local function getFaceSize(size, face)
	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return size.X, size.Y
	elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return size.Z, size.Y
	elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		return size.X, size.Z
	end
end

local function getFaceCFrame(cf, size, face)
	local half = size * 0.5
	local padding = 0.005 -- offset to prevent Z-fighting

	if face == Enum.NormalId.Front then
		return cf * CFrame.new(0, 0, -half.Z - padding) * CFrame.Angles(math.rad(90), math.rad(180), 0)
	elseif face == Enum.NormalId.Back then
		return cf * CFrame.new(0, 0, half.Z + padding) * CFrame.Angles(math.rad(90), math.rad(180), 0)
	elseif face == Enum.NormalId.Left then
		return cf * CFrame.new(-half.X - padding, 0, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90))
	elseif face == Enum.NormalId.Right then
		return cf * CFrame.new(half.X + padding, 0, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90))
	elseif face == Enum.NormalId.Top then
		return cf * CFrame.new(0, half.Y + padding, 0) * CFrame.Angles(math.rad(180), 0, 0)
	elseif face == Enum.NormalId.Bottom then
		return cf * CFrame.new(0, -half.Y - padding, 0) * CFrame.Angles(math.rad(-180), 0, 0)
	end
end

local function buildBaseDecal()
	local decal = r3dstructs.R3D_Decal:new({})

	local albedo = r3dstructs.R3D_AlbedoMap:new({
		color = const.WHITE,
	})
	buffer.copy(decal, r3dstructs.R3D_Decal:offset("albedo"), albedo, 0, r3dstructs.R3D_AlbedoMap:size())

	local emission = r3dstructs.R3D_EmissionMap:new({
		color = const.WHITE,
		energy = 0.0,
	})
	buffer.copy(decal, r3dstructs.R3D_Decal:offset("emission"), emission, 0, r3dstructs.R3D_EmissionMap:size())

	local normal = r3dstructs.R3D_NormalMap:new({
		scale = 1.0,
	})
	buffer.copy(decal, r3dstructs.R3D_Decal:offset("normal"), normal, 0, r3dstructs.R3D_NormalMap:size())

	local orm = r3dstructs.R3D_OrmMap:new({
		occlusion = 1.0,
		roughness = 1.0,
		metalness = 0.0,
	})
	buffer.copy(decal, r3dstructs.R3D_Decal:offset("orm"), orm, 0, r3dstructs.R3D_OrmMap:size())

	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvScale"), 1.0)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvScale") + 4, 1.0)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("alphaCutoff"), 0.01)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("normalThreshold"), 0.0)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("fadeWidth"), 0.0)
	buffer.writeu8(decal, r3dstructs.R3D_Decal:offset("applyColor"), 1)

	return decal
end

local function loadAlbedoMap(path, color)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	local ok, data = pcall(zune.fs.readFileSync, path, true)
	if not ok or not data then
		return nil
	end

	local ext = lib.GetFileExtension(path)
	local okLoad, map = pcall(rlib.R3D_LoadAlbedoMapFromMemory, ext, data, buffer.len(data), color)
	if okLoad then
		return map
	end

	return nil
end

local function loadAlbedoMapFromEditable(editableImage, color)
	if not editableImage or not editableImage._image then
		return nil
	end

	local sizePtr = ffi.create(ffi.types.i32)
	local memPtr = lib.ExportImageToMemory(editableImage._image, ".png", sizePtr)
	if memPtr == ffi.null then
		return nil
	end

	local size = sizePtr:readi32(0)
	if not size or size <= 0 then
		lib.MemFree(memPtr)
		return nil
	end

	local data = buffer.create(size)
	for i = 0, size - 1 do
		buffer.writeu8(data, i, memPtr:readu8(i))
	end
	lib.MemFree(memPtr)

	local okLoad, map = pcall(rlib.R3D_LoadAlbedoMapFromMemory, ".png", data, size, color)
	if okLoad then
		return map
	end
	return nil
end

local function applyAlbedoColor(decal, color, transparency)
	local albedoColor = color:ToRaylib(transparency or 0)
	local offset = r3dstructs.R3D_Decal:offset("albedo") + r3dstructs.R3D_AlbedoMap:offset("color")
	buffer.copy(decal, offset, albedoColor, 0, structs.Color:size())
end

local function applyDecalSettings(instance, decal)
	local normalThreshold = math.max(0, instance.NormalThreshold or 0)
	local fadeWidth = math.max(0, instance.FadeWidth or 0)

	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("normalThreshold"), normalThreshold)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("fadeWidth"), fadeWidth)
end

local function applyFaceOffset(cf, offset)
	if type(offset) ~= "table" or not offset.__type then
		return cf
	end

	if offset.__type == "Vector3" then
		return cf * CFrame.new(offset.X, offset.Y, offset.Z)
	elseif offset.__type == "Vector2" then
		return cf * CFrame.new(offset.X, offset.Y, 0)
	end

	return cf
end

local function applyUvSettings(instance, decal, width, height)
	local studsU = tonumber(instance.StudsPerTileU) or 1
	local studsV = tonumber(instance.StudsPerTileV) or 1

	if studsU == 0 then
		studsU = 1
	end
	if studsV == 0 then
		studsV = 1
	end

	local tilesU = width / studsU
	local tilesV = height / studsV

	local offsetU = (instance.OffsetStudsU or 0) / studsU
	local offsetV = (instance.OffsetStudsV or 0) / studsV

	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvScale"), tilesU)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvScale") + 4, tilesV)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvOffset"), offsetU)
	buffer.writef32(decal, r3dstructs.R3D_Decal:offset("uvOffset") + 4, offsetV)
end

return {
	class = "Texture",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		local decal = buildBaseDecal()
		instance._r3dDecal = decal
		instance._decalHasMaps = false
		instance._decalLastPath = nil

		local function syncAlbedo(force)
			local color = instance.Color3:ToRaylib(instance.Transparency or 0)
			local source = instance.Texture

			if not force and source == instance._decalLastPath then
				if type(source) == "table" and source.ClassName == "EditableImage" then
					if source._dirty or source._texture ~= instance._decalLastTexture then
						-- continue to rebuild
					else
						return
					end
				else
					return
				end
			end

			instance._decalLastPath = source

			local map = nil
			if type(source) == "table" and source.ClassName == "EditableImage" then
				if source._dirty then
					if source._texture then
						lib.UnloadTexture(source._texture)
					end
					source._texture = lib.LoadTextureFromImage(source._image)
					source._dirty = false
				end
				map = loadAlbedoMapFromEditable(source, color)
				instance._decalLastTexture = source._texture
			else
				map = loadAlbedoMap(source, color)
				instance._decalLastTexture = nil
			end

			if map then
				if instance._decalHasMaps then
					pcall(rlib.R3D_UnloadDecalMaps, decal)
				end
				buffer.copy(decal, r3dstructs.R3D_Decal:offset("albedo"), map, 0, r3dstructs.R3D_AlbedoMap:size())
				instance._decalHasMaps = true
			else
				if instance._decalHasMaps then
					pcall(rlib.R3D_UnloadDecalMaps, decal)
					instance._decalHasMaps = false
				end
				local fallback = r3dstructs.R3D_AlbedoMap:new({ color = color })
				buffer.copy(decal, r3dstructs.R3D_Decal:offset("albedo"), fallback, 0, r3dstructs.R3D_AlbedoMap:size())
			end

			applyAlbedoColor(decal, instance.Color3, instance.Transparency or 0)
		end

		syncAlbedo(true)
		applyDecalSettings(instance, decal)

		local renderId
		if renderer and renderer.DecalPool and renderer.Pool then
			renderId = renderer.Pool.new("3d", function()
				syncAlbedo(false)
				if instance.Transparency >= 1 then
					return
				end

				local adornee = instance.Adornee
				if not adornee or not adornee.CFrame or not adornee.Size then
					adornee = instance.Parent
				end
				if not adornee or not adornee.CFrame or not adornee.Size then
					return
				end

				local face = instance.Face
				local depth = math.max(0.001, instance.Depth or 0.1)
				local cf
				local scale
				local width
				local height

				if instance.Wrap == true then
					cf = adornee.CFrame
					width = adornee.Size.X
					height = adornee.Size.Z
					scale = Vector3.new(adornee.Size.X + depth, adornee.Size.Y + depth, adornee.Size.Z + depth)
				else
					width, height = getFaceSize(adornee.Size, face)
					if not width or not height then
						return
					end

					cf = getFaceCFrame(adornee.CFrame, adornee.Size, face)
					if not cf then
						return
					end

					scale = Vector3.new(width, depth, height)
				end

				cf = applyFaceOffset(cf, instance.Position)

				applyUvSettings(instance, decal, width, height)
				local matrix = cf:ToRaylibMatrixScale(scale, structs)

				renderer.DecalPool.DrawDecal(decal, matrix)
			end)
		end

		instance.Changed:Connect(function(property)
			if property == "Texture" then
				syncAlbedo(true)
			elseif property == "Color3" or property == "Transparency" then
				applyAlbedoColor(decal, instance.Color3, instance.Transparency or 0)
			elseif property == "NormalThreshold" or property == "FadeWidth" then
				applyDecalSettings(instance, decal)
			end
		end)

		instance.Destroying:Connect(function()
			if renderId and renderer and renderer.Pool then
				renderer.Pool.Destroy(renderId)
			end
			pcall(rlib.R3D_UnloadDecalMaps, decal)
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
