-- devcell
local adapter = require("@raylib")
local raylib = adapter.lib

local Atext = {}

local languages = {}

function Atext.AddLanguage(name, data)
	languages[name] = data
end

Atext.DrawTextEx = function(font, text, position, fontSize, spacing, color)
	adapter.lib.DrawTextEx(font, text, position, fontSize, spacing, color)
end

return Atext
