local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local manifold = require("@manifold")

local GeometryService = Instance.new("GeometryService")
GeometryService.ExplorerHidden = true

GeometryService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local registry = require("@Kinemium.registry")
	GeometryService:SetProperties({})
end

return GeometryService
