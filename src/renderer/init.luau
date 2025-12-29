--!optimize 2
--!native

local raylib = require("./external/raylib")
local task = zune.task
--local raygui = require("@raygui")

-- DEPENDENCIES
local skybox = require("./renderer/skybox")
local texture = require("./renderer/texture")
local signal = require("@Kinemium.signal")
local Vector2 = require("@Vector2")
local shader = require("./renderer/shader")
local freecam = require("./renderer/freecam")
local Enum = require("@EnumMap")
local CFrame = require("@CFrame")
local meshlib = require("./renderer/mesh")
local blurmod = require("./renderer/guiblur")
local Instance = require("@Instance")
local bufferUtils = require("@bufferutils")
local Camera = require("@Camera")

-- CONF
local mainSignal = signal.new()
local game

-- INIT
local Kinemium_camera = Instance.new("Camera")
Camera.callback(Kinemium_camera)
Kinemium_camera.Name = "CurrentCamera"

-- TABLES
local fontRegistry = {}
local renderPool3d = {}
local renderPool2d = {}
local callbackStep = {}
local global_registry = {}
local mouseProperties = {}
local activeShaders = {}
local partRegistry = {}
local guiRegistry = {}

-- RAYLIB INIT
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

-- W&H
local screenWidth = raylib.lib.GetMonitorWidth(0)
local screenHeight = raylib.lib.GetMonitorHeight(0)

-- MATERIALS
local txtureMethods = texture(lib)
local materialList = txtureMethods.GetMaterials()

-- CAMERA SETTINGS
local FOV = 70
Kinemium_camera.FieldOfView = FOV
local cameraPos = vector.create(0.0, 5.0, 10.0)

-- RAYLIB INIT
--lib.SetTraceLogLevel(const.TraceLogLevel.LOG_ERROR)
lib.SetConfigFlags(const.ConfigFlags.FLAG_MSAA_4X_HINT)
lib.SetConfigFlags(const.ConfigFlags.FLAG_VSYNC_HINT)
lib.SetConfigFlags(const.ConfigFlags.FLAG_WINDOW_RESIZABLE)

lib.InitWindow(screenWidth, screenHeight, "Kinemium Engine")
--lib.SetWindowState(const.ConfigFlags.FLAG_BORDERLESS_WINDOWED_MODE)

lib.SetTargetFPS(0)
--raylib.r3d.lib.R3D_Init(raylib.lib.GetRenderWidth(), raylib.lib.GetRenderHeight(), 0)
-- R3D CMAKE
--cmake .. -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_COMPILER=cl -DCMAKE_BUILD_TYPE=Release -DR3D_RAYLIB_VENDORED=ON -DR3D_ASSIMP_VENDORED=ON -DR3D_BUILD_EXAMPLES=ON -DR3D_BUILD_DOCS=OFF

local engineIcon = lib.LoadImage("./src/assets/icon/icon.png")
lib.SetWindowIcon(engineIcon)
lib.InitAudioDevice()
local guiBlur = blurmod.Init(lib.GetRenderWidth(), lib.GetRenderHeight())

-- TEXTURES
local UI_TEXTURE = raylib.lib.LoadRenderTexture(lib.GetRenderWidth(), lib.GetRenderHeight())

-- LOAD CAMERA
local camera = structs.Camera3D:new({
	position = cameraPos,
	target = vector.create(0.0, 0.0, 0.0),
	up = vector.create(0.0, 1.0, 0.0),
	fovy = 70.0,
	projection = const.CameraProjection.CAMERA_PERSPECTIVE,
})

local activeCamera = camera

local function readRayCollision(collisionBuffer)
	-- RayCollision struct layout:
	-- { hit = u8 }        - offset 0, size 1
	-- { distance = float } - offset 4, size 4 (padded to 4-byte alignment)
	-- { point = Vector3 }  - offset 8, size 12
	-- { normal = Vector3 } - offset 20, size 12

	local hit = buffer.readu8(collisionBuffer, 0)
	local distance = buffer.readf32(collisionBuffer, 4)

	-- Read point Vector3 (x, y, z)
	local pointX = buffer.readf32(collisionBuffer, 8)
	local pointY = buffer.readf32(collisionBuffer, 12)
	local pointZ = buffer.readf32(collisionBuffer, 16)

	-- Read normal Vector3 (x, y, z)
	local normalX = buffer.readf32(collisionBuffer, 20)
	local normalY = buffer.readf32(collisionBuffer, 24)
	local normalZ = buffer.readf32(collisionBuffer, 28)

	return {
		hit = hit,
		distance = distance,
		point = vector.create(pointX, pointY, pointZ),
		normal = vector.create(normalX, normalY, normalZ),
	}
end

local function getNormalFace(normal)
	local absX = math.abs(normal.x)
	local absY = math.abs(normal.y)
	local absZ = math.abs(normal.z)

	if absX > absY and absX > absZ then
		if normal.x > 0 then
			return Enum.NormalId.Right
		else
			return Enum.NormalId.Left
		end
	elseif absY > absX and absY > absZ then
		if normal.y > 0 then
			return Enum.NormalId.Top
		else
			return Enum.NormalId.Bottom
		end
	else
		if normal.z > 0 then
			return Enum.NormalId.Front
		else
			return Enum.NormalId.Back
		end
	end
end

local mouseConfig = { TargetFilter = { Kinemium_camera } }

local function getMouseRay()
	local mousePos = raylib.lib.GetMousePosition()
	local ray = raylib.lib.GetScreenToWorldRay(mousePos, camera)

	local closestCollision = nil
	local closestDistance = math.huge
	local closestPart = nil

	for _, part in pairs(partRegistry) do
		part = part()

		if not part or not part._mesh then
			continue
		end

		local shouldSkip = false
		for _, filtered in ipairs(mouseConfig.TargetFilter) do
			if part == filtered then
				shouldSkip = true
				break
			end
			if part.Parent == filtered then
				shouldSkip = true
				break
			end
			local ancestor = part.Parent
			while ancestor do
				if ancestor == filtered then
					shouldSkip = true
					break
				end
				ancestor = ancestor.Parent
			end
			if shouldSkip then
				break
			end
		end

		if shouldSkip then
			part.MouseOverObject = false
			continue
		end

		local pos = vector.create(part.Position.X, part.Position.Y, part.Position.Z)
		local scale = vector.create(part.Size.X, part.Size.Y, part.Size.Z)
		local axis, angle = EulerToAxisAngleRad(part.Orientation or part.Rotation)
		local scaleMatrix = raylib.lib.MatrixScale(scale.x, scale.y, scale.z)
		local rotateMatrix = raylib.lib.MatrixRotate(axis, angle)
		local translateMatrix = raylib.lib.MatrixTranslate(pos.x, pos.y, pos.z)
		local transform = raylib.lib.MatrixMultiply(scaleMatrix, rotateMatrix)
		transform = raylib.lib.MatrixMultiply(transform, translateMatrix)

		local collision = raylib.lib.GetRayCollisionMesh(ray, part._mesh, transform)
		collision = readRayCollision(collision)

		if collision.hit == 1 and collision.distance < closestDistance then
			closestDistance = collision.distance
			closestCollision = collision
			closestPart = part
		end

		part.MouseOverObject = false
	end

	if closestPart and closestCollision then
		closestPart.MouseOverObject = true
		mouseProperties = {
			target = closestPart,
			Target = closestPart,
			TargetSurface = getNormalFace(closestCollision.normal),
			Hit = CFrame.new(closestCollision.point.x, closestCollision.point.y, closestCollision.point.z),
			hit = CFrame.new(closestCollision.point.x, closestCollision.point.y, closestCollision.point.z),
		}
		return true, mouseProperties
	end
end

local function mouseOverVector3(point, size)
	local mousePos = raylib.lib.GetMousePosition()
	local ray = raylib.lib.GetScreenToWorldRay(mousePos, camera)

	local mesh = raylib.lib.GenMeshCube(size, size, size)

	local scaleMatrix = raylib.lib.MatrixScale(1, 1, 1)
	local rotateMatrix = raylib.lib.MatrixRotate(vector.create(0, 1, 0), 0) -- no rotation
	local translateMatrix = raylib.lib.MatrixTranslate(point.x, point.y, point.z)
	local transform = raylib.lib.MatrixMultiply(scaleMatrix, rotateMatrix)
	transform = raylib.lib.MatrixMultiply(transform, translateMatrix)

	local collisionBuffer = raylib.lib.GetRayCollisionMesh(ray, mesh, transform)
	local collision = readRayCollision(collisionBuffer)

	raylib.lib.UnloadMesh(mesh)

	if collision.hit == 1 then
		mouseProperties = {
			Hit = CFrame.new(point.x, point.y, point.z),
			hit = CFrame.new(point.x, point.y, point.z),
		}
		return true, mouseProperties
	end

	return false
end

local viewport = lib.LoadRenderTexture(screenWidth, screenHeight)

local runtimelib

runtimelib = {
	lib = lib,
	drawModel = meshlib.drawModel,
	loadMaterialOnModel = meshlib.loadMaterialOnModel,
	LoadShader = shader.LoadShader,
	structs = structs,
	const = const,
	blur = guiBlur,
	time = time,
	GetFont = function(name)
		if fontRegistry[name] then
			return fontRegistry[name]
		end
	end,
	SetMouseProperties = function(data)
		mouseProperties = data
	end,
	gbSet = function(property, value)
		global_registry[property] = value
	end,

	gbGet = function(property)
		return global_registry[property]
	end,
}

local function step(time)
	--lib.SetWindowState(const.ConfigFlags.FLAG_BORDERLESS_WINDOWED_MODE)
	local activeLights = {}
	local delta = lib.GetFrameTime()
	mainSignal:Fire("PreRender", delta)
	mainSignal:Fire("RenderStepped", delta)

	getMouseRay()

	local runtimeMouse = {
		position = Vector2.new(lib.GetMouseX(), lib.GetMouseY()),
		delta = lib.GetMouseDelta(),
		mouse_wheel_move = lib.GetMouseWheelMove(),
		mouse_wheel_delta = lib.GetMouseWheelMoveV(),
		Button1Down = lib.IsMouseButtonDown(0) == 1,
		Button1Pressed = lib.IsMouseButtonPressed(0) == 1,
		Button1Released = lib.IsMouseButtonReleased(0) == 1,
		Button2Down = lib.IsMouseButtonDown(1) == 1,
		Button2Pressed = lib.IsMouseButtonPressed(1) == 1,
		Button2Released = lib.IsMouseButtonReleased(1) == 1,
		Button3Down = lib.IsMouseButtonDown(2) == 1,
		Button3Pressed = lib.IsMouseButtonPressed(2) == 1,
		Button3Released = lib.IsMouseButtonReleased(2) == 1,

		-- cursor states
		is_cursor_hidden = lib.IsCursorHidden(),
		is_cursor_inbounds = lib.IsCursorOnScreen(),
	}
	for prop, value in pairs(mouseProperties) do
		runtimeMouse[prop] = value
	end
	mainSignal:Fire("MouseData", runtimeMouse)

	time += delta

	if raylib.lib.IsWindowResized() == 1 then
		UI_TEXTURE = raylib.lib.LoadRenderTexture(lib.GetRenderWidth(), lib.GetRenderHeight())
	end

	local cameraPosition = freecam.Update(camera, delta, Kinemium_camera)

	for name, keycode in pairs(const.KeyboardKey) do
		if lib.IsKeyPressed(keycode) == 1 then
			mainSignal:Fire("Pressed", keycode)
		end
		if lib.IsKeyDown(keycode) == 1 then
			mainSignal:Fire("IsKeyDown", keycode)
		end
		if lib.IsKeyReleased(keycode) == 1 then
			mainSignal:Fire("IsKeyReleased", keycode)
		end
		if lib.IsKeyUp(keycode) == 1 then
			mainSignal:Fire("IsKeyUp", keycode)
		end

		local mouseDelta = lib.GetMouseDelta()
		if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
			mainSignal:Fire("MouseMoved", mouseDelta)
		end

		local wheel = lib.GetMouseWheelMove()
		if wheel ~= 0 then
			mainSignal:Fire("MouseWheel", wheel)
		end
	end

	--lib.BeginTextureMode(viewport)
	lib.BeginDrawing()

	for _, callback in pairs(callbackStep) do
		callback(lib, delta)
	end

	if game and game.Dimension == Enum.Dimension["3D"] then
		guiBlur:BeginCapture()
		lib.BeginMode3D(activeCamera)
		lib.ClearBackground(const.BLUE)
		lib.rlEnableBackfaceCulling()
		mainSignal:Fire("Begin3D")

		for _, v in pairs(renderPool3d) do
			v(runtimelib)
		end

		mainSignal:Fire("RenderClouds")

		lib.rlDisableBackfaceCulling()
		lib.EndMode3D()
		mainSignal:Fire("End3D")

		guiBlur:EndCapture()
	end
	--lib.EndTextureMode()

	lib.ClearBackground(const.BLACK)

	guiBlur:ApplyBlur()
	guiBlur:DrawUnblurred(const.WHITE)
	mainSignal:Fire("PreGuiRender")

	for _, gui in pairs(guiRegistry) do
		-- {render = function(), object = function()}
		gui.render(lib, gui.object(), time, structs, runtimelib)
	end

	for _, v in pairs(renderPool2d) do
		lib.BeginTextureMode(UI_TEXTURE)
		lib.ClearBackground(const.BLANK)
		v(runtimelib)
		lib.EndTextureMode()
	end

	mainSignal:Fire("GuiRender")

	table.clear(activeLights)

	lib.DrawTextureRec(
		bufferUtils.extract.texture(UI_TEXTURE),
		structs.Rectangle:new({ x = 0, y = 0, width = lib.GetRenderWidth(), height = -lib.GetRenderHeight() }),
		vector.create(0, 0),
		const.WHITE
	)
	lib.EndDrawing()
	mainSignal:Fire("Heartbeat", delta)

	task.wait(0)
end

local function run()
	local time = 0.0

	while lib.WindowShouldClose() == 0 do
		step(time)
	end

	for shaderName, _ in pairs(activeShaders) do
		shader.UnloadShader(shaderName)
	end
end

return {
	Signal = mainSignal,
	AddToRegistry = function(data)
		table.insert(partRegistry, data)
		mainSignal:Fire("AddedPartToRenderPool", data())
	end,
	GetPool3D = function()
		local results = {}

		for _, part in pairs(partRegistry) do
			local data = part()
			table.insert(results, data)
		end

		return results
	end,
	DatamodelObject = function(object)
		game = object
	end,
	Step = step,
	get2DCount = function()
		return #guiRegistry
	end,
	AddToGuiRenderingPool = function(object, renderFn)
		table.insert(guiRegistry, {
			render = renderFn,
			object = object,
		})
		mainSignal:Fire("AddedGuiToRenderPool", object())
	end,
	Run = run,
	lib = lib,
	camera = camera,
	const = const,
	structs = structs,

	-- camera Instance
	Kinemium_camera = Kinemium_camera,

	-- Mesh API
	mesh = meshlib,
	runtimelib = runtimelib,

	-- 3DHook
	Add3DStack = function(v)
		table.insert(renderPool3d, v)
	end,

	Add2DStack = function(v)
		table.insert(renderPool2d, v)
	end,

	add = function(self, v)
		table.insert(callbackStep, v)
	end,

	shader = shader,
	materialList = materialList,

	-- graphics
	blur = guiBlur,

	-- Font
	LoadFont = function(name, fontPath)
		local buf = lib.LoadFontEx(fontPath, 100, nil, 0)
		fontRegistry[name] = buf
		return buf
	end,

	GetFont = function(name)
		if fontRegistry[name] then
			return fontRegistry[name]
		end
	end,

	UnloadFont = function(name)
		if fontRegistry[name] then
			lib.UnloadFont(fontRegistry[name])
		end
	end,

	-- Global Registry
	gbSet = function(property, value)
		global_registry[property] = value
	end,

	gbGet = function(property)
		return global_registry[property]
	end,

	ChangeActiveCamera = function(camera)
		activeCamera = camera
	end,

	-- Lighting
	SetLightingService = function(service)
		lighting = service
	end,
	Viewport = viewport,
	mouseOverVector3 = mouseOverVector3,
	meshlib = meshlib,
	skybox = skybox,
	shadowSystem = shadowSystem,
	readRayCollision = readRayCollision,

	-- Mouse
	SetMouseTargetFilter = function() end,
}
