local Instance = require("@Instance")

local StarterPlayer = Instance.new("ScriptContext")

StarterPlayer.InitRenderer = function(renderer, signal, datamodel)
	StarterPlayer:SetProperties({})

	local StarterPlayerScripts = Instance.new("StarterPlayerScripts")
	StarterPlayerScripts.Name = "StarterPlayerScripts"
	StarterPlayerScripts.Parent = StarterPlayer

	local StarterCharacterScripts = Instance.new("StarterCharacterScripts")
	StarterCharacterScripts.Name = "StarterCharacterScripts"
	StarterCharacterScripts.Parent = StarterPlayer
end

return StarterPlayer
