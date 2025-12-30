--!strict
--!optimize 2
--!native

local raylib = require("@raylib")

type int = number
type float = number

local Vector3 = raylib.structs.Vector3
local Color = raylib.structs.Color
local Shader = raylib.structs.Shader

local MAX_LIGHTS = 64

export type LightType = number
local LIGHT_DIRECTIONAL: LightType = 0
local LIGHT_POINT: LightType = 1

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

local function GetLightsCount(): number
	return lightsCount
end

local function Begin(self, shader)
	raylib.lib.BeginShaderMode(shader)
end

local function End(self)
	raylib.lib.EndShaderMode()
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

return {
	MAX_LIGHTS = MAX_LIGHTS,
	LIGHT_DIRECTIONAL = LIGHT_DIRECTIONAL,
	LIGHT_POINT = LIGHT_POINT,

	getDefaultShader = getDefaultShader,

	CreateLight = CreateLight,
	UpdateLightValues = UpdateLightValues,
	ResetLights = ResetLights,
	GetLightsCount = GetLightsCount,
	SetAmbientColor = SetAmbientColor,
	SetCameraPos = SetCameraPos,

	Begin = Begin,
	End = End,
}
