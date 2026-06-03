--!strict

if _G.IsHeadless == true then
	local function noop()
		return 0
	end

	local mockStruct = {
		new = function()
			return {}
		end,
		offset = function()
			return 0
		end,
		size = function()
			return 0
		end,
	}

	local mockStructs = setmetatable({}, {
		__index = function()
			return mockStruct
		end,
	})
	local mockConstGroup = setmetatable({}, {
		__index = function()
			return 0
		end,
	})

	local mockLib = setmetatable({}, {
		__index = function()
			return noop
		end,
	})

	local mockConst = setmetatable({
		structs = mockStructs,
		BlendMode = mockConstGroup,
		CameraProjection = mockConstGroup,
		ConfigFlags = mockConstGroup,
		CubemapLayout = mockConstGroup,
		KeyboardKey = mockConstGroup,
		MaterialMapIndex = mockConstGroup,
		MouseButton = mockConstGroup,
		MouseCursor = mockConstGroup,
		PixelFormat = mockConstGroup,
		ShaderLocationIndex = mockConstGroup,
		ShaderUniformDataType = mockConstGroup,
		TextureFilter = mockConstGroup,
		TextureWrap = mockConstGroup,
		TraceLogLevel = mockConstGroup,
	}, {
		__index = function()
			return 0
		end,
	})

	return {
		lib = mockLib,
		const = mockConst,
		structs = mockStructs,
	}
end

local native = require("@self/native")
local raylib = require("@self/native/raylib")

export type Vector2 = raylib.Vector2
export type Vector3 = raylib.Vector3
export type Vector4 = raylib.Vector4
export type Quaternion = raylib.Quaternion
export type Matrix = raylib.Matrix
export type Color = raylib.Color
export type Rectangle = raylib.Rectangle
export type Image = raylib.Image
export type Texture = raylib.Texture
export type Texture2D = raylib.Texture2D
export type TextureCubemap = raylib.TextureCubemap
export type RenderTexture = raylib.RenderTexture
export type RenderTexture2D = raylib.RenderTexture2D
export type NPatchInfo = raylib.NPatchInfo
export type GlyphInfo = raylib.GlyphInfo
export type Font = raylib.Font
export type Camera3D = raylib.Camera3D
export type Camera2D = raylib.Camera2D
export type Mesh = raylib.Mesh
export type Shader = raylib.Shader
export type MaterialMap = raylib.MaterialMap
export type Material = raylib.Material
export type Transform = raylib.Transform
export type BoneInfo = raylib.BoneInfo
export type Model = raylib.Model
export type ModelAnimation = raylib.ModelAnimation
export type Ray = raylib.Ray
export type RayCollision = raylib.RayCollision
export type BoundingBox = raylib.BoundingBox
export type Wave = raylib.Wave
export type rAudioBuffer = raylib.rAudioBuffer
export type rAudioProcessor = raylib.rAudioProcessor
export type AudioStream = raylib.AudioStream
export type Sound = raylib.Sound
export type Music = raylib.Music
export type VrDeviceInfo = raylib.VrDeviceInfo
export type VrStereoConfig = raylib.VrStereoConfig
export type FilePathList = raylib.FilePathList
export type AutomationEvent = raylib.AutomationEvent
export type AutomationEventList = raylib.AutomationEventList

local lib = native.lib
local const = native.const
local structs = const.structs

return {
	lib = lib,
	const = const,
	structs = structs,
}
