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

export type Vector2 = adapter.Vector2
export type Vector3 = adapter.Vector3
export type Vector4 = adapter.Vector4
export type Quaternion = adapter.Quaternion
export type Matrix = adapter.Matrix
export type Color = adapter.Color
export type Rectangle = adapter.Rectangle
export type Image = adapter.Image
export type Texture = adapter.Texture
export type Texture2D = adapter.Texture2D
export type TextureCubemap = adapter.TextureCubemap
export type RenderTexture = adapter.RenderTexture
export type RenderTexture2D = adapter.RenderTexture2D
export type NPatchInfo = adapter.NPatchInfo
export type GlyphInfo = adapter.GlyphInfo
export type Font = adapter.Font
export type Camera3D = adapter.Camera3D
export type Camera2D = adapter.Camera2D
export type Mesh = adapter.Mesh
export type Shader = adapter.Shader
export type MaterialMap = adapter.MaterialMap
export type Material = adapter.Material
export type Transform = adapter.Transform
export type BoneInfo = adapter.BoneInfo
export type Model = adapter.Model
export type ModelAnimation = adapter.ModelAnimation
export type Ray = adapter.Ray
export type RayCollision = adapter.RayCollision
export type BoundingBox = adapter.BoundingBox
export type Wave = adapter.Wave
export type rAudioBuffer = adapter.rAudioBuffer
export type rAudioProcessor = adapter.rAudioProcessor
export type AudioStream = adapter.AudioStream
export type Sound = adapter.Sound
export type Music = adapter.Music
export type VrDeviceInfo = adapter.VrDeviceInfo
export type VrStereoConfig = adapter.VrStereoConfig
export type FilePathList = adapter.FilePathList
export type AutomationEvent = adapter.AutomationEvent
export type AutomationEventList = adapter.AutomationEventList

local lib = native.lib
local const = native.const
local structs = const.structs

return {
	lib = lib,
	const = const,
	structs = structs,
}
