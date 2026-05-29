local Instance = require("@Instance")
local Enum = require("@EnumMap")

local KinemiumShaderService = Instance.new("KinemiumShaderService")
KinemiumShaderService.ExplorerHidden = true
KinemiumShaderService._Intents = Enum.PluginIntents.Graphics

local r3d = require("@r3d")
local raylib = require("@raylib")
local rlib = raylib.lib

KinemiumShaderService.InitRenderer = function(renderer, renderer_signal, datamodel)
	if IsHeadless == true then
		return KinemiumShaderService:SetProperties({})
	end

	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true

		local Lighting = datamodel:GetService("Lighting")
		local workspace = datamodel:GetService("Workspace")

		local function activateSkyShader(shaderobj)
			Lighting.SetSkyShader(shaderobj)
		end

		local function activateScreenShader(shaderobj)
			local chain_array = zune.ffi.create(zune.ffi.types.pointer:array(1))
			local shader = shaderobj._shader
			chain_array:writeptr(0, shader)
			r3d.lib.R3D_SetScreenShaderChain(chain_array, 1)
		end

		local function activateMaterialShader(shaderobj)
			workspace.ApplyGlobalSurfaceShader(shaderobj)
		end

		KinemiumShaderService:SetProperties({
			LoadShader = function(ShaderObject)
				if typeof(ShaderObject) == "table" then
					if ShaderObject._class == "shader" then
						if ShaderObject._type == "raylib" then
							return true, "Already loaded"
						elseif ShaderObject._type == "surface" then
							activateMaterialShader(ShaderObject)
							return true
						elseif ShaderObject._type == "sky" then
							activateSkyShader(ShaderObject)
							return true
						elseif ShaderObject._type == "screen" then
							activateScreenShader(ShaderObject)
							return true
						end
					end
				end
				return false, "Invalid shader type"
			end,

			UnloadShader = function(ShaderObject)
				if typeof(ShaderObject) == "table" then
					if ShaderObject._class == "shader" then
						if ShaderObject._type == "raylib" then
							rlib.UnloadShader(ShaderObject._shader)
							return true
						elseif ShaderObject._type == "surface" then
							r3d.lib.R3D_UnloadSurfaceShader(ShaderObject._shader)
							return true
						elseif ShaderObject._type == "sky" then
							r3d.lib.R3D_UnloadSkyShader(ShaderObject._shader)
							return true
						elseif ShaderObject._type == "screen" then
							r3d.lib.R3D_UnloadScreenShader(ShaderObject._shader)
							return true
						end
					end
				end
				return false
			end,

			LoadShaderPipeline = function(...)
				local args = { ... }
				local shaders = args

				if #args == 1 and type(args[1]) == "table" and not args[1]._class then
					shaders = args[1]
				end

				local count = #shaders
				if count == 0 then
					return true
				end

				local chain_array = zune.ffi.create(zune.ffi.types.pointer:array(count))
				local ptrSize = zune.ffi.types.pointer:size()

				for i = 1, count do
					local shaderobj = shaders[i]
					if
						typeof(shaderobj) == "table"
						and shaderobj._class == "shader"
						and shaderobj._type == "screen"
					then
						chain_array:writeptr((i - 1) * ptrSize, shaderobj._shader)
					else
						return false, "Invalid shader in pipeline: expected screen shader"
					end
				end

				r3d.lib.R3D_SetScreenShaderChain(chain_array, count)
				return {
					Unload = function()
						r3d.lib.R3D_SetScreenShaderChain(nil, 0)
					end,
				}
			end,
		})

		return true
	end)
	return true
end

return KinemiumShaderService
