-- description: "Renders descendant GUI objects as a single canvas."
local adapter = require("@RaylibAdapter")
local lib = adapter.lib
local utils = require("@bufferutils")
local Color3 = require("@Color3")

local GuiObject = require("@GuiObject")

local propTable = {
	Name = "CanvasGroup",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	GroupColor3 = Color3.new(1, 1, 1),
	GroupTransparency = 0,
}

local function improveQuality(tex)
	local texture = utils.extract.texture(tex)
	adapter.lib.SetTextureFilter(texture, adapter.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
	adapter.lib.SetTextureWrap(texture, adapter.const.TextureWrap.TEXTURE_WRAP_CLAMP)
	adapter.lib.GenTextureMipmaps(texture)
end

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	if adapter.lib.IsWindowResized() == 1 then
		local dpiScale = lib.GetWindowScaleDPI()
		local width, height = lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y
		local texture = adapter.lib.LoadRenderTexture(width, height)
		if object._rendertex then
			adapter.lib.UnloadRenderTexture(object._rendertex)
		end
		object._rendertex = texture
		improveQuality(texture)
	end

	if not object.Visible then
		return
	end

	if object._rendertex then
		adapter.lib.BeginTextureMode(object._rendertex)
		adapter.lib.ClearBackground(adapter.const.BLANK)

		-- render gui objects
		local pos, size = GuiObject.render(lib, object, dt, structs, renderer)
		object.AbsolutePosition = pos
		object.AbsoluteSize = size
		GuiObject.renderChildren(lib, object, dt, structs, renderer)
		adapter.lib.EndTextureMode()

		local dpiScale = lib.GetWindowScaleDPI()
		local W, H = lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y
		local source = adapter.structs.Rectangle:new({ x = 0, y = 0, width = W, height = -H })
		local dest = adapter.structs.Rectangle:new({ x = 0, y = 0, width = W, height = -H })

		lib.DrawTexturePro(
			utils.extract.texture(object._rendertex),
			source,
			dest,
			vector.create(0, 0),
			0,
			object.GroupColor3:ToRaylib(object.GroupTransparency)
		)
	end
end

return {
	class = "CanvasGroup",
	render = propTable.render,
	callback = function(instance, renderer)
		local dpiScale = lib.GetWindowScaleDPI()
		local width, height = lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y
		local texture = adapter.lib.LoadRenderTexture(width, height)
		instance:SetProperties(propTable)
		instance._rendertex = texture
		improveQuality(texture)
		instance.Destroying:Connect(function()
			if instance._rendertex then
				adapter.lib.UnloadRenderTexture(instance._rendertex)
				instance._rendertex = nil
			end
		end)
		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
