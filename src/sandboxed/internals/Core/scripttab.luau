local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

NewCategoryToolbar:Fire("Script", {
	elements = {
		{
			type = "ImageButton",
			text = "Debugger",
			callback = function() end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Move.png"),
		},
		{
			type = "ImageButton",

			callback = function() end,
			hoverTransparency = 0.5,
			text = "Profiler",
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Rotate.png"),
		},
		{
			type = "ImageButton",
			text = "Threads",
			callback = function() end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Size.png"),
		},
		{
			type = "Separator",
		},
	},
})
