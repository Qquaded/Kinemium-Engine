--!optimize 2
--!native

local raylib = require("./external/raylib")
local task = zune.task
local KiRend = {}
--local raygui = require("@raygui")

-- DEPENDENCIES
local skybox = require("./renderer/skybox")
local texture = require("./renderer/texture")
local signal = require("@Kinemium.signal")
local shader = require("./renderer/shader")
local freecam = require("./renderer/freecam")
local meshlib = require("./renderer/mesh")
local utils = require("@bufferutils")
local r3d = require("@r3d")
local rlib = r3d.lib

-- TYPES
export type KiRendConf = {
	width: number,
	height: number,
	maxFps: number,
	title: string,
	vsync: boolean?,
}

-- RAYLIB INIT
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

function KiRend.new(config: KiRendConf)
	-- RAYLIB INIT

	local Dimension = "3D"

	lib.SetTraceLogLevel(const.TraceLogLevel.LOG_ERROR)

	local useVsync = if config.vsync == nil then false else config.vsync
	local windowFlags = bit32.bor(const.ConfigFlags.FLAG_WINDOW_RESIZABLE)
	if useVsync then
		windowFlags = bit32.bor(windowFlags, const.ConfigFlags.FLAG_VSYNC_HINT)
	end
	lib.SetConfigFlags(windowFlags)

	lib.InitWindow(config.width, config.height, config.title)

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

	rlib.R3D_Init(config.width, config.height)
	rlib.R3D_SetUpscaleMode(2)
	rlib.R3D_SetAntiAliasingMode(1)
	rlib.R3D_SetTextureWrap(raylib.const.TextureWrap.TEXTURE_WRAP_REPEAT)

	local lastRenderWidth, lastRenderHeight = config.width, config.height

	local function getSortedPool(pool)
		local sorted = {}
		for id, entry in pairs(pool) do
			table.insert(sorted, { id = id, entry = entry })
		end
		table.sort(sorted, function(a, b)
			return a.entry.priority < b.entry.priority
		end)
		return sorted
	end

	local blur = require("./renderer/guiblur")
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
	local renderer_watching_keys = {}
	local renderer_draw_calls = {}
	local renderer_instanced_draw_calls = {}
	local renderer_decal_draw_calls = {}
	local renderer_instance_buffers_to_unload = {}
	local renderer_meshes = {}
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
	}

	local newBlurInstance = blur.Init(config.width, config.height)
	local rendererObject

	rendererObject = {
		Mesh = meshlib,
		Skybox = skybox,
		Freecam = freecam,
		Shader = shader,
		Raylib = raylib,
		Texture = texture(lib, structs),
		Enable3D = true,
		Blur = newBlurInstance,

		DrawFps = true,
		ShowPerfOverlay = false,
		PerfStats = perf_stats,

		SetDimension = function(self, dimension: "2D" | "3D")
			Dimension = dimension
		end,

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
				return renderer_storage.fonts[name]
			end,

			getFontTexture = function(name)
				local buf = renderer_storage.fonts[name]
				local texture = zune.mem.slice(buf, structs.Font:offset("texture"), structs.Texture2D:size())
				return texture
			end,

			Remove = function(name)
				renderer_storage.fonts[name] = nil
			end,
		},

		MeshPool = {
			DrawMesh = function(mesh, material, matrix, begin, End)
				table.insert(renderer_draw_calls, {
					mesh = mesh,
					material = material,
					matrix = matrix,
					Begin = begin,
					End = End,
				})
			end,
			DrawMeshInstanced = function(mesh, material, instances, count, begin, End, unloadAfterFrame)
				table.insert(renderer_instanced_draw_calls, {
					mesh = mesh,
					material = material,
					instances = instances,
					count = count,
					Begin = begin,
					End = End,
					unloadAfterFrame = unloadAfterFrame == true,
				})
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
				table.insert(renderer_decal_draw_calls, {
					decal = decal,
					transform = transform,
					Begin = begin,
					End = End,
				})
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

				return id
			end,

			SetPriority = function(id, newPriority: number)
				if renderer_pool.gui[id] then
					renderer_pool.gui[id].priority = newPriority
				elseif renderer_pool.object[id] then
					renderer_pool.object[id].priority = newPriority
				elseif renderer_pool.gizmos[id] then
					renderer_pool.gizmos[id].priority = newPriority
				end
			end,

			Destroy = function(id)
				renderer_pool.gui[id] = nil
				renderer_pool.object[id] = nil
				renderer_pool.gizmos[id] = nil
			end,
		},

		Audio = {
			new = function(audioPath, volume, pitch)
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
		local engineIcon = lib.LoadImage(Texture)
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

	function rendererObject:UseRlCamera(raylibCam)
		activeCamera = raylibCam
	end

	function rendererObject:InitAudioDevice()
		lib.InitAudioDevice()
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

		meshCalls = #renderer_draw_calls
		instancedBatches = #renderer_instanced_draw_calls

		perf_stats.call3d_ms = 0
		local callStart = os.clock()
		if #renderer_draw_calls > 0 or #renderer_instanced_draw_calls > 0 or #renderer_decal_draw_calls > 0 then
			if Dimension == "3D" then
				rlib.R3D_Begin(activeCamera)
				for _, drawCall in ipairs(renderer_draw_calls) do
					if drawCall.Begin then
						drawCall.Begin()
					end
					rlib.R3D_DrawMeshPro(drawCall.mesh, drawCall.material, drawCall.matrix)
					if drawCall.End then
						drawCall.End()
					end
				end
				for _, drawCall in ipairs(renderer_instanced_draw_calls) do
					instancedInstances += drawCall.count or 0
					if drawCall.Begin then
						drawCall.Begin()
					end
					rlib.R3D_DrawMeshInstanced(drawCall.mesh, drawCall.material, drawCall.instances, drawCall.count)
					if drawCall.End then
						drawCall.End()
					end
					if drawCall.unloadAfterFrame then
						table.insert(renderer_instance_buffers_to_unload, drawCall.instances)
					end
				end
				for _, drawCall in ipairs(renderer_decal_draw_calls) do
					if drawCall.Begin then
						drawCall.Begin()
					end
					rlib.R3D_DrawDecalPro(drawCall.decal, drawCall.transform)
					if drawCall.End then
						drawCall.End()
					end
				end
				rlib.R3D_End()
				for i = 1, #renderer_instance_buffers_to_unload do
					pcall(rlib.R3D_UnloadInstanceBuffer, renderer_instance_buffers_to_unload[i])
				end
				table.clear(renderer_instance_buffers_to_unload)
			end
		end
		table.clear(renderer_draw_calls)
		table.clear(renderer_instanced_draw_calls)
		table.clear(renderer_decal_draw_calls)
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
	end

	function rendererObject:Render2D()
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
					"3D Drawcalls: %.3f ms | 3D Pool Update: %.3f ms",
					perf_stats.call3d_ms,
					perf_stats.render3d_update_ms
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

		perf_stats.ui_ms = (os.clock() - uiStart) * 1000
	end

	function rendererObject:step(time)
		local frameStart = os.clock()
		local updateStart = os.clock()
		rendererObject.RuntimeLibrary.dt = lib.GetFrameTime()
		rendererObject.RuntimeLibrary.time = lib.GetTime()

		profileNextFrame()
		profileBegin("Update")

		local delta = lib.GetFrameTime()

		profileBegin("GC")
		if os.clock() - perf_stats.gc_last >= 10 then
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
				rlib.R3D_SetResolution(renderWidth, renderHeight)
				renderer_eventbus:Fire("WindowResized", renderWidth, renderHeight)
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
			},
			windowSize = {
				width = lib.GetRenderWidth(),
				height = lib.GetRenderHeight(),
			},
		}
	end

	return rendererObject
end

return KiRend
