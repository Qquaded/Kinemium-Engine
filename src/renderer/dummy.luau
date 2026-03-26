--!optimize 2
--!native

local task = zune.task
local KiRend = {}

local signal = require("@Kinemium.signal")

local mockMeshlib = {
	LoadMesh = function()
		return {}
	end,
	UnloadMesh = function() end,
	GetMesh = function()
		return nil
	end,
	GenerateMesh = function()
		return {}, {}
	end,
	PreloadStandardMeshes = function()
		return {}
	end,
	GetModelRegistry = function()
		return {}
	end,
	drawModel = function() end,
	loadMaterialOnModel = function() end,
}

local mockSkybox = {
	Load = function() end,
	Unload = function() end,
	Draw = function() end,
	FromCubemap = function()
		return {}
	end,
}

local mockShader = {
	LoadShader = function()
		return {}
	end,
	LoadShaderCode = function()
		return {}
	end,
	GetShaderUniformLocation = function()
		return 0
	end,
	SetShaderUniform = function() end,
	SetShaderValueRaw = function() end,
	SetShaderTextureRaw = function() end,
	SetShaderTexture = function() end,
	UnloadShader = function() end,
}

local mockFreecam = {
	Update = function() end,
	SetSpeed = function() end,
	SetSensitivity = function() end,
	GetPos = function()
		return { X = 0, Y = 0, Z = 0 }
	end,
	SetCFrame = function() end,
	GetCFrame = function()
		return { Position = { X = 0, Y = 0, Z = 0 } }
	end,
}

local mockTexture = function()
	return {
		LoadTextureFromFile = function()
			return nil
		end,
		LoadTextureFromFileAsync = function()
			return nil
		end,
		GetMaterials = function()
			return {}
		end,
	}
end

local mockBlur = {
	Init = function(width, height)
		return {
			enabled = true,
			SetBlurRadius = function() end,
			BeginCapture = function() end,
			EndCapture = function() end,
			ApplyBlur = function() end,
			DrawFullBlur = function() end,
			DrawMixed = function() end,
			DrawBlurredRegion = function() end,
			DrawUnblurred = function() end,
			Enable = function() end,
			Disable = function() end,
			Cleanup = function() end,
		}
	end,
}

local mockRaylib = {
	lib = setmetatable({}, {
		__index = function(_, key)
			return function()
				return 0
			end
		end,
	}),
	const = setmetatable({}, {
		__index = function(_, key)
			return {}
		end,
	}),
	structs = setmetatable({}, {
		__index = function(_, key)
			return {
				new = function()
					return {}
				end,
				offset = function()
					return 0
				end,
				size = function()
					return 0
				end,
			}
		end,
	}),
}

-- TYPES
export type KiRendConf = {
	width: number,
	height: number,
	maxFps: number,
	title: string,
	vsync: boolean?,
}

function KiRend.new(config: KiRendConf)
	local time = 0.0
	local frameCount = 0
	local simulatedFPS = config.maxFps or 120
	local frameTime = 1 / simulatedFPS
	local lastFrameTime = os.clock()
	local isRunning = false
	local Dimension = "3D"

	local activeCamera = nil

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
		sounds = {},
	}
	local renderer_watching_keys = {}
	local renderer_draw_calls = {}
	local renderer_instanced_draw_calls = {}
	local renderer_meshes = {}
	local ENGINE_PROFILER = nil

	local perf_stats = {
		frame_ms = 0,
		fps = simulatedFPS,
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

	local rendererObject

	rendererObject = {
		Mesh = mockMeshlib,
		Skybox = mockSkybox,
		Freecam = mockFreecam,
		Shader = mockShader,
		Raylib = mockRaylib,
		Texture = mockTexture(),
		Enable3D = true,
		Blur = mockBlur.Init(config.width, config.height),

		DrawFps = true,
		ShowPerfOverlay = false,
		PerfStats = perf_stats,

		SetDimension = function(self, dimension: "2D" | "3D")
			Dimension = dimension
		end,

		RuntimeLibrary = {
			lib = mockRaylib.lib,
			drawModel = mockMeshlib.drawModel,
			loadMaterialOnModel = mockMeshlib.loadMaterialOnModel,
			LoadShader = mockShader.LoadShader,
			structs = mockRaylib.structs,
			const = mockRaylib.const,
			dt = frameTime,
			time = 0,
			perf = perf_stats,
		},

		EventBus = renderer_eventbus,

		Draw = mockRaylib.lib,

		Hook = {
			new = function(
				hookListName: "Before3D" | "After3D" | "Before2D" | "After2D" | "Renderstep" | "Afterstep" | "Shutdown",
				cb
			)
				if not renderer_hooks[hookListName] then
					return
				end
				table.insert(renderer_hooks[hookListName], cb)
			end,
		},

		Font = {
			new = function(name, fontPath, size)
				if renderer_storage.fonts[name] then
					return renderer_storage.fonts[name]
				end
				renderer_storage.fonts[name] = {
					name = name,
					path = fontPath,
					size = size or 24,
				}
				return renderer_storage.fonts[name]
			end,

			Get = function(name)
				return renderer_storage.fonts[name]
			end,

			getFontTexture = function(name)
				return renderer_storage.fonts[name]
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
				return buffer.create(64) -- mock material struct
			end,

			AddMesh = function(mesh, mat_texture, mat_shader)
				local data = {
					id = math.random(0, 1000),
					mat = {},
				}
				table.insert(renderer_meshes, data)
				return data
			end,

			GetMesh = function(MeshId)
				for _, v in pairs(renderer_meshes) do
					if v.id == MeshId then
						return v
					end
				end
				return nil
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
			DrawDecal = function() end,
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

				pool[id] = {
					render = renderFn,
					object = nil,
					priority = priority or 0,
				}

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
				local soundId = math.random(1, 99999)
				renderer_storage.sounds[soundId] = {
					path = audioPath,
					volume = volume or 1.0,
					pitch = pitch or 1.0,
					playing = false,
				}

				return {
					IsPlaying = function()
						return renderer_storage.sounds[soundId] and renderer_storage.sounds[soundId].playing or false
					end,

					Pause = function()
						if renderer_storage.sounds[soundId] then
							renderer_storage.sounds[soundId].playing = false
						end
					end,

					Play = function()
						if renderer_storage.sounds[soundId] then
							renderer_storage.sounds[soundId].playing = true
						end
					end,

					Destroy = function()
						renderer_storage.sounds[soundId] = nil
					end,
				}
			end,
		},
	}

	function rendererObject.GetViewMatrix()
		-- no real camera matrix in headless, return nil
		return nil
	end

	function rendererObject:GetProjectionMatrix()
		return nil
	end

	function rendererObject:GetInverseProjectionMatrix()
		return nil
	end

	function rendererObject:WatchKey(RaylibKeyObject)
		renderer_watching_keys[RaylibKeyObject] = true
	end

	function rendererObject:StopWatchingKey(RaylibKeyObject)
		renderer_watching_keys[RaylibKeyObject] = nil
	end

	-- Returns a mock noise texture (headless: just a table descriptor)
	function rendererObject:MakeKernelTex(kernelSize: number?)
		return { _mock = true, kind = "kernel", size = kernelSize or 32 }
	end

	function rendererObject:MakeNoiseTex(size: number?)
		return { _mock = true, kind = "noise", size = size or 4 }
	end

	function rendererObject:MakeDepthBuffer()
		self.FBO = 0
		self.Depth = 0
		self.Normal = 0
	end

	function rendererObject:SetProfiler(profilerObject)
		ENGINE_PROFILER = profilerObject
	end

	function rendererObject:SetGlobalShader(shader)
		-- no-op in headless
	end

	function rendererObject:SetIcon(Texture)
		-- no-op in headless
	end

	function rendererObject:SetResizable()
		-- no-op in headless
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
		-- no-op in headless
	end

	function rendererObject:Render3D()
		local render3DStart = os.clock()
		local meshCalls = 0
		local instancedBatches = 0
		local instancedInstances = 0

		local sorted3DPool = getSortedPool(renderer_pool.object)
		perf_stats.scene_roots_3d = #sorted3DPool

		renderer_eventbus:Fire("Begin3D")

		for _, v in pairs(renderer_hooks.Before3D) do
			pcall(v, rendererObject.RuntimeLibrary)
		end

		local render3DUpdateStart = os.clock()
		for _, item in ipairs(sorted3DPool) do
			local entry = item.entry
			if entry.render then
				pcall(entry.render, rendererObject.RuntimeLibrary)
			end
		end
		perf_stats.render3d_update_ms = (os.clock() - render3DUpdateStart) * 1000

		-- Flush draw calls (no-op in headless, but we still invoke Begin/End callbacks)
		meshCalls = #renderer_draw_calls
		instancedBatches = #renderer_instanced_draw_calls

		local callStart = os.clock()
		for _, drawCall in ipairs(renderer_draw_calls) do
			if drawCall.Begin then
				pcall(drawCall.Begin)
			end
			if drawCall.End then
				pcall(drawCall.End)
			end
		end
		for _, drawCall in ipairs(renderer_instanced_draw_calls) do
			instancedInstances += drawCall.count or 0
			if drawCall.Begin then
				pcall(drawCall.Begin)
			end
			if drawCall.End then
				pcall(drawCall.End)
			end
		end
		table.clear(renderer_draw_calls)
		table.clear(renderer_instanced_draw_calls)
		perf_stats.call3d_ms = (os.clock() - callStart) * 1000

		for _, item in ipairs(getSortedPool(renderer_pool.gizmos)) do
			local entry = item.entry
			if entry.render then
				pcall(entry.render, rendererObject.RuntimeLibrary)
			end
		end

		for _, v in pairs(renderer_hooks.After3D) do
			pcall(v, rendererObject.RuntimeLibrary)
		end

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
			pcall(v, rendererObject.RuntimeLibrary)
		end

		local sortedGuiPool = getSortedPool(renderer_pool.gui)
		perf_stats.gui_roots = #sortedGuiPool

		for _, item in ipairs(sortedGuiPool) do
			local gui = item.entry
			pcall(
				gui.render,
				mockRaylib.lib,
				gui.object and gui.object() or nil,
				time,
				mockRaylib.structs,
				rendererObject.RuntimeLibrary
			)
		end

		for _, v in pairs(renderer_hooks.After2D) do
			pcall(v, rendererObject.RuntimeLibrary)
		end

		perf_stats.ui_ms = (os.clock() - uiStart) * 1000
	end

	-- Matches the real renderer's lowercase `step` signature
	function rendererObject:step(time)
		local frameStart = os.clock()
		local updateStart = os.clock()

		rendererObject.RuntimeLibrary.dt = frameTime
		rendererObject.RuntimeLibrary.time = time

		if ENGINE_PROFILER then
			ENGINE_PROFILER:NextFrame()
			ENGINE_PROFILER:Begin("Update")
		end

		if os.clock() - perf_stats.gc_last >= 10 then
			local gcStart = os.clock()
			zune.luau.garbagecollect()
			perf_stats.gc_ms = (os.clock() - gcStart) * 1000
			perf_stats.gc_last = os.clock()
		end

		for _, v in pairs(renderer_hooks.Renderstep) do
			pcall(v, frameTime)
		end

		perf_stats.rendereventbus_conns = renderer_eventbus:GetConnectionCount()

		renderer_eventbus:Fire("PreRender", frameTime)
		renderer_eventbus:Fire("RenderStepped", frameTime)

		-- Key watching (no-op in headless — keys are never down, but hooks still fire)
		local keyboardListenStart = os.clock()
		perf_stats.input_key_ms = (os.clock() - keyboardListenStart) * 1000

		perf_stats.update_ms = (os.clock() - updateStart) * 1000

		if ENGINE_PROFILER then
			ENGINE_PROFILER:End()
			ENGINE_PROFILER:Begin("Render")
		end

		rendererObject:Render3D()
		rendererObject:Render2D()

		local dispatchStart = os.clock()
		perf_stats.dispatch_ms = (os.clock() - dispatchStart) * 1000

		renderer_eventbus:Fire("Heartbeat", frameTime)

		perf_stats.frame_ms = (os.clock() - frameStart) * 1000
		perf_stats.fps = simulatedFPS

		if ENGINE_PROFILER then
			ENGINE_PROFILER:SetCounter("FPS", simulatedFPS)
			ENGINE_PROFILER:End()
		end

		for _, v in pairs(renderer_hooks.Afterstep) do
			pcall(v, frameTime)
		end

		task.wait(0)
	end

	-- Also keep Step (PascalCase) as an alias for compatibility
	function rendererObject:Step()
		local currentTime = os.clock()
		time = time + frameTime
		frameCount = frameCount + 1
		rendererObject:step(time)
		local sleepTime = frameTime - (os.clock() - currentTime)
		if sleepTime > 0 then
			task.wait(sleepTime)
		end
		lastFrameTime = os.clock()
	end

	function rendererObject:Run(maxFrames)
		isRunning = true
		lastFrameTime = os.clock()

		while lib and isRunning do
			time += frameTime
			frameCount += 1
			rendererObject:step(time)

			if maxFrames and frameCount >= maxFrames then
				break
			end
		end

		rendererObject:Shutdown()
	end

	function rendererObject:Stop()
		isRunning = false
	end

	function rendererObject:Shutdown()
		for _, callback in pairs(renderer_hooks.Shutdown) do
			local success, result = pcall(callback)
			if not success then
				warn(result)
			end
		end

		table.clear(renderer_storage.fonts)
		table.clear(renderer_storage.sounds)
		table.clear(renderer_pool.gui)
		table.clear(renderer_pool.object)
		table.clear(renderer_pool.gizmos)
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
			fps = simulatedFPS,
			time = time,
			frameCount = frameCount,
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
				width = config.width,
				height = config.height,
			},
			isHeadless = true,
		}
	end

	return rendererObject
end

return KiRend
