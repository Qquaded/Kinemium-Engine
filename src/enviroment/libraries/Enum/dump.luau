local enums = {}
enums.AccessModifierType = {
	Allow = 0,
	Deny = 1,
}
enums.AccessoryType = {
	Unknown = 0,
	Hat = 1,
	Hair = 2,
	Face = 3,
	Neck = 4,
	Shoulder = 5,
	Front = 6,
	Back = 7,
	Waist = 8,
	TShirt = 9,
	Shirt = 10,
	Pants = 11,
	Jacket = 12,
	Sweater = 13,
	Shorts = 14,
	LeftShoe = 15,
	RightShoe = 16,
	DressSkirt = 17,
	Eyebrow = 18,
	Eyelash = 19,
}
enums.ActionOnAutoResumeSync = {
	DontResume = 0,
	KeepStudio = 1,
	KeepLocal = 2,
}
enums.ActionOnStopSync = {
	AlwaysAsk = 0,
	KeepLocalFiles = 1,
	DeleteLocalFiles = 2,
}
enums.ActionType = {
	Nothing = 0,
	Pause = 1,
	Lose = 2,
	Draw = 3,
	Win = 4,
}
enums.ActuatorRelativeTo = {
	Attachment0 = 0,
	Attachment1 = 1,
	World = 2,
}
enums.ActuatorType = {
	None = 0,
	Motor = 1,
	Servo = 2,
}
enums.AdAvailabilityResult = {
	IsAvailable = 1,
	DeviceIneligible = 2,
	ExperienceIneligible = 3,
	InternalError = 4,
	NoFill = 5,
	PlayerIneligible = 6,
	PublisherIneligible = 7,
}
enums.AdEventType = {
	RewardedAdLoaded = 3,
	RewardedAdGrant = 4,
	RewardedAdUnloaded = 5,
	VideoLoaded = 0,
	VideoRemoved = 1,
	UserCompletedVideo = 2,
}
enums.AdFormat = {
	RewardedVideo = 0,
}
enums.AdShape = {
	HorizontalRectangle = 1,
}
enums.AdTeleportMethod = {
	Undefined = 0,
	PortalForward = 1,
	InGameMenuBackButton = 2,
	UIBackButton = 3,
}
enums.AdUIEventType = {
	AdLabelClicked = 0,
	VolumeButtonClicked = 1,
	FullscreenButtonClicked = 2,
	PlayButtonClicked = 3,
	PauseButtonClicked = 4,
	CloseButtonClicked = 5,
	WhyThisAdClicked = 6,
	PlayEventTriggered = 7,
	PauseEventTriggered = 8,
}
enums.AdUIType = {
	None = 0,
	Image = 1,
	Video = 2,
}
enums.AdUnitStatus = {
	Inactive = 0,
	Active = 1,
}
enums.AdornCullingMode = {
	Automatic = 0,
	Never = 1,
}
enums.AdornShading = {
	Default = 0,
	Shaded = 1,
	XRay = 2,
	XRayShaded = 3,
	AlwaysOnTop = 4,
}
enums.AlignType = {
	PrimaryAxisParallel = 2,
	PrimaryAxisPerpendicular = 3,
	PrimaryAxisLookAt = 4,
	AllAxes = 5,
	Parallel = 0,
	Perpendicular = 1,
}
enums.AlphaMode = {
	Overlay = 0,
	Transparency = 1,
	TintMask = 2,
	Opaque = 3,
}
enums.AnalyticsCustomFieldKeys = {
	CustomField01 = 0,
	CustomField02 = 1,
	CustomField03 = 2,
}
enums.AnalyticsEconomyAction = {
	Default = 0,
	Acquire = 1,
	Spend = 2,
}
enums.AnalyticsEconomyFlowType = {
	Sink = 0,
	Source = 1,
}
enums.AnalyticsEconomyTransactionType = {
	IAP = 0,
	Shop = 1,
	Gameplay = 2,
	ContextualPurchase = 3,
	TimedReward = 4,
	Onboarding = 5,
}
enums.AnalyticsLogLevel = {
	Trace = 0,
	Debug = 1,
	Information = 2,
	Warning = 3,
	Error = 4,
	Fatal = 5,
}
enums.AnalyticsProgressionStatus = {
	Default = 0,
	Begin = 1,
	Complete = 2,
	Abandon = 3,
	Fail = 4,
}
enums.AnalyticsProgressionType = {
	Custom = 0,
	Start = 1,
	Fail = 2,
	Complete = 3,
}
enums.AnimationClipFromVideoStatus = {
	Initializing = 0,
	Pending = 1,
	Processing = 2,
	ErrorGeneric = 4,
	Success = 6,
	ErrorVideoTooLong = 7,
	ErrorNoPersonDetected = 8,
	ErrorVideoUnstable = 9,
	Timeout = 10,
	Cancelled = 11,
	ErrorMultiplePeople = 12,
	ErrorUploadingVideo = 2001,
}
enums.AnimationNodeBlend2DInputMode = {
	Cartesian = 0,
	Polar = 1,
}
enums.AnimationNodeInterruptible = {
	Always = 0,
	ClipFinished = 1,
	Expression = 2,
}
enums.AnimationNodePlayMode = {
	Loop = 0,
	PingPong = 1,
	OnceAndHold = 2,
	OnceAndReset = 3,
}
enums.AnimationNodeTransitionType = {
	CrossFade = 0,
	InertialBlend = 1,
	DeadBlend = 2,
}
enums.AnimationNodeType = {
	InvalidNode = 0,
	AddNode = 1,
	BlendNode = 2,
	Blend1DNode = 3,
	Blend2DNode = 4,
	ClipNode = 5,
	GraphOutput = 6,
	MaskNode = 7,
	PrioritySelectNode = 8,
	RandomSequenceNode = 9,
	SelectNode = 10,
	SequenceNode = 11,
	SpeedNode = 12,
	SubtractNode = 13,
}
enums.AnimationNodeWaitFor = {
	ClipFinished = 0,
	Expression = 1,
}
enums.AnimationPriority = {
	Core = 1000,
	Idle = 0,
	Movement = 1,
	Action = 2,
	Action2 = 3,
	Action3 = 4,
	Action4 = 5,
}
enums.AnimatorRetargetingMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.AnnotationChannelContentPreference = {
	None = 0,
	All = 1,
	Unknown = 2,
}
enums.AnnotationEditingMode = {
	None = 0,
	PlacingNew = 1,
	WritingNew = 2,
}
enums.AnnotationPlaceContentPreference = {
	None = 0,
	All = 1,
	MentionsAndReplies = 2,
	Unknown = 3,
}
enums.AnnotationRequestStatus = {
	Success = 0,
	Loading = 1,
	ErrorInternalFailure = 2,
	ErrorNotFound = 3,
	ErrorModerated = 4,
}
enums.AnnotationRequestType = {
	Unknown = 0,
	Create = 1,
	Resolve = 2,
	Delete = 3,
	Edit = 4,
}
enums.AppLifecycleManagerState = {
	Detached = 0,
	Active = 1,
	Inactive = 2,
	Hidden = 3,
}
enums.AppShellActionType = {
	None = 0,
	OpenApp = 1,
	TapChatTab = 2,
	TapConversationEntry = 3,
	TapAvatarTab = 4,
	ReadConversation = 5,
	TapGamePageTab = 6,
	TapHomePageTab = 7,
	GamePageLoaded = 8,
	HomePageLoaded = 9,
	AvatarEditorPageLoaded = 10,
}
enums.AppShellFeature = {
	None = 0,
	Chat = 1,
	AvatarEditor = 2,
	GamePage = 3,
	HomePage = 4,
	More = 5,
	Landing = 6,
}
enums.AppUpdateStatus = {
	Unknown = 0,
	NotSupported = 1,
	Failed = 2,
	NotAvailable = 3,
	Available = 4,
	AvailableBoundChannel = 5,
	AvailableBetaProgram = 6,
}
enums.ApplyStrokeMode = {
	Contextual = 0,
	Border = 1,
}
enums.AspectType = {
	FitWithinMaxSize = 0,
	ScaleWithParentSize = 1,
}
enums.AssetCreatorType = {
	User = 0,
	Group = 1,
}
enums.AssetFetchStatus = {
	Success = 0,
	Failure = 1,
	None = 2,
	Loading = 3,
	TimedOut = 4,
}
enums.AssetType = {
	Image = 1,
	TShirt = 2,
	Audio = 3,
	Mesh = 4,
	Lua = 5,
	Hat = 8,
	Place = 9,
	Model = 10,
	Shirt = 11,
	Pants = 12,
	Decal = 13,
	Head = 17,
	Face = 18,
	Gear = 19,
	Badge = 21,
	Animation = 24,
	Torso = 27,
	RightArm = 28,
	LeftArm = 29,
	LeftLeg = 30,
	RightLeg = 31,
	Package = 32,
	GamePass = 34,
	Plugin = 38,
	MeshPart = 40,
	HairAccessory = 41,
	FaceAccessory = 42,
	NeckAccessory = 43,
	ShoulderAccessory = 44,
	FrontAccessory = 45,
	BackAccessory = 46,
	WaistAccessory = 47,
	ClimbAnimation = 48,
	DeathAnimation = 49,
	FallAnimation = 50,
	IdleAnimation = 51,
	JumpAnimation = 52,
	RunAnimation = 53,
	SwimAnimation = 54,
	WalkAnimation = 55,
	PoseAnimation = 56,
	EmoteAnimation = 61,
	Video = 62,
	TShirtAccessory = 64,
	ShirtAccessory = 65,
	PantsAccessory = 66,
	JacketAccessory = 67,
	SweaterAccessory = 68,
	ShortsAccessory = 69,
	LeftShoeAccessory = 70,
	RightShoeAccessory = 71,
	DressSkirtAccessory = 72,
	FontFamily = 73,
	EyebrowAccessory = 76,
	EyelashAccessory = 77,
	MoodAnimation = 78,
	DynamicHead = 79,
	FaceMakeup = 88,
	LipMakeup = 89,
	EyeMakeup = 90,
	EarAccessory = 57,
	EyeAccessory = 58,
}
enums.AssetTypeVerification = {
	Default = 1,
	ClientOnly = 2,
	Always = 3,
}
enums.AudioApiRollout = {
	Disabled = 0,
	Automatic = 1,
	Enabled = 2,
}
enums.AudioCaptureMode = {}
enums.AudioChannelLayout = {
	Mono = 0,
	Stereo = 1,
	Quad = 2,
	Surround_5 = 3,
	Surround_5_1 = 4,
	Surround_7_1 = 5,
	Surround_7_1_4 = 6,
}
enums.AudioFilterType = {
	Peak = 0,
	LowShelf = 1,
	HighShelf = 2,
	Lowpass12dB = 3,
	Lowpass24dB = 4,
	Lowpass48dB = 5,
	Highpass12dB = 6,
	Highpass24dB = 7,
	Highpass48dB = 8,
	Bandpass = 9,
	Notch = 10,
	Lowpass6dB = 11,
}
enums.AudioSimulationFidelity = {
	None = 0,
	Automatic = 1,
}
enums.AudioSubType = {
	Music = 1,
	SoundEffect = 2,
}
enums.AudioWindowSize = {
	Small = 0,
	Medium = 1,
	Large = 2,
}
enums.AuthorityMode = {
	Server = 0,
	Automatic = 1,
}
enums.AutoIndentRule = {
	Off = 0,
	Absolute = 1,
	Relative = 2,
}
enums.AutomaticSize = {
	None = 0,
	X = 1,
	Y = 2,
	XY = 3,
}
enums.AvatarAssetType = {
	TShirt = 2,
	Hat = 8,
	Shirt = 11,
	Pants = 12,
	Head = 17,
	Face = 18,
	Gear = 19,
	Torso = 27,
	RightArm = 28,
	LeftArm = 29,
	LeftLeg = 30,
	RightLeg = 31,
	HairAccessory = 41,
	FaceAccessory = 42,
	NeckAccessory = 43,
	ShoulderAccessory = 44,
	FrontAccessory = 45,
	BackAccessory = 46,
	WaistAccessory = 47,
	ClimbAnimation = 48,
	FallAnimation = 50,
	IdleAnimation = 51,
	JumpAnimation = 52,
	RunAnimation = 53,
	SwimAnimation = 54,
	WalkAnimation = 55,
	MoodAnimation = 78,
	EmoteAnimation = 61,
	TShirtAccessory = 64,
	ShirtAccessory = 65,
	PantsAccessory = 66,
	JacketAccessory = 67,
	SweaterAccessory = 68,
	ShortsAccessory = 69,
	LeftShoeAccessory = 70,
	RightShoeAccessory = 71,
	DressSkirtAccessory = 72,
	EyebrowAccessory = 76,
	EyelashAccessory = 77,
	DynamicHead = 79,
	FaceMakeup = 88,
	LipMakeup = 89,
	EyeMakeup = 90,
}
enums.AvatarChatServiceFeature = {
	None = 0,
	UniverseAudio = 1,
	UniverseVideo = 2,
	PlaceAudio = 4,
	PlaceVideo = 8,
	UserAudioEligible = 16,
	UserAudio = 32,
	UserVideoEligible = 64,
	UserVideo = 128,
	UserBanned = 256,
	UserVerifiedForVoice = 512,
}
enums.AvatarContextMenuOption = {
	Friend = 0,
	Chat = 1,
	Emote = 2,
	InspectMenu = 3,
}
enums.AvatarGenerationError = {
	None = 0,
	Unknown = 1,
	DownloadFailed = 2,
	Canceled = 3,
	Offensive = 4,
	Timeout = 5,
	JobNotFound = 6,
}
enums.AvatarItemType = {
	Asset = 1,
	Bundle = 2,
}
enums.AvatarPromptResult = {
	Success = 1,
	PermissionDenied = 2,
	Failed = 3,
}
enums.AvatarSettingsAccessoryLimitMethod = {
	Scale = 0,
	Remove = 1,
	PreviewScale = 2,
	PreviewRemove = 3,
}
enums.AvatarSettingsAccessoryMode = {
	PlayerChoice = 0,
	CustomLimit = 1,
}
enums.AvatarSettingsAnimationClipsMode = {
	PlayerChoice = 0,
	CustomClips = 1,
}
enums.AvatarSettingsAnimationPacksMode = {
	PlayerChoice = 0,
	StandardR15 = 1,
	StandardR6 = 2,
}
enums.AvatarSettingsAppearanceMode = {
	PlayerChoice = 0,
	CustomParts = 1,
	CustomBody = 2,
}
enums.AvatarSettingsBuildMode = {
	PlayerChoice = 0,
	CustomBuild = 1,
}
enums.AvatarSettingsClothingMode = {
	PlayerChoice = 0,
	CustomLimit = 1,
}
enums.AvatarSettingsCollisionMode = {
	Default = 0,
	SingleCollider = 1,
	Legacy = 2,
}
enums.AvatarSettingsCustomAccessoryMode = {
	PlayerChoice = 0,
	CustomAccessories = 1,
}
enums.AvatarSettingsCustomBodyType = {
	AvatarReference = 0,
	BundleId = 1,
}
enums.AvatarSettingsCustomClothingMode = {
	PlayerChoice = 0,
	CustomClothing = 1,
}
enums.AvatarSettingsHitAndTouchDetectionMode = {
	UseParts = 0,
	UseCollider = 1,
}
enums.AvatarSettingsJumpMode = {
	JumpHeight = 0,
	JumpPower = 1,
}
enums.AvatarSettingsLegacyCollisionMode = {
	R6Colliders = 0,
	InnerBoxColliders = 1,
}
enums.AvatarSettingsScaleMode = {
	PlayerChoice = 0,
	CustomScale = 1,
}
enums.AvatarThumbnailCustomizationType = {
	Closeup = 1,
	FullBody = 2,
}
enums.AvatarUnificationMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.Axis = {
	X = 0,
	Y = 1,
	Z = 2,
}
enums.BenefitType = {
	DeveloperProduct = 0,
	AvatarAsset = 1,
	AvatarBundle = 2,
}
enums.BinType = {
	Script = 0,
	GameTool = 1,
	Grab = 2,
	Clone = 3,
	Hammer = 4,
}
enums.BodyPart = {
	Head = 0,
	Torso = 1,
	LeftArm = 2,
	RightArm = 3,
	LeftLeg = 4,
	RightLeg = 5,
}
enums.BodyPartR15 = {
	Head = 0,
	UpperTorso = 1,
	LowerTorso = 2,
	LeftFoot = 3,
	LeftLowerLeg = 4,
	LeftUpperLeg = 5,
	RightFoot = 6,
	RightLowerLeg = 7,
	RightUpperLeg = 8,
	LeftHand = 9,
	LeftLowerArm = 10,
	LeftUpperArm = 11,
	RightHand = 12,
	RightLowerArm = 13,
	RightUpperArm = 14,
	RootPart = 15,
	Unknown = 17,
}
enums.BorderMode = {
	Outline = 0,
	Middle = 1,
	Inset = 2,
}
enums.BorderStrokePosition = {
	Outer = 0,
	Center = 1,
	Inner = 2,
}
enums.BreakReason = {
	Other = 0,
	Error = 1,
	SpecialBreakpoint = 2,
	UserBreakpoint = 3,
}
enums.BreakpointRemoveReason = {
	Requested = 0,
	ScriptChanged = 1,
	ScriptRemoved = 2,
}
enums.BulkMoveMode = {
	FireAllEvents = 0,
	FireCFrameChanged = 1,
}
enums.BundleType = {
	BodyParts = 1,
	Animations = 2,
	Shoes = 3,
	DynamicHead = 4,
	DynamicHeadAvatar = 5,
}
enums.Button = {
	Jump = 32,
	Dismount = 8,
}

enums.CageType = {
	Inner = 0,
	Outer = 1,
}
enums.CameraMode = {
	Classic = 0,
	LockFirstPerson = 1,
}
enums.CameraPanMode = {
	Classic = 0,
	EdgeBump = 1,
}
enums.CameraSpeedAdjustBinding = {
	None = 0,
	RmbScroll = 1,
	AltScroll = 2,
}
enums.CameraType = {
	Fixed = 0,
	Attach = 1,
	Watch = 2,
	Track = 3,
	Follow = 4,
	Custom = 5,
	Scriptable = 6,
	Orbital = 7,
}
enums.CaptureGalleryPermission = {
	ReadAndUpload = 0,
}
enums.CaptureType = {
	Screenshot = 1,
	Video = 2,
}
enums.CatalogCategoryFilter = {
	None = 1,
	Featured = 2,
	Collectibles = 3,
	CommunityCreations = 4,
	Premium = 5,
	Recommended = 6,
}
enums.CatalogSortAggregation = {
	Past12Hours = 1,
	PastDay = 2,
	Past3Days = 3,
	PastWeek = 4,
	PastMonth = 5,
	AllTime = 6,
}
enums.CatalogSortType = {
	Relevance = 1,
	PriceHighToLow = 2,
	PriceLowToHigh = 3,
	MostFavorited = 5,
	RecentlyCreated = 6,
	Bestselling = 7,
}
enums.CatalogTimedOptionFilter = {
	All = 1,
	TimedOptionOnly = 2,
}
enums.CellBlock = {
	Solid = 0,
	VerticalWedge = 1,
	CornerWedge = 2,
	InverseCornerWedge = 3,
	HorizontalWedge = 4,
}
enums.CellMaterial = {
	Empty = 0,
	Grass = 1,
	Sand = 2,
	Brick = 3,
	Granite = 4,
	Asphalt = 5,
	Iron = 6,
	Aluminum = 7,
	Gold = 8,
	WoodPlank = 9,
	WoodLog = 10,
	Gravel = 11,
	CinderBlock = 12,
	MossyStone = 13,
	Cement = 14,
	RedPlastic = 15,
	BluePlastic = 16,
	Water = 17,
}
enums.CellOrientation = {
	NegZ = 0,
	X = 1,
	Z = 2,
	NegX = 3,
}
enums.CenterDialogType = {
	UnsolicitedDialog = 1,
	PlayerInitiatedDialog = 2,
	ModalDialog = 3,
	QuitDialog = 4,
}
enums.CharacterControlMode = {
	Default = 0,
	Legacy = 1,
	NoCharacterController = 2,
	LuaCharacterController = 3,
}
enums.ChatCallbackType = {
	OnCreatingChatWindow = 1,
	OnClientSendingMessage = 2,
	OnClientFormattingMessage = 3,
	OnServerReceivingMessage = 17,
}
enums.ChatColor = {
	Blue = 0,
	Green = 1,
	Red = 2,
	White = 3,
}
enums.ChatMode = {
	Menu = 0,
	TextAndMenu = 1,
}
enums.ChatPrivacyMode = {
	AllUsers = 0,
	NoOne = 1,
	Friends = 2,
}
enums.ChatRestrictionStatus = {
	Unknown = 0,
	NotRestricted = 1,
	Restricted = 2,
}
enums.ChatStyle = {
	Classic = 0,
	Bubble = 1,
	ClassicAndBubble = 2,
}
enums.ChatVersion = {
	LegacyChatService = 0,
	TextChatService = 1,
}
enums.ClientAnimatorThrottlingMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.CloseReason = {
	Unknown = 0,
	DeveloperShutdown = 2,
	DeveloperUpdate = 3,
	ServerEmpty = 4,
	OutOfMemory = 5,
}
enums.CollaboratorStatus = {
	None = 0,
	Editing3D = 1,
	Scripting = 2,
	PrivateScripting = 3,
}
enums.CollisionFidelity = {
	Default = 0,
	Hull = 1,
	Box = 2,
	PreciseConvexDecomposition = 3,
}
enums.CommandPermission = {
	Plugin = 0,
	LocalUser = 1,
}
enums.CompileTarget = {
	Client = 0,
	CoreScript = 1,
	Studio = 2,
	CoreScriptRaw = 3,
}
enums.CompletionAcceptanceBehavior = {
	Insert = 0,
	Replace = 1,
	ReplaceOnEnterInsertOnTab = 2,
	InsertOnEnterReplaceOnTab = 3,
}
enums.CompletionItemKind = {
	Text = 1,
	Method = 2,
	Function = 3,
	Constructor = 4,
	Field = 5,
	Variable = 6,
	Class = 7,
	Interface = 8,
	Module = 9,
	Property = 10,
	Unit = 11,
	Value = 12,
	Enum = 13,
	Keyword = 14,
	Snippet = 15,
	Color = 16,
	File = 17,
	Reference = 18,
	Folder = 19,
	EnumMember = 20,
	Constant = 21,
	Struct = 22,
	Event = 23,
	Operator = 24,
	TypeParameter = 25,
}
enums.CompletionItemTag = {
	Deprecated = 1,
	IncorrectIndexType = 2,
	PluginPermissions = 3,
	CommandLinePermissions = 4,
	AddParens = 6,
	PutCursorInParens = 7,
	TypeCorrect = 8,
	ClientServerBoundaryViolation = 9,
	Invalidated = 10,
	PutCursorBeforeEnd = 11,
}
enums.CompletionTriggerKind = {
	Invoked = 1,
	TriggerCharacter = 2,
	TriggerForIncompleteCompletions = 3,
}
enums.CompositeValueCurveType = {
	ColorRGB = 0,
	ColorHSV = 1,
	NumberRange = 2,
	Rect = 3,
	UDim = 4,
	UDim2 = 5,
	Vector2 = 6,
	Vector3 = 7,
}
enums.CompressionAlgorithm = {
	Zstd = 0,
	Zlib = 1,
	lz4 = 3,
	flate = 4,
	brotli = 5,
}
enums.ComputerCameraMovementMode = {
	Default = 0,
	Classic = 1,
	Follow = 2,
	Orbital = 3,
	CameraToggle = 4,
}
enums.ComputerMovementMode = {
	Default = 0,
	KeyboardMouse = 1,
	ClickToMove = 2,
}
enums.ConfigSnapshotErrorState = {
	None = 0,
	LoadFailed = 1,
}
enums.ConnectionError = {
	OK = 0,
	Unknown = 1,
	ConnectErrors = 2,
	AlreadyConnected = 3,
	NoFreeIncomingConnections = 4,
	ConnectionBanned = 5,
	InvalidPassword = 6,
	IncompatibleProtocolVersion = 7,
	IPRecentlyConnected = 8,
	OurSystemRequiresSecurity = 9,
	SecurityKeyMismatch = 10,
	DisconnectErrors = 256,
	DisconnectBadhash = 257,
	DisconnectSecurityKeyMismatch = 258,
	DisconnectProtocolMismatch = 259,
	DisconnectReceivePacketError = 260,
	DisconnectReceivePacketStreamError = 261,
	DisconnectSendPacketError = 262,
	DisconnectIllegalTeleport = 263,
	DisconnectDuplicatePlayer = 264,
	DisconnectDuplicateTicket = 265,
	DisconnectTimeout = 266,
	DisconnectLuaKick = 267,
	DisconnectOnRemoteSysStats = 268,
	DisconnectHashTimeout = 269,
	DisconnectCloudEditKick = 270,
	DisconnectPlayerless = 271,
	DisconnectNewSecurityKeyMismatch = 272,
	DisconnectEvicted = 273,
	DisconnectDevMaintenance = 274,
	DisconnectRejoin = 276,
	DisconnectConnectionLost = 277,
	DisconnectIdle = 278,
	DisconnectRaknetErrors = 279,
	DisconnectWrongVersion = 280,
	DisconnectBySecurityPolicy = 281,
	DisconnectBlockedIP = 282,
	DisconnectClientFailure = 284,
	DisconnectClientRequest = 285,
	DisconnectPrivateServerKickout = 286,
	DisconnectModeratedGame = 287,
	ServerShutdown = 288,
	ReplicatorTimeout = 290,
	PlayerRemoved = 291,
	DisconnectOutOfMemoryKeepPlayingLeave = 292,
	DisconnectRomarkEndOfTest = 293,
	DisconnectCollaboratorPermissionRevoked = 294,
	DisconnectCollaboratorUnderage = 295,
	NetworkInternal = 296,
	NetworkSend = 297,
	NetworkTimeout = 298,
	NetworkMisbehavior = 299,
	NetworkSecurity = 300,
	ReplacementReady = 301,
	ServerEmpty = 302,
	PhantomFreeze = 303,
	AndroidAnticheatKick = 304,
	AndroidEmulatorKick = 305,
	AndroidRootedKick = 306,
	ScreentimeLockoutKick = 307,
	DisconnectionNotification = 308,
	DisconnectVerboselyModeratedGame = 309,
	PlacelaunchErrors = 512,
	PlacelaunchDisabled = 515,
	PlacelaunchError = 516,
	PlacelaunchGameEnded = 517,
	PlacelaunchGameFull = 518,
	PlacelaunchUserLeft = 522,
	PlacelaunchRestricted = 523,
	PlacelaunchUnauthorized = 524,
	PlacelaunchFlooded = 525,
	PlacelaunchHashExpired = 526,
	PlacelaunchHashException = 527,
	PlacelaunchPartyCannotFit = 528,
	PlacelaunchHttpError = 529,
	PlacelaunchUserPrivacyUnauthorized = 533,
	PlacelaunchCreatorBan = 600,
	PlacelaunchCustomMessage = 610,
	PlacelaunchOtherError = 611,
	TeleportErrors = 768,
	TeleportFailure = 769,
	TeleportGameNotFound = 770,
	TeleportGameEnded = 771,
	TeleportGameFull = 772,
	TeleportUnauthorized = 773,
	TeleportFlooded = 774,
	TeleportIsTeleporting = 775,
}
enums.ConnectionState = {
	Connected = 0,
	Disconnected = 1,
}
enums.ContentSourceType = {
	None = 0,
	Uri = 1,
	Object = 2,
	Opaque = 3,
}
enums.ContextActionPriority = {
	Low = 1000,
	Medium = 2000,
	High = 3000,
}
enums.ContextActionResult = {
	Sink = 0,
	Pass = 1,
}
enums.ControlMode = {
	Classic = 0,
	MouseLockSwitch = 1,
}
enums.CoreGuiType = {
	PlayerList = 0,
	Health = 1,
	Backpack = 2,
	Chat = 3,
	All = 4,
	EmotesMenu = 5,
	SelfView = 6,
	Captures = 7,
}
enums.CreateAssetResult = {
	Success = 1,
	PermissionDenied = 2,
	UploadFailed = 3,
	Unknown = 4,
}
enums.CreateOutfitFailure = {
	InvalidName = 1,
	OutfitLimitReached = 2,
	Other = 3,
}
enums.CreatorType = {
	User = 0,
	Group = 1,
}
enums.CreatorTypeFilter = {
	User = 0,
	Group = 1,
	All = 2,
}
enums.CustomCameraMode = {
	Default = 0,
	Classic = 1,
	Follow = 2,
}
enums.DataStoreRequestType = {
	GetAsync = 0,
	SetIncrementAsync = 1,
	UpdateAsync = 2,
	GetSortedAsync = 3,
	SetIncrementSortedAsync = 4,
	OnUpdate = 5,
	ListAsync = 6,
	GetVersionAsync = 7,
	RemoveVersionAsync = 8,
	StandardRead = 9,
	StandardWrite = 10,
	StandardList = 11,
	StandardRemove = 12,
	OrderedRead = 13,
	OrderedWrite = 14,
	OrderedList = 15,
	OrderedRemove = 16,
}
enums.DebuggerEndReason = {
	ClientRequest = 0,
	Timeout = 1,
	InvalidHost = 2,
	Disconnected = 3,
	ServerShutdown = 4,
	ServerProtocolMismatch = 5,
	ConfigurationFailed = 6,
	RpcError = 7,
}
enums.DebuggerExceptionBreakMode = {
	Never = 0,
	Always = 1,
	Unhandled = 2,
}
enums.DebuggerFrameType = {
	C = 0,
	Lua = 1,
}
enums.DebuggerPauseReason = {
	Unknown = 0,
	Requested = 1,
	Breakpoint = 2,
	Exception = 3,
	SingleStep = 4,
	Entrypoint = 5,
}
enums.DebuggerStatus = {
	Success = 0,
	Timeout = 1,
	ConnectionLost = 2,
	InvalidResponse = 3,
	InternalError = 4,
	InvalidState = 5,
	RpcError = 6,
	InvalidArgument = 7,
	ConnectionClosed = 8,
}
enums.DefaultScriptSyncFileType = {
	Lua = 0,
	Luau = 1,
}
enums.DevCameraOcclusionMode = {
	Zoom = 0,
	Invisicam = 1,
}
enums.DevComputerCameraMovementMode = {
	UserChoice = 0,
	Classic = 1,
	Follow = 2,
	Orbital = 3,
	CameraToggle = 4,
}
enums.DevComputerMovementMode = {
	UserChoice = 0,
	KeyboardMouse = 1,
	ClickToMove = 2,
	Scriptable = 3,
}
enums.DevTouchCameraMovementMode = {
	UserChoice = 0,
	Classic = 1,
	Follow = 2,
	Orbital = 3,
}
enums.DevTouchMovementMode = {
	UserChoice = 0,
	Thumbstick = 1,
	DPad = 2,
	Thumbpad = 3,
	ClickToMove = 4,
	Scriptable = 5,
	DynamicThumbstick = 6,
}
enums.DeveloperMemoryTag = {
	Internal = 0,
	HttpCache = 1,
	Instances = 2,
	Signals = 3,
	LuaHeap = 4,
	Script = 5,
	PhysicsCollision = 6,
	BaseParts = 7,
	GraphicsSolidModels = 8,
	GraphicsMeshParts = 10,
	GraphicsParticles = 11,
	GraphicsParts = 12,
	GraphicsSpatialHash = 13,
	GraphicsTerrain = 14,
	GraphicsTexture = 15,
	GraphicsTextureCharacter = 16,
	Sounds = 17,
	StreamingSounds = 18,
	TerrainVoxels = 19,
	Gui = 21,
	Animation = 22,
	Navigation = 23,
	GeometryCSG = 24,
	GraphicsSlimModels = 25,
}
enums.DeviceFeatureType = {
	DeviceCapture = 0,
	InExperienceFAE = 1,
}
enums.DeviceForm = {
	Console = 0,
	Phone = 1,
	Tablet = 2,
	Desktop = 3,
	VR = 4,
}
enums.DeviceLevel = {
	Low = 0,
	Medium = 1,
	High = 2,
}
enums.DeviceType = {
	Unknown = 0,
	Desktop = 1,
	Tablet = 2,
	Phone = 3,
}
enums.DialogBehaviorType = {
	SinglePlayer = 0,
	MultiplePlayers = 1,
}
enums.DialogPurpose = {
	Quest = 0,
	Help = 1,
	Shop = 2,
}
enums.DialogTone = {
	Neutral = 0,
	Friendly = 1,
	Enemy = 2,
}
enums.DisplaySize = {
	Small = 0,
	Medium = 1,
	Large = 2,
}
enums.DominantAxis = {
	Width = 0,
	Height = 1,
}
enums.DraftStatusCode = {
	OK = 0,
	DraftOutdated = 1,
	ScriptRemoved = 2,
	DraftCommitted = 3,
}
enums.DragDetectorDragStyle = {
	TranslateLine = 0,
	TranslatePlane = 1,
	TranslatePlaneOrLine = 2,
	TranslateLineOrPlane = 3,
	TranslateViewPlane = 4,
	RotateAxis = 5,
	RotateTrackball = 6,
	Scriptable = 7,
	BestForDevice = 8,
}
enums.DragDetectorPermissionPolicy = {
	Nobody = 0,
	Everybody = 1,
	Scriptable = 2,
}
enums.DragDetectorResponseStyle = {
	Geometric = 0,
	Physical = 1,
	Custom = 2,
}
enums.DraggerCoordinateSpace = {
	Object = 0,
	World = 1,
}
enums.DraggerMovementMode = {
	Geometric = 0,
	Physical = 1,
}
enums.DraggingScrollBar = {
	None = 0,
	Horizontal = 1,
	Vertical = 2,
}
enums.EasingDirection = {
	In = 0,
	Out = 1,
	InOut = 2,
}
enums.EasingStyle = {
	Linear = 0,
	Sine = 1,
	Back = 2,
	Quad = 3,
	Quart = 4,
	Quint = 5,
	Bounce = 6,
	Elastic = 7,
	Exponential = 8,
	Circular = 9,
	Cubic = 10,
}
enums.EditableStatus = {
	Unknown = 0,
	Allowed = 1,
	Disallowed = 2,
}
enums.ElasticBehavior = {
	WhenScrollable = 0,
	Always = 1,
	Never = 2,
}
enums.EnviromentalPhysicsThrottle = {
	DefaultAuto = 0,
	Disabled = 1,
	Always = 2,
	Skip2 = 3,
	Skip4 = 4,
	Skip8 = 5,
	Skip16 = 6,
}
enums.ExperienceAuthScope = {
	DefaultScope = 0,
	CreatorAssetsCreate = 1,
}
enums.ExperienceEventStatus = {
	Active = 0,
	Cancelled = 1,
	Moderated = 2,
	Unpublished = 3,
	Unknown = 4,
}
enums.ExperienceStateCaptureSelectionMode = {
	Default = 0,
	SafetyHighlightMode = 1,
}
enums.ExperienceStateRecordingLoadMode = {
	NewReplay = 0,
	ContiguousSlice = 1,
	NoncontiguousSlice = 2,
}
enums.ExperienceStateRecordingLoadSourceType = {
	S3Url = 0,
	File = 1,
}
enums.ExperienceStateRecordingPlaybackMode = {
	Undefined = 0,
	Stopped = 1,
	Playing = 2,
	Rewinding = 3,
}
enums.ExplosionType = {
	NoCraters = 0,
	Craters = 1,
}
enums.FACSDataLod = {
	LOD0 = 0,
	LOD1 = 1,
	LODCount = 2,
}
enums.FacialAgeEstimationResultType = {
	Complete = 0,
	Cancel = 1,
	Error = 2,
}
enums.FacialAnimationStreamingState = {
	None = 0,
	Audio = 1,
	Video = 2,
	Place = 4,
	Server = 8,
}
enums.FacsActionUnit = {
	ChinRaiserUpperLip = 0,
	ChinRaiser = 1,
	FlatPucker = 2,
	Funneler = 3,
	LowerLipSuck = 4,
	LipPresser = 5,
	LipsTogether = 6,
	MouthLeft = 7,
	MouthRight = 8,
	Pucker = 9,
	UpperLipSuck = 10,
	LeftCheekPuff = 11,
	LeftDimpler = 12,
	LeftLipCornerDown = 13,
	LeftLowerLipDepressor = 14,
	LeftLipCornerPuller = 15,
	LeftLipStretcher = 16,
	LeftUpperLipRaiser = 17,
	RightCheekPuff = 18,
	RightDimpler = 19,
	RightLipCornerDown = 20,
	RightLowerLipDepressor = 21,
	RightLipCornerPuller = 22,
	RightLipStretcher = 23,
	RightUpperLipRaiser = 24,
	JawDrop = 25,
	JawLeft = 26,
	JawRight = 27,
	Corrugator = 28,
	LeftBrowLowerer = 29,
	LeftOuterBrowRaiser = 30,
	LeftNoseWrinkler = 31,
	LeftInnerBrowRaiser = 32,
	RightBrowLowerer = 33,
	RightOuterBrowRaiser = 34,
	RightInnerBrowRaiser = 35,
	RightNoseWrinkler = 36,
	EyesLookDown = 37,
	EyesLookLeft = 38,
	EyesLookUp = 39,
	EyesLookRight = 40,
	LeftCheekRaiser = 41,
	LeftEyeUpperLidRaiser = 42,
	LeftEyeClosed = 43,
	RightCheekRaiser = 44,
	RightEyeUpperLidRaiser = 45,
	RightEyeClosed = 46,
	TongueDown = 47,
	TongueOut = 48,
	TongueUp = 49,
}
enums.FeatureRestrictionAbuseVector = {
	ExperienceChat = 0,
	Communication = 1,
}
enums.FieldOfViewMode = {
	Vertical = 0,
	Diagonal = 1,
	MaxAxis = 2,
}
enums.FillDirection = {
	Horizontal = 0,
	Vertical = 1,
}
enums.FilterErrorType = {
	BackslashNotEscapingAnything = 0,
	BadBespokeFilter = 1,
	BadName = 2,
	IncompleteOr = 3,
	IncompleteParenthesis = 4,
	InvalidDoubleStar = 5,
	InvalidTilde = 6,
	PropertyBadOperator = 7,
	PropertyDoesNotExist = 8,
	PropertyInvalidField = 9,
	PropertyInvalidValue = 10,
	PropertyUnsupportedFields = 11,
	PropertyUnsupportedProperty = 12,
	UnexpectedNameIndex = 13,
	UnexpectedToken = 14,
	UnfinishedBinaryOperator = 15,
	UnfinishedQuote = 16,
	UnknownBespokeFilter = 17,
	WildcardInProperty = 18,
}
enums.FilterResult = {
	Accepted = 0,
	Rejected = 1,
}
enums.FilterType = {
	Exclude = 0,
	Include = 1,
}
enums.FinishRecordingOperation = {
	Cancel = 0,
	Commit = 1,
	Append = 2,
}
enums.FluidFidelity = {
	Automatic = 0,
	UseCollisionGeometry = 1,
	UsePreciseGeometry = 2,
}
enums.FluidForces = {
	Default = 0,
	Experimental = 1,
}
enums.Font = {
	Legacy = 0,
	Arial = 1,
	ArialBold = 2,
	SourceSans = 3,
	SourceSansBold = 4,
	SourceSansLight = 5,
	SourceSansItalic = 6,
	Bodoni = 7,
	Garamond = 8,
	Cartoon = 9,
	Code = 10,
	Highway = 11,
	SciFi = 12,
	Arcade = 13,
	Fantasy = 14,
	Antique = 15,
	SourceSansSemibold = 16,
	Gotham = 17,
	GothamMedium = 18,
	GothamBold = 19,
	GothamBlack = 20,
	AmaticSC = 21,
	Bangers = 22,
	Creepster = 23,
	DenkOne = 24,
	Fondamento = 25,
	FredokaOne = 26,
	GrenzeGotisch = 27,
	IndieFlower = 28,
	JosefinSans = 29,
	Jura = 30,
	Kalam = 31,
	LuckiestGuy = 32,
	Merriweather = 33,
	Michroma = 34,
	Nunito = 35,
	Oswald = 36,
	PatrickHand = 37,
	PermanentMarker = 38,
	Roboto = 39,
	RobotoCondensed = 40,
	RobotoMono = 41,
	Sarpanch = 42,
	SpecialElite = 43,
	TitilliumWeb = 44,
	Ubuntu = 45,
	Arimo = 50,
	ArimoBold = 51,
}
enums.FontSize = {
	Size8 = 0,
	Size9 = 1,
	Size10 = 2,
	Size11 = 3,
	Size12 = 4,
	Size14 = 5,
	Size18 = 6,
	Size24 = 7,
	Size36 = 8,
	Size48 = 9,
	Size28 = 10,
	Size32 = 11,
	Size42 = 12,
	Size60 = 13,
	Size96 = 14,
}
enums.FontStyle = {
	Normal = 0,
	Italic = 1,
}
enums.FontWeight = {
	Thin = 100,
	ExtraLight = 200,
	Light = 300,
	Regular = 400,
	Medium = 500,
	SemiBold = 600,
	Bold = 700,
	ExtraBold = 800,
	Heavy = 900,
}
enums.ForceLimitMode = {
	Magnitude = 0,
	PerAxis = 1,
}
enums.FormFactor = {
	Symmetric = 0,
	Brick = 1,
	Plate = 2,
	Custom = 3,
}
enums.FrameStyle = {
	Custom = 0,
	ChatBlue = 1,
	ChatGreen = 4,
	ChatRed = 5,
	DropShadow = 6,
}
enums.FramerateManagerMode = {
	Automatic = 0,
	On = 1,
	Off = 2,
}
enums.FriendRequestEvent = {
	Issue = 0,
	Revoke = 1,
	Accept = 2,
	Deny = 3,
}
enums.FriendStatus = {
	Unknown = 0,
	NotFriend = 1,
	Friend = 2,
	FriendRequestSent = 3,
	FriendRequestReceived = 4,
}
enums.FunctionalTestResult = {
	Passed = 0,
	Warning = 1,
	Error = 2,
}
enums.GamepadType = {
	Unknown = 0,
	PS4 = 1,
	PS5 = 2,
	XboxOne = 3,
}
enums.GearGenreSetting = {
	AllGenres = 0,
	MatchingGenreOnly = 1,
}
enums.GearType = {
	MeleeWeapons = 0,
	RangedWeapons = 1,
	Explosives = 2,
	PowerUps = 3,
	NavigationEnhancers = 4,
	MusicalInstruments = 5,
	SocialItems = 6,
	BuildingTools = 7,
	Transport = 8,
}
enums.Genre = {
	All = 0,
	TownAndCity = 1,
	Fantasy = 2,
	SciFi = 3,
	Ninja = 4,
	Scary = 5,
	Pirate = 6,
	Adventure = 7,
	Sports = 8,
	Funny = 9,
	WildWest = 10,
	War = 11,
	SkatePark = 12,
	Tutorial = 13,
}
enums.GraphicsMode = {
	Automatic = 1,
	Direct3D11 = 2,
	OpenGL = 4,
	Metal = 5,
	Vulkan = 6,
	NoGraphics = 9,
}
enums.GraphicsOptimizationMode = {
	Performance = 0,
	Balanced = 1,
	Quality = 2,
}
enums.GroupMembershipStatus = {
	None = 0,
	Joined = 1,
	JoinRequestPending = 2,
	AlreadyMember = 3,
}
enums.GuiState = {
	Idle = 0,
	Hover = 1,
	Press = 2,
	NonInteractable = 3,
}
enums.GuiType = {
	Core = 0,
	Custom = 1,
	PlayerNameplates = 2,
	CustomBillboards = 3,
	CoreBillboards = 4,
}
enums.HandRigDescriptionSide = {
	None = 0,
	Left = 1,
	Right = 2,
}
enums.HandlesStyle = {
	Resize = 0,
	Movement = 1,
}
enums.HapticEffectType = {
	Custom = 0,
	UIHover = 1,
	UIClick = 2,
	UINotification = 3,
	GameplayExplosion = 4,
	GameplayCollision = 5,
}
enums.HashAlgorithm = {
	Blake2b = 0,
	Blake3 = 1,
	Md5 = 2,
	Sha1 = 3,
	Sha256 = 4,
}
enums.HighlightDepthMode = {
	AlwaysOnTop = 0,
	Occluded = 1,
}
enums.HorizontalAlignment = {
	Center = 0,
	Left = 1,
	Right = 2,
}
enums.HoverAnimateSpeed = {
	VerySlow = 0,
	Slow = 1,
	Medium = 2,
	Fast = 3,
	VeryFast = 4,
}
enums.HttpCachePolicy = {
	None = 0,
	Full = 1,
	DataOnly = 2,
	Default = 3,
	InternalRedirectRefresh = 4,
}
enums.HttpCompression = {
	None = 0,
	Gzip = 1,
}
enums.HttpContentType = {
	ApplicationJson = 0,
	ApplicationXml = 1,
	ApplicationUrlEncoded = 2,
	TextPlain = 3,
	TextXml = 4,
}
enums.HttpError = {
	OK = 0,
	InvalidUrl = 1,
	DnsResolve = 2,
	ConnectFail = 3,
	OutOfMemory = 4,
	TimedOut = 5,
	TooManyRedirects = 6,
	InvalidRedirect = 7,
	NetFail = 8,
	Aborted = 9,
	SslConnectFail = 10,
	SslVerificationFail = 11,
	Unknown = 12,
	ConnectionClosed = 13,
	ServerProtocolError = 14,
	CreatorEnvironmentsNotSupportedByService = 15,
}
enums.HttpRequestType = {
	Default = 0,
	MarketplaceService = 2,
	Players = 7,
	Chat = 15,
	Avatar = 16,
	Analytics = 23,
	Localization = 25,
}
enums.HumanoidCollisionType = {
	OuterBox = 0,
	InnerBox = 1,
}
enums.HumanoidDisplayDistanceType = {
	Viewer = 0,
	Subject = 1,
	None = 2,
}
enums.HumanoidHealthDisplayType = {
	DisplayWhenDamaged = 0,
	AlwaysOn = 1,
	AlwaysOff = 2,
}
enums.HumanoidStateType = {
	FallingDown = 0,
	Ragdoll = 1,
	GettingUp = 2,
	Jumping = 3,
	Swimming = 4,
	Freefall = 5,
	Flying = 6,
	Landed = 7,
	Running = 8,
	RunningNoPhysics = 10,
	StrafingNoPhysics = 11,
	Climbing = 12,
	Seated = 13,
	PlatformStanding = 14,
	Dead = 15,
	Physics = 16,
	None = 18,
}
enums.IKCollisionsMode = {
	NoCollisions = 0,
	OtherMechanismsAnchored = 1,
	IncludeContactedMechanisms = 2,
}
enums.IKControlConstraintSupport = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.IKControlType = {
	Transform = 0,
	Position = 1,
	Rotation = 2,
	LookAt = 3,
}
enums.IXPLoadingStatus = {
	None = 0,
	Pending = 1,
	Initialized = 2,
	ErrorInvalidUser = 3,
	ErrorConnection = 4,
	ErrorJsonParse = 5,
	ErrorTimedOut = 6,
}
enums.ImageAlphaType = {
	Default = 1,
	LockCanvasAlpha = 2,
	LockCanvasColor = 3,
}
enums.ImageCombineType = {
	BlendSourceOver = 1,
	Overwrite = 2,
	Add = 3,
	Multiply = 4,
	AlphaBlend = 5,
}
enums.InOut = {
	Edge = 0,
	Inset = 1,
	Center = 2,
}
enums.InfoType = {
	Asset = 0,
	Product = 1,
	GamePass = 2,
	Subscription = 3,
	Bundle = 4,
}
enums.InitialDockState = {
	Top = 0,
	Bottom = 1,
	Left = 2,
	Right = 3,
	Float = 4,
}
enums.InputActionType = {
	Bool = 0,
	Direction1D = 1,
	Direction2D = 2,
	Direction3D = 3,
	ViewportPosition = 4,
}
enums.InputType = {
	NoInput = 0,
	Constant = 12,
	Sin = 13,
}
enums.IntermediateMeshGenerationResult = {
	HighQualityMesh = 0,
}
enums.InterpolationThrottlingMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.InviteState = {
	Placed = 0,
	Accepted = 1,
	Declined = 2,
	Missed = 3,
}
enums.ItemLineAlignment = {
	Automatic = 0,
	Start = 1,
	Center = 2,
	End = 3,
	Stretch = 4,
}
enums.JoinSource = {
	CreatedItemAttribution = 1,
}
enums.JointCreationMode = {
	All = 0,
	Surface = 1,
	None = 2,
}
enums.KeyInterpolationMode = {
	Constant = 0,
	Linear = 1,
	Cubic = 2,
}
enums.KeywordFilterType = {
	Include = 0,
	Exclude = 1,
}
enums.Language = {
	Default = 0,
}
enums.LeftRight = {
	Left = 0,
	Center = 1,
	Right = 2,
}
enums.LexemeType = {
	Eof = 0,
	Name = 1,
	QuotedString = 2,
	Number = 3,
	And = 4,
	Or = 5,
	Equal = 6,
	TildeEqual = 7,
	GreaterThan = 8,
	GreaterThanEqual = 9,
	LessThan = 10,
	LessThanEqual = 11,
	Colon = 12,
	Dot = 13,
	LeftParenthesis = 14,
	RightParenthesis = 15,
	Star = 16,
	DoubleStar = 17,
	ReservedSpecial = 18,
}
enums.LightingStyle = {
	Realistic = 0,
	Soft = 1,
}
enums.Limb = {
	Head = 0,
	Torso = 1,
	LeftArm = 2,
	RightArm = 3,
	LeftLeg = 4,
	RightLeg = 5,
	Unknown = 6,
}
enums.LineJoinMode = {
	Round = 0,
	Bevel = 1,
	Miter = 2,
}
enums.ListDisplayMode = {
	Horizontal = 0,
	Vertical = 1,
}
enums.ListenerLocation = {
	Default = 0,
	None = 1,
	Character = 2,
	Camera = 3,
}
enums.ListenerType = {
	Camera = 0,
	CFrame = 1,
	ObjectPosition = 2,
	ObjectCFrame = 3,
}
enums.LiveEditingAtomicUpdateResponse = {
	Success = 0,
	FailureGuidNotFound = 1,
	FailureHashMismatch = 2,
	FailureOperationIllegal = 3,
}
enums.LiveEditingBroadcastMessageType = {
	Normal = 0,
	Warning = 1,
	Error = 2,
}
enums.LoadCharacterLayeredClothing = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.LoadDynamicHeads = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.LocationType = {
	Character = 0,
	Camera = 1,
	ObjectPosition = 2,
}
enums.LuauTypeCheckMode = {
	Default = 0,
	NoCheck = 1,
	Nonstrict = 2,
	Strict = 3,
}
enums.MakeupType = {
	Face = 0,
	Lip = 1,
	Eye = 2,
}
enums.MarketplaceBulkPurchasePromptStatus = {
	Completed = 1,
	Aborted = 2,
	Error = 3,
}

enums.MarketplaceProductType = {
	AvatarAsset = 1,
	AvatarBundle = 2,
}
enums.MarkupKind = {
	PlainText = 0,
	Markdown = 1,
}
enums.MatchmakingType = {
	Default = 1,
	XboxOnly = 2,
	PlayStationOnly = 3,
}

enums.MaterialPattern = {
	Regular = 0,
	Organic = 1,
}
enums.MembershipType = {
	None = 0,
	BuildersClub = 1,
	TurboBuildersClub = 2,
	OutrageousBuildersClub = 3,
	Premium = 4,
}
enums.MeshPartDetailLevel = {
	DistanceBased = 0,
	Level00 = 1,
	Level01 = 2,
	Level02 = 3,
	Level03 = 4,
	Level04 = 5,
}
enums.MeshPartHeadsAndAccessories = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.MeshScaleUnit = {
	Stud = 0,
	Meter = 1,
	CM = 2,
	MM = 3,
	Foot = 4,
	Inch = 5,
}
enums.MeshType = {
	Head = 0,
	Torso = 1,
	Wedge = 2,
	Sphere = 3,
	Cylinder = 4,
	FileMesh = 5,
	Brick = 6,
	Prism = 7,
	Pyramid = 8,
	ParallelRamp = 9,
	RightAngleRamp = 10,
	CornerWedge = 11,
}
enums.MessageType = {
	MessageOutput = 0,
	MessageInfo = 1,
	MessageWarning = 2,
	MessageError = 3,
}
enums.ModelLevelOfDetail = {
	Automatic = 0,
	StreamingMesh = 1,
	Disabled = 2,
	SLIM = 4,
}
enums.ModelStreamingBehavior = {
	Default = 0,
	Legacy = 1,
	Improved = 2,
}
enums.ModelStreamingMode = {
	Default = 0,
	Atomic = 1,
	Persistent = 2,
	PersistentPerPlayer = 3,
	Nonatomic = 4,
}
enums.ModerationResultCategory = {
	ViolationDetected = 0,
	Borderline = 1,
	NoViolationDetected = 2,
}
enums.ModerationResultLabel = {
	ChildExploitation = 0,
	SuicideSelfInjuryAndHarmfulBehavior = 1,
	ThreatsBullyingAndHarassment = 2,
	TerrorismAndViolentExtremism = 3,
	DiscriminationSlursAndHateSpeech = 4,
	RealWorldSensitiveEvents = 5,
	ViolentContentAndGore = 6,
	RomanticAndSexualContent = 7,
	IllegalAndRegulatedGoodsAndActivities = 8,
	Profanity = 9,
	Other = 100,
}
enums.ModerationStatus = {
	ReviewedApproved = 1,
	ReviewedRejected = 2,
	NotReviewed = 3,
	NotApplicable = 4,
	Invalid = 5,
}
enums.ModifierKey = {
	Shift = 0,
	Ctrl = 1,
	Alt = 2,
	Meta = 3,
}
enums.MouseBehavior = {
	Default = 0,
	LockCenter = 1,
	LockCurrentPosition = 2,
}
enums.MoveState = {
	Stopped = 0,
	Coasting = 1,
	Pushing = 2,
	Stopping = 3,
	AirFree = 4,
}
enums.MoverConstraintRootBehaviorMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.MuteState = {
	Unmuted = 0,
	Muted = 1,
}
enums.NameOcclusion = {
	NoOcclusion = 0,
	EnemyOcclusion = 1,
	OccludeAll = 2,
}
enums.NegateOperationHiddenHistory = {
	None = 0,
	NegatedUnion = 1,
	NegatedIntersection = 2,
}

enums.NetworkStatus = {
	Unknown = 0,
	Connected = 1,
	Disconnected = 2,
}
enums.NoiseType = {
	SimplexGabor = 0,
}
enums.NormalId = {
	Right = 0,
	Top = 1,
	Back = 2,
	Left = 3,
	Bottom = 4,
	Front = 5,
}
enums.NotificationButtonType = {
	Primary = 0,
	Secondary = 1,
}
enums.OperationType = {
	Null = 0,
	Union = 1,
	Subtraction = 2,
	Intersection = 3,
	Primitive = 4,
}
enums.OrientationAlignmentMode = {
	OneAttachment = 0,
	TwoAttachment = 1,
}
enums.OutfitSource = {
	All = 1,
	Created = 2,
	Purchased = 3,
}
enums.OutfitType = {
	All = 1,
	Avatar = 2,
	DynamicHead = 3,
	Shoes = 4,
}
enums.OutputLayoutMode = {
	Horizontal = 0,
	Vertical = 1,
}
enums.OverrideMouseIconBehavior = {
	None = 0,
	ForceShow = 1,
	ForceHide = 2,
}
enums.PackagePermission = {
	None = 0,
	NoAccess = 1,
	Revoked = 2,
	UseView = 3,
	Edit = 4,
	Own = 5,
}
enums.PartType = {
	Ball = 0,
	Block = 1,
	Cylinder = 2,
	Wedge = 3,
	CornerWedge = 4,
}
enums.ParticleEmitterShape = {
	Box = 0,
	Sphere = 1,
	Cylinder = 2,
	Disc = 3,
}
enums.ParticleEmitterShapeInOut = {
	Outward = 0,
	Inward = 1,
	InAndOut = 2,
}
enums.ParticleEmitterShapeStyle = {
	Volume = 0,
	Surface = 1,
}
enums.ParticleFlipbookLayout = {
	None = 0,
	Grid2x2 = 1,
	Grid4x4 = 2,
	Grid8x8 = 3,
	Custom = 4,
}
enums.ParticleFlipbookMode = {
	Loop = 0,
	OneShot = 1,
	PingPong = 2,
	Random = 3,
}
enums.ParticleFlipbookTextureCompatible = {
	NotCompatible = 0,
	Compatible = 1,
	Unknown = 2,
}
enums.ParticleOrientation = {
	FacingCamera = 0,
	FacingCameraWorldUp = 1,
	VelocityParallel = 2,
	VelocityPerpendicular = 3,
}
enums.PathStatus = {
	Success = 0,
	NoPath = 5,
	ClosestNoPath = 1,
	ClosestOutOfRange = 2,
	FailStartNotEmpty = 3,
	FailFinishNotEmpty = 4,
}
enums.PathWaypointAction = {
	Walk = 0,
	Jump = 1,
	Custom = 2,
}
enums.PathfindingUseImprovedSearch = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.PeoplePageLayout = {
	Card = 0,
	List = 1,
}
enums.PerformanceOverlayMode = {
	Overdraw = 0,
	Transparent = 1,
	Decals = 2,
	Lights = 3,
}
enums.PermissionLevelShown = {
	Game = 0,
	Studio = 3,
}
enums.PhysicsSimulationRate = {
	Fixed240Hz = 0,
	Fixed120Hz = 1,
	Fixed60Hz = 2,
}
enums.PhysicsSteppingMethod = {
	Default = 0,
	Fixed = 1,
	Adaptive = 2,
}
enums.PlaceContentPreference = {
	None = 0,
	All = 1,
	MentionsAndReplies = 2,
	Unknown = 3,
}
enums.PlacePublishType = {
	None = 0,
	Publish = 1,
	Save = 2,
}
enums.Platform = {
	Windows = 0,
	OSX = 1,
	IOS = 2,
	Android = 3,
	XBoxOne = 4,
	PS4 = 5,
	PS3 = 6,
	XBox360 = 7,
	WiiU = 8,
	NX = 9,
	Ouya = 10,
	AndroidTV = 11,
	Chromecast = 12,
	Linux = 13,
	SteamOS = 14,
	WebOS = 15,
	DOS = 16,
	BeOS = 17,
	UWP = 18,
	PS5 = 19,
	MetaOS = 20,
	FreeBSD = 21,
	None = 22,
}
enums.PlaybackState = {
	Begin = 0,
	Delayed = 1,
	Playing = 2,
	Paused = 3,
	Completed = 4,
	Cancelled = 5,
}
enums.PlayerActions = {
	CharacterForward = 0,
	CharacterBackward = 1,
	CharacterLeft = 2,
	CharacterRight = 3,
	CharacterJump = 4,
}
enums.PlayerCharacterDestroyBehavior = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.PlayerChatType = {
	All = 0,
	Team = 1,
	Whisper = 2,
}
enums.PlayerDataErrorState = {
	LoadFailed = 0,
	FlushFailed = 1,
	ReleaseFailed = 2,
	None = 3,
}
enums.PlayerDataLoadFailureBehavior = {
	Failure = 0,
	FallbackToDefault = 1,
	Kick = 2,
}
enums.PlayerExitReason = {
	Unknown = 0,
	PlatformKick = 1,
	CreatorKick = 2,
}
enums.PoseEasingDirection = {
	In = 0,
	Out = 1,
	InOut = 2,
}
enums.PoseEasingStyle = {
	Linear = 0,
	Constant = 1,
	Elastic = 2,
	Cubic = 3,
	Bounce = 4,
	CubicV2 = 5,
}
enums.PositionAlignmentMode = {
	OneAttachment = 0,
	TwoAttachment = 1,
}
enums.PredictionMode = {
	Automatic = 0,
	On = 1,
	Off = 2,
}
enums.PredictionStatus = {
	Authoritative = 0,
	Predicted = 1,
	None = 2,
}
enums.PreferredInput = {
	KeyboardAndMouse = 0,
	Gamepad = 1,
	Touch = 2,
}
enums.PreferredTextSize = {
	Medium = 1,
	Large = 2,
	Larger = 3,
	Largest = 4,
}
enums.PrimalPhysicsSolver = {
	Default = 0,
	Experimental = 1,
	Disabled = 2,
}
enums.PrimitiveType = {
	Null = 0,
	Ball = 1,
	Cylinder = 2,
	Block = 3,
	Wedge = 4,
	CornerWedge = 5,
}
enums.PrivilegeType = {
	Owner = 255,
	Admin = 240,
	Member = 128,
	Visitor = 10,
	Banned = 0,
}
enums.ProductLocationRestriction = {
	AvatarShop = 0,
	AllowedGames = 1,
	AllGames = 2,
}
enums.ProductPurchaseChannel = {
	InExperience = 1,
	ExperienceDetailsPage = 2,
	AdReward = 3,
	CommerceProduct = 4,
}
enums.ProductPurchaseDecision = {
	NotProcessedYet = 0,
	PurchaseGranted = 1,
}
enums.PromptCreateAssetResult = {
	Success = 1,
	PermissionDenied = 2,
	Timeout = 3,
	UploadFailed = 4,
	NoUserInput = 5,
	UnknownFailure = 6,
	UGCValidationFailed = 7,
	ModeratedName = 8,
	PurchaseFailure = 9,
	TokenInvalid = 10,
}
enums.PromptCreateAvatarResult = {
	Success = 1,
	PermissionDenied = 2,
	Timeout = 3,
	UploadFailed = 4,
	NoUserInput = 5,
	InvalidHumanoidDescription = 6,
	UGCValidationFailed = 7,
	ModeratedName = 8,
	MaxOutfits = 9,
	PurchaseFailure = 10,
	UnknownFailure = 11,
	TokenInvalid = 12,
}
enums.PromptExperienceDetailsResult = {
	PromptClosed = 0,
	TeleportAttempted = 1,
}
enums.PromptLinkSharingResult = {
	Success = 1,
	PlayerLeft = 2,
	InvalidLaunchData = 3,
}
enums.PromptPublishAssetResult = {
	Success = 1,
	PermissionDenied = 2,
	Timeout = 3,
	UploadFailed = 4,
	NoUserInput = 5,
	UnknownFailure = 6,
}
enums.PropertyStatus = {
	Ok = 0,
	Warning = 1,
	Error = 2,
}
enums.ProximityPromptExclusivity = {
	OnePerButton = 0,
	OneGlobally = 1,
	AlwaysShow = 2,
}
enums.ProximityPromptInputType = {
	Keyboard = 0,
	Gamepad = 1,
	Touch = 2,
}
enums.ProximityPromptStyle = {
	Default = 0,
	Custom = 1,
}
enums.QualityLevel = {
	Automatic = 0,
	Level01 = 1,
	Level02 = 2,
	Level03 = 3,
	Level04 = 4,
	Level05 = 5,
	Level06 = 6,
	Level07 = 7,
	Level08 = 8,
	Level09 = 9,
	Level10 = 10,
	Level11 = 11,
	Level12 = 12,
	Level13 = 13,
	Level14 = 14,
	Level15 = 15,
	Level16 = 16,
	Level17 = 17,
	Level18 = 18,
	Level19 = 19,
	Level20 = 20,
	Level21 = 21,
}
enums.R15CollisionType = {
	OuterBox = 0,
	InnerBox = 1,
}
enums.RaycastFilterType = {
	Exclude = 0,
	Include = 1,
}
enums.ReadCapturesFromGalleryResult = {
	Success = 0,
	NeedPermission = 1,
}
enums.RecommendationActionType = {
	AddReaction = 0,
	RemoveReaction = 1,
	Share = 2,
	Report = 3,
	Comment = 4,
	Play = 5,
	Purchase = 6,
}
enums.RecommendationDepartureIntent = {
	Neutral = 0,
	Positive = 1,
	Negative = 2,
}
enums.RecommendationImpressionType = {
	View = 0,
	NotViewable = 1,
}
enums.RecommendationItemContentType = {
	Static = 0,
	Dynamic = 1,
	Interactive = 2,
}
enums.RecommendationItemVisibility = {
	Private = 0,
	Public = 1,
}
enums.RejectCharacterDeletions = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.RenderFidelity = {
	Automatic = 0,
	Precise = 1,
	Performance = 2,
}
enums.RenderPriority = {
	First = 0,
	Input = 100,
	Camera = 200,
	Character = 300,
	Last = 2000,
}
enums.RenderingCacheOptimizationMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.RenderingTestComparisonMethod = {
	psnr = 0,
	diff = 1,
}
enums.ReplicateInstanceDestroySetting = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.ResamplerMode = {
	Default = 0,
	Pixelated = 1,
}
enums.ReservedHighlightId = {
	Standard = 0,
	Selection = 524288,
	Hover = 262144,
	Active = 131072,
}
enums.RestPose = {
	Default = 0,
	RotationsReset = 1,
	Custom = 2,
}
enums.RestPoseModel = {
	FromRigInACE = 0,
	FromRigInFile = 1,
}
enums.ReturnKeyType = {
	Default = 0,
	Done = 1,
	Go = 2,
	Next = 3,
	Search = 4,
	Send = 5,
}
enums.ReverbType = {
	NoReverb = 0,
	GenericReverb = 1,
	PaddedCell = 2,
	Room = 3,
	Bathroom = 4,
	LivingRoom = 5,
	StoneRoom = 6,
	Auditorium = 7,
	ConcertHall = 8,
	Cave = 9,
	Arena = 10,
	Hangar = 11,
	CarpettedHallway = 12,
	Hallway = 13,
	StoneCorridor = 14,
	Alley = 15,
	Forest = 16,
	City = 17,
	Mountains = 18,
	Quarry = 19,
	Plain = 20,
	ParkingLot = 21,
	SewerPipe = 22,
	UnderWater = 23,
}
enums.ReviewableContentState = {
	Pending = 0,
	Completed = 1,
	Failed = 2,
}
enums.RibbonTool = {
	Select = 0,
	Scale = 1,
	Rotate = 2,
	Move = 3,
	Transform = 4,
	ColorPicker = 5,
	MaterialPicker = 6,
	Group = 7,
	Ungroup = 8,
	None = 9,
	PivotEditor = 10,
}
enums.RigLabel = {
	Invalid = 0,
	Root = 1,
	Pelvis = 2,
	Waist = 3,
	Chest = 4,
	Neck = 5,
	HeadBase = 6,
	LeftClavicle = 7,
	LeftShoulder = 8,
	LeftElbow = 9,
	LeftWrist = 10,
	RightClavicle = 11,
	RightShoulder = 12,
	RightElbow = 13,
	RightWrist = 14,
	LeftHip = 15,
	LeftKnee = 16,
	LeftAnkle = 17,
	LeftToes = 18,
	RightHip = 19,
	RightKnee = 20,
	RightAnkle = 21,
	RightToes = 22,
}
enums.RigScale = {
	Default = 0,
	Rthro = 1,
	RthroNarrow = 2,
}
enums.RigType = {
	R15 = 0,
	CustomHumanoid = 1,
	Custom = 2,
	None = 3,
}
enums.RollOffMode = {
	Inverse = 0,
	Linear = 1,
	LinearSquare = 2,
	InverseTapered = 3,
}
enums.RolloutState = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.RotationOrder = {
	XYZ = 0,
	XZY = 1,
	YZX = 2,
	YXZ = 3,
	ZXY = 4,
	ZYX = 5,
}
enums.RotationType = {
	MovementRelative = 0,
	CameraRelative = 1,
}
enums.RsvpStatus = {
	None = 0,
	Going = 1,
	NotGoing = 2,
}
enums.RtlTextSupport = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.RunContext = {
	Legacy = 0,
	Server = 1,
	Client = 2,
	Plugin = 3,
}
enums.RunState = {
	Stopped = 0,
	Running = 1,
	Paused = 2,
}
enums.RuntimeUndoBehavior = {
	Aggregate = 0,
	Snapshot = 1,
	Hybrid = 2,
}
enums.SafeAreaCompatibility = {
	None = 0,
	FullscreenExtension = 1,
}
enums.SalesTypeFilter = {
	All = 1,
	Collectibles = 2,
	Premium = 3,
	TimedOptions = 4,
}
enums.SandboxedInstanceMode = {
	Default = 0,
	Experimental = 1,
}
enums.SaveAvatarThumbnailCustomizationFailure = {
	BadThumbnailType = 1,
	BadYRotDeg = 2,
	BadFieldOfViewDeg = 3,
	BadDistanceScale = 4,
	Other = 5,
	Throttled = 6,
}
enums.SaveFilter = {
	SaveWorld = 0,
	SaveGame = 1,
	SaveAll = 2,
}
enums.SavedQualitySetting = {
	Automatic = 0,
	QualityLevel1 = 1,
	QualityLevel2 = 2,
	QualityLevel3 = 3,
	QualityLevel4 = 4,
	QualityLevel5 = 5,
	QualityLevel6 = 6,
	QualityLevel7 = 7,
	QualityLevel8 = 8,
	QualityLevel9 = 9,
	QualityLevel10 = 10,
}
enums.ScaleType = {
	Stretch = 0,
	Slice = 1,
	Tile = 2,
	Fit = 3,
	Crop = 4,
}
enums.ScopeCheckResult = {
	ConsentAccepted = 0,
	InvalidScopes = 1,
	Timeout = 2,
	NoUserInput = 3,
	BackendError = 4,
	UnexpectedError = 5,
	InvalidArgument = 6,
	ConsentDenied = 7,
}
enums.ScreenInsets = {
	None = 0,
	DeviceSafeInsets = 1,
	CoreUISafeInsets = 2,
	TopbarSafeInsets = 3,
}
enums.ScreenOrientation = {
	LandscapeLeft = 0,
	LandscapeRight = 1,
	LandscapeSensor = 2,
	Portrait = 3,
	Sensor = 4,
}
enums.ScrollBarInset = {
	None = 0,
	ScrollBar = 1,
	Always = 2,
}
enums.ScrollingDirection = {
	X = 1,
	Y = 2,
	XY = 4,
}
enums.SecurityCapability = {
	RunClientScript = 0,
	RunServerScript = 1,
	AccessOutsideWrite = 2,
	AssetRequire = 3,
	LoadString = 4,
	ScriptGlobals = 5,
	CreateInstances = 6,
	Basic = 7,
	Audio = 8,
	DataStore = 9,
	Network = 10,
	Physics = 11,
	UI = 12,
	CSG = 13,
	Chat = 14,
	Animation = 15,
	Avatar = 16,
	Input = 17,
	Environment = 18,
	RemoteEvent = 19,
	LegacySound = 20,
	Players = 21,
	CapabilityControl = 22,
	Plugin = 23,
	LocalUser = 24,
	WritePlayer = 25,
	Unassigned = 28,
	InternalTest = 29,
	PluginOrOpenCloud = 30,
	Assistant = 31,
	RemoteCommand = 32,
}
enums.SelectionBehavior = {
	Escape = 0,
	Stop = 1,
}
enums.SelectionRenderMode = {
	Outlines = 0,
	BoundingBoxes = 1,
	Both = 2,
}
enums.SelfViewPosition = {
	LastPosition = 0,
	TopLeft = 1,
	TopRight = 2,
	BottomLeft = 3,
	BottomRight = 4,
}
enums.SensorMode = {
	Floor = 0,
	Ladder = 1,
}
enums.SensorUpdateType = {
	OnRead = 0,
	Manual = 1,
}
enums.ServerLiveEditingMode = {
	Uninitialized = 0,
	Enabled = 1,
	Disabled = 2,
}
enums.ServiceVisibility = {
	Always = 0,
	Off = 1,
	WithChildren = 2,
}
enums.Severity = {
	Error = 1,
	Warning = 2,
	Information = 3,
	Hint = 4,
}
enums.ShowAdResult = {
	ShowCompleted = 1,
	AdNotReady = 2,
	AdAlreadyShowing = 3,
	InternalError = 4,
	ShowInterrupted = 5,
	InsufficientMemory = 6,
}
enums.SignalBehavior = {
	Default = 0,
	Immediate = 1,
	Deferred = 2,
	AncestryDeferred = 3,
}
enums.SizeConstraint = {
	RelativeXY = 0,
	RelativeXX = 1,
	RelativeYY = 2,
}
enums.SolverConvergenceMetricType = {
	IterationBased = 0,
	AlgorithmAgnostic = 1,
}
enums.SolverConvergenceVisualizationMode = {
	Disabled = 0,
	PerIsland = 1,
	PerEdge = 2,
}
enums.SortDirection = {
	Ascending = 0,
	Descending = 1,
}
enums.SortOrder = {
	Name = 0,
	Custom = 1,
	LayoutOrder = 2,
}
enums.SpecialKey = {
	Insert = 0,
	Home = 1,
	End = 2,
	PageUp = 3,
	PageDown = 4,
	ChatHotkey = 5,
}
enums.StartCorner = {
	TopLeft = 0,
	TopRight = 1,
	BottomLeft = 2,
	BottomRight = 3,
}
enums.StateObjectFieldType = {
	Boolean = 0,
	CFrame = 1,
	Color3 = 2,
	Float = 3,
	Instance = 4,
	Random = 5,
	Vector2 = 6,
	Vector3 = 7,
	INVALID = 8,
}
enums.Status = {
	Poison = 0,
	Confusion = 1,
}
enums.StepFrequency = {
	Hz60 = 0,
	Hz30 = 1,
	Hz15 = 2,
	Hz10 = 3,
	Hz5 = 4,
	Hz1 = 5,
}
enums.StreamOutBehavior = {
	Default = 0,
	LowMemory = 1,
	Opportunistic = 2,
}
enums.StreamingIntegrityMode = {
	Default = 0,
	Disabled = 1,
	MinimumRadiusPause = 2,
	PauseOutsideLoadedArea = 3,
}
enums.StreamingPauseMode = {
	Default = 0,
	Disabled = 1,
	ClientPhysicsPause = 2,
}
enums.StrokeSizingMode = {
	FixedSize = 0,
	ScaledSize = 1,
}
enums.StudioCloseMode = {
	None = 0,
	CloseStudio = 1,
	CloseDoc = 2,
	LogOut = 3,
}
enums.StudioDataModelType = {
	Edit = 0,
	PlayClient = 1,
	PlayServer = 2,
	Standalone = 3,
	None = 4,
}
enums.StudioPlaceUpdateFailureReason = {
	Other = 0,
	TeamCreateConflict = 1,
}
enums.StudioScriptEditorColorCategories = {
	Default = 0,
	Operator = 1,
	Number = 2,
	String = 3,
	Comment = 4,
	Keyword = 5,
	Builtin = 6,
	Method = 7,
	Property = 8,
	Nil = 9,
	Bool = 10,
	Function = 11,
	Local = 12,
	Self = 13,
	LuauKeyword = 14,
	FunctionName = 15,
	TODO = 16,
	Background = 17,
	SelectionText = 18,
	SelectionBackground = 19,
	FindSelectionBackground = 20,
	MatchingWordBackground = 21,
	Warning = 22,
	Error = 23,
	Info = 24,
	Hint = 25,
	Whitespace = 26,
	ActiveLine = 27,
	DebuggerCurrentLine = 28,
	DebuggerErrorLine = 29,
	Ruler = 30,
	Bracket = 31,
	Type = 32,
	MenuPrimaryText = 33,
	MenuSecondaryText = 34,
	MenuSelectedText = 35,
	MenuBackground = 36,
	MenuSelectedBackground = 37,
	MenuScrollbarBackground = 38,
	MenuScrollbarHandle = 39,
	MenuBorder = 40,
	DocViewCodeBackground = 41,
	AICOOverlayText = 42,
	AICOOverlayButtonBackground = 43,
	AICOOverlayButtonBackgroundHover = 44,
	AICOOverlayButtonBackgroundPressed = 45,
	IndentationRuler = 46,
}
enums.StudioScriptEditorColorPresets = {
	Extra1 = 1,
	Extra2 = 2,
	Custom = 3,
}
enums.StudioStyleGuideColor = {
	MainBackground = 0,
	Titlebar = 1,
	Dropdown = 2,
	Tooltip = 3,
	Notification = 4,
	ScrollBar = 5,
	ScrollBarBackground = 6,
	TabBar = 7,
	Tab = 8,
	FilterButtonDefault = 9,
	FilterButtonHover = 10,
	FilterButtonChecked = 11,
	FilterButtonAccent = 12,
	FilterButtonBorder = 13,
	FilterButtonBorderAlt = 14,
	RibbonTab = 15,
	RibbonTabTopBar = 16,
	Button = 17,
	MainButton = 18,
	RibbonButton = 19,
	ViewPortBackground = 20,
	InputFieldBackground = 21,
	Item = 22,
	TableItem = 23,
	CategoryItem = 24,
	GameSettingsTableItem = 25,
	GameSettingsTooltip = 26,
	EmulatorBar = 27,
	EmulatorDropDown = 28,
	ColorPickerFrame = 29,
	CurrentMarker = 30,
	Border = 31,
	DropShadow = 32,
	Shadow = 33,
	Light = 34,
	Dark = 35,
	Mid = 36,
	MainText = 37,
	SubText = 38,
	TitlebarText = 39,
	BrightText = 40,
	DimmedText = 41,
	LinkText = 42,
	WarningText = 43,
	ErrorText = 44,
	InfoText = 45,
	SensitiveText = 46,
	ScriptSideWidget = 47,
	ScriptBackground = 48,
	ScriptText = 49,
	ScriptSelectionText = 50,
	ScriptSelectionBackground = 51,
	ScriptFindSelectionBackground = 52,
	ScriptMatchingWordSelectionBackground = 53,
	ScriptOperator = 54,
	ScriptNumber = 55,
	ScriptString = 56,
	ScriptComment = 57,
	ScriptKeyword = 58,
	ScriptBuiltInFunction = 59,
	ScriptWarning = 60,
	ScriptError = 61,
	ScriptInformation = 62,
	ScriptHint = 63,
	ScriptWhitespace = 64,
	ScriptRuler = 65,
	DocViewCodeBackground = 66,
	DebuggerCurrentLine = 67,
	DebuggerErrorLine = 68,
	DiffFilePathText = 69,
	DiffTextHunkInfo = 70,
	DiffTextNoChange = 71,
	DiffTextAddition = 72,
	DiffTextDeletion = 73,
	DiffTextSeparatorBackground = 74,
	DiffTextNoChangeBackground = 75,
	DiffTextAdditionBackground = 76,
	DiffTextDeletionBackground = 77,
	DiffLineNum = 78,
	DiffLineNumSeparatorBackground = 79,
	DiffLineNumNoChangeBackground = 80,
	DiffLineNumAdditionBackground = 81,
	DiffLineNumDeletionBackground = 82,
	DiffFilePathBackground = 83,
	DiffFilePathBorder = 84,
	ChatIncomingBgColor = 85,
	ChatIncomingTextColor = 86,
	ChatOutgoingBgColor = 87,
	ChatOutgoingTextColor = 88,
	ChatModeratedMessageColor = 89,
	Separator = 90,
	ButtonBorder = 91,
	ButtonText = 92,
	InputFieldBorder = 93,
	CheckedFieldBackground = 94,
	CheckedFieldBorder = 95,
	CheckedFieldIndicator = 96,
	HeaderSection = 97,
	Midlight = 98,
	StatusBar = 99,
	DialogButton = 100,
	DialogButtonText = 101,
	DialogButtonBorder = 102,
	DialogMainButton = 103,
	DialogMainButtonText = 104,
	InfoBarWarningBackground = 105,
	InfoBarWarningText = 106,
	ScriptEditorCurrentLine = 107,
	ScriptMethod = 108,
	ScriptProperty = 109,
	ScriptNil = 110,
	ScriptBool = 111,
	ScriptFunction = 112,
	ScriptLocal = 113,
	ScriptSelf = 114,
	ScriptLuauKeyword = 115,
	ScriptFunctionName = 116,
	ScriptTodo = 117,
	ScriptBracket = 118,
	AttributeCog = 119,
	AICOOverlayText = 128,
	AICOOverlayButtonBackground = 129,
	AICOOverlayButtonBackgroundHover = 130,
	AICOOverlayButtonBackgroundPressed = 131,
	OnboardingCover = 132,
	OnboardingHighlight = 133,
	OnboardingShadow = 134,
	BreakpointMarker = 136,
	DiffLineNumHover = 137,
	DiffLineNumSeparatorBackgroundHover = 138,
}
enums.StudioStyleGuideModifier = {
	Default = 0,
	Selected = 1,
	Pressed = 2,
	Disabled = 3,
	Hover = 4,
}
enums.Style = {
	AlternatingSupports = 0,
	BridgeStyleSupports = 1,
	NoSupports = 2,
}
enums.SubscriptionExpirationReason = {
	ProductInactive = 0,
	ProductDeleted = 1,
	SubscriberCancelled = 2,
	SubscriberRefunded = 3,
	Lapsed = 4,
}
enums.SubscriptionPaymentStatus = {
	Paid = 0,
	Refunded = 1,
}
enums.SubscriptionPeriod = {
	Month = 0,
}
enums.SubscriptionState = {
	NeverSubscribed = 0,
	SubscribedWillRenew = 1,
	SubscribedWillNotRenew = 2,
	SubscribedRenewalPaymentPending = 3,
	Expired = 4,
}
enums.SurfaceConstraint = {
	None = 0,
	Hinge = 1,
	SteppingMotor = 2,
	Motor = 3,
}
enums.SurfaceGuiShape = {
	Flat = 0,
	CurvedHorizontally = 1,
}
enums.SurfaceGuiSizingMode = {
	FixedSize = 0,
	PixelsPerStud = 1,
}
enums.SurfaceType = {
	Smooth = 0,
	Glue = 1,
	Weld = 2,
	Studs = 3,
	Inlet = 4,
	Universal = 5,
	Hinge = 6,
	Motor = 7,
	SteppingMotor = 8,
	SmoothNoOutlines = 10,
}
enums.SwipeDirection = {
	Right = 0,
	Left = 1,
	Up = 2,
	Down = 3,
	None = 4,
}
enums.SystemThemeValue = {
	error = 0,
	light = 1,
	dark = 2,
	systemLight = 3,
	systemDark = 4,
}
enums.TableMajorAxis = {
	RowMajor = 0,
	ColumnMajor = 1,
}
enums.TeamCreateErrorState = {
	PlaceSizeTooLarge = 0,
	PlaceSizeApproachingLimit = 1,
	PlaceUploadFailing = 2,
	NoError = 3,
}
enums.Technology = {
	Voxel = 1,
	Compatibility = 2,
	ShadowMap = 3,
	Future = 4,
	Legacy = 0,
	Unified = 5,
}
enums.TelemetryBackend = {
	UNSPECIFIED = 0,
	EventIngest = 1,
	Points = 2,
	Teletune = 3,
	EphemeralCounter = 4,
	EphemeralStat = 5,
	Counter = 6,
	Stat = 7,
}
enums.TelemetryStandardizedField = {
	AddDatacenterId = 0,
	AddPlaceId = 1,
	AddUniverseId = 2,
	AddPlaceInstanceId = 3,
	AddPlaySessionId = 4,
	AddCurrentContextName = 5,
	AddOsInfo = 6,
	AddArchitectureInfo = 7,
	AddCpuInfo = 8,
	AddMemoryInfo = 9,
	AddSessionInfo = 10,
}
enums.TeleportMethod = {
	TeleportToSpawnByName = 0,
	TeleportToPlaceInstance = 1,
	TeleportToPrivateServer = 2,
	TeleportPartyAsync = 3,
	TeleportToVIPServer = 4,
	TeleportToInstanceBack = 5,
	TeleportUnknown = 6,
}
enums.TeleportResult = {
	Success = 0,
	Failure = 1,
	GameNotFound = 2,
	GameEnded = 3,
	GameFull = 4,
	Unauthorized = 5,
	Flooded = 6,
	IsTeleporting = 7,
}
enums.TeleportState = {
	RequestedFromServer = 0,
	Started = 1,
	WaitingForServer = 2,
	Failed = 3,
	InProgress = 4,
}
enums.TeleportType = {
	ToPlace = 0,
	ToInstance = 1,
	ToReservedServer = 2,
	ToVIPServer = 3,
	ToInstanceBack = 4,
}
enums.TerrainAcquisitionMethod = {
	None = 0,
	Legacy = 1,
	Template = 2,
	Generate = 3,
	Import = 4,
	Convert = 5,
	EditAddTool = 6,
	EditSeaLevelTool = 7,
	EditReplaceTool = 8,
	RegionFillTool = 9,
	RegionPasteTool = 10,
	Other = 11,
}
enums.TerrainFace = {
	Top = 0,
	Side = 1,
	Bottom = 2,
}
enums.TextChatMessageStatus = {
	Unknown = 1,
	Success = 2,
	Sending = 3,
	TextFilterFailed = 4,
	Floodchecked = 5,
	InvalidPrivacySettings = 6,
	InvalidTextChannelPermissions = 7,
	MessageTooLong = 8,
	ModerationTimeout = 9,
}
enums.TextDirection = {
	Auto = 0,
	LeftToRight = 1,
	RightToLeft = 2,
}
enums.TextFilterContext = {
	PublicChat = 1,
	PrivateChat = 2,
}
enums.TextInputType = {
	Default = 0,
	NoSuggestions = 1,
	Number = 2,
	Email = 3,
	Phone = 4,
	Password = 5,
	PasswordShown = 6,
	Username = 7,
	OneTimePassword = 8,
}
enums.TextTruncate = {
	None = 0,
	AtEnd = 1,
	SplitWord = 2,
}
enums.TextXAlignment = {
	Left = 0,
	Right = 1,
	Center = 2,
}
enums.TextYAlignment = {
	Top = 0,
	Center = 1,
	Bottom = 2,
}
enums.TextureMode = {
	Stretch = 0,
	Wrap = 1,
	Static = 2,
}
enums.TextureQueryType = {
	NonHumanoid = 0,
	NonHumanoidOrphaned = 1,
	Humanoid = 2,
	HumanoidOrphaned = 3,
}
enums.ThreadPoolConfig = {
	PerCore4 = 104,
	PerCore3 = 103,
	PerCore2 = 102,
	PerCore1 = 101,
	Auto = 0,
	Threads1 = 1,
	Threads2 = 2,
	Threads3 = 3,
	Threads4 = 4,
	Threads8 = 8,
	Threads16 = 16,
}
enums.ThrottlingPriority = {
	Extreme = 2,
	ElevatedOnServer = 1,
	Default = 0,
}
enums.ThumbnailSize = {
	Size48x48 = 0,
	Size180x180 = 1,
	Size420x420 = 2,
	Size60x60 = 3,
	Size100x100 = 4,
	Size150x150 = 5,
	Size352x352 = 6,
}
enums.ThumbnailType = {
	HeadShot = 0,
	AvatarBust = 1,
	AvatarThumbnail = 2,
}
enums.TickCountSampleMethod = {
	Fast = 0,
	Benchmark = 1,
	Precise = 2,
}
enums.TonemapperPreset = {
	Default = 0,
	Retro = 1,
}
enums.TopBottom = {
	Top = 0,
	Center = 1,
	Bottom = 2,
}
enums.TouchCameraMovementMode = {
	Default = 0,
	Classic = 1,
	Follow = 2,
	Orbital = 3,
}
enums.TouchMovementMode = {
	Default = 0,
	Thumbstick = 1,
	DPad = 2,
	Thumbpad = 3,
	ClickToMove = 4,
	DynamicThumbstick = 5,
}
enums.TrackerError = {
	Ok = 0,
	NoService = 1,
	InitFailed = 2,
	NoVideo = 3,
	VideoError = 4,
	VideoNoPermission = 5,
	VideoUnsupported = 6,
	NoAudio = 7,
	AudioError = 8,
	AudioNoPermission = 9,
	UnsupportedDevice = 10,
}
enums.TrackerExtrapolationFlagMode = {
	Auto = 3,
	ForceDisabled = 0,
	ExtrapolateFacsAndPose = 1,
	ExtrapolateFacsOnly = 2,
}
enums.TrackerFaceTrackingStatus = {
	FaceTrackingSuccess = 0,
	FaceTrackingNoFaceFound = 1,
	FaceTrackingUnknown = 2,
	FaceTrackingLost = 3,
	FaceTrackingHasTrackingError = 4,
	FaceTrackingIsOccluded = 5,
	FaceTrackingUninitialized = 6,
}
enums.TrackerLodFlagMode = {
	Auto = 2,
	ForceFalse = 0,
	ForceTrue = 1,
}
enums.TrackerLodValueMode = {
	Auto = 2,
	Force0 = 0,
	Force1 = 1,
}
enums.TrackerMode = {
	None = 0,
	Audio = 1,
	Video = 2,
	AudioVideo = 3,
}
enums.TrackerPromptEvent = {
	LODCameraRecommendDisable = 0,
}
enums.TrackerType = {
	None = 0,
	Face = 1,
	UpperBody = 2,
}
enums.TriStateBoolean = {
	False = 2,
	True = 1,
	Unknown = 0,
}
enums.TweenStatus = {
	Canceled = 0,
	Completed = 1,
}
enums.UICaptureMode = {
	All = 0,
	None = 1,
}
enums.UIDragDetectorBoundingBehavior = {
	Automatic = 0,
	EntireObject = 1,
	HitPoint = 2,
}
enums.UIDragDetectorDragRelativity = {
	Absolute = 0,
	Relative = 1,
}
enums.UIDragDetectorDragSpace = {
	Parent = 0,
	LayerCollector = 1,
	Reference = 2,
}
enums.UIDragDetectorDragStyle = {
	TranslatePlane = 0,
	TranslateLine = 1,
	Rotate = 2,
	Scriptable = 3,
}
enums.UIDragDetectorResponseStyle = {
	Offset = 0,
	Scale = 1,
	CustomOffset = 2,
	CustomScale = 3,
}
enums.UIDragSpeedAxisMapping = {
	XY = 0,
	XX = 1,
	YY = 2,
}
enums.UIFlexAlignment = {
	None = 0,
	Fill = 1,
	SpaceAround = 2,
	SpaceBetween = 3,
	SpaceEvenly = 4,
}
enums.UIFlexMode = {
	None = 0,
	Grow = 1,
	Shrink = 2,
	Fill = 3,
	Custom = 4,
}
enums.UITheme = {
	Light = 0,
	Dark = 1,
}
enums.UiMessageType = {
	UiMessageError = 0,
	UiMessageInfo = 1,
}
enums.UpdateState = {
	UpdateNotAvailable = 0,
	UpdateAvailable = 1,
	UpdateInProgress = 2,
	UpdateReady = 3,
	UpdateFailed = 4,
}
enums.UploadCaptureResult = {
	Success = 0,
	NeedPermission = 1,
	CaptureModerated = 2,
	CaptureNotInGallery = 3,
	IneligibleCapture = 4,
	UploadQuotaReached = 5,
}
enums.UsageContext = {
	Default = 0,
	Preview = 1,
}
enums.UserCFrame = {
	Head = 0,
	LeftHand = 1,
	RightHand = 2,
	Floor = 3,
}
enums.UserInputState = {
	Begin = 0,
	Change = 1,
	End = 2,
	Cancel = 3,
	None = 4,
}
enums.UserInputType = {
	MouseButton1 = 0,
	MouseButton2 = 1,
	MouseButton3 = 2,
	MouseWheel = 3,
	MouseMovement = 4,
	Touch = 7,
	Keyboard = 8,
	Focus = 9,
	Accelerometer = 10,
	Gyro = 11,
	Gamepad1 = 12,
	Gamepad2 = 13,
	Gamepad3 = 14,
	Gamepad4 = 15,
	Gamepad5 = 16,
	Gamepad6 = 17,
	Gamepad7 = 18,
	Gamepad8 = 19,
	TextInput = 20,
	InputMethod = 21,
	None = 22,
}
enums.VRComfortSetting = {
	Comfort = 0,
	Normal = 1,
	Expert = 2,
	Custom = 3,
}
enums.VRControllerModelMode = {
	Disabled = 0,
	Transparent = 1,
}
enums.VRDeviceType = {
	Unknown = 0,
	OculusRift = 1,
	HTCVive = 2,
	ValveIndex = 3,
	OculusQuest = 4,
}
enums.VRLaserPointerMode = {
	Disabled = 0,
	Pointer = 1,
	DualPointer = 2,
}
enums.VRSafetyBubbleMode = {
	NoOne = 0,
	OnlyFriends = 1,
	Anyone = 2,
}
enums.VRScaling = {
	World = 0,
	Off = 1,
}
enums.VRSessionState = {
	Undefined = 0,
	Idle = 1,
	Visible = 2,
	Focused = 3,
	Stopping = 4,
}
enums.VRTouchpad = {
	Left = 0,
	Right = 1,
}
enums.VRTouchpadMode = {
	Touch = 0,
	VirtualThumbstick = 1,
	ABXY = 2,
}
enums.VelocityConstraintMode = {
	Line = 0,
	Plane = 1,
	Vector = 2,
}
enums.VerticalAlignment = {
	Center = 0,
	Top = 1,
	Bottom = 2,
}
enums.VerticalScrollBarPosition = {
	Right = 0,
	Left = 1,
}
enums.VibrationMotor = {
	Large = 0,
	Small = 1,
	LeftTrigger = 2,
	RightTrigger = 3,
	LeftHand = 4,
	RightHand = 5,
}
enums.VideoCaptureResult = {
	Success = 0,
	OtherError = 1,
	ScreenSizeChanged = 2,
	TimeLimitReached = 3,
}
enums.VideoCaptureStartedResult = {
	Success = 0,
	OtherError = 1,
	CapturingAlready = 2,
	NoDeviceSupport = 3,
	NoSpaceOnDevice = 4,
}
enums.VideoDeviceCaptureQuality = {
	Default = 0,
	Low = 1,
	Medium = 2,
	High = 3,
}
enums.VideoError = {
	Ok = 0,
	Eof = 1,
	EAgain = 2,
	BadParameter = 3,
	AllocFailed = 4,
	CodecInitFailed = 5,
	CodecCloseFailed = 6,
	DecodeFailed = 7,
	ParsingFailed = 8,
	Unsupported = 9,
	Generic = 10,
	DownloadFailed = 11,
	StreamNotFound = 12,
	EncodeFailed = 13,
	CreateFailed = 14,
	NoPermission = 15,
	NoService = 16,
	ReleaseFailed = 17,
	Unknown = 18,
}
enums.VideoSampleSize = {
	Small = 0,
	Medium = 1,
	Large = 2,
	Full = 3,
}
enums.ViewMode = {
	None = 0,
	GeometryComplexity = 1,
	Transparent = 2,
	Decal = 3,
}
enums.VirtualCursorMode = {
	Default = 0,
	Disabled = 1,
	Enabled = 2,
}
enums.VirtualInputMode = {
	None = 0,
	Recording = 1,
	Playing = 2,
}
enums.VoiceChatDistanceAttenuationType = {
	Inverse = 0,
	Legacy = 1,
}
enums.VoiceChatState = {
	Idle = 0,
	Joining = 1,
	JoiningRetry = 2,
	Joined = 3,
	Leaving = 4,
	Ended = 5,
	Failed = 6,
}
enums.VoiceClientLeaveReasons = {
	Unknown = 0,
	ClientNetworkDisconnected = 1,
	PlayerLeft = 2,
	ClientShutdown = 3,
	PublishFailed = 4,
	RejoinReceived = 5,
	VoiceReboot = 6,
	ImguiDebugLeave = 7,
	LuaInitiated = 8,
}
enums.VoiceControlPath = {
	Publish = 0,
	Subscribe = 1,
	Join = 2,
}
enums.VolumetricAudio = {
	Disabled = 0,
	Automatic = 1,
	Enabled = 2,
}
enums.WaterDirection = {
	NegX = 0,
	X = 1,
	NegY = 2,
	Y = 3,
	NegZ = 4,
	Z = 5,
}
enums.WaterForce = {
	None = 0,
	Small = 1,
	Medium = 2,
	Strong = 3,
	Max = 4,
}
enums.WebSocketState = {
	Connecting = 0,
	Open = 1,
	Closing = 2,
	Closed = 3,
}
enums.WebStreamClientState = {
	Connecting = 0,
	Open = 1,
	Error = 2,
	Closed = 3,
}
enums.WebStreamClientType = {
	SSE = 0,
	RawStream = 1,
	WebSocket = 2,
}
enums.WeldConstraintPreserve = {
	All = 0,
	None = 1,
	Touching = 2,
}
enums.WhisperChatPrivacyMode = {
	AllUsers = 0,
	NoOne = 1,
}
enums.WrapLayerAutoSkin = {
	Disabled = 0,
	EnabledPreserve = 1,
	EnabledOverride = 2,
}
enums.WrapLayerDebugMode = {
	None = 0,
	BoundCage = 1,
	LayerCage = 2,
	BoundCageAndLinks = 3,
	Reference = 4,
	Rbf = 5,
	OuterCage = 6,
	ReferenceMeshAfterMorph = 7,
	HSROuterDetail = 8,
	HSROuter = 9,
	HSRInner = 10,
	HSRInnerReverse = 11,
	LayerCageFittedToBase = 12,
	LayerCageFittedToPrev = 13,
	PreWrapDeformerOuterCage = 14,
}
enums.WrapTargetDebugMode = {
	None = 0,
	TargetCageOriginal = 1,
	TargetCageCompressed = 2,
	TargetCageInterface = 3,
	TargetLayerCageOriginal = 4,
	TargetLayerCageCompressed = 5,
	TargetLayerInterface = 6,
	Rbf = 7,
	OuterCageDetail = 8,
	PreWrapDeformerCage = 9,
}
enums.ZIndexBehavior = {
	Global = 0,
	Sibling = 1,
}
return enums
