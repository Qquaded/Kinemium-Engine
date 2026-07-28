--!optimize 2
--!native

local raylib = require("./external/raylib")
local zembed = require("@zembed")
local task = zune.task
local KiRend = {}
--local raygui = require("@raygui")

-- DEPENDENCIES
local Vector2 = require("@Vector2")
local MouseCursor = require("@Kinemium.MouseCursor")
local skybox = require("./renderer/skybox")
local texture = require("./renderer/texture")
local signal = require("@Kinemium.signal")
local shader = require("./renderer/shader")
local freecam = require("./renderer/freecam")
local meshlib = require("./renderer/mesh")
local utils = require("@bufferutils")
local filament = require("@Filament")
local adapter = require("@Raylibadapter")

local cachedMousePos = Vector2.new(0, 0)
local cachedMouseDelta = Vector2.new(0, 0)

-- TYPES
export type KiRendConf = {
	width: number,
	height: number,
	maxFps: number,
	title: string,
	vsync: boolean?,
	renderScale: number?,
	autoScale3D: boolean?,
	max3DRenderPixels: number?,
	min3DRenderScale: number?,
}

-- RAYLIB INIT
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

function KiRend.new(config: KiRendConf)
	-- RAYLIB INIT

	local Dimension = "3D"

	lib.SetTraceLogLevel(const.TraceLogLevel.LOG_ERROR)

	print("[Kine] Setup window..")

	local useVsync = true
	local useWindowMSAA = FlagExists("windowmsaa")
	local windowFlags = bit32.bor(const.ConfigFlags.FLAG_WINDOW_RESIZABLE)
	if useWindowMSAA then
		windowFlags = bit32.bor(windowFlags, const.ConfigFlags.FLAG_MSAA_4X_HINT)
		config.max3DRenderPixels = 3240000
	end
	if useVsync then
		windowFlags = bit32.bor(windowFlags, const.ConfigFlags.FLAG_VSYNC_HINT)
	end
	if FlagExists("highdpi") then
		windowFlags = bit32.bor(windowFlags, const.ConfigFlags.FLAG_WINDOW_HIGHDPI)
	end
	lib.SetConfigFlags(windowFlags)
	local ok, err = pcall(lib.InitWindow, config.width, config.height, config.title)
	if not ok then
		error("Failed to initialize window: " .. tostring(err))
	end

	if lib.WindowShouldClose() == 0 then
		lib.BeginDrawing()
		lib.ClearBackground(const.BLACK)
		lib.EndDrawing()
	end

	if config.maxFps and config.maxFps > 0 then
		lib.SetTargetFPS(config.maxFps)
	elseif not useVsync then
		lib.SetTargetFPS(0)
	end
	lib.SetExitKey(0)

	local sceneTarget = lib.LoadRenderTexture(config.width, config.height)

	local function readRenderTexFields(rt)
		local raw = type(rt) == "table" and rt.getraw and rt:getraw() or rt
		local texOffset = structs.RenderTexture:offset("texture")
		local texId = buffer.readu32(raw, texOffset + structs.Texture:offset("id"))
		local texW = buffer.readi32(raw, texOffset + structs.Texture:offset("width")) -- was readi16
		local texH = buffer.readi32(raw, texOffset + structs.Texture:offset("height")) -- was readi16
		return texId, texW, texH
	end

	local texId, texW, texH = readRenderTexFields(sceneTarget)
	print("[Kine] sceneTarget texId:", texId, "w:", texW, "h:", texH)
	local ctx = filament.lib.Kine_Filament_Create(texW, texH)
	print("Filament ctx:", ctx)
	assert(ctx ~= nil and ctx ~= 0, "Kine_Filament_Create failed")
	local filamentCube = filament.lib.Kine_Filament_CreateMesh(ctx, 1)

	local filamentPixelBuf = buffer.create(texW * texH * 4)
	local filamentTexId = filament.lib.Kine_Filament_GetColorTextureId(ctx)

	local filamentTexBuf = buffer.create(structs.Texture2D:size())
	buffer.writeu32(filamentTexBuf, structs.Texture2D:offset("id"), filamentTexId)
	buffer.writei32(filamentTexBuf, structs.Texture2D:offset("width"), texW)
	buffer.writei32(filamentTexBuf, structs.Texture2D:offset("height"), texH)
	buffer.writei32(filamentTexBuf, structs.Texture2D:offset("mipmaps"), 1)
	buffer.writei32(
		filamentTexBuf,
		structs.Texture2D:offset("format"),
		raylib.const.PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
	)

	local requested3DRenderScale = math.clamp(config.renderScale or 1, 0.1, 1)
	local autoScale3D = if config.autoScale3D == nil then true else config.autoScale3D
	local max3DRenderPixels = config.max3DRenderPixels or (1920 * 1080)
	local min3DRenderScale = math.clamp(config.min3DRenderScale or 0.5, 0.1, 1)
	local internalRenderWidth, internalRenderHeight = config.width, config.height
	local actual3DRenderScale = 1

	local sortedPoolCache = {}
	local sortedPoolDirty = {}

	local function getSortedPool(pool)
		if sortedPoolCache[pool] and not sortedPoolDirty[pool] then
			return sortedPoolCache[pool]
		end
		local sorted = {}
		for id, entry in pairs(pool) do
			table.insert(sorted, { id = id, entry = entry })
		end
		table.sort(sorted, function(a, b)
			return a.entry.priority < b.entry.priority
		end)
		sortedPoolCache[pool] = sorted
		sortedPoolDirty[pool] = false
		return sorted
	end

	local activeCamera

	local renderer_eventbus = signal.new()
	local renderer_hooks = {
		Before3D = {},
		After3D = {},
		After2D = {},
		Before2D = {},
		Renderstep = {},
		Afterstep = {},
		Shutdown = {},
	}

	local renderer_pool = {
		gui = {},
		object = {},
		gizmos = {},
	}
	local renderer_storage = {
		fonts = {},
	}
	local renderer_font_resolver
	local renderer_watching_keys = {}
	local renderer_draw_calls = {}
	local renderer_instanced_draw_calls = {}
	local renderer_decal_draw_calls = {}
	local draw_calls_count = 0
	local instanced_draw_calls_count = 0
	local decal_draw_calls_count = 0
	local renderer_instance_buffers_to_unload = {}
	local renderer_meshes = {}
	local renderer_mousedata = {}
	local ENGINE_PROFILER = {}

	local perf_stats = {
		frame_ms = 0,
		fps = 0,
		update_ms = 0,
		render3d_ms = 0,
		ui_ms = 0,
		gui_roots = 0,
		scene_roots_3d = 0,
		mesh_calls = 0,
		instanced_batches = 0,
		instanced_instances = 0,
		batches_3d = 0,
		input_ms = 0,
		input_key_ms = 0,
		rendereventbus_conns = 0,
		call3d_ms = 0,
		dispatch_ms = 0,
		render3d_update_ms = 0,
		gc_ms = 0,
		gc_last = os.clock(),
		render_width = config.width,
		render_height = config.height,
		render_scale = 1,
	}
	local rendererObject

	local function compute3DResolution(targetWidth, targetHeight)
		local scale = requested3DRenderScale
		if autoScale3D and max3DRenderPixels > 0 then
			local pixelCount = targetWidth * targetHeight
			if pixelCount > max3DRenderPixels then
				scale = math.min(scale, math.sqrt(max3DRenderPixels / pixelCount))
			end
		end

		scale = math.clamp(scale, min3DRenderScale, 1)

		local width = math.max(1, math.floor(targetWidth * scale + 0.5))
		local height = math.max(1, math.floor(targetHeight * scale + 0.5))
		return width, height, scale
	end

	local function apply3DResolution(targetWidth, targetHeight)
		local width, height, scale = compute3DResolution(targetWidth, targetHeight)
		internalRenderWidth = width
		internalRenderHeight = height
		actual3DRenderScale = scale
		perf_stats.render_width = width
		perf_stats.render_height = height
		perf_stats.render_scale = scale
		return width, height, scale
	end

	apply3DResolution(config.width, config.height)

	rendererObject = {
		Mesh = meshlib,
		Skybox = skybox,
		Freecam = freecam,
		Shader = shader,
		Raylib = raylib,
		Texture = texture(lib, structs),
		Enable3D = true,
		Enable3DRT = false,
		EnableUIRT = false,
		TDRT = nil,
		UIRT = nil,

		DrawFps = true,
		ShowPerfOverlay = false,
		PerfStats = perf_stats,
		Internal3DRenderScale = actual3DRenderScale,
		Max3DRenderPixels = max3DRenderPixels,

		LoadImageAsTex = function(path)
			path = zembed.AssetPath(path)
			local ok, image = pcall(lib.LoadImage, path)
			if not ok or not image then
				error("Failed to load image: " .. tostring(path))
			end
			local buf = utils.wrap(lib.LoadTextureFromImage(image), structs.Texture2D)

			local texture_raw = buf:getraw()
			pcall(raylib.lib.SetTextureFilter, texture_raw, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			pcall(raylib.lib.SetTextureWrap, texture_raw, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			pcall(raylib.lib.GenTextureMipmaps, texture_raw)

			return buf:getraw(), image
		end,

		ImproveTexture = function(texture)
			pcall(raylib.lib.SetTextureFilter, texture, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			pcall(raylib.lib.SetTextureWrap, texture, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			pcall(raylib.lib.GenTextureMipmaps, texture)
		end,

		SetDimension = function(self, dimension: "2D" | "3D")
			Dimension = dimension
		end,

		Set3DRenderScale = function(self, scale)
			requested3DRenderScale = math.clamp(scale or 1, min3DRenderScale, 1)
			local renderWidth, renderHeight = lib.GetRenderWidth(), lib.GetRenderHeight()
			local width, height, actualScale = apply3DResolution(renderWidth, renderHeight)
			self.Internal3DRenderScale = actualScale
			return width, height, actualScale
		end,

		Lib2d = adapter.lib,

		SetAutoScale3D = function(self, enabled)
			autoScale3D = enabled ~= false
			local renderWidth, renderHeight = lib.GetRenderWidth(), lib.GetRenderHeight()
			local width, height, actualScale = apply3DResolution(renderWidth, renderHeight)
			self.Internal3DRenderScale = actualScale
			return width, height, actualScale
		end,

		SetMax3DRenderPixels = function(self, pixels)
			if type(pixels) == "number" and pixels > 0 then
				max3DRenderPixels = math.floor(pixels)
			else
				max3DRenderPixels = 0
			end
			self.Max3DRenderPixels = max3DRenderPixels
			local renderWidth, renderHeight = lib.GetRenderWidth(), lib.GetRenderHeight()
			local width, height, actualScale = apply3DResolution(renderWidth, renderHeight)
			self.Internal3DRenderScale = actualScale
			return width, height, actualScale
		end,

		Get3DRenderResolution = function()
			return {
				width = internalRenderWidth,
				height = internalRenderHeight,
				scale = actual3DRenderScale,
			}
		end,

		perfstats = perf_stats,

		RuntimeLibrary = {
			lib = lib,
			drawModel = meshlib.drawModel,
			loadMaterialOnModel = meshlib.loadMaterialOnModel,
			LoadShader = shader.LoadShader,
			structs = structs,
			const = const,
			dt = lib.GetFrameTime(),
			time = lib.GetTime(),
			perf = perf_stats,
		},

		EventBus = renderer_eventbus,

		Draw = raylib.lib,

		Hook = {
			new = function(
				hookListName: "Before3D" | "After3D" | "Before2D" | "After2D" | "Renderstep" | "Afterstep" | "Shutdown",
				cb
			)
				table.insert(renderer_hooks[hookListName], cb)
			end,
		},

		Font = {
			SetResolver = function(resolver)
				renderer_font_resolver = resolver
			end,

			new = function(name, fontPath, size)
				local buf = utils.wrap(lib.LoadFontEx(fontPath, size, nil, 0), structs.Font)

				local texture = buf:getptr("texture", structs.Texture2D)
				local texture_raw = texture:getraw()
				raylib.lib.SetTextureFilter(texture_raw, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
				raylib.lib.SetTextureWrap(texture_raw, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
				raylib.lib.GenTextureMipmaps(texture_raw)

				local buf_raw = buf:getraw()
				renderer_storage.fonts[name] = buf_raw
				return buf_raw
			end,

			Get = function(name)
				local font = renderer_storage.fonts[name]
				if font or not renderer_font_resolver then
					return font
				end

				local success, result = pcall(renderer_font_resolver, name)
				if not success then
					print("Font resolver error: " .. tostring(result))
					return nil
				end

				return renderer_storage.fonts[name] or result
			end,

			getFontTexture = function(name)
				local buf = renderer_storage.fonts[name]
				local texture = zune.mem.slice(buf, structs.Font:offset("texture"), structs.Texture2D:size())
				return texture
			end,

			Remove = function(name)
				local font = renderer_storage.fonts[name]
				if font then
					lib.UnloadFont(font)
					renderer_storage.fonts[name] = nil
				end
			end,
		},

		MeshPool = {
			DrawMesh = function(data)
				local mesh = data.mesh
				local material = data.material
				local color = data.color
				local matrix = data.matrix
				local begin = data.begin
				local transparency = data.transparency

				draw_calls_count = draw_calls_count + 1
				local drawCall = renderer_draw_calls[draw_calls_count]
				if not drawCall then
					drawCall = {}
					renderer_draw_calls[draw_calls_count] = drawCall
				end
				drawCall.mesh = mesh
				drawCall.material = material
				drawCall.Color = color
				drawCall.matrix = matrix
				drawCall.Transparency = transparency
				drawCall.Metallic = data.metallic
				drawCall.Roughness = data.roughness
				drawCall.Begin = begin
				drawCall.End = nil
			end,
			DrawMeshInstanced = function(mesh, material, instances, count, begin, End, unloadAfterFrame)
				instanced_draw_calls_count = instanced_draw_calls_count + 1
				local drawCall = renderer_instanced_draw_calls[instanced_draw_calls_count]
				if not drawCall then
					drawCall = {}
					renderer_instanced_draw_calls[instanced_draw_calls_count] = drawCall
				end
				drawCall.mesh = mesh
				drawCall.material = material
				drawCall.instances = instances
				drawCall.count = count
				drawCall.Begin = begin
				drawCall.End = End
				drawCall.unloadAfterFrame = unloadAfterFrame == true
			end,

			CreateMaterial = function(texture, shader)
				local default = lib.LoadMaterialDefault()
				lib.SetMaterialTexture(default, 0, texture)

				local wrapper = utils.wrap(default, structs.Material)
				wrapper.shader = utils.typepointer(shader)

				return wrapper
			end,

			AddMesh = function(mesh: buffer, mat_texture, mat_shader: buffer?)
				local default = lib.LoadMaterialDefault()
				lib.SetMaterialTexture(default, 0, texture)

				local wrapper = utils.wrap(default, structs.Material)
				wrapper.shader = utils.typepointer(mat_shader)

				local data = {
					id = math.random(0, 1000),
					mat = default,
				}

				table.insert(renderer_meshes, data)

				return data
			end,

			GetMesh = function(MeshId)
				for i, v in pairs(renderer_meshes) do
					if v.id == MeshId then
						return v
					end
				end
				return
			end,

			SetConfigMesh = function(meshId, prop, Value)
				for i, v in pairs(renderer_meshes) do
					if v.id == meshId then
						renderer_meshes[i][prop] = Value
						break
					end
				end
			end,

			RemoveMesh = function(id)
				for i, v in pairs(renderer_meshes) do
					if v.id == id then
						table.remove(renderer_meshes, i)
						break
					end
				end
			end,
		},

		DecalPool = {
			DrawDecal = function(decal, transform, begin, End)
				decal_draw_calls_count = decal_draw_calls_count + 1
				local drawCall = renderer_decal_draw_calls[decal_draw_calls_count]
				if not drawCall then
					drawCall = {}
					renderer_decal_draw_calls[decal_draw_calls_count] = drawCall
				end
				drawCall.decal = decal
				drawCall.transform = transform
				drawCall.Begin = begin
				drawCall.End = End
			end,
		},

		Pool = {
			new = function(type: "2d" | "3d" | "gizmo", renderFn: () -> (), priority: number?)
				local pool
				if type == "2d" then
					pool = renderer_pool.gui
				elseif type == "3d" then
					pool = renderer_pool.object
				elseif type == "gizmo" then
					pool = renderer_pool.gizmos
				end

				local id
				repeat
					id = math.random(1, 99999)
				until pool[id] == nil
				local poolEntry = {
					render = renderFn,
					object = nil,
					priority = priority or 0,
				}

				pool[id] = poolEntry
				sortedPoolDirty[pool] = true

				return id
			end,

			SetPriority = function(id, newPriority: number)
				if renderer_pool.gui[id] then
					renderer_pool.gui[id].priority = newPriority
					sortedPoolDirty[renderer_pool.gui] = true
				elseif renderer_pool.object[id] then
					renderer_pool.object[id].priority = newPriority
					sortedPoolDirty[renderer_pool.object] = true
				elseif renderer_pool.gizmos[id] then
					renderer_pool.gizmos[id].priority = newPriority
					sortedPoolDirty[renderer_pool.gizmos] = true
				end
			end,

			Destroy = function(id)
				if renderer_pool.gui[id] then
					sortedPoolDirty[renderer_pool.gui] = true
				end
				if renderer_pool.object[id] then
					sortedPoolDirty[renderer_pool.object] = true
				end
				if renderer_pool.gizmos[id] then
					sortedPoolDirty[renderer_pool.gizmos] = true
				end
				renderer_pool.gui[id] = nil
				renderer_pool.object[id] = nil
				renderer_pool.gizmos[id] = nil
			end,
		},

		Audio = {
			new = function(audioPath, volume, pitch)
				audioPath = zembed.AssetPath(audioPath)
				local sound = lib.LoadSound(audioPath)
				if volume then
					lib.SetSoundVolume(sound, volume)
				end
				if pitch then
					lib.SetSoundPitch(sound, pitch)
				end

				return {
					IsPlaying = function()
						return lib.IsSoundPlaying(sound) == 1
					end,

					Pause = function()
						lib.PauseSound(sound)
					end,

					Play = function()
						raylib.lib.PlaySound(sound)
					end,

					Destroy = function()
						raylib.lib.UnloadSound(sound)
					end,
				}
			end,
		},
	}

	local function profileBegin(name)
		if ENGINE_PROFILER then
			ENGINE_PROFILER:Begin(name)
		end
	end

	local function profileSetCounter(name, value)
		if ENGINE_PROFILER then
			ENGINE_PROFILER:SetCounter(name, value)
		end
	end

	local function profileNextFrame()
		if ENGINE_PROFILER then
			ENGINE_PROFILER:NextFrame()
		end
	end

	local function profileEnd()
		if ENGINE_PROFILER then
			ENGINE_PROFILER:End()
		end
	end

	function rendererObject.GetViewMatrix()
		if activeCamera then
			return raylib.lib.GetCameraMatrix(activeCamera)
		end
		return
	end

	function rendererObject:GetProjectionMatrix()
		if activeCamera then
			return raylib.lib.rlGetMatrixProjection()
		end
		return
	end

	function rendererObject:WatchKey(RaylibKeyObject)
		renderer_watching_keys[RaylibKeyObject] = true
	end

	function rendererObject:StopWatchingKey(RaylibKeyObject)
		renderer_watching_keys[RaylibKeyObject] = nil
	end

	function rendererObject:GetInverseProjectionMatrix()
		local proj = self:GetProjectionMatrix()
		if not proj then
			return nil
		end
		if raylib.lib.MatrixInvert then
			return raylib.lib.MatrixInvert(proj)
		end
		return
	end

	function rendererObject:MakeKernelTex(kernelSize: number?)
		local ksize = kernelSize or 32

		local kernel = {}
		for i = 1, ksize do
			local sample = {
				x = math.random() * 2 - 1,
				y = math.random() * 2 - 1,
				z = math.random(),
			}

			local scale = i / ksize
			scale = 0.1 + 0.9 * scale * scale
			kernel[i] = { sample.x * scale, sample.y * scale, sample.z * scale }
		end

		local data = buffer.create(ksize * 3 * 4) -- 3 floats * 4 bytes each
		for i = 1, ksize do
			local v = kernel[i]
			buffer.writef32(data, (i - 1) * 12 + 0, v.x) -- offset in bytes
			buffer.writef32(data, (i - 1) * 12 + 4, v.y)
			buffer.writef32(data, (i - 1) * 12 + 8, v.z)
		end

		local img = lib.ImageFromBuffer(data, ksize, 1, 1, raylib.const.PixelFormat.PIXELFORMAT_UNCOMPRESSED_R32G32B32)
		local tex = lib.LoadTextureFromImage(img)
		lib.UnloadImage(img) -- free CPU-side image
		return tex
	end

	function rendererObject:MakeNoiseTex(size: number?)
		local w = size or 4
		local h = w
		local pixelCount = w * h
		local data = buffer.create(pixelCount * 3)
		for i = 0, pixelCount - 1 do
			local r = math.random(0, 255)
			local g = math.random(0, 255)
			local b = math.random(0, 255)
			buffer.writeu8(data, i * 3, r)
			buffer.writeu8(data, i * 3 + 1, g)
			buffer.writeu8(data, i * 3 + 2, b)
		end

		local img = lib.ImageFromBuffer(data, w, h, 1, raylib.const.PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8)
		local tex = lib.LoadTextureFromImage(img)
		lib.UnloadImage(img)
		return tex
	end

	function rendererObject:MakeDepthBuffer()
		local const = raylib.const
		local width, height = raylib.lib.GetRenderWidth(), raylib.lib.GetRenderHeight()

		local fbo = raylib.lib.rlLoadFramebuffer(width, height)
		raylib.lib.rlEnableFramebuffer(fbo)

		local depthTex = raylib.lib.rlLoadTextureDepth(width, height, true)
		raylib.lib.rlFramebufferAttach(fbo, depthTex, const.RL_ATTACHMENT_DEPTH, const.RL_ATTACHMENT_TEXTURE2D, 0)

		local normalTex =
			raylib.lib.rlLoadTexture(nil, width, height, const.PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1)

		raylib.lib.rlFramebufferAttach(
			fbo,
			normalTex,
			const.RL_ATTACHMENT_COLOR_CHANNEL0,
			const.RL_ATTACHMENT_TEXTURE2D,
			0
		)

		if not raylib.lib.rlFramebufferComplete(fbo) then
			error("Framebuffer not complete")
		end

		raylib.lib.rlDisableFramebuffer()

		self.FBO = fbo
		self.Depth = depthTex
		self.Normal = normalTex
	end

	function rendererObject:SetProfiler(profilerObject)
		ENGINE_PROFILER = profilerObject
	end

	function rendererObject:SetGlobalShader(shader)
		globalShaderOverride = shader
	end

	function rendererObject:SetIcon(Texture)
		local engineIcon = lib.LoadImage(zembed.AssetPath(Texture))
		lib.SetWindowIcon(engineIcon)
	end

	function rendererObject:SetResizable()
		lib.SetConfigFlags(const.ConfigFlags.FLAG_WINDOW_RESIZABLE)
	end

	function rendererObject:Include()
		local caller = getfenv(2)
		for k, v in pairs(rendererObject) do
			caller[k] = v
		end
	end

	local camObject

	function rendererObject:UseRlCamera(raylibCam, c)
		camObject = c
		activeCamera = raylibCam
	end

	function rendererObject:InitAudioDevice()
		lib.InitAudioDevice()
	end

	function rendererObject:DrawRenderTexture(rendertex, improveQuality)
		local width = lib.GetRenderWidth()
		local height = lib.GetRenderHeight()

		local destRec = structs.Rectangle:new({
			x = 0,
			y = 0,
			width = width,
			height = height,
		})

		local tex = utils.extract.texture(rendertex)

		local sourceRec = structs.Rectangle:new({
			x = 0,
			y = 0,
			width = width,
			height = -height,
		})

		if improveQuality then
			rendererObject.ImproveTexture(tex)
		end

		lib.DrawTexturePro(
			tex,
			sourceRec,
			destRec,
			vector.create(0, 0),
			0,
			structs.Color:new({ r = 255, g = 255, b = 255, a = 255 })
		)
	end

	function rendererObject:Render3D()
		if not activeCamera then
			return
		end
		local render3DStart = os.clock()
		local meshCalls = 0
		local instancedBatches = 0
		local instancedInstances = 0
		local sorted3DPool = getSortedPool(renderer_pool.object)
		perf_stats.scene_roots_3d = #sorted3DPool

		lib.BeginMode3D(activeCamera)
		lib.rlEnableBackfaceCulling()
		renderer_eventbus:Fire("Begin3D")

		for _, v in pairs(renderer_hooks.Before3D) do
			v(rendererObject.RuntimeLibrary)
		end

		local render3DUpdateStart = os.clock()
		for _, item in ipairs(sorted3DPool) do
			local entry = item.entry
			if entry.render then
				entry.render(rendererObject.RuntimeLibrary)
			end
		end
		perf_stats.render3d_update_ms = (os.clock() - render3DUpdateStart) * 1000

		meshCalls = draw_calls_count
		instancedBatches = instanced_draw_calls_count

		if camObject then
			local cf = camObject.CFrame
			filament.lib.Kine_Filament_SetCameraPosition(ctx, cf.Position.X, cf.Position.Y, cf.Position.Z)
			local pos = cf.Position
			local target = pos + cf:GetLookVector()
			filament.lib.Kine_Filament_SetCameraLookAt(ctx, pos.X, pos.Y, pos.Z, target.X, target.Y, target.Z, 0, 1, 0)
		end
		perf_stats.call3d_ms = 0
		local callStart = os.clock()
		if draw_calls_count > 0 or instanced_draw_calls_count > 0 or decal_draw_calls_count > 0 then
			if Dimension == "3D" then
				if not rendererObject.TDRT and rendererObject.Enable3DRT then
					rendererObject.TDRT = lib.LoadRenderTexture(internalRenderWidth, internalRenderHeight)
				end
				--
				if rendererObject.Enable3DRT and rendererObject.TDRT then
					-- replaced by filament
				else
					-- replaced by filament
				end

				for i = 1, draw_calls_count do
					local drawCall = renderer_draw_calls[i]
					if drawCall.Begin then
						drawCall.Begin()
					end

					local rawMatrix = drawCall.matrix
					if type(rawMatrix) == "table" and rawMatrix.getraw then
						rawMatrix = rawMatrix:getraw()
					end

					filament.lib.Kine_Filament_DrawMesh(
						ctx,
						filamentCube,
						drawCall.Color.R,
						drawCall.Color.G,
						drawCall.Color.B,
						nil,
						drawCall.Transparency,
						drawCall.Roughness,
						drawCall.Metallic,
						rawMatrix
					)

					if drawCall.End then
						drawCall.End()
					end
				end
				for i = 1, instanced_draw_calls_count do
					local drawCall = renderer_instanced_draw_calls[i]
					instancedInstances += drawCall.count or 0
					if drawCall.Begin then
						drawCall.Begin()
					end
					if drawCall.End then
						drawCall.End()
					end
					if drawCall.unloadAfterFrame then
						table.insert(renderer_instance_buffers_to_unload, drawCall.instances)
					end
				end
				for i = 1, decal_draw_calls_count do
					local drawCall = renderer_decal_draw_calls[i]
					if drawCall.Begin then
						drawCall.Begin()
					end
					if drawCall.End then
						drawCall.End()
					end
				end
				for i = 1, #renderer_instance_buffers_to_unload do
				end
				table.clear(renderer_instance_buffers_to_unload)
			end
		end
		for i = 1, draw_calls_count do
			local d = renderer_draw_calls[i]
			d.mesh = nil
			d.material = nil
			d.matrix = nil
			d.Begin = nil
			d.End = nil
		end
		for i = 1, instanced_draw_calls_count do
			local d = renderer_instanced_draw_calls[i]
			d.mesh = nil
			d.material = nil
			d.instances = nil
			d.Begin = nil
			d.End = nil
		end
		for i = 1, decal_draw_calls_count do
			local d = renderer_decal_draw_calls[i]
			d.decal = nil
			d.transform = nil
			d.Begin = nil
			d.End = nil
		end
		draw_calls_count = 0
		instanced_draw_calls_count = 0
		decal_draw_calls_count = 0
		perf_stats.call3d_ms = (os.clock() - callStart) * 1000

		for _, item in ipairs(getSortedPool(renderer_pool.gizmos)) do
			local entry = item.entry
			if entry.render then
				entry.render(rendererObject.RuntimeLibrary)
			end
		end

		for _, v in pairs(renderer_hooks.After3D) do
			v(rendererObject.RuntimeLibrary)
		end

		lib.rlDisableBackfaceCulling()
		lib.EndMode3D()
		renderer_eventbus:Fire("End3D")

		perf_stats.mesh_calls = meshCalls
		perf_stats.instanced_batches = instancedBatches
		perf_stats.instanced_instances = instancedInstances
		perf_stats.batches_3d = meshCalls + instancedBatches
		perf_stats.render3d_ms = (os.clock() - render3DStart) * 1000

		if rendererObject.Enable3DRT and rendererObject.TDRT then
			rendererObject:DrawRenderTexture(rendererObject.TDRT, actual3DRenderScale < 1)
		end
	end

	function rendererObject:Render2D()
		if rendererObject.EnableUIRT and not rendererObject.UIRT then
			rendererObject.UIRT = lib.LoadRenderTexture(lib.GetRenderWidth(), lib.GetRenderHeight())
			return -- skip a frame
		end
		MouseCursor.beginFrame()
		if rendererObject.UIRT and rendererObject.EnableUIRT then
			lib.BeginTextureMode(rendererObject.UIRT)
			lib.ClearBackground(const.BLANK)
		end
		local uiStart = os.clock()
		for _, v in pairs(renderer_hooks.Before2D) do
			v(rendererObject.RuntimeLibrary)
		end

		local sortedGuiPool = getSortedPool(renderer_pool.gui)
		perf_stats.gui_roots = #sortedGuiPool

		for _, item in ipairs(sortedGuiPool) do
			local gui = item.entry
			gui.render(lib, gui.object and gui.object() or nil, time, structs, rendererObject.RuntimeLibrary)
		end

		for _, v in pairs(renderer_hooks.After2D) do
			v(rendererObject.RuntimeLibrary)
		end

		if rendererObject.DrawFps then
			local fpsText = string.format("%2i FPS", lib.GetFPS())
			local width, height = lib.GetRenderWidth(), lib.GetRenderHeight()

			local size = 10
			local textLength = lib.MeasureText(fpsText, size)

			local color = structs.Color:new({ r = 255, g = 255, b = 255, a = 127 })
			lib.DrawText(fpsText, width - textLength - 10, height - 10 - size, size, color)
		end

		if rendererObject.ShowPerfOverlay then
			local color = structs.Color:new({ r = 255, g = 255, b = 255, a = 127 })
			local size = 10

			local text = table.concat({
				string.format(
					"Frame: %.3f ms | FPS: %d | Dispatch: %.3f ms",
					perf_stats.frame_ms,
					perf_stats.fps,
					perf_stats.dispatch_ms
				),
				string.format(
					"Update: %.3f ms | UI: %.3f ms | UI Roots: %d",
					perf_stats.update_ms,
					perf_stats.ui_ms,
					perf_stats.gui_roots
				),
				string.format(
					"3D: %.3f ms | Batches: %d (%d mesh + %d inst) | Instances: %d | 3D Roots: %d",
					perf_stats.render3d_ms,
					perf_stats.batches_3d,
					perf_stats.mesh_calls,
					perf_stats.instanced_batches,
					perf_stats.instanced_instances,
					perf_stats.scene_roots_3d
				),
				string.format(
					"3D Drawcalls: %.3f ms | 3D Pool Update: %.3f ms | Internal: %dx%d (%.0f%%)",
					perf_stats.call3d_ms,
					perf_stats.render3d_update_ms,
					perf_stats.render_width,
					perf_stats.render_height,
					perf_stats.render_scale * 100
				),
				string.format("Input: %.3f ms | Key Process: %.3f ms", perf_stats.input_ms, perf_stats.input_key_ms),
				string.format(
					"GC: %.3f ms | gcinfo: %i | RenderBus Connections: %d",
					perf_stats.gc_ms,
					gcinfo(),
					perf_stats.rendereventbus_conns
				),
			}, "\n")

			lib.DrawText(text, 10, lib.GetRenderHeight() - 10 - (#string.split(text, "\n") + 1) * size, size, color)
		end

		if rendererObject.UIRT and rendererObject.EnableUIRT then
			lib.EndTextureMode()

			rendererObject:DrawRenderTexture(rendererObject.UIRT)
		end

		MouseCursor.commitFrame()

		perf_stats.ui_ms = (os.clock() - uiStart) * 1000
	end

	renderer_eventbus:SetHistoryLimit(0)

	function rendererObject:step(time)
		local frameStart = os.clock()
		local updateStart = os.clock()
		rendererObject.RuntimeLibrary.dt = lib.GetFrameTime()
		rendererObject.RuntimeLibrary.time = lib.GetTime()

		profileNextFrame()
		profileBegin("Update")

		local mousePos = lib.GetMousePosition()
		local delta = lib.GetMouseDelta()

		cachedMousePos.x = mousePos.x
		cachedMousePos.y = mousePos.y
		cachedMouseDelta.x = delta.x
		cachedMouseDelta.y = delta.y
		renderer_mousedata.position = cachedMousePos
		renderer_mousedata.delta = cachedMouseDelta
		renderer_mousedata.mouse_wheel_move = lib.GetMouseWheelMove()
		renderer_mousedata.mouse_wheel_delta = lib.GetMouseDelta()
		renderer_mousedata.is_cursor_hidden = lib.IsCursorHidden() == 1
		renderer_mousedata.is_cursor_inbounds = lib.IsCursorOnScreen() == 1
		renderer_mousedata.Button1IsDown = lib.IsMouseButtonDown(0) == 1
		renderer_mousedata.Button1Down = lib.IsMouseButtonPressed(0) == 1
		renderer_mousedata.Button1Released = lib.IsMouseButtonReleased(0) == 1
		renderer_mousedata.Button2IsDown = lib.IsMouseButtonDown(1) == 1
		renderer_mousedata.Button2Down = lib.IsMouseButtonPressed(1) == 1
		renderer_mousedata.Button2Released = lib.IsMouseButtonReleased(1) == 1
		renderer_eventbus:Fire("MouseData", renderer_mousedata)

		profileBegin("Controller Poll")
		renderer_eventbus:Fire("GamepadPoll", nil)
		profileEnd()

		local delta = lib.GetFrameTime()

		profileBegin("GC")
		if os.clock() - perf_stats.gc_last >= 3 then
			local gcStart = os.clock()
			zune.luau.garbagecollect()
			perf_stats.gc_ms = (os.clock() - gcStart) * 1000
			perf_stats.gc_last = os.clock()
		end
		profileEnd()

		for _, v in pairs(renderer_hooks.Renderstep) do
			v(delta)
		end

		perf_stats.rendereventbus_conns = renderer_eventbus:GetConnectionCount()

		renderer_eventbus:Fire("PreRender", delta)
		renderer_eventbus:Fire("RenderStepped", delta)

		time += delta

		if raylib.lib.IsWindowResized() == 1 then
			local renderWidth, renderHeight = raylib.lib.GetRenderWidth(), raylib.lib.GetRenderHeight()
			if
				renderWidth > 0
				and renderHeight > 0
				and (renderWidth ~= lastRenderWidth or renderHeight ~= lastRenderHeight)
			then
				lastRenderWidth, lastRenderHeight = renderWidth, renderHeight
				local internalWidth, internalHeight, actualScale = apply3DResolution(renderWidth, renderHeight)
				rendererObject.Internal3DRenderScale = actualScale
				renderer_eventbus:Fire(
					"WindowResized",
					renderWidth,
					renderHeight,
					internalWidth,
					internalHeight,
					actualScale
				)
				if rendererObject.Enable3DRT and rendererObject.TDRT then
					lib.UnloadRenderTexture(rendererObject.TDRT)
					rendererObject.TDRT = lib.LoadRenderTexture(internalWidth, internalHeight)
				end
				lib.UnloadRenderTexture(sceneTarget)
				sceneTarget = lib.LoadRenderTexture(renderWidth, renderHeight)
				local rTexId, rTexW, rTexH = readRenderTexFields(sceneTarget)
				filament.lib.Kine_Filament_Resize(ctx, rTexW, rTexH)
				if rendererObject.EnableUIRT and rendererObject.UIRT then
					lib.UnloadRenderTexture(rendererObject.UIRT)
					rendererObject.UIRT = lib.LoadRenderTexture(renderWidth, renderHeight)
				end
				texW, texH = rTexW, rTexH
				filamentTexId = filament.lib.Kine_Filament_GetColorTextureId(ctx)
				buffer.writeu32(filamentTexBuf, structs.Texture2D:offset("id"), filamentTexId)
				buffer.writei32(filamentTexBuf, structs.Texture2D:offset("width"), texW)
				buffer.writei32(filamentTexBuf, structs.Texture2D:offset("height"), texH)
			end
		end

		local keyboardListenStart = os.clock()
		for keycode, _ in pairs(renderer_watching_keys) do
			if lib.IsKeyDown(keycode) == 1 then
				renderer_eventbus:Fire("IsKeyDown", keycode)
			end
			if lib.IsKeyPressed(keycode) == 1 then
				renderer_eventbus:Fire("IsKeyDown", keycode)
			end
			if lib.IsKeyReleased(keycode) == 1 then
				renderer_eventbus:Fire("IsKeyReleased", keycode)
			end
		end
		perf_stats.input_key_ms = (os.clock() - keyboardListenStart) * 1000

		local mouseDelta = lib.GetMouseDelta()
		if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
			renderer_eventbus:Fire("MouseMoved", mouseDelta)
		end

		local wheel = lib.GetMouseWheelMove()
		if wheel ~= 0 then
			renderer_eventbus:Fire("MouseWheel", wheel)
		end
		perf_stats.update_ms = (os.clock() - updateStart) * 1000

		profileEnd()
		profileBegin("Render")

		--lib.BeginTextureMode(viewport)
		lib.BeginDrawing()
		lib.ClearBackground(const.BLACK)

		rendererObject:Render3D()
		filament.lib.Kine_Filament_RenderFrame(ctx)

		local srcRec = structs.Rectangle:new({ x = 0, y = 0, width = texW, height = -texH })
		local dstRec =
			structs.Rectangle:new({ x = 0, y = 0, width = lib.GetRenderWidth(), height = lib.GetRenderHeight() })
		lib.DrawTexturePro(
			filamentTexBuf,
			srcRec,
			dstRec,
			vector.create(0, 0),
			0,
			structs.Color:new({ r = 255, g = 255, b = 255, a = 255 })
		)

		rendererObject:Render2D()

		local dispatchStart = os.clock()
		lib.EndDrawing()
		perf_stats.dispatch_ms = (os.clock() - dispatchStart) * 1000

		renderer_eventbus:Fire("Heartbeat", delta)
		perf_stats.frame_ms = (os.clock() - frameStart) * 1000
		perf_stats.fps = lib.GetFPS()

		profileSetCounter("FPS", lib.GetFPS())
		profileEnd()

		for _, v in pairs(renderer_hooks.Afterstep) do
			v(delta)
		end
		task.wait(0)
	end

	function rendererObject:Run()
		local time = 0.0

		while lib.WindowShouldClose() == 0 do
			rendererObject:step(time)
		end

		rendererObject:Shutdown()
	end

	function rendererObject:Shutdown()
		for _, callback in pairs(renderer_hooks.Shutdown) do
			local success, result = pcall(function()
				callback()
			end)
			if not success then
				warn(result)
			end
		end

		zune.process.exit(0)
	end

	function rendererObject:GetStats()
		local gui3DCount = 0
		local gui2DCount = 0
		local gizmoCount = 0

		for _ in pairs(renderer_pool.object) do
			gui3DCount = gui3DCount + 1
		end
		for _ in pairs(renderer_pool.gui) do
			gui2DCount = gui2DCount + 1
		end
		for _ in pairs(renderer_pool.gizmos) do
			gizmoCount = gizmoCount + 1
		end

		return {
			fps = lib.GetFPS(),
			time = lib.GetTime(),
			render3DCount = gui3DCount,
			render2DCount = gui2DCount,
			gizmoCount = gizmoCount,
			perf = {
				frame_ms = perf_stats.frame_ms,
				update_ms = perf_stats.update_ms,
				render3d_ms = perf_stats.render3d_ms,
				ui_ms = perf_stats.ui_ms,
				batches_3d = perf_stats.batches_3d,
				mesh_calls = perf_stats.mesh_calls,
				instanced_batches = perf_stats.instanced_batches,
				instanced_instances = perf_stats.instanced_instances,
				gui_roots = perf_stats.gui_roots,
				scene_roots_3d = perf_stats.scene_roots_3d,
				input_ms = perf_stats.input_ms,
				input_key_ms = perf_stats.input_key_ms,
				rendereventbus_conns = perf_stats.rendereventbus_conns,
				call3d_ms = perf_stats.call3d_ms,
				dispatch_ms = perf_stats.dispatch_ms,
				render3d_update_ms = perf_stats.render3d_update_ms,
				gc_ms = perf_stats.gc_ms,
				render_width = perf_stats.render_width,
				render_height = perf_stats.render_height,
				render_scale = perf_stats.render_scale,
			},
			windowSize = {
				width = lib.GetRenderWidth(),
				height = lib.GetRenderHeight(),
			},
			internal3DSize = {
				width = internalRenderWidth,
				height = internalRenderHeight,
				scale = actual3DRenderScale,
			},
		}
	end

	return rendererObject
end

return KiRend
