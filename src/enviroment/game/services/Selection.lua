local Instance = require("@Instance")
local Color3 = require("@Color3")
local Vector3 = require("@Vector3")

local Selection = Instance.new("Selection")
Selection.ExplorerHidden = true

Selection.InitRenderer = function(renderer, renderer_signal)
	local selected = {}
	Selection:SetProperties({
		Get = function()
			return selected
		end,

		Add = function(Object)
			table.insert(selected, Object)
		end,

		Remove = function(toRemove)
			for _, object in pairs(toRemove) do
				local index = table.find(selected, object)
				if index then
					table.remove(selected, index)
				end
			end
		end,

		Clear = function()
			table.clear(selected)
		end,

		IsSelected = function(object)
			if table.find(selected, object) then
				return true
			else
				return false
			end
		end,

		Set = function(data)
			selected = {} -- clear
			for _, v in ipairs(data) do
				table.insert(selected, v)
			end
		end,
	})
end

return Selection
