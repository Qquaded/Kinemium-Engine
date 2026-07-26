local Shader = {}
Shader.__index = Shader

local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local util = require("@kineshader")

function Shader.fromMemoryRaylib(vs, fs)
	local shader = adapter.lib.LoadShaderFromMemory(vs, fs)
	return Shader.new({ _shader = shader, _type = "raylib" })
end

function Shader.fromMemorySurface(glsl)
	local shader = r3d.lib.R3D_LoadSurfaceShaderFromMemory(glsl)
	return Shader.new({ _shader = shader, _type = "surface" })
end

function Shader.fromMemorySky(glsl)
	local shader = r3d.lib.R3D_LoadSkyShaderFromMemory(glsl)
	return Shader.new({ _shader = shader, _type = "sky" })
end

function Shader.fromMemoryScreen(glsl)
	local shader = r3d.lib.R3D_LoadScreenShaderFromMemory(glsl)
	return Shader.new({ _shader = shader, _type = "screen" })
end

function Shader.new(source)
	local self = setmetatable({}, Shader)

	self._vertex = source.vertex
	self._fragment = source.fragment
	self._type = source._type or "raylib"
	self._class = "shader"

	if source._shader then
		self._shader = source._shader
	elseif self._type == "raylib" then
		local vertex = source.vertex and zembed.AssetPath(source.vertex) or nil
		local fragment = source.fragment and zembed.AssetPath(source.fragment) or nil
		self._shader = adapter.lib.LoadShader(vertex, fragment)
	elseif self._type == "surface" then
		if source.glsl then
			self._shader = r3d.lib.R3D_LoadSurfaceShaderFromMemory(source.glsl)
		else
			error("Surface shaders require 'glsl' parameter with complete shader code")
		end
	elseif self._type == "sky" then
		if source.glsl then
			self._shader = r3d.lib.R3D_LoadSkyShaderFromMemory(source.glsl)
		else
			error("Sky shaders require 'glsl' parameter with complete shader code")
		end
	elseif self._type == "screen" then
		if source.glsl then
			self._shader = r3d.lib.R3D_LoadScreenShaderFromMemory(source.glsl)
		else
			error("Screen shaders require 'glsl' parameter with complete shader code")
		end
	end

	return self
end

function Shader:SetUniform(name, value)
	local uniformPtr = nil
	local uniformType = nil

	if self._shader then
		if type(value) == "number" then
			uniformPtr = util.SetShaderValueRaw(
				self._shader,
				name,
				value,
				adapter.const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
			)
			uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
		elseif type(value) == "table" then
			if value.__type then
				if value.__type == "Vector3" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X, value.Y, value.Z },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "CFrame" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.Position.X, value.Position.Y, value.Position.Z },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "Color3" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.R, value.G, value.B },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "Color4" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.R, value.G, value.B, value.A },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif value.__type == "Vector2" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X, value.Y },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
				elseif value.__type == "UDim2" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif value.__type == "UDim" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.Scale, value.Offset },
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
				end
			else
				local valueCount = #value
				if valueCount == 4 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif valueCount == 3 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif valueCount == 2 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = adapter.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
				end
			end
		end
	end

	if uniformPtr then
		if self._type == "surface" then
			r3d.lib.R3D_SetSurfaceShaderUniform(self._shader, name, uniformPtr)
		elseif self._type == "sky" then
			r3d.lib.R3D_SetSkyShaderUniform(self._shader, name, uniformPtr)
		elseif self._type == "screen" then
			r3d.lib.R3D_SetScreenShaderUniform(self._shader, name, uniformPtr)
		elseif self._type == "raylib" then
			if uniformType then
				adapter.lib.SetShaderValue(self._shader, name, uniformPtr, uniformType)
			end
		end
	end
end

function Shader:SetSampler(name, texture)
	if self._type == "surface" then
		r3d.lib.R3D_SetSurfaceShaderSampler(self._shader, name, texture)
	elseif self._type == "sky" then
		r3d.lib.R3D_SetSkyShaderSampler(self._shader, name, texture)
	elseif self._type == "screen" then
		r3d.lib.R3D_SetScreenShaderSampler(self._shader, name, texture)
	end
end

function Shader:Unload()
	if self._type == "surface" then
		r3d.lib.R3D_UnloadSurfaceShader(self._shader)
	elseif self._type == "sky" then
		r3d.lib.R3D_UnloadSkyShader(self._shader)
	elseif self._type == "screen" then
		r3d.lib.R3D_UnloadScreenShader(self._shader)
	elseif self._type == "raylib" then
		adapter.lib.UnloadShader(self._shader)
	end
end

function Shader:GetUniformLoc(field)
	if self._type == "raylib" then
		return adapter.lib.GetShaderLocation(self._shader, field)
	end
	return false, "Not a raylib shader type"
end

return Shader
