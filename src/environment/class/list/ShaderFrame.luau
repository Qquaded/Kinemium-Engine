-- description: "Creates a shader-based frame for custom rendering."
local GuiObject = require("@GuiObject")
local adapter = require("@RaylibAdapter")

local propTable = {
	Name = "ShaderFrame",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Shader = nil,
}

GuiObject.inherit(propTable)

local function clamp(value, minValue, maxValue)
	if value < minValue then
		return minValue
	end
	if value > maxValue then
		return maxValue
	end
	return value
end

propTable.render = function(lib, object, dt, structs, renderer)
	if not object.Visible then
		return
	end

	local pos, size = GuiObject.render(lib, object, dt, structs, renderer)
	object.AbsolutePosition = pos
	object.AbsoluteSize = size

	local scissorX = math.floor(pos.X)
	local scissorY = math.floor(pos.Y)
	local scissorW = math.max(1, math.floor(size.X))
	local scissorH = math.max(1, math.floor(size.Y))

	if object.Shader then
		object._frameCount = (object._frameCount or 0) + 1

		adapter.lib.BeginShaderMode(object.Shader._shader)

		local time = adapter.lib.GetTime()
		local safeW = math.max(size.X, 1)
		local safeH = math.max(size.Y, 1)

		local localX = clamp(lib.GetMouseX() - pos.X, 0, safeW)
		local localY = clamp(lib.GetMouseY() - pos.Y, 0, safeH)
		local mouseUVX = localX / safeW
		local mouseUVY = localY / safeH

		object.Shader:SetUniform("u_time", time, true)
		object.Shader:SetUniform("u_deltaTime", dt, true)
		object.Shader:SetUniform("u_frame", object._frameCount, false)
		object.Shader:SetUniform("u_resolution", { safeW, safeH }, true)
		object.Shader:SetUniform("u_mouse", { localX, localY }, true)
		object.Shader:SetUniform("u_mouseUV", { mouseUVX, mouseUVY }, true)
		object.Shader:SetUniform("u_framePos", { pos.X, pos.Y }, true)
		object.Shader:SetUniform("iTime", time, true)
		object.Shader:SetUniform("iTimeDelta", dt, true)
		object.Shader:SetUniform("iFrame", object._frameCount, false)
		object.Shader:SetUniform("iResolution", { safeW, safeH, 1 }, true)
		object.Shader:SetUniform("iMouse", { localX, localY, localX, localY }, true)
	end
	adapter.lib.DrawRectangle(pos.X, pos.Y, size.X, size.Y, adapter.const.WHITE)

	if object.Shader then
		adapter.lib.EndShaderMode()
	end

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	return pos, size
end

return {
	class = "ShaderFrame",
	render = propTable.render,
	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		return instance
	end,
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
