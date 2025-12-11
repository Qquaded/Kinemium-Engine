--!optimize 2
--!native

local raylib = require("./external/raylib")
--local raygui = require("@raygui")

local signal = require("@Kinemium.signal")
local mb = require("./renderer/mesh")
local texture = require("./renderer/texture")
local Vector2 = require("@Vector2")
local shader3d = require("./renderer/shader")
local skybox = require("./renderer/skybox")
local mainSignal = signal.new()

local CFrame = require("@CFrame")
local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local camera_addon = require("@Camera")

-- comment this until i find a way to make the shitty dll error stop
-- help me pls.........
-- please speed i need this
--local r3d = require("@r3d")

local Kinemium_camera = Instance.new("Camera")
camera_addon.callback(Kinemium_camera)
Kinemium_camera.Name = "CurrentCamera"

local loadedMaterials = {}
local meshlib = {}
local fontRegistry = {}

local renderPool3d = {}
local renderPool2d = {}
local shaderPool2d = {}

local global_registry = {}

local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs
local task = zune.task
local ffi = zune.ffi

local screenWidth = 1800
local screenHeight = 900

local txtureMethods = texture(lib)
local materialList = txtureMethods.GetMaterials()

local MOVE_SPEED = 10.0
local MOUSE_SENSITIVITY = 0.003
local FOV = 70

Kinemium_camera.FieldOfView = FOV

local cameraPos = vector.create(0.0, 5.0, 10.0)
local yaw = 0.0
local pitch = 0.0

local activeShaders = {}
local shaderUniforms = {}
local lighting = nil

local function float_ptr(value: number): FFIPointer
	local ptr = ffi.create(ffi.types.float)
	ptr:writef32(0, value)
	return ptr
end

local function vec3_ptr(x: number, y: number, z: number): FFIPointer
	local ptr = ffi.create(ffi.types.float:array(3))
	ptr:writef32(0, x)
	ptr:writef32(4, y)
	ptr:writef32(8, z)
	return ptr
end

local function loopshader(callback)
	for shaderName, shader in pairs(activeShaders) do
		callback(shaderName, shader)
	end
end

local function Vector3RotateByAxisAngle(v: raylib.Vector3, axis: raylib.Vector3, angle: number): raylib.Vector3
	local length = vector.magnitude(axis)
	if length == 0.0 then
		length = 1.0
	end
	local ilength = 1.0 / length
	axis *= vector.create(ilength, ilength, ilength)

	angle /= 2.0
	local a = math.sin(angle)
	local w = vector.create(axis.x * a, axis.y * a, axis.z * a)
	a = math.cos(angle)

	local wv = vector.create(w.y * v.z - w.z * v.y, w.z * v.x - w.x * v.z, w.x * v.y - w.y * v.x)
	local wwv = vector.create(w.y * wv.z - w.z * wv.y, w.z * wv.x - w.x * wv.z, w.x * wv.y - w.y * wv.x)

	a *= 2.0
	wv *= a
	wwv *= 2.0

	return v + wv + wwv
end

local function loadMaterialOnModel(model, texture, const)
	local materials = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("materials"), 8))

	-- Set texture
	local maps = materials:readptr(structs.Material:offset("maps"))
	maps:write(const or 0, texture, 0, structs.Texture:size())

	loopshader(function(shaderName, shader)
		materials:write(structs.Material:offset("shader"), shader, 0, structs.Shader:size())
	end)
end

local function UpdateFreecam(camera: raylib.Camera3D, delta: number)
	-- Only update camera rotation when right mouse button is held
	if lib.IsMouseButtonPressed(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.DisableCursor()
	end

	if lib.IsMouseButtonReleased(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.EnableCursor()
	end

	if lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		local mouseDelta = lib.GetMouseDelta()
		yaw -= mouseDelta.x * MOUSE_SENSITIVITY
		pitch += mouseDelta.y * MOUSE_SENSITIVITY

		pitch = math.clamp(pitch, -math.pi / 2 + 0.01, math.pi / 2 - 0.01)
	end

	local forward = vector.create(math.sin(yaw) * math.cos(pitch), -math.sin(pitch), math.cos(yaw) * math.cos(pitch))
	forward = vector.normalize(forward)

	local up = vector.create(0.0, 1.0, 0.0)
	local right = vector.cross(forward, up)
	right = vector.normalize(right)

	local moveSpeed = MOVE_SPEED * delta
	local sideway = lib.IsKeyDown(const.KeyboardKey.KEY_D) - lib.IsKeyDown(const.KeyboardKey.KEY_A)
	local forwardInput = lib.IsKeyDown(const.KeyboardKey.KEY_W) - lib.IsKeyDown(const.KeyboardKey.KEY_S)
	local vertical = lib.IsKeyDown(const.KeyboardKey.KEY_SPACE) - lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT)

	cameraPos += forward * (forwardInput * moveSpeed)
	cameraPos += right * (sideway * moveSpeed)
	cameraPos += up * (vertical * moveSpeed)

	local wheelMove = lib.GetMouseWheelMove()
	if wheelMove ~= 0 then
		cameraPos += forward * (wheelMove * 5.0) -- 5 units per scroll step
	end

	local target = cameraPos + forward
	zune.mem.writeVector3(camera, 0, cameraPos)
	zune.mem.writeVector3(camera, 12, target)
	buffer.writef32(camera, structs.Camera3D:offset("fovy"), Kinemium_camera.FieldOfView)

	local lookAt =
		CFrame.lookAt(Vector3.new(cameraPos.x, cameraPos.y, cameraPos.z), Vector3.new(target.x, target.y, target.z))

	Kinemium_camera.CFrame = lookAt
	Kinemium_camera.Position = Vector3.new(cameraPos.x, cameraPos.y, cameraPos.z)
end

local partRegistry = {}
local guiRegistry = {}

lib.InitWindow(screenWidth, screenHeight, "Kinemium Engine")
lib.SetWindowState(const.ConfigFlags.FLAG_WINDOW_RESIZABLE)
lib.SetWindowState(const.ConfigFlags.FLAG_MSAA_4X_HINT)

lib.SetTargetFPS(0)

local engineIcon = lib.LoadImage("./src/assets/icon/icon.png")
lib.SetWindowIcon(engineIcon)
--lib.DisableCursor()

skybox.Load()
meshlib = mb(lib)

local material_index = 0
for material_name, material_path in pairs(materialList) do
	local texture = lib.LoadTexture(material_path)
	local default = lib.LoadMaterialDefault()
	lib.SetMaterialTexture(default, 0, texture)

	loadedMaterials[material_name] = {
		index = material_index,
		material = default,
		texture = texture,
	}
	material_index += 1
	print(`Loaded custom material: {material_name}`)
end

local audioDevice = lib.InitAudioDevice()

local preloadedMeshes = meshlib.PreloadStandardMeshes()

local camera = structs.Camera3D:new({
	position = cameraPos,
	target = vector.create(0.0, 0.0, 0.0),
	up = vector.create(0.0, 1.0, 0.0),
	fovy = 70.0,
	projection = const.CameraProjection.CAMERA_PERSPECTIVE,
})

local function cacheCommonLocations(shaderName)
	local names = {
		"time",
		"lightPos",
		"viewPos",
		"lightColor",
		"texture0",
		"mvp",
		"matModel",
		"matNormal",
		"colDiffuse",
		"constant",
		"linear",
		"quadratic",
		"globalAmbient",
		"brightness",
		"dirLightDir",
		"dirLightColor",
		"pointLightCount",
	}
	for _, n in ipairs(names) do
		shaderUniforms[shaderName][n] = lib.GetShaderLocation(activeShaders[shaderName], n)
		print(`Shader uniform "{n}" location: {shaderUniforms[shaderName][n]}`) -- DEBUG
	end
end

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function LoadShader(shaderName: string, vertexPath: string?, fragmentPath: string?)
	local vertexCode = vertexPath and zune.fs.readFile(vertexPath) or ffi.null
	local fragmentCode = fragmentPath and zune.fs.readFile(fragmentPath) or ffi.null

	local shader = lib.LoadShaderFromMemory(vertexCode, fragmentCode)
	activeShaders[shaderName] = shader
	shaderUniforms[shaderName] = {}

	if lib.IsShaderValid(shader) == 0 then
		print(`Loaded shader {shaderName} is INVALID`)
	end

	cacheCommonLocations(shaderName)

	print(`Loaded shader: {shaderName}`)
	return shader
end

local function LoadShaderCode(shaderName: string, vertex: string?, fragment: string?)
	local vertexCode = vertex or ffi.null
	local fragmentCode = fragment or ffi.null

	local shader = lib.LoadShaderFromMemory(vertexCode, fragmentCode)
	activeShaders[shaderName] = shader
	shaderUniforms[shaderName] = {}

	if lib.IsShaderValid(shader) == 0 then
		print(`Loaded shader {shaderName} is INVALID`)
	end

	cacheCommonLocations(shaderName)

	print(`Loaded shader: {shaderName}`)
	return shader
end

local function GetShaderUniformLocation(shaderName: string, uniformName: string): number
	local shader = activeShaders[shaderName]
	if not shader then
		return -1
	end

	local location = lib.GetShaderLocation(shader, uniformName)
	shaderUniforms[shaderName][uniformName] = location
	return location
end

local function SetShaderUniform(shaderName: string, uniformName: string, value: any, uniformType: number)
	local shader = activeShaders[shaderName]
	if not shader then
		return
	end

	local location = shaderUniforms[shaderName][uniformName] or GetShaderUniformLocation(shaderName, uniformName)

	--[[
	if location == -1 then
		return
	end
	--]]

	local valuePtr
	if type(value) == "number" then
		valuePtr = float_ptr(value)
	elseif type(value) == "table" and #value == 3 then
		valuePtr = vec3_ptr(value[1], value[2], value[3])
	else
		valuePtr = value
	end

	lib.SetShaderValue(shader, location, valuePtr, uniformType)
end

local function UnloadShader(shaderName: string)
	local shader = activeShaders[shaderName]
	if shader then
		lib.UnloadShader(shader)
		activeShaders[shaderName] = nil
		shaderUniforms[shaderName] = nil
		print(`Unloaded shader: {shaderName}`)
	end
end

local function EulerToAxisAngleRad(euler: Vector3): (Vector3, number)
	local cx, sx = math.cos(euler.X / 2), math.sin(euler.X / 2)
	local cy, sy = math.cos(euler.Y / 2), math.sin(euler.Y / 2)
	local cz, sz = math.cos(euler.Z / 2), math.sin(euler.Z / 2)

	-- Quaternion multiplication: q = qz * qy * qx
	local qw = cz * cy * cx + sz * sy * sx
	local qx = cz * cy * sx - sz * sy * cx
	local qy = cz * sy * cx + sz * cy * sx
	local qz = sz * cy * cx - cz * sy * sx

	local angle = 2 * math.acos(math.clamp(qw, -1, 1))
	local s = math.sqrt(1 - qw * qw)
	if s < 0.0001 then
		-- If s is near zero, axis direction is arbitrary
		return vector.create(1, 0, 0), 0
	else
		return vector.create(qx / s, qy / s, qz / s), angle
	end
end

local function drawModel(model, part)
	local axis, angle = EulerToAxisAngleRad(part.Orientation or part.Rotation)

	-- Apply material texture
	if loadedMaterials[part.Material.Value] then
		local data = loadedMaterials[part.Material.Value]
		loadMaterialOnModel(model, data.texture)
	end

	lib.DrawModelEx(
		model,
		vector.create(part.Position.X, part.Position.Y, part.Position.Z),
		axis,
		angle,
		vector.create(part.Size.X, part.Size.Y, part.Size.Z),
		Color3ToRaylib(part.Color, part.Transparency)
	)
end

local function drawPart(part)
	if part.ClassName == "MeshPart" then
		local model = meshlib.GetModelRegistry()[part.MeshId]
		if model then
			drawModel(model, part)
		end
	else
		drawModel(preloadedMeshes[part.Shape.Value], part)
	end

	mainSignal:Fire("Rendered", part)
end

local function step(time)
	--lib.SetWindowState(const.ConfigFlags.FLAG_BORDERLESS_WINDOWED_MODE)
	local activeLights = {}
	local delta = lib.GetFrameTime()
	mainSignal:Fire("PreRender", delta)

	local runtimelib = {
		lib = lib,
		drawModel = drawModel,
		drawPart = drawPart,
		loadMaterialOnModel = loadMaterialOnModel,
		LoadShader = LoadShader,
		structs = structs,
		const = const,
		time = time,
		GetFont = function(name)
			if fontRegistry[name] then
				return fontRegistry[name]
			end
		end,
		gbSet = function(property, value)
			global_registry[property] = value
		end,

		gbGet = function(property)
			return global_registry[property]
		end,
	}

	mainSignal:Fire("RenderStepped", delta)
	mainSignal:Fire("MouseData", {
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
	})

	time += delta

	UpdateFreecam(camera, delta)

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

	lib.BeginDrawing()
	lib.BeginMode3D(camera)
	lib.ClearBackground(const.BLUE)
	lib.rlEnableBackfaceCulling()
	lib.rlEnableDepthTest()
	skybox.Draw(vector.create(0, 0, 0))

	for _, part in pairs(partRegistry) do
		local partData = part()
		if partData.BaseClass == "Kinemium.light" then
			table.insert(activeLights, {
				pos = { partData.Position.X, partData.Position.Y, partData.Position.Z },
				intensity = partData.Range,
				color = { partData.Color.R / 255, partData.Color.G / 255, partData.Color.B / 255 },
			})
		end
	end

	shader3d(lib, loopshader, lighting, const, cameraPos, activeLights, SetShaderUniform, time)

	for _, v in pairs(renderPool3d) do
		v(runtimelib)
	end

	for _, part in pairs(partRegistry) do
		local partData = part()
		if partData.BaseClass ~= "Kinemium.light" then
			drawPart(partData)
		end
	end

	lib.EndShaderMode()
	lib.rlDisableBackfaceCulling()
	lib.rlDisableDepthTest()

	lib.EndMode3D()

	for _, gui in pairs(guiRegistry) do
		-- {render = function(), object = function()}
		for _, shader2D in pairs(shaderPool2d) do
			lib.BeginShaderMode(shader2D)
		end
		gui.render(lib, gui.object(), time, structs, runtimelib)
		lib.EndShaderMode()
	end

	for _, v in pairs(renderPool2d) do
		v(runtimelib)
	end

	table.clear(activeLights)

	lib.DrawFPS(10, 10)

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
		UnloadShader(shaderName)
	end
end

return {
	Signal = mainSignal,
	AddToRegistry = function(data)
		table.insert(partRegistry, data)
		mainSignal:Fire("AddedPartToRenderPool", data())
	end,
	Step = step,
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

	-- Shader API
	LoadShader = LoadShader,
	UnloadShader = UnloadShader,
	SetShaderUniform = SetShaderUniform,
	GetShaderUniformLocation = GetShaderUniformLocation,
	GetActiveShaders = function()
		return activeShaders
	end,
	LoadShaderCode = LoadShaderCode,
	Add2DShader = function(shaderName: string, vertexPath: string?, fragmentPath: string?)
		local shader = LoadShader(shaderName, vertexPath, fragmentPath)
		if shader then
			table.insert(shaderPool2d, shader)
		end
	end,

	-- Mesh API
	mesh = meshlib,

	-- 3DHook
	Add3DStack = function(v)
		table.insert(renderPool3d, v)
	end,

	Add2DStack = function(v)
		table.insert(renderPool2d, v)
	end,

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

	-- Lighting
	SetLightingService = function(service)
		lighting = service
	end,
}
