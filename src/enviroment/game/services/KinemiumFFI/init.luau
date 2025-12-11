local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local KinemiumFFI = Instance.new("KinemiumFFI")
KinemiumFFI.ExplorerHidden = true

-- simple wrapper for zune's FFI
KinemiumFFI.InitRenderer = function(renderer, renderer_signal)
	KinemiumFFI:SetProperties(zune.ffi)
end

return KinemiumFFI
