-- devcell
local rl = require("@raylib")
local raylib = rl.lib

local Atext = {}

local languages = {}

function Atext.AddLanguage(name, data)
	languages[name] = data
end

Atext.DrawTextEx = function(font, text, position, fontSize, spacing, color)
	raylib.lib.DrawTextEx(font, text, position, fontSize, spacing, color)
end

return Atext
