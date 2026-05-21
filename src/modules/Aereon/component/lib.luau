local raylib = require("@raylib")
local _structs = raylib.structs
local objects = {}
local StyleSheet = require("./stylesheet")

local _defaultFont = raylib.lib.GetFontDefault()

local comps = {}

export type CreatedComponent = {
	render: (dt: number) -> (),
	set: (prop: string, value: any) -> (),
}

local function create(path, data)
	local styledData = StyleSheet.apply(data)
	if styledData.font == nil and _defaultFont ~= nil then
		styledData.font = _defaultFont
	end
	return require(path)(objects, styledData) :: CreatedComponent
end

comps.badge = function(data)
	return create("./objects/badge", data)
end
comps.cellitem = function(data)
	return create("./objects/cellItem", data)
end
comps.modcard = function(data)
	return create("./objects/modcard", data)
end
comps.UICellList = function(data)
	return create("./objects/UICellList", data)
end
comps.cellparser = function(data)
	return create("./objects/cellparser", data)
end
comps.profiler = function(data)
	return create("./objects/profilergui", data)
end
comps.button = function(data)
	return create("./objects/button", data)
end
comps.servercard = function(data)
	return create("./objects/serverCard", data)
end
comps.keyboard = function(data)
	return create("./objects/keyboard", data)
end
comps.card = function(data)
	return create("./objects/card", data)
end
comps.checkbox = function(data)
	return create("./objects/checkbox", data)
end
comps.colorPicker = function(data)
	return create("./objects/colorPicker", data)
end
comps.divider = function(data)
	return create("./objects/divider", data)
end
comps.githistory = function(data)
	return create("./objects/githistory", data)
end
comps.poll = function(data)
	return create("./objects/poll", data)
end
comps.dropdown = function(data)
	return create("./objects/dropdown", data)
end
comps.pie = function(data)
	return create("./objects/pie", data)
end
comps.frame = function(data)
	return create("./objects/frame", data)
end
comps.graph = function(data)
	return create("./objects/graph", data)
end
comps.iconButton = function(data)
	return create("./objects/iconButton", data)
end
comps.image = function(data)
	return create("./objects/image", data)
end
comps.imageButton = function(data)
	return create("./objects/imageButton", data)
end
comps.textButton = function(data)
	return create("./objects/textButton", data)
end
comps.label = function(data)
	return create("./objects/label", data)
end
comps.menu = function(data)
	return create("./objects/menu", data)
end
comps.apibrowser = function(data)
	return create("./objects/apibrowser", data)
end
comps.itemcard = function(data)
	return create("./objects/itemcard", data)
end
comps.imageTextButton = function(data)
	return create("./objects/imageTextButton", data)
end
comps.progressBar = function(data)
	return create("./objects/progressBar", data)
end
comps.prompt = function(data)
	return create("./objects/prompt", data)
end
comps.navigation = function(data)
	return create("./objects/navigation", data)
end
comps.radioButton = function(data)
	return create("./objects/radioButton", data)
end
comps.slider = function(data)
	return create("./objects/slider", data)
end
comps.spinner = function(data)
	return create("./objects/spinner", data)
end
comps.stepper = function(data)
	return create("./objects/stepper", data)
end
comps.switch = function(data)
	return create("./objects/switch", data)
end
comps.tabs = function(data)
	return create("./objects/tabs", data)
end
comps.textInput = function(data)
	return create("./objects/textInput", data)
end
comps.toggle = function(data)
	return create("./objects/toggle", data)
end
comps.tooltip = function(data)
	return create("./objects/tooltip", data)
end
comps.fileSearch = function(data)
	return create("./objects/filesearch", data)
end
comps.toast = function(data)
	return create("./objects/toast", data)
end
comps.commandPalette = function(data)
	return create("./objects/commandPalette", data)
end
comps.projectCard = function(data)
	return create("./objects/projectCard", data)
end

comps.filePickerButton = function(data)
	return create("./objects/filePickerButton", data)
end

comps.scrollable = function(data)
	return create("./objects/scrollable", data)
end

comps.engineUIContainer = function(data)
	return create("./objects/engineUIContainer", data)
end

comps.hstack = function(data)
	data.direction = "horizontal"
	return create("./objects/stack", data)
end

comps.vstack = function(data)
	data.direction = "vertical"
	return create("./objects/stack", data)
end

comps.flex = function(data)
	return create("./objects/flex", data)
end

-- Styling API
comps.immediate = require("./objects/immediate")
comps.stylesheet = StyleSheet

local activeToasts = 0

function comps.notify(message, toastType, duration)
	local padding = 10
	local toastHeight = 60

	for _, v in pairs(objects) do
		if v.render and debug.info(v.render, "s"):find("toast") then
			activeToasts = activeToasts + 1
		end
	end

	local screenHeight = raylib.lib.GetScreenHeight()

	return comps.toast({
		message = message,
		type = toastType or "info",
		duration = duration or 3,
		x = 20,
		y = screenHeight - (activeToasts + 1) * (toastHeight + padding) - 20,
	})
end

function comps.SetFont(font)
	_defaultFont = font
end

function comps.register(name, factory)
	comps[name] = function(data)
		local styledData = StyleSheet.apply(data)
		if styledData.font == nil and _defaultFont ~= nil then
			styledData.font = _defaultFont
		end
		return factory(objects, styledData)
	end
end

function comps.clear()
	table.clear(objects)
end

function comps:step(dt)
	for _, v in pairs(objects) do
		if v["render"] then
			v.render(dt)
		end
	end
end

export type AereonGui = typeof(comps)

return comps :: AereonGui
