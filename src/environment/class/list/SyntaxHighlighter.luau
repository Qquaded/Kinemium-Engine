-- description: "Represents a SyntaxHighlighter in the environment."
local Enum = require("@EnumMap")
local syntax = require("../../../modules/Aereon/ide/syntax")

local propTable = {
	Name = "SyntaxHighlighter",
	BaseClass = "Highlighter",
	Language = Enum.Language.Luau,
}

return {
	class = "SyntaxHighlighter",
	-- description: "Initializes the SyntaxHighlighter instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- description: "Sets the Color."
		-- args: "key: number, color: number, transparency: number"
		function instance:SetColor(key, color, transparency)
			syntax.colors[key] = color:ToRaylib(transparency)
		end

		-- description: "Evaluates."
		-- args: "source: any"
		function instance:Evaluate(source)
			return syntax.highlight(source)
		end

		instance:SetMetadata("Highlighter", syntax)

		return instance
	end,
	-- description: "Inherits the properties of the SyntaxHighlighter class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
