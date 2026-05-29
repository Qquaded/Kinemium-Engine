-- description: "Represents a TextButton in the environment."
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

-- description: "Renders the component."
-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
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
	-- description: "Initializes the TextButton instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		logic:SetupSignals(propTable)

		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the TextButton class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
