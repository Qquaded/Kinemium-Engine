local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local Selection = Instance.new("Selection")
Selection.ExplorerHidden = true

Selection.InitRenderer = function(renderer, renderer_signal)
	local selected = {}
	Selection:SetProperties({
		Get = function()
			return selected
		end,

		SelectionAdded = signal.new(),

		Add = function(Object)
			Selection.SelectionAdded:Fire(Object)
			table.insert(selected, Object)
		end,

		SelectionRemoved = signal.new(),

		Remove = function(toRemove)
			Selection.SelectionRemoved:Fire(toRemove)
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
				Selection.SelectionAdded:Fire(v)

				table.insert(selected, v)
			end
		end,
	})
end

return Selection
