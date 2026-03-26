--!strict
--!optimize 2

local constants = {
	ULMessageSource = {
		kMessageSource_XML = 0x0,
		kMessageSource_JS = 0x1,
		kMessageSource_Network = 0x2,
		kMessageSource_ConsoleAPI = 0x3,
		kMessageSource_Storage = 0x4,
		kMessageSource_AppCache = 0x5,
		kMessageSource_Rendering = 0x6,
		kMessageSource_CSS = 0x7,
		kMessageSource_Security = 0x8,
		kMessageSource_ContentBlocker = 0x9,
		kMessageSource_Media = 0xa,
		kMessageSource_MediaSource = 0xb,
		kMessageSource_WebRTC = 0xc,
		kMessageSource_ITPDebug = 0xd,
		kMessageSource_PrivateClickMeasurement = 0xe,
		kMessageSource_PaymentRequest = 0xf,
		kMessageSource_Other = 0x10,
	},

	ULMessageLevel = {
		kMessageLevel_Log = 0x0,
		kMessageLevel_Warning = 0x1,
		kMessageLevel_Error = 0x2,
		kMessageLevel_Debug = 0x3,
		kMessageLevel_Info = 0x4,
	},

	ULCursor = {
		kCursor_Pointer = 0x0,
		kCursor_Cross = 0x1,
		kCursor_Hand = 0x2,
		kCursor_IBeam = 0x3,
		kCursor_Wait = 0x4,
		kCursor_Help = 0x5,
		kCursor_EastResize = 0x6,
		kCursor_NorthResize = 0x7,
		kCursor_NorthEastResize = 0x8,
		kCursor_NorthWestResize = 0x9,
		kCursor_SouthResize = 0xa,
		kCursor_SouthEastResize = 0xb,
		kCursor_SouthWestResize = 0xc,
		kCursor_WestResize = 0xd,
		kCursor_NorthSouthResize = 0xe,
		kCursor_EastWestResize = 0xf,
		kCursor_NorthEastSouthWestResize = 0x10,
		kCursor_NorthWestSouthEastResize = 0x11,
		kCursor_ColumnResize = 0x12,
		kCursor_RowResize = 0x13,
		kCursor_MiddlePanning = 0x14,
		kCursor_EastPanning = 0x15,
		kCursor_NorthPanning = 0x16,
		kCursor_NorthEastPanning = 0x17,
		kCursor_NorthWestPanning = 0x18,
		kCursor_SouthPanning = 0x19,
		kCursor_SouthEastPanning = 0x1a,
		kCursor_SouthWestPanning = 0x1b,
		kCursor_WestPanning = 0x1c,
		kCursor_Move = 0x1d,
		kCursor_VerticalText = 0x1e,
		kCursor_Cell = 0x1f,
		kCursor_ContextMenu = 0x20,
		kCursor_Alias = 0x21,
		kCursor_Progress = 0x22,
		kCursor_NoDrop = 0x23,
		kCursor_Copy = 0x24,
		kCursor_None = 0x25,
		kCursor_NotAllowed = 0x26,
		kCursor_ZoomIn = 0x27,
		kCursor_ZoomOut = 0x28,
		kCursor_Grab = 0x29,
		kCursor_Grabbing = 0x2a,
		kCursor_Custom = 0x2b,
	},

	ULBitmapFormat = {
		kBitmapFormat_A8_UNORM = 0x0,
		kBitmapFormat_BGRA8_UNORM_SRGB = 0x1,
	},

	ULKeyEventType = {
		kKeyEventType_KeyDown = 0x0,
		kKeyEventType_KeyUp = 0x1,
		kKeyEventType_RawKeyDown = 0x2,
		kKeyEventType_Char = 0x3,
	},

	ULMouseEventType = {
		kMouseEventType_MouseMoved = 0x0,
		kMouseEventType_MouseDown = 0x1,
		kMouseEventType_MouseUp = 0x2,
	},

	ULMouseButton = {
		kMouseButton_None = 0x0,
		kMouseButton_Left = 0x1,
		kMouseButton_Middle = 0x2,
		kMouseButton_Right = 0x3,
	},

	ULScrollEventType = {
		kScrollEventType_ScrollByPixel = 0x0,
		kScrollEventType_ScrollByPage = 0x1,
	},

	ULGamepadEventType = {
		kGamepadEventType_Connected = 0x0,
		kGamepadEventType_Disconnected = 0x1,
	},

	ULFaceWinding = {
		kFaceWinding_Clockwise = 0x0,
		kFaceWinding_CounterClockwise = 0x1,
	},

	ULFontHinting = {
		kFontHinting_Smooth = 0x0,
		kFontHinting_Normal = 0x1,
		kFontHinting_Monochrome = 0x2,
	},

	ULVertexBufferFormat = {
		kVertexBufferFormat_2f_4ub_2f = 0x0,
		kVertexBufferFormat_2f_4ub_2f_2f_28f = 0x1,
	},

	ULShaderType = {
		kShaderType_Fill = 0x0,
		kShaderType_FillPath = 0x1,
	},

	ULCommandType = {
		kCommandType_ClearRenderBuffer = 0x0,
		kCommandType_DrawGeometry = 0x1,
	},

	ULLogLevel = {
		kLogLevel_Error = 0x0,
		kLogLevel_Warning = 0x1,
		kLogLevel_Info = 0x2,
	},
}

return constants
