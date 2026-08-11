local Instance = require("@Instance")

local ContentProvider = Instance.new("ScriptContext")

ContentProvider.InitRenderer = function(renderer, signal, datamodel)
	ContentProvider:SetProperties({})

	function ContentProvider:PreloadAsync(assets)
		--stub
	end
end

return ContentProvider
