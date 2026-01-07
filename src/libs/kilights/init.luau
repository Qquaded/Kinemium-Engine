--!strict
--!optimize 2
--!native

local raylib = require("@raylib")

type int = number
type float = number

local Vector3 = raylib.structs.Vector3
local Color = raylib.structs.Color
local Shader = raylib.structs.Shader

local bufferUtils = require("@BufferUtils")

local MAX_LIGHTS = 64

export type LightType = number
local LIGHT_DIRECTIONAL: LightType = 0
local LIGHT_POINT: LightType = 1

local ShadowMap = raylib.lib.LoadRenderTexture(1024, 1024)

export type Light = {
	type: int,
	enabled: boolean,
	position: Vector3,
	target: Vector3,
	color: Color,
	attenuation: float,
	enabledLoc: int,
	typeLoc: int,
	positionLoc: int,
	targetLoc: int,
	colorLoc: int,
	attenuationLoc: int,
}

type Shader = raylib.Shader
type Matrix = raylib.Matrix
type RenderTexture = raylib.RenderTexture

local lightsCount = 0

local function UpdateLightValues(shader: Shader, light: Light)
	local enabledBuf = buffer.create(4)
	buffer.writei32(enabledBuf, 0, if light.enabled then 1 else 0)

	local typeBuf = buffer.create(4)
	buffer.writei32(typeBuf, 0, light.type)

	local position = vector.create(light.position.x, light.position.y, light.position.z)
	local target = vector.create(light.target.x, light.target.y, light.target.z)

	local colorBuf = buffer.create(16)
	buffer.writef32(colorBuf, 0, light.color.r / 255.0)
	buffer.writef32(colorBuf, 4, light.color.g / 255.0)
	buffer.writef32(colorBuf, 8, light.color.b / 255.0)
	buffer.writef32(colorBuf, 12, light.color.a / 255.0)

	local attenuationBuf = buffer.create(4)
	buffer.writef32(attenuationBuf, 0, light.attenuation)

	local shader_types = raylib.const.ShaderUniformDataType
	raylib.lib.SetShaderValue(shader, light.enabledLoc, enabledBuf, shader_types.SHADER_UNIFORM_INT)
	raylib.lib.SetShaderValue(shader, light.typeLoc, typeBuf, shader_types.SHADER_UNIFORM_INT)
	raylib.lib.SetShaderValue(shader, light.positionLoc, position, shader_types.SHADER_UNIFORM_VEC3)
	raylib.lib.SetShaderValue(shader, light.targetLoc, target, shader_types.SHADER_UNIFORM_VEC3)
	raylib.lib.SetShaderValue(shader, light.colorLoc, colorBuf, shader_types.SHADER_UNIFORM_VEC4)
	raylib.lib.SetShaderValue(shader, light.attenuationLoc, attenuationBuf, shader_types.SHADER_UNIFORM_FLOAT)
end

local function CreateLight(
	lightType: LightType,
	position: Vector3,
	target: Vector3,
	color: typeof(Color),
	shader: typeof(Shader)
): Light
	local light: Light = {
		type = lightType,
		enabled = false,
		position = position,
		target = target,
		color = color,
		attenuation = 0,
		enabledLoc = -1,
		typeLoc = -1,
		positionLoc = -1,
		targetLoc = -1,
		colorLoc = -1,
		attenuationLoc = -1,
	}

	if lightsCount < MAX_LIGHTS then
		light.enabled = true
		light.enabledLoc = raylib.lib.GetShaderLocation(shader, `lightEnabled[{lightsCount}]`)
		light.typeLoc = raylib.lib.GetShaderLocation(shader, `lightType[{lightsCount}]`)
		light.positionLoc = raylib.lib.GetShaderLocation(shader, `lightPosition[{lightsCount}]`)
		light.targetLoc = raylib.lib.GetShaderLocation(shader, `lightTarget[{lightsCount}]`)
		light.colorLoc = raylib.lib.GetShaderLocation(shader, `lightColor[{lightsCount}]`)
		light.attenuationLoc = raylib.lib.GetShaderLocation(shader, `lightAttenuation[{lightsCount}]`)

		UpdateLightValues(shader, light)

		lightsCount += 1
	end

	return light
end

local function ResetLights()
	lightsCount = 0
end

local function getDefaultShader()
	return raylib.lib.LoadShader("./src/libs/kilights/shaders/light.vs", "./src/libs/kilights/shaders/light.fs")
end

local function getDepthShader()
	return raylib.lib.LoadShader("./src/libs/kilights/shaders/depth.vs", "./src/libs/kilights/shaders/depth.fs")
end

local function getShadowShader()
	return raylib.lib.LoadShader("./src/libs/kilights/shaders/shadow.vs", "./src/libs/kilights/shaders/shadow.fs")
end

local function GetLightsCount(): number
	return lightsCount
end

local function Begin(self, shader)
	raylib.lib.BeginShaderMode(shader)
end

local function End(self)
	raylib.lib.EndShaderMode()
end

local function BeginShadowMode(self)
	raylib.lib.BeginTextureMode(ShadowMap)
end

local function BindShadow(self, shader)
	raylib.lib.SetShaderValueTexture(
		shader,
		raylib.lib.GetShaderLocation(shader, "shadowMap"),
		bufferUtils.extract.texture(ShadowMap)
	)
end

local function EndShadowMode(self)
	raylib.lib.EndTextureMode()
end

local function SetCameraPos(shader, camera)
	local viewPosLoc = raylib.lib.GetShaderLocation(shader, "viewPos")
	local camPos = zune.mem.toVector3(camera, 0)
	local shader_types = raylib.const.ShaderUniformDataType
	raylib.lib.SetShaderValue(shader, viewPosLoc, camPos, shader_types.SHADER_UNIFORM_VEC3)
end

local function SetAmbientColor(color, shader)
	local ambientColor = buffer.create(16)
	buffer.writef32(ambientColor, 0, color.r) -- r
	buffer.writef32(ambientColor, 4, color.g) -- g
	buffer.writef32(ambientColor, 8, color.b) -- b
	buffer.writef32(ambientColor, 12, color.a) -- a

	local ambientLoc = raylib.lib.GetShaderLocation(shader, "ambient")
	raylib.lib.SetShaderValue(shader, ambientLoc, ambientColor, raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4)
end

-- Math helpers
local function vec3_cross(a, b)
	return vector.create(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

local function vec3_normalize(v)
	local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
	if len == 0 then
		return vector.create(0, 0, 0)
	end
	return vector.create(v.x / len, v.y / len, v.z / len)
end

local function vec3_dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

local function sub_vec(a, b)
	return vector.create(a.x - b.x, a.y - b.y, a.z - b.z)
end

local function MatrixLookAt(eye, target, up)
	local z = sub_vec(eye, target)
	z = vec3_normalize(z)

	local x = vec3_cross(up, z)
	x = vec3_normalize(x)

	local y = vec3_cross(z, x)
	y = vec3_normalize(y) -- Should be normalized already if strictly orthogonal

	-- Matrix is initialized to identity by default usually, but we set all fields
	-- Raylib Matrix is:
	-- m0 m4 m8 m12
	-- m1 m5 m9 m13 ...

	return raylib.structs.Matrix:new({
		m0 = x.x,
		m4 = x.y,
		m8 = x.z,
		m12 = -vec3_dot(x, eye),
		m1 = y.x,
		m5 = y.y,
		m9 = y.z,
		m13 = -vec3_dot(y, eye),
		m2 = z.x,
		m6 = z.y,
		m10 = z.z,
		m14 = -vec3_dot(z, eye),
		m3 = 0,
		m7 = 0,
		m11 = 0,
		m15 = 1,
	})
end

local function MatrixOrtho(left, right, bottom, top, near, far)
	local rl = right - left
	local tb = top - bottom
	local fn = far - near

	return raylib.structs.Matrix:new({
		m0 = 2.0 / rl,
		m4 = 0,
		m8 = 0,
		m12 = -(right + left) / rl,
		m1 = 0,
		m5 = 2.0 / tb,
		m9 = 0,
		m13 = -(top + bottom) / tb,
		m2 = 0,
		m6 = 0,
		m10 = -2.0 / fn,
		m14 = -(far + near) / fn,
		m3 = 0,
		m7 = 0,
		m11 = 0,
		m15 = 1,
	})
end

local function MatrixMultiply(left, right)
	local result = raylib.structs.Matrix:new({})

	result.m0 = left.m0 * right.m0 + left.m4 * right.m1 + left.m8 * right.m2 + left.m12 * right.m3
	result.m4 = left.m0 * right.m4 + left.m4 * right.m5 + left.m8 * right.m6 + left.m12 * right.m7
	result.m8 = left.m0 * right.m8 + left.m4 * right.m9 + left.m8 * right.m10 + left.m12 * right.m11
	result.m12 = left.m0 * right.m12 + left.m4 * right.m13 + left.m8 * right.m14 + left.m12 * right.m15

	result.m1 = left.m1 * right.m0 + left.m5 * right.m1 + left.m9 * right.m2 + left.m13 * right.m3
	result.m5 = left.m1 * right.m4 + left.m5 * right.m5 + left.m9 * right.m6 + left.m13 * right.m7
	result.m9 = left.m1 * right.m8 + left.m5 * right.m9 + left.m9 * right.m10 + left.m13 * right.m11
	result.m13 = left.m1 * right.m12 + left.m5 * right.m13 + left.m9 * right.m14 + left.m13 * right.m15

	result.m2 = left.m2 * right.m0 + left.m6 * right.m1 + left.m10 * right.m2 + left.m14 * right.m3
	result.m6 = left.m2 * right.m4 + left.m6 * right.m5 + left.m10 * right.m6 + left.m14 * right.m7
	result.m10 = left.m2 * right.m8 + left.m6 * right.m9 + left.m10 * right.m10 + left.m14 * right.m11
	result.m14 = left.m2 * right.m12 + left.m6 * right.m13 + left.m10 * right.m14 + left.m14 * right.m15

	result.m3 = left.m3 * right.m0 + left.m7 * right.m1 + left.m11 * right.m2 + left.m15 * right.m3
	result.m7 = left.m3 * right.m4 + left.m7 * right.m5 + left.m11 * right.m6 + left.m15 * right.m7
	result.m11 = left.m3 * right.m8 + left.m7 * right.m9 + left.m11 * right.m10 + left.m15 * right.m11
	result.m15 = left.m3 * right.m12 + left.m7 * right.m13 + left.m11 * right.m14 + left.m15 * right.m15

	return result
end

local function CalculateSunShadowMatrix(cameraPos, sunDirection)
	local shadowSize = 100.0
	local nearPlane = 0.1
	local farPlane = 500.0

	local lightViewPos = vector.create(
		cameraPos.x + sunDirection.x * 100.0,
		cameraPos.y + sunDirection.y * 100.0,
		cameraPos.z + sunDirection.z * 100.0
	)

	local targetPos = vector.create(cameraPos.x, cameraPos.y, cameraPos.z)
	local up = vector.create(0, 1, 0)

	local view = MatrixLookAt(lightViewPos, targetPos, up)
	local projection = MatrixOrtho(-shadowSize, shadowSize, -shadowSize, shadowSize, nearPlane, farPlane)

	return MatrixMultiply(view, projection)
end

local function UpdateShadowUniforms(shader, shadowMatrix)
	local lightMVPLoc = raylib.lib.GetShaderLocation(shader, "lightMVP")
	if lightMVPLoc ~= -1 then
		raylib.lib.SetShaderValueMatrix(shader, lightMVPLoc, shadowMatrix)
	end
	-- note: texture binding is handled by calling BindShadow/BeginShadowMode or manually binding.
	-- We'll assume the texture is bound to unit 1 for now if we extend, but usually
	-- we need to set the uniform 'shadowMap' to the texture unit index.
	local shadowMapLoc = raylib.lib.GetShaderLocation(shader, "shadowMap")
	if shadowMapLoc ~= -1 then
		-- Set to texture unit 1 (TODO: Ensure we bind the texture to unit 1)
		-- raylib.lib.SetShaderValue(shader, shadowMapLoc, ...)

		-- Since raylib abstracts texture units somewhat, we might rely on the order of drawing
		-- or explicit SetShaderValueTexture which sets the texture to a slot.
		-- raylib.lib.SetShaderValueTexture(shader, shadowMapLoc, shadowMapTexture)
	end
end

return {
	MAX_LIGHTS = MAX_LIGHTS,
	LIGHT_DIRECTIONAL = LIGHT_DIRECTIONAL,
	LIGHT_POINT = LIGHT_POINT,

	getDefaultShader = getDefaultShader,
	getDepthShader = getDepthShader,
	getShadowShader = getShadowShader,

	CreateLight = CreateLight,
	UpdateLightValues = UpdateLightValues,
	ResetLights = ResetLights,
	GetLightsCount = GetLightsCount,
	SetAmbientColor = SetAmbientColor,
	SetCameraPos = SetCameraPos,

	Begin = Begin,
	End = End,

	-- shadow
	BeginShadowMode = BeginShadowMode,
	BindShadow = BindShadow,
	EndShadowMode = EndShadowMode,

	CalculateSunShadowMatrix = CalculateSunShadowMatrix,
	UpdateShadowUniforms = UpdateShadowUniforms,
}
