local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local WebviewService = Instance.new("WebviewService")
WebviewService.ExplorerHidden = true

WebviewService.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless then
		return
	end

	WebviewService:SetProperties({
		MakeULHTMLObj = function()
			local raylib = require("@raylib")
			local UltraLight = require("@Ultralight")
			local UL = UltraLight.lib
			local C = UltraLight.constants
			local AppCore = UltraLight.AppCore.lib

			local function evalJS(view, script)
				local jsStr = UL.ulCreateString(script)
				UL.ulViewEvaluateScript(view, jsStr, nil)
				UL.ulDestroyString(jsStr)
			end

			AppCore.ulEnablePlatformFontLoader()
			AppCore.ulEnablePlatformFileSystem(UL.ulCreateString("./"))

			local config = UL.ulCreateConfig()
			UL.ulConfigSetResourcePathPrefix(
				config,
				UL.ulCreateString("./src/external/ultralight/bin/resources/") -- adjust path relative to your exe
			)

			local ULrenderer = UL.ulCreateRenderer(config)
			UL.ulDestroyConfig(config)

			return {
				MakeRaylibImage = function(htmlPath, w, h)
					local viewConfig = UL.ulCreateViewConfig()
					UL.ulViewConfigSetIsAccelerated(viewConfig, 0) -- CPU mode, gives us a bitmap
					UL.ulViewConfigSetIsTransparent(viewConfig, 1) -- transparent background

					local session = UL.ulDefaultSession(ULrenderer)
					local view = UL.ulCreateView(ULrenderer, 1280, 720, viewConfig, session)
					UL.ulDestroyViewConfig(viewConfig)

					local url = UL.ulCreateString(htmlPath)
					UL.ulViewLoadURL(view, url)
					UL.ulDestroyString(url)

					while true do
						UL.ulUpdate(ULrenderer)
						UL.ulRender(ULrenderer)
						if UL.ulViewIsLoading(view) == 0 then
							print("Loaded HTML!")
							break
						end
						task.wait(0.1)
					end

					-- first update block
					UL.ulUpdate(ULrenderer)
					UL.ulRender(ULrenderer)

					local surface = UL.ulViewGetSurface(view)
					local bitmap = UL.ulBitmapSurfaceGetBitmap(surface)

					local bw = UL.ulBitmapGetWidth(bitmap)
					local bh = UL.ulBitmapGetHeight(bitmap)

					UL.ulBitmapSwapRedBlueChannels(bitmap) -- BGRA -> RGBA for raylib

					local pixels = UL.ulBitmapLockPixels(bitmap)

					local rl_image = raylib.structs.Image:new({
						data = pixels,
						width = bw,
						height = bh,
						mipmaps = 1,
						format = 7,
					})
					local texture = raylib.lib.LoadTextureFromImage(rl_image)

					UL.ulBitmapUnlockPixels(bitmap)
					-- end

					local obj = {
						texture = texture,
						rl_image = rl_image,
						view = view,
						evalJS = evalJS,
					}

					renderer_signal:Connect(function(event, W, H)
						if event == "WindowResized" then
							UL.ulViewResize(view, W, H)

							raylib.lib.UnloadTexture(texture)

							UL.ulUpdate(ULrenderer)
							UL.ulRender(ULrenderer)

							local surface = UL.ulViewGetSurface(view)
							local bitmap = UL.ulBitmapSurfaceGetBitmap(surface)
							local bw = UL.ulBitmapGetWidth(bitmap)
							local bh = UL.ulBitmapGetHeight(bitmap)

							UL.ulBitmapSwapRedBlueChannels(bitmap)
							local pixels = UL.ulBitmapLockPixels(bitmap)

							local img = raylib.structs.Image:new({
								data = pixels,
								width = bw,
								height = bh,
								mipmaps = 1,
								format = 7,
							})
							texture = raylib.lib.LoadTextureFromImage(img)
							UL.ulBitmapUnlockPixels(bitmap)
							UL.ulBitmapSwapRedBlueChannels(bitmap) -- swap back

							obj.texture = texture
							print("[UL] Resized to", W, H)
						end
					end)

					renderer.Hook.new("Renderstep", function()
						-- ── INPUT FIRST (before render so UL processes it this frame) ──
						local mx = raylib.lib.GetMouseX()
						local my = raylib.lib.GetMouseY()

						-- Mouse move (always send)
						local moveEvt = UL.ulCreateMouseEvent(
							C.ULMouseEventType.kMouseEventType_MouseMoved,
							mx,
							my,
							C.ULMouseButton.kMouseButton_None
						)
						UL.ulViewFireMouseEvent(view, moveEvt)
						UL.ulDestroyMouseEvent(moveEvt)

						-- Mouse buttons (only on press/release)
						local buttons = {
							{
								rl = raylib.const.MouseButton.MOUSE_BUTTON_LEFT,
								ul = C.ULMouseButton.kMouseButton_Left,
							},
							{
								rl = raylib.const.MouseButton.MOUSE_BUTTON_RIGHT,
								ul = C.ULMouseButton.kMouseButton_Right,
							},
							{
								rl = raylib.const.MouseButton.MOUSE_BUTTON_MIDDLE,
								ul = C.ULMouseButton.kMouseButton_Middle,
							},
						}
						for _, btn in ipairs(buttons) do
							if raylib.lib.IsMouseButtonPressed(btn.rl) == 1 then
								local evt =
									UL.ulCreateMouseEvent(C.ULMouseEventType.kMouseEventType_MouseDown, mx, my, btn.ul)
								UL.ulViewFireMouseEvent(view, evt)
								UL.ulDestroyMouseEvent(evt)
							end
							if raylib.lib.IsMouseButtonReleased(btn.rl) == 1 then
								local evt =
									UL.ulCreateMouseEvent(C.ULMouseEventType.kMouseEventType_MouseUp, mx, my, btn.ul)
								UL.ulViewFireMouseEvent(view, evt)
								UL.ulDestroyMouseEvent(evt)
							end
						end
						-- Scroll
						local wheel = raylib.lib.GetMouseWheelMove()
						if wheel ~= 0 then
							local scrollEvt = UL.ulCreateScrollEvent(
								C.ULScrollEventType.kScrollEventType_ScrollByPixel,
								0,
								math.floor(wheel * 60)
							)
							UL.ulViewFireScrollEvent(view, scrollEvt)
							UL.ulDestroyScrollEvent(scrollEvt)
						end
						-- Keyboard
						while true do
							local char = raylib.lib.GetCharPressed()
							if char == 0 then
								break
							end
							local charStr = utf8.char(char)
							local text = UL.ulCreateString(charStr)
							local notext = UL.ulCreateString("")
							local rawEvt = UL.ulCreateKeyEvent(
								C.ULKeyEventType.kKeyEventType_RawKeyDown,
								0,
								char,
								0,
								notext,
								notext,
								0,
								0,
								0
							)
							UL.ulViewFireKeyEvent(view, rawEvt)
							UL.ulDestroyKeyEvent(rawEvt)
							local charEvt =
								UL.ulCreateKeyEvent(C.ULKeyEventType.kKeyEventType_Char, 0, 0, 0, text, text, 0, 0, 0)
							UL.ulViewFireKeyEvent(view, charEvt)
							UL.ulDestroyKeyEvent(charEvt)
							local upEvt = UL.ulCreateKeyEvent(
								C.ULKeyEventType.kKeyEventType_KeyUp,
								0,
								char,
								0,
								notext,
								notext,
								0,
								0,
								0
							)
							UL.ulViewFireKeyEvent(view, upEvt)
							UL.ulDestroyKeyEvent(upEvt)
							UL.ulDestroyString(text)
							UL.ulDestroyString(notext)
						end
						local notext = UL.ulCreateString("")
						local specialKeys = {
							{ rl = raylib.const.KeyboardKey.KEY_BACKSPACE, ul = 0x08 },
							{ rl = raylib.const.KeyboardKey.KEY_ENTER, ul = 0x0D },
							{ rl = raylib.const.KeyboardKey.KEY_TAB, ul = 0x09 },
							{ rl = raylib.const.KeyboardKey.KEY_LEFT, ul = 0x25 },
							{ rl = raylib.const.KeyboardKey.KEY_RIGHT, ul = 0x27 },
							{ rl = raylib.const.KeyboardKey.KEY_UP, ul = 0x26 },
							{ rl = raylib.const.KeyboardKey.KEY_DOWN, ul = 0x28 },
							{ rl = raylib.const.KeyboardKey.KEY_DELETE, ul = 0x2E },
							{ rl = raylib.const.KeyboardKey.KEY_HOME, ul = 0x24 },
							{ rl = raylib.const.KeyboardKey.KEY_END, ul = 0x23 },
						}
						for _, key in ipairs(specialKeys) do
							if raylib.lib.IsKeyPressed(key.rl) == 1 then
								local downEvt = UL.ulCreateKeyEvent(
									C.ULKeyEventType.kKeyEventType_RawKeyDown,
									0,
									key.ul,
									0,
									notext,
									notext,
									0,
									0,
									0
								)
								UL.ulViewFireKeyEvent(view, downEvt)
								UL.ulDestroyKeyEvent(downEvt)
							end
							if raylib.lib.IsKeyReleased(key.rl) == 1 then
								local upEvt = UL.ulCreateKeyEvent(
									C.ULKeyEventType.kKeyEventType_KeyUp,
									0,
									key.ul,
									0,
									notext,
									notext,
									0,
									0,
									0
								)
								UL.ulViewFireKeyEvent(view, upEvt)
								UL.ulDestroyKeyEvent(upEvt)
							end
						end
						UL.ulDestroyString(notext)
						UL.ulUpdate(ULrenderer)
						UL.ulRender(ULrenderer)

						local surface = UL.ulViewGetSurface(view)
						local dirty = UL.ulSurfaceGetDirtyBounds(surface)
						if UL.ulIntRectIsEmpty(dirty) == 0 then
							local bitmap = UL.ulBitmapSurfaceGetBitmap(surface)
							UL.ulBitmapSwapRedBlueChannels(bitmap)
							local pixels = UL.ulBitmapLockPixels(bitmap)
							raylib.lib.UpdateTexture(texture, pixels)
							UL.ulBitmapUnlockPixels(bitmap)
							UL.ulBitmapSwapRedBlueChannels(bitmap) -- swap back
							UL.ulSurfaceClearDirtyBounds(surface)
						end
					end)

					return obj
				end,
			}
		end,
		CreateWindow = function(title, x, y)
			local webview = require("@webview")
			local lib = webview.lib
			if zune.platform.os == "windows" then
				local ole32 = require("@ole32")

				ole32.lib.CoInitializeEx(nil, 2)
			end

			local wv = lib.webview_create(0, nil)
			lib.webview_set_title(wv, title or "Kinemium Webview")
			lib.webview_set_size(wv, x or 800, y or 600, nil)

			return {
				Navigate = function(site)
					lib.webview_navigate(wv, site or "https://github.com/Qquaded/Kinemium-Engine")
				end,

				SetTitle = function(title)
					lib.webview_set_title(wv, title or "Kinemium Webview")
				end,

				SetSize = function(x, y)
					lib.webview_set_size(wv, x or 800, y or 600, 0)
				end,

				Run = function()
					lib.webview_run(wv)
				end,
			}
		end,
	})
end

return WebviewService
