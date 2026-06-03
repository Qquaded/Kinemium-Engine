export type EnumItem = {
    Name: string,
    Value: number,
    EnumType: Enum,
    IsA: (self: EnumItem, enumName: string) -> boolean,
}
export type Enum = {
    GetEnumItems: (self: Enum) -> { EnumItem }
}
export type Enum_AccessModifierType = Enum & {
    Allow: EnumItem,
    Deny: EnumItem,
}
export type Enum_AccessoryType = Enum & {
    Unknown: EnumItem,
    Hat: EnumItem,
    Hair: EnumItem,
    Face: EnumItem,
    Neck: EnumItem,
    Shoulder: EnumItem,
    Front: EnumItem,
    Back: EnumItem,
    Waist: EnumItem,
    TShirt: EnumItem,
    Shirt: EnumItem,
    Pants: EnumItem,
    Jacket: EnumItem,
    Sweater: EnumItem,
    Shorts: EnumItem,
    LeftShoe: EnumItem,
    RightShoe: EnumItem,
    DressSkirt: EnumItem,
    Eyebrow: EnumItem,
    Eyelash: EnumItem,
}
export type Enum_ActionOnAutoResumeSync = Enum & {
    DontResume: EnumItem,
    KeepStudio: EnumItem,
    KeepLocal: EnumItem,
}
export type Enum_ActionOnStopSync = Enum & {
    AlwaysAsk: EnumItem,
    KeepLocalFiles: EnumItem,
    DeleteLocalFiles: EnumItem,
}
export type Enum_ActionType = Enum & {
    Nothing: EnumItem,
    Pause: EnumItem,
    Lose: EnumItem,
    Draw: EnumItem,
    Win: EnumItem,
}
export type Enum_ActuatorRelativeTo = Enum & {
    Attachment0: EnumItem,
    Attachment1: EnumItem,
    World: EnumItem,
}
export type Enum_ActuatorType = Enum & {
    None: EnumItem,
    Motor: EnumItem,
    Servo: EnumItem,
}
export type Enum_AdAvailabilityResult = Enum & {
    IsAvailable: EnumItem,
    DeviceIneligible: EnumItem,
    ExperienceIneligible: EnumItem,
    InternalError: EnumItem,
    NoFill: EnumItem,
    PlayerIneligible: EnumItem,
    PublisherIneligible: EnumItem,
}
export type Enum_AdEventType = Enum & {
    RewardedAdLoaded: EnumItem,
    RewardedAdGrant: EnumItem,
    RewardedAdUnloaded: EnumItem,
    VideoLoaded: EnumItem,
    VideoRemoved: EnumItem,
    UserCompletedVideo: EnumItem,
}
export type Enum_AdFormat = Enum & {
    RewardedVideo: EnumItem,
}
export type Enum_AdShape = Enum & {
    HorizontalRectangle: EnumItem,
}
export type Enum_AdTeleportMethod = Enum & {
    Undefined: EnumItem,
    PortalForward: EnumItem,
    InGameMenuBackButton: EnumItem,
    UIBackButton: EnumItem,
}
export type Enum_AdUIEventType = Enum & {
    AdLabelClicked: EnumItem,
    VolumeButtonClicked: EnumItem,
    FullscreenButtonClicked: EnumItem,
    PlayButtonClicked: EnumItem,
    PauseButtonClicked: EnumItem,
    CloseButtonClicked: EnumItem,
    WhyThisAdClicked: EnumItem,
    PlayEventTriggered: EnumItem,
    PauseEventTriggered: EnumItem,
}
export type Enum_AdUIType = Enum & {
    None: EnumItem,
    Image: EnumItem,
    Video: EnumItem,
}
export type Enum_AdUnitStatus = Enum & {
    Inactive: EnumItem,
    Active: EnumItem,
}
export type Enum_AdornCullingMode = Enum & {
    Automatic: EnumItem,
    Never: EnumItem,
}
export type Enum_AdornShading = Enum & {
    Default: EnumItem,
    Shaded: EnumItem,
    XRay: EnumItem,
    XRayShaded: EnumItem,
    AlwaysOnTop: EnumItem,
}
export type Enum_AlignType = Enum & {
    PrimaryAxisParallel: EnumItem,
    PrimaryAxisPerpendicular: EnumItem,
    PrimaryAxisLookAt: EnumItem,
    AllAxes: EnumItem,
    Parallel: EnumItem,
    Perpendicular: EnumItem,
}
export type Enum_AlphaMode = Enum & {
    Overlay: EnumItem,
    Transparency: EnumItem,
    TintMask: EnumItem,
    Opaque: EnumItem,
}
export type Enum_AnalyticsCustomFieldKeys = Enum & {
    CustomField01: EnumItem,
    CustomField02: EnumItem,
    CustomField03: EnumItem,
}
export type Enum_AnalyticsEconomyAction = Enum & {
    Default: EnumItem,
    Acquire: EnumItem,
    Spend: EnumItem,
}
export type Enum_AnalyticsEconomyFlowType = Enum & {
    Sink: EnumItem,
    Source: EnumItem,
}
export type Enum_AnalyticsEconomyTransactionType = Enum & {
    IAP: EnumItem,
    Shop: EnumItem,
    Gameplay: EnumItem,
    ContextualPurchase: EnumItem,
    TimedReward: EnumItem,
    Onboarding: EnumItem,
}
export type Enum_AnalyticsLogLevel = Enum & {
    Trace: EnumItem,
    Debug: EnumItem,
    Information: EnumItem,
    Warning: EnumItem,
    Error: EnumItem,
    Fatal: EnumItem,
}
export type Enum_AnalyticsProgressionStatus = Enum & {
    Default: EnumItem,
    Begin: EnumItem,
    Complete: EnumItem,
    Abandon: EnumItem,
    Fail: EnumItem,
}
export type Enum_AnalyticsProgressionType = Enum & {
    Custom: EnumItem,
    Start: EnumItem,
    Fail: EnumItem,
    Complete: EnumItem,
}
export type Enum_AnimationClipFromVideoStatus = Enum & {
    Initializing: EnumItem,
    Pending: EnumItem,
    Processing: EnumItem,
    ErrorGeneric: EnumItem,
    Success: EnumItem,
    ErrorVideoTooLong: EnumItem,
    ErrorNoPersonDetected: EnumItem,
    ErrorVideoUnstable: EnumItem,
    Timeout: EnumItem,
    Cancelled: EnumItem,
    ErrorMultiplePeople: EnumItem,
    ErrorUploadingVideo: EnumItem,
}
export type Enum_AnimationNodeBlend2DInputMode = Enum & {
    Cartesian: EnumItem,
    Polar: EnumItem,
}
export type Enum_AnimationNodeInterruptible = Enum & {
    Always: EnumItem,
    ClipFinished: EnumItem,
    Expression: EnumItem,
}
export type Enum_AnimationNodePlayMode = Enum & {
    Loop: EnumItem,
    PingPong: EnumItem,
    OnceAndHold: EnumItem,
    OnceAndReset: EnumItem,
}
export type Enum_AnimationNodeTransitionType = Enum & {
    CrossFade: EnumItem,
    InertialBlend: EnumItem,
    DeadBlend: EnumItem,
}
export type Enum_AnimationNodeType = Enum & {
    InvalidNode: EnumItem,
    AddNode: EnumItem,
    BlendNode: EnumItem,
    Blend1DNode: EnumItem,
    Blend2DNode: EnumItem,
    ClipNode: EnumItem,
    GraphOutput: EnumItem,
    MaskNode: EnumItem,
    PrioritySelectNode: EnumItem,
    RandomSequenceNode: EnumItem,
    SelectNode: EnumItem,
    SequenceNode: EnumItem,
    SpeedNode: EnumItem,
    SubtractNode: EnumItem,
}
export type Enum_AnimationNodeWaitFor = Enum & {
    ClipFinished: EnumItem,
    Expression: EnumItem,
}
export type Enum_AnimationPriority = Enum & {
    Core: EnumItem,
    Idle: EnumItem,
    Movement: EnumItem,
    Action: EnumItem,
    Action2: EnumItem,
    Action3: EnumItem,
    Action4: EnumItem,
}
export type Enum_AnimatorRetargetingMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_AnnotationChannelContentPreference = Enum & {
    None: EnumItem,
    All: EnumItem,
    Unknown: EnumItem,
}
export type Enum_AnnotationEditingMode = Enum & {
    None: EnumItem,
    PlacingNew: EnumItem,
    WritingNew: EnumItem,
}
export type Enum_AnnotationPlaceContentPreference = Enum & {
    None: EnumItem,
    All: EnumItem,
    MentionsAndReplies: EnumItem,
    Unknown: EnumItem,
}
export type Enum_AnnotationRequestStatus = Enum & {
    Success: EnumItem,
    Loading: EnumItem,
    ErrorInternalFailure: EnumItem,
    ErrorNotFound: EnumItem,
    ErrorModerated: EnumItem,
}
export type Enum_AnnotationRequestType = Enum & {
    Unknown: EnumItem,
    Create: EnumItem,
    Resolve: EnumItem,
    Delete: EnumItem,
    Edit: EnumItem,
}
export type Enum_AppLifecycleManagerState = Enum & {
    Detached: EnumItem,
    Active: EnumItem,
    Inactive: EnumItem,
    Hidden: EnumItem,
}
export type Enum_AppShellActionType = Enum & {
    None: EnumItem,
    OpenApp: EnumItem,
    TapChatTab: EnumItem,
    TapConversationEntry: EnumItem,
    TapAvatarTab: EnumItem,
    ReadConversation: EnumItem,
    TapGamePageTab: EnumItem,
    TapHomePageTab: EnumItem,
    GamePageLoaded: EnumItem,
    HomePageLoaded: EnumItem,
    AvatarEditorPageLoaded: EnumItem,
}
export type Enum_AppShellFeature = Enum & {
    None: EnumItem,
    Chat: EnumItem,
    AvatarEditor: EnumItem,
    GamePage: EnumItem,
    HomePage: EnumItem,
    More: EnumItem,
    Landing: EnumItem,
}
export type Enum_AppUpdateStatus = Enum & {
    Unknown: EnumItem,
    NotSupported: EnumItem,
    Failed: EnumItem,
    NotAvailable: EnumItem,
    Available: EnumItem,
    AvailableBoundChannel: EnumItem,
    AvailableBetaProgram: EnumItem,
}
export type Enum_ApplyStrokeMode = Enum & {
    Contextual: EnumItem,
    Border: EnumItem,
}
export type Enum_AspectType = Enum & {
    FitWithinMaxSize: EnumItem,
    ScaleWithParentSize: EnumItem,
}
export type Enum_AssetCreatorType = Enum & {
    User: EnumItem,
    Group: EnumItem,
}
export type Enum_AssetFetchStatus = Enum & {
    Success: EnumItem,
    Failure: EnumItem,
    None: EnumItem,
    Loading: EnumItem,
    TimedOut: EnumItem,
}
export type Enum_AssetType = Enum & {
    Image: EnumItem,
    TShirt: EnumItem,
    Audio: EnumItem,
    Mesh: EnumItem,
    Lua: EnumItem,
    Hat: EnumItem,
    Place: EnumItem,
    Model: EnumItem,
    Shirt: EnumItem,
    Pants: EnumItem,
    Decal: EnumItem,
    Head: EnumItem,
    Face: EnumItem,
    Gear: EnumItem,
    Badge: EnumItem,
    Animation: EnumItem,
    Torso: EnumItem,
    RightArm: EnumItem,
    LeftArm: EnumItem,
    LeftLeg: EnumItem,
    RightLeg: EnumItem,
    Package: EnumItem,
    GamePass: EnumItem,
    Plugin: EnumItem,
    MeshPart: EnumItem,
    HairAccessory: EnumItem,
    FaceAccessory: EnumItem,
    NeckAccessory: EnumItem,
    ShoulderAccessory: EnumItem,
    FrontAccessory: EnumItem,
    BackAccessory: EnumItem,
    WaistAccessory: EnumItem,
    ClimbAnimation: EnumItem,
    DeathAnimation: EnumItem,
    FallAnimation: EnumItem,
    IdleAnimation: EnumItem,
    JumpAnimation: EnumItem,
    RunAnimation: EnumItem,
    SwimAnimation: EnumItem,
    WalkAnimation: EnumItem,
    PoseAnimation: EnumItem,
    EmoteAnimation: EnumItem,
    Video: EnumItem,
    TShirtAccessory: EnumItem,
    ShirtAccessory: EnumItem,
    PantsAccessory: EnumItem,
    JacketAccessory: EnumItem,
    SweaterAccessory: EnumItem,
    ShortsAccessory: EnumItem,
    LeftShoeAccessory: EnumItem,
    RightShoeAccessory: EnumItem,
    DressSkirtAccessory: EnumItem,
    FontFamily: EnumItem,
    EyebrowAccessory: EnumItem,
    EyelashAccessory: EnumItem,
    MoodAnimation: EnumItem,
    DynamicHead: EnumItem,
    FaceMakeup: EnumItem,
    LipMakeup: EnumItem,
    EyeMakeup: EnumItem,
    EarAccessory: EnumItem,
    EyeAccessory: EnumItem,
}
export type Enum_AssetTypeVerification = Enum & {
    Default: EnumItem,
    ClientOnly: EnumItem,
    Always: EnumItem,
}
export type Enum_AudioApiRollout = Enum & {
    Disabled: EnumItem,
    Automatic: EnumItem,
    Enabled: EnumItem,
}
export type Enum_AudioCaptureMode = Enum & {
}
export type Enum_AudioChannelLayout = Enum & {
    Mono: EnumItem,
    Stereo: EnumItem,
    Quad: EnumItem,
    Surround_5: EnumItem,
    Surround_5_1: EnumItem,
    Surround_7_1: EnumItem,
    Surround_7_1_4: EnumItem,
}
export type Enum_AudioFilterType = Enum & {
    Peak: EnumItem,
    LowShelf: EnumItem,
    HighShelf: EnumItem,
    Lowpass12dB: EnumItem,
    Lowpass24dB: EnumItem,
    Lowpass48dB: EnumItem,
    Highpass12dB: EnumItem,
    Highpass24dB: EnumItem,
    Highpass48dB: EnumItem,
    Bandpass: EnumItem,
    Notch: EnumItem,
    Lowpass6dB: EnumItem,
}
export type Enum_AudioSimulationFidelity = Enum & {
    None: EnumItem,
    Automatic: EnumItem,
}
export type Enum_AudioSubType = Enum & {
    Music: EnumItem,
    SoundEffect: EnumItem,
}
export type Enum_AudioWindowSize = Enum & {
    Small: EnumItem,
    Medium: EnumItem,
    Large: EnumItem,
}
export type Enum_AuthorityMode = Enum & {
    Server: EnumItem,
    Automatic: EnumItem,
}
export type Enum_AutoIndentRule = Enum & {
    Off: EnumItem,
    Absolute: EnumItem,
    Relative: EnumItem,
}
export type Enum_AutomaticSize = Enum & {
    None: EnumItem,
    X: EnumItem,
    Y: EnumItem,
    XY: EnumItem,
}
export type Enum_AvatarAssetType = Enum & {
    TShirt: EnumItem,
    Hat: EnumItem,
    Shirt: EnumItem,
    Pants: EnumItem,
    Head: EnumItem,
    Face: EnumItem,
    Gear: EnumItem,
    Torso: EnumItem,
    RightArm: EnumItem,
    LeftArm: EnumItem,
    LeftLeg: EnumItem,
    RightLeg: EnumItem,
    HairAccessory: EnumItem,
    FaceAccessory: EnumItem,
    NeckAccessory: EnumItem,
    ShoulderAccessory: EnumItem,
    FrontAccessory: EnumItem,
    BackAccessory: EnumItem,
    WaistAccessory: EnumItem,
    ClimbAnimation: EnumItem,
    FallAnimation: EnumItem,
    IdleAnimation: EnumItem,
    JumpAnimation: EnumItem,
    RunAnimation: EnumItem,
    SwimAnimation: EnumItem,
    WalkAnimation: EnumItem,
    MoodAnimation: EnumItem,
    EmoteAnimation: EnumItem,
    TShirtAccessory: EnumItem,
    ShirtAccessory: EnumItem,
    PantsAccessory: EnumItem,
    JacketAccessory: EnumItem,
    SweaterAccessory: EnumItem,
    ShortsAccessory: EnumItem,
    LeftShoeAccessory: EnumItem,
    RightShoeAccessory: EnumItem,
    DressSkirtAccessory: EnumItem,
    EyebrowAccessory: EnumItem,
    EyelashAccessory: EnumItem,
    DynamicHead: EnumItem,
    FaceMakeup: EnumItem,
    LipMakeup: EnumItem,
    EyeMakeup: EnumItem,
}
export type Enum_AvatarChatServiceFeature = Enum & {
    None: EnumItem,
    UniverseAudio: EnumItem,
    UniverseVideo: EnumItem,
    PlaceAudio: EnumItem,
    PlaceVideo: EnumItem,
    UserAudioEligible: EnumItem,
    UserAudio: EnumItem,
    UserVideoEligible: EnumItem,
    UserVideo: EnumItem,
    UserBanned: EnumItem,
    UserVerifiedForVoice: EnumItem,
}
export type Enum_AvatarContextMenuOption = Enum & {
    Friend: EnumItem,
    Chat: EnumItem,
    Emote: EnumItem,
    InspectMenu: EnumItem,
}
export type Enum_AvatarGenerationError = Enum & {
    None: EnumItem,
    Unknown: EnumItem,
    DownloadFailed: EnumItem,
    Canceled: EnumItem,
    Offensive: EnumItem,
    Timeout: EnumItem,
    JobNotFound: EnumItem,
}
export type Enum_AvatarItemType = Enum & {
    Asset: EnumItem,
    Bundle: EnumItem,
}
export type Enum_AvatarPromptResult = Enum & {
    Success: EnumItem,
    PermissionDenied: EnumItem,
    Failed: EnumItem,
}
export type Enum_AvatarSettingsAccessoryLimitMethod = Enum & {
    Scale: EnumItem,
    Remove: EnumItem,
    PreviewScale: EnumItem,
    PreviewRemove: EnumItem,
}
export type Enum_AvatarSettingsAccessoryMode = Enum & {
    PlayerChoice: EnumItem,
    CustomLimit: EnumItem,
}
export type Enum_AvatarSettingsAnimationClipsMode = Enum & {
    PlayerChoice: EnumItem,
    CustomClips: EnumItem,
}
export type Enum_AvatarSettingsAnimationPacksMode = Enum & {
    PlayerChoice: EnumItem,
    StandardR15: EnumItem,
    StandardR6: EnumItem,
}
export type Enum_AvatarSettingsAppearanceMode = Enum & {
    PlayerChoice: EnumItem,
    CustomParts: EnumItem,
    CustomBody: EnumItem,
}
export type Enum_AvatarSettingsBuildMode = Enum & {
    PlayerChoice: EnumItem,
    CustomBuild: EnumItem,
}
export type Enum_AvatarSettingsClothingMode = Enum & {
    PlayerChoice: EnumItem,
    CustomLimit: EnumItem,
}
export type Enum_AvatarSettingsCollisionMode = Enum & {
    Default: EnumItem,
    SingleCollider: EnumItem,
    Legacy: EnumItem,
}
export type Enum_AvatarSettingsCustomAccessoryMode = Enum & {
    PlayerChoice: EnumItem,
    CustomAccessories: EnumItem,
}
export type Enum_AvatarSettingsCustomBodyType = Enum & {
    AvatarReference: EnumItem,
    BundleId: EnumItem,
}
export type Enum_AvatarSettingsCustomClothingMode = Enum & {
    PlayerChoice: EnumItem,
    CustomClothing: EnumItem,
}
export type Enum_AvatarSettingsHitAndTouchDetectionMode = Enum & {
    UseParts: EnumItem,
    UseCollider: EnumItem,
}
export type Enum_AvatarSettingsJumpMode = Enum & {
    JumpHeight: EnumItem,
    JumpPower: EnumItem,
}
export type Enum_AvatarSettingsLegacyCollisionMode = Enum & {
    R6Colliders: EnumItem,
    InnerBoxColliders: EnumItem,
}
export type Enum_AvatarSettingsScaleMode = Enum & {
    PlayerChoice: EnumItem,
    CustomScale: EnumItem,
}
export type Enum_AvatarThumbnailCustomizationType = Enum & {
    Closeup: EnumItem,
    FullBody: EnumItem,
}
export type Enum_AvatarUnificationMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_Axis = Enum & {
    X: EnumItem,
    Y: EnumItem,
    Z: EnumItem,
}
export type Enum_BenefitType = Enum & {
    DeveloperProduct: EnumItem,
    AvatarAsset: EnumItem,
    AvatarBundle: EnumItem,
}
export type Enum_BinType = Enum & {
    Script: EnumItem,
    GameTool: EnumItem,
    Grab: EnumItem,
    Clone: EnumItem,
    Hammer: EnumItem,
}
export type Enum_BodyPart = Enum & {
    Head: EnumItem,
    Torso: EnumItem,
    LeftArm: EnumItem,
    RightArm: EnumItem,
    LeftLeg: EnumItem,
    RightLeg: EnumItem,
}
export type Enum_BodyPartR15 = Enum & {
    Head: EnumItem,
    UpperTorso: EnumItem,
    LowerTorso: EnumItem,
    LeftFoot: EnumItem,
    LeftLowerLeg: EnumItem,
    LeftUpperLeg: EnumItem,
    RightFoot: EnumItem,
    RightLowerLeg: EnumItem,
    RightUpperLeg: EnumItem,
    LeftHand: EnumItem,
    LeftLowerArm: EnumItem,
    LeftUpperArm: EnumItem,
    RightHand: EnumItem,
    RightLowerArm: EnumItem,
    RightUpperArm: EnumItem,
    RootPart: EnumItem,
    Unknown: EnumItem,
}
export type Enum_BorderMode = Enum & {
    Outline: EnumItem,
    Middle: EnumItem,
    Inset: EnumItem,
}
export type Enum_BorderStrokePosition = Enum & {
    Outer: EnumItem,
    Center: EnumItem,
    Inner: EnumItem,
}
export type Enum_BreakReason = Enum & {
    Other: EnumItem,
    Error: EnumItem,
    SpecialBreakpoint: EnumItem,
    UserBreakpoint: EnumItem,
}
export type Enum_BreakpointRemoveReason = Enum & {
    Requested: EnumItem,
    ScriptChanged: EnumItem,
    ScriptRemoved: EnumItem,
}
export type Enum_BulkMoveMode = Enum & {
    FireAllEvents: EnumItem,
    FireCFrameChanged: EnumItem,
}
export type Enum_BundleType = Enum & {
    BodyParts: EnumItem,
    Animations: EnumItem,
    Shoes: EnumItem,
    DynamicHead: EnumItem,
    DynamicHeadAvatar: EnumItem,
}
export type Enum_Button = Enum & {
    Jump: EnumItem,
    Dismount: EnumItem,
}
export type Enum_ButtonStyle = Enum & {
    Custom: EnumItem,
    RobloxButtonDefault: EnumItem,
    RobloxButton: EnumItem,
    RobloxRoundButton: EnumItem,
    RobloxRoundDefaultButton: EnumItem,
    RobloxRoundDropdownButton: EnumItem,
}
export type Enum_CageType = Enum & {
    Inner: EnumItem,
    Outer: EnumItem,
}
export type Enum_CameraMode = Enum & {
    Classic: EnumItem,
    LockFirstPerson: EnumItem,
}
export type Enum_CameraPanMode = Enum & {
    Classic: EnumItem,
    EdgeBump: EnumItem,
}
export type Enum_CameraSpeedAdjustBinding = Enum & {
    None: EnumItem,
    RmbScroll: EnumItem,
    AltScroll: EnumItem,
}
export type Enum_CameraType = Enum & {
    Fixed: EnumItem,
    Attach: EnumItem,
    Watch: EnumItem,
    Track: EnumItem,
    Follow: EnumItem,
    Custom: EnumItem,
    Scriptable: EnumItem,
    Orbital: EnumItem,
}
export type Enum_CaptureGalleryPermission = Enum & {
    ReadAndUpload: EnumItem,
}
export type Enum_CaptureType = Enum & {
    Screenshot: EnumItem,
    Video: EnumItem,
}
export type Enum_CatalogCategoryFilter = Enum & {
    None: EnumItem,
    Featured: EnumItem,
    Collectibles: EnumItem,
    CommunityCreations: EnumItem,
    Premium: EnumItem,
    Recommended: EnumItem,
}
export type Enum_CatalogSortAggregation = Enum & {
    Past12Hours: EnumItem,
    PastDay: EnumItem,
    Past3Days: EnumItem,
    PastWeek: EnumItem,
    PastMonth: EnumItem,
    AllTime: EnumItem,
}
export type Enum_CatalogSortType = Enum & {
    Relevance: EnumItem,
    PriceHighToLow: EnumItem,
    PriceLowToHigh: EnumItem,
    MostFavorited: EnumItem,
    RecentlyCreated: EnumItem,
    Bestselling: EnumItem,
}
export type Enum_CellBlock = Enum & {
    Solid: EnumItem,
    VerticalWedge: EnumItem,
    CornerWedge: EnumItem,
    InverseCornerWedge: EnumItem,
    HorizontalWedge: EnumItem,
}
export type Enum_CellMaterial = Enum & {
    Empty: EnumItem,
    Grass: EnumItem,
    Sand: EnumItem,
    Brick: EnumItem,
    Granite: EnumItem,
    Asphalt: EnumItem,
    Iron: EnumItem,
    Aluminum: EnumItem,
    Gold: EnumItem,
    WoodPlank: EnumItem,
    WoodLog: EnumItem,
    Gravel: EnumItem,
    CinderBlock: EnumItem,
    MossyStone: EnumItem,
    Cement: EnumItem,
    RedPlastic: EnumItem,
    BluePlastic: EnumItem,
    Water: EnumItem,
}
export type Enum_CellOrientation = Enum & {
    NegZ: EnumItem,
    X: EnumItem,
    Z: EnumItem,
    NegX: EnumItem,
}
export type Enum_CenterDialogType = Enum & {
    UnsolicitedDialog: EnumItem,
    PlayerInitiatedDialog: EnumItem,
    ModalDialog: EnumItem,
    QuitDialog: EnumItem,
}
export type Enum_CharacterControlMode = Enum & {
    Default: EnumItem,
    Legacy: EnumItem,
    NoCharacterController: EnumItem,
    LuaCharacterController: EnumItem,
}
export type Enum_ChatCallbackType = Enum & {
    OnCreatingChatWindow: EnumItem,
    OnClientSendingMessage: EnumItem,
    OnClientFormattingMessage: EnumItem,
    OnServerReceivingMessage: EnumItem,
}
export type Enum_ChatColor = Enum & {
    Blue: EnumItem,
    Green: EnumItem,
    Red: EnumItem,
    White: EnumItem,
}
export type Enum_ChatMode = Enum & {
    Menu: EnumItem,
    TextAndMenu: EnumItem,
}
export type Enum_ChatPrivacyMode = Enum & {
    AllUsers: EnumItem,
    NoOne: EnumItem,
    Friends: EnumItem,
}
export type Enum_ChatRestrictionStatus = Enum & {
    Unknown: EnumItem,
    NotRestricted: EnumItem,
    Restricted: EnumItem,
}
export type Enum_ChatStyle = Enum & {
    Classic: EnumItem,
    Bubble: EnumItem,
    ClassicAndBubble: EnumItem,
}
export type Enum_ChatVersion = Enum & {
    LegacyChatService: EnumItem,
    TextChatService: EnumItem,
}
export type Enum_ClientAnimatorThrottlingMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_CloseReason = Enum & {
    Unknown: EnumItem,
    RobloxMaintenance: EnumItem,
    DeveloperShutdown: EnumItem,
    DeveloperUpdate: EnumItem,
    ServerEmpty: EnumItem,
    OutOfMemory: EnumItem,
}
export type Enum_CollaboratorStatus = Enum & {
    None: EnumItem,
    Editing3D: EnumItem,
    Scripting: EnumItem,
    PrivateScripting: EnumItem,
}
export type Enum_CollisionFidelity = Enum & {
    Default: EnumItem,
    Hull: EnumItem,
    Box: EnumItem,
    PreciseConvexDecomposition: EnumItem,
}
export type Enum_CommandPermission = Enum & {
    Plugin: EnumItem,
    LocalUser: EnumItem,
}
export type Enum_CompileTarget = Enum & {
    Client: EnumItem,
    CoreScript: EnumItem,
    Studio: EnumItem,
    CoreScriptRaw: EnumItem,
}
export type Enum_CompletionAcceptanceBehavior = Enum & {
    Insert: EnumItem,
    Replace: EnumItem,
    ReplaceOnEnterInsertOnTab: EnumItem,
    InsertOnEnterReplaceOnTab: EnumItem,
}
export type Enum_CompletionItemKind = Enum & {
    Text: EnumItem,
    Method: EnumItem,
    Function: EnumItem,
    Constructor: EnumItem,
    Field: EnumItem,
    Variable: EnumItem,
    Class: EnumItem,
    Interface: EnumItem,
    Module: EnumItem,
    Property: EnumItem,
    Unit: EnumItem,
    Value: EnumItem,
    Enum: EnumItem,
    Keyword: EnumItem,
    Snippet: EnumItem,
    Color: EnumItem,
    File: EnumItem,
    Reference: EnumItem,
    Folder: EnumItem,
    EnumMember: EnumItem,
    Constant: EnumItem,
    Struct: EnumItem,
    Event: EnumItem,
    Operator: EnumItem,
    TypeParameter: EnumItem,
}
export type Enum_CompletionItemTag = Enum & {
    Deprecated: EnumItem,
    IncorrectIndexType: EnumItem,
    PluginPermissions: EnumItem,
    CommandLinePermissions: EnumItem,
    RobloxPermissions: EnumItem,
    AddParens: EnumItem,
    PutCursorInParens: EnumItem,
    TypeCorrect: EnumItem,
    ClientServerBoundaryViolation: EnumItem,
    Invalidated: EnumItem,
    PutCursorBeforeEnd: EnumItem,
}
export type Enum_CompletionTriggerKind = Enum & {
    Invoked: EnumItem,
    TriggerCharacter: EnumItem,
    TriggerForIncompleteCompletions: EnumItem,
}
export type Enum_CompositeValueCurveType = Enum & {
    ColorRGB: EnumItem,
    ColorHSV: EnumItem,
    NumberRange: EnumItem,
    Rect: EnumItem,
    UDim: EnumItem,
    UDim2: EnumItem,
    Vector2: EnumItem,
    Vector3: EnumItem,
}
export type Enum_CompressionAlgorithm = Enum & {
    Zstd: EnumItem,
}
export type Enum_ComputerCameraMovementMode = Enum & {
    Default: EnumItem,
    Classic: EnumItem,
    Follow: EnumItem,
    Orbital: EnumItem,
    CameraToggle: EnumItem,
}
export type Enum_ComputerMovementMode = Enum & {
    Default: EnumItem,
    KeyboardMouse: EnumItem,
    ClickToMove: EnumItem,
}
export type Enum_ConfigSnapshotErrorState = Enum & {
    None: EnumItem,
    LoadFailed: EnumItem,
}
export type Enum_ConnectionError = Enum & {
    OK: EnumItem,
    Unknown: EnumItem,
    ConnectErrors: EnumItem,
    AlreadyConnected: EnumItem,
    NoFreeIncomingConnections: EnumItem,
    ConnectionBanned: EnumItem,
    InvalidPassword: EnumItem,
    IncompatibleProtocolVersion: EnumItem,
    IPRecentlyConnected: EnumItem,
    OurSystemRequiresSecurity: EnumItem,
    SecurityKeyMismatch: EnumItem,
    DisconnectErrors: EnumItem,
    DisconnectBadhash: EnumItem,
    DisconnectSecurityKeyMismatch: EnumItem,
    DisconnectProtocolMismatch: EnumItem,
    DisconnectReceivePacketError: EnumItem,
    DisconnectReceivePacketStreamError: EnumItem,
    DisconnectSendPacketError: EnumItem,
    DisconnectIllegalTeleport: EnumItem,
    DisconnectDuplicatePlayer: EnumItem,
    DisconnectDuplicateTicket: EnumItem,
    DisconnectTimeout: EnumItem,
    DisconnectLuaKick: EnumItem,
    DisconnectOnRemoteSysStats: EnumItem,
    DisconnectHashTimeout: EnumItem,
    DisconnectCloudEditKick: EnumItem,
    DisconnectPlayerless: EnumItem,
    DisconnectNewSecurityKeyMismatch: EnumItem,
    DisconnectEvicted: EnumItem,
    DisconnectDevMaintenance: EnumItem,
    DisconnectRobloxMaintenance: EnumItem,
    DisconnectRejoin: EnumItem,
    DisconnectConnectionLost: EnumItem,
    DisconnectIdle: EnumItem,
    DisconnectRaknetErrors: EnumItem,
    DisconnectWrongVersion: EnumItem,
    DisconnectBySecurityPolicy: EnumItem,
    DisconnectBlockedIP: EnumItem,
    DisconnectClientFailure: EnumItem,
    DisconnectClientRequest: EnumItem,
    DisconnectPrivateServerKickout: EnumItem,
    DisconnectModeratedGame: EnumItem,
    ServerShutdown: EnumItem,
    ReplicatorTimeout: EnumItem,
    PlayerRemoved: EnumItem,
    DisconnectOutOfMemoryKeepPlayingLeave: EnumItem,
    DisconnectRomarkEndOfTest: EnumItem,
    DisconnectCollaboratorPermissionRevoked: EnumItem,
    DisconnectCollaboratorUnderage: EnumItem,
    NetworkInternal: EnumItem,
    NetworkSend: EnumItem,
    NetworkTimeout: EnumItem,
    NetworkMisbehavior: EnumItem,
    NetworkSecurity: EnumItem,
    ReplacementReady: EnumItem,
    ServerEmpty: EnumItem,
    PhantomFreeze: EnumItem,
    AndroidAnticheatKick: EnumItem,
    AndroidEmulatorKick: EnumItem,
    AndroidRootedKick: EnumItem,
    ScreentimeLockoutKick: EnumItem,
    DisconnectionNotification: EnumItem,
    DisconnectVerboselyModeratedGame: EnumItem,
    DisconnectCollaboratorNotAgeVerified: EnumItem,
    DisconnectCollaboratorTrustedConnectionsRequired: EnumItem,
    DisconnectCollaboratorOwnerActionRequired: EnumItem,
    DisconnectCollaboratorTooManyCollaborators: EnumItem,
    DisconnectCollaboratorUnknownError: EnumItem,
    PlacelaunchErrors: EnumItem,
    PlacelaunchDisabled: EnumItem,
    PlacelaunchError: EnumItem,
    PlacelaunchGameEnded: EnumItem,
    PlacelaunchGameFull: EnumItem,
    PlacelaunchUserLeft: EnumItem,
    PlacelaunchRestricted: EnumItem,
    PlacelaunchUnauthorized: EnumItem,
    PlacelaunchFlooded: EnumItem,
    PlacelaunchHashExpired: EnumItem,
    PlacelaunchHashException: EnumItem,
    PlacelaunchPartyCannotFit: EnumItem,
    PlacelaunchHttpError: EnumItem,
    PlacelaunchUserPrivacyUnauthorized: EnumItem,
    PlacelaunchCreatorBan: EnumItem,
    PlacelaunchCustomMessage: EnumItem,
    PlacelaunchOtherError: EnumItem,
    TeleportErrors: EnumItem,
    TeleportFailure: EnumItem,
    TeleportGameNotFound: EnumItem,
    TeleportGameEnded: EnumItem,
    TeleportGameFull: EnumItem,
    TeleportUnauthorized: EnumItem,
    TeleportFlooded: EnumItem,
    TeleportIsTeleporting: EnumItem,
}
export type Enum_ConnectionState = Enum & {
    Connected: EnumItem,
    Disconnected: EnumItem,
}
export type Enum_ContentSourceType = Enum & {
    None: EnumItem,
    Uri: EnumItem,
    Object: EnumItem,
    Opaque: EnumItem,
}
export type Enum_ContextActionPriority = Enum & {
    Low: EnumItem,
    Medium: EnumItem,
    High: EnumItem,
}
export type Enum_ContextActionResult = Enum & {
    Sink: EnumItem,
    Pass: EnumItem,
}
export type Enum_ControlMode = Enum & {
    Classic: EnumItem,
    MouseLockSwitch: EnumItem,
}
export type Enum_CoreGuiType = Enum & {
    PlayerList: EnumItem,
    Health: EnumItem,
    Backpack: EnumItem,
    Chat: EnumItem,
    All: EnumItem,
    EmotesMenu: EnumItem,
    SelfView: EnumItem,
    Captures: EnumItem,
    AvatarSwitcher: EnumItem,
}
export type Enum_CreateAssetResult = Enum & {
    Success: EnumItem,
    PermissionDenied: EnumItem,
    UploadFailed: EnumItem,
    Unknown: EnumItem,
}
export type Enum_CreateOutfitFailure = Enum & {
    InvalidName: EnumItem,
    OutfitLimitReached: EnumItem,
    Other: EnumItem,
}
export type Enum_CreatorType = Enum & {
    User: EnumItem,
    Group: EnumItem,
}
export type Enum_CreatorTypeFilter = Enum & {
    User: EnumItem,
    Group: EnumItem,
    All: EnumItem,
}
export type Enum_CurrencyType = Enum & {
    Default: EnumItem,
    Robux: EnumItem,
    Tix: EnumItem,
}
export type Enum_CustomCameraMode = Enum & {
    Default: EnumItem,
    Classic: EnumItem,
    Follow: EnumItem,
}
export type Enum_DataModelExtractorFileType = Enum & {
    PlaceFile: EnumItem,
    FirstSlice: EnumItem,
    NonFirstSlice: EnumItem,
}
export type Enum_DataStoreRequestType = Enum & {
    GetAsync: EnumItem,
    SetIncrementAsync: EnumItem,
    UpdateAsync: EnumItem,
    GetSortedAsync: EnumItem,
    SetIncrementSortedAsync: EnumItem,
    OnUpdate: EnumItem,
    ListAsync: EnumItem,
    GetVersionAsync: EnumItem,
    RemoveVersionAsync: EnumItem,
    StandardRead: EnumItem,
    StandardWrite: EnumItem,
    StandardList: EnumItem,
    StandardRemove: EnumItem,
    OrderedRead: EnumItem,
    OrderedWrite: EnumItem,
    OrderedList: EnumItem,
    OrderedRemove: EnumItem,
}
export type Enum_DebuggerEndReason = Enum & {
    ClientRequest: EnumItem,
    Timeout: EnumItem,
    InvalidHost: EnumItem,
    Disconnected: EnumItem,
    ServerShutdown: EnumItem,
    ServerProtocolMismatch: EnumItem,
    ConfigurationFailed: EnumItem,
    RpcError: EnumItem,
}
export type Enum_DebuggerExceptionBreakMode = Enum & {
    Never: EnumItem,
    Always: EnumItem,
    Unhandled: EnumItem,
}
export type Enum_DebuggerFrameType = Enum & {
    C: EnumItem,
    Lua: EnumItem,
}
export type Enum_DebuggerPauseReason = Enum & {
    Unknown: EnumItem,
    Requested: EnumItem,
    Breakpoint: EnumItem,
    Exception: EnumItem,
    SingleStep: EnumItem,
    Entrypoint: EnumItem,
}
export type Enum_DebuggerStatus = Enum & {
    Success: EnumItem,
    Timeout: EnumItem,
    ConnectionLost: EnumItem,
    InvalidResponse: EnumItem,
    InternalError: EnumItem,
    InvalidState: EnumItem,
    RpcError: EnumItem,
    InvalidArgument: EnumItem,
    ConnectionClosed: EnumItem,
}
export type Enum_DefaultScriptSyncFileType = Enum & {
    Lua: EnumItem,
    Luau: EnumItem,
}
export type Enum_DevCameraOcclusionMode = Enum & {
    Zoom: EnumItem,
    Invisicam: EnumItem,
}
export type Enum_DevComputerCameraMovementMode = Enum & {
    UserChoice: EnumItem,
    Classic: EnumItem,
    Follow: EnumItem,
    Orbital: EnumItem,
    CameraToggle: EnumItem,
}
export type Enum_DevComputerMovementMode = Enum & {
    UserChoice: EnumItem,
    KeyboardMouse: EnumItem,
    ClickToMove: EnumItem,
    Scriptable: EnumItem,
}
export type Enum_DevTouchCameraMovementMode = Enum & {
    UserChoice: EnumItem,
    Classic: EnumItem,
    Follow: EnumItem,
    Orbital: EnumItem,
}
export type Enum_DevTouchMovementMode = Enum & {
    UserChoice: EnumItem,
    Thumbstick: EnumItem,
    DPad: EnumItem,
    Thumbpad: EnumItem,
    ClickToMove: EnumItem,
    Scriptable: EnumItem,
    DynamicThumbstick: EnumItem,
}
export type Enum_DeveloperMemoryTag = Enum & {
    Internal: EnumItem,
    HttpCache: EnumItem,
    Instances: EnumItem,
    Signals: EnumItem,
    LuaHeap: EnumItem,
    Script: EnumItem,
    PhysicsCollision: EnumItem,
    BaseParts: EnumItem,
    GraphicsSolidModels: EnumItem,
    GraphicsMeshParts: EnumItem,
    GraphicsParticles: EnumItem,
    GraphicsParts: EnumItem,
    GraphicsSpatialHash: EnumItem,
    GraphicsTerrain: EnumItem,
    GraphicsTexture: EnumItem,
    GraphicsTextureCharacter: EnumItem,
    Sounds: EnumItem,
    StreamingSounds: EnumItem,
    TerrainVoxels: EnumItem,
    Gui: EnumItem,
    Animation: EnumItem,
    Navigation: EnumItem,
    GeometryCSG: EnumItem,
    GraphicsSlimModels: EnumItem,
}
export type Enum_DeviceFeatureType = Enum & {
    DeviceCapture: EnumItem,
    InExperienceFAE: EnumItem,
}
export type Enum_DeviceForm = Enum & {
    Console: EnumItem,
    Phone: EnumItem,
    Tablet: EnumItem,
    Desktop: EnumItem,
    VR: EnumItem,
}
export type Enum_DeviceLevel = Enum & {
    Low: EnumItem,
    Medium: EnumItem,
    High: EnumItem,
}
export type Enum_DeviceType = Enum & {
    Unknown: EnumItem,
    Desktop: EnumItem,
    Tablet: EnumItem,
    Phone: EnumItem,
}
export type Enum_DialogBehaviorType = Enum & {
    SinglePlayer: EnumItem,
    MultiplePlayers: EnumItem,
}
export type Enum_DialogPurpose = Enum & {
    Quest: EnumItem,
    Help: EnumItem,
    Shop: EnumItem,
}
export type Enum_DialogTone = Enum & {
    Neutral: EnumItem,
    Friendly: EnumItem,
    Enemy: EnumItem,
}
export type Enum_DisplayScalingMode = Enum & {
    Default: EnumItem,
    Legacy: EnumItem,
    Responsive: EnumItem,
}
export type Enum_DisplaySize = Enum & {
    Small: EnumItem,
    Medium: EnumItem,
    Large: EnumItem,
}
export type Enum_DominantAxis = Enum & {
    Width: EnumItem,
    Height: EnumItem,
}
export type Enum_DraftStatusCode = Enum & {
    OK: EnumItem,
    DraftOutdated: EnumItem,
    ScriptRemoved: EnumItem,
    DraftCommitted: EnumItem,
}
export type Enum_DragDetectorDragStyle = Enum & {
    TranslateLine: EnumItem,
    TranslatePlane: EnumItem,
    TranslatePlaneOrLine: EnumItem,
    TranslateLineOrPlane: EnumItem,
    TranslateViewPlane: EnumItem,
    RotateAxis: EnumItem,
    RotateTrackball: EnumItem,
    Scriptable: EnumItem,
    BestForDevice: EnumItem,
}
export type Enum_DragDetectorPermissionPolicy = Enum & {
    Nobody: EnumItem,
    Everybody: EnumItem,
    Scriptable: EnumItem,
}
export type Enum_DragDetectorResponseStyle = Enum & {
    Geometric: EnumItem,
    Physical: EnumItem,
    Custom: EnumItem,
}
export type Enum_DraggerCoordinateSpace = Enum & {
    Object: EnumItem,
    World: EnumItem,
}
export type Enum_DraggerMovementMode = Enum & {
    Geometric: EnumItem,
    Physical: EnumItem,
}
export type Enum_DraggingScrollBar = Enum & {
    None: EnumItem,
    Horizontal: EnumItem,
    Vertical: EnumItem,
}
export type Enum_EasingDirection = Enum & {
    In: EnumItem,
    Out: EnumItem,
    InOut: EnumItem,
}
export type Enum_EasingStyle = Enum & {
    Linear: EnumItem,
    Sine: EnumItem,
    Back: EnumItem,
    Quad: EnumItem,
    Quart: EnumItem,
    Quint: EnumItem,
    Bounce: EnumItem,
    Elastic: EnumItem,
    Exponential: EnumItem,
    Circular: EnumItem,
    Cubic: EnumItem,
}
export type Enum_EditableStatus = Enum & {
    Unknown: EnumItem,
    Allowed: EnumItem,
    Disallowed: EnumItem,
}
export type Enum_ElasticBehavior = Enum & {
    WhenScrollable: EnumItem,
    Always: EnumItem,
    Never: EnumItem,
}
export type Enum_EngineFolder = Enum & {
    Screenshots: EnumItem,
    Videos: EnumItem,
    Logs: EnumItem,
}
export type Enum_EnviromentalPhysicsThrottle = Enum & {
    DefaultAuto: EnumItem,
    Disabled: EnumItem,
    Always: EnumItem,
    Skip2: EnumItem,
    Skip4: EnumItem,
    Skip8: EnumItem,
    Skip16: EnumItem,
}
export type Enum_ExperienceAuthScope = Enum & {
    DefaultScope: EnumItem,
    CreatorAssetsCreate: EnumItem,
}
export type Enum_ExperienceEventStatus = Enum & {
    Active: EnumItem,
    Cancelled: EnumItem,
    Moderated: EnumItem,
    Unpublished: EnumItem,
    Unknown: EnumItem,
}
export type Enum_ExperienceStateCaptureSelectionMode = Enum & {
    Default: EnumItem,
    SafetyHighlightMode: EnumItem,
}
export type Enum_ExperienceStateRecordingLoadMode = Enum & {
    NewReplay: EnumItem,
    ContiguousSlice: EnumItem,
    NoncontiguousSlice: EnumItem,
}
export type Enum_ExperienceStateRecordingLoadSourceType = Enum & {
    S3Url: EnumItem,
    File: EnumItem,
}
export type Enum_ExperienceStateRecordingPlaybackMode = Enum & {
    Undefined: EnumItem,
    Stopped: EnumItem,
    Playing: EnumItem,
    Rewinding: EnumItem,
}
export type Enum_ExplosionType = Enum & {
    NoCraters: EnumItem,
    Craters: EnumItem,
}
export type Enum_FACSDataLod = Enum & {
    LOD0: EnumItem,
    LOD1: EnumItem,
    LODCount: EnumItem,
}
export type Enum_FacialAgeEstimationResultType = Enum & {
    Complete: EnumItem,
    Cancel: EnumItem,
    Error: EnumItem,
}
export type Enum_FacialAnimationStreamingState = Enum & {
    None: EnumItem,
    Audio: EnumItem,
    Video: EnumItem,
    Place: EnumItem,
    Server: EnumItem,
}
export type Enum_FacsActionUnit = Enum & {
    ChinRaiserUpperLip: EnumItem,
    ChinRaiser: EnumItem,
    FlatPucker: EnumItem,
    Funneler: EnumItem,
    LowerLipSuck: EnumItem,
    LipPresser: EnumItem,
    LipsTogether: EnumItem,
    MouthLeft: EnumItem,
    MouthRight: EnumItem,
    Pucker: EnumItem,
    UpperLipSuck: EnumItem,
    LeftCheekPuff: EnumItem,
    LeftDimpler: EnumItem,
    LeftLipCornerDown: EnumItem,
    LeftLowerLipDepressor: EnumItem,
    LeftLipCornerPuller: EnumItem,
    LeftLipStretcher: EnumItem,
    LeftUpperLipRaiser: EnumItem,
    RightCheekPuff: EnumItem,
    RightDimpler: EnumItem,
    RightLipCornerDown: EnumItem,
    RightLowerLipDepressor: EnumItem,
    RightLipCornerPuller: EnumItem,
    RightLipStretcher: EnumItem,
    RightUpperLipRaiser: EnumItem,
    JawDrop: EnumItem,
    JawLeft: EnumItem,
    JawRight: EnumItem,
    Corrugator: EnumItem,
    LeftBrowLowerer: EnumItem,
    LeftOuterBrowRaiser: EnumItem,
    LeftNoseWrinkler: EnumItem,
    LeftInnerBrowRaiser: EnumItem,
    RightBrowLowerer: EnumItem,
    RightOuterBrowRaiser: EnumItem,
    RightInnerBrowRaiser: EnumItem,
    RightNoseWrinkler: EnumItem,
    EyesLookDown: EnumItem,
    EyesLookLeft: EnumItem,
    EyesLookUp: EnumItem,
    EyesLookRight: EnumItem,
    LeftCheekRaiser: EnumItem,
    LeftEyeUpperLidRaiser: EnumItem,
    LeftEyeClosed: EnumItem,
    RightCheekRaiser: EnumItem,
    RightEyeUpperLidRaiser: EnumItem,
    RightEyeClosed: EnumItem,
    TongueDown: EnumItem,
    TongueOut: EnumItem,
    TongueUp: EnumItem,
}
export type Enum_FeatureRestrictionAbuseVector = Enum & {
    ExperienceChat: EnumItem,
    Communication: EnumItem,
}
export type Enum_FieldOfViewMode = Enum & {
    Vertical: EnumItem,
    Diagonal: EnumItem,
    MaxAxis: EnumItem,
}
export type Enum_FillDirection = Enum & {
    Horizontal: EnumItem,
    Vertical: EnumItem,
}
export type Enum_FilterErrorType = Enum & {
    BackslashNotEscapingAnything: EnumItem,
    BadBespokeFilter: EnumItem,
    BadName: EnumItem,
    IncompleteOr: EnumItem,
    IncompleteParenthesis: EnumItem,
    InvalidDoubleStar: EnumItem,
    InvalidTilde: EnumItem,
    PropertyBadOperator: EnumItem,
    PropertyDoesNotExist: EnumItem,
    PropertyInvalidField: EnumItem,
    PropertyInvalidValue: EnumItem,
    PropertyUnsupportedFields: EnumItem,
    PropertyUnsupportedProperty: EnumItem,
    UnexpectedNameIndex: EnumItem,
    UnexpectedToken: EnumItem,
    UnfinishedBinaryOperator: EnumItem,
    UnfinishedQuote: EnumItem,
    UnknownBespokeFilter: EnumItem,
    WildcardInProperty: EnumItem,
}
export type Enum_FilterResult = Enum & {
    Accepted: EnumItem,
    Rejected: EnumItem,
}
export type Enum_FilterType = Enum & {
    Exclude: EnumItem,
    Include: EnumItem,
}
export type Enum_FinishRecordingOperation = Enum & {
    Cancel: EnumItem,
    Commit: EnumItem,
    Append: EnumItem,
}
export type Enum_FluidFidelity = Enum & {
    Automatic: EnumItem,
    UseCollisionGeometry: EnumItem,
    UsePreciseGeometry: EnumItem,
}
export type Enum_FluidForces = Enum & {
    Default: EnumItem,
    Experimental: EnumItem,
}
export type Enum_Font = Enum & {
    Legacy: EnumItem,
    Arial: EnumItem,
    ArialBold: EnumItem,
    SourceSans: EnumItem,
    SourceSansBold: EnumItem,
    SourceSansLight: EnumItem,
    SourceSansItalic: EnumItem,
    Bodoni: EnumItem,
    Garamond: EnumItem,
    Cartoon: EnumItem,
    Code: EnumItem,
    Highway: EnumItem,
    SciFi: EnumItem,
    Arcade: EnumItem,
    Fantasy: EnumItem,
    Antique: EnumItem,
    SourceSansSemibold: EnumItem,
    Gotham: EnumItem,
    GothamMedium: EnumItem,
    GothamBold: EnumItem,
    GothamBlack: EnumItem,
    AmaticSC: EnumItem,
    Bangers: EnumItem,
    Creepster: EnumItem,
    DenkOne: EnumItem,
    Fondamento: EnumItem,
    FredokaOne: EnumItem,
    GrenzeGotisch: EnumItem,
    IndieFlower: EnumItem,
    JosefinSans: EnumItem,
    Jura: EnumItem,
    Kalam: EnumItem,
    LuckiestGuy: EnumItem,
    Merriweather: EnumItem,
    Michroma: EnumItem,
    Nunito: EnumItem,
    Oswald: EnumItem,
    PatrickHand: EnumItem,
    PermanentMarker: EnumItem,
    Roboto: EnumItem,
    RobotoCondensed: EnumItem,
    RobotoMono: EnumItem,
    Sarpanch: EnumItem,
    SpecialElite: EnumItem,
    TitilliumWeb: EnumItem,
    Ubuntu: EnumItem,
    BuilderSans: EnumItem,
    BuilderSansMedium: EnumItem,
    BuilderSansBold: EnumItem,
    BuilderSansExtraBold: EnumItem,
    Arimo: EnumItem,
    ArimoBold: EnumItem,
    Unknown: EnumItem,
}
export type Enum_FontSize = Enum & {
    Size8: EnumItem,
    Size9: EnumItem,
    Size10: EnumItem,
    Size11: EnumItem,
    Size12: EnumItem,
    Size14: EnumItem,
    Size18: EnumItem,
    Size24: EnumItem,
    Size36: EnumItem,
    Size48: EnumItem,
    Size28: EnumItem,
    Size32: EnumItem,
    Size42: EnumItem,
    Size60: EnumItem,
    Size96: EnumItem,
}
export type Enum_FontStyle = Enum & {
    Normal: EnumItem,
    Italic: EnumItem,
}
export type Enum_FontWeight = Enum & {
    Thin: EnumItem,
    ExtraLight: EnumItem,
    Light: EnumItem,
    Regular: EnumItem,
    Medium: EnumItem,
    SemiBold: EnumItem,
    Bold: EnumItem,
    ExtraBold: EnumItem,
    Heavy: EnumItem,
}
export type Enum_ForceLimitMode = Enum & {
    Magnitude: EnumItem,
    PerAxis: EnumItem,
}
export type Enum_FormFactor = Enum & {
    Symmetric: EnumItem,
    Brick: EnumItem,
    Plate: EnumItem,
    Custom: EnumItem,
}
export type Enum_FrameStyle = Enum & {
    Custom: EnumItem,
    ChatBlue: EnumItem,
    RobloxSquare: EnumItem,
    RobloxRound: EnumItem,
    ChatGreen: EnumItem,
    ChatRed: EnumItem,
    DropShadow: EnumItem,
}
export type Enum_FramerateManagerMode = Enum & {
    Automatic: EnumItem,
    On: EnumItem,
    Off: EnumItem,
}
export type Enum_FriendRequestEvent = Enum & {
    Issue: EnumItem,
    Revoke: EnumItem,
    Accept: EnumItem,
    Deny: EnumItem,
}
export type Enum_FriendStatus = Enum & {
    Unknown: EnumItem,
    NotFriend: EnumItem,
    Friend: EnumItem,
    FriendRequestSent: EnumItem,
    FriendRequestReceived: EnumItem,
}
export type Enum_FunctionalTestResult = Enum & {
    Passed: EnumItem,
    Warning: EnumItem,
    Error: EnumItem,
}
export type Enum_GameAvatarType = Enum & {
    R6: EnumItem,
    R15: EnumItem,
    PlayerChoice: EnumItem,
}
export type Enum_GamepadType = Enum & {
    Unknown: EnumItem,
    PS4: EnumItem,
    PS5: EnumItem,
    XboxOne: EnumItem,
}
export type Enum_GearGenreSetting = Enum & {
    AllGenres: EnumItem,
    MatchingGenreOnly: EnumItem,
}
export type Enum_GearType = Enum & {
    MeleeWeapons: EnumItem,
    RangedWeapons: EnumItem,
    Explosives: EnumItem,
    PowerUps: EnumItem,
    NavigationEnhancers: EnumItem,
    MusicalInstruments: EnumItem,
    SocialItems: EnumItem,
    BuildingTools: EnumItem,
    Transport: EnumItem,
}
export type Enum_Genre = Enum & {
    All: EnumItem,
    TownAndCity: EnumItem,
    Fantasy: EnumItem,
    SciFi: EnumItem,
    Ninja: EnumItem,
    Scary: EnumItem,
    Pirate: EnumItem,
    Adventure: EnumItem,
    Sports: EnumItem,
    Funny: EnumItem,
    WildWest: EnumItem,
    War: EnumItem,
    SkatePark: EnumItem,
    Tutorial: EnumItem,
}
export type Enum_GraphicsMode = Enum & {
    Automatic: EnumItem,
    Direct3D11: EnumItem,
    OpenGL: EnumItem,
    Metal: EnumItem,
    Vulkan: EnumItem,
    NoGraphics: EnumItem,
}
export type Enum_GraphicsOptimizationMode = Enum & {
    Performance: EnumItem,
    Balanced: EnumItem,
    Quality: EnumItem,
}
export type Enum_GroupMembershipStatus = Enum & {
    None: EnumItem,
    Joined: EnumItem,
    JoinRequestPending: EnumItem,
    AlreadyMember: EnumItem,
}
export type Enum_GuiState = Enum & {
    Idle: EnumItem,
    Hover: EnumItem,
    Press: EnumItem,
    NonInteractable: EnumItem,
}
export type Enum_GuiType = Enum & {
    Core: EnumItem,
    Custom: EnumItem,
    PlayerNameplates: EnumItem,
    CustomBillboards: EnumItem,
    CoreBillboards: EnumItem,
}
export type Enum_HandRigDescriptionSide = Enum & {
    None: EnumItem,
    Left: EnumItem,
    Right: EnumItem,
}
export type Enum_HandlesStyle = Enum & {
    Resize: EnumItem,
    Movement: EnumItem,
}
export type Enum_HapticEffectType = Enum & {
    Custom: EnumItem,
    UIHover: EnumItem,
    UIClick: EnumItem,
    UINotification: EnumItem,
    GameplayExplosion: EnumItem,
    GameplayCollision: EnumItem,
}
export type Enum_HashAlgorithm = Enum & {
    Blake2b: EnumItem,
    Blake3: EnumItem,
    Md5: EnumItem,
    Sha1: EnumItem,
    Sha256: EnumItem,
}
export type Enum_HighlightDepthMode = Enum & {
    AlwaysOnTop: EnumItem,
    Occluded: EnumItem,
}
export type Enum_HorizontalAlignment = Enum & {
    Center: EnumItem,
    Left: EnumItem,
    Right: EnumItem,
}
export type Enum_HoverAnimateSpeed = Enum & {
    VerySlow: EnumItem,
    Slow: EnumItem,
    Medium: EnumItem,
    Fast: EnumItem,
    VeryFast: EnumItem,
}
export type Enum_HttpCachePolicy = Enum & {
    None: EnumItem,
    Full: EnumItem,
    DataOnly: EnumItem,
    Default: EnumItem,
    InternalRedirectRefresh: EnumItem,
}
export type Enum_HttpCompression = Enum & {
    None: EnumItem,
    Gzip: EnumItem,
}
export type Enum_HttpContentType = Enum & {
    ApplicationJson: EnumItem,
    ApplicationXml: EnumItem,
    ApplicationUrlEncoded: EnumItem,
    TextPlain: EnumItem,
    TextXml: EnumItem,
}
export type Enum_HttpError = Enum & {
    OK: EnumItem,
    InvalidUrl: EnumItem,
    DnsResolve: EnumItem,
    ConnectFail: EnumItem,
    OutOfMemory: EnumItem,
    TimedOut: EnumItem,
    TooManyRedirects: EnumItem,
    InvalidRedirect: EnumItem,
    NetFail: EnumItem,
    Aborted: EnumItem,
    SslConnectFail: EnumItem,
    SslVerificationFail: EnumItem,
    Unknown: EnumItem,
    ConnectionClosed: EnumItem,
    ServerProtocolError: EnumItem,
    CreatorEnvironmentsNotSupportedByService: EnumItem,
    InactivityTimeout: EnumItem,
    TooManyOutstandingRequests: EnumItem,
}
export type Enum_HttpRequestType = Enum & {
    Default: EnumItem,
    MarketplaceService: EnumItem,
    Players: EnumItem,
    Chat: EnumItem,
    Avatar: EnumItem,
    Analytics: EnumItem,
    Localization: EnumItem,
}
export type Enum_HumanoidCollisionType = Enum & {
    OuterBox: EnumItem,
    InnerBox: EnumItem,
}
export type Enum_HumanoidDisplayDistanceType = Enum & {
    Viewer: EnumItem,
    Subject: EnumItem,
    None: EnumItem,
}
export type Enum_HumanoidHealthDisplayType = Enum & {
    DisplayWhenDamaged: EnumItem,
    AlwaysOn: EnumItem,
    AlwaysOff: EnumItem,
}
export type Enum_HumanoidRigType = Enum & {
    R6: EnumItem,
    R15: EnumItem,
}
export type Enum_HumanoidStateType = Enum & {
    FallingDown: EnumItem,
    Ragdoll: EnumItem,
    GettingUp: EnumItem,
    Jumping: EnumItem,
    Swimming: EnumItem,
    Freefall: EnumItem,
    Flying: EnumItem,
    Landed: EnumItem,
    Running: EnumItem,
    RunningNoPhysics: EnumItem,
    StrafingNoPhysics: EnumItem,
    Climbing: EnumItem,
    Seated: EnumItem,
    PlatformStanding: EnumItem,
    Dead: EnumItem,
    Physics: EnumItem,
    None: EnumItem,
}
export type Enum_IKCollisionsMode = Enum & {
    NoCollisions: EnumItem,
    OtherMechanismsAnchored: EnumItem,
    IncludeContactedMechanisms: EnumItem,
}
export type Enum_IKControlConstraintSupport = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_IKControlType = Enum & {
    Transform: EnumItem,
    Position: EnumItem,
    Rotation: EnumItem,
    LookAt: EnumItem,
}
export type Enum_IXPLoadingStatus = Enum & {
    None: EnumItem,
    Pending: EnumItem,
    Initialized: EnumItem,
    ErrorInvalidUser: EnumItem,
    ErrorConnection: EnumItem,
    ErrorJsonParse: EnumItem,
    ErrorTimedOut: EnumItem,
}
export type Enum_ImageAlphaType = Enum & {
    Default: EnumItem,
    LockCanvasAlpha: EnumItem,
    LockCanvasColor: EnumItem,
}
export type Enum_ImageCombineType = Enum & {
    BlendSourceOver: EnumItem,
    Overwrite: EnumItem,
    Add: EnumItem,
    Multiply: EnumItem,
    AlphaBlend: EnumItem,
}
export type Enum_InOut = Enum & {
    Edge: EnumItem,
    Inset: EnumItem,
    Center: EnumItem,
}
export type Enum_InfoType = Enum & {
    Asset: EnumItem,
    Product: EnumItem,
    GamePass: EnumItem,
    Subscription: EnumItem,
    Bundle: EnumItem,
}
export type Enum_InitialDockState = Enum & {
    Top: EnumItem,
    Bottom: EnumItem,
    Left: EnumItem,
    Right: EnumItem,
    Float: EnumItem,
}
export type Enum_InputActionType = Enum & {
    Bool: EnumItem,
    Direction1D: EnumItem,
    Direction2D: EnumItem,
    Direction3D: EnumItem,
    ViewportPosition: EnumItem,
}
export type Enum_InputType = Enum & {
    NoInput: EnumItem,
    Constant: EnumItem,
    Sin: EnumItem,
}
export type Enum_InstanceFileSyncStatus = Enum & {
    NotSynced: EnumItem,
    Errored: EnumItem,
    SyncedAsRoot: EnumItem,
    SyncedAsDescendant: EnumItem,
}
export type Enum_IntermediateMeshGenerationResult = Enum & {
    HighQualityMesh: EnumItem,
}
export type Enum_InterpolationThrottlingMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_InviteState = Enum & {
    Placed: EnumItem,
    Accepted: EnumItem,
    Declined: EnumItem,
    Missed: EnumItem,
}
export type Enum_ItemLineAlignment = Enum & {
    Automatic: EnumItem,
    Start: EnumItem,
    Center: EnumItem,
    End: EnumItem,
    Stretch: EnumItem,
}
export type Enum_JoinSource = Enum & {
    CreatedItemAttribution: EnumItem,
}
export type Enum_JointCreationMode = Enum & {
    All: EnumItem,
    Surface: EnumItem,
    None: EnumItem,
}
export type Enum_KeyCode = Enum & {
    Unknown: EnumItem,
    Backspace: EnumItem,
    Tab: EnumItem,
    Clear: EnumItem,
    Return: EnumItem,
    Pause: EnumItem,
    Escape: EnumItem,
    Space: EnumItem,
    QuotedDouble: EnumItem,
    Hash: EnumItem,
    Dollar: EnumItem,
    Percent: EnumItem,
    Ampersand: EnumItem,
    Quote: EnumItem,
    LeftParenthesis: EnumItem,
    RightParenthesis: EnumItem,
    Asterisk: EnumItem,
    Plus: EnumItem,
    Comma: EnumItem,
    Minus: EnumItem,
    Period: EnumItem,
    Slash: EnumItem,
    Zero: EnumItem,
    One: EnumItem,
    Two: EnumItem,
    Three: EnumItem,
    Four: EnumItem,
    Five: EnumItem,
    Six: EnumItem,
    Seven: EnumItem,
    Eight: EnumItem,
    Nine: EnumItem,
    Colon: EnumItem,
    Semicolon: EnumItem,
    LessThan: EnumItem,
    Equals: EnumItem,
    GreaterThan: EnumItem,
    Question: EnumItem,
    At: EnumItem,
    LeftBracket: EnumItem,
    BackSlash: EnumItem,
    RightBracket: EnumItem,
    Caret: EnumItem,
    Underscore: EnumItem,
    Backquote: EnumItem,
    A: EnumItem,
    B: EnumItem,
    C: EnumItem,
    D: EnumItem,
    E: EnumItem,
    F: EnumItem,
    G: EnumItem,
    H: EnumItem,
    I: EnumItem,
    J: EnumItem,
    K: EnumItem,
    L: EnumItem,
    M: EnumItem,
    N: EnumItem,
    O: EnumItem,
    P: EnumItem,
    Q: EnumItem,
    R: EnumItem,
    S: EnumItem,
    T: EnumItem,
    U: EnumItem,
    V: EnumItem,
    W: EnumItem,
    X: EnumItem,
    Y: EnumItem,
    Z: EnumItem,
    LeftCurly: EnumItem,
    Pipe: EnumItem,
    RightCurly: EnumItem,
    Tilde: EnumItem,
    Delete: EnumItem,
    KeypadZero: EnumItem,
    KeypadOne: EnumItem,
    KeypadTwo: EnumItem,
    KeypadThree: EnumItem,
    KeypadFour: EnumItem,
    KeypadFive: EnumItem,
    KeypadSix: EnumItem,
    KeypadSeven: EnumItem,
    KeypadEight: EnumItem,
    KeypadNine: EnumItem,
    KeypadPeriod: EnumItem,
    KeypadDivide: EnumItem,
    KeypadMultiply: EnumItem,
    KeypadMinus: EnumItem,
    KeypadPlus: EnumItem,
    KeypadEnter: EnumItem,
    KeypadEquals: EnumItem,
    Up: EnumItem,
    Down: EnumItem,
    Right: EnumItem,
    Left: EnumItem,
    Insert: EnumItem,
    Home: EnumItem,
    End: EnumItem,
    PageUp: EnumItem,
    PageDown: EnumItem,
    F1: EnumItem,
    F2: EnumItem,
    F3: EnumItem,
    F4: EnumItem,
    F5: EnumItem,
    F6: EnumItem,
    F7: EnumItem,
    F8: EnumItem,
    F9: EnumItem,
    F10: EnumItem,
    F11: EnumItem,
    F12: EnumItem,
    F13: EnumItem,
    F14: EnumItem,
    F15: EnumItem,
    NumLock: EnumItem,
    CapsLock: EnumItem,
    ScrollLock: EnumItem,
    RightShift: EnumItem,
    LeftShift: EnumItem,
    RightControl: EnumItem,
    LeftControl: EnumItem,
    RightAlt: EnumItem,
    LeftAlt: EnumItem,
    RightMeta: EnumItem,
    LeftMeta: EnumItem,
    LeftSuper: EnumItem,
    RightSuper: EnumItem,
    Mode: EnumItem,
    Compose: EnumItem,
    Help: EnumItem,
    Print: EnumItem,
    SysReq: EnumItem,
    Break: EnumItem,
    Menu: EnumItem,
    Power: EnumItem,
    Euro: EnumItem,
    Undo: EnumItem,
    ButtonX: EnumItem,
    ButtonY: EnumItem,
    ButtonA: EnumItem,
    ButtonB: EnumItem,
    ButtonR1: EnumItem,
    ButtonL1: EnumItem,
    ButtonR2: EnumItem,
    ButtonL2: EnumItem,
    ButtonR3: EnumItem,
    ButtonL3: EnumItem,
    ButtonStart: EnumItem,
    ButtonSelect: EnumItem,
    DPadLeft: EnumItem,
    DPadRight: EnumItem,
    DPadUp: EnumItem,
    DPadDown: EnumItem,
    Thumbstick1: EnumItem,
    Thumbstick2: EnumItem,
    Thumbstick1Up: EnumItem,
    Thumbstick1Down: EnumItem,
    Thumbstick1Left: EnumItem,
    Thumbstick1Right: EnumItem,
    Thumbstick2Up: EnumItem,
    Thumbstick2Down: EnumItem,
    Thumbstick2Left: EnumItem,
    Thumbstick2Right: EnumItem,
    MouseLeftButton: EnumItem,
    MouseRightButton: EnumItem,
    MouseMiddleButton: EnumItem,
    MousePosition: EnumItem,
    Touch: EnumItem,
    MouseWheel: EnumItem,
    TrackpadPan: EnumItem,
    TrackpadPinch: EnumItem,
    World0: EnumItem,
    World1: EnumItem,
    World2: EnumItem,
    World3: EnumItem,
    World4: EnumItem,
    World5: EnumItem,
    World6: EnumItem,
    World7: EnumItem,
    World8: EnumItem,
    World9: EnumItem,
    World10: EnumItem,
    World11: EnumItem,
    World12: EnumItem,
    World13: EnumItem,
    World14: EnumItem,
    World15: EnumItem,
    World16: EnumItem,
    World17: EnumItem,
    World18: EnumItem,
    World19: EnumItem,
    World20: EnumItem,
    World21: EnumItem,
    World22: EnumItem,
    World23: EnumItem,
    World24: EnumItem,
    World25: EnumItem,
    World26: EnumItem,
    World27: EnumItem,
    World28: EnumItem,
    World29: EnumItem,
    World30: EnumItem,
    World31: EnumItem,
    World32: EnumItem,
    World33: EnumItem,
    World34: EnumItem,
    World35: EnumItem,
    World36: EnumItem,
    World37: EnumItem,
    World38: EnumItem,
    World39: EnumItem,
    World40: EnumItem,
    World41: EnumItem,
    World42: EnumItem,
    World43: EnumItem,
    World44: EnumItem,
    World45: EnumItem,
    World46: EnumItem,
    World47: EnumItem,
    World48: EnumItem,
    World49: EnumItem,
    World50: EnumItem,
    World51: EnumItem,
    World52: EnumItem,
    World53: EnumItem,
    World54: EnumItem,
    World55: EnumItem,
    World56: EnumItem,
    World57: EnumItem,
    World58: EnumItem,
    World59: EnumItem,
    World60: EnumItem,
    World61: EnumItem,
    World62: EnumItem,
    World63: EnumItem,
    World64: EnumItem,
    World65: EnumItem,
    World66: EnumItem,
    World67: EnumItem,
    World68: EnumItem,
    World69: EnumItem,
    World70: EnumItem,
    World71: EnumItem,
    World72: EnumItem,
    World73: EnumItem,
    World74: EnumItem,
    World75: EnumItem,
    World76: EnumItem,
    World77: EnumItem,
    World78: EnumItem,
    World79: EnumItem,
    World80: EnumItem,
    World81: EnumItem,
    World82: EnumItem,
    World83: EnumItem,
    World84: EnumItem,
    World85: EnumItem,
    World86: EnumItem,
    World87: EnumItem,
    World88: EnumItem,
    World89: EnumItem,
    World90: EnumItem,
    World91: EnumItem,
    World92: EnumItem,
    World93: EnumItem,
    World94: EnumItem,
    World95: EnumItem,
    MouseBackButton: EnumItem,
    MouseNoButton: EnumItem,
    MouseX: EnumItem,
    MouseY: EnumItem,
}
export type Enum_KeyInterpolationMode = Enum & {
    Constant: EnumItem,
    Linear: EnumItem,
    Cubic: EnumItem,
}
export type Enum_KeywordFilterType = Enum & {
    Include: EnumItem,
    Exclude: EnumItem,
}
export type Enum_Language = Enum & {
    Default: EnumItem,
}
export type Enum_LeftRight = Enum & {
    Left: EnumItem,
    Center: EnumItem,
    Right: EnumItem,
}
export type Enum_LexemeType = Enum & {
    Eof: EnumItem,
    Name: EnumItem,
    QuotedString: EnumItem,
    Number: EnumItem,
    And: EnumItem,
    Or: EnumItem,
    Equal: EnumItem,
    TildeEqual: EnumItem,
    GreaterThan: EnumItem,
    GreaterThanEqual: EnumItem,
    LessThan: EnumItem,
    LessThanEqual: EnumItem,
    Colon: EnumItem,
    Dot: EnumItem,
    LeftParenthesis: EnumItem,
    RightParenthesis: EnumItem,
    Star: EnumItem,
    DoubleStar: EnumItem,
    ReservedSpecial: EnumItem,
}
export type Enum_LightingStyle = Enum & {
    Realistic: EnumItem,
    Soft: EnumItem,
}
export type Enum_Limb = Enum & {
    Head: EnumItem,
    Torso: EnumItem,
    LeftArm: EnumItem,
    RightArm: EnumItem,
    LeftLeg: EnumItem,
    RightLeg: EnumItem,
    Unknown: EnumItem,
}
export type Enum_LineJoinMode = Enum & {
    Round: EnumItem,
    Bevel: EnumItem,
    Miter: EnumItem,
}
export type Enum_ListDisplayMode = Enum & {
    Horizontal: EnumItem,
    Vertical: EnumItem,
}
export type Enum_ListenerLocation = Enum & {
    Default: EnumItem,
    None: EnumItem,
    Character: EnumItem,
    Camera: EnumItem,
}
export type Enum_ListenerType = Enum & {
    Camera: EnumItem,
    CFrame: EnumItem,
    ObjectPosition: EnumItem,
    ObjectCFrame: EnumItem,
}
export type Enum_LiveEditingAtomicUpdateResponse = Enum & {
    Success: EnumItem,
    FailureGuidNotFound: EnumItem,
    FailureHashMismatch: EnumItem,
    FailureOperationIllegal: EnumItem,
}
export type Enum_LiveEditingBroadcastMessageType = Enum & {
    Normal: EnumItem,
    Warning: EnumItem,
    Error: EnumItem,
}
export type Enum_LoadCharacterLayeredClothing = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_LoadDynamicHeads = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_LocationType = Enum & {
    Character: EnumItem,
    Camera: EnumItem,
    ObjectPosition: EnumItem,
}
export type Enum_LuauTypeCheckMode = Enum & {
    Default: EnumItem,
    NoCheck: EnumItem,
    Nonstrict: EnumItem,
    Strict: EnumItem,
}
export type Enum_MakeupType = Enum & {
    Face: EnumItem,
    Lip: EnumItem,
    Eye: EnumItem,
}
export type Enum_MarketplaceBulkPurchasePromptStatus = Enum & {
    Completed: EnumItem,
    Aborted: EnumItem,
    Error: EnumItem,
}
export type Enum_MarketplaceItemPurchaseStatus = Enum & {
    Success: EnumItem,
    SystemError: EnumItem,
    AlreadyOwned: EnumItem,
    InsufficientRobux: EnumItem,
    QuantityLimitExceeded: EnumItem,
    QuotaExceeded: EnumItem,
    NotForSale: EnumItem,
    NotAvailableForPurchaser: EnumItem,
    PriceMismatch: EnumItem,
    SoldOut: EnumItem,
    PurchaserIsSeller: EnumItem,
    InsufficientMembership: EnumItem,
    PlaceInvalid: EnumItem,
}
export type Enum_MarketplaceProductType = Enum & {
    AvatarAsset: EnumItem,
    AvatarBundle: EnumItem,
}
export type Enum_MarkupKind = Enum & {
    PlainText: EnumItem,
    Markdown: EnumItem,
}
export type Enum_MatchmakingType = Enum & {
    Default: EnumItem,
    XboxOnly: EnumItem,
    PlayStationOnly: EnumItem,
}
export type Enum_Material = Enum & {
    Plastic: EnumItem,
    SmoothPlastic: EnumItem,
    Neon: EnumItem,
    Wood: EnumItem,
    WoodPlanks: EnumItem,
    Marble: EnumItem,
    Slate: EnumItem,
    Concrete: EnumItem,
    Granite: EnumItem,
    Brick: EnumItem,
    Pebble: EnumItem,
    Cobblestone: EnumItem,
    Rock: EnumItem,
    Sandstone: EnumItem,
    Basalt: EnumItem,
    CrackedLava: EnumItem,
    Limestone: EnumItem,
    Pavement: EnumItem,
    CorrodedMetal: EnumItem,
    DiamondPlate: EnumItem,
    Foil: EnumItem,
    Metal: EnumItem,
    Grass: EnumItem,
    LeafyGrass: EnumItem,
    Sand: EnumItem,
    Fabric: EnumItem,
    Snow: EnumItem,
    Mud: EnumItem,
    Ground: EnumItem,
    Asphalt: EnumItem,
    Salt: EnumItem,
    Ice: EnumItem,
    Glacier: EnumItem,
    Glass: EnumItem,
    ForceField: EnumItem,
    Air: EnumItem,
    Water: EnumItem,
    Cardboard: EnumItem,
    Carpet: EnumItem,
    CeramicTiles: EnumItem,
    ClayRoofTiles: EnumItem,
    RoofShingles: EnumItem,
    Leather: EnumItem,
    Plaster: EnumItem,
    Rubber: EnumItem,
}
export type Enum_MaterialPattern = Enum & {
    Regular: EnumItem,
    Organic: EnumItem,
}
export type Enum_MembershipType = Enum & {
    None: EnumItem,
    BuildersClub: EnumItem,
    TurboBuildersClub: EnumItem,
    OutrageousBuildersClub: EnumItem,
    Premium: EnumItem,
}
export type Enum_MeshPartDetailLevel = Enum & {
    DistanceBased: EnumItem,
    Level00: EnumItem,
    Level01: EnumItem,
    Level02: EnumItem,
    Level03: EnumItem,
    Level04: EnumItem,
}
export type Enum_MeshPartHeadsAndAccessories = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_MeshScaleUnit = Enum & {
    Stud: EnumItem,
    Meter: EnumItem,
    CM: EnumItem,
    MM: EnumItem,
    Foot: EnumItem,
    Inch: EnumItem,
}
export type Enum_MeshType = Enum & {
    Head: EnumItem,
    Torso: EnumItem,
    Wedge: EnumItem,
    Sphere: EnumItem,
    Cylinder: EnumItem,
    FileMesh: EnumItem,
    Brick: EnumItem,
    Prism: EnumItem,
    Pyramid: EnumItem,
    ParallelRamp: EnumItem,
    RightAngleRamp: EnumItem,
    CornerWedge: EnumItem,
}
export type Enum_MessageType = Enum & {
    MessageOutput: EnumItem,
    MessageInfo: EnumItem,
    MessageWarning: EnumItem,
    MessageError: EnumItem,
}
export type Enum_ModelLevelOfDetail = Enum & {
    Automatic: EnumItem,
    StreamingMesh: EnumItem,
    Disabled: EnumItem,
    SLIM: EnumItem,
}
export type Enum_ModelStreamingBehavior = Enum & {
    Default: EnumItem,
    Legacy: EnumItem,
    Improved: EnumItem,
}
export type Enum_ModelStreamingMode = Enum & {
    Default: EnumItem,
    Atomic: EnumItem,
    Persistent: EnumItem,
    PersistentPerPlayer: EnumItem,
    Nonatomic: EnumItem,
}
export type Enum_ModerationResultCategory = Enum & {
    ViolationDetected: EnumItem,
    Borderline: EnumItem,
    NoViolationDetected: EnumItem,
}
export type Enum_ModerationResultLabel = Enum & {
    ChildExploitation: EnumItem,
    SuicideSelfInjuryAndHarmfulBehavior: EnumItem,
    ThreatsBullyingAndHarassment: EnumItem,
    TerrorismAndViolentExtremism: EnumItem,
    DiscriminationSlursAndHateSpeech: EnumItem,
    RealWorldSensitiveEvents: EnumItem,
    ViolentContentAndGore: EnumItem,
    RomanticAndSexualContent: EnumItem,
    IllegalAndRegulatedGoodsAndActivities: EnumItem,
    Profanity: EnumItem,
    Other: EnumItem,
}
export type Enum_ModerationStatus = Enum & {
    ReviewedApproved: EnumItem,
    ReviewedRejected: EnumItem,
    NotReviewed: EnumItem,
    NotApplicable: EnumItem,
    Invalid: EnumItem,
}
export type Enum_ModifierKey = Enum & {
    Shift: EnumItem,
    Ctrl: EnumItem,
    Alt: EnumItem,
    Meta: EnumItem,
}
export type Enum_MouseBehavior = Enum & {
    Default: EnumItem,
    LockCenter: EnumItem,
    LockCurrentPosition: EnumItem,
}
export type Enum_MoveState = Enum & {
    Stopped: EnumItem,
    Coasting: EnumItem,
    Pushing: EnumItem,
    Stopping: EnumItem,
    AirFree: EnumItem,
}
export type Enum_MoverConstraintRootBehaviorMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_MuteState = Enum & {
    Unmuted: EnumItem,
    Muted: EnumItem,
}
export type Enum_NameOcclusion = Enum & {
    NoOcclusion: EnumItem,
    EnemyOcclusion: EnumItem,
    OccludeAll: EnumItem,
}
export type Enum_NegateOperationHiddenHistory = Enum & {
    None: EnumItem,
    NegatedUnion: EnumItem,
    NegatedIntersection: EnumItem,
}
export type Enum_NetworkOwnership = Enum & {
    Automatic: EnumItem,
    Manual: EnumItem,
    OnContact: EnumItem,
}
export type Enum_NetworkStatus = Enum & {
    Unknown: EnumItem,
    Connected: EnumItem,
    Disconnected: EnumItem,
}
export type Enum_NoiseType = Enum & {
    SimplexGabor: EnumItem,
}
export type Enum_NormalId = Enum & {
    Right: EnumItem,
    Top: EnumItem,
    Back: EnumItem,
    Left: EnumItem,
    Bottom: EnumItem,
    Front: EnumItem,
}
export type Enum_NotificationButtonType = Enum & {
    Primary: EnumItem,
    Secondary: EnumItem,
}
export type Enum_OperationType = Enum & {
    Null: EnumItem,
    Union: EnumItem,
    Subtraction: EnumItem,
    Intersection: EnumItem,
    Primitive: EnumItem,
}
export type Enum_OrientationAlignmentMode = Enum & {
    OneAttachment: EnumItem,
    TwoAttachment: EnumItem,
}
export type Enum_OutfitSource = Enum & {
    All: EnumItem,
    Created: EnumItem,
    Purchased: EnumItem,
}
export type Enum_OutfitType = Enum & {
    All: EnumItem,
    Avatar: EnumItem,
    DynamicHead: EnumItem,
    Shoes: EnumItem,
}
export type Enum_OutputLayoutMode = Enum & {
    Horizontal: EnumItem,
    Vertical: EnumItem,
}
export type Enum_OverrideMouseIconBehavior = Enum & {
    None: EnumItem,
    ForceShow: EnumItem,
    ForceHide: EnumItem,
}
export type Enum_PackagePermission = Enum & {
    None: EnumItem,
    NoAccess: EnumItem,
    Revoked: EnumItem,
    UseView: EnumItem,
    Edit: EnumItem,
    Own: EnumItem,
}
export type Enum_PartType = Enum & {
    Ball: EnumItem,
    Block: EnumItem,
    Cylinder: EnumItem,
    Wedge: EnumItem,
    CornerWedge: EnumItem,
}
export type Enum_ParticleEmitterShape = Enum & {
    Box: EnumItem,
    Sphere: EnumItem,
    Cylinder: EnumItem,
    Disc: EnumItem,
}
export type Enum_ParticleEmitterShapeInOut = Enum & {
    Outward: EnumItem,
    Inward: EnumItem,
    InAndOut: EnumItem,
}
export type Enum_ParticleEmitterShapeStyle = Enum & {
    Volume: EnumItem,
    Surface: EnumItem,
}
export type Enum_ParticleFlipbookLayout = Enum & {
    None: EnumItem,
    Grid2x2: EnumItem,
    Grid4x4: EnumItem,
    Grid8x8: EnumItem,
    Custom: EnumItem,
}
export type Enum_ParticleFlipbookMode = Enum & {
    Loop: EnumItem,
    OneShot: EnumItem,
    PingPong: EnumItem,
    Random: EnumItem,
}
export type Enum_ParticleFlipbookTextureCompatible = Enum & {
    NotCompatible: EnumItem,
    Compatible: EnumItem,
    Unknown: EnumItem,
}
export type Enum_ParticleOrientation = Enum & {
    FacingCamera: EnumItem,
    FacingCameraWorldUp: EnumItem,
    VelocityParallel: EnumItem,
    VelocityPerpendicular: EnumItem,
}
export type Enum_PathStatus = Enum & {
    Success: EnumItem,
    NoPath: EnumItem,
    ClosestNoPath: EnumItem,
    ClosestOutOfRange: EnumItem,
    FailStartNotEmpty: EnumItem,
    FailFinishNotEmpty: EnumItem,
}
export type Enum_PathWaypointAction = Enum & {
    Walk: EnumItem,
    Jump: EnumItem,
    Custom: EnumItem,
}
export type Enum_PathfindingUseImprovedSearch = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_PeoplePageLayout = Enum & {
    Card: EnumItem,
    List: EnumItem,
}
export type Enum_PerformanceOverlayMode = Enum & {
    Overdraw: EnumItem,
    Transparent: EnumItem,
    Decals: EnumItem,
    Lights: EnumItem,
}
export type Enum_PermissionLevelShown = Enum & {
    Game: EnumItem,
    RobloxGame: EnumItem,
    RobloxScript: EnumItem,
    Studio: EnumItem,
    Roblox: EnumItem,
}
export type Enum_PhysicsSimulationRate = Enum & {
    Fixed240Hz: EnumItem,
    Fixed120Hz: EnumItem,
    Fixed60Hz: EnumItem,
}
export type Enum_PhysicsSteppingMethod = Enum & {
    Default: EnumItem,
    Fixed: EnumItem,
    Adaptive: EnumItem,
}
export type Enum_PlaceContentPreference = Enum & {
    None: EnumItem,
    All: EnumItem,
    MentionsAndReplies: EnumItem,
    Unknown: EnumItem,
}
export type Enum_PlacePublishType = Enum & {
    None: EnumItem,
    Publish: EnumItem,
    Save: EnumItem,
}
export type Enum_Platform = Enum & {
    Windows: EnumItem,
    OSX: EnumItem,
    IOS: EnumItem,
    Android: EnumItem,
    XBoxOne: EnumItem,
    PS4: EnumItem,
    PS3: EnumItem,
    XBox360: EnumItem,
    WiiU: EnumItem,
    NX: EnumItem,
    Ouya: EnumItem,
    AndroidTV: EnumItem,
    Chromecast: EnumItem,
    Linux: EnumItem,
    SteamOS: EnumItem,
    WebOS: EnumItem,
    DOS: EnumItem,
    BeOS: EnumItem,
    UWP: EnumItem,
    PS5: EnumItem,
    MetaOS: EnumItem,
    Web: EnumItem,
    None: EnumItem,
}
export type Enum_PlaybackState = Enum & {
    Begin: EnumItem,
    Delayed: EnumItem,
    Playing: EnumItem,
    Paused: EnumItem,
    Completed: EnumItem,
    Cancelled: EnumItem,
}
export type Enum_PlayerActions = Enum & {
    CharacterForward: EnumItem,
    CharacterBackward: EnumItem,
    CharacterLeft: EnumItem,
    CharacterRight: EnumItem,
    CharacterJump: EnumItem,
}
export type Enum_PlayerCharacterDestroyBehavior = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_PlayerChatType = Enum & {
    All: EnumItem,
    Team: EnumItem,
    Whisper: EnumItem,
}
export type Enum_PlayerDataErrorState = Enum & {
    LoadFailed: EnumItem,
    FlushFailed: EnumItem,
    ReleaseFailed: EnumItem,
    None: EnumItem,
}
export type Enum_PlayerDataLoadFailureBehavior = Enum & {
    Failure: EnumItem,
    FallbackToDefault: EnumItem,
    Kick: EnumItem,
}
export type Enum_PlayerExitReason = Enum & {
    Unknown: EnumItem,
    PlatformKick: EnumItem,
    CreatorKick: EnumItem,
}
export type Enum_PoseEasingDirection = Enum & {
    In: EnumItem,
    Out: EnumItem,
    InOut: EnumItem,
}
export type Enum_PoseEasingStyle = Enum & {
    Linear: EnumItem,
    Constant: EnumItem,
    Elastic: EnumItem,
    Cubic: EnumItem,
    Bounce: EnumItem,
    CubicV2: EnumItem,
}
export type Enum_PositionAlignmentMode = Enum & {
    OneAttachment: EnumItem,
    TwoAttachment: EnumItem,
}
export type Enum_PredictionMode = Enum & {
    Automatic: EnumItem,
    On: EnumItem,
    Off: EnumItem,
}
export type Enum_PredictionStatus = Enum & {
    Authoritative: EnumItem,
    Predicted: EnumItem,
    None: EnumItem,
}
export type Enum_PreferredInput = Enum & {
    KeyboardAndMouse: EnumItem,
    Gamepad: EnumItem,
    Touch: EnumItem,
}
export type Enum_PreferredTextSize = Enum & {
    Medium: EnumItem,
    Large: EnumItem,
    Larger: EnumItem,
    Largest: EnumItem,
}
export type Enum_PrimalPhysicsSolver = Enum & {
    Default: EnumItem,
    Experimental: EnumItem,
    Disabled: EnumItem,
}
export type Enum_PrimitiveType = Enum & {
    Null: EnumItem,
    Ball: EnumItem,
    Cylinder: EnumItem,
    Block: EnumItem,
    Wedge: EnumItem,
    CornerWedge: EnumItem,
}
export type Enum_PrivilegeType = Enum & {
    Owner: EnumItem,
    Admin: EnumItem,
    Member: EnumItem,
    Visitor: EnumItem,
    Banned: EnumItem,
}
export type Enum_ProductLocationRestriction = Enum & {
    AvatarShop: EnumItem,
    AllowedGames: EnumItem,
    AllGames: EnumItem,
}
export type Enum_ProductPurchaseChannel = Enum & {
    InExperience: EnumItem,
    ExperienceDetailsPage: EnumItem,
    AdReward: EnumItem,
    CommerceProduct: EnumItem,
}
export type Enum_ProductPurchaseDecision = Enum & {
    NotProcessedYet: EnumItem,
    PurchaseGranted: EnumItem,
}
export type Enum_PromptCreateAssetResult = Enum & {
    Success: EnumItem,
    PermissionDenied: EnumItem,
    Timeout: EnumItem,
    UploadFailed: EnumItem,
    NoUserInput: EnumItem,
    UnknownFailure: EnumItem,
    UGCValidationFailed: EnumItem,
    ModeratedName: EnumItem,
    PurchaseFailure: EnumItem,
    TokenInvalid: EnumItem,
}
export type Enum_PromptCreateAvatarResult = Enum & {
    Success: EnumItem,
    PermissionDenied: EnumItem,
    Timeout: EnumItem,
    UploadFailed: EnumItem,
    NoUserInput: EnumItem,
    InvalidHumanoidDescription: EnumItem,
    UGCValidationFailed: EnumItem,
    ModeratedName: EnumItem,
    MaxOutfits: EnumItem,
    PurchaseFailure: EnumItem,
    UnknownFailure: EnumItem,
    TokenInvalid: EnumItem,
}
export type Enum_PromptExperienceDetailsResult = Enum & {
    PromptClosed: EnumItem,
    TeleportAttempted: EnumItem,
}
export type Enum_PromptLinkSharingResult = Enum & {
    Success: EnumItem,
    PlayerLeft: EnumItem,
    InvalidLaunchData: EnumItem,
}
export type Enum_PromptPublishAssetResult = Enum & {
    Success: EnumItem,
    PermissionDenied: EnumItem,
    Timeout: EnumItem,
    UploadFailed: EnumItem,
    NoUserInput: EnumItem,
    UnknownFailure: EnumItem,
}
export type Enum_PropertyStatus = Enum & {
    Ok: EnumItem,
    Warning: EnumItem,
    Error: EnumItem,
}
export type Enum_ProximityPromptExclusivity = Enum & {
    OnePerButton: EnumItem,
    OneGlobally: EnumItem,
    AlwaysShow: EnumItem,
}
export type Enum_ProximityPromptInputType = Enum & {
    Keyboard: EnumItem,
    Gamepad: EnumItem,
    Touch: EnumItem,
}
export type Enum_ProximityPromptStyle = Enum & {
    Default: EnumItem,
    Custom: EnumItem,
}
export type Enum_QualityLevel = Enum & {
    Automatic: EnumItem,
    Level01: EnumItem,
    Level02: EnumItem,
    Level03: EnumItem,
    Level04: EnumItem,
    Level05: EnumItem,
    Level06: EnumItem,
    Level07: EnumItem,
    Level08: EnumItem,
    Level09: EnumItem,
    Level10: EnumItem,
    Level11: EnumItem,
    Level12: EnumItem,
    Level13: EnumItem,
    Level14: EnumItem,
    Level15: EnumItem,
    Level16: EnumItem,
    Level17: EnumItem,
    Level18: EnumItem,
    Level19: EnumItem,
    Level20: EnumItem,
    Level21: EnumItem,
}
export type Enum_R15CollisionType = Enum & {
    OuterBox: EnumItem,
    InnerBox: EnumItem,
}
export type Enum_RaycastFilterType = Enum & {
    Exclude: EnumItem,
    Include: EnumItem,
}
export type Enum_ReadCapturesFromGalleryResult = Enum & {
    Success: EnumItem,
    NeedPermission: EnumItem,
}
export type Enum_RecommendationActionType = Enum & {
    AddReaction: EnumItem,
    RemoveReaction: EnumItem,
    Share: EnumItem,
    Report: EnumItem,
    Comment: EnumItem,
    Play: EnumItem,
    Purchase: EnumItem,
}
export type Enum_RecommendationDepartureIntent = Enum & {
    Neutral: EnumItem,
    Positive: EnumItem,
    Negative: EnumItem,
}
export type Enum_RecommendationImpressionType = Enum & {
    View: EnumItem,
    NotViewable: EnumItem,
}
export type Enum_RecommendationItemContentType = Enum & {
    Static: EnumItem,
    Dynamic: EnumItem,
    Interactive: EnumItem,
}
export type Enum_RecommendationItemVisibility = Enum & {
    Private: EnumItem,
    Public: EnumItem,
}
export type Enum_RejectCharacterDeletions = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_RenderFidelity = Enum & {
    Automatic: EnumItem,
    Precise: EnumItem,
    Performance: EnumItem,
}
export type Enum_RenderPriority = Enum & {
    First: EnumItem,
    Input: EnumItem,
    Camera: EnumItem,
    Character: EnumItem,
    Last: EnumItem,
}
export type Enum_RenderingCacheOptimizationMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_RenderingTestComparisonMethod = Enum & {
    psnr: EnumItem,
    diff: EnumItem,
}
export type Enum_ReplicateInstanceDestroySetting = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_ResamplerMode = Enum & {
    Default: EnumItem,
    Pixelated: EnumItem,
}
export type Enum_ReservedHighlightId = Enum & {
    Standard: EnumItem,
    Selection: EnumItem,
    Hover: EnumItem,
    Active: EnumItem,
    NegatedPart: EnumItem,
}
export type Enum_RestPose = Enum & {
    Default: EnumItem,
    RotationsReset: EnumItem,
    Custom: EnumItem,
}
export type Enum_RestPoseModel = Enum & {
    FromRigInACE: EnumItem,
    FromRigInFile: EnumItem,
}
export type Enum_ReturnKeyType = Enum & {
    Default: EnumItem,
    Done: EnumItem,
    Go: EnumItem,
    Next: EnumItem,
    Search: EnumItem,
    Send: EnumItem,
}
export type Enum_ReverbType = Enum & {
    NoReverb: EnumItem,
    GenericReverb: EnumItem,
    PaddedCell: EnumItem,
    Room: EnumItem,
    Bathroom: EnumItem,
    LivingRoom: EnumItem,
    StoneRoom: EnumItem,
    Auditorium: EnumItem,
    ConcertHall: EnumItem,
    Cave: EnumItem,
    Arena: EnumItem,
    Hangar: EnumItem,
    CarpettedHallway: EnumItem,
    Hallway: EnumItem,
    StoneCorridor: EnumItem,
    Alley: EnumItem,
    Forest: EnumItem,
    City: EnumItem,
    Mountains: EnumItem,
    Quarry: EnumItem,
    Plain: EnumItem,
    ParkingLot: EnumItem,
    SewerPipe: EnumItem,
    UnderWater: EnumItem,
}
export type Enum_ReviewableContentState = Enum & {
    Pending: EnumItem,
    Completed: EnumItem,
    Failed: EnumItem,
}
export type Enum_RibbonTool = Enum & {
    Select: EnumItem,
    Scale: EnumItem,
    Rotate: EnumItem,
    Move: EnumItem,
    Transform: EnumItem,
    ColorPicker: EnumItem,
    MaterialPicker: EnumItem,
    Group: EnumItem,
    Ungroup: EnumItem,
    None: EnumItem,
    PivotEditor: EnumItem,
}
export type Enum_RigLabel = Enum & {
    Invalid: EnumItem,
    Root: EnumItem,
    Pelvis: EnumItem,
    Waist: EnumItem,
    Chest: EnumItem,
    Neck: EnumItem,
    HeadBase: EnumItem,
    LeftClavicle: EnumItem,
    LeftShoulder: EnumItem,
    LeftElbow: EnumItem,
    LeftWrist: EnumItem,
    RightClavicle: EnumItem,
    RightShoulder: EnumItem,
    RightElbow: EnumItem,
    RightWrist: EnumItem,
    LeftHip: EnumItem,
    LeftKnee: EnumItem,
    LeftAnkle: EnumItem,
    LeftToes: EnumItem,
    RightHip: EnumItem,
    RightKnee: EnumItem,
    RightAnkle: EnumItem,
    RightToes: EnumItem,
}
export type Enum_RigScale = Enum & {
    Default: EnumItem,
    Rthro: EnumItem,
    RthroNarrow: EnumItem,
}
export type Enum_RigType = Enum & {
    R15: EnumItem,
    CustomHumanoid: EnumItem,
    Custom: EnumItem,
    None: EnumItem,
}
export type Enum_RollOffMode = Enum & {
    Inverse: EnumItem,
    Linear: EnumItem,
    LinearSquare: EnumItem,
    InverseTapered: EnumItem,
}
export type Enum_RolloutState = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_RotationOrder = Enum & {
    XYZ: EnumItem,
    XZY: EnumItem,
    YZX: EnumItem,
    YXZ: EnumItem,
    ZXY: EnumItem,
    ZYX: EnumItem,
}
export type Enum_RotationType = Enum & {
    MovementRelative: EnumItem,
    CameraRelative: EnumItem,
}
export type Enum_RsvpStatus = Enum & {
    None: EnumItem,
    Going: EnumItem,
    NotGoing: EnumItem,
}
export type Enum_RtlTextSupport = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_RunContext = Enum & {
    Legacy: EnumItem,
    Server: EnumItem,
    Client: EnumItem,
    Plugin: EnumItem,
}
export type Enum_RunState = Enum & {
    Stopped: EnumItem,
    Running: EnumItem,
    Paused: EnumItem,
}
export type Enum_RuntimeUndoBehavior = Enum & {
    Aggregate: EnumItem,
    Snapshot: EnumItem,
    Hybrid: EnumItem,
}
export type Enum_SafeAreaCompatibility = Enum & {
    None: EnumItem,
    FullscreenExtension: EnumItem,
}
export type Enum_SalesTypeFilter = Enum & {
    All: EnumItem,
    Collectibles: EnumItem,
    Premium: EnumItem,
    TimedOptions: EnumItem,
}
export type Enum_SandboxedInstanceMode = Enum & {
    Default: EnumItem,
    Experimental: EnumItem,
}
export type Enum_SaveAvatarThumbnailCustomizationFailure = Enum & {
    BadThumbnailType: EnumItem,
    BadYRotDeg: EnumItem,
    BadFieldOfViewDeg: EnumItem,
    BadDistanceScale: EnumItem,
    Other: EnumItem,
    Throttled: EnumItem,
}
export type Enum_SaveFilter = Enum & {
    SaveWorld: EnumItem,
    SaveGame: EnumItem,
    SaveAll: EnumItem,
}
export type Enum_SavedQualitySetting = Enum & {
    Automatic: EnumItem,
    QualityLevel1: EnumItem,
    QualityLevel2: EnumItem,
    QualityLevel3: EnumItem,
    QualityLevel4: EnumItem,
    QualityLevel5: EnumItem,
    QualityLevel6: EnumItem,
    QualityLevel7: EnumItem,
    QualityLevel8: EnumItem,
    QualityLevel9: EnumItem,
    QualityLevel10: EnumItem,
}
export type Enum_ScaleType = Enum & {
    Stretch: EnumItem,
    Slice: EnumItem,
    Tile: EnumItem,
    Fit: EnumItem,
    Crop: EnumItem,
}
export type Enum_ScopeCheckResult = Enum & {
    ConsentAccepted: EnumItem,
    InvalidScopes: EnumItem,
    Timeout: EnumItem,
    NoUserInput: EnumItem,
    BackendError: EnumItem,
    UnexpectedError: EnumItem,
    InvalidArgument: EnumItem,
    ConsentDenied: EnumItem,
}
export type Enum_ScreenInsets = Enum & {
    None: EnumItem,
    DeviceSafeInsets: EnumItem,
    CoreUISafeInsets: EnumItem,
    TopbarSafeInsets: EnumItem,
}
export type Enum_ScreenOrientation = Enum & {
    LandscapeLeft: EnumItem,
    LandscapeRight: EnumItem,
    LandscapeSensor: EnumItem,
    Portrait: EnumItem,
    Sensor: EnumItem,
}
export type Enum_ScreenshotCaptureResult = Enum & {
    Success: EnumItem,
    OtherError: EnumItem,
    NoDeviceSupport: EnumItem,
    NoSpaceOnDevice: EnumItem,
}
export type Enum_ScrollBarInset = Enum & {
    None: EnumItem,
    ScrollBar: EnumItem,
    Always: EnumItem,
}
export type Enum_ScrollingDirection = Enum & {
    X: EnumItem,
    Y: EnumItem,
    XY: EnumItem,
}
export type Enum_SecurityCapability = Enum & {
    RunClientScript: EnumItem,
    RunServerScript: EnumItem,
    AccessOutsideWrite: EnumItem,
    AssetRequire: EnumItem,
    LoadString: EnumItem,
    ScriptGlobals: EnumItem,
    CreateInstances: EnumItem,
    Basic: EnumItem,
    Audio: EnumItem,
    DataStore: EnumItem,
    Network: EnumItem,
    Physics: EnumItem,
    UI: EnumItem,
    CSG: EnumItem,
    Chat: EnumItem,
    Animation: EnumItem,
    Avatar: EnumItem,
    Input: EnumItem,
    Environment: EnumItem,
    RemoteEvent: EnumItem,
    LegacySound: EnumItem,
    Players: EnumItem,
    CapabilityControl: EnumItem,
    Plugin: EnumItem,
    LocalUser: EnumItem,
    WritePlayer: EnumItem,
    RobloxScript: EnumItem,
    RobloxEngine: EnumItem,
    Unassigned: EnumItem,
    InternalTest: EnumItem,
    PluginOrOpenCloud: EnumItem,
    Assistant: EnumItem,
    RemoteCommand: EnumItem,
    AssetRead: EnumItem,
    AssetManagement: EnumItem,
    DynamicGeneration: EnumItem,
    PlatformAvatarEditing: EnumItem,
    AssetCreateUpdate: EnumItem,
    Capture: EnumItem,
    SensitiveInput: EnumItem,
    Monetization: EnumItem,
    LoadOwnedAsset: EnumItem,
    Social: EnumItem,
    ServerCommunication: EnumItem,
    Logging: EnumItem,
    PromptExternalPurchase: EnumItem,
    Groups: EnumItem,
    Teleport: EnumItem,
    Consequences: EnumItem,
    Material: EnumItem,
    AvatarBehavior: EnumItem,
}
export type Enum_SelectionBehavior = Enum & {
    Escape: EnumItem,
    Stop: EnumItem,
}
export type Enum_SelectionRenderMode = Enum & {
    Outlines: EnumItem,
    BoundingBoxes: EnumItem,
    Both: EnumItem,
}
export type Enum_SelfViewPosition = Enum & {
    LastPosition: EnumItem,
    TopLeft: EnumItem,
    TopRight: EnumItem,
    BottomLeft: EnumItem,
    BottomRight: EnumItem,
}
export type Enum_SensorMode = Enum & {
    Floor: EnumItem,
    Ladder: EnumItem,
}
export type Enum_SensorUpdateType = Enum & {
    OnRead: EnumItem,
    Manual: EnumItem,
}
export type Enum_ServerLiveEditingMode = Enum & {
    Uninitialized: EnumItem,
    Enabled: EnumItem,
    Disabled: EnumItem,
}
export type Enum_ServiceVisibility = Enum & {
    Always: EnumItem,
    Off: EnumItem,
    WithChildren: EnumItem,
}
export type Enum_Severity = Enum & {
    Error: EnumItem,
    Warning: EnumItem,
    Information: EnumItem,
    Hint: EnumItem,
}
export type Enum_ShowAdResult = Enum & {
    ShowCompleted: EnumItem,
    AdNotReady: EnumItem,
    AdAlreadyShowing: EnumItem,
    InternalError: EnumItem,
    ShowInterrupted: EnumItem,
    InsufficientMemory: EnumItem,
}
export type Enum_SignalBehavior = Enum & {
    Default: EnumItem,
    Immediate: EnumItem,
    Deferred: EnumItem,
    AncestryDeferred: EnumItem,
}
export type Enum_SizeConstraint = Enum & {
    RelativeXY: EnumItem,
    RelativeXX: EnumItem,
    RelativeYY: EnumItem,
}
export type Enum_SolverConvergenceMetricType = Enum & {
    IterationBased: EnumItem,
    AlgorithmAgnostic: EnumItem,
}
export type Enum_SolverConvergenceVisualizationMode = Enum & {
    Disabled: EnumItem,
    PerIsland: EnumItem,
    PerEdge: EnumItem,
}
export type Enum_SortDirection = Enum & {
    Ascending: EnumItem,
    Descending: EnumItem,
}
export type Enum_SortOrder = Enum & {
    Name: EnumItem,
    Custom: EnumItem,
    LayoutOrder: EnumItem,
}
export type Enum_SpecialKey = Enum & {
    Insert: EnumItem,
    Home: EnumItem,
    End: EnumItem,
    PageUp: EnumItem,
    PageDown: EnumItem,
    ChatHotkey: EnumItem,
}
export type Enum_StartCorner = Enum & {
    TopLeft: EnumItem,
    TopRight: EnumItem,
    BottomLeft: EnumItem,
    BottomRight: EnumItem,
}
export type Enum_StateObjectFieldType = Enum & {
    Boolean: EnumItem,
    CFrame: EnumItem,
    Color3: EnumItem,
    Float: EnumItem,
    Instance: EnumItem,
    Random: EnumItem,
    Vector2: EnumItem,
    Vector3: EnumItem,
    INVALID: EnumItem,
}
export type Enum_Status = Enum & {
    Poison: EnumItem,
    Confusion: EnumItem,
}
export type Enum_StepFrequency = Enum & {
    Hz60: EnumItem,
    Hz30: EnumItem,
    Hz15: EnumItem,
    Hz10: EnumItem,
    Hz5: EnumItem,
    Hz1: EnumItem,
}
export type Enum_StreamOutBehavior = Enum & {
    Default: EnumItem,
    LowMemory: EnumItem,
    Opportunistic: EnumItem,
}
export type Enum_StreamingIntegrityMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    MinimumRadiusPause: EnumItem,
    PauseOutsideLoadedArea: EnumItem,
}
export type Enum_StreamingPauseMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    ClientPhysicsPause: EnumItem,
}
export type Enum_StrokeSizingMode = Enum & {
    FixedSize: EnumItem,
    ScaledSize: EnumItem,
}
export type Enum_StudioCloseMode = Enum & {
    None: EnumItem,
    CloseStudio: EnumItem,
    CloseDoc: EnumItem,
    LogOut: EnumItem,
}
export type Enum_StudioDataModelType = Enum & {
    Edit: EnumItem,
    PlayClient: EnumItem,
    PlayServer: EnumItem,
    Standalone: EnumItem,
    None: EnumItem,
}
export type Enum_StudioPlaceUpdateFailureReason = Enum & {
    Other: EnumItem,
    TeamCreateConflict: EnumItem,
}
export type Enum_StudioScriptEditorColorCategories = Enum & {
    Default: EnumItem,
    Operator: EnumItem,
    Number: EnumItem,
    String: EnumItem,
    Comment: EnumItem,
    Keyword: EnumItem,
    Builtin: EnumItem,
    Method: EnumItem,
    Property: EnumItem,
    Nil: EnumItem,
    Bool: EnumItem,
    Function: EnumItem,
    Local: EnumItem,
    Self: EnumItem,
    LuauKeyword: EnumItem,
    FunctionName: EnumItem,
    TODO: EnumItem,
    Background: EnumItem,
    SelectionText: EnumItem,
    SelectionBackground: EnumItem,
    FindSelectionBackground: EnumItem,
    MatchingWordBackground: EnumItem,
    Warning: EnumItem,
    Error: EnumItem,
    Info: EnumItem,
    Hint: EnumItem,
    Whitespace: EnumItem,
    ActiveLine: EnumItem,
    DebuggerCurrentLine: EnumItem,
    DebuggerErrorLine: EnumItem,
    Ruler: EnumItem,
    Bracket: EnumItem,
    Type: EnumItem,
    MenuPrimaryText: EnumItem,
    MenuSecondaryText: EnumItem,
    MenuSelectedText: EnumItem,
    MenuBackground: EnumItem,
    MenuSelectedBackground: EnumItem,
    MenuScrollbarBackground: EnumItem,
    MenuScrollbarHandle: EnumItem,
    MenuBorder: EnumItem,
    DocViewCodeBackground: EnumItem,
    AICOOverlayText: EnumItem,
    AICOOverlayButtonBackground: EnumItem,
    AICOOverlayButtonBackgroundHover: EnumItem,
    AICOOverlayButtonBackgroundPressed: EnumItem,
    IndentationRuler: EnumItem,
}
export type Enum_StudioScriptEditorColorPresets = Enum & {
    RobloxDefault: EnumItem,
    Extra1: EnumItem,
    Extra2: EnumItem,
    Custom: EnumItem,
}
export type Enum_StudioStyleGuideColor = Enum & {
    MainBackground: EnumItem,
    Titlebar: EnumItem,
    Dropdown: EnumItem,
    Tooltip: EnumItem,
    Notification: EnumItem,
    ScrollBar: EnumItem,
    ScrollBarBackground: EnumItem,
    TabBar: EnumItem,
    Tab: EnumItem,
    FilterButtonDefault: EnumItem,
    FilterButtonHover: EnumItem,
    FilterButtonChecked: EnumItem,
    FilterButtonAccent: EnumItem,
    FilterButtonBorder: EnumItem,
    FilterButtonBorderAlt: EnumItem,
    RibbonTab: EnumItem,
    RibbonTabTopBar: EnumItem,
    Button: EnumItem,
    MainButton: EnumItem,
    RibbonButton: EnumItem,
    ViewPortBackground: EnumItem,
    InputFieldBackground: EnumItem,
    Item: EnumItem,
    TableItem: EnumItem,
    CategoryItem: EnumItem,
    GameSettingsTableItem: EnumItem,
    GameSettingsTooltip: EnumItem,
    EmulatorBar: EnumItem,
    EmulatorDropDown: EnumItem,
    ColorPickerFrame: EnumItem,
    CurrentMarker: EnumItem,
    Border: EnumItem,
    DropShadow: EnumItem,
    Shadow: EnumItem,
    Light: EnumItem,
    Dark: EnumItem,
    Mid: EnumItem,
    MainText: EnumItem,
    SubText: EnumItem,
    TitlebarText: EnumItem,
    BrightText: EnumItem,
    DimmedText: EnumItem,
    LinkText: EnumItem,
    WarningText: EnumItem,
    ErrorText: EnumItem,
    InfoText: EnumItem,
    SensitiveText: EnumItem,
    ScriptSideWidget: EnumItem,
    ScriptBackground: EnumItem,
    ScriptText: EnumItem,
    ScriptSelectionText: EnumItem,
    ScriptSelectionBackground: EnumItem,
    ScriptFindSelectionBackground: EnumItem,
    ScriptMatchingWordSelectionBackground: EnumItem,
    ScriptOperator: EnumItem,
    ScriptNumber: EnumItem,
    ScriptString: EnumItem,
    ScriptComment: EnumItem,
    ScriptKeyword: EnumItem,
    ScriptBuiltInFunction: EnumItem,
    ScriptWarning: EnumItem,
    ScriptError: EnumItem,
    ScriptInformation: EnumItem,
    ScriptHint: EnumItem,
    ScriptWhitespace: EnumItem,
    ScriptRuler: EnumItem,
    DocViewCodeBackground: EnumItem,
    DebuggerCurrentLine: EnumItem,
    DebuggerErrorLine: EnumItem,
    DiffFilePathText: EnumItem,
    DiffTextHunkInfo: EnumItem,
    DiffTextNoChange: EnumItem,
    DiffTextAddition: EnumItem,
    DiffTextDeletion: EnumItem,
    DiffTextSeparatorBackground: EnumItem,
    DiffTextNoChangeBackground: EnumItem,
    DiffTextAdditionBackground: EnumItem,
    DiffTextDeletionBackground: EnumItem,
    DiffLineNum: EnumItem,
    DiffLineNumSeparatorBackground: EnumItem,
    DiffLineNumNoChangeBackground: EnumItem,
    DiffLineNumAdditionBackground: EnumItem,
    DiffLineNumDeletionBackground: EnumItem,
    DiffFilePathBackground: EnumItem,
    DiffFilePathBorder: EnumItem,
    ChatIncomingBgColor: EnumItem,
    ChatIncomingTextColor: EnumItem,
    ChatOutgoingBgColor: EnumItem,
    ChatOutgoingTextColor: EnumItem,
    ChatModeratedMessageColor: EnumItem,
    Separator: EnumItem,
    ButtonBorder: EnumItem,
    ButtonText: EnumItem,
    InputFieldBorder: EnumItem,
    CheckedFieldBackground: EnumItem,
    CheckedFieldBorder: EnumItem,
    CheckedFieldIndicator: EnumItem,
    HeaderSection: EnumItem,
    Midlight: EnumItem,
    StatusBar: EnumItem,
    DialogButton: EnumItem,
    DialogButtonText: EnumItem,
    DialogButtonBorder: EnumItem,
    DialogMainButton: EnumItem,
    DialogMainButtonText: EnumItem,
    InfoBarWarningBackground: EnumItem,
    InfoBarWarningText: EnumItem,
    ScriptEditorCurrentLine: EnumItem,
    ScriptMethod: EnumItem,
    ScriptProperty: EnumItem,
    ScriptNil: EnumItem,
    ScriptBool: EnumItem,
    ScriptFunction: EnumItem,
    ScriptLocal: EnumItem,
    ScriptSelf: EnumItem,
    ScriptLuauKeyword: EnumItem,
    ScriptFunctionName: EnumItem,
    ScriptTodo: EnumItem,
    ScriptBracket: EnumItem,
    AttributeCog: EnumItem,
    AICOOverlayText: EnumItem,
    AICOOverlayButtonBackground: EnumItem,
    AICOOverlayButtonBackgroundHover: EnumItem,
    AICOOverlayButtonBackgroundPressed: EnumItem,
    OnboardingCover: EnumItem,
    OnboardingHighlight: EnumItem,
    OnboardingShadow: EnumItem,
    BreakpointMarker: EnumItem,
    DiffLineNumHover: EnumItem,
    DiffLineNumSeparatorBackgroundHover: EnumItem,
}
export type Enum_StudioStyleGuideModifier = Enum & {
    Default: EnumItem,
    Selected: EnumItem,
    Pressed: EnumItem,
    Disabled: EnumItem,
    Hover: EnumItem,
}
export type Enum_Style = Enum & {
    AlternatingSupports: EnumItem,
    BridgeStyleSupports: EnumItem,
    NoSupports: EnumItem,
}
export type Enum_SubscriptionExpirationReason = Enum & {
    ProductInactive: EnumItem,
    ProductDeleted: EnumItem,
    SubscriberCancelled: EnumItem,
    SubscriberRefunded: EnumItem,
    Lapsed: EnumItem,
}
export type Enum_SubscriptionPaymentStatus = Enum & {
    Paid: EnumItem,
    Refunded: EnumItem,
}
export type Enum_SubscriptionPeriod = Enum & {
    Month: EnumItem,
}
export type Enum_SubscriptionState = Enum & {
    NeverSubscribed: EnumItem,
    SubscribedWillRenew: EnumItem,
    SubscribedWillNotRenew: EnumItem,
    SubscribedRenewalPaymentPending: EnumItem,
    Expired: EnumItem,
}
export type Enum_SurfaceConstraint = Enum & {
    None: EnumItem,
    Hinge: EnumItem,
    SteppingMotor: EnumItem,
    Motor: EnumItem,
}
export type Enum_SurfaceGuiShape = Enum & {
    Flat: EnumItem,
    CurvedHorizontally: EnumItem,
}
export type Enum_SurfaceGuiSizingMode = Enum & {
    FixedSize: EnumItem,
    PixelsPerStud: EnumItem,
}
export type Enum_SurfaceType = Enum & {
    Smooth: EnumItem,
    Glue: EnumItem,
    Weld: EnumItem,
    Studs: EnumItem,
    Inlet: EnumItem,
    Universal: EnumItem,
    Hinge: EnumItem,
    Motor: EnumItem,
    SteppingMotor: EnumItem,
    SmoothNoOutlines: EnumItem,
}
export type Enum_SwipeDirection = Enum & {
    Right: EnumItem,
    Left: EnumItem,
    Up: EnumItem,
    Down: EnumItem,
    None: EnumItem,
}
export type Enum_SystemThemeValue = Enum & {
    error: EnumItem,
    light: EnumItem,
    dark: EnumItem,
    systemLight: EnumItem,
    systemDark: EnumItem,
}
export type Enum_TableMajorAxis = Enum & {
    RowMajor: EnumItem,
    ColumnMajor: EnumItem,
}
export type Enum_TeamCreateErrorState = Enum & {
    PlaceSizeTooLarge: EnumItem,
    PlaceSizeApproachingLimit: EnumItem,
    PlaceUploadFailing: EnumItem,
    NoError: EnumItem,
}
export type Enum_Technology = Enum & {
    Voxel: EnumItem,
    Compatibility: EnumItem,
    ShadowMap: EnumItem,
    Future: EnumItem,
    Legacy: EnumItem,
    Unified: EnumItem,
}
export type Enum_TelemetryBackend = Enum & {
    UNSPECIFIED: EnumItem,
    EventIngest: EnumItem,
    Points: EnumItem,
    Teletune: EnumItem,
    EphemeralCounter: EnumItem,
    EphemeralStat: EnumItem,
    Counter: EnumItem,
    Stat: EnumItem,
}
export type Enum_TelemetryStandardizedField = Enum & {
    AddDatacenterId: EnumItem,
    AddPlaceId: EnumItem,
    AddUniverseId: EnumItem,
    AddPlaceInstanceId: EnumItem,
    AddPlaySessionId: EnumItem,
    AddCurrentContextName: EnumItem,
    AddOsInfo: EnumItem,
    AddArchitectureInfo: EnumItem,
    AddCpuInfo: EnumItem,
    AddMemoryInfo: EnumItem,
    AddSessionInfo: EnumItem,
}
export type Enum_TeleportMethod = Enum & {
    TeleportToSpawnByName: EnumItem,
    TeleportToPlaceInstance: EnumItem,
    TeleportToPrivateServer: EnumItem,
    TeleportPartyAsync: EnumItem,
    TeleportToVIPServer: EnumItem,
    TeleportToInstanceBack: EnumItem,
    TeleportUnknown: EnumItem,
}
export type Enum_TeleportResult = Enum & {
    Success: EnumItem,
    Failure: EnumItem,
    GameNotFound: EnumItem,
    GameEnded: EnumItem,
    GameFull: EnumItem,
    Unauthorized: EnumItem,
    Flooded: EnumItem,
    IsTeleporting: EnumItem,
}
export type Enum_TeleportState = Enum & {
    RequestedFromServer: EnumItem,
    Started: EnumItem,
    WaitingForServer: EnumItem,
    Failed: EnumItem,
    InProgress: EnumItem,
}
export type Enum_TeleportType = Enum & {
    ToPlace: EnumItem,
    ToInstance: EnumItem,
    ToReservedServer: EnumItem,
    ToVIPServer: EnumItem,
    ToInstanceBack: EnumItem,
}
export type Enum_TerrainAcquisitionMethod = Enum & {
    None: EnumItem,
    Legacy: EnumItem,
    Template: EnumItem,
    Generate: EnumItem,
    Import: EnumItem,
    Convert: EnumItem,
    EditAddTool: EnumItem,
    EditSeaLevelTool: EnumItem,
    EditReplaceTool: EnumItem,
    RegionFillTool: EnumItem,
    RegionPasteTool: EnumItem,
    Other: EnumItem,
}
export type Enum_TerrainFace = Enum & {
    Top: EnumItem,
    Side: EnumItem,
    Bottom: EnumItem,
}
export type Enum_TextChatMessageStatus = Enum & {
    Unknown: EnumItem,
    Success: EnumItem,
    Sending: EnumItem,
    TextFilterFailed: EnumItem,
    Floodchecked: EnumItem,
    InvalidPrivacySettings: EnumItem,
    InvalidTextChannelPermissions: EnumItem,
    MessageTooLong: EnumItem,
    ModerationTimeout: EnumItem,
}
export type Enum_TextDirection = Enum & {
    Auto: EnumItem,
    LeftToRight: EnumItem,
    RightToLeft: EnumItem,
}
export type Enum_TextFilterContext = Enum & {
    PublicChat: EnumItem,
    PrivateChat: EnumItem,
}
export type Enum_TextInputType = Enum & {
    Default: EnumItem,
    NoSuggestions: EnumItem,
    Number: EnumItem,
    Email: EnumItem,
    Phone: EnumItem,
    Password: EnumItem,
    PasswordShown: EnumItem,
    Username: EnumItem,
    OneTimePassword: EnumItem,
    NewPassword: EnumItem,
    NewPasswordShown: EnumItem,
}
export type Enum_TextTruncate = Enum & {
    None: EnumItem,
    AtEnd: EnumItem,
    SplitWord: EnumItem,
}
export type Enum_TextXAlignment = Enum & {
    Left: EnumItem,
    Right: EnumItem,
    Center: EnumItem,
}
export type Enum_TextYAlignment = Enum & {
    Top: EnumItem,
    Center: EnumItem,
    Bottom: EnumItem,
}
export type Enum_TextureMode = Enum & {
    Stretch: EnumItem,
    Wrap: EnumItem,
    Static: EnumItem,
}
export type Enum_TextureQueryType = Enum & {
    NonHumanoid: EnumItem,
    NonHumanoidOrphaned: EnumItem,
    Humanoid: EnumItem,
    HumanoidOrphaned: EnumItem,
}
export type Enum_ThreadPoolConfig = Enum & {
    PerCore4: EnumItem,
    PerCore3: EnumItem,
    PerCore2: EnumItem,
    PerCore1: EnumItem,
    Auto: EnumItem,
    Threads1: EnumItem,
    Threads2: EnumItem,
    Threads3: EnumItem,
    Threads4: EnumItem,
    Threads8: EnumItem,
    Threads16: EnumItem,
}
export type Enum_ThrottlingPriority = Enum & {
    Extreme: EnumItem,
    ElevatedOnServer: EnumItem,
    Default: EnumItem,
}
export type Enum_ThumbnailSize = Enum & {
    Size48x48: EnumItem,
    Size180x180: EnumItem,
    Size420x420: EnumItem,
    Size60x60: EnumItem,
    Size100x100: EnumItem,
    Size150x150: EnumItem,
    Size352x352: EnumItem,
}
export type Enum_ThumbnailType = Enum & {
    HeadShot: EnumItem,
    AvatarBust: EnumItem,
    AvatarThumbnail: EnumItem,
}
export type Enum_TickCountSampleMethod = Enum & {
    Fast: EnumItem,
    Benchmark: EnumItem,
    Precise: EnumItem,
}
export type Enum_TonemapperPreset = Enum & {
    Default: EnumItem,
    Retro: EnumItem,
}
export type Enum_TopBottom = Enum & {
    Top: EnumItem,
    Center: EnumItem,
    Bottom: EnumItem,
}
export type Enum_TouchCameraMovementMode = Enum & {
    Default: EnumItem,
    Classic: EnumItem,
    Follow: EnumItem,
    Orbital: EnumItem,
}
export type Enum_TouchMovementMode = Enum & {
    Default: EnumItem,
    Thumbstick: EnumItem,
    DPad: EnumItem,
    Thumbpad: EnumItem,
    ClickToMove: EnumItem,
    DynamicThumbstick: EnumItem,
}
export type Enum_TrackerError = Enum & {
    Ok: EnumItem,
    NoService: EnumItem,
    InitFailed: EnumItem,
    NoVideo: EnumItem,
    VideoError: EnumItem,
    VideoNoPermission: EnumItem,
    VideoUnsupported: EnumItem,
    NoAudio: EnumItem,
    AudioError: EnumItem,
    AudioNoPermission: EnumItem,
    UnsupportedDevice: EnumItem,
}
export type Enum_TrackerExtrapolationFlagMode = Enum & {
    Auto: EnumItem,
    ForceDisabled: EnumItem,
    ExtrapolateFacsAndPose: EnumItem,
    ExtrapolateFacsOnly: EnumItem,
}
export type Enum_TrackerFaceTrackingStatus = Enum & {
    FaceTrackingSuccess: EnumItem,
    FaceTrackingNoFaceFound: EnumItem,
    FaceTrackingUnknown: EnumItem,
    FaceTrackingLost: EnumItem,
    FaceTrackingHasTrackingError: EnumItem,
    FaceTrackingIsOccluded: EnumItem,
    FaceTrackingUninitialized: EnumItem,
}
export type Enum_TrackerLodFlagMode = Enum & {
    Auto: EnumItem,
    ForceFalse: EnumItem,
    ForceTrue: EnumItem,
}
export type Enum_TrackerLodValueMode = Enum & {
    Auto: EnumItem,
    Force0: EnumItem,
    Force1: EnumItem,
}
export type Enum_TrackerMode = Enum & {
    None: EnumItem,
    Audio: EnumItem,
    Video: EnumItem,
    AudioVideo: EnumItem,
}
export type Enum_TrackerPromptEvent = Enum & {
    LODCameraRecommendDisable: EnumItem,
}
export type Enum_TrackerType = Enum & {
    None: EnumItem,
    Face: EnumItem,
    UpperBody: EnumItem,
}
export type Enum_TriStateBoolean = Enum & {
    False: EnumItem,
    True: EnumItem,
    Unknown: EnumItem,
}
export type Enum_TweenStatus = Enum & {
    Canceled: EnumItem,
    Completed: EnumItem,
}
export type Enum_UICaptureMode = Enum & {
    All: EnumItem,
    None: EnumItem,
}
export type Enum_UIDragDetectorBoundingBehavior = Enum & {
    Automatic: EnumItem,
    EntireObject: EnumItem,
    HitPoint: EnumItem,
}
export type Enum_UIDragDetectorDragRelativity = Enum & {
    Absolute: EnumItem,
    Relative: EnumItem,
}
export type Enum_UIDragDetectorDragSpace = Enum & {
    Parent: EnumItem,
    LayerCollector: EnumItem,
    Reference: EnumItem,
}
export type Enum_UIDragDetectorDragStyle = Enum & {
    TranslatePlane: EnumItem,
    TranslateLine: EnumItem,
    Rotate: EnumItem,
    Scriptable: EnumItem,
}
export type Enum_UIDragDetectorResponseStyle = Enum & {
    Offset: EnumItem,
    Scale: EnumItem,
    CustomOffset: EnumItem,
    CustomScale: EnumItem,
}
export type Enum_UIDragSpeedAxisMapping = Enum & {
    XY: EnumItem,
    XX: EnumItem,
    YY: EnumItem,
}
export type Enum_UIFlexAlignment = Enum & {
    None: EnumItem,
    Fill: EnumItem,
    SpaceAround: EnumItem,
    SpaceBetween: EnumItem,
    SpaceEvenly: EnumItem,
}
export type Enum_UIFlexMode = Enum & {
    None: EnumItem,
    Grow: EnumItem,
    Shrink: EnumItem,
    Fill: EnumItem,
    Custom: EnumItem,
}
export type Enum_UITheme = Enum & {
    Light: EnumItem,
    Dark: EnumItem,
}
export type Enum_UiMessageType = Enum & {
    UiMessageError: EnumItem,
    UiMessageInfo: EnumItem,
}
export type Enum_UpdateState = Enum & {
    UpdateNotAvailable: EnumItem,
    UpdateAvailable: EnumItem,
    UpdateInProgress: EnumItem,
    UpdateReady: EnumItem,
    UpdateFailed: EnumItem,
}
export type Enum_UploadCaptureResult = Enum & {
    Success: EnumItem,
    NeedPermission: EnumItem,
    CaptureModerated: EnumItem,
    CaptureNotInGallery: EnumItem,
    IneligibleCapture: EnumItem,
    UploadQuotaReached: EnumItem,
}
export type Enum_UsageContext = Enum & {
    Default: EnumItem,
    Preview: EnumItem,
}
export type Enum_UserCFrame = Enum & {
    Head: EnumItem,
    LeftHand: EnumItem,
    RightHand: EnumItem,
    Floor: EnumItem,
}
export type Enum_UserInputState = Enum & {
    Begin: EnumItem,
    Change: EnumItem,
    End: EnumItem,
    Cancel: EnumItem,
    None: EnumItem,
}
export type Enum_UserInputType = Enum & {
    MouseButton1: EnumItem,
    MouseButton2: EnumItem,
    MouseButton3: EnumItem,
    MouseWheel: EnumItem,
    MouseMovement: EnumItem,
    Touch: EnumItem,
    Keyboard: EnumItem,
    Focus: EnumItem,
    Accelerometer: EnumItem,
    Gyro: EnumItem,
    Gamepad1: EnumItem,
    Gamepad2: EnumItem,
    Gamepad3: EnumItem,
    Gamepad4: EnumItem,
    Gamepad5: EnumItem,
    Gamepad6: EnumItem,
    Gamepad7: EnumItem,
    Gamepad8: EnumItem,
    TextInput: EnumItem,
    InputMethod: EnumItem,
    None: EnumItem,
}
export type Enum_VRComfortSetting = Enum & {
    Comfort: EnumItem,
    Normal: EnumItem,
    Expert: EnumItem,
    Custom: EnumItem,
}
export type Enum_VRControllerModelMode = Enum & {
    Disabled: EnumItem,
    Transparent: EnumItem,
}
export type Enum_VRDeviceType = Enum & {
    Unknown: EnumItem,
    OculusRift: EnumItem,
    HTCVive: EnumItem,
    ValveIndex: EnumItem,
    OculusQuest: EnumItem,
}
export type Enum_VRLaserPointerMode = Enum & {
    Disabled: EnumItem,
    Pointer: EnumItem,
    DualPointer: EnumItem,
}
export type Enum_VRSafetyBubbleMode = Enum & {
    NoOne: EnumItem,
    OnlyFriends: EnumItem,
    Anyone: EnumItem,
}
export type Enum_VRScaling = Enum & {
    World: EnumItem,
    Off: EnumItem,
}
export type Enum_VRSessionState = Enum & {
    Undefined: EnumItem,
    Idle: EnumItem,
    Visible: EnumItem,
    Focused: EnumItem,
    Stopping: EnumItem,
}
export type Enum_VRTouchpad = Enum & {
    Left: EnumItem,
    Right: EnumItem,
}
export type Enum_VRTouchpadMode = Enum & {
    Touch: EnumItem,
    VirtualThumbstick: EnumItem,
    ABXY: EnumItem,
}
export type Enum_VelocityConstraintMode = Enum & {
    Line: EnumItem,
    Plane: EnumItem,
    Vector: EnumItem,
}
export type Enum_VerticalAlignment = Enum & {
    Center: EnumItem,
    Top: EnumItem,
    Bottom: EnumItem,
}
export type Enum_VerticalScrollBarPosition = Enum & {
    Right: EnumItem,
    Left: EnumItem,
}
export type Enum_VibrationMotor = Enum & {
    Large: EnumItem,
    Small: EnumItem,
    LeftTrigger: EnumItem,
    RightTrigger: EnumItem,
    LeftHand: EnumItem,
    RightHand: EnumItem,
}
export type Enum_VideoCaptureResult = Enum & {
    Success: EnumItem,
    OtherError: EnumItem,
    ScreenSizeChanged: EnumItem,
    TimeLimitReached: EnumItem,
}
export type Enum_VideoCaptureStartedResult = Enum & {
    Success: EnumItem,
    OtherError: EnumItem,
    CapturingAlready: EnumItem,
    NoDeviceSupport: EnumItem,
    NoSpaceOnDevice: EnumItem,
}
export type Enum_VideoDeviceCaptureQuality = Enum & {
    Default: EnumItem,
    Low: EnumItem,
    Medium: EnumItem,
    High: EnumItem,
}
export type Enum_VideoError = Enum & {
    Ok: EnumItem,
    Eof: EnumItem,
    EAgain: EnumItem,
    BadParameter: EnumItem,
    AllocFailed: EnumItem,
    CodecInitFailed: EnumItem,
    CodecCloseFailed: EnumItem,
    DecodeFailed: EnumItem,
    ParsingFailed: EnumItem,
    Unsupported: EnumItem,
    Generic: EnumItem,
    DownloadFailed: EnumItem,
    StreamNotFound: EnumItem,
    EncodeFailed: EnumItem,
    CreateFailed: EnumItem,
    NoPermission: EnumItem,
    NoService: EnumItem,
    ReleaseFailed: EnumItem,
    Unknown: EnumItem,
}
export type Enum_VideoSampleSize = Enum & {
    Small: EnumItem,
    Medium: EnumItem,
    Large: EnumItem,
    Full: EnumItem,
}
export type Enum_ViewMode = Enum & {
    None: EnumItem,
    GeometryComplexity: EnumItem,
    Transparent: EnumItem,
    Decal: EnumItem,
}
export type Enum_VirtualCursorMode = Enum & {
    Default: EnumItem,
    Disabled: EnumItem,
    Enabled: EnumItem,
}
export type Enum_VirtualInputMode = Enum & {
    None: EnumItem,
    Recording: EnumItem,
    Playing: EnumItem,
}
export type Enum_VoiceChatDistanceAttenuationType = Enum & {
    Inverse: EnumItem,
    Legacy: EnumItem,
}
export type Enum_VoiceChatState = Enum & {
    Idle: EnumItem,
    Joining: EnumItem,
    JoiningRetry: EnumItem,
    Joined: EnumItem,
    Leaving: EnumItem,
    Ended: EnumItem,
    Failed: EnumItem,
}
export type Enum_VoiceClientLeaveReasons = Enum & {
    Unknown: EnumItem,
    ClientNetworkDisconnected: EnumItem,
    PlayerLeft: EnumItem,
    ClientShutdown: EnumItem,
    PublishFailed: EnumItem,
    RejoinReceived: EnumItem,
    VoiceReboot: EnumItem,
    ImguiDebugLeave: EnumItem,
    LuaInitiated: EnumItem,
}
export type Enum_VoiceControlPath = Enum & {
    Publish: EnumItem,
    Subscribe: EnumItem,
    Join: EnumItem,
}
export type Enum_VolumetricAudio = Enum & {
    Disabled: EnumItem,
    Automatic: EnumItem,
    Enabled: EnumItem,
}
export type Enum_WaterDirection = Enum & {
    NegX: EnumItem,
    X: EnumItem,
    NegY: EnumItem,
    Y: EnumItem,
    NegZ: EnumItem,
    Z: EnumItem,
}
export type Enum_WaterForce = Enum & {
    None: EnumItem,
    Small: EnumItem,
    Medium: EnumItem,
    Strong: EnumItem,
    Max: EnumItem,
}
export type Enum_WebSocketState = Enum & {
    Connecting: EnumItem,
    Open: EnumItem,
    Closing: EnumItem,
    Closed: EnumItem,
}
export type Enum_WebStreamClientState = Enum & {
    Connecting: EnumItem,
    Open: EnumItem,
    Error: EnumItem,
    Closed: EnumItem,
}
export type Enum_WebStreamClientType = Enum & {
    SSE: EnumItem,
    RawStream: EnumItem,
    WebSocket: EnumItem,
}
export type Enum_WeldConstraintPreserve = Enum & {
    All: EnumItem,
    None: EnumItem,
    Touching: EnumItem,
}
export type Enum_WhisperChatPrivacyMode = Enum & {
    AllUsers: EnumItem,
    NoOne: EnumItem,
}
export type Enum_WrapLayerAutoSkin = Enum & {
    Disabled: EnumItem,
    EnabledPreserve: EnumItem,
    EnabledOverride: EnumItem,
}
export type Enum_WrapLayerDebugMode = Enum & {
    None: EnumItem,
    BoundCage: EnumItem,
    LayerCage: EnumItem,
    BoundCageAndLinks: EnumItem,
    Reference: EnumItem,
    Rbf: EnumItem,
    OuterCage: EnumItem,
    ReferenceMeshAfterMorph: EnumItem,
    HSROuterDetail: EnumItem,
    HSROuter: EnumItem,
    HSRInner: EnumItem,
    HSRInnerReverse: EnumItem,
    LayerCageFittedToBase: EnumItem,
    LayerCageFittedToPrev: EnumItem,
    PreWrapDeformerOuterCage: EnumItem,
}
export type Enum_WrapTargetDebugMode = Enum & {
    None: EnumItem,
    TargetCageOriginal: EnumItem,
    TargetCageCompressed: EnumItem,
    TargetCageInterface: EnumItem,
    TargetLayerCageOriginal: EnumItem,
    TargetLayerCageCompressed: EnumItem,
    TargetLayerInterface: EnumItem,
    Rbf: EnumItem,
    OuterCageDetail: EnumItem,
    PreWrapDeformerCage: EnumItem,
}
export type Enum_ZIndexBehavior = Enum & {
    Global: EnumItem,
    Sibling: EnumItem,
}
export type Enums = {
    AccessModifierType: Enum_AccessModifierType,
    AccessoryType: Enum_AccessoryType,
    ActionOnAutoResumeSync: Enum_ActionOnAutoResumeSync,
    ActionOnStopSync: Enum_ActionOnStopSync,
    ActionType: Enum_ActionType,
    ActuatorRelativeTo: Enum_ActuatorRelativeTo,
    ActuatorType: Enum_ActuatorType,
    AdAvailabilityResult: Enum_AdAvailabilityResult,
    AdEventType: Enum_AdEventType,
    AdFormat: Enum_AdFormat,
    AdShape: Enum_AdShape,
    AdTeleportMethod: Enum_AdTeleportMethod,
    AdUIEventType: Enum_AdUIEventType,
    AdUIType: Enum_AdUIType,
    AdUnitStatus: Enum_AdUnitStatus,
    AdornCullingMode: Enum_AdornCullingMode,
    AdornShading: Enum_AdornShading,
    AlignType: Enum_AlignType,
    AlphaMode: Enum_AlphaMode,
    AnalyticsCustomFieldKeys: Enum_AnalyticsCustomFieldKeys,
    AnalyticsEconomyAction: Enum_AnalyticsEconomyAction,
    AnalyticsEconomyFlowType: Enum_AnalyticsEconomyFlowType,
    AnalyticsEconomyTransactionType: Enum_AnalyticsEconomyTransactionType,
    AnalyticsLogLevel: Enum_AnalyticsLogLevel,
    AnalyticsProgressionStatus: Enum_AnalyticsProgressionStatus,
    AnalyticsProgressionType: Enum_AnalyticsProgressionType,
    AnimationClipFromVideoStatus: Enum_AnimationClipFromVideoStatus,
    AnimationNodeBlend2DInputMode: Enum_AnimationNodeBlend2DInputMode,
    AnimationNodeInterruptible: Enum_AnimationNodeInterruptible,
    AnimationNodePlayMode: Enum_AnimationNodePlayMode,
    AnimationNodeTransitionType: Enum_AnimationNodeTransitionType,
    AnimationNodeType: Enum_AnimationNodeType,
    AnimationNodeWaitFor: Enum_AnimationNodeWaitFor,
    AnimationPriority: Enum_AnimationPriority,
    AnimatorRetargetingMode: Enum_AnimatorRetargetingMode,
    AnnotationChannelContentPreference: Enum_AnnotationChannelContentPreference,
    AnnotationEditingMode: Enum_AnnotationEditingMode,
    AnnotationPlaceContentPreference: Enum_AnnotationPlaceContentPreference,
    AnnotationRequestStatus: Enum_AnnotationRequestStatus,
    AnnotationRequestType: Enum_AnnotationRequestType,
    AppLifecycleManagerState: Enum_AppLifecycleManagerState,
    AppShellActionType: Enum_AppShellActionType,
    AppShellFeature: Enum_AppShellFeature,
    AppUpdateStatus: Enum_AppUpdateStatus,
    ApplyStrokeMode: Enum_ApplyStrokeMode,
    AspectType: Enum_AspectType,
    AssetCreatorType: Enum_AssetCreatorType,
    AssetFetchStatus: Enum_AssetFetchStatus,
    AssetType: Enum_AssetType,
    AssetTypeVerification: Enum_AssetTypeVerification,
    AudioApiRollout: Enum_AudioApiRollout,
    AudioCaptureMode: Enum_AudioCaptureMode,
    AudioChannelLayout: Enum_AudioChannelLayout,
    AudioFilterType: Enum_AudioFilterType,
    AudioSimulationFidelity: Enum_AudioSimulationFidelity,
    AudioSubType: Enum_AudioSubType,
    AudioWindowSize: Enum_AudioWindowSize,
    AuthorityMode: Enum_AuthorityMode,
    AutoIndentRule: Enum_AutoIndentRule,
    AutomaticSize: Enum_AutomaticSize,
    AvatarAssetType: Enum_AvatarAssetType,
    AvatarChatServiceFeature: Enum_AvatarChatServiceFeature,
    AvatarContextMenuOption: Enum_AvatarContextMenuOption,
    AvatarGenerationError: Enum_AvatarGenerationError,
    AvatarItemType: Enum_AvatarItemType,
    AvatarPromptResult: Enum_AvatarPromptResult,
    AvatarSettingsAccessoryLimitMethod: Enum_AvatarSettingsAccessoryLimitMethod,
    AvatarSettingsAccessoryMode: Enum_AvatarSettingsAccessoryMode,
    AvatarSettingsAnimationClipsMode: Enum_AvatarSettingsAnimationClipsMode,
    AvatarSettingsAnimationPacksMode: Enum_AvatarSettingsAnimationPacksMode,
    AvatarSettingsAppearanceMode: Enum_AvatarSettingsAppearanceMode,
    AvatarSettingsBuildMode: Enum_AvatarSettingsBuildMode,
    AvatarSettingsClothingMode: Enum_AvatarSettingsClothingMode,
    AvatarSettingsCollisionMode: Enum_AvatarSettingsCollisionMode,
    AvatarSettingsCustomAccessoryMode: Enum_AvatarSettingsCustomAccessoryMode,
    AvatarSettingsCustomBodyType: Enum_AvatarSettingsCustomBodyType,
    AvatarSettingsCustomClothingMode: Enum_AvatarSettingsCustomClothingMode,
    AvatarSettingsHitAndTouchDetectionMode: Enum_AvatarSettingsHitAndTouchDetectionMode,
    AvatarSettingsJumpMode: Enum_AvatarSettingsJumpMode,
    AvatarSettingsLegacyCollisionMode: Enum_AvatarSettingsLegacyCollisionMode,
    AvatarSettingsScaleMode: Enum_AvatarSettingsScaleMode,
    AvatarThumbnailCustomizationType: Enum_AvatarThumbnailCustomizationType,
    AvatarUnificationMode: Enum_AvatarUnificationMode,
    Axis: Enum_Axis,
    BenefitType: Enum_BenefitType,
    BinType: Enum_BinType,
    BodyPart: Enum_BodyPart,
    BodyPartR15: Enum_BodyPartR15,
    BorderMode: Enum_BorderMode,
    BorderStrokePosition: Enum_BorderStrokePosition,
    BreakReason: Enum_BreakReason,
    BreakpointRemoveReason: Enum_BreakpointRemoveReason,
    BulkMoveMode: Enum_BulkMoveMode,
    BundleType: Enum_BundleType,
    Button: Enum_Button,
    ButtonStyle: Enum_ButtonStyle,
    CageType: Enum_CageType,
    CameraMode: Enum_CameraMode,
    CameraPanMode: Enum_CameraPanMode,
    CameraSpeedAdjustBinding: Enum_CameraSpeedAdjustBinding,
    CameraType: Enum_CameraType,
    CaptureGalleryPermission: Enum_CaptureGalleryPermission,
    CaptureType: Enum_CaptureType,
    CatalogCategoryFilter: Enum_CatalogCategoryFilter,
    CatalogSortAggregation: Enum_CatalogSortAggregation,
    CatalogSortType: Enum_CatalogSortType,
    CellBlock: Enum_CellBlock,
    CellMaterial: Enum_CellMaterial,
    CellOrientation: Enum_CellOrientation,
    CenterDialogType: Enum_CenterDialogType,
    CharacterControlMode: Enum_CharacterControlMode,
    ChatCallbackType: Enum_ChatCallbackType,
    ChatColor: Enum_ChatColor,
    ChatMode: Enum_ChatMode,
    ChatPrivacyMode: Enum_ChatPrivacyMode,
    ChatRestrictionStatus: Enum_ChatRestrictionStatus,
    ChatStyle: Enum_ChatStyle,
    ChatVersion: Enum_ChatVersion,
    ClientAnimatorThrottlingMode: Enum_ClientAnimatorThrottlingMode,
    CloseReason: Enum_CloseReason,
    CollaboratorStatus: Enum_CollaboratorStatus,
    CollisionFidelity: Enum_CollisionFidelity,
    CommandPermission: Enum_CommandPermission,
    CompileTarget: Enum_CompileTarget,
    CompletionAcceptanceBehavior: Enum_CompletionAcceptanceBehavior,
    CompletionItemKind: Enum_CompletionItemKind,
    CompletionItemTag: Enum_CompletionItemTag,
    CompletionTriggerKind: Enum_CompletionTriggerKind,
    CompositeValueCurveType: Enum_CompositeValueCurveType,
    CompressionAlgorithm: Enum_CompressionAlgorithm,
    ComputerCameraMovementMode: Enum_ComputerCameraMovementMode,
    ComputerMovementMode: Enum_ComputerMovementMode,
    ConfigSnapshotErrorState: Enum_ConfigSnapshotErrorState,
    ConnectionError: Enum_ConnectionError,
    ConnectionState: Enum_ConnectionState,
    ContentSourceType: Enum_ContentSourceType,
    ContextActionPriority: Enum_ContextActionPriority,
    ContextActionResult: Enum_ContextActionResult,
    ControlMode: Enum_ControlMode,
    CoreGuiType: Enum_CoreGuiType,
    CreateAssetResult: Enum_CreateAssetResult,
    CreateOutfitFailure: Enum_CreateOutfitFailure,
    CreatorType: Enum_CreatorType,
    CreatorTypeFilter: Enum_CreatorTypeFilter,
    CurrencyType: Enum_CurrencyType,
    CustomCameraMode: Enum_CustomCameraMode,
    DataModelExtractorFileType: Enum_DataModelExtractorFileType,
    DataStoreRequestType: Enum_DataStoreRequestType,
    DebuggerEndReason: Enum_DebuggerEndReason,
    DebuggerExceptionBreakMode: Enum_DebuggerExceptionBreakMode,
    DebuggerFrameType: Enum_DebuggerFrameType,
    DebuggerPauseReason: Enum_DebuggerPauseReason,
    DebuggerStatus: Enum_DebuggerStatus,
    DefaultScriptSyncFileType: Enum_DefaultScriptSyncFileType,
    DevCameraOcclusionMode: Enum_DevCameraOcclusionMode,
    DevComputerCameraMovementMode: Enum_DevComputerCameraMovementMode,
    DevComputerMovementMode: Enum_DevComputerMovementMode,
    DevTouchCameraMovementMode: Enum_DevTouchCameraMovementMode,
    DevTouchMovementMode: Enum_DevTouchMovementMode,
    DeveloperMemoryTag: Enum_DeveloperMemoryTag,
    DeviceFeatureType: Enum_DeviceFeatureType,
    DeviceForm: Enum_DeviceForm,
    DeviceLevel: Enum_DeviceLevel,
    DeviceType: Enum_DeviceType,
    DialogBehaviorType: Enum_DialogBehaviorType,
    DialogPurpose: Enum_DialogPurpose,
    DialogTone: Enum_DialogTone,
    DisplayScalingMode: Enum_DisplayScalingMode,
    DisplaySize: Enum_DisplaySize,
    DominantAxis: Enum_DominantAxis,
    DraftStatusCode: Enum_DraftStatusCode,
    DragDetectorDragStyle: Enum_DragDetectorDragStyle,
    DragDetectorPermissionPolicy: Enum_DragDetectorPermissionPolicy,
    DragDetectorResponseStyle: Enum_DragDetectorResponseStyle,
    DraggerCoordinateSpace: Enum_DraggerCoordinateSpace,
    DraggerMovementMode: Enum_DraggerMovementMode,
    DraggingScrollBar: Enum_DraggingScrollBar,
    EasingDirection: Enum_EasingDirection,
    EasingStyle: Enum_EasingStyle,
    EditableStatus: Enum_EditableStatus,
    ElasticBehavior: Enum_ElasticBehavior,
    EngineFolder: Enum_EngineFolder,
    EnviromentalPhysicsThrottle: Enum_EnviromentalPhysicsThrottle,
    ExperienceAuthScope: Enum_ExperienceAuthScope,
    ExperienceEventStatus: Enum_ExperienceEventStatus,
    ExperienceStateCaptureSelectionMode: Enum_ExperienceStateCaptureSelectionMode,
    ExperienceStateRecordingLoadMode: Enum_ExperienceStateRecordingLoadMode,
    ExperienceStateRecordingLoadSourceType: Enum_ExperienceStateRecordingLoadSourceType,
    ExperienceStateRecordingPlaybackMode: Enum_ExperienceStateRecordingPlaybackMode,
    ExplosionType: Enum_ExplosionType,
    FACSDataLod: Enum_FACSDataLod,
    FacialAgeEstimationResultType: Enum_FacialAgeEstimationResultType,
    FacialAnimationStreamingState: Enum_FacialAnimationStreamingState,
    FacsActionUnit: Enum_FacsActionUnit,
    FeatureRestrictionAbuseVector: Enum_FeatureRestrictionAbuseVector,
    FieldOfViewMode: Enum_FieldOfViewMode,
    FillDirection: Enum_FillDirection,
    FilterErrorType: Enum_FilterErrorType,
    FilterResult: Enum_FilterResult,
    FilterType: Enum_FilterType,
    FinishRecordingOperation: Enum_FinishRecordingOperation,
    FluidFidelity: Enum_FluidFidelity,
    FluidForces: Enum_FluidForces,
    Font: Enum_Font,
    FontSize: Enum_FontSize,
    FontStyle: Enum_FontStyle,
    FontWeight: Enum_FontWeight,
    ForceLimitMode: Enum_ForceLimitMode,
    FormFactor: Enum_FormFactor,
    FrameStyle: Enum_FrameStyle,
    FramerateManagerMode: Enum_FramerateManagerMode,
    FriendRequestEvent: Enum_FriendRequestEvent,
    FriendStatus: Enum_FriendStatus,
    FunctionalTestResult: Enum_FunctionalTestResult,
    GameAvatarType: Enum_GameAvatarType,
    GamepadType: Enum_GamepadType,
    GearGenreSetting: Enum_GearGenreSetting,
    GearType: Enum_GearType,
    Genre: Enum_Genre,
    GraphicsMode: Enum_GraphicsMode,
    GraphicsOptimizationMode: Enum_GraphicsOptimizationMode,
    GroupMembershipStatus: Enum_GroupMembershipStatus,
    GuiState: Enum_GuiState,
    GuiType: Enum_GuiType,
    HandRigDescriptionSide: Enum_HandRigDescriptionSide,
    HandlesStyle: Enum_HandlesStyle,
    HapticEffectType: Enum_HapticEffectType,
    HashAlgorithm: Enum_HashAlgorithm,
    HighlightDepthMode: Enum_HighlightDepthMode,
    HorizontalAlignment: Enum_HorizontalAlignment,
    HoverAnimateSpeed: Enum_HoverAnimateSpeed,
    HttpCachePolicy: Enum_HttpCachePolicy,
    HttpCompression: Enum_HttpCompression,
    HttpContentType: Enum_HttpContentType,
    HttpError: Enum_HttpError,
    HttpRequestType: Enum_HttpRequestType,
    HumanoidCollisionType: Enum_HumanoidCollisionType,
    HumanoidDisplayDistanceType: Enum_HumanoidDisplayDistanceType,
    HumanoidHealthDisplayType: Enum_HumanoidHealthDisplayType,
    HumanoidRigType: Enum_HumanoidRigType,
    HumanoidStateType: Enum_HumanoidStateType,
    IKCollisionsMode: Enum_IKCollisionsMode,
    IKControlConstraintSupport: Enum_IKControlConstraintSupport,
    IKControlType: Enum_IKControlType,
    IXPLoadingStatus: Enum_IXPLoadingStatus,
    ImageAlphaType: Enum_ImageAlphaType,
    ImageCombineType: Enum_ImageCombineType,
    InOut: Enum_InOut,
    InfoType: Enum_InfoType,
    InitialDockState: Enum_InitialDockState,
    InputActionType: Enum_InputActionType,
    InputType: Enum_InputType,
    InstanceFileSyncStatus: Enum_InstanceFileSyncStatus,
    IntermediateMeshGenerationResult: Enum_IntermediateMeshGenerationResult,
    InterpolationThrottlingMode: Enum_InterpolationThrottlingMode,
    InviteState: Enum_InviteState,
    ItemLineAlignment: Enum_ItemLineAlignment,
    JoinSource: Enum_JoinSource,
    JointCreationMode: Enum_JointCreationMode,
    KeyCode: Enum_KeyCode,
    KeyInterpolationMode: Enum_KeyInterpolationMode,
    KeywordFilterType: Enum_KeywordFilterType,
    Language: Enum_Language,
    LeftRight: Enum_LeftRight,
    LexemeType: Enum_LexemeType,
    LightingStyle: Enum_LightingStyle,
    Limb: Enum_Limb,
    LineJoinMode: Enum_LineJoinMode,
    ListDisplayMode: Enum_ListDisplayMode,
    ListenerLocation: Enum_ListenerLocation,
    ListenerType: Enum_ListenerType,
    LiveEditingAtomicUpdateResponse: Enum_LiveEditingAtomicUpdateResponse,
    LiveEditingBroadcastMessageType: Enum_LiveEditingBroadcastMessageType,
    LoadCharacterLayeredClothing: Enum_LoadCharacterLayeredClothing,
    LoadDynamicHeads: Enum_LoadDynamicHeads,
    LocationType: Enum_LocationType,
    LuauTypeCheckMode: Enum_LuauTypeCheckMode,
    MakeupType: Enum_MakeupType,
    MarketplaceBulkPurchasePromptStatus: Enum_MarketplaceBulkPurchasePromptStatus,
    MarketplaceItemPurchaseStatus: Enum_MarketplaceItemPurchaseStatus,
    MarketplaceProductType: Enum_MarketplaceProductType,
    MarkupKind: Enum_MarkupKind,
    MatchmakingType: Enum_MatchmakingType,
    Material: Enum_Material,
    MaterialPattern: Enum_MaterialPattern,
    MembershipType: Enum_MembershipType,
    MeshPartDetailLevel: Enum_MeshPartDetailLevel,
    MeshPartHeadsAndAccessories: Enum_MeshPartHeadsAndAccessories,
    MeshScaleUnit: Enum_MeshScaleUnit,
    MeshType: Enum_MeshType,
    MessageType: Enum_MessageType,
    ModelLevelOfDetail: Enum_ModelLevelOfDetail,
    ModelStreamingBehavior: Enum_ModelStreamingBehavior,
    ModelStreamingMode: Enum_ModelStreamingMode,
    ModerationResultCategory: Enum_ModerationResultCategory,
    ModerationResultLabel: Enum_ModerationResultLabel,
    ModerationStatus: Enum_ModerationStatus,
    ModifierKey: Enum_ModifierKey,
    MouseBehavior: Enum_MouseBehavior,
    MoveState: Enum_MoveState,
    MoverConstraintRootBehaviorMode: Enum_MoverConstraintRootBehaviorMode,
    MuteState: Enum_MuteState,
    NameOcclusion: Enum_NameOcclusion,
    NegateOperationHiddenHistory: Enum_NegateOperationHiddenHistory,
    NetworkOwnership: Enum_NetworkOwnership,
    NetworkStatus: Enum_NetworkStatus,
    NoiseType: Enum_NoiseType,
    NormalId: Enum_NormalId,
    NotificationButtonType: Enum_NotificationButtonType,
    OperationType: Enum_OperationType,
    OrientationAlignmentMode: Enum_OrientationAlignmentMode,
    OutfitSource: Enum_OutfitSource,
    OutfitType: Enum_OutfitType,
    OutputLayoutMode: Enum_OutputLayoutMode,
    OverrideMouseIconBehavior: Enum_OverrideMouseIconBehavior,
    PackagePermission: Enum_PackagePermission,
    PartType: Enum_PartType,
    ParticleEmitterShape: Enum_ParticleEmitterShape,
    ParticleEmitterShapeInOut: Enum_ParticleEmitterShapeInOut,
    ParticleEmitterShapeStyle: Enum_ParticleEmitterShapeStyle,
    ParticleFlipbookLayout: Enum_ParticleFlipbookLayout,
    ParticleFlipbookMode: Enum_ParticleFlipbookMode,
    ParticleFlipbookTextureCompatible: Enum_ParticleFlipbookTextureCompatible,
    ParticleOrientation: Enum_ParticleOrientation,
    PathStatus: Enum_PathStatus,
    PathWaypointAction: Enum_PathWaypointAction,
    PathfindingUseImprovedSearch: Enum_PathfindingUseImprovedSearch,
    PeoplePageLayout: Enum_PeoplePageLayout,
    PerformanceOverlayMode: Enum_PerformanceOverlayMode,
    PermissionLevelShown: Enum_PermissionLevelShown,
    PhysicsSimulationRate: Enum_PhysicsSimulationRate,
    PhysicsSteppingMethod: Enum_PhysicsSteppingMethod,
    PlaceContentPreference: Enum_PlaceContentPreference,
    PlacePublishType: Enum_PlacePublishType,
    Platform: Enum_Platform,
    PlaybackState: Enum_PlaybackState,
    PlayerActions: Enum_PlayerActions,
    PlayerCharacterDestroyBehavior: Enum_PlayerCharacterDestroyBehavior,
    PlayerChatType: Enum_PlayerChatType,
    PlayerDataErrorState: Enum_PlayerDataErrorState,
    PlayerDataLoadFailureBehavior: Enum_PlayerDataLoadFailureBehavior,
    PlayerExitReason: Enum_PlayerExitReason,
    PoseEasingDirection: Enum_PoseEasingDirection,
    PoseEasingStyle: Enum_PoseEasingStyle,
    PositionAlignmentMode: Enum_PositionAlignmentMode,
    PredictionMode: Enum_PredictionMode,
    PredictionStatus: Enum_PredictionStatus,
    PreferredInput: Enum_PreferredInput,
    PreferredTextSize: Enum_PreferredTextSize,
    PrimalPhysicsSolver: Enum_PrimalPhysicsSolver,
    PrimitiveType: Enum_PrimitiveType,
    PrivilegeType: Enum_PrivilegeType,
    ProductLocationRestriction: Enum_ProductLocationRestriction,
    ProductPurchaseChannel: Enum_ProductPurchaseChannel,
    ProductPurchaseDecision: Enum_ProductPurchaseDecision,
    PromptCreateAssetResult: Enum_PromptCreateAssetResult,
    PromptCreateAvatarResult: Enum_PromptCreateAvatarResult,
    PromptExperienceDetailsResult: Enum_PromptExperienceDetailsResult,
    PromptLinkSharingResult: Enum_PromptLinkSharingResult,
    PromptPublishAssetResult: Enum_PromptPublishAssetResult,
    PropertyStatus: Enum_PropertyStatus,
    ProximityPromptExclusivity: Enum_ProximityPromptExclusivity,
    ProximityPromptInputType: Enum_ProximityPromptInputType,
    ProximityPromptStyle: Enum_ProximityPromptStyle,
    QualityLevel: Enum_QualityLevel,
    R15CollisionType: Enum_R15CollisionType,
    RaycastFilterType: Enum_RaycastFilterType,
    ReadCapturesFromGalleryResult: Enum_ReadCapturesFromGalleryResult,
    RecommendationActionType: Enum_RecommendationActionType,
    RecommendationDepartureIntent: Enum_RecommendationDepartureIntent,
    RecommendationImpressionType: Enum_RecommendationImpressionType,
    RecommendationItemContentType: Enum_RecommendationItemContentType,
    RecommendationItemVisibility: Enum_RecommendationItemVisibility,
    RejectCharacterDeletions: Enum_RejectCharacterDeletions,
    RenderFidelity: Enum_RenderFidelity,
    RenderPriority: Enum_RenderPriority,
    RenderingCacheOptimizationMode: Enum_RenderingCacheOptimizationMode,
    RenderingTestComparisonMethod: Enum_RenderingTestComparisonMethod,
    ReplicateInstanceDestroySetting: Enum_ReplicateInstanceDestroySetting,
    ResamplerMode: Enum_ResamplerMode,
    ReservedHighlightId: Enum_ReservedHighlightId,
    RestPose: Enum_RestPose,
    RestPoseModel: Enum_RestPoseModel,
    ReturnKeyType: Enum_ReturnKeyType,
    ReverbType: Enum_ReverbType,
    ReviewableContentState: Enum_ReviewableContentState,
    RibbonTool: Enum_RibbonTool,
    RigLabel: Enum_RigLabel,
    RigScale: Enum_RigScale,
    RigType: Enum_RigType,
    RollOffMode: Enum_RollOffMode,
    RolloutState: Enum_RolloutState,
    RotationOrder: Enum_RotationOrder,
    RotationType: Enum_RotationType,
    RsvpStatus: Enum_RsvpStatus,
    RtlTextSupport: Enum_RtlTextSupport,
    RunContext: Enum_RunContext,
    RunState: Enum_RunState,
    RuntimeUndoBehavior: Enum_RuntimeUndoBehavior,
    SafeAreaCompatibility: Enum_SafeAreaCompatibility,
    SalesTypeFilter: Enum_SalesTypeFilter,
    SandboxedInstanceMode: Enum_SandboxedInstanceMode,
    SaveAvatarThumbnailCustomizationFailure: Enum_SaveAvatarThumbnailCustomizationFailure,
    SaveFilter: Enum_SaveFilter,
    SavedQualitySetting: Enum_SavedQualitySetting,
    ScaleType: Enum_ScaleType,
    ScopeCheckResult: Enum_ScopeCheckResult,
    ScreenInsets: Enum_ScreenInsets,
    ScreenOrientation: Enum_ScreenOrientation,
    ScreenshotCaptureResult: Enum_ScreenshotCaptureResult,
    ScrollBarInset: Enum_ScrollBarInset,
    ScrollingDirection: Enum_ScrollingDirection,
    SecurityCapability: Enum_SecurityCapability,
    SelectionBehavior: Enum_SelectionBehavior,
    SelectionRenderMode: Enum_SelectionRenderMode,
    SelfViewPosition: Enum_SelfViewPosition,
    SensorMode: Enum_SensorMode,
    SensorUpdateType: Enum_SensorUpdateType,
    ServerLiveEditingMode: Enum_ServerLiveEditingMode,
    ServiceVisibility: Enum_ServiceVisibility,
    Severity: Enum_Severity,
    ShowAdResult: Enum_ShowAdResult,
    SignalBehavior: Enum_SignalBehavior,
    SizeConstraint: Enum_SizeConstraint,
    SolverConvergenceMetricType: Enum_SolverConvergenceMetricType,
    SolverConvergenceVisualizationMode: Enum_SolverConvergenceVisualizationMode,
    SortDirection: Enum_SortDirection,
    SortOrder: Enum_SortOrder,
    SpecialKey: Enum_SpecialKey,
    StartCorner: Enum_StartCorner,
    StateObjectFieldType: Enum_StateObjectFieldType,
    Status: Enum_Status,
    StepFrequency: Enum_StepFrequency,
    StreamOutBehavior: Enum_StreamOutBehavior,
    StreamingIntegrityMode: Enum_StreamingIntegrityMode,
    StreamingPauseMode: Enum_StreamingPauseMode,
    StrokeSizingMode: Enum_StrokeSizingMode,
    StudioCloseMode: Enum_StudioCloseMode,
    StudioDataModelType: Enum_StudioDataModelType,
    StudioPlaceUpdateFailureReason: Enum_StudioPlaceUpdateFailureReason,
    StudioScriptEditorColorCategories: Enum_StudioScriptEditorColorCategories,
    StudioScriptEditorColorPresets: Enum_StudioScriptEditorColorPresets,
    StudioStyleGuideColor: Enum_StudioStyleGuideColor,
    StudioStyleGuideModifier: Enum_StudioStyleGuideModifier,
    Style: Enum_Style,
    SubscriptionExpirationReason: Enum_SubscriptionExpirationReason,
    SubscriptionPaymentStatus: Enum_SubscriptionPaymentStatus,
    SubscriptionPeriod: Enum_SubscriptionPeriod,
    SubscriptionState: Enum_SubscriptionState,
    SurfaceConstraint: Enum_SurfaceConstraint,
    SurfaceGuiShape: Enum_SurfaceGuiShape,
    SurfaceGuiSizingMode: Enum_SurfaceGuiSizingMode,
    SurfaceType: Enum_SurfaceType,
    SwipeDirection: Enum_SwipeDirection,
    SystemThemeValue: Enum_SystemThemeValue,
    TableMajorAxis: Enum_TableMajorAxis,
    TeamCreateErrorState: Enum_TeamCreateErrorState,
    Technology: Enum_Technology,
    TelemetryBackend: Enum_TelemetryBackend,
    TelemetryStandardizedField: Enum_TelemetryStandardizedField,
    TeleportMethod: Enum_TeleportMethod,
    TeleportResult: Enum_TeleportResult,
    TeleportState: Enum_TeleportState,
    TeleportType: Enum_TeleportType,
    TerrainAcquisitionMethod: Enum_TerrainAcquisitionMethod,
    TerrainFace: Enum_TerrainFace,
    TextChatMessageStatus: Enum_TextChatMessageStatus,
    TextDirection: Enum_TextDirection,
    TextFilterContext: Enum_TextFilterContext,
    TextInputType: Enum_TextInputType,
    TextTruncate: Enum_TextTruncate,
    TextXAlignment: Enum_TextXAlignment,
    TextYAlignment: Enum_TextYAlignment,
    TextureMode: Enum_TextureMode,
    TextureQueryType: Enum_TextureQueryType,
    ThreadPoolConfig: Enum_ThreadPoolConfig,
    ThrottlingPriority: Enum_ThrottlingPriority,
    ThumbnailSize: Enum_ThumbnailSize,
    ThumbnailType: Enum_ThumbnailType,
    TickCountSampleMethod: Enum_TickCountSampleMethod,
    TonemapperPreset: Enum_TonemapperPreset,
    TopBottom: Enum_TopBottom,
    TouchCameraMovementMode: Enum_TouchCameraMovementMode,
    TouchMovementMode: Enum_TouchMovementMode,
    TrackerError: Enum_TrackerError,
    TrackerExtrapolationFlagMode: Enum_TrackerExtrapolationFlagMode,
    TrackerFaceTrackingStatus: Enum_TrackerFaceTrackingStatus,
    TrackerLodFlagMode: Enum_TrackerLodFlagMode,
    TrackerLodValueMode: Enum_TrackerLodValueMode,
    TrackerMode: Enum_TrackerMode,
    TrackerPromptEvent: Enum_TrackerPromptEvent,
    TrackerType: Enum_TrackerType,
    TriStateBoolean: Enum_TriStateBoolean,
    TweenStatus: Enum_TweenStatus,
    UICaptureMode: Enum_UICaptureMode,
    UIDragDetectorBoundingBehavior: Enum_UIDragDetectorBoundingBehavior,
    UIDragDetectorDragRelativity: Enum_UIDragDetectorDragRelativity,
    UIDragDetectorDragSpace: Enum_UIDragDetectorDragSpace,
    UIDragDetectorDragStyle: Enum_UIDragDetectorDragStyle,
    UIDragDetectorResponseStyle: Enum_UIDragDetectorResponseStyle,
    UIDragSpeedAxisMapping: Enum_UIDragSpeedAxisMapping,
    UIFlexAlignment: Enum_UIFlexAlignment,
    UIFlexMode: Enum_UIFlexMode,
    UITheme: Enum_UITheme,
    UiMessageType: Enum_UiMessageType,
    UpdateState: Enum_UpdateState,
    UploadCaptureResult: Enum_UploadCaptureResult,
    UsageContext: Enum_UsageContext,
    UserCFrame: Enum_UserCFrame,
    UserInputState: Enum_UserInputState,
    UserInputType: Enum_UserInputType,
    VRComfortSetting: Enum_VRComfortSetting,
    VRControllerModelMode: Enum_VRControllerModelMode,
    VRDeviceType: Enum_VRDeviceType,
    VRLaserPointerMode: Enum_VRLaserPointerMode,
    VRSafetyBubbleMode: Enum_VRSafetyBubbleMode,
    VRScaling: Enum_VRScaling,
    VRSessionState: Enum_VRSessionState,
    VRTouchpad: Enum_VRTouchpad,
    VRTouchpadMode: Enum_VRTouchpadMode,
    VelocityConstraintMode: Enum_VelocityConstraintMode,
    VerticalAlignment: Enum_VerticalAlignment,
    VerticalScrollBarPosition: Enum_VerticalScrollBarPosition,
    VibrationMotor: Enum_VibrationMotor,
    VideoCaptureResult: Enum_VideoCaptureResult,
    VideoCaptureStartedResult: Enum_VideoCaptureStartedResult,
    VideoDeviceCaptureQuality: Enum_VideoDeviceCaptureQuality,
    VideoError: Enum_VideoError,
    VideoSampleSize: Enum_VideoSampleSize,
    ViewMode: Enum_ViewMode,
    VirtualCursorMode: Enum_VirtualCursorMode,
    VirtualInputMode: Enum_VirtualInputMode,
    VoiceChatDistanceAttenuationType: Enum_VoiceChatDistanceAttenuationType,
    VoiceChatState: Enum_VoiceChatState,
    VoiceClientLeaveReasons: Enum_VoiceClientLeaveReasons,
    VoiceControlPath: Enum_VoiceControlPath,
    VolumetricAudio: Enum_VolumetricAudio,
    WaterDirection: Enum_WaterDirection,
    WaterForce: Enum_WaterForce,
    WebSocketState: Enum_WebSocketState,
    WebStreamClientState: Enum_WebStreamClientState,
    WebStreamClientType: Enum_WebStreamClientType,
    WeldConstraintPreserve: Enum_WeldConstraintPreserve,
    WhisperChatPrivacyMode: Enum_WhisperChatPrivacyMode,
    WrapLayerAutoSkin: Enum_WrapLayerAutoSkin,
    WrapLayerDebugMode: Enum_WrapLayerDebugMode,
    WrapTargetDebugMode: Enum_WrapTargetDebugMode,
    ZIndexBehavior: Enum_ZIndexBehavior,
}
return {};