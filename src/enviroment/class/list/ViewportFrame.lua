local logic = require("@Kinemium.2dbutton")

local Frame = require("@Frame")
local TextLabel = require("@TextLabel")
local raylib = require("@raylib")
local utils = require("@bufferutils")

local propTable = {
	Camera = nil,
	Name = "ViewportFrame",
}
Frame.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize = TextLabel.render(lib, object, dt, structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end

	local rtx = object._rendertexture
	if rtx then
		if not object.Camera then
			return
		end
		local raylibcam = object.Camera._raylibcam
		if not raylibcam then
			return
		end
		local position = object.AbsolutePosition
		if not position then
			return
		end
		raylib.lib.BeginTextureMode(rtx)
		raylib.lib.BeginMode3D(raylibcam)
		for _, object in pairs(object:GetChildren()) do
			raylib.lib.DrawCubeV(
				vector.create(object.Position.X, object.Position.Y, object.Position.Z),
				vector.create(object.Size.X, object.Size.Y, object.Size.Z),
				raylib.const.WHITE
			)
			-- draw basic cube until workspace:RenderPart is added
		end
		raylib.lib.EndMode3D()
		raylib.lib.EndTextureMode()

		-- draw
		local tex = utils.extract.texture(rtx)
		local size = vector.create(buffer.readi32(tex, 4), buffer.readi32(tex, 8))
		local source = structs.Rectangle:new({ x = position.X, y = position.Y, width = size.x, height = -size.y })
		lib.DrawTextureRec(tex, source, vector.create(0, 0), raylib.const.WHITE)
	end
	return framePos, frameSize
end

return {
	class = "ViewportFrame",
	callback = function(instance)
		instance:SetProperties(propTable)

		instance._rendertexture = raylib.lib.LoadRenderTexture(
			math.max(1, math.floor(instance.Size.X.Offset or 100)),
			math.max(1, math.floor(instance.Size.Y.Offset or 100))
		)

		instance.Changed:Connect(function(prop)
			if prop == "Size" then
				local AbsoluteSize = instance.AbsoluteSize
				instance._rendertexture = raylib.lib.LoadRenderTexture(
					math.max(1, math.floor(AbsoluteSize.X or 100)),
					math.max(1, math.floor(AbsoluteSize.Y or 100))
				)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
