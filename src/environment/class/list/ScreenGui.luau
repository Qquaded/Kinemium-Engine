-- description: "A GUI container that displays interface elements in screen space."
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")

local proptble = {
	Name = "ScreenGui",
	Enabled = true,
	GravityY = -50,
	GravityX = 0,
	ZIndexBehavior = "Sibling",

	ResetOnSpawn = true,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 400, 0, 400),
	RenderOffset = Vector2.new(0, 0),
	OverrideScreenSize = false,

	BaseClass = "UIContainer",
}

local function profileBegin(name)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:Begin(name)
	end
end

local function profileSetCounter(name, value)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:SetCounter(name, value)
	end
end

local function profileNextFrame()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:NextFrame()
	end
end

local function profileEnd()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:End()
	end
end

return {
	class = "ScreenGui",

	callback = function(instance, renderer)
		proptble.render = function(lib, instance, dt, structs, datamodel)
			if not datamodel then
				return
			end

			local renderWidth, renderHeight

			if IsHeadless then
				renderWidth = 1024
				renderHeight = 1024
			else
				local dpiScale = lib.GetWindowScaleDPI()
				renderWidth = lib.GetRenderWidth() / dpiScale.x
				renderHeight = lib.GetRenderHeight() / dpiScale.y
			end

			if not instance.OverrideScreenSize then
				local currentSize = instance.Size
				local currentAbsSize = instance.AbsoluteSize
				local needsResize = currentSize == nil
					or currentSize.X == nil
					or currentSize.Y == nil
					or currentSize.X.Scale ~= 0
					or currentSize.Y.Scale ~= 0
					or currentSize.X.Offset ~= renderWidth
					or currentSize.Y.Offset ~= renderHeight
					or currentAbsSize == nil
					or currentAbsSize.X ~= renderWidth
					or currentAbsSize.Y ~= renderHeight

				if needsResize then
					instance.Size = UDim2.new(0, renderWidth, 0, renderHeight)
					instance.AbsoluteSize = Vector2.new(renderWidth, renderHeight)
					instance.AbsolutePosition = Vector2.new(0, 0)
				end
			end

			profileBegin("Gui render")
			if not instance.Enabled then
				return
			end
			for _, child in pairs(instance:GetChildren()) do
				if child["render"] then
					child.render(lib, child, dt, structs, renderer, datamodel)
				end
			end
			profileEnd()
		end

		instance:SetProperties(proptble)

		return instance
	end,
}
