-- default renderer adapter, SDL3
local sdl = require("@sdl3")
local typedefs = require("../../typedefs")
local ui = require("./ui")
local SDLAdapter = {}

local function window_real(w)
	if type(w) ~= "table" then
		return false
	end
	if not w._handle then
		return false
	end
	return true
end

function SDLAdapter:Init()
	sdl.lib.SDL_Init()
end

function SDLAdapter:InitWindow(params: typedefs.WindowParams): typedefs.Window
	local graphics = {
		opengl = 0x0000000000000002,
		vulkan = 0x0000000010000000,
	}

	local sdl_window = sdl.lib.SDL_CreateWindow(params.Title, params.Width, params.Height, graphics[params.WGI])
	if sdl_window then
		local object = {
			Width = params.Width,
			Height = params.Height,
			WGI = params.WGI,
			_handle = sdl_window,
			_uihandle = ui:Init(params.Width, params.Height),
		}
		return object
	end
	return false
end

function SDLAdapter:CreateRenderingContext(window: typedefs.Window): typedefs.RenderingContext | boolean
	if not window_real(window) then
		return
	end
	if window.WGI == "opengl" then
		local context = sdl.lib.SDL_GL_CreateContext(window._handle)
		if context then
			local struct = {
				_handle = context,
				Window = window,
			}

			return struct
		else
			return false
		end
	elseif window.WGI == "vulkan" then
		print("Vulkan Rendering Context is in development, Check back later!")
		return false
	end
	return false
end

function SDLAdapter:ShowWindow(window: typedefs.Window)
	if not window_real(window) then
		return
	end
	sdl.lib.SDL_ShowWindow(window._handle)
end

function SDLAdapter:BeginFrame(context: typedefs.RenderingContext)
	sdl.lib.SDL_GL_MakeCurrent(context.Window._handle, context._handle)
end

function SDLAdapter:EndFrame(context: typedefs.RenderingContext)
	sdl.lib.SDL_GL_SwapWindow(context.Window._handle)
end

function SDLAdapter:CreateRenderer(window: typedefs.Window): typedefs.Renderer
	if not window_real(window) then
		return
	end

	return {
		_handle = sdl.lib.SDL_CreateRenderer(window._handle, 0),
	}
end

function SDLAdapter:CreateTexture(params: typedefs.TextureParams): typedefs.Texture
	local PixelFormat = {
		UNKNOWN = 0,

		RGB332 = 0x14110801,
		RGB444 = 0x15120E02,
		RGB555 = 0x15130F02,
		BGR555 = 0x15530F02,
		ARGB4444 = 0x15321002,
		RGBA4444 = 0x15421002,
		ABGR4444 = 0x15721002,
		BGRA4444 = 0x15821002,

		RGB565 = 0x15151002,
		BGR565 = 0x15551002,

		RGB24 = 0x17101803,
		BGR24 = 0x17401803,

		RGB888 = 0x16161804,
		RGBX8888 = 0x16261804,
		BGR888 = 0x16561804,
		BGRX8888 = 0x16661804,

		ARGB8888 = 0x16362004,
		RGBA8888 = 0x16462004,
		ABGR8888 = 0x16762004,
		BGRA8888 = 0x16862004,

		ARGB2101010 = 0x16372004,
		ABGR2101010 = 0x16772004,

		RGB10A2 = 0x16472004,
		BGR10A2 = 0x16872004,

		RGBA32 = 0xA1676204,
		ARGB32 = 0xA1632004,
		BGRA32 = 0xA1686204,
		ABGR32 = 0xA1676204,
	}

	local TextureAccess = {
		STATIC = 0,
		STREAMING = 1,
		TARGET = 2,
	}

	local texture = sdl.lib.SDL_CreateTexture(
		params.renderer._handle,
		PixelFormat[params.pixelFormat],
		TextureAccess[params.access],
		params.width,
		params.height
	)

	return {
		_handle = texture,
		width = params.width,
		height = params.height,
	}
end

function SDLAdapter:DrawTexture(renderer: typedefs.Renderer, texture: typedefs.Texture)
	sdl.lib.SDL_RenderTexture(renderer._handle, texture._handle, nil, nil)
end

function SDLAdapter:PollEvents()
	local event = sdl.structs.SDL_Event:new({})
	sdl.lib.SDL_PollEvent(event)
end

-- ui lib
function SDLAdapter:DrawRectangle(window: typedefs.Window, rectangle: typedefs.Rectangle)
	ui:DrawRect(window._uihandle, rectangle)
end

return SDLAdapter
