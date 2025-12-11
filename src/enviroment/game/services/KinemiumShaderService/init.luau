local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local KinemiumShaderService = Instance.new("KinemiumShaderService")
KinemiumShaderService.ExplorerHidden = true

local ShaderAdded = signal.new()
local ShaderRemoved = signal.new()
local loaded = {}

KinemiumShaderService.InitRenderer = function(renderer, renderer_signal)
	KinemiumShaderService:SetProperties({
		ShaderAdded = ShaderAdded,
		ShaderRemoved = ShaderRemoved,
		LoadShader = function(shaderName: string, vertexPath: string?, fragmentPath: string?)
			if loaded[shaderName] then
				return
			end
			loaded[shaderName] = shaderName
			renderer.LoadShader(shaderName, vertexPath, fragmentPath)
			ShaderAdded:Fire(shaderName, vertexPath, fragmentPath)
		end,
		GetShaderUniformLocation = renderer.GetShaderUniformLocation,
		SetShaderUniform = renderer.SetShaderUniform,
		LoadShaderCode = renderer.LoadShaderCode,
		UnloadShader = function(shaderName: string)
			renderer.UnloadShader(shaderName)
			ShaderRemoved:Fire(shaderName)
		end,
	})
end

return KinemiumShaderService
