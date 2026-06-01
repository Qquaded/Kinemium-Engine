-- description: "A clickable 2D button that displays text."
local logic = require("@Kinemium.2dbutton")

local Frame = require("@Frame")
local TextLabel = require("@TextLabel")

local propTable = {
	AutoButtonColor = true,
	ChangeCursorOnHover = true,
	Visible = true,
}
TextLabel.inherit(propTable)
Frame.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize = TextLabel.render(lib, object, dt, structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end

	logic:Step(object, lib)

	return framePos, frameSize
end

return {
	class = "TextButton",
	callback = function(instance)
		logic:SetupSignals(propTable)

		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
