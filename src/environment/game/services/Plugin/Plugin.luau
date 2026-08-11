local Instance = require("@Instance")
local aereon = require("@Aereon")
local adapter = require("@RaylibAdapter")
local Color3 = require("@Color3")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local ScreenGui = require("@ScreenGui")

local Plugin = Instance.new("Plugin")
Plugin._Intents = Enum.PluginIntents.UI

local lib = adapter.lib
local structs = adapter.structs
local arect = require("@arect")

local windowList = {}

local NON_WIDGET_KEYS = {
	notify = true,
	SetFont = true,
	register = true,
	clear = true,
	step = true,
	stylesheet = true,
	immediate = true,
}

local WIDGET_ALIASES = {
	Button = "textButton",
	TextButton = "textButton",
	Label = "label",
	TextLabel = "label",
	TextBox = "textInput",
	TextInput = "textInput",
	Toggle = "switch",
	Switch = "switch",
	CheckBox = "checkbox",
	Checkbox = "checkbox",
	ComboBox = "dropdown",
	Dropdown = "dropdown",
	Tabs = "tabs",
	TabBar = "tabs",
	Slider = "slider",
	ProgressBar = "progressBar",
	Spinner = "spinner",
	Stepper = "stepper",
	ColorPicker = "colorPicker",
	Prompt = "prompt",
	Frame = "frame",
	Card = "card",
	EngineUIContainer = "engineUIContainer",
}

local FRIENDLY_WIDGET_METHODS = {
	CreateButton = "textButton",
	CreateTextButton = "textButton",
	CreateLabel = "label",
	CreateTextLabel = "label",
	CreateTextBox = "textInput",
	CreateTextInput = "textInput",
	CreateToggle = "switch",
	CreateSwitch = "switch",
	CreateCheckbox = "checkbox",
	CreateCheckBox = "checkbox",
	CreateDropdown = "dropdown",
	CreateTabs = "tabs",
	CreateSlider = "slider",
	CreateProgressBar = "progressBar",
	CreateSpinner = "spinner",
	CreateStepper = "stepper",
	CreateColorPicker = "colorPicker",
	CreatePrompt = "prompt",
	CreateFrame = "frame",
	CreateCard = "card",
	CreateEngineUIContainer = "engineUIContainer",
}

local function copyTable(source)
	local new = {}
	for k, v in pairs(source or {}) do
		new[k] = v
	end
	return new
end

local function removeArrayValue(list, value)
	for i = #list, 1, -1 do
		if list[i] == value then
			table.remove(list, i)
			return true
		end
	end
	return false
end

local function colorToRaylib(color, transparency)
	local source = color or Color3.new(1, 1, 1)
	local r, g, b = source:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - (transparency or 0))),
	})
end

local function getRectSize(component)
	if component and component.get_rect then
		local ok, value = pcall(component.get_rect)
		if ok and value then
			return value.width, value.height
		end
	end

	if component and component.get then
		local ok, value = pcall(component.get, "obj_rect")
		if ok and value then
			return value.width, value.height
		end
	end

	return nil, nil
end

local function getAvailableWidgetTypes(gui)
	local types = {}
	for name, factory in pairs(gui) do
		if type(factory) == "function" and not NON_WIDGET_KEYS[name] then
			table.insert(types, name)
		end
	end
	table.sort(types)
	return types
end

local function copyIfMissing(tbl, fromKey, toKey)
	if tbl[toKey] == nil and tbl[fromKey] ~= nil then
		tbl[toKey] = tbl[fromKey]
	end
end

local function unpackXY(value)
	if type(value) ~= "table" then
		return nil, nil
	end

	return value.X or value.x or value.Width or value.width or value[1],
		value.Y or value.y or value.Height or value.height or value[2]
end

local function getSizePair(value, defaultWidth, defaultHeight)
	local width, height = unpackXY(value)
	return width or defaultWidth, height or defaultHeight
end

Plugin.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		Plugin:SetProperties({
			ResetOnSpawn = true,
		})

		repeat
			task.wait()
		until game.GetService

		local window = aereon.window(game)
		local gui = aereon.gui
		local textboxModule = aereon.textbox(nil, game)
		local availableWidgetTypes = getAvailableWidgetTypes(gui)
		local widgetTypeLookup = {}
		local toolbars = {}
		local iconLoader = game:GetService("KinemiumIconLoader")

		for _, widgetType in ipairs(availableWidgetTypes) do
			widgetTypeLookup[widgetType] = widgetType
			widgetTypeLookup[string.lower(widgetType)] = widgetType
		end

		for alias, target in pairs(WIDGET_ALIASES) do
			if widgetTypeLookup[target] then
				widgetTypeLookup[alias] = target
				widgetTypeLookup[string.lower(alias)] = target
			end
		end

		local function resolveWidgetType(widgetType)
			if type(widgetType) ~= "string" then
				error(("Plugin: widget type must be a string, got '%s'"):format(type(widgetType)))
			end

			local resolved = widgetTypeLookup[widgetType] or widgetTypeLookup[string.lower(widgetType)]
			if type(resolved) ~= "string" or NON_WIDGET_KEYS[resolved] then
				error(("Plugin: unknown widget type '%s'"):format(tostring(widgetType)))
			end

			return resolved
		end

		local function mergeEvents(target, source)
			for name, eventSignal in pairs(source or {}) do
				target[name] = eventSignal
			end
		end

		local function bridgeCallback(config, callbackKey, signalNames, candidateKeys)
			local userCallback = nil

			for _, key in ipairs(candidateKeys) do
				if type(config[key]) == "function" then
					userCallback = config[key]
					break
				end
			end

			local eventSignal = signal.new()
			config[callbackKey] = function(...)
				if userCallback then
					userCallback(...)
				end
				eventSignal:Fire(...)
			end

			local events = {}
			for _, name in ipairs(signalNames) do
				events[name] = eventSignal
			end
			return events
		end

		local function normalizeWidgetConfig(widgetType, rawConfig)
			local normalized = copyTable(rawConfig or {})
			local events = {}

			local position = normalized.Position or normalized.position
			if position then
				local x, y = unpackXY(position)
				normalized.x = normalized.x or x or 0
				normalized.y = normalized.y or y or 0
			end

			local size = normalized.Size or normalized.size
			if size then
				local width, height = unpackXY(size)
				normalized.width = normalized.width or width
				normalized.height = normalized.height or height
			end

			copyIfMissing(normalized, "Text", "text")
			copyIfMissing(normalized, "Title", "title")
			copyIfMissing(normalized, "Message", "message")
			copyIfMissing(normalized, "PlaceholderText", "placeholder")
			copyIfMissing(normalized, "FontSize", "fontSize")
			copyIfMissing(normalized, "BackgroundColor3", "backgroundColor")
			copyIfMissing(normalized, "TextColor3", "textColor")
			copyIfMissing(normalized, "Visible", "visible")
			copyIfMissing(normalized, "ZIndex", "zindex")

			if widgetType == "textInput" then
				copyIfMissing(normalized, "Value", "text")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onChange",
						{ "Changed", "TextChanged" },
						{ "onChange", "OnChange", "onChanged", "OnChanged", "Changed", "TextChanged", "Callback" }
					)
				)
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onSubmit",
						{ "Submitted", "ReturnPressed" },
						{ "onSubmit", "OnSubmit", "Submitted", "ReturnPressed" }
					)
				)
				mergeEvents(
					events,
					bridgeCallback(normalized, "onFocus", { "Focused" }, { "onFocus", "OnFocus", "Focused" })
				)
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onBlur",
						{ "Blurred", "FocusLost" },
						{ "onBlur", "OnBlur", "Blurred", "FocusLost" }
					)
				)
			elseif widgetType == "dropdown" then
				copyIfMissing(normalized, "Items", "options")
				copyIfMissing(normalized, "Options", "options")
				copyIfMissing(normalized, "SelectedIndex", "selectedIndex")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onSelect",
						{ "Changed", "SelectionChanged" },
						{ "onSelect", "OnSelect", "Changed", "SelectionChanged", "Callback" }
					)
				)
			elseif widgetType == "tabs" then
				copyIfMissing(normalized, "Items", "tabs")
				copyIfMissing(normalized, "Tabs", "tabs")
				copyIfMissing(normalized, "SelectedIndex", "activeIndex")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onTabChange",
						{ "Changed", "TabChanged" },
						{ "onTabChange", "OnTabChange", "Changed", "TabChanged", "Callback" }
					)
				)
			elseif widgetType == "slider" then
				copyIfMissing(normalized, "Value", "value")
				copyIfMissing(normalized, "MinValue", "min")
				copyIfMissing(normalized, "MaxValue", "max")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onChanged",
						{ "Changed" },
						{ "onChanged", "OnChanged", "Changed", "Callback" }
					)
				)
			elseif widgetType == "progressBar" then
				copyIfMissing(normalized, "Value", "progress")
				copyIfMissing(normalized, "Progress", "progress")
			elseif widgetType == "switch" or widgetType == "checkbox" or widgetType == "toggle" then
				copyIfMissing(normalized, "Value", "value")
				copyIfMissing(normalized, "Checked", "value")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onChanged",
						{ "Changed", "Toggled" },
						{ "onChanged", "OnChanged", "Changed", "Toggled", "Callback" }
					)
				)
			elseif widgetType == "colorPicker" then
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onChanged",
						{ "Changed", "ColorChanged" },
						{ "onChanged", "OnChanged", "Changed", "ColorChanged", "Callback" }
					)
				)
			elseif widgetType == "stepper" then
				copyIfMissing(normalized, "Value", "value")
				copyIfMissing(normalized, "MinValue", "min")
				copyIfMissing(normalized, "MaxValue", "max")
				mergeEvents(
					events,
					bridgeCallback(
						normalized,
						"onChanged",
						{ "Changed" },
						{ "onChanged", "OnChanged", "Changed", "Callback" }
					)
				)
			elseif widgetType == "prompt" then
				mergeEvents(
					events,
					bridgeCallback(normalized, "onClose", { "Closed" }, { "onClose", "OnClose", "Closed", "Callback" })
				)
			else
				if
					widgetType == "button"
					or widgetType == "textButton"
					or widgetType == "iconButton"
					or widgetType == "imageButton"
					or widgetType == "imageTextButton"
				then
					mergeEvents(
						events,
						bridgeCallback(
							normalized,
							"onClick",
							{ "Activated", "Clicked" },
							{ "onClick", "OnClick", "Activated", "Clicked", "Callback" }
						)
					)
				elseif widgetType == "engineUIContainer" then
					copyIfMissing(normalized, "Instance", "instance")
					copyIfMissing(normalized, "Target", "target")
					copyIfMissing(normalized, "DataModel", "datamodel")
					copyIfMissing(normalized, "Game", "game")
					copyIfMissing(normalized, "Renderer", "renderer")
				end
			end

			return normalized, events
		end

		local function componentSet(component, prop, value)
			if not component then
				return false
			end

			if prop == "text" and component.setText then
				component.setText(value)
				return true
			end
			if prop == "value" and component.setValue then
				component.setValue(value)
				return true
			end
			if prop == "selectedIndex" and component.setSelected then
				component.setSelected(value)
				return true
			end
			if prop == "activeIndex" and component.setActive then
				component.setActive(value)
				return true
			end
			if prop == "progress" and component.setProgress then
				component.setProgress(value)
				return true
			end
			if prop == "buttons" and component.setButtons then
				component.setButtons(value)
				return true
			end
			if prop == "bodyRenderer" and component.setBodyRenderer then
				component.setBodyRenderer(value)
				return true
			end
			if prop == "instance" and component.setInstance then
				component.setInstance(value)
				return true
			end

			if component.set then
				local ok = pcall(component.set, prop, value)
				if ok then
					return true
				end
			end

			return false
		end

		local function componentGet(component, prop)
			if not component then
				return nil
			end

			if prop == "text" and component.getText then
				return component.getText()
			end
			if prop == "value" and component.getValue then
				return component.getValue()
			end
			if prop == "progress" and component.getProgress then
				return component.getProgress()
			end
			if prop == "selectedIndex" and component.getSelected then
				return select(1, component.getSelected())
			end
			if prop == "selectedItem" and component.getSelected then
				return select(2, component.getSelected())
			end
			if prop == "color" and component.getColor then
				return component.getColor()
			end
			if prop == "alpha" and component.getAlpha then
				return component.getAlpha()
			end
			if prop == "instance" and component.getInstance then
				return component.getInstance()
			end

			if component.get then
				local ok, value = pcall(component.get, prop)
				if ok then
					return value
				end
			end

			return nil
		end

		local function attachFriendlyWidgetApi(widget, widgetType, events)
			widget.Events = events or {}

			for name, eventSignal in pairs(widget.Events or {}) do
				widget[name] = eventSignal
			end

			function widget:Connect(eventName, callback)
				local eventSignal = self.Events[eventName]
				if not eventSignal then
					error(("Plugin widget '%s' has no event '%s'"):format(self.WidgetType, tostring(eventName)))
				end
				return eventSignal:Connect(callback)
			end

			function widget:SetText(value)
				self:Set("text", value)
				return self
			end

			function widget:GetText()
				return self:Get("text")
			end

			function widget:SetValue(value)
				if widgetType == "progressBar" then
					self:Set("progress", value)
				elseif widgetType == "dropdown" then
					self:Set("selectedIndex", value)
				elseif widgetType == "tabs" then
					self:Set("activeIndex", value)
				else
					self:Set("value", value)
				end
				return self
			end

			function widget:GetValue()
				if widgetType == "progressBar" then
					return self:Get("progress")
				end
				if widgetType == "dropdown" then
					return self:Get("selectedIndex")
				end
				if widgetType == "tabs" then
					return self:Get("activeIndex")
				end
				return self:Get("value")
			end

			function widget:Focus()
				if self.component and self.component.focus then
					self.component.focus()
				end
				return self
			end

			function widget:Blur()
				if self.component and self.component.blur then
					self.component.blur()
				end
				return self
			end

			function widget:Submit()
				if self.component and self.component.submit then
					self.component.submit()
				end
				return self
			end

			function widget:SetItems(items)
				if widgetType == "tabs" then
					self:Set("tabs", items)
				else
					self:Set("options", items)
				end
				return self
			end

			function widget:GetItems()
				if widgetType == "tabs" then
					return self:Get("tabs")
				end
				return self:Get("options")
			end

			function widget:SetSelectedIndex(index)
				if widgetType == "tabs" then
					self:Set("activeIndex", index)
				else
					self:Set("selectedIndex", index)
				end
				return self
			end

			function widget:GetSelectedIndex()
				if widgetType == "tabs" then
					return self:Get("activeIndex")
				end
				return self:Get("selectedIndex")
			end

			function widget:GetSelectedItem()
				return self:Get("selectedItem")
			end

			function widget:SetProgress(value)
				self:Set("progress", value)
				return self
			end

			function widget:GetProgress()
				return self:Get("progress")
			end

			function widget:SetInstance(instance)
				self:Set("instance", instance)
				return self
			end

			function widget:GetInstance()
				return self:Get("instance")
			end

			local destroySignals = {}
			for _, eventSignal in pairs(widget.Events) do
				if not table.find(destroySignals, eventSignal) then
					table.insert(destroySignals, eventSignal)
				end
			end

			local oldDestroy = widget.Destroy
			function widget:Destroy()
				if oldDestroy then
					oldDestroy(self)
				end

				for _, eventSignal in ipairs(destroySignals) do
					if eventSignal and eventSignal.Destroy then
						eventSignal:Destroy()
					end
				end
			end
		end

		local function normalizeCreationStructure(structure)
			local normalized = {}
			for name, widgetConfig in pairs(structure or {}) do
				local copied = copyTable(widgetConfig)
				if copied.comp then
					copied.comp = resolveWidgetType(copied.comp)
				end
				normalized[name] = copied
			end
			return normalized
		end

		local function resolveToolbarIcon(icon)
			if not icon or not iconLoader then
				return nil
			end

			if type(icon) == "table" and icon.texture then
				return icon
			end

			if type(icon) ~= "string" then
				return nil
			end

			local path = icon
			if iconLoader.Get then
				local registered = iconLoader.Get(icon)
				if registered then
					path = registered
				end
			end

			if iconLoader.ToTexture then
				local ok, textureData = pcall(iconLoader.ToTexture, path)
				if ok then
					return textureData
				end
			end

			return nil
		end

		local function attachFriendlyFactories(target, createFn)
			function target:CreateAereonWidget(widgetType, config, options)
				return createFn(widgetType, config, options)
			end

			function target:SpawnWidget(widgetType, config, options)
				return createFn(widgetType, config, options)
			end

			function target:SpawnAereonWidget(widgetType, config, options)
				return createFn(widgetType, config, options)
			end

			for methodName, widgetType in pairs(FRIENDLY_WIDGET_METHODS) do
				target[methodName] = function(self, config, options)
					return createFn(widgetType, config, options)
				end
			end
		end

		local function createPluginTextInput(config)
			local componentRect = arect.new(
				config.x or config[1] or 0,
				config.y or config[2] or 0,
				config.width or config[3] or 220,
				config.height or config[4] or 34
			)

			local textbox = textboxModule.new({
				placeholder = config.placeholder,
				fontSize = config.fontSize,
				backgroundColor = config.backgroundColor,
				textColor = config.textColor,
				placeholderColor = config.placeholderColor,
				borderColor = config.borderColor,
				focusBorderColor = config.focusBorderColor,
				selectionColor = config.selectionColor,
				label = config.label,
				labelPosition = config.labelPosition,
				labelWidth = config.labelWidth,
				labelGap = config.labelGap,
				prefix = config.prefix,
				suffix = config.suffix,
				prefixGap = config.prefixGap,
				suffixGap = config.suffixGap,
				numeric = config.numeric,
				numericMin = config.numericMin,
				numericMax = config.numericMax,
				numericStep = config.numericStep,
				numericPrecision = config.numericPrecision,
				showStepButtons = config.showStepButtons,
				slider = config.slider,
				sliderWidth = config.sliderWidth,
				sliderMin = config.sliderMin,
				sliderMax = config.sliderMax,
				sliderStep = config.sliderStep,
				sliderPosition = config.sliderPosition,
				readOnly = config.readOnly,
				maxLength = config.maxLength,
				validator = config.validator,
				selectAllOnFocus = config.selectAllOnFocus,
				blurOnSubmit = config.blurOnSubmit,
				clearOnEscape = config.clearOnEscape,
				escapeBlurs = config.escapeBlurs,
				onSubmit = config.onSubmit,
				onFocus = config.onFocus,
				onBlur = config.onBlur,
			})

			if config.text ~= nil then
				local onChange = textbox.onChange
				textbox.onChange = nil
				textbox:setText(tostring(config.text))
				textbox.onChange = onChange
			end

			local function applyThemeColor(prop, value)
				if not value then
					return false
				end

				if prop == "backgroundColor" then
					textbox.theme.background = value:ToRaylib(textbox.BackgroundTransparency or 0)
					return true
				end
				if prop == "textColor" then
					textbox.TextColor = value
					textbox.theme.text = value:ToRaylib(0)
					return true
				end
				if prop == "placeholderColor" then
					textbox.theme.placeholder = value:ToRaylib(0)
					return true
				end
				if prop == "borderColor" then
					textbox.theme.border = value:ToRaylib(textbox.BorderTransparency or 0)
					return true
				end
				if prop == "focusBorderColor" then
					textbox.theme.focusBorder = value:ToRaylib(textbox.BorderTransparency or 0)
					return true
				end
				if prop == "selectionColor" then
					textbox.theme.selection = value:ToRaylib(0.5)
					return true
				end

				return false
			end

			local wrapper = {}

			wrapper.set = function(prop, value)
				if prop == "obj_rect" then
					componentRect = value
					return wrapper
				end
				if prop == "text" or prop == "value" then
					textbox:setText(tostring(value or ""))
					return wrapper
				end
				if prop == "placeholder" then
					textbox.placeholder = tostring(value or "")
					return wrapper
				end
				if prop == "fontSize" then
					textbox.fontSize = value or textbox.fontSize
					return wrapper
				end

				if applyThemeColor(prop, value) then
					return wrapper
				end

				textbox[prop] = value
				return wrapper
			end

			wrapper.get = function(prop)
				if prop == "obj_rect" then
					return componentRect
				end
				if prop == "text" or prop == "value" then
					return textbox:getText()
				end
				if prop == "focused" or prop == "isFocused" then
					return textbox.isFocused
				end

				return textbox[prop]
			end

			wrapper.get_rect = function()
				return componentRect
			end

			wrapper.render = function(_dt)
				textbox:drawWithExtras(componentRect.x, componentRect.y, componentRect.width, componentRect.height)
			end

			wrapper.setText = function(value)
				textbox:setText(tostring(value or ""))
				return wrapper
			end

			wrapper.getText = function()
				return textbox:getText()
			end

			wrapper.focus = function()
				textbox:focus()
				return wrapper
			end

			wrapper.blur = function()
				textbox:blur()
				return wrapper
			end

			wrapper.submit = function()
				textbox:submit()
				return wrapper
			end

			return wrapper
		end

		local function createRawWidget(widgetType, config)
			local resolvedType = resolveWidgetType(widgetType)
			local normalizedConfig = select(1, normalizeWidgetConfig(resolvedType, config))
			if resolvedType == "textInput" then
				return createPluginTextInput(copyTable(normalizedConfig or {}))
			end
			local factory = gui[resolvedType]

			return factory(copyTable(normalizedConfig or {}))
		end

		local function getWindowContentOrigin(windowData)
			local x = windowData.x + (windowData.ContentPaddingX or 0)
			local y = windowData.y + (windowData.ContentPaddingY or 0)

			if windowData.headerRender ~= false then
				y += 28
			end

			return x, y
		end

		local function makeMountedWidget(windowData, topRenderables, allWidgets, widgetType, config, options)
			options = options or {}
			local resolvedType = resolveWidgetType(widgetType)
			local normalizedConfig, events = normalizeWidgetConfig(resolvedType, config)
			local component = createRawWidget(resolvedType, normalizedConfig)
			local widget = {
				WidgetType = resolvedType,
				component = component,
				x = normalizedConfig.x or normalizedConfig[1] or 0,
				y = normalizedConfig.y or normalizedConfig[2] or 0,
				width = normalizedConfig.width or normalizedConfig[3],
				height = normalizedConfig.height or normalizedConfig[4],
				absolute = options.absolute == true or normalizedConfig.Absolute == true,
				enabled = options.enabled ~= false and normalizedConfig.visible ~= false,
				order = options.order or options.zindex or normalizedConfig.zindex or 0,
				destroyed = false,
				_parentList = nil,
				Events = events,
			}

			function widget:_mountTo(list)
				if self._parentList then
					removeArrayValue(self._parentList, self)
				end

				self._parentList = list
				table.insert(list, self)
			end

			function widget:_applyRect(baseX, baseY, yOffset)
				if self.absolute then
					baseX = 0
					baseY = 0
				end

				local width = self.width
				local height = self.height

				if width == nil or height == nil then
					local dynamicW, dynamicH = getRectSize(self.component)
					width = width or dynamicW or 0
					height = height or dynamicH or 0
				end

				if self.component and self.component.set then
					self.component.set(
						"obj_rect",
						arect.new(baseX + self.x, baseY + self.y + (yOffset or 0), width, height)
					)
				end
			end

			function widget:_render(dt, baseX, baseY, yOffset)
				if self.destroyed or not self.enabled then
					return
				end

				self:_applyRect(baseX, baseY, yOffset)

				if self.component and self.component.render then
					self.component.render(dt)
				end
			end

			function widget:render(dt, _windowData, baseX, baseY)
				self:_render(dt, baseX, baseY, 0)
			end

			function widget:GetComponent()
				return self.component
			end

			function widget:GetRect()
				local width = self.width
				local height = self.height
				if width == nil or height == nil then
					local dynamicW, dynamicH = getRectSize(self.component)
					width = width or dynamicW or 0
					height = height or dynamicH or 0
				end
				return {
					x = self.x,
					y = self.y,
					width = width,
					height = height,
				}
			end

			function widget:Get(prop)
				if prop == "x" or prop == "y" or prop == "width" or prop == "height" then
					return self[prop]
				end
				if prop == "enabled" then
					return self.enabled
				end
				if prop == "absolute" then
					return self.absolute
				end
				if prop == "order" or prop == "zindex" then
					return self.order
				end

				local value = componentGet(self.component, prop)
				if value ~= nil then
					return value
				end

				return nil
			end

			function widget:Set(prop, value)
				if prop == "x" or prop == "y" or prop == "width" or prop == "height" then
					self[prop] = value
					return self
				end
				if prop == "enabled" or prop == "visible" then
					self.enabled = not not value
					return self
				end
				if prop == "absolute" then
					self.absolute = not not value
					return self
				end
				if prop == "order" or prop == "zindex" then
					self.order = value or 0
					return self
				end

				if componentSet(self.component, prop, value) then
					return self
				end
				return self
			end

			function widget:Destroy()
				if self.destroyed then
					return
				end

				self.destroyed = true
				self.enabled = false

				if self._parentList then
					removeArrayValue(self._parentList, self)
					self._parentList = nil
				end

				removeArrayValue(allWidgets, self)
			end

			if options.mount ~= false then
				widget:_mountTo(topRenderables)
			end

			table.insert(allWidgets, widget)
			attachFriendlyWidgetApi(widget, resolvedType, events)
			return widget
		end

		local function createWindowHandle(config)
			local windowConfig = copyTable(config or {})
			local userStep = windowConfig.step
			local topRenderables = {}
			local allWidgets = {}
			local scrollViews = {}

			local windowData
			local wrapper
			local function renderPluginUI(dt)
				local baseX, baseY = getWindowContentOrigin(wrapper)

				table.sort(topRenderables, function(a, b)
					return (a.order or 0) < (b.order or 0)
				end)

				for _, renderable in ipairs(topRenderables) do
					if
						renderable
						and renderable.render
						and not renderable.destroyed
						and renderable.enabled ~= false
					then
						renderable:render(dt, windowData, baseX, baseY)
					end
				end
			end

			windowConfig.step = function(currentWindow, dt)
				renderPluginUI(dt)
				if userStep then
					userStep(currentWindow, dt)
				end
			end

			wrapper = window.create(windowConfig)
			windowData = Instance.new("PluginGui")
			windowData.BaseClass = "Instance"
			windowData.ClassName = windowData.ClassName or "PluginGui"
			windowData.ContentPaddingX = windowConfig.contentPaddingX or 0
			windowData.ContentPaddingY = windowConfig.contentPaddingY or 0
			windowData.PluginGuiId = windowConfig.pluginGuiId or windowConfig.id
			windowData.Title = windowConfig.title or "Plugin Window"
			windowData.Enabled = windowConfig.enabled ~= false
			windowData.Parent = game:GetService("PluginGuiService")
			windowData.Window = wrapper

			table.insert(windowList, { windowData, wrapper })

			function windowData:SetContentPadding(paddingX, paddingY)
				self.ContentPaddingX = paddingX or 0
				self.ContentPaddingY = paddingY or paddingX or 0
				return self
			end

			function windowData:SetTitle(title)
				self.title = title or self.title
				self.Title = self.title
				return self
			end

			function windowData:BindToClose(callback)
				self._onClose = callback
				return self
			end

			local rawClose = wrapper.Close
			function windowData:Close()
				if self._onClose then
					pcall(self._onClose, self)
				end
				rawClose(self)
				self.Enabled = false
			end

			local rawOpen = wrapper.Open
			function windowData:Open()
				rawOpen(self)
				self.enabled = true
				self.Enabled = true
			end

			function windowData:Show()
				self:Open()
				return self
			end

			function windowData:Hide()
				self:Close()
				return self
			end

			function windowData:SetEnabled(value)
				if value then
					wrapper:Show()
				else
					wrapper:Hide()
				end
				return wrapper
			end

			function windowData:RequestRaise()
				wrapper.enabled = true
				wrapper.Enabled = true
				if wrapper.Closed then
					wrapper:Open()
				end
				return wrapper
			end

			function windowData:GetContentOrigin()
				return getWindowContentOrigin(wrapper)
			end

			function windowData:CreateWidget(widgetType, widgetConfig, options)
				options = copyTable(options or {})
				local container = options.container
				options.container = nil

				if container then
					options.mount = false
				end

				local widget = makeMountedWidget(wrapper, topRenderables, allWidgets, widgetType, widgetConfig, options)

				if container and container.AddWidget then
					container:AddWidget(widget)
				end

				return widget
			end

			function windowData:MountWidget(widget)
				if type(widget) ~= "table" or not widget._mountTo then
					return nil
				end
				widget:_mountTo(topRenderables)
				return widget
			end

			function windowData:CreateWidgetTree(structure, options)
				local created = {}
				local renderList = {}

				for name, widgetConfig in pairs(structure or {}) do
					local copied = copyTable(widgetConfig)
					local typeName = copied.comp and resolveWidgetType(copied.comp) or nil
					if typeName then
						copied.comp = typeName
						created[name] = self:CreateWidget(typeName, copied, options)
						table.insert(renderList, name)
					end
				end

				table.sort(renderList, function(a, b)
					return (created[a].order or 0) < (created[b].order or 0)
				end)

				created.get = function(name)
					return created[name]
				end

				created.setprop = function(name, prop, value)
					local target = created[name]
					if target and target.Set then
						target:Set(prop, value)
					end
				end

				created.render = function(dt, excluded)
					local baseX, baseY = getWindowContentOrigin(wrapper)

					for _, name in ipairs(renderList) do
						if excluded and table.find(excluded, name) then
							continue
						end
						local target = created[name]
						if target and target._render then
							target:_render(dt, baseX, baseY, 0)
						end
					end
				end

				created.destroy = function()
					for _, name in ipairs(renderList) do
						local target = created[name]
						if target and target.Destroy then
							target:Destroy()
						end
					end
				end

				return created
			end

			function windowData:CreateScrollView(configData)
				local scrollConfig = copyTable(configData or {})
				local scrollView = {
					x = scrollConfig.x or 0,
					y = scrollConfig.y or 0,
					width = scrollConfig.width or 220,
					height = scrollConfig.height or 220,
					padding = scrollConfig.padding or 0,
					scrollY = scrollConfig.scrollY or 0,
					contentHeight = scrollConfig.contentHeight,
					wheelStep = scrollConfig.wheelStep or 26,
					showScrollbar = scrollConfig.showScrollbar ~= false,
					scrollbarWidth = scrollConfig.scrollbarWidth or 5,
					scrollbarColor = scrollConfig.scrollbarColor or Color3.new(1, 1, 1),
					scrollbarTransparency = scrollConfig.scrollbarTransparency or 0.6,
					trackColor = scrollConfig.trackColor or Color3.new(0, 0, 0),
					trackTransparency = scrollConfig.trackTransparency or 0.75,
					backgroundColor = scrollConfig.backgroundColor,
					backgroundTransparency = scrollConfig.backgroundTransparency,
					order = scrollConfig.order or scrollConfig.zindex or 0,
					absolute = scrollConfig.absolute == true,
					clip = scrollConfig.clip ~= false,
					enabled = scrollConfig.enabled ~= false,
					children = {},
					destroyed = false,
				}

				local function getChildBottom(widget)
					local rect = widget:GetRect()
					return rect.y + rect.height
				end

				function scrollView:_getContentHeight()
					if self.contentHeight ~= nil then
						return self.contentHeight
					end

					local maxBottom = 0
					for _, child in ipairs(self.children) do
						if not child.destroyed and child.enabled ~= false then
							maxBottom = math.max(maxBottom, getChildBottom(child))
						end
					end
					return maxBottom
				end

				function scrollView:AddWidget(widget)
					if type(widget) ~= "table" or not widget._mountTo then
						error("Plugin ScrollView:AddWidget expects a widget returned by CreateWidget")
					end

					widget:_mountTo(self.children)
					return widget
				end

				function scrollView:CreateWidget(widgetType, widgetConfig, widgetOptions)
					local options = copyTable(widgetOptions or {})
					options.mount = false

					local widget =
						makeMountedWidget(windowData, topRenderables, allWidgets, widgetType, widgetConfig, options)

					return self:AddWidget(widget)
				end

				function scrollView:GetWidgets()
					return self.children
				end

				function scrollView:GetWidgetAliases()
					return Plugin:GetWidgetAliases()
				end

				function scrollView:Set(prop, value)
					if prop == "x" or prop == "y" or prop == "width" or prop == "height" or prop == "padding" then
						self[prop] = value
					elseif prop == "scroll" or prop == "scrollY" then
						self.scrollY = math.max(0, value or 0)
					elseif prop == "enabled" or prop == "visible" then
						self.enabled = not not value
					elseif prop == "absolute" then
						self.absolute = not not value
					elseif prop == "order" or prop == "zindex" then
						self.order = value or 0
					else
						self[prop] = value
					end
					return self
				end

				function scrollView:Get(prop)
					if prop == "scroll" then
						return self.scrollY
					end
					return self[prop]
				end

				function scrollView:SetScroll(value)
					self.scrollY = math.max(0, value or 0)
					return self
				end

				function scrollView:ScrollTo(value)
					return self:SetScroll(value)
				end

				function scrollView:ClearWidgets(destroyChildren)
					for i = #self.children, 1, -1 do
						local child = self.children[i]
						if destroyChildren and child.Destroy then
							child:Destroy()
						else
							child._parentList = nil
							table.remove(self.children, i)
						end
					end
				end

				function scrollView:Destroy()
					if self.destroyed then
						return
					end

					self.destroyed = true
					self.enabled = false
					self:ClearWidgets(false)
					removeArrayValue(topRenderables, self)
					removeArrayValue(scrollViews, self)
				end

				function scrollView:render(dt, _windowState, baseX, baseY)
					if self.destroyed or not self.enabled then
						return
					end

					local viewX = self.absolute and self.x or (baseX + self.x)
					local viewY = self.absolute and self.y or (baseY + self.y)
					local viewWidth = self.width
					local viewHeight = self.height

					if
						self.backgroundColor
						and self.backgroundTransparency ~= nil
						and self.backgroundTransparency < 1
					then
						lib.DrawRectangleRec(
							arect:translate(arect.new(viewX, viewY, viewWidth, viewHeight)),
							colorToRaylib(self.backgroundColor, self.backgroundTransparency)
						)
					end

					local padding = self.padding
					local innerX = viewX + padding
					local innerY = viewY + padding
					local innerWidth = math.max(1, viewWidth - padding * 2)
					local innerHeight = math.max(1, viewHeight - padding * 2)

					local contentHeight = math.max(0, self:_getContentHeight())
					local maxScroll = math.max(0, contentHeight - innerHeight)
					self.scrollY = math.clamp(self.scrollY, 0, maxScroll)

					local viewport = arect.new(viewX, viewY, viewWidth, viewHeight)

					if arect.MouseIsInRect(viewport) then
						local wheel = lib.GetMouseWheelMove()
						if wheel ~= 0 then
							self.scrollY = math.clamp(self.scrollY - wheel * self.wheelStep, 0, maxScroll)
						end
					end

					if self.clip then
						lib.BeginScissorMode(viewX, viewY, viewWidth, viewHeight)
					end

					table.sort(self.children, function(a, b)
						return (a.order or 0) < (b.order or 0)
					end)

					for _, child in ipairs(self.children) do
						if child and child._render then
							child:_render(dt, innerX, innerY, -self.scrollY)
						end
					end

					if self.clip then
						lib.EndScissorMode()
					end

					if self.showScrollbar and maxScroll > 0 then
						local trackX = viewX + viewWidth - self.scrollbarWidth - 2
						local trackY = viewY + 2
						local trackHeight = viewHeight - 4

						lib.DrawRectangleRec(
							arect:translate(arect.new(trackX, trackY, self.scrollbarWidth, trackHeight)),
							colorToRaylib(self.trackColor, self.trackTransparency)
						)

						local thumbHeight = math.max(20, (innerHeight / contentHeight) * trackHeight)
						local thumbTravel = trackHeight - thumbHeight
						local thumbY = trackY + (self.scrollY / maxScroll) * thumbTravel

						lib.DrawRectangleRec(
							arect:translate(arect.new(trackX, thumbY, self.scrollbarWidth, thumbHeight)),
							colorToRaylib(self.scrollbarColor, self.scrollbarTransparency)
						)
					end
				end

				table.insert(topRenderables, scrollView)
				table.insert(scrollViews, scrollView)
				attachFriendlyFactories(scrollView, function(widgetType, widgetConfig, widgetOptions)
					return scrollView:CreateWidget(widgetType, widgetConfig, widgetOptions)
				end)
				return scrollView
			end

			function windowData:AddRenderCallback(callback, order)
				local renderable = {
					order = order or 0,
					enabled = true,
					destroyed = false,
				}

				function renderable:SetEnabled(value)
					self.enabled = not not value
				end

				function renderable:Destroy()
					if self.destroyed then
						return
					end
					self.destroyed = true
					self.enabled = false
					removeArrayValue(topRenderables, self)
				end

				function renderable:render(dt, currentWindow, baseX, baseY)
					callback(dt, currentWindow, baseX, baseY)
				end

				table.insert(topRenderables, renderable)
				return renderable
			end

			function windowData:GetWidgets()
				return allWidgets
			end

			function windowData:GetScrollViews()
				return scrollViews
			end

			function windowData:ClearWidgets(destroyWidgets)
				for i = #allWidgets, 1, -1 do
					local widget = allWidgets[i]
					if destroyWidgets == false then
						widget.destroyed = true
						widget.enabled = false
						if widget._parentList then
							removeArrayValue(widget._parentList, widget)
							widget._parentList = nil
						end
						table.remove(allWidgets, i)
					else
						widget:Destroy()
					end
				end

				for i = #scrollViews, 1, -1 do
					local scrollView = scrollViews[i]
					scrollView:Destroy()
				end

				for i = #topRenderables, 1, -1 do
					local item = topRenderables[i]
					if item.destroyed ~= false and item.destroyed ~= nil then
						table.remove(topRenderables, i)
					end
				end
			end

			function windowData:Destroy()
				self:ClearWidgets(true)
				self.Closed = true
				self.enabled = false
				self.Enabled = false
			end

			function windowData:GetAvailableWidgets()
				return availableWidgetTypes
			end

			function windowData:GetWidgetAliases()
				return Plugin:GetWidgetAliases()
			end

			attachFriendlyFactories(windowData, function(widgetType, widgetConfig, widgetOptions)
				return windowData:CreateWidget(widgetType, widgetConfig, widgetOptions)
			end)

			local mountedContainer = nil

			local function getContentSize()
				local paddingX = (windowConfig.contentPaddingX or 0) * 2
				local extraY = (windowConfig.contentPaddingY or 0) * 2
					+ (windowConfig.headerRender ~= false and 28 or 0)
				return wrapper.width - paddingX, wrapper.height - extraY
			end

			-- gui rendering fix for now
			local ScreenGuiObj = Instance.new("ScreenGui")
			ScreenGuiObj.Parent = windowData
			ScreenGui.callback(ScreenGuiObj, renderer)

			mountedContainer = windowData:CreateWidget("engineUIContainer", {
				Instance = ScreenGuiObj,
				width = 0,
				height = 0,
				Renderer = renderer,
				datamodel = game,
			})

			mountedContainer._resizeSync = windowData:AddRenderCallback(function()
				if not mountedContainer or mountedContainer.destroyed then
					return
				end

				local cw, ch = getContentSize()
				if mountedContainer.width ~= cw or mountedContainer.height ~= ch then
					mountedContainer:Set("width", cw)
					mountedContainer:Set("height", ch)
				end
			end, -1000)

			windowData.ChildAdded:Connect(function(child)
				child:PrintTree()

				if child["BackgroundTransparency"] then
					child.BackgroundTransparency = 1
				end

				child.Parent = ScreenGuiObj
			end)

			return windowData
		end

		local function createToolbar(name)
			game.EngineSignal:Fire("NewToolbarGroup", "Plugins", {
				name = name,
			})

			local toolbarWindow = createWindowHandle({
				title = name or "Toolbar",
				x = 16,
				y = 16 + (#toolbars * 84),
				width = 280,
				height = 68,
				contentPaddingX = 8,
				contentPaddingY = 8,
				pluginGuiId = tostring(name or "Toolbar"),
			})

			local toolbar = Instance.new("PluginToolbar")

			toolbar.Name = name or "Toolbar"
			toolbar.Window = toolbarWindow
			toolbar.Buttons = {}
			toolbar.ButtonCreated = signal.new()

			function toolbar:CreateButton(buttonId, tooltip, icon, text)
				local button = Instance.new("PluginToolbarButton")
				button.ClickableWhenViewportHidden = false
				button.Click = signal.new()
				button.Enabled = true
				button.Icon = icon

				function button:SetActive(bool)
					button.Enabled = bool
				end

				local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

				game.EngineSignal:Fire("AddToolbarGroupElement", "Plugins", {
					group = name,
					name = buttonId,
					type = "ImageButton",
					text = text,
					tooltip = tooltip,
					width = 60,
					height = 60,
					texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Move.png"),
					callback = function(element, rect)
						button.Click:Fire(element, rect)
					end,
				})

				return button
			end

			function toolbar:GetButtons()
				return self.Buttons
			end

			function toolbar:Destroy()
				for i = #self.Buttons, 1, -1 do
					self.Buttons[i]:Destroy()
				end
				self.ButtonCreated:Destroy()
				self.Window:Destroy()
				removeArrayValue(toolbars, self)
			end

			table.insert(toolbars, toolbar)
			return toolbar
		end

		local function normalizeDockWidgetConfig(pluginGuiId, dockInfo)
			local config = copyTable(dockInfo or {})
			local width, height = getSizePair(config.FloatingSize or config.InitialSize or config.Size, 360, 260)
			local x = config.x or config.X or 80
			local y = config.y or config.Y or 80

			return {
				id = pluginGuiId,
				pluginGuiId = pluginGuiId,
				title = config.Title or config.Name or tostring(pluginGuiId),
				x = x,
				y = y,
				width = width,
				height = height,
				enabled = config.Enabled ~= false and config.InitialEnabled ~= false,
				headerRender = config.HeaderRender ~= false,
				contentPaddingX = config.ContentPaddingX or 0,
				contentPaddingY = config.ContentPaddingY or 0,
				showStatusBar = config.ShowStatusBar == true,
				statusText = config.StatusText or "",
				tabs = config.Tabs,
				defaultTab = config.DefaultTab,
			}
		end

		function Plugin:CreateWindow(config)
			return createWindowHandle(config or {})
		end

		function Plugin:CreateDockWidgetPluginGui(pluginGuiId, dockInfo)
			return createWindowHandle(normalizeDockWidgetConfig(pluginGuiId, dockInfo))
		end

		function Plugin:CreateToolbar(name)
			return createToolbar(name)
		end

		function Plugin:CreateWidget(widgetType, config)
			return createRawWidget(widgetType, config)
		end

		function Plugin:CreateAereonWidget(widgetType, config)
			return createRawWidget(widgetType, config)
		end

		function Plugin:SpawnWidget(widgetType, config)
			return createRawWidget(widgetType, config)
		end

		function Plugin:SpawnAereonWidget(widgetType, config)
			return createRawWidget(widgetType, config)
		end

		function Plugin:CreateWidgetTree(structure)
			return aereon.create(normalizeCreationStructure(structure))
		end

		function Plugin:GetAvailableWidgets()
			return availableWidgetTypes
		end

		function Plugin:GetWidgetAliases()
			local aliases = {}
			for alias in pairs(widgetTypeLookup) do
				if alias == string.lower(alias) and widgetTypeLookup[alias] then
					continue
				end
				table.insert(aliases, alias)
			end
			table.sort(aliases)
			return aliases
		end

		function Plugin:ResolveWidgetType(widgetType)
			return resolveWidgetType(widgetType)
		end

		Plugin.Unloading = signal.new()
		Plugin.Deactivation = signal.new()

		function Plugin:Activate(exclusiveMouse) end

		function Plugin:CreateDockWidgetPluginGuiAsync(pluginGuiId, dockWidgetpluginGuiInfo)
			return nil
		end

		function Plugin:GetSetting(value)
			return true
		end

		function Plugin:CreatePluginAction(actionId, text, statusTip, iconName, allowBinding)
			return { Triggered = signal.new() }
		end

		function Plugin:CreatePluginMenu(id, title, icon)
			return nil
		end

		function Plugin:Deactivate() end

		function Plugin:GetJoinMode()
			return nil
		end

		function Plugin:GetMouse()
			return nil
		end

		function Plugin:GetSelectedRibbonTool()
			return nil
		end

		function Plugin:GetStudioUserId()
			return 0
		end

		function Plugin:ImportFbxAnimation(rigModel, isR15)
			return nil
		end

		function Plugin:ImportFbxAnimationAsync(rigModel, isR15)
			return nil
		end

		function Plugin:ImportFbxRig(isR15)
			return nil
		end

		function Plugin:ImportFbxRigAsync(isR15)
			return nil
		end

		function Plugin:Intersect(objects)
			return nil
		end

		function Plugin:IsActivated()
			return false
		end

		function Plugin:IsActivatedWithExclusiveMouse()
			return false
		end

		function Plugin:Negate(objects)
			return {}
		end

		function Plugin:OpenScript(script, lineNumber) end

		function Plugin:OpenWikiPage(url) end

		function Plugin:PromptForExistingAssetId(assetType)
			return 0
		end

		function Plugin:PromptForExistingAssetIdAsync(assetType)
			return 0
		end

		function Plugin:PromptSaveSelection(suggestedFileName)
			return false
		end

		function Plugin:PromptSaveSelectionAsync(suggestedFileName)
			return false
		end

		function Plugin:SaveSelectedToRoblox() end

		function Plugin:SelectRibbonTool(tool, position) end

		function Plugin:Separate(objects)
			return {}
		end

		function Plugin:SetSetting(key, value) end

		function Plugin:StartDrag(dragData) end

		function Plugin:Union(objects)
			return nil
		end

		Plugin.WidgetTypes = availableWidgetTypes
		Plugin.WidgetAliases = Plugin:GetWidgetAliases()
		Plugin.Ready = true

		renderer.Pool.new("2d", function()
			if not game.GetService then
				return
			end
			local dt = lib.GetFrameTime()

			local StudioThemeService = game:GetService("StudioThemeService")
			if StudioThemeService then
				window.update(dt, StudioThemeService.SelectedTheme.aereon)
				window.draw(dt, StudioThemeService.SelectedTheme, renderer.Lib2d)
			end

			for _, data in pairs(windowList) do
				local PluginGui, ANPlugin = data[1], data[2]

				ANPlugin.enabled = PluginGui.Enabled
				ANPlugin.title = PluginGui.Title
			end
		end)
	end)

	return Plugin
end

return Plugin
