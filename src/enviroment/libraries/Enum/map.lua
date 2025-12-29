local enumtransformer = require("@Enum")

local enumTable = {}

enumTable.KeyCode = {
	Backspace = 8,
	Tab = 9,
	Clear = 12,
	Return = 13,
	Pause = 19,
	Escape = 27,
	Space = 32,

	Quote = 39,
	Comma = 44,
	Minus = 45,
	Period = 46,
	Slash = 47,

	Zero = 48,
	One = 49,
	Two = 50,
	Three = 51,
	Four = 52,
	Five = 53,
	Six = 54,
	Seven = 55,
	Eight = 56,
	Nine = 57,

	Semicolon = 59,
	Equals = 61,

	A = 65,
	B = 66,
	C = 67,
	D = 68,
	E = 69,
	F = 70,
	G = 71,
	H = 72,
	I = 73,
	J = 74,
	K = 75,
	L = 76,
	M = 77,
	N = 78,
	O = 79,
	P = 80,
	Q = 81,
	R = 82,
	S = 83,
	T = 84,
	U = 85,
	V = 86,
	W = 87,
	X = 88,
	Y = 89,
	Z = 90,

	LeftBracket = 91,
	Backslash = 92,
	RightBracket = 93,

	Insert = 45,
	Delete = 46,
	Home = 36,
	End = 35,
	PageUp = 33,
	PageDown = 34,

	Left = 37,
	Up = 38,
	Right = 39,
	Down = 40,

	Select = 41,
	Print = 42,
	Execute = 43,
	PrintScreen = 44,
	Help = 47,

	ZeroPad = 96,
	OnePad = 97,
	TwoPad = 98,
	ThreePad = 99,
	FourPad = 100,
	FivePad = 101,
	SixPad = 102,
	SevenPad = 103,
	EightPad = 104,
	NinePad = 105,

	Multiply = 106,
	Add = 107,
	Separator = 108,
	Subtract = 109,
	Decimal = 110,
	Divide = 111,

	F1 = 112,
	F2 = 113,
	F3 = 114,
	F4 = 115,
	F5 = 116,
	F6 = 117,
	F7 = 118,
	F8 = 119,
	F9 = 120,
	F10 = 121,
	F11 = 122,
	F12 = 123,
	F13 = 124,
	F14 = 125,
	F15 = 126,

	NumLock = 144,
	CapsLock = 20,
	ScrollLock = 145,

	LeftShift = 160,
	RightShift = 161,
	LeftControl = 162,
	RightControl = 163,
	LeftAlt = 164,
	RightAlt = 165,

	LeftMeta = 91,
	RightMeta = 92,
	LeftSuper = 91,
	RightSuper = 92,

	Mode = 257,

	Apps = 93,
	Sleep = 95,

	Thumbstick1 = 1000,
	Thumbstick2 = 1001,
	ButtonX = 1002,
	ButtonY = 1003,
	ButtonA = 1004,
	ButtonB = 1005,
	DPadLeft = 1006,
	DPadRight = 1007,
	DPadUp = 1008,
	DPadDown = 1009,
	Start = 1010,
	Back = 1011,
}

enumTable.UserInputType = {
	None = 0,

	-- Mouse
	MouseButton1 = 1,
	MouseButton2 = 2,
	MouseButton3 = 3,
	MouseWheel = 4,
	MouseMovement = 5,

	-- Keyboard
	Keyboard = 6,

	-- Touch
	Touch = 7,

	Gamepad1 = 8,
	Gamepad2 = 9,
	Gamepad3 = 10,
	Gamepad4 = 11,
	Gamepad5 = 12,
	Gamepad6 = 13,
	Gamepad7 = 14,
	Gamepad8 = 15,

	Accelerometer = 16,
	Gyro = 17,

	Gamepad = 18,
	TextInput = 19,
	Voice = 20,
}

enumTable.PartType = {
	Block = "block",
	Ball = "sphere",
	Cylinder = "cylinder",
	Wedge = "wedge",
	Torus = "torus",
	CornerWedge = "cornerwedge",
	Mesh = "kmesh",
	Terrain = "kterrain",
}

enumTable.ActuatorRelativeTo = {
	World = 0,
	Attachment0 = 1,
}

enumTable.Material = {
	Air = "air",
	SmoothPlastic = "smoothplastic",
	Plastic = "plastic",
	Metal = "metal",
	Wood = "wood",
	Glass = "glass",
	Grass = "grass",
	Rubber = "rubber",
	Marble = "marble",
	Granite = "granite",
	Concrete = "concrete",
	Fabric = "fabric",
	Slate = "slate",
	Sand = "sand",
	Leather = "leather",
	CarbonFiber = "carbonfiber",
	Ice = "ice",
	Neon = "neon",
	debug = "debug",
	ForceField = "forcefield",
}

enumTable.UserInputState = {
	Begin = 0,
	Change = 1,
	End = 2,
	Cancel = 3,
	None = 4,
}

enumTable.MouseButton = {
	Left = 0,
	Right = 1,
	Middle = 2,
}

enumTable.KinemiumMouseCursor = {
	MOUSE_CURSOR_DEFAULT = 0, -- Default pointer shape
	MOUSE_CURSOR_ARROW = 1, -- Arrow shape
	MOUSE_CURSOR_IBEAM = 2, -- Text writing cursor shape
	MOUSE_CURSOR_CROSSHAIR = 3, -- Cross shape
	MOUSE_CURSOR_POINTING_HAND = 4, -- Pointing hand cursor
	MOUSE_CURSOR_RESIZE_EW = 5, -- Horizontal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NS = 6, -- Vertical resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NWSE = 7, -- Top-left to bottom-right diagonal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NESW = 8, -- The top-right to bottom-left diagonal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_ALL = 9, -- The omnidirectional resize/move cursor shape
	MOUSE_CURSOR_NOT_ALLOWED = 10, -- The operation-not-allowed shape
}

enumTable.NormalId = {
	Top = 1,
	Bottom = 2,
	Back = 3,
	Front = 4,
	Right = 5,
	Left = 6,
}

enumTable.Font = {
	Legacy = "Legacy",
	Arial = "Arial",
	ArialBold = "ArialBold",
	SourceSans = "SourceSans",
	SourceSansBold = "SourceSansBold",
	SourceSansLight = "SourceSansLight",
	SourceSansItalic = "SourceSansItalic",
	Bodoni = "Bodoni",
	Garamond = "Garamond",
	Cartoon = "Cartoon",
	Code = "Code",
	DefaultEngineFont = "DefaultEngineFont",
	Highway = "Highway",
	SciFi = "SciFi",
	Arcade = "Arcade",
	Fantasy = "Fantasy",
	Antique = "Antique",
	SourceSansSemibold = "SourceSansSemibold",
	Gotham = "Gotham",
	Vend = "Vend",
	GothamMedium = "GothamMedium",
	GothamBold = "GothamBold",
	GothamBlack = "GothamBlack",
	AmaticSC = "AmaticSC",
	Bangers = "Bangers",
	Creepster = "Creepster",
	DenkOne = "DenkOne",
	Fondamento = "Fondamento",
	Audiowide = "AudiowideRegular",
	FredokaOne = "FredokaOne",
	GrenzeGotisch = "GrenzeGotisch",
	IndieFlower = "IndieFlower",
	JosefinSans = "JosefinSans",
	Jura = "Jura",
	Kalam = "Kalam",
	LuckiestGuy = "LuckiestGuy",
	Merriweather = "Merriweather",
	Michroma = "Michroma",
	Nunito = "Nunito",
	Oswald = "Oswald",
	Exo = "ExoRegular",
	ExoBold = "ExoBold",
	ExoItalic = "ExoItalic",
	PatrickHand = "PatrickHand",
	PermanentMarker = "PermanentMarker",
	Roboto = "Roboto",
	RobotoCondensed = "RobotoCondensed",
	RobotoMono = "RobotoMono",
	Sarpanch = "Sarpanch",
	SpecialElite = "SpecialElite",
	TitilliumWeb = "TitilliumWeb",
	Ubuntu = "Ubuntu",
	BuilderSans = "BuilderSans",
	BuilderSansMedium = "BuilderSansMedium",
	BuilderSansBold = "BuilderSansBold",
	BuilderSansExtraBold = "BuilderSansExtraBold",
	Arimo = "Arimo",
	ArimoBold = "ArimoBold",
	Unknown = "Unknown",
}

enumTable.Language = {
	Luau = 1,
	Lua = 2,
	JavaScript = 3,
	Python = 4,
	C = 5,
	["C++"] = 6,
	["C#"] = 7,
	Zig = 8,
}

enumTable.TextXAlignment = {
	Left = 0,
	Center = 1,
	Right = 2,
}

enumTable.TextYAlignment = {
	Top = 0,
	Center = 1,
	Bottom = 2,
}

enumTable.TextTruncate = {
	None = 0,
	Head = 1,
	Tail = 2,
	Line = 3,
}

enumTable.Dimension = {
	["2D"] = 1,
	["3D"] = 2,
}

enumTable.FillDirection = {
	Vertical = 0,
	Horizontal = 1,
}

enumTable.SortOrder = {
	LayoutOrder = 0,
	Name = 1,
}

enumTable.HorizontalAlignment = {
	Left = 0,
	Center = 1,
	Right = 2,
}

enumTable.VerticalAlignment = {
	Top = 0,
	Center = 1,
	Bottom = 2,
}

enumTable.EasingStyle = {
	Linear = 0,
	Sine = 1,
	Quad = 2,
	Cubic = 3,
	Quart = 4,
	Quint = 5,
	Expo = 6,
	Circular = 7,
	Back = 8,
	Bounce = 9,
	Elastic = 10,
}

enumTable.EasingDirection = {
	In = 0,
	Out = 1,
	InOut = 2,
}

enumTable.CameraType = {
	Custom = 0,
	Fixed = 1,
	Attach = 2,
	Watch = 3,
	Track = 4,
	Follow = 5,
	Scriptable = 6,
}

enumTable.Axis = {
	X = 0,
	Y = 1,
	Z = 2,
}

enumTable.Face = {
	Top = 0,
	Bottom = 1,
	Left = 2,
	Right = 3,
	Front = 4,
	Back = 5,
}

enumTable.AutomaticSize = {
	None = 0,
	X = 1,
	Y = 2,
	XY = 3,
}

enumTable.PlaybackState = {
	Stopped = 0,
	Playing = 1,
	Paused = 2,
}

enumTable.AnimationPriority = {
	Core = 0,
	Idle = 1,
	Movement = 2,
	Action = 3,
}

enumTable.GameContext = {
	Game = 1,
	Editor = 2,
}

enumTable.RunContext = {
	Legacy = 0,
	Server = 1,
	Client = 2,
	Plugin = 3,
	Editor = 4,
}

enumTable.HumanoidStateType = {
	None = 0,
	Running = 1,
	Jumping = 2,
	Freefall = 3,
	Landed = 4,
	Swimming = 5,
	Climbing = 6,
	Dead = 7,
}

enumTable.ZIndexBehavior = {
	Global = 0,
	Sibling = 1,
}

enumTable.ScaleType = {
	Stretch = 0,
	Fit = 1,
	Crop = 2,
}

enumTable.ConstraintType = {
	Weld = 0,
	BallSocket = 1,
	Hinge = 2,
	Prismatic = 3,
	Spring = 4,
	Rope = 5,
}

enumTable.SurfaceType = {
	Smooth = 0,
	Studs = 1,
	Inlet = 2,
	Universal = 3,
}

enumTable.CollisionGroup = {
	Default = 0,
	Player = 1,
	World = 2,
	Sensor = 3,
}

enumTable.BodyType2D = {
	Static = 0,
	Kinematic = 1,
	Dynamic = 2,
}

enumTable.ShapeType2D = {
	Circle = 0,
	Box = 1,
	Polygon = 2,
	Edge = 3,
	Chain = 4,
}

enumTable.JointType2D = {
	Revolute = 0,
	Prismatic = 1,
	Distance = 2,
	Pulley = 3,
	Mouse = 4,
	Gear = 5,
	Wheel = 6,
	Weld = 7,
	Friction = 8,
	Motor = 9,
}

enumTable.RaycastMode2D = {
	Closest = 0,
	Any = 1,
	All = 2,
}

enumTable.CollisionDetection2D = {
	Discrete = 0,
	Continuous = 1,
}

enumTable.ContactState2D = {
	Begin = 0,
	Persist = 1,
	End = 2,
}

enumTable.BodySleepState2D = {
	Awake = 0,
	Sleeping = 1,
}

enumTable.RigidbodyConstraints2D = {
	None = 0,
	FreezePositionX = 1,
	FreezePositionY = 2,
	FreezeRotation = 4,
	FreezeAll = 7,
}

enumTable.ForceMode2D = {
	Force = 0,
	Impulse = 1,
}

enumTable.PhysicsMaterialCombine = {
	Average = 0,
	Min = 1,
	Multiply = 2,
	Max = 3,
}

enumTable.RenderFidelity = {
	Automatic = 0,
	Precise = 1,
	Performance = 2,
}

enumTable.CollisionFidelity = {
	Default = 0,
	Hull = 1,
	Box = 2,
	PreciseConvexDecomposition = 3,
}

enumTable.AudioBackend = {
	Raudio = 0,
	FMOD = 1,
}

enumTable.CameraType = {
	Custom = 0,
	Scriptable = 1,
	Orbital = 2,
	FirstPerson = 3,
	ThirdPerson = 4,
}

enumTable.SecurityCapabilities = {
	UserScript = 1,
	Internals = 2,
}

return enumtransformer.new(enumTable)
