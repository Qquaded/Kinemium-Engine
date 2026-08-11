local syntax = require("@kilang_sh")
local beautifier = require("@kilang_beautifier")
local completions = require("@kilang_completions")
local autocomplete = require("@kilang_autocomplete")

return {
	id = "luau",
	extensions = { "lua", "luau" },
	commentPrefix = "--",
	blockOpenChars = { "{" },
	blockCloseChars = { "}" },
	blockOpenKeywords = { "then", "do", "function", "repeat" },
	dedentKeywords = { "end" },

	highlight = syntax.highlight,

	format = function(code)
		local ok, parse = pcall(zune.luau.parse, code)
		if not ok or not parse then
			return nil, "parse failed"
		end
		local ok2, formatted = pcall(beautifier.format, parse)
		if not ok2 then
			return nil, formatted
		end
		return formatted
	end,

	parseErrors = function(code)
		local ok, result = pcall(zune.luau.parse, code)
		if not ok or not result then
			return {}
		end
		local errors = {}
		for _, err in ipairs(result.errors or {}) do
			table.insert(errors, { message = err.message, location = err.location })
		end
		return errors
	end,

	parse = function(code)
		local ok, result = pcall(zune.luau.parse, code)
		if ok and result and result.root then
			return result
		end
		return nil
	end,

	getCompletions = function(editor, ast)
		return autocomplete.getCompletions(editor, completions, ast)
	end,
}
