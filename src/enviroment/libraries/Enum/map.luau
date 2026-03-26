local enumtransformer = require("@Enum")

local enumTable = {}
local dump = require("./dump")

_G.log = _G.log

enumTable.KinemiumDownscaleMode = {
	Nearest = 1,
	Linear = 2,
	Box = 3,
}

enumTable.KinemiumUpscaleMode = {
	Nearest = 1,
	Linear = 2,
	Bicubic = 3,
	Lanczos = 4,
}

enumTable.KinemiumBloomMode = {
	Mix = 1,
	Additive = 2,
	Screen = 3,
}

enumTable.KinemiumFogMode = {
	Linear = 1,
	Exponential = 2,
	Exponential2 = 3,
}

enumTable.KinemiumTonemapMode = {
	ACES = 1,
	Reinhard = 2,
	Filmic = 3,
	Hejl = 4,
	ACESFilmic = 5,
}

enumTable.KinemiumOutputMode = {
	Scene = 1,
	Albedo = 2,
	Normal = 3,
	ORM = 4,
	Diffuse = 5,
	Specular = 6,
	SSAO = 7,
	SSIL = 8,
	SSGI = 9,
	SSR = 10,
	Bloom = 11,
	DOF = 12,
}

enumTable.ParticleTransparencyMode = {
	Disabled = 0,
	Prepass = 1,
	Alpha = 2,
}

enumTable.ParticleBlendMode = {
	Mix = 0,
	Additive = 1,
	Multiply = 2,
	PremultipliedAlpha = 3,
}

enumTable.ParticleCullMode = {
	None = 0,
	Back = 1,
	Front = 2,
}

enumTable.ParticleBillboardMode = {
	Disabled = 0,
	Front = 1,
	YAxis = 2,
}

enumTable.ParticleFlipbookMode = {
	Loop = 0,
	OneShot = 1,
	PingPong = 2,
	Random = 3,
}

enumTable.UIParticleEmitterShape = {
	Point = 0,
	Box = 1,
	Circle = 2,
	Ring = 3,
}

enumTable.KinemiumShaderPreset = {
	Low = 1,
	Medium = 2,
	High = 3,
	Ultra = 4,
}

enumTable.KeyCode = {
	Space = 32,
	Quote = 39, -- Apostrophe
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
	Grave = 96,

	Escape = 256,
	Return = 257,
	Tab = 258,
	Backspace = 259,
	Insert = 260,
	Delete = 261,

	Right = 262,
	Left = 263,
	Down = 264,
	Up = 265,

	PageUp = 266,
	PageDown = 267,
	Home = 268,
	End = 269,

	CapsLock = 280,
	ScrollLock = 281,
	NumLock = 282,
	PrintScreen = 283,
	Pause = 284,

	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,

	-- Keypad
	ZeroPad = 320,
	OnePad = 321,
	TwoPad = 322,
	ThreePad = 323,
	FourPad = 324,
	FivePad = 325,
	SixPad = 326,
	SevenPad = 327,
	EightPad = 328,
	NinePad = 329,

	Decimal = 330,
	Divide = 331,
	Multiply = 332,
	Subtract = 333,
	Add = 334,
	KeypadEnter = 335,
	KeypadEquals = 336,

	-- Modifiers
	LeftShift = 340,
	LeftControl = 341,
	LeftAlt = 342,
	LeftSuper = 343,
	RightShift = 344,
	RightControl = 345,
	RightAlt = 346,
	RightSuper = 347,

	Apps = 348,
}

enumTable.MachineNetworkOwner = {
	Server = 0,
	Client = 1,
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
}

enumTable.ActuatorRelativeTo = {
	World = 0,
	Attachment0 = 1,
}

enumTable.Material = {
	SmoothPlastic = "smoothplastic",
	Wood = "wood",
	Grass = "grass",
	Concrete = "concrete",
	Slate = "slate",
	Glass = "glass",
	Neon = "neon",
	Sand = "sand",
	Water = "water",
	debug = "debug",
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
	Code = "GoogleSansCode",
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
	VCR = "VCR",
	Bembo = "Bembo",
	Beyno = "Beyno",
	Avenir = "Avenir",
	Atiba = "Atiba",
	Aerova = "Aerova",
	DuskfallGothic = "Duskfall Gothic",
	Filted = "Filted",
	GillSans = "GillSans",
	Curlz = "Curlz",
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
	JavaScript = 2,
	Python = 3,
	WASM = 4,
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
	Smooth = 11,
	Smoother = 12,
	RidiculousWiggle = 13,
	RevBack = 14,
	Spring = 15,
	SoftSpring = 16,
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
	Home = 3,
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

enumTable.PhysicsEngine = {
	Default = 0,
	Jolt = 1,
	Ode = 2,
	Bullet = 3,
	PhysX = 4,
	Impulse3D = 6,
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
	RAUDIO = 0,
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

local enumProcessStart = os.clock()
local alreadyExisting = {}
for propName, values in next, dump do
	-- if not propName then
	-- 	continue
	-- end

	local enum = enumTable[propName]
	if enum then
		local existing = {}
		for name, value in next, values do
			if enum[name] then
				table.insert(existing, name)
				continue
			end
			enum[name] = value
		end
		if #existing > 0 then
			table.insert(alreadyExisting, `\t{propName} ({table.concat(existing, ", ")})`)
		end
	else
		enumTable[propName] = values
	end
	--log("[ENUM] Created platform enum " .. propName)
end
if #alreadyExisting > 0 then
	log("[ENUM] The following enums already exist and are skipped:\n" .. table.concat(alreadyExisting, "\n"))
end

local enum = enumtransformer.new(enumTable)
log(string.format("[ENUM] Processed enums in %.3fms", (os.clock() - enumProcessStart) * 1000))
return enum
