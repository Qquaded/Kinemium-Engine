--!strict
--!optimize 2
--!native

local raylib = require("./raylib")

local ffi = zune.ffi
local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
local long = ffi.types.i64
local FFIPointer = ffi.types.FFIPointer

type int = number
type uint = number
type bool = number
type float = number
type long = buffer
type double = number
type cstring = string | buffer | FFIPointer

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	rlEnableDepthTest: () -> (),
	rlDisableDepthTest: () -> (),
	rlEnableDepthMask: () -> (),
	rlDisableDepthMask: () -> (),
	rlEnableBackfaceCulling: () -> (),
	rlDisableBackfaceCulling: () -> (),
}

return {
	def = {
		rlMatrixMode = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlPushMatrix = { returns = ffi.types.void, args = {} },
		rlPopMatrix = { returns = ffi.types.void, args = {} },
		rlLoadIdentity = { returns = ffi.types.void, args = {} },
		rlTranslatef = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		rlRotatef = {
			returns = ffi.types.void,
			args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
		},
		rlScalef = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		rlMultMatrixf = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlFrustum = {
			returns = ffi.types.void,
			args = {
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
			},
		},
		rlOrtho = {
			returns = ffi.types.void,
			args = {
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
			},
		},
		rlViewport = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 } },
		rlSetClipPlanes = { returns = ffi.types.void, args = { ffi.types.double, ffi.types.double } },
		rlGetCullDistanceNear = { returns = ffi.types.double, args = {} },
		rlGetCullDistanceFar = { returns = ffi.types.double, args = {} },
		rlBegin = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlEnd = { returns = ffi.types.void, args = {} },
		rlVertex2i = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
		rlVertex2f = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float } },
		rlVertex3f = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		rlTexCoord2f = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float } },
		rlNormal3f = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		rlColor4ub = { returns = ffi.types.void, args = { ffi.types.u8, ffi.types.u8, ffi.types.u8, ffi.types.u8 } },
		rlColor3f = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		rlColor4f = {
			returns = ffi.types.void,
			args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
		},
		rlEnableVertexArray = { returns = ffi.types.u8, args = { ffi.types.u32 } },
		rlDisableVertexArray = { returns = ffi.types.void, args = {} },
		rlEnableVertexBuffer = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableVertexBuffer = { returns = ffi.types.void, args = {} },
		rlEnableVertexBufferElement = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableVertexBufferElement = { returns = ffi.types.void, args = {} },
		rlEnableVertexAttribute = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableVertexAttribute = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlActiveTextureSlot = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlEnableTexture = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableTexture = { returns = ffi.types.void, args = {} },
		rlEnableTextureCubemap = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableTextureCubemap = { returns = ffi.types.void, args = {} },
		rlTextureParameters = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.i32, ffi.types.i32 } },
		rlCubemapParameters = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.i32, ffi.types.i32 } },
		rlEnableShader = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableShader = { returns = ffi.types.void, args = {} },
		rlEnableFramebuffer = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlDisableFramebuffer = { returns = ffi.types.void, args = {} },
		rlGetActiveFramebuffer = { returns = ffi.types.i32, args = {} },
		rlActiveDrawBuffers = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlBlitFramebuffer = {
			returns = ffi.types.void,
			args = {
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
			},
		},
		rlBindFramebuffer = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.u32 } },
		rlEnableColorBlend = { returns = ffi.types.void, args = {} },
		rlDisableColorBlend = { returns = ffi.types.void, args = {} },
		rlEnableDepthTest = { returns = ffi.types.void, args = {} },
		rlDisableDepthTest = { returns = ffi.types.void, args = {} },
		rlEnableDepthMask = { returns = ffi.types.void, args = {} },
		rlDisableDepthMask = { returns = ffi.types.void, args = {} },
		rlEnableBackfaceCulling = { returns = ffi.types.void, args = {} },
		rlDisableBackfaceCulling = { returns = ffi.types.void, args = {} },
		rlColorMask = { returns = ffi.types.void, args = { ffi.types.u8, ffi.types.u8, ffi.types.u8, ffi.types.u8 } },
		rlSetCullFace = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlEnableScissorTest = { returns = ffi.types.void, args = {} },
		rlDisableScissorTest = { returns = ffi.types.void, args = {} },
		rlScissor = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 } },
		rlEnableWireMode = { returns = ffi.types.void, args = {} },
		rlDisableWireMode = { returns = ffi.types.void, args = {} },
		rlSetLineWidth = { returns = ffi.types.void, args = { ffi.types.float } },
		rlGetLineWidth = { returns = ffi.types.float, args = {} },
		rlEnableSmoothLines = { returns = ffi.types.void, args = {} },
		rlDisableSmoothLines = { returns = ffi.types.void, args = {} },
		rlEnableStereoRender = { returns = ffi.types.void, args = {} },
		rlDisableStereoRender = { returns = ffi.types.void, args = {} },
		rlIsStereoRenderEnabled = { returns = ffi.types.u8, args = {} },
		rlClearScreenBuffers = { returns = ffi.types.void, args = {} },
		rlCheckErrors = { returns = ffi.types.void, args = {} },
		rlSetBlendMode = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlSetBlendFactors = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32, ffi.types.i32 } },
		rlSetBlendFactorsSeparate = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlglInit = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
		rlglClose = { returns = ffi.types.void, args = {} },
		rlLoadExtensions = { returns = ffi.types.void, args = {} },
		rlGetVersion = { returns = ffi.types.i32, args = {} },
		rlSetFramebufferWidth = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlGetFramebufferWidth = { returns = ffi.types.i32, args = {} },
		rlSetFramebufferHeight = { returns = ffi.types.void, args = { ffi.types.i32 } },
		rlGetFramebufferHeight = { returns = ffi.types.i32, args = {} },
		rlGetTextureIdDefault = { returns = ffi.types.i32, args = {} },
		rlGetShaderIdDefault = { returns = ffi.types.i32, args = {} },
		rlLoadRenderBatch = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.i32 } },
		rlUnloadRenderBatch = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlDrawRenderBatch = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlSetRenderBatchActive = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlDrawRenderBatchActive = { returns = ffi.types.void, args = {} },
		rlCheckRenderBatchLimit = { returns = ffi.types.u8, args = { ffi.types.i32 } },
		rlSetTexture = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlLoadVertexArray = { returns = ffi.types.i32, args = {} },
		rlLoadVertexBuffer = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32, ffi.types.u8 } },
		rlLoadVertexBufferElement = {
			returns = ffi.types.i32,
			args = { ffi.types.pointer, ffi.types.i32, ffi.types.u8 },
		},
		rlUpdateVertexBuffer = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
		},
		rlUpdateVertexBufferElements = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
		},
		rlUnloadVertexArray = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlUnloadVertexBuffer = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlSetVertexAttribute = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.i32, ffi.types.i32, ffi.types.u8, ffi.types.i32, ffi.types.i32 },
		},
		rlSetVertexAttributeDivisor = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.i32 } },
		rlSetVertexAttributeDefault = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
		},
		rlDrawVertexArray = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
		rlDrawVertexArrayElements = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.i32, ffi.types.pointer },
		},
		rlDrawVertexArrayInstanced = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlDrawVertexArrayElementsInstanced = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.i32, ffi.types.pointer, ffi.types.i32 },
		},
		rlLoadTexture = {
			returns = ffi.types.i32,
			args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlLoadTextureDepth = { returns = ffi.types.i32, args = { ffi.types.i32, ffi.types.i32, ffi.types.u8 } },
		rlLoadTextureCubemap = {
			returns = ffi.types.i32,
			args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlUpdateTexture = {
			returns = ffi.types.void,
			args = {
				ffi.types.u32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.i32,
				ffi.types.pointer,
			},
		},
		rlGetGlTextureFormats = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
		},
		rlUnloadTexture = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlGenTextureMipmaps = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.i32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlLoadFramebuffer = { returns = ffi.types.i32, args = {} },
		rlFramebufferAttach = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.u32, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
		},
		rlFramebufferComplete = { returns = ffi.types.u8, args = { ffi.types.u32 } },
		rlUnloadFramebuffer = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlLoadShaderCode = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
		rlCompileShader = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
		rlLoadShaderProgram = { returns = ffi.types.i32, args = { ffi.types.u32, ffi.types.u32 } },
		rlUnloadShaderProgram = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlGetLocationUniform = { returns = ffi.types.i32, args = { ffi.types.u32, ffi.types.pointer } },
		rlGetLocationAttrib = { returns = ffi.types.i32, args = { ffi.types.u32, ffi.types.pointer } },
		rlSetUniform = {
			returns = ffi.types.void,
			args = { ffi.types.i32, ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
		},
		rlSetUniformMatrix = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.pointer } },
		rlSetUniformMatrices = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.pointer, ffi.types.i32 } },
		rlSetUniformSampler = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.u32 } },
		rlSetShader = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.i32 } },
		rlLoadComputeShaderProgram = { returns = ffi.types.i32, args = { ffi.types.u32 } },
		rlComputeShaderDispatch = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.u32, ffi.types.u32 } },
		rlLoadShaderBuffer = { returns = ffi.types.i32, args = { ffi.types.u32, ffi.types.pointer, ffi.types.i32 } },
		rlUnloadShaderBuffer = { returns = ffi.types.void, args = { ffi.types.u32 } },
		rlUpdateShaderBuffer = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
		},
		rlBindShaderBuffer = { returns = ffi.types.void, args = { ffi.types.u32, ffi.types.u32 } },
		rlReadShaderBuffer = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.u32, ffi.types.u32 },
		},
		rlCopyShaderBuffer = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.u32, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
		},
		rlGetShaderBufferSize = { returns = ffi.types.i32, args = { ffi.types.u32 } },
		rlBindImageTexture = {
			returns = ffi.types.void,
			args = { ffi.types.u32, ffi.types.u32, ffi.types.i32, ffi.types.u8 },
		},
		rlGetMatrixModelview = { returns = ffi.types.pointer, args = {} },
		rlGetMatrixProjection = { returns = ffi.types.pointer, args = {} },
		rlGetMatrixTransform = { returns = ffi.types.pointer, args = {} },
		rlGetMatrixProjectionStereo = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
		rlGetMatrixViewOffsetStereo = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
		rlSetMatrixProjection = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlSetMatrixModelview = { returns = ffi.types.void, args = { ffi.types.pointer } },
		rlSetMatrixProjectionStereo = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
		rlSetMatrixViewOffsetStereo = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
		rlLoadDrawCube = { returns = ffi.types.void, args = {} },
		rlLoadDrawQuad = { returns = ffi.types.void, args = {} },
	},
}
