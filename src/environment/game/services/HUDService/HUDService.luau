local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local HUDService = Instance.new("HUDService")
HUDService.ExplorerHidden = true
HUDService._Intents = Enum.PluginIntents.UI

HUDService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local pendingActions = {}
	local pendingRuntime = {}
	local pendingNotifications = {}
	local notificationHandler = nil
	local hudSignal = nil
	local runtimeManager = nil
	local rootGui = nil
	local ready = false
	local readyChanged = signal.new()

	local function normalizeArgs(a, b, c, d)
		if a == HUDService then
			return b, c, d
		end
		return a, b, c
	end

	local function cloneValue(value)
		if type(value) ~= "table" then
			return value
		end
		if getmetatable(value) ~= nil then
			return value
		end

		local cloned = {}
		for key, child in pairs(value) do
			cloned[key] = cloneValue(child)
		end
		return cloned
	end

	local function mergeInto(target, source)
		for key, value in pairs(source) do
			if type(value) == "table" and type(target[key]) == "table" then
				mergeInto(target[key], value)
			else
				target[key] = cloneValue(value)
			end
		end
		return target
	end

	local function publishSettings(nextConfig)
		local configService = datamodel:GetService("ConfigService")

		if configService and configService.SetConfig then
			configService.SetConfig(nextConfig)
		end
		return nextConfig
	end

	local function queueAction(message, param, callback)
		table.insert(pendingActions, {
			message = message,
			param = param,
			callback = callback,
		})
	end

	local function flushPendingRuntime()
		if not runtimeManager then
			return
		end

		for key, value in pairs(pendingRuntime) do
			runtimeManager:set("#runtime", key, value)
		end
	end

	local function flushPendingActions()
		if not hudSignal then
			return
		end

		for _, action in ipairs(pendingActions) do
			hudSignal:Fire(action.message, action.param, action.callback)
		end
		table.clear(pendingActions)
	end

	local function dispatch(message, param, callback)
		if hudSignal and ready then
			hudSignal:Fire(message, param, callback)
			return true
		end

		queueAction(message, param, callback)
		return false
	end

	local function sanitizeRouteName(routeName)
		routeName = tostring(routeName or "")
		routeName = routeName:gsub("^/+", "")
		routeName = routeName:gsub("%s+", "-")
		return string.lower(routeName)
	end

	HUDService:SetProperties({
		Ready = false,
		ReadyChanged = readyChanged,

		AttachRuntime = function(a, b)
			local manager = normalizeArgs(a, b)
			runtimeManager = manager
			flushPendingRuntime()
			return runtimeManager
		end,

		AttachClient = function(a, b, c)
			local signalBridge, gui = normalizeArgs(a, b, c)
			hudSignal = signalBridge or hudSignal
			rootGui = gui or rootGui
			flushPendingActions()

			if ready ~= true then
				ready = true
				HUDService.Ready = true
				readyChanged:Fire()
			end

			return hudSignal
		end,

		IsReady = function()
			return ready
		end,

		GetGui = function()
			return rootGui
		end,

		GetRuntimeManager = function()
			return runtimeManager
		end,

		GetRuntime = function(a, b, c)
			local key, fallback = normalizeArgs(a, b, c)
			if runtimeManager then
				local value = runtimeManager:get("#runtime", key)
				if value ~= nil then
					return value
				end
			end

			local pendingValue = pendingRuntime[key]
			if pendingValue ~= nil then
				return pendingValue
			end

			return fallback
		end,

		SetRuntime = function(a, b, c)
			local key, value = normalizeArgs(a, b, c)
			pendingRuntime[key] = value
			if runtimeManager then
				runtimeManager:set("#runtime", key, value)
			end
			return value
		end,

		OpenMenu = function()
			dispatch("OpenMenu")
		end,

		CloseMenu = function()
			dispatch("CloseMenu")
		end,

		ToggleMenu = function()
			dispatch("ToggleMenu")
		end,

		Notify = function(a, b, c, d)
			local title, description, timeout
			if a == HUDService then
				title, description, timeout = b, c, d
			else
				title, description, timeout = a, b, c
			end
			local notif = { title = tostring(title or ""), desc = tostring(description or ""), timeout = timeout }
			if notificationHandler then
				notificationHandler(notif.title, notif.desc, notif.timeout)
			else
				table.insert(pendingNotifications, notif)
			end
		end,

		SetNotificationHandler = function(a, b)
			local handler = normalizeArgs(a, b)
			notificationHandler = handler
			-- Drain any notifications that fired before the handler was registered
			local drained = pendingNotifications
			pendingNotifications = {}
			for _, notif in ipairs(drained) do
				handler(notif.title, notif.desc, notif.timeout)
			end
		end,

		OpenRoute = function(a, b)
			local routeName = sanitizeRouteName(normalizeArgs(a, b))
			dispatch("OpenRoute", routeName)
		end,

		CloseRoute = function()
			dispatch("CloseRoute")
		end,

		AddWindow = function(a, b, c)
			local title, callback = normalizeArgs(a, b, c)
			if type(title) == "table" then
				callback = title.callback or title.build or title.render
				title = title.title or title.name
			end

			if title == nil then
				return nil
			end

			dispatch("MakeWindow", tostring(title), callback)
			return title
		end,

		AddTopbarButton = function(a, b)
			local config = normalizeArgs(a, b)
			if type(config) ~= "table" then
				return nil
			end

			local routeName = config.routeName or config.route or config.id or config.title or config.icon
			local payload = {
				icon = config.icon,
				routeName = sanitizeRouteName(routeName),
				open_callback = config.open_callback or config.open or config.onOpen or config.callback,
				close_callback = config.close_callback or config.close or config.onClose,
			}

			dispatch("NewTopbarButton", payload)
			return payload.routeName
		end,

		GetSettings = function()
			local configService = datamodel:GetService("ConfigService")

			if configService and configService.GetConfig then
				return configService.GetConfig()
			end
			return {}
		end,

		MergeSettings = function(a, b)
			local configService = datamodel:GetService("ConfigService")

			local config = normalizeArgs(a, b)
			local currentConfig = {}
			if configService and configService.GetConfig then
				currentConfig = cloneValue(configService.GetConfig() or {})
			end

			return publishSettings(mergeInto(currentConfig, config or {}))
		end,

		AddSettingsSection = function(a, b, c)
			local sectionName, entries = normalizeArgs(a, b, c)
			if sectionName == nil then
				return nil
			end

			return HUDService.MergeSettings({
				[tostring(sectionName)] = entries or {},
			})
		end,

		AddSettingsEntries = function(a, b, c)
			local sectionName, entries = normalizeArgs(a, b, c)
			if sectionName == nil then
				return nil
			end

			return HUDService.MergeSettings({
				[tostring(sectionName)] = entries or {},
			})
		end,

		AddSettingsEntry = function(a, b, c, d)
			local sectionName, entryName, entryData
			if a == HUDService then
				sectionName, entryName, entryData = b, c, d
			else
				sectionName, entryName, entryData = a, b, c
			end

			if sectionName == nil or entryName == nil then
				return nil
			end

			return HUDService.MergeSettings({
				[tostring(sectionName)] = {
					[tostring(entryName)] = entryData or {},
				},
			})
		end,
	})
end

return HUDService
