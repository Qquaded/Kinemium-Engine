local shader = {}

local raylib = require("@raylib")
local zembed = require("@zembed")
local lib, const, structs = raylib.lib, raylib.const, raylib.structs
local ffi = zune.ffi
local fs = zune.fs
local ptr = require("./ptr")

local function preprocess(path, visited)
	if not path then
		return nil
	end

	local absolutePath = fs.path.resolve(zembed.AssetPath(path))
	if visited[absolutePath] then
		return ""
	end
	visited[absolutePath] = true

	print(`Preprocessing shader at {absolutePath}`)
	local content = fs.readFile(absolutePath)
	if not content then
		error(`Could not read shader file: {absolutePath}`)
	end

	local contentStr = (typeof(content) == "buffer") and buffer.tostring(content) or content
	local dir = fs.path.dirname(absolutePath)

	local lines = contentStr:split("\n")
	local result = {}

	for _, line in ipairs(lines) do
		local includePath = line:match('#include%s+"([^"]+)"')
		if includePath then
			print(`  Found include: {includePath}`)
			local resolvedInclude = fs.path.resolve(dir, includePath)
			local includedContent = preprocess(resolvedInclude, visited)
			table.insert(result, includedContent)
		else
			table.insert(result, line)
		end
	end

	return table.concat(result, "\n")
end

local shaderUniforms, activeShaders = {}, {}

function shader.Apply(loopshader, lighting, cameraPos, activeLights, SetShaderUniform, time)
	loopshader(function(shaderName, activeShader)
		lib.BeginShaderMode(activeShader)

		SetShaderUniform(activeShader, "time", time, const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT)
		SetShaderUniform(
			activeShader,
			"viewPos",
			{ cameraPos.x, cameraPos.y, cameraPos.z },
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
		)

		if lighting then
			local ambient = lighting.Ambient
			SetShaderUniform(
				activeShader,
				"globalAmbient",
				{ ambient.R / 255, ambient.G / 255, ambient.B / 255 },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)

			local sunDir = lighting:GetSunDirection()
			SetShaderUniform(
				activeShader,
				"dirLightDir",
				{ -sunDir.X, -sunDir.Y, -sunDir.Z },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)
			SetShaderUniform(
				activeShader,
				"dirLightColor",
				{ 1.0, 0.95, 0.8 },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)
		end

		local positions, colors, intensities = {}, {}, {}
		for i, light in ipairs(activeLights) do
			positions[i] = light.pos
			colors[i] = light.color
			intensities[i] = light.intensity
		end

		SetShaderUniform(activeShader, "pointLightCount", #activeLights, const.ShaderUniformDataType.SHADER_UNIFORM_INT)
		SetShaderUniform(
			activeShader,
			"pointLightPositions",
			positions,
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3_ARRAY
		)
		SetShaderUniform(
			activeShader,
			"pointLightColors",
			colors,
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3_ARRAY
		)
		SetShaderUniform(
			activeShader,
			"pointLightIntensities",
			intensities,
			const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT_ARRAY
		)
	end)
end

function shader.cacheCommonLocations(shaderName)
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
		"lightCount",
		"matProjection",
	}
	for _, n in ipairs(names) do
		shaderUniforms[shaderName][n] = lib.GetShaderLocation(activeShaders[shaderName], n)
		print(`Shader uniform "{n}" location: {shaderUniforms[shaderName][n]}`) -- DEBUG
	end
end

function shader.LoadShader(shaderName: string, vertexPath: string?, fragmentPath: string?)
	local vertexCode = vertexPath and preprocess(vertexPath, {}) or ffi.null
	local fragmentCode = fragmentPath and preprocess(fragmentPath, {}) or ffi.null

	local shaderObj = lib.LoadShaderFromMemory(vertexCode, fragmentCode)
	activeShaders[shaderName] = shaderObj
	shaderUniforms[shaderName] = {}

	if lib.IsShaderValid(shaderObj) == 0 then
		print(`Loaded shader {shaderName} is INVALID`)
	end

	shader.cacheCommonLocations(shaderName)

	print(`Loaded shader: {shaderName}`)
	return shaderObj
end

function shader.LoadShaderCode(shaderName: string, vertex: string?, fragment: string?)
	local vertexCode = vertex or ffi.null
	local fragmentCode = fragment or ffi.null

	local shaderObj = lib.LoadShaderFromMemory(vertexCode, fragmentCode)
	activeShaders[shaderName] = shaderObj
	shaderUniforms[shaderName] = {}

	if lib.IsShaderValid(shaderObj) == 0 then
		print(`Loaded shader {shaderName} is INVALID`)
	end

	shader.cacheCommonLocations(shaderName)

	print(`Loaded shader: {shaderName}`)
	return shaderObj
end

function shader.GetShaderUniformLocation(shaderName: string, uniformName: string): number
	local shaderObj = activeShaders[shaderName]
	if not shaderObj then
		return -1
	end

	local location = lib.GetShaderLocation(shaderObj, uniformName)
	shaderUniforms[shaderName][uniformName] = location
	return location
end

function shader.SetShaderUniform(shaderName: string, uniformName: string, value: any, uniformType: number)
	local shaderObj = activeShaders[shaderName]
	if not shaderObj then
		return
	end

	shader.SetShaderValueRaw(shaderObj, uniformName, value, uniformType)
end

function shader.SetShaderValueRaw(shaderObj: buffer, uniformName: string, value: any, uniformType: number)
	local valuePtr
	if type(value) == "number" then
		if uniformType == const.ShaderUniformDataType.SHADER_UNIFORM_INT then
			valuePtr = ffi.create(ffi.types.i32)
			valuePtr:writei32(0, value)
		else
			valuePtr = ptr.float_ptr(value)
		end
	elseif typeof(value) == "vector" then
		valuePtr = ptr.vec3_ptr(value.x, value.y, value.z)
	elseif type(value) == "table" and #value == 3 then
		valuePtr = ptr.vec3_ptr(value[1], value[2], value[3])
	elseif type(value) == "table" and #value == 4 then
		local arr = ffi.create(ffi.types.float:array(4))
		arr:writef32(0, value[1])
		arr:writef32(4, value[2])
		arr:writef32(8, value[3])
		arr:writef32(12, value[4])
		valuePtr = arr
	elseif uniformType == const.ShaderUniformDataType.SHADER_UNIFORM_VEC4 and type(value) == "table" then
		local count = #value
		local arr = ffi.create(ffi.types.float:array(count * 4))
		for i = 1, count do
			local v = value[i]
			local x = v[1] or v.x or v.X or 0
			local y = v[2] or v.y or v.Y or 0
			local z = v[3] or v.z or v.Z or 0
			local w = v[4] or v.w or v.W or 0
			local base = (i - 1) * 16
			arr:writef32(base + 0, x)
			arr:writef32(base + 4, y)
			arr:writef32(base + 8, z)
			arr:writef32(base + 12, w)
		end
		valuePtr = arr
	elseif uniformType == const.ShaderUniformDataType.SHADER_UNIFORM_VEC3_ARRAY and type(value) == "table" then
		local count = #value
		local arr = ffi.create(ffi.types.float:array(count * 3))
		for i = 1, count do
			local v = value[i]
			local x = v[1] or v.x or v.X or 0
			local y = v[2] or v.y or v.Y or 0
			local z = v[3] or v.z or v.Z or 0
			local base = (i - 1) * 12
			arr:writef32(base + 0, x)
			arr:writef32(base + 4, y)
			arr:writef32(base + 8, z)
		end
		valuePtr = arr
	elseif uniformType == const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT_ARRAY and type(value) == "table" then
		local count = #value
		local arr = ffi.create(ffi.types.float:array(count))
		for i = 1, count do
			arr:writef32((i - 1) * 4, value[i] or 0)
		end
		valuePtr = arr
	elseif uniformType == const.ShaderUniformDataType.SHADER_UNIFORM_VEC2 and type(value) == "table" then
		local count = #value
		local arr = ffi.create(ffi.types.float:array(count * 2))
		arr:writef32(0, value[1] or value.x or value.X or 0)
		arr:writef32(4, value[2] or value.y or value.Y or 0)
		valuePtr = arr
	else
		valuePtr = value
	end

	return valuePtr
end

function shader.SetShaderTextureRaw(shaderObject, uniformName: string, texture: any)
	local location = lib.GetShaderLocation(shaderObject, uniformName)
	lib.SetShaderValueTexture(shaderObject, location, texture)
end

function shader.SetShaderTexture(shaderName: string, uniformName: string, texture: any)
	local shaderObj = activeShaders[shaderName]
	if not shaderObj then
		return
	end

	shader.SetShaderTextureRaw(shaderObj, uniformName, texture)
end

function shader.UnloadShader(shaderName: string)
	local shaderObj = activeShaders[shaderName]
	if shaderObj then
		lib.UnloadShader(shaderObj)
		activeShaders[shaderName] = nil
		shaderUniforms[shaderName] = nil
		print(`Unloaded shader: {shaderName}`)
	end
end

return shader
