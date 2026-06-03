repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar

NewCategoryToolbar:Fire("Plugins", {
	elements = {},
})
