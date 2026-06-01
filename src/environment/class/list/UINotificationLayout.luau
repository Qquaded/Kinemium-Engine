-- description: "A layout for managing notification overlays."
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local UDim = require("@UDim")
local Signal = require("@Kinemium.signal")

local propTable = {
	Name = "UINotificationLayout",
	Enabled = true,

	Anchor = Enum.NotificationAnchor.TopRight,
	Padding = UDim.new(0, 12), -- gap between notifications
	MarginX = UDim.new(0, 16), -- distance from screen edge X
	MarginY = UDim.new(0, 16), -- distance from screen edge Y

	MaxVisible = 5, -- max notifications shown at once
	EnterDuration = 0.25, -- slide-in time
	ExitDuration = 0.2, -- slide-out time
	DefaultTimeout = 4, -- seconds before auto-dismiss (0 = never)

	EnterEasing = Enum.EasingStyle.Quad,
	ExitEasing = Enum.EasingStyle.Quad,

	_notifications = nil, -- internal list, initialized on first render

	render = function(lib, object, dt, structs, renderer)
		if not object.Enabled then
			return
		end

		if rawget(object, "_notifications") == nil then
			rawset(object, "_notifications", {})
		end

		local notifications = rawget(object, "_notifications")
		local dpiScale = lib.GetWindowScaleDPI()
		local screenW = lib.GetRenderWidth() / dpiScale.x
		local screenH = lib.GetRenderHeight() / dpiScale.y

		local marginX = object.MarginX.Scale * screenW + object.MarginX.Offset
		local marginY = object.MarginY.Scale * screenH + object.MarginY.Offset
		local padding = object.Padding.Scale * screenH + object.Padding.Offset

		local anchor = object.Anchor
		local isRight = anchor == Enum.NotificationAnchor.TopRight or anchor == Enum.NotificationAnchor.BottomRight
		local isBottom = anchor == Enum.NotificationAnchor.BottomLeft or anchor == Enum.NotificationAnchor.BottomRight

		local function ease(t, style)
			if style == Enum.EasingStyle.Linear then
				return t
			elseif style == Enum.EasingStyle.Quad then
				return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2
			elseif style == Enum.EasingStyle.Cubic then
				return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2
			elseif style == Enum.EasingStyle.Sine then
				return -(math.cos(math.pi * t) - 1) / 2
			elseif style == Enum.EasingStyle.Expo then
				if t == 0 then
					return 0
				end
				if t == 1 then
					return 1
				end
				return t < 0.5 and 2 ^ (20 * t - 10) / 2 or (2 - 2 ^ (-20 * t + 10)) / 2
			end
			return t
		end

		local toRemove = {}
		for i, notif in ipairs(notifications) do
			notif._elapsed = (notif._elapsed or 0) + dt

			if notif.state == Enum.NotificationState.Entering then
				local t = math.clamp(notif._elapsed / object.EnterDuration, 0, 1)
				notif._alpha = ease(t, object.EnterEasing)
				notif._slideT = notif._alpha

				if t >= 1 then
					notif.state = Enum.NotificationState.Visible
					notif._elapsed = 0
					notif._alpha = 1
					notif._slideT = 1
				end
			elseif notif.state == Enum.NotificationState.Visible then
				local timeout = notif.timeout ~= nil and notif.timeout or object.DefaultTimeout
				if timeout > 0 and notif._elapsed >= timeout then
					notif.state = Enum.NotificationState.Exiting
					notif._elapsed = 0
				end
			elseif notif.state == Enum.NotificationState.Exiting then
				local t = math.clamp(notif._elapsed / object.ExitDuration, 0, 1)
				notif._alpha = 1 - ease(t, object.ExitEasing)
				notif._slideT = notif._alpha

				if t >= 1 then
					table.insert(toRemove, i)

					local completedSignal = rawget(object, "_completedSignal")
					if completedSignal then
						completedSignal:Fire(notif.frame)
					end
				end
			end
		end

		for i = #toRemove, 1, -1 do
			table.remove(notifications, toRemove[i])
		end

		while #notifications > object.MaxVisible do
			table.remove(notifications, 1)
		end

		local cursor = marginY

		if isBottom then
			local totalH = 0
			for _, notif in ipairs(notifications) do
				local h = notif.frame and notif.frame.AbsoluteSize and notif.frame.AbsoluteSize.Y or 0
				totalH = totalH + h + padding
			end
			cursor = screenH - marginY - totalH
		end

		for _, notif in ipairs(notifications) do
			local frame = notif.frame
			if not frame or not frame.render then
				continue
			end

			local frameW = (frame.AbsoluteSize and frame.AbsoluteSize.X)
				or (frame.Size.X.Scale * screenW + frame.Size.X.Offset)
				or 0
			local frameH = (frame.AbsoluteSize and frame.AbsoluteSize.Y)
				or (frame.Size.Y.Scale * screenH + frame.Size.Y.Offset)
				or 0

			local slideT = notif._slideT or 0

			local posX
			if isRight then
				posX = screenW - marginX - frameW + (1 - slideT) * (frameW + marginX)
			else
				posX = marginX - (1 - slideT) * (frameW + marginX)
			end

			local posY = cursor

			rawset(frame, "_LayoutControlled", false)
			rawset(frame, "_LayoutRelativePosition", nil)
			rawset(frame, "_EditorOverride", false)
			frame.Position = UDim2.new(0, posX, 0, posY)
			frame.AnchorPoint = vector.create(0, 0, 0)

			if notif._alpha ~= nil then
				local baseTransparency = notif._baseTransparency or 0
				frame.BackgroundTransparency = 1 - (1 - baseTransparency) * notif._alpha
			end

			frame.render(lib, frame, dt, structs, renderer)

			cursor = cursor + frameH + padding
		end
	end,
}

local api = {}

-- description: "Pushes a notification."
-- args: "layoutObject: table, frame: table, options: table"
function api.Push(layoutObject, frame, options)
	options = options or {}
	local notifications = rawget(layoutObject, "_notifications")
	if not notifications then
		notifications = {}
		rawset(layoutObject, "_notifications", notifications)
	end

	table.insert(notifications, {
		frame = frame,
		state = Enum.NotificationState.Entering,
		timeout = options.timeout,
		_elapsed = 0,
		_alpha = 0,
		_slideT = 0,
		_baseTransparency = frame.BackgroundTransparency or 0,
	})
end

-- description: "Dismisses a notification."
-- args: "layout: any, frame: table"
function api.Dismiss(layout, frame)
	local notifications = rawget(layout, "_notifications")
	if not notifications then
		return
	end

	for _, notif in ipairs(notifications) do
		if notif.frame == frame and notif.state ~= Enum.NotificationState.Exiting then
			notif.state = Enum.NotificationState.Exiting
			notif._elapsed = 0
		end
	end
end

-- description: "Dismisses all notifications."
-- args: "layout: any"
function api.DismissAll(layout)
	local notifications = rawget(layout, "_notifications")
	if not notifications then
		return
	end

	for _, notif in ipairs(notifications) do
		if notif.state ~= Enum.NotificationState.Exiting then
			notif.state = Enum.NotificationState.Exiting
			notif._elapsed = 0
		end
	end
end

return {
	class = "UINotificationLayout",
	render = propTable.render,
	api = api,
	callback = function(instance)
		instance:SetProperties(propTable)

		local completedSignal = Signal.new()
		rawset(instance, "_completedSignal", completedSignal)

		-- description: "Pushes a notification."
		-- args: "frame: table, options: table"
		instance.Push = function(frame, options)
			api.Push(instance, frame, options)
		end
		-- description: "Dismisses a notification."
		-- args: "frame: table"
		instance.Dismiss = function(frame)
			api.Dismiss(instance, frame)
		end
		-- description: "Dismisses all notifications."
		instance.DismissAll = function()
			api.DismissAll(instance)
		end
		instance.Completed = completedSignal

		return instance
	end,
}
