local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local RunService = require("@RunService")

local DebrisService = Instance.new("Debris")

local ObjectRemoved = signal.new()

local trackedItems = {}

function DebrisService:AddItem(object, lifetime)
	lifetime = lifetime or 5
	trackedItems[object] = {
		ExpireTime = os.clock() + lifetime,
	}
end

function DebrisService:RemoveItem(object)
	trackedItems[object] = nil
end

DebrisService.InitRenderer = function(renderer, renderer_signal, datamodel)
	DebrisService:SetProperties({
		AddItem = DebrisService.AddItem,
		RemoveItem = DebrisService.RemoveItem,
		ObjectRemoved = ObjectRemoved,
	})

	renderer_signal:Connect(function(route, dt)
		if route ~= "Heartbeat" then
			return
		end

		local now = os.clock()
		for object, info in pairs(trackedItems) do
			if not object or object.Parent == nil then
				trackedItems[object] = nil
			elseif now >= info.ExpireTime then
				if object.Destroy then
					object:Destroy()
				else
					object.Parent = nil
				end
				ObjectRemoved:Fire(object)
				trackedItems[object] = nil
			end
		end
	end)
end

return DebrisService
