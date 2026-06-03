local Shader = {}
Shader.__index = Shader

local raylib = require("@raylib")
local zembed = require("@zembed")
local util = require("@kineshader")
local r3d = require("@r3d")

local function cleanScreenShaderCode(glsl)
	glsl = glsl:gsub("#version%s+[%d%w]+", "")
	glsl = glsl:gsub("in%s+[%w%[%]%s]+%s+[%w_]+%s*;", "")
	glsl = glsl:gsub("out%s+[%w%[%]%s]+%s+[%w_]+%s*;", "")
	glsl = glsl:gsub("uniform%s+sampler[%d%w]+%s+[%w_]+%s*;", "")
	glsl = glsl:gsub("void%s+main%s*%(", "void fragment(")
	glsl = glsl:gsub("uniform%s+[%w%[%]%s]+%s+[%w_]+%s*;", function(match)
		if not match:match("sampler") then
			return match
		end
		return ""
	end)

	glsl = glsl:gsub("%s+%f[%w]", " ")
	glsl = glsl:gsub("%s+%f[%p]", "")
	glsl = glsl:gsub("\n%s*\n", "\n")

	return glsl
end

function Shader.fromMemoryRaylib(vs, fs)
	local shader = raylib.lib.LoadShaderFromMemory(vs, fs)
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
		self._shader = raylib.lib.LoadShader(vertex, fragment)
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
				raylib.const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
			)
			uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
		elseif type(value) == "table" then
			if value.__type then
				if value.__type == "Vector3" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X, value.Y, value.Z },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "CFrame" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.Position.X, value.Position.Y, value.Position.Z },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "Color3" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.R, value.G, value.B },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif value.__type == "Color4" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.R, value.G, value.B, value.A },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif value.__type == "Vector2" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X, value.Y },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
				elseif value.__type == "UDim2" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif value.__type == "UDim" then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						{ value.Scale, value.Offset },
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
				end
			else
				local valueCount = #value
				if valueCount == 4 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC4
				elseif valueCount == 3 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
				elseif valueCount == 2 then
					uniformPtr = util.SetShaderValueRaw(
						self._shader,
						name,
						value,
						raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
					)
					uniformType = raylib.const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
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
				raylib.lib.SetShaderValue(self._shader, name, uniformPtr, uniformType)
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
		raylib.lib.UnloadShader(self._shader)
	end
end

function Shader:GetUniformLoc(field)
	if self._type == "raylib" then
		return raylib.lib.GetShaderLocation(self._shader, field)
	end
	return false, "Not a raylib shader type"
end

return Shader
