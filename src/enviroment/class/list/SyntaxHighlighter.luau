local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local syntax = require("../../../modules/Aereon/ide/syntax")

local propTable = {
	Name = "SyntaxHighlighter",
	BaseClass = "Highlighter",
	Language = Enum.Language.Luau,
}

return {
	class = "SyntaxHighlighter",
	callback = function(instance)
		instance:SetProperties(propTable)

		function instance:SetColor(key, color, transparency)
			syntax.colors[key] = color:ToRaylib(transparency)
		end

		function instance:Evaluate(source)
			return syntax.highlight(source)
		end

		instance:SetMetadata("Highlighter", syntax)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
