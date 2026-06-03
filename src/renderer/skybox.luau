local rl = require("@raylib")
local zembed = require("@zembed")
local ffi = zune.ffi
local lib = rl.lib

local structs = rl.structs
local const = rl.const

local skybox = { _loaded = false }

local U32 = 4294967296

local OFF_MODEL_MATERIALS = structs.Model:offset("materials")
local OFF_MATERIAL_MAPS = structs.Material:offset("maps")
local OFF_MATERIAL_SHADER = structs.Material:offset("shader")
local OFF_SHADER_LOCS = structs.Shader:offset("locs")

local SIZE_SHADER = structs.Shader:size()
local SIZE_TEX = structs.TextureCubemap:size()

local STRIDE_MATERIALMAP = structs.MaterialMap:size()
local OFF_MATERIALMAP_TEXTURE = structs.MaterialMap:offset("texture")

local function readPtr64FromBuffer(buf: buffer, off: number): number
	local lo = buffer.readu32(buf, off)
	local hi = buffer.readu32(buf, off + 4)
	return hi * U32 + lo
end

local function readPtr64FromPtr(ptr, off: number): number
	local lo = ptr:readu32(off)
	local hi = ptr:readu32(off + 4)
	return hi * U32 + lo
end

local function FromCubemap(paths)
	assert(#paths == 6, "Need exactly 6 images")

	local imgs = {}
	local sizes = {}

	for i, path in ipairs(paths) do
		path = zembed.AssetPath(path)
		imgs[i] = lib.LoadImage(path)

		local buf = imgs[i]
		local w = buffer.readi32(buf, 4)
		local h = buffer.readi32(buf, 8)

		sizes[i] = vector.create(w, h)

		if imgs[i].data == nil then
			error("Failed to load image from buffer: " .. path)
		end
	end

	local w, h = sizes[1].x, sizes[1].y
	local cross = lib.GenImageColor(w * 4, h * 3, const.WHITE)

	local function makeRect(x, y, size)
		return structs.Rectangle:new({ x = x, y = y, width = size.x, height = size.y })
	end

	lib.ImageDraw(imgs[3], cross, makeRect(0, 0, sizes[3]), makeRect(w, 0, sizes[3])) -- +Y
	lib.ImageDraw(imgs[4], cross, makeRect(0, 0, sizes[4]), makeRect(w, 2 * h, sizes[4])) -- -Y
	lib.ImageDraw(imgs[2], cross, makeRect(0, 0, sizes[2]), makeRect(0, h, sizes[2])) -- -X
	lib.ImageDraw(imgs[5], cross, makeRect(0, 0, sizes[5]), makeRect(w, h, sizes[5])) -- +Z
	lib.ImageDraw(imgs[1], cross, makeRect(0, 0, sizes[1]), makeRect(2 * w, h, sizes[1])) -- +X
	lib.ImageDraw(imgs[6], cross, makeRect(0, 0, sizes[6]), makeRect(3 * w, h, sizes[6])) -- -Z

	for _, img in ipairs(imgs) do
		lib.UnloadImage(img)
	end

	local cubemap = lib.LoadTextureCubemap(cross, const.CubemapLayout.CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE)
	lib.UnloadImage(cross)

	return cubemap
end

local function ptrFromU64(addr: number)
	local b = buffer.create(8)
	local hi = math.floor(addr / U32)
	local lo = addr - hi * U32
	buffer.writeu32(b, 0, lo)
	buffer.writeu32(b, 4, hi)
	return ffi.ptrFromAddress(b)
end

local function ptrFromStructFieldBuf(structBuf: buffer, fieldOff: number)
	return ptrFromU64(readPtr64FromBuffer(structBuf, fieldOff))
end

local function ptrFromStructFieldPtr(structPtr, fieldOff: number)
	return ptrFromU64(readPtr64FromPtr(structPtr, fieldOff))
end

local function getMaterialsPtr(model: buffer)
	return ptrFromStructFieldBuf(model, OFF_MODEL_MATERIALS)
end

local function setMaterialShaderOnModel(model: buffer, shader: buffer)
	local materials = getMaterialsPtr(model)
	materials:write(OFF_MATERIAL_SHADER, shader, 0, SIZE_SHADER)
end

local function setShaderLoc(shader: buffer, locIndex: number, locValue: number)
	local locs = ptrFromStructFieldBuf(shader, OFF_SHADER_LOCS)
	locs:writei32(locIndex * 4, locValue)
end

local function setMaterialMapTexture(model: buffer, mapIndex: number, texture: buffer)
	local materials = getMaterialsPtr(model)
	local maps = ptrFromStructFieldPtr(materials, OFF_MATERIAL_MAPS)
	local dst = mapIndex * STRIDE_MATERIALMAP + OFF_MATERIALMAP_TEXTURE
	maps:write(dst, texture, 0, SIZE_TEX)
end

function skybox.Load(png)
	--assert(not skybox._loaded, "attempted to load skybox after already loading it")

	skybox.Mesh = lib.GenMeshCube(1, 1, 1)
	skybox.Model = lib.LoadModelFromMesh(skybox.Mesh)

	skybox.Shader = lib.LoadShader(
		zembed.AssetPath("kineasset://sky/default/shader/skybox.vs"),
		zembed.AssetPath("kineasset://sky/default/shader/skybox.fs")
	)

	local envLoc = lib.GetShaderLocation(skybox.Shader, "environmentMap")
	assert(envLoc ~= -1, "skybox shader missing uniform: environmentMap")

	setShaderLoc(skybox.Shader, rl.const.ShaderLocationIndex.SHADER_LOC_MAP_CUBEMAP, envLoc)
	setMaterialShaderOnModel(skybox.Model, skybox.Shader)

	local img = lib.LoadImage(zembed.AssetPath(png or "kineasset://sky/default/images/cubemap.png"))
	skybox.CubeMap = lib.LoadTextureCubemap(img, const.CubemapLayout.CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE)
	lib.UnloadImage(img)

	setMaterialMapTexture(skybox.Model, const.MaterialMapIndex.MATERIAL_MAP_CUBEMAP, skybox.CubeMap)

	skybox._loaded = true
end

function skybox.Unload()
	assert(skybox._loaded, "attempted to unload skybox after already unloading it")

	skybox._loaded = false

	if skybox.CubeMap then
		lib.UnloadTexture(skybox.CubeMap)
	end
	if skybox.Model then
		lib.UnloadModel(skybox.Model)
	end
	if skybox.Shader then
		lib.UnloadShader(skybox.Shader)
	end

	skybox.Mesh = nil
	skybox.Model = nil
	skybox.Shader = nil
	skybox.CubeMap = nil
end

function skybox.Draw(position, scale)
	assert(skybox._loaded, "attempted to draw skybox before loading skybox")
	scale = scale or 50

	lib.rlDisableBackfaceCulling()
	lib.rlDisableDepthMask()
	lib.DrawModel(skybox.Model, position, scale, const.WHITE)
	lib.rlEnableBackfaceCulling()
	lib.rlEnableDepthMask()
end

skybox.FromCubemap = FromCubemap

return skybox
