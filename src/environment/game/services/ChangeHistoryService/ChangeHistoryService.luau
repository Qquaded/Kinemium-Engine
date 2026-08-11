local Instance = require("@Instance")
local Signal = require("@Kinemium.signal")

local ChangeHistoryService = Instance.new("ScriptContext")

ChangeHistoryService.InitRenderer = function(renderer, signal, datamodel)
	ChangeHistoryService:SetProperties({
		OnUndo = Signal.new(),
	})

	function ChangeHistoryService:PreloadAsync()
		--stub
	end
end

return ChangeHistoryService
