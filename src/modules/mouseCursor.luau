local Enum = require("@EnumMap")
local raylib = require("@raylib")

local MouseCursor = {}

local DEFAULT_CURSOR = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value
local HIGH_PRIORITY_CURSORS = {
	[Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value] = true,
	[Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NS.Value] = true,
	[Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NWSE.Value] = true,
	[Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NESW.Value] = true,
	[Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_ALL.Value] = true,
}

local cursorState = {
	managed = false,
	requested = DEFAULT_CURSOR,
	priority = 0,
	applied = nil,
}

local function getCursorPriority(cursor)
	if cursor == DEFAULT_CURSOR then
		return 0
	end

	if HIGH_PRIORITY_CURSORS[cursor] then
		return 2
	end

	return 1
end

function MouseCursor.beginFrame()
	cursorState.managed = true
	cursorState.requested = DEFAULT_CURSOR
	cursorState.priority = 0
end

function MouseCursor.request(cursor)
	if not cursorState.managed then
		if cursorState.applied ~= cursor then
			raylib.lib.SetMouseCursor(cursor)
			cursorState.applied = cursor
		end
		return
	end

	local priority = getCursorPriority(cursor)
	if priority > cursorState.priority or priority == cursorState.priority then
		cursorState.requested = cursor
		cursorState.priority = priority
	end
end

function MouseCursor.commitFrame()
	if not cursorState.managed then
		return
	end

	cursorState.managed = false
	if cursorState.applied ~= cursorState.requested then
		raylib.lib.SetMouseCursor(cursorState.requested)
		cursorState.applied = cursorState.requested
	end
end

function MouseCursor.getDefaultCursor()
	return DEFAULT_CURSOR
end

return MouseCursor
