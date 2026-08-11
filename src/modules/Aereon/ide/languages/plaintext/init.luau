return {
	id = "plaintext",
	extensions = {},
	commentPrefix = nil,
	blockOpenChars = {},
	blockCloseChars = {},
	highlight = function(line)
		return { { text = line, category = "default" } }
	end,
}
