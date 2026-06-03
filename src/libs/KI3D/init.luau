--!optimize 2

local raylib = require("@raylib")
local lib = raylib.lib
local ki3d = {}
local utils = require("@bufferutils")

--  Types

export type KI3DShader = {
	name: string,
	vertex: string,
	fragment: string,
	shader: FFIPointer,
}

export type KI3DFilter = {
	shader: { vertex: string?, fragment: string },
	priority: number?,
	blendMode: string?,
	inputTexture: string?,
	disableauto: boolean?,
	setuniforms: ((self: any, runtime: any) -> ())?,
	begin: (self: any, runtime: any) -> (),
	finish: (self: any, runtime: any) -> (),
}

--  G-Buffer Render Targets
--  sceneRT  – main RGBA colour pass
--  normalRT – view-space normals (RGB encoded 0-1)
--  depthRT  – depth values (R channel, hardware z)
--  outputRT – scratch buffer: filter output before compositing
--  swapRT   – copy of currentRT before a multiply-blend composite

local sceneRT, normalRT, depthRT, outputRT, swapRT

local shaders = {}
local filters = {}

local _normalShader = nil -- shader used for the automatic normal prepass
local _depthShader = nil -- shader used for the automatic depth prepass

ki3d.enabled = true
ki3d.filtersEnabled = false
ki3d.finalRT = nil

local function getSortedFilters()
	local sorted = {}
	for _, f in pairs(filters) do
		table.insert(sorted, f)
	end
	table.sort(sorted, function(a, b)
		return (a.priority or 0) < (b.priority or 0)
	end)
	return sorted
end

local function makeRuntime(currentRT, w, h, filterObj)
	return {
		lib = lib,
		structs = raylib.structs,
		const = raylib.const,
		texture = utils.extract.texture(currentRT),
		depth = utils.extract.texture(depthRT),
		normal = utils.extract.texture(normalRT),
		width = w,
		height = h,
		size = { x = 0, y = 0, width = w, height = -h },
		rect = raylib.structs.Rectangle,
		shaderobj = filterObj.shader,
	}
end

--  Public API

ki3d.color3 = function(x, y, z)
	return { r = x, g = y, b = z }
end
ki3d.vector3 = function(x, y, z)
	return { x = x, y = y, z = z }
end

-- Named geometry-shader registry (legacy / external use)
ki3d.shaders = {
	new = function(name, data: KI3DShader)
		local object = data
		object.name = name
		object.shader = lib.LoadShader(object.vertex, object.fragment)
		shaders[name] = object
		return shaders[name]
	end,
	load = function(name)
		return shaders[name] :: KI3DShader
	end,
}

ki3d.filters = {
	new = function(name, data: KI3DFilter)
		local object = data
		object.name = name
		object.priority = data.priority or 0
		object.shader = lib.LoadShader(object.shader.vertex, object.shader.fragment)
		filters[name] = object
		return filters[name]
	end,
	load = function(name)
		return filters[name] :: KI3DFilter
	end,
	get = function(name)
		return filters[name]
	end,
}

-- Tell KI3D which shaders to use during the automatic depth and normal prepasses.
-- Must be called after ki3d.init() and after the shaders are loaded.
ki3d.SetPassShaders = function(normalShader, depthShader)
	_normalShader = normalShader
	_depthShader = depthShader
end

-- Allocate (or reallocate) all G-Buffer render targets.
ki3d.init = function(screenWidth, screenHeight)
	screenWidth = screenWidth or lib.GetScreenWidth()
	screenHeight = screenHeight or lib.GetScreenHeight()

	sceneRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	normalRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	depthRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	outputRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	swapRT = lib.LoadRenderTexture(screenWidth, screenHeight)
end

ki3d.Frame = function(self, camera, drawFn)
	if not sceneRT or not ki3d.enabled then
		return
	end

	local W = lib.GetRenderWidth()
	local H = lib.GetRenderHeight()

	--  Pass 1: Depth
	if _depthShader then
		lib.BeginTextureMode(depthRT)
		lib.ClearBackground(raylib.const.BLACK)
		_G._globalShaderOverride = _depthShader
		drawFn()
		_G._globalShaderOverride = nil
		lib.EndTextureMode()
	end

	--  Pass 2: Normals
	if _normalShader then
		lib.BeginTextureMode(normalRT)
		lib.ClearBackground(raylib.const.BLACK)
		_G._globalShaderOverride = _normalShader
		drawFn()
		_G._globalShaderOverride = nil
		lib.EndTextureMode()
	end

	--  Pass 3: Main scene
	lib.BeginTextureMode(sceneRT)
	lib.ClearBackground(raylib.const.BLACK)
	drawFn()
	lib.EndTextureMode()

	--  Post-process filter chain
	if not ki3d.filtersEnabled then
		self.finalRT = sceneRT
		return
	end

	local currentRT = sceneRT -- accumulation target
	local sorted = getSortedFilters()
	local flipRect = { x = 0, y = 0, width = W, height = -H } -- GL Y-flip: for rendering scene into filter
	local copyRect = { x = 0, y = 0, width = W, height = H } -- no flip: for RT-to-RT copies
	local origin = vector.create(0, 0)
	local WHITE = raylib.const.WHITE
	local BLANK = raylib.const.BLANK
	local BLACK = raylib.const.BLACK

	for _, filter in ipairs(sorted) do
		local runtime = makeRuntime(currentRT, W, H, filter)

		-- disableauto filters only set geometry-shader uniforms; no full-screen quad
		if filter.disableauto and filter.setuniforms then
			filter.setuniforms(filter, runtime)
			continue
		end

		-- Render this filter's output into outputRT
		lib.BeginTextureMode(outputRT)
		lib.ClearBackground(BLACK)
		filter:begin(runtime)

		local inputTex = runtime.texture
		if filter.inputTexture == "depth" then
			inputTex = runtime.depth
		elseif filter.inputTexture == "normal" then
			inputTex = runtime.normal
		end

		lib.DrawTextureRec(inputTex, runtime.rect:new(flipRect), origin, WHITE)
		filter:finish(runtime)
		lib.EndTextureMode()

		if filter.blendMode == "multiply" then
			lib.BeginTextureMode(swapRT)
			lib.ClearBackground(BLACK)
			lib.DrawTextureRec(utils.extract.texture(currentRT), runtime.rect:new(copyRect), origin, WHITE)
			lib.EndTextureMode()

			lib.BeginTextureMode(currentRT)
			lib.ClearBackground(BLACK)
			lib.DrawTextureRec(utils.extract.texture(swapRT), runtime.rect:new(copyRect), origin, WHITE)
			lib.BeginBlendMode(raylib.const.BlendMode.BLEND_MULTIPLIED)
			lib.DrawTextureRec(utils.extract.texture(outputRT), runtime.rect:new(flipRect), origin, WHITE)
			lib.EndBlendMode()
			lib.EndTextureMode()
		else
			lib.BeginTextureMode(currentRT)
			lib.ClearBackground(BLANK)
			lib.DrawTextureRec(utils.extract.texture(outputRT), runtime.rect:new(flipRect), origin, WHITE)
			lib.EndTextureMode()
		end
	end

	self.finalRT = currentRT
end

--  Final Blit to Screen

ki3d.Draw = function(self, _camera)
	if not self.finalRT then
		return
	end

	local W = lib.GetRenderWidth()
	local H = lib.GetRenderHeight()

	lib.ClearBackground(raylib.const.BLACK)
	lib.BeginBlendMode(raylib.const.BlendMode.BLEND_ALPHA)

	-- source: +H = read texture normally (y-up storage, OpenGL convention)
	-- dest:   -H = flip on screen (compensates for GL vs screen Y-axis)
	local source = raylib.structs.Rectangle:new({ x = 0, y = 0, width = W, height = -H })
	local dest = raylib.structs.Rectangle:new({ x = 0, y = 0, width = W, height = -H })

	lib.DrawTexturePro(utils.extract.texture(self.finalRT), source, dest, vector.create(0, 0), 0, raylib.const.WHITE)

	lib.EndBlendMode()
end

--  Resize Support

ki3d.UpdateRenderTextures = function(screenWidth, screenHeight)
	for _, rt in ipairs({ sceneRT, normalRT, depthRT, outputRT, swapRT }) do
		if rt then
			lib.UnloadRenderTexture(rt)
		end
	end

	sceneRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	normalRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	depthRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	outputRT = lib.LoadRenderTexture(screenWidth, screenHeight)
	swapRT = lib.LoadRenderTexture(screenWidth, screenHeight)
end

--  Filter Control

ki3d.EnableFilters = function()
	ki3d.filtersEnabled = true
end
ki3d.DisableFilters = function()
	ki3d.filtersEnabled = false
end

--  G-Buffer Access

ki3d.GetRenderTextures = function()
	return { scene = sceneRT, normalRT = normalRT, depthRT = depthRT }
end

--  Legacy Stubs (backward compat)
-- These are kept so older service code that calls Begin3D/End3D still compiles.
-- The new pipeline is driven entirely by ki3d:Frame(); these are no-ops there.

ki3d.Begin3D = function(self, target)
	if not sceneRT then
		return
	end
	lib.BeginTextureMode(target or sceneRT)
	lib.ClearBackground(raylib.const.BLACK)
end

ki3d.End3D = function(self)
	if not sceneRT then
		return
	end
	lib.EndTextureMode()
	-- Run filter chain on whatever was drawn (legacy path, no prepasses)
	self.finalRT = sceneRT
end

ki3d.BeginNormals = function(normalShader)
	_G._globalShaderOverride = normalShader
	if normalShader then
		lib.BeginShaderMode(normalShader)
	end
end

ki3d.EndNormals = function()
	lib.EndShaderMode()
	_G._globalShaderOverride = nil
end

ki3d.BeginDepth = function(depthShader)
	_G._globalShaderOverride = depthShader
	if depthShader then
		lib.BeginShaderMode(depthShader)
	end
end

ki3d.EndDepth = function()
	lib.EndShaderMode()
	_G._globalShaderOverride = nil
end

return ki3d
