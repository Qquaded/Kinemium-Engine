-- Immediate mode library based on Aereon

export type WindowTab = {
	name: string,
	render: (window: Window) -> (),
}

export type WindowData = {
	headerRender: boolean?,
	step: (window: Window, dt: number) -> (),
	title: string,
	x: number,
	y: number,
	width: number,
	height: number,

	enabled: boolean?,
	DisableClipping: boolean?,
	Scrollable: boolean?,
	Draggable: boolean?,
	Resizable: boolean?,

	showStatusBar: boolean?,
	statusText: string?,

	parent: {
		x: number,
		y: number,
		width: number,
		height: number,
	}?,

	tabs: { WindowTab }?,
	defaultTab: number | boolean?,

	Minimized: boolean?,
	Maximized: boolean?,

	focused: ((window: Window) -> ())?,
	unfocused: ((window: Window) -> ())?,
}

export type Window = {
	title: string,

	x: number,
	y: number,
	width: number,
	height: number,

	id: number,

	headerRender: boolean?,
	DisableClipping: boolean?,
	Scrollable: boolean?,
	Draggable: boolean,
	Resizable: boolean,

	stepped: ((window: Window, dt: number) -> ())?,
	enabled: boolean,

	Closed: boolean,
	Focused: boolean,
	IsDragging: boolean,
	Minimized: boolean,
	Maximized: boolean,

	scrollOffset: any,

	showStatusBar: boolean,
	statusText: string,

	parent: {
		x: number,
		y: number,
		width: number,
		height: number,
	}?,

	tabs: { WindowTab }?,
	activeTab: number?,

	focused: (window: Window) -> (),
	unfocused: (window: Window) -> (),

	_titleBarH: number,
	_tabBarH: number,

	_savedX: number,
	_savedY: number,
	_savedW: number,
	_savedH: number,

	titleRect: {
		x: number,
		y: number,
		width: number,
		height: number,
	}?,

	_contentHeight: number?,
	_scrollArea: any?,

	MoveTo: (self: Window, x: number, y: number) -> (),
	Resize: (self: Window, width: number, height: number) -> (),
	Close: (self: Window) -> (),
	Open: (self: Window) -> (),
	Minimize: (self: Window) -> (),
	Unminimize: (self: Window) -> (),
	ToggleMinimize: (self: Window) -> (),
	Maximize: (self: Window) -> (),
	Unmaximize: (self: Window) -> (),
	ToggleMaximize: (self: Window) -> (),
	SetStatus: (self: Window, text: string?) -> (),
	SetTab: (self: Window, index: number?) -> (),
	SetTabByName: (self: Window, name: string) -> (),
}

export type Widget = {
	x: number?,
	y: number?,
	width: number?,
	height: number?,
}

export type WidgetContext = {
	children: { any },
	window: Window,
	layout: ListLayout?,
}

export type ListConfig = {
	spacing: number?,
	padding: number?,
}

export type ListLayout = {
	x: number,
	y: number,
	width: number,
	height: number,

	spacing: number,
	padding: number,

	_originX: number,

	_prevX: number?,
	_prevY: number?,
	_prevWidth: number?,
	_prevHeight: number?,
}

export type WindowLib = {
	OutlineColor: any,
	OutlineTransparency: number,

	dragged: (window: Window) -> (),
	stepped: (window: Window, dt: number) -> (),
	dragEnd: (window: Window) -> (),
	backgroundDrawed: (window: Window) -> (),

	focused: (window: Window) -> (),
	unfocused: (window: Window) -> (),
	tabChanged: (window: Window, index: number?, tab: WindowTab?) -> (),

	windowClosed: (window: Window) -> (),
	windowMinimized: (window: Window) -> (),
	windowUnminimized: (window: Window) -> (),
	windowMaximized: (window: Window) -> (),
	windowUnmaximized: (window: Window) -> (),

	create: (data: WindowData) -> Window,
	update: (dt: number, selectedTheme: any?) -> (),
	draw: (dt: number, selectedTheme: any?, lib: typeof(require("@raylib").lib)) -> (),

	dragspring: any,
}

local aereon = require("./Aereon/main")
local window = require("./Aereon/window") :: WindowLib
local rect = require("@arect")

local Immco = {}

local stored_game, stored_theme
local windowlib

function Immco:Init(game, theme)
	local lib = {}
	local currentWidget: WidgetContext?

	local windowGraphs = {}
	local windowBuilders = {}

	stored_game = game
	stored_theme = theme

	windowlib = window(adapter.lib, structs, game, theme) :: WindowLib

	windowlib.stepped = function(win: Window, dt: number)
		local builder = windowBuilders[win]
		if not builder then
			return
		end

		currentWidget = {
			children = {},
			window = win,
			layout = nil,
		}

		builder(win)

		for _, child in ipairs(currentWidget.children) do
			if child.render then
				child.render(dt)
			end
		end

		currentWidget = nil
	end

	function lib:Widget(callback, data)
		data = data or {}

		local created = windowlib.create({
			headerRender = data.headerRender ~= false,
			title = data.title or "Immco",
			x = data.x or 0,
			y = data.y or 0,
			width = data.width or 400,
			height = data.height or 400,
			Draggable = data.Draggable ~= false,
			enabled = data.enabled ~= false,
			DisableClipping = data.DisableClipping or false,
			Scrollable = data.Scrollable,
			Resizable = data.Resizable,
			showStatusBar = data.showStatusBar,
			statusText = data.statusText,
			parent = data.parent,
			tabs = data.tabs,
			defaultTab = data.defaultTab,
		})

		windowBuilders[created] = callback

		return created
	end

	function lib:BeginList(config: ListConfig?)
		if not currentWidget then
			return
		end

		config = config or {}

		local padding = config.padding or 10

		local win = currentWidget.window
		local originX = win.x + padding

		currentWidget.layout = {
			x = originX,
			y = win.y + win._titleBarH + 10,

			width = win.width - padding * 2,
			height = 0,

			spacing = config.spacing or 4,
			padding = padding,

			_originX = originX,
		}
	end

	function lib:EndList()
		if not currentWidget then
			return
		end

		if currentWidget.layout then
			currentWidget.window._contentHeight = currentWidget.layout.height
		end

		currentWidget.layout = nil
	end

	function lib:GetPosition()
		if not currentWidget or not currentWidget.layout then
			return vector.create(0, 0)
		end

		local layout = currentWidget.layout

		return vector.create(layout.x, layout.y)
	end

	function lib:GetAvailableWidth()
		if not currentWidget or not currentWidget.layout then
			return 0
		end

		local layout = currentWidget.layout

		return math.max(0, (layout._originX + layout.width) - layout.x)
	end

	function lib:Advance(height: number, width: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout
		width = width or layout.width

		layout._prevX = layout.x
		layout._prevY = layout.y
		layout._prevWidth = width
		layout._prevHeight = height

		layout.x = layout._originX
		layout.y += height + layout.spacing
		layout.height += height + layout.spacing
	end

	function lib:SameLine(spacing: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout

		if not layout._prevX or not layout._prevY or not layout._prevWidth or not layout._prevHeight then
			return
		end

		layout.height -= (layout._prevHeight + layout.spacing)

		layout.y = layout._prevY
		layout.x = layout._prevX + layout._prevWidth + (spacing or math.max(layout.spacing * 2, 8))
	end

	function lib:NewLine(height: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout
		height = height or layout.spacing

		layout.x = layout._originX
		layout.y += height
		layout.height += height
	end

	function lib:Spacing(height: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout
		height = height or layout.spacing

		layout.x = layout._originX
		layout.y += height
		layout.height += height
	end

	function lib:Dummy(width: number, height: number)
		if not currentWidget or not currentWidget.layout then
			return
		end

		lib:Advance(height, width)
	end

	function lib:Indent(amount: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout
		amount = amount or 10

		layout._originX += amount
		layout.x = layout._originX
		layout.width -= amount
	end

	function lib:Unindent(amount: number?)
		if not currentWidget or not currentWidget.layout then
			return
		end

		local layout = currentWidget.layout
		amount = amount or 10

		layout._originX -= amount
		layout.x = layout._originX
		layout.width += amount
	end

	function lib:Separator()
		if not currentWidget or not currentWidget.layout then
			return
		end

		local position = lib:GetPosition()

		table.insert(
			currentWidget.children,
			aereon.gui.divider({
				width = lib:GetAvailableWidth(),
				x = position.x,
				y = position.y,
			})
		)

		lib:Advance(8)
	end

	function lib:Text(text, textSize, width)
		if not currentWidget then
			return
		end

		textSize = textSize or 16

		local position = lib:GetPosition()

		local label = aereon.gui.label({
			text = text,
			x = position.x,
			y = position.y,
			fontSize = textSize,
		})

		table.insert(currentWidget.children, label)

		local actualWidth = width or label.get_rect().width

		lib:Advance(textSize, actualWidth)
	end

	function lib:Image(tex, width, height)
		if not currentWidget then
			return
		end

		width = width or 26
		height = height or 26

		local position = lib:GetPosition()

		table.insert(
			currentWidget.children,
			aereon.gui.image({
				texture = tex,
				x = position.x,
				y = position.y,
				width = width,
				height = height,
			})
		)

		lib:Advance(height, width)
	end

	function lib:TextButton(text, width, height, onClick, fontSize)
		if not currentWidget then
			return
		end

		width = width or 100
		height = height or 32

		local position = lib:GetPosition()

		local button = aereon.gui.textButton({
			text = text or "Button",
			x = position.x,
			y = position.y,
			width = width,
			height = height,
			onClick = onClick,
			fontSize = fontSize,
		})

		table.insert(currentWidget.children, button)

		lib:Advance(height, width)

		return button
	end

	function lib:ProjectCard(data, width, height)
		if not currentWidget then
			return
		end

		data = data or {}

		width = width or lib:GetAvailableWidth()
		height = height or 80

		local position = lib:GetPosition()

		data.x = position.x
		data.y = position.y
		data.width = width
		data.height = height

		local card = aereon.gui.projectCard(data)

		table.insert(currentWidget.children, card)

		lib:Advance(height, width)

		return card
	end

	function lib:ColorPicker(width, height, onChanged)
		if not currentWidget then
			return
		end

		width = width or lib:GetAvailableWidth()
		height = height or width

		local position = lib:GetPosition()

		local picker = aereon.gui.colorPicker({
			x = position.x,
			y = position.y,
			width = width,
			height = height,
			onChanged = onChanged,
		})

		table.insert(currentWidget.children, picker)

		lib:Advance(height, width)

		return picker
	end

	function lib:Graph(width, height, data)
		if not currentWidget then
			return
		end

		width = width or lib:GetAvailableWidth()
		height = height or 120
		data = data or {}

		local position = lib:GetPosition()

		data.x = position.x
		data.y = position.y
		data.width = width
		data.height = height

		local win = currentWidget.window

		windowGraphs[win] = windowGraphs[win] or {}

		local key = data.id or "default"

		local graph = windowGraphs[win][key]

		if not graph then
			graph = aereon.gui.graph(data)
			windowGraphs[win][key] = graph
		else
			graph.set("obj_rect", rect.new(data.x, data.y, data.width, data.height))

			for prop, value in pairs(data) do
				if prop ~= "x" and prop ~= "y" and prop ~= "width" and prop ~= "height" then
					graph.set(prop, value)
				end
			end
		end

		table.insert(currentWidget.children, graph)

		lib:Advance(height, width)

		return graph
	end

	function lib:Poll(data, width, height)
		if not currentWidget then
			return
		end

		width = width or lib:GetAvailableWidth()
		height = height or 300

		local position = lib:GetPosition()

		data = data or {}
		data.x = position.x
		data.y = position.y
		data.width = width
		data.height = height

		local poll = aereon.gui.poll(data)

		table.insert(currentWidget.children, poll)

		lib:Advance(height, width)

		return poll
	end

	return lib
end

function Immco:Render(dt)
	-- windowlib.stepped (set in Init) now does all the per-window
	-- build-and-draw work as part of this single update/draw pass -
	-- there is no separate widget list to walk, nothing to reposition.
	windowlib.update(dt, stored_theme)
	windowlib.draw(dt, stored_theme, adapter.lib)
end

return Immco
