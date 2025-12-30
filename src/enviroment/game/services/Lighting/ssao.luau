local ssao = {}

local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const

local ssaoShader
local blurShader
local ssaoUniforms = {}
local blurUniforms = {}

function ssao.Init()
	ssaoShader = lib.LoadShader("./src/assets/shaders/screen.vert", "./src/assets/shaders/ssao.frag")
	ssaoUniforms = {
		texDepth = lib.GetShaderLocation(ssaoShader, "uTexDepth"),
		texNormal = lib.GetShaderLocation(ssaoShader, "uTexNormal"),
		texKernel = lib.GetShaderLocation(ssaoShader, "uTexKernel"),
		texNoise = lib.GetShaderLocation(ssaoShader, "uTexNoise"),
		matInvProj = lib.GetShaderLocation(ssaoShader, "uMatInvProj"),
		matInvView = lib.GetShaderLocation(ssaoShader, "uMatInvView"),
		radius = lib.GetShaderLocation(ssaoShader, "uRadius"),
		bias = lib.GetShaderLocation(ssaoShader, "uBias"),
		intensity = lib.GetShaderLocation(ssaoShader, "uIntensity"),
	}

	blurShader = lib.LoadShader("./src/assets/shaders/screen.vert", "./src/assets/shaders/ssao_blur.frag")
	blurUniforms = {
		texSSAO = lib.GetShaderLocation(blurShader, "uTexSSAO"),
	}
end

function ssao.UpdateUniforms(camera, settings)
	local proj = lib.MatrixPerspective(70 * math.pi / 180, 16 / 9, 0.1, 1000)
	local invProj = lib.MatrixInvert(proj)
	local view = lib.GetCameraMatrix(camera)
	local invView = lib.MatrixInvert(view)

	lib.SetShaderValue(ssaoShader, ssaoUniforms.matInvProj, invProj, const.ShaderUniformDataType.SHADER_UNIFORM_MAT4)
	lib.SetShaderValue(ssaoShader, ssaoUniforms.matInvView, invView, const.ShaderUniformDataType.SHADER_UNIFORM_MAT4)
	lib.SetShaderValue(
		ssaoShader,
		ssaoUniforms.radius,
		settings.SSAORadius or 0.5,
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)
	lib.SetShaderValue(
		ssaoShader,
		ssaoUniforms.bias,
		settings.SSAOBias or 0.025,
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)
	lib.SetShaderValue(
		ssaoShader,
		ssaoUniforms.intensity,
		settings.SSAOIntensity or 1.0,
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)
end

function ssao.Render(depthTex, normalTex)
	lib.SetShaderValueTexture(ssaoShader, ssaoUniforms.texDepth, depthTex)
	lib.SetShaderValueTexture(ssaoShader, ssaoUniforms.texNormal, normalTex)

	lib.BeginShaderMode(ssaoShader)
	local quad = lib.GenMeshPlane(2, 2, 1, 1)
	lib.DrawMesh(quad, lib.LoadMaterialDefault(), lib.MatrixIdentity())
	lib.UnloadMesh(quad)
	lib.EndShaderMode()
end

function ssao.Unload()
	if ssaoShader then
		lib.UnloadShader(ssaoShader)
	end
	if blurShader then
		lib.UnloadShader(blurShader)
	end
end

return ssao
