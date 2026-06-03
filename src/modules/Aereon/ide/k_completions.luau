local completions = {
	{
		label = "warn",
		type = "function",
		icon = "Function.png",
		args = { "..." },
	},
	{
		label = "log",
		type = "function",
		icon = "Function.png",
		args = { "..." },
	},
	{
		label = "runtime",
		type = "function",
		icon = "Function.png",
		args = { "..." },
	},
	{
		label = "evalError",
		type = "function",
		icon = "Function.png",
		args = { "..." },
	},
	{
		label = "iodebug",
		type = "function",
		icon = "Function.png",
		args = { "..." },
	},
	{
		label = "FlagExists",
		type = "function",
		icon = "Function.png",
		args = { "flag" },
	},
	{
		label = "include",
		type = "function",
		icon = "Function.png",
		args = { "path" },
	},
	{
		label = "plug",
		type = "function",
		icon = "Function.png",
		args = { "lib" },
	},
	{
		label = "GetFlagValue",
		type = "function",
		icon = "Function.png",
		args = { "flag" },
	},
	{
		label = "debugstep",
		type = "function",
		icon = "Function.png",
	},
	{
		label = "float",
		type = "function",
		icon = "Function.png",
		args = { "value" },
	},
	{
		label = "readFloat",
		type = "function",
		icon = "Function.png",
		args = { "buf" },
	},
	{
		label = "writeFloat",
		type = "function",
		icon = "Function.png",
		args = { "buf", "v" },
	},
	{
		label = "printi",
		type = "function",
		icon = "Function.png",
		args = { "tbl" },
	},
	{
		label = "game",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "JoltPhysicsService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Lighting",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "NetworkService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PathfindingService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Players",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PlaytestService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ReplicatorService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ScriptContext",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "SoundService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ENGINE_ENDPOINT",
		type = "global",
		icon = "Variable.png",
	},
	{
		label = "color",
		type = "global",
		icon = "Variable.png",
	},
	{
		label = "ENGINE_PROFILER",
		type = "constant",
		icon = "Variable.png",
	},
	{
		label = "ENGINE_VERSION",
		type = "constant",
		icon = "Variable.png",
	},
	{
		label = "task",
		type = "library",
		icon = "Module.png",
	},
	{
		label = "IsClient",
		type = "constant",
		icon = "Variable.png",
	},
	{
		label = "IsServer",
		type = "constant",
		icon = "Variable.png",
	},
	{
		label = "IsHeadless",
		type = "constant",
		icon = "Variable.png",
	},
	{
		label = "Enum.ActuatorRelativeTo",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ActuatorRelativeTo.Attachment0",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ActuatorRelativeTo.Attachment1",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ActuatorRelativeTo.World",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AnimationPriority",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.AnimationPriority.Action",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AnimationPriority.Core",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AnimationPriority.Idle",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AnimationPriority.Movement",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AudioBackend",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.AudioBackend.RAUDIO",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AuthorityMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.AuthorityMode.Client",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AuthorityMode.Server",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AutomaticSize",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.AutomaticSize.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AutomaticSize.X",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AutomaticSize.XY",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.AutomaticSize.Y",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Axis",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Axis.X",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Axis.Y",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Axis.Z",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.BodySleepState2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.BodySleepState2D.Awake",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.BodySleepState2D.Sleeping",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.BodyType2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.BodyType2D.Dynamic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.BodyType2D.Kinematic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.BodyType2D.Static",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CameraType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.CameraType.Custom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CameraType.FirstPerson",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CameraType.Orbital",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CameraType.Scriptable",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CameraType.ThirdPerson",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionDetection2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.CollisionDetection2D.Continuous",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionDetection2D.Discrete",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionFidelity",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.CollisionFidelity.Box",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionFidelity.Default",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionFidelity.Hull",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionFidelity.PreciseConvexDecomposition",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionGroup",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.CollisionGroup.Default",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionGroup.Player",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionGroup.Sensor",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.CollisionGroup.World",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ConstraintType.BallSocket",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType.Hinge",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType.Prismatic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType.Rope",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType.Spring",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ConstraintType.Weld",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ContactState2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ContactState2D.Begin",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ContactState2D.End",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ContactState2D.Persist",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Dimension",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.EasingDirection",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.EasingDirection.In",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingDirection.InOut",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingDirection.Out",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.EasingStyle.Back",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Bounce",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Circular",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Cubic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Elastic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Expo",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Linear",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Quad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Quart",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Quint",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.RevBack",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.RidiculousWiggle",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Sine",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Smooth",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Smoother",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.SoftSpring",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.EasingStyle.Spring",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Face.Back",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face.Bottom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face.Front",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Face.Top",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.FillDirection",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.FillDirection.Horizontal",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.FillDirection.Vertical",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Font.Aerova",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.AmaticSC",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Antique",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Arcade",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Arial",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.ArialBold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Arimo",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.ArimoBold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Atiba",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Audiowide",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Avenir",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Bangers",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Bembo",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Beyno",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Bodoni",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Cartoon",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Code",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Creepster",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Curlz",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.DefaultEngineFont",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.DenkOne",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.DuskfallGothic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Exo",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.ExoBold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.ExoItalic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Fantasy",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Filted",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Fondamento",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.FredokaOne",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Garamond",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.GillSans",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Gotham",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.GothamBlack",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.GothamBold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.GothamMedium",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.GrenzeGotisch",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Highway",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.IndieFlower",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.JosefinSans",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Jura",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Kalam",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Legacy",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.LuckiestGuy",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Merriweather",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Michroma",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Nunito",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Oswald",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.PatrickHand",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.PermanentMarker",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Roboto",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.RobotoCondensed",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.RobotoMono",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Sarpanch",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SciFi",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SourceSans",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SourceSansBold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SourceSansItalic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SourceSansLight",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SourceSansSemibold",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.SpecialElite",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.TitilliumWeb",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Ubuntu",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Unknown",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.VCR",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Font.Vend",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ForceLimitMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ForceLimitMode.Magnitude",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ForceLimitMode.PerAxis",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ForceMode2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ForceMode2D.Force",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ForceMode2D.Impulse",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GameContext",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.GameContext.Editor",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GameContext.Game",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GameContext.Home",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.GraphicsLevel.Automatic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.Compatibility",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.High",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.Low",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.Medium",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.Performance",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.GraphicsLevel.Ultra",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HorizontalAlignment",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.HorizontalAlignment.Center",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HorizontalAlignment.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HorizontalAlignment.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.HumanoidStateType.Climbing",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Dead",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Freefall",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Jumping",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Landed",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Running",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Seated",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.HumanoidStateType.Swimming",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.JointType2D.Distance",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Friction",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Gear",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Motor",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Mouse",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Prismatic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Pulley",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Revolute",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Weld",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.JointType2D.Wheel",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KeyCode.A",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Add",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Apps",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.B",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Backslash",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Backspace",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.C",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.CapsLock",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Comma",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.D",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Decimal",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Delete",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Divide",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Down",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.E",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Eight",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.EightPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.End",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Equals",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Escape",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F1",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F10",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F11",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F12",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F2",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F3",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F4",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F5",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F6",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F7",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F8",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.F9",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Five",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.FivePad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Four",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.FourPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.G",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Grave",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.H",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Home",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.I",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Insert",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.J",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.K",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.KeypadEnter",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.KeypadEquals",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.L",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.LeftAlt",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.LeftBracket",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.LeftControl",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.LeftShift",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.LeftSuper",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.M",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Minus",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Multiply",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.N",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Nine",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.NinePad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.NumLock",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.O",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.One",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.OnePad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.P",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.PageDown",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.PageUp",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Pause",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Period",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.PrintScreen",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Q",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.R",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Return",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.RightAlt",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.RightBracket",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.RightControl",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.RightShift",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.RightSuper",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.S",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.ScrollLock",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Semicolon",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Seven",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.SevenPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Six",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.SixPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Slash",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Space",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Subtract",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.T",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Tab",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Three",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.ThreePad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Two",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.TwoPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.U",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Up",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.V",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.W",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.X",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Y",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Z",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.Zero",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KeyCode.ZeroPad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumBloomMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumBloomMode.Additive",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumBloomMode.Mix",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumBloomMode.Screen",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumDownscaleMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumDownscaleMode.Box",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumDownscaleMode.Linear",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumDownscaleMode.Nearest",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumFogMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumFogMode.Exponential",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumFogMode.Exponential2",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumFogMode.Linear",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumMouseCursor",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumOutputMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Albedo",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Bloom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.DOF",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Diffuse",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Normal",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.ORM",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.SSAO",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.SSGI",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.SSIL",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.SSR",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Scene",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumOutputMode.Specular",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumShaderPreset",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumShaderPreset.High",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumShaderPreset.Low",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumShaderPreset.Medium",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumShaderPreset.Ultra",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumTonemapMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumTonemapMode.ACES",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumTonemapMode.ACESFilmic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumTonemapMode.Filmic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumTonemapMode.Hejl",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumTonemapMode.Reinhard",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumUpscaleMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.KinemiumUpscaleMode.Bicubic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumUpscaleMode.Lanczos",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumUpscaleMode.Linear",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.KinemiumUpscaleMode.Nearest",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Language",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Language.Luau",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MachineNetworkOwner",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.MachineNetworkOwner.Client",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MachineNetworkOwner.Server",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Material.Concrete",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Glass",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Grass",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Neon",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Sand",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Slate",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.SmoothPlastic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Water",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.Wood",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Material.debug",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MouseButton",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.MouseButton.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MouseButton.Middle",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MouseButton.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MultiplayerMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.MultiplayerMode.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.MultiplayerMode.Singleplayer",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.NormalId.Back",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId.Bottom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId.Front",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NormalId.Top",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationAnchor",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.NotificationAnchor.BottomLeft",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationAnchor.BottomRight",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationAnchor.TopLeft",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationAnchor.TopRight",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationState",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.NotificationState.Entering",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationState.Exiting",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.NotificationState.Visible",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PartType.Ball",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType.Block",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType.CornerWedge",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType.Cylinder",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType.Torus",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PartType.Wedge",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBillboardMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ParticleBillboardMode.Disabled",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBillboardMode.Front",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBillboardMode.YAxis",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBlendMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ParticleBlendMode.Additive",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBlendMode.Mix",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBlendMode.Multiply",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleBlendMode.PremultipliedAlpha",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleCullMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ParticleCullMode.Back",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleCullMode.Front",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleCullMode.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleFlipbookMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ParticleFlipbookMode.Loop",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleFlipbookMode.OneShot",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleFlipbookMode.PingPong",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleFlipbookMode.Random",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleTransparencyMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ParticleTransparencyMode.Alpha",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleTransparencyMode.Disabled",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ParticleTransparencyMode.Prepass",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PhysicsEngine.Bullet",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine.Default",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine.Impulse3D",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine.Jolt",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine.Ode",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsEngine.PhysX",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsMaterialCombine",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PhysicsMaterialCombine.Average",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsMaterialCombine.Max",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsMaterialCombine.Min",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PhysicsMaterialCombine.Multiply",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PlaybackState",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PlaybackState.Paused",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PlaybackState.Playing",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PlaybackState.Stopped",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PredictionMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PredictionMode.Automatic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PredictionMode.Off",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PredictionMode.On",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PredictionStatus",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.PredictionStatus.NotPredicted",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.PredictionStatus.Predicted",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RaycastMode2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.RaycastMode2D.All",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RaycastMode2D.Any",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RaycastMode2D.Closest",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RenderFidelity",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.RenderFidelity.Automatic",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RenderFidelity.Performance",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RenderFidelity.Precise",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.RigType.Custom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigType.K17",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D.FreezeAll",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D.FreezePositionX",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D.FreezePositionY",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D.FreezeRotation",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RigidbodyConstraints2D.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RunContext",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.RunContext.Client",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RunContext.Editor",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RunContext.Legacy",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RunContext.Plugin",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.RunContext.Server",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ScaleType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ScaleType.Crop",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ScaleType.Fit",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ScaleType.Stretch",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SecurityCapabilities",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.SecurityCapabilities.Internals",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SecurityCapabilities.UserScript",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ShapeType2D",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ShapeType2D.Box",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ShapeType2D.Chain",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ShapeType2D.Circle",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ShapeType2D.Edge",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ShapeType2D.Polygon",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SortOrder",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.SortOrder.LayoutOrder",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SortOrder.Name",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.StepFrequency",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.StepFrequency.Hz120",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.StepFrequency.Hz240",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.StepFrequency.Hz60",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Style",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.Style.AlternatingSupports",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Style.BridgeStyleSupports",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.Style.NoSupports",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SurfaceType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.SurfaceType.Inlet",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SurfaceType.Smooth",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SurfaceType.Studs",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.SurfaceType.Universal",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextTruncate",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.TextTruncate.Head",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextTruncate.Line",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextTruncate.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextTruncate.Tail",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextXAlignment",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.TextXAlignment.Center",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextXAlignment.Left",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextXAlignment.Right",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextYAlignment",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.TextYAlignment.Bottom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextYAlignment.Center",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.TextYAlignment.Top",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UIParticleEmitterShape",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.UIParticleEmitterShape.Box",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UIParticleEmitterShape.Circle",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UIParticleEmitterShape.Point",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UIParticleEmitterShape.Ring",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputState",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.UserInputState.Begin",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputState.Cancel",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputState.Change",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputState.End",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputState.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.UserInputType.Accelerometer",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad1",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad2",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad3",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad4",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad5",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad6",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad7",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gamepad8",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Gyro",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Keyboard",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.MouseButton1",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.MouseButton2",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.MouseButton3",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.MouseMovement",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.MouseWheel",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.None",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.TextInput",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Touch",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.UserInputType.Voice",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VelocityConstraintMode",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.VelocityConstraintMode.Line",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VelocityConstraintMode.Plane",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VelocityConstraintMode.Vector",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VerticalAlignment",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.VerticalAlignment.Bottom",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VerticalAlignment.Center",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.VerticalAlignment.Top",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ZIndexBehavior",
		type = "enum",
		icon = "Enum.png",
	},
	{
		label = "Enum.ZIndexBehavior.Global",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "Enum.ZIndexBehavior.Sibling",
		type = "constant",
		icon = "EnumItem.png",
	},
	{
		label = "instancePointer",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "Accessory",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AccessoryType",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "AlignOrientation",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxTorque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxAngularVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Responsiveness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "AlignPosition",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Responsiveness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ApplyAtCenterOfMass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "AngularVelocity",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "AngularVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxTorque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReactionTorqueEnabled",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Animation",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "AnimationId",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Animator",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Clock",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpeedScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UseDefaultAnimations",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PoseProvider",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DefaultProvider",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ArcHandles",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CastShadows",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Atmosphere",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Density",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Offset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Decay",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Glare",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Haze",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Attachment",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Orientation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Axis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SecondaryAxis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldOrientation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldRotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldCFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldAxis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WorldSecondaryAxis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElapsedTime",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Attachment2D",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "GetWorldPosition",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetWorldRotation",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Backpack",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "UIBadge",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Text",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FontSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Spacing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BallSocketConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Radius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Beam",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CurveSize0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CurveSize1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Segments",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Width0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Width1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightEmission",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightInfluence",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FaceCamera",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZOffset",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BillboardGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Camera",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RenderOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StudsOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StudsOffsetWorldSpace",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PixelsPerStud",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AlwaysOnTop",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BinaryStringValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "BinaryString",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BindableEvent",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "BindableFunction",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "OnInvoke",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BloomEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Levels",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Intensity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Threshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SoftThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FilterRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BlurEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BodyGyro",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Part",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "P",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "D",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxTorque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Bone",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transform",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BoolValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BrickColorValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CFrameValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Camera",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "FieldOfView",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Roll",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CameraSubject",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Focus",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CanvasGroup",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GroupColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GroupTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CharacterMesh",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseTextureId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BodyPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MeshId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OverlayTextureId",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UICheckbox",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BoxColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CheckColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ClickDetector",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "CursorIcon",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CursorIconContent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxActivationDistance",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Clouds",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Speed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Color3Value",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ColorEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Brightness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Contrast",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Saturation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ColorPicker",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectedColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Configuration",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CornerWedgePart",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "Cursor",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IconPack",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CylindricalConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LowerLimit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UpperLimit",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DOFEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Mode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FocusPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FocusScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxBlurSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DataModel",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DebugOverlay",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowWireframes",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowAttachments",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowNormals",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Decal",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ColorMapContent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Face",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Wrap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Depth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NormalThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FadeWidth",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIDivider",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Vertical",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DoubleConstrainedValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "ConstrainedValue",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxValue",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinValue",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIDropdown",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Options",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectedIndex",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectedOption",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HoverColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectedColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SecondaryTextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "EditableImage",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "EditableMesh",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "FixedSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkinningEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Fire",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Heat",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LocalTransparencyModifier",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SecondaryColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TimeScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "FogEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Start",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "End",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Density",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyAffect",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Folder",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ForceField",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Frame",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "GuiObject",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "GetBounds",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetCenter",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsPointInside",
				type = "method",
				icon = "Method.png",
				args = { "point" },
			},
			{
				label = "GetRelativePoint",
				type = "method",
				icon = "Method.png",
				args = { "point" },
			},
			{
				label = "CancelGuiTweens",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "TweenPosition",
				type = "method",
				icon = "Method.png",
				args = { "endPosition", "easingDirection", "easingStyle", "time", "override", "callback" },
			},
			{
				label = "TweenSize",
				type = "method",
				icon = "Method.png",
				args = { "endSize", "easingDirection", "easingStyle", "time", "override", "callback" },
			},
			{
				label = "TweenSizeAndPosition",
				type = "method",
				icon = "Method.png",
				args = { "endSize", "endPosition", "easingDirection", "easingStyle", "time", "override", "callback" },
			},
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Anchored",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutomaticSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ClipsDescendants",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZIndex",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AnchorPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MouseIsInObject",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "endPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingStyle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "time",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "override",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "endSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingStyle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "time",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "override",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "endSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "endPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "easingStyle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "time",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "override",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Handles",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CastShadows",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Style",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RotationSnap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_gizmoTransform",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_isDragging",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Highlight",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OutlineColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OutlineTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillTransparency",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "HingeConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActuatorType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AngularVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MotorMaxAcceleration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MotorMaxTorque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ServoMaxTorque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TargetAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LowerAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UpperAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Restitution",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Offset",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Humanoid",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "AutoJumpEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutomaticScalingEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoRotate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BreakJointsOnDeath",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CameraOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CollisionType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ControllerEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DisplayDistanceType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DisplayName",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FloorMaterial",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FallCap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Gravity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GravityScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GroundProbePadding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GroundSnapDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AirControl",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Health",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxHealth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HealthDisplayDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HealthDisplayType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HipHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Jump",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "JumpHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "JumpPower",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "JumpQueueWindow",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxSlopeAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MoveDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WalkSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WalkToPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PlatformStand",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RequiresNeck",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Sit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TargetPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TurnSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UseJumpPower",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VelocityLerp",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Sprinting",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SprintMultiplier",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Crouching",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CrouchSpeedMultiplier",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Dashing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DashSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DashDuration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DashCooldown",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DashLift",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LeanEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LeanAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LeanLerp",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FacingDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Stance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Character",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RootPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SeatPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WalkToPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FocusOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SprintFocusOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CrouchFocusOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DashFocusOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MoveVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Animator",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpeedModifiers",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PoseOffsets",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigBindings",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigParts",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigPartIndex",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigChains",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigDescriptor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Died",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HealthChanged",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MoveToFinished",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Running",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Jumping",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FreeFalling",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Seated",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Landed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StateChanged",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StanceChanged",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RigBuilt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SprintStarted",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SprintEnded",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CrouchStarted",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CrouchEnded",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Dashed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "State",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "IKControl",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Target",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EndEffector",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Weight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Pole",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ImageButton",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Image",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageRectOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageRectSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScaleType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliceCenter",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HoverImage",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PressedImage",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ImageLabel",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AnchorPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Image",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ImageTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Shader",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZIndex",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_cached",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "IntConstrainedValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxValue",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinValue",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "IntValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LegIK",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Humanoid",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Workspace",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepDistThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PoleForwardBias",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PoleSideBias",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LineForce",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "ApplyAtCenterOfMass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "InverseSquareLaw",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Magnitude",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReactionForceEnabled",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LinearVelocity",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ForceLimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxAxesForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxPlanarAxesForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PlaneVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PrimaryTangentAxis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReactionForceEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SecondaryTangentAxis",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VectorVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VelocityConstraintMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LocalScript",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Source",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RunContext",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Language",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "MeshPart",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "MeshObject",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_showhitbox",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CollisionScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MeshScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Model",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "WorldPivot",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PrimaryPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ModuleScript",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Source",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RunContext",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Language",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Motor6D",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DesireAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CurrentAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxVelocity",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Mouse",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "SetIcon",
				type = "method",
				icon = "Method.png",
				args = { "mouse", "icon" },
			},
			{
				label = "GetScreenPosition",
				type = "method",
				icon = "Method.png",
				args = { "mouse" },
			},
			{
				label = "Raycast",
				type = "method",
				icon = "Method.png",
				args = { "mouse", "distance" },
			},
			{
				label = "IsButtonDown",
				type = "method",
				icon = "Method.png",
				args = { "mouse", "button" },
			},
			{
				label = "Target",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Hit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UnitRay",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TargetFilter",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsMouseHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsMouseOutOfBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "X",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Y",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ViewSizeX",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ViewSizeY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Button1Down",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Button1Up",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Button2Down",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Button2Up",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Move",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WheelForward",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WheelBackward",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "mouse",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "mouse",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "mouse",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "NetworkController",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoAssignOwnership",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LockOwner",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OwnershipRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OwnershipReleaseRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OwnershipTransferCooldown",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OwnershipVelocityThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OwnershipStealMargin",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReplicatePhysics",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReplicateProperties",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PropertyList",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "NoCollisionConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Part0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Part1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "NumberValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ObjectValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Pants",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PantsTemplate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Part",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Material",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Anchored",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NeonEnergy",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CanCollide",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CollisionGroup",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Velocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MeshScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Mass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Restitution",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Elasticity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Friction",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CastsShadow",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Reflectance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Locked",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Orientation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MouseOverObject",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElapsedTime",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_mesh",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Touched",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AssemblyAngularVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AssemblyCenterOfMass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AssemblyLinearVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AssemblyMass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NetworkOwnerType",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ParticleEmitter",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Acceleration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Drag",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Restitution",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmissionDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpreadAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmissionTexture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmissionColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmissionEnergy",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TransparencyMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BlendMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CullMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BillboardMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UVScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UVOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookColumns",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookRows",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookFramerate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookStartRandom",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxParticles",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LockedToPart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CastShadow",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIParticleEmitter",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SizeScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SizeSpread",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShapeSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShapeThickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShapeRotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmitFromEdge",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AlignToVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Acceleration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Drag",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EmissionDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpreadAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BlendMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UVScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UVOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookColumns",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookRows",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookFramerate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlipbookStartRandom",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxParticles",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LockedToParent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PathfindingModifier",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Label",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PassThrough",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PlaneConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Player",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UserId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Character",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Backpack",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Team",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Health",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxHealth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WalkSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "JumpPower",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PlayerGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PointLight",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Brightness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Range",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CastShadow",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DebugShape",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIPoll",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OptionBackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OptionHoverColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectedOptionColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DimTextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PrismaticConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActuatorType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Velocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MotorMaxForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ServoMaxForce",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TargetPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LowerLimit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UpperLimit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Restitution",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ProximityPrompt",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "ActionText",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoLocalize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ClickablePrompt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Exclusivity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GamepadKeyCode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HoldDuration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "KeyboardKeyCode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxActivationDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxIndicatorDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ObjectText",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RequiresLineOfSight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RootLocalizationTable",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Style",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UIOffset",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIRadioButton",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RingColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RayValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RemoteData",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "RemoteEvent",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "RemoteFunction",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "RigidConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RodConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Length",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RopeConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Length",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Stiffness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Damping",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SSAOEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "SampleCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Intensity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Power",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Radius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Bias",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SSEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Shader",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SSGIEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "SampleCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxRaySteps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FadeStart",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FadeEnd",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DenoiseSteps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SSILEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "SampleCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliceCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Radius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Intensity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AOPower",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DenoiseSteps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SSREffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "MaxRaySteps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BinarySteps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EdgeFade",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ScreenGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GravityY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GravityX",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PhysicsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZIndexBehavior",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ResetOnSpawn",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RenderOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OverrideScreenSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Script",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Source",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RunContext",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Language",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ScrollingFrame",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarCornerRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarBackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarBackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarHoverColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Scroll",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollTarget",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollLerpSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ContentSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CanvasPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoScrollSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CanvasSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarThickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarVisible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarAutoHide",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarFadeSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollBarPadding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElasticEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElasticStrength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElasticSnapSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MomentumEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MomentumFriction",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MomentumMinVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TrackClickEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TrackClickSmooth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_draggingThumb",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_dragOffsetY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_scrollBarAlpha",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_timeSinceLastScroll",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_velocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_isOverscrolled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_lastScroll",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_isHoveringThumb",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_isHoveringTrack",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Seat",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Disabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Occupant",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SeatPart",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Disabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Occupant",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsSeat",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SelectionBox",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineThickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SurfaceColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SurfaceTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SelectionSphere",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SurfaceColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SurfaceTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ShaderFrame",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Shader",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Sky",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "CelestialBodiesShown",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StarCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SunAngularSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MoonAngularSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Cubemap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxBk",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxDn",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxFt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxLf",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxRt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxUp",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxBkColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxDnColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxFtColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxLfColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxRtColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SkyboxUpColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SunTextureId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MoonTextureId",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UISlider",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Min",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Max",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TrackColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HandleColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Smoke",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LocalTransparencyModifier",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Opacity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RiseVelocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TimeScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Snap",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SoftBody",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Mesh",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Pressure",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Stiffness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BendingStiffness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LinearDamping",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Friction",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Restitution",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CanCollide",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CollisionGroup",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Anchored",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Touched",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "FluidSimulation",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "GetSubmergedFraction",
				type = "method",
				icon = "Method.png",
				args = { "part" },
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Resolution",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WaveHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WaveSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WaveScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WaveDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Waves",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Roughness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlowDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FlowSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PhysicsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BuoyancyFactor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Dampening",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Container",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FitContainer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillLevel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Splashed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "x",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "x",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Sound",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "SoundId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Volume",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Pitch",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Looped",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Playing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TimePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PlayOnRemove",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsLoaded",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AudioBackend",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsStream",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SoundGroup",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_effectiveVolume",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_fadeVolume",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Velocity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Direction",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Up",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxDistance",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RollOffMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Is3D",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Sparkles",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LocalTransparencyModifier",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SparkleColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TimeScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SpawnLocation",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AllowTeamChangeOnTouch",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Duration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Neutral",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TeamColor",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SpecialMesh",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SpotLight",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "SpringConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Damping",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Stiffness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Frequency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpringMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Coils",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SegmentsPerCoil",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Radius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIStepper",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Steps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CurrentStep",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepSpacing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActiveColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "InactiveColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "StringValue",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SunRaysEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Intensity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Spread",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SurfaceGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Face",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CanvasSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PixelsPerStud",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SizingMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AlwaysOnTop",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightInfluence",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Brightness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZIndexBehavior",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ZOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RenderOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SurfaceLight",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "UISwitch",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OffColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OnColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HandleColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SyntaxHighlighter",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Language",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UITabs",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Tabs",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActiveIndex",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActiveTab",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ActiveColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TextBox",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Validator",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "_", "object", "dt", "structs", "renderer", "datamodel" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoButtonColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ChangeCursorOnHover",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Focused",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Text",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PlaceholderText",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FontSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PlaceholderColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FocusColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextXAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextYAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MultiLine",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ReadOnly",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Mask",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AllowedChars",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TrimWhitespace",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TabSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoPairs",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AutoIndent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "WordWrap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Numeric",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NumericMin",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NumericMax",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NumericStep",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NumericPrecision",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowStepButtons",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StepButtonWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Slider",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderMin",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderMax",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderStep",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SliderGap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Scrollable",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableScrollbar",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollbarWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowLineNumbers",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowLineCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShowCharCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CornerRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CornerSegments",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FocusBorderWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DropShadow",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShadowOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineHighlight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MatchBrackets",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableAnimatedFocus",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableMinimap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableHyperlinks",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableDragDrop",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnableColumnSelection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Label",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LabelPosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LabelWidth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LabelGap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Prefix",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Suffix",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PrefixGap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SuffixGap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SelectAllOnFocus",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SubmitOnCtrlEnter",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BlurOnSubmit",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ClearOnEscape",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EscapeBlurs",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DoubleClickSelect",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TripleClickSelect",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ContextMenu",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxHistory",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "KeyRepeatInitialDelay",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "KeyRepeatMinInterval",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "KeyRepeatAcceleration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TextButton",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "AutoButtonColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ChangeCursorOnHover",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TextLabel",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Text",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextXAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextYAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSpacing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextStrokeColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextStrokeTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextWrapped",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextTruncate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextScaled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RichText",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxVisibleGraphemes",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BorderTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AnchorPoint",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Texture",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Face",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StudsPerTileU",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "StudsPerTileV",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OffsetStudsU",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OffsetStudsV",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Adornee",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Wrap",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Depth",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NormalThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FadeWidth",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIToggle",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OffColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OnColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HandleColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TonemapEffect",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Exposure",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "White",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Tool",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RequiresHandle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Grip",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ToolTip",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureId",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Torque",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Torque",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TorsionSpringConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Damping",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Stiffness",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Trail",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Lifetime",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Texture",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureLength",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextureMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightEmission",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightInfluence",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FaceCamera",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TrussPart",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Style",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIAnchorLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "posX",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIAspectRatioConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AspectRatio",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AspectType",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DominantAxis",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIBevel",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "LightColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LightTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShadowColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ShadowTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Style",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIBlend",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Mode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AffectSelf",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AffectChildren",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UICellList",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Sections",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CellHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GroupSpacing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UICorner",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "CornerRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BottomLeftRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BottomRightRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TopLeftRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TopRightRadius",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIDragDetector",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "isDragging",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RespectScreenBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dragOffset",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIFlowLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "FillDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Padding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ItemAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "paddingY",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIGlow",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Blur",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Spread",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BlendMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIGradient",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rotation",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIGraph",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BgColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GridColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DrawGrid",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TooltipTextColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TooltipBackgroundColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TooltipFontSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Capacity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Values",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxPoints",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Min",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Max",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIGridLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CellPaddingX",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CellPaddingY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIListLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "FillDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Padding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Virtualized",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Overscan",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "paddingY",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UILoadingSpinner",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SpinnerColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIMask",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Inset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AffectChildren",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UINotificationLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Anchor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Padding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MarginX",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MarginY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxVisible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EnterDuration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ExitDuration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DefaultTimeout",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_notifications",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIPadding",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Padding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingLeft",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingRight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingTop",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingBottom",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_CachedParentSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_CachedResolved",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIPageLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Animated",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Circular",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EasingDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "EasingStyle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillDirection",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "GamepadInputEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Padding",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ScrollWheelInputEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TouchInputEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TweenTime",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIProgressBar",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Progress",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIRipple",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Duration",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxRadiusScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Fill",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BlendMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIScale",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Scale",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIScaleDetector",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "newSizeCallback",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "isResizing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "activeHandle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RespectScreenBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_startMouse",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_startAbsPos",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_startAbsSz",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIShadow",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Offset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Blur",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Spread",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UISizeConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinSize",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UISquircle",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "CornerRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Exponent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BottomLeftRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BottomRightRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TopLeftRadius",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TopRightRadius",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIStackLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillParent",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LayerOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIStroke",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ApplyStrokeMode",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UITableLayout",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Columns",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RowHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingX",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PaddingY",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SortOrder",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HorizontalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VerticalAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FillEmptyColumns",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UITextSizeConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxTextSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinTextSize",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UITilt",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "MaxOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UITooltip",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BackgroundTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextColor3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextStrokeColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextStrokeTransparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextXAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextYAlignment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextSpacing",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextWrapped",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextTruncate",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TextScaled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RichText",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxVisibleGraphemes",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LineHeight",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Text",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UIVignette",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Transparency",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Thickness",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Steps",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Union",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UniversalConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Attachment1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Visible",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LimitsEnabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxAngle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UnreliableRemoteEvent",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "ValueBase",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Vector3Value",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Value",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "VectorForce",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Attachment0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Force",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElapsedTime",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "VehicleSeat",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Disabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Occupant",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Throttle",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Steer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "HeadsUpDisplay",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Torque",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TurnSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "IsSeat",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Material",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "VideoFrame",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "render",
				type = "method",
				icon = "Method.png",
				args = { "lib", "object", "dt", "structs", "renderer" },
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsoluteSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AbsolutePosition",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VideoObject",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "lib",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "dt",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "structs",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ViewportFrame",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Camera",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "WedgePart",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Weld",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Part0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Part1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "C0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "C1",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "WeldConstraint",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Part0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Part1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Enabled",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElapsedTime",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "World2D",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "AddBody",
				type = "method",
				icon = "Method.png",
				args = { "body" },
			},
			{
				label = "inherit",
				type = "method",
				icon = "Method.png",
				args = { "tble" },
			},
			{
				label = "Gravity",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "TimeScale",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Paused",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ResetOnSpawn",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Position",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Size",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "RenderOffset",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "OverrideScreenSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "FixedDeltaTime",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ElapsedTime",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Accumulator",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "contactHertz",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "contactDampingRatio",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "maximumLinearSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "maximumAngularSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "restitutionThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "hitEventThreshold",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "maxContactPushSpeed",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "enableSleep",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "enableContinuous",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "workerCount",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MotionLocks",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Bodies",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Constraints",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CollisionLayers",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UseBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MinBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "MaxBounds",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "VelocityIterations",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "PositionIterations",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "AllowSleep",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DebugDraw",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DebugColor",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "BaseClass",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BlobLoader",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "LoadFileAsGame",
				type = "method",
				icon = "Method.png",
				args = { "binary" },
			},
			{
				label = "LoadFileAsGameFetch",
				type = "method",
				icon = "Method.png",
				args = { "link" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Box2DService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "init",
				type = "method",
				icon = "Method.png",
				args = { "World2D", "body_update" },
			},
			{
				label = "AddBody",
				type = "method",
				icon = "Method.png",
				args = { "_", "body" },
			},
			{
				label = "RemoveBody",
				type = "method",
				icon = "Method.png",
				args = { "_", "body" },
			},
			{
				label = "Clear",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Step",
				type = "method",
				icon = "Method.png",
				args = { "_", "dt" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "World2D",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "_",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ChatService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "CreateChatMessage",
				type = "method",
				icon = "Method.png",
				args = { "player", "message" },
			},
			{
				label = "CreateChatMessageForAll",
				type = "method",
				icon = "Method.png",
				args = { "message" },
			},
			{
				label = "CreateChatMessageForPlayers",
				type = "method",
				icon = "Method.png",
				args = { "players", "message" },
			},
			{
				label = "OnMessageServerReplace",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "OnMessageClientReplace",
				type = "method",
				icon = "Method.png",
				args = { "player", "message" },
			},
			{
				label = "GetChatGui",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "player",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "players",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "player",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CollectionService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "GetTags",
				type = "method",
				icon = "Method.png",
				args = { "object" },
			},
			{
				label = "GetAllTags",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetTagged",
				type = "method",
				icon = "Method.png",
				args = { "tag" },
			},
			{
				label = "HasTag",
				type = "method",
				icon = "Method.png",
				args = { "object", "tag" },
			},
			{
				label = "GetInstanceAddedSignal",
				type = "method",
				icon = "Method.png",
				args = { "tag" },
			},
			{
				label = "GetInstanceRemovedSignal",
				type = "method",
				icon = "Method.png",
				args = { "tag" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ConfigService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "SetConfig",
				type = "method",
				icon = "Method.png",
				args = { "config" },
			},
			{
				label = "GetConfig",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ContentService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CoreGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DebrisService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "AddItem",
				type = "method",
				icon = "Method.png",
				args = { "object", "lifetime" },
			},
			{
				label = "RemoveItem",
				type = "method",
				icon = "Method.png",
				args = { "object" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "DiscordService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "SetRPC",
				type = "method",
				icon = "Method.png",
				args = { "rpcData" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "EncodingService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "Base64Encode",
				type = "method",
				icon = "Method.png",
				args = { "data" },
			},
			{
				label = "Base64Decode",
				type = "method",
				icon = "Method.png",
				args = { "buf" },
			},
			{
				label = "GetDecompressedBufferSize",
				type = "method",
				icon = "Method.png",
				args = { "input", "algorithim" },
			},
			{
				label = "ComputeBufferHash",
				type = "method",
				icon = "Method.png",
				args = { "input", "algorithim" },
			},
			{
				label = "CompressBuffer",
				type = "method",
				icon = "Method.png",
				args = { "buf", "algorithim", "compressionLevel" },
			},
			{
				label = "DecompressBuffer",
				type = "method",
				icon = "Method.png",
				args = { "buf", "algorithim" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "input",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "input",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "buf",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "algorithim",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "buf",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "FileDialogService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "RequestFile",
				type = "method",
				icon = "Method.png",
				args = { "filters" },
			},
			{
				label = "RequestFolder",
				type = "method",
				icon = "Method.png",
				args = { "filters" },
			},
			{
				label = "RequestSaveFile",
				type = "method",
				icon = "Method.png",
				args = { "defaultName", "filters" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "defaultName",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "GeometryService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "GuiStackService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "HttpService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "HUDService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "AttachRuntime",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "AttachClient",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "IsReady",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetGui",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetRuntimeManager",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetRuntime",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "SetRuntime",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "OpenMenu",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "CloseMenu",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ToggleMenu",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Notify",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c", "d" },
			},
			{
				label = "SetNotificationHandler",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "OpenRoute",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "CloseRoute",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "AddWindow",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "AddTopbarButton",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "GetSettings",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "MergeSettings",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "AddSettingsSection",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "AddSettingsEntries",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "AddSettingsEntry",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c", "d" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "c",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "c",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "InputActionService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "BindAction",
				type = "method",
				icon = "Method.png",
				args = { "actionName", "callback" },
			},
			{
				label = "GetActionValue",
				type = "method",
				icon = "Method.png",
				args = { "actionName", "player" },
			},
			{
				label = "SetActionValue",
				type = "method",
				icon = "Method.png",
				args = { "actionName", "player", "value" },
			},
			{
				label = "SetLocalMovementBasisYaw",
				type = "method",
				icon = "Method.png",
				args = { "yaw" },
			},
			{
				label = "SampleLocalInputs",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "actionName",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "callback",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "actionName",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "actionName",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "player",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "InternalStorage",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumPhysicsService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KineFileService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "BuildRuntime",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Save",
				type = "method",
				icon = "Method.png",
				args = { "pathName" },
			},
			{
				label = "ExportObject",
				type = "method",
				icon = "Method.png",
				args = { "instances", "path", "name" },
			},
			{
				label = "ExportDatamodel",
				type = "method",
				icon = "Method.png",
				args = { "path", "name" },
			},
			{
				label = "ExportGameAsFile",
				type = "method",
				icon = "Method.png",
				args = { "path", "gameName" },
			},
			{
				label = "DecodeFile",
				type = "method",
				icon = "Method.png",
				args = { "filePath" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "instances",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "path",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "path",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "path",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumFFI",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumFontService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "LoadFont",
				type = "method",
				icon = "Method.png",
				args = { "name", "fontPath" },
			},
			{
				label = "Unload",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetDefaultFontSmall",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetDefaultFont",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetMonoFontDefault",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetBoldFont",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "LoadAllEngineFonts",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumIconLoader",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "LoadImageCustom",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "ToTextureBuffer",
				type = "method",
				icon = "Method.png",
				args = { "buffer_data", "filename" },
			},
			{
				label = "ToTexture",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "new",
				type = "method",
				icon = "Method.png",
				args = { "name", "path" },
			},
			{
				label = "Get",
				type = "method",
				icon = "Method.png",
				args = { "name" },
			},
			{
				label = "Remove",
				type = "method",
				icon = "Method.png",
				args = { "name" },
			},
			{
				label = "Change",
				type = "method",
				icon = "Method.png",
				args = { "name", "newPath" },
			},
			{
				label = "LoadAutoTexture",
				type = "method",
				icon = "Method.png",
				args = { "name", "path" },
			},
			{
				label = "Cleanup",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "buffer_data",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumModService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "Register",
				type = "method",
				icon = "Method.png",
				args = { "mod" },
			},
			{
				label = "run",
				type = "method",
				icon = "Method.png",
				args = { "code" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumRaylib",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "GetLib",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetConst",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetStructs",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetRenderer",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "KinemiumShaderService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Lighting",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "GetSunDirection",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetDaylight",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LogicGateService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "AND",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "NOT",
				type = "method",
				icon = "Method.png",
				args = { "one" },
			},
			{
				label = "NAND",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "NOR",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "OR",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "XOR",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "XNOR",
				type = "method",
				icon = "Method.png",
				args = { "one", "two" },
			},
			{
				label = "BUFFER",
				type = "method",
				icon = "Method.png",
				args = { "one" },
			},
			{
				label = "IMPLY",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "AND3",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "OR3",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "XOR3",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "NAND3",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "c" },
			},
			{
				label = "ANDn",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ORn",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "XORn",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "MUX2",
				type = "method",
				icon = "Method.png",
				args = { "sel", "a", "b" },
			},
			{
				label = "MUX4",
				type = "method",
				icon = "Method.png",
				args = { "sel1", "sel0", "a", "b", "c", "d" },
			},
			{
				label = "MUX8",
				type = "method",
				icon = "Method.png",
				args = { "sel2", "sel1", "sel0", "a", "b", "c", "d", "e", "f", "g", "h" },
			},
			{
				label = "DEMUX2",
				type = "method",
				icon = "Method.png",
				args = { "sel", "input" },
			},
			{
				label = "DEMUX4",
				type = "method",
				icon = "Method.png",
				args = { "sel1", "sel0", "input" },
			},
			{
				label = "HalfAdder",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "FullAdder",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "cin" },
			},
			{
				label = "HalfSubtractor",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "FullSubtractor",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "bin" },
			},
			{
				label = "SRLatch",
				type = "method",
				icon = "Method.png",
				args = { "s", "r", "prev_q" },
			},
			{
				label = "DLatch",
				type = "method",
				icon = "Method.png",
				args = { "d", "enable", "prev_q" },
			},
			{
				label = "JKFlipFlop",
				type = "method",
				icon = "Method.png",
				args = { "j", "k", "clk", "prev_q" },
			},
			{
				label = "Encoder4to2",
				type = "method",
				icon = "Method.png",
				args = { "i0", "i1", "i2", "i3" },
			},
			{
				label = "Encoder8to3",
				type = "method",
				icon = "Method.png",
				args = { "i0", "i1", "i2", "i3", "i4", "i5", "i6", "i7" },
			},
			{
				label = "Decoder2to4",
				type = "method",
				icon = "Method.png",
				args = { "a1", "a0", "enable" },
			},
			{
				label = "Decoder3to8",
				type = "method",
				icon = "Method.png",
				args = { "a2", "a1", "a0", "enable" },
			},
			{
				label = "Comparator1Bit",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "PriorityEncoder4to2",
				type = "method",
				icon = "Method.png",
				args = { "i0", "i1", "i2", "i3" },
			},
			{
				label = "ParityGenEven",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ParityGenOdd",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "MagnitudeComp4Bit",
				type = "method",
				icon = "Method.png",
				args = { "a3", "a2", "a1", "a0", "b3", "b2", "b1", "b0" },
			},
			{
				label = "BarrelShift4",
				type = "method",
				icon = "Method.png",
				args = { "d3", "d2", "d1", "d0", "s1", "s0", "direction" },
			},
			{
				label = "TextToBinary",
				type = "method",
				icon = "Method.png",
				args = { "text" },
			},
			{
				label = "BinaryToText",
				type = "method",
				icon = "Method.png",
				args = { "binary" },
			},
			{
				label = "ToBinary",
				type = "method",
				icon = "Method.png",
				args = { "num", "bits" },
			},
			{
				label = "FromBinary",
				type = "method",
				icon = "Method.png",
				args = { "binary" },
			},
			{
				label = "BinaryToGray",
				type = "method",
				icon = "Method.png",
				args = { "b3", "b2", "b1", "b0" },
			},
			{
				label = "GrayToBinary",
				type = "method",
				icon = "Method.png",
				args = { "g3", "g2", "g1", "g0" },
			},
			{
				label = "BCD7Segment",
				type = "method",
				icon = "Method.png",
				args = { "b3", "b2", "b1", "b0" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "c",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "c",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "e",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "f",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "g",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sel0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "s",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "r",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "enable",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "j",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "k",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "clk",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i4",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i5",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i6",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "i2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "a0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "d0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "s1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "s0",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "num",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "g3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "g2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "g1",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "b1",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "LogService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ClearOutput",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetLogHistory",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Errortest",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "CreateLog",
				type = "method",
				icon = "Method.png",
				args = { "type", "message" },
			},
			{
				label = "GetLog",
				type = "method",
				icon = "Method.png",
				args = { "id" },
			},
			{
				label = "UpdateLog",
				type = "method",
				icon = "Method.png",
				args = { "id", "message" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "type",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "id",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "NetworkService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "RegisterMessageHandler",
				type = "method",
				icon = "Method.png",
				args = { "channel", "kind", "callback" },
			},
			{
				label = "UnregisterMessageHandler",
				type = "method",
				icon = "Method.png",
				args = { "channel", "kind", "callback" },
			},
			{
				label = "SendToServer",
				type = "method",
				icon = "Method.png",
				args = { "channel", "kind", "payload", "reliable" },
			},
			{
				label = "SendToClient",
				type = "method",
				icon = "Method.png",
				args = { "recipient", "channel", "kind", "payload", "reliable" },
			},
			{
				label = "Broadcast",
				type = "method",
				icon = "Method.png",
				args = { "channel", "kind", "payload", "reliable" },
			},
			{
				label = "BroadcastFiltered",
				type = "method",
				icon = "Method.png",
				args = { "channel", "kind", "payload", "reliable", "filterFn" },
			},
			{
				label = "SendToMultipleClients",
				type = "method",
				icon = "Method.png",
				args = { "sessions", "channel", "kind", "payload", "reliable" },
			},
			{
				label = "GetCurrentTick",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetServerDataAsync",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetLocalPlayerUserId",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetSessionByUserId",
				type = "method",
				icon = "Method.png",
				args = { "userId" },
			},
			{
				label = "GetSessions",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetStatsSnapshot",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Ping",
				type = "method",
				icon = "Method.png",
				args = { "address", "port", "options" },
			},
			{
				label = "SetPreviewData",
				type = "method",
				icon = "Method.png",
				args = { "data" },
			},
			{
				label = "GetPreviewData",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ResetStats",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "payload",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "recipient",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "payload",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "payload",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "payload",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "reliable",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "sessions",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "channel",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "kind",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "payload",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "address",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "port",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PathfindingService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "Initenvironment",
				type = "method",
				icon = "Method.png",
				args = { "environment", "datamodel" },
			},
			{
				label = "CreatePath",
				type = "method",
				icon = "Method.png",
				args = { "agentParameters" },
			},
			{
				label = "FindPathAsync",
				type = "method",
				icon = "Method.png",
				args = { "startPos", "endPos" },
			},
			{
				label = "InvalidateNavMesh",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "environment",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "startPos",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Players",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "game" },
			},
			{
				label = "MaxPlayers",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Players",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "LocalPlayer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "SetupClient",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PlaytestService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "CreatePlaytestAsync",
				type = "method",
				icon = "Method.png",
				args = { "gameName" },
			},
			{
				label = "StopCurrentPlaytest",
				type = "method",
				icon = "Method.png",
				args = { "gameName" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Plugin",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PluginLoader",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "LoadPluginDir",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "LoadPluginCode",
				type = "method",
				icon = "Method.png",
				args = { "files" },
			},
			{
				label = "GetFileContents",
				type = "method",
				icon = "Method.png",
				args = { "fileName" },
			},
			{
				label = "plugin_require",
				type = "method",
				icon = "Method.png",
				args = { "filePath" },
			},
			{
				label = "DownloadPlugin",
				type = "method",
				icon = "Method.png",
				args = { "pluginManifest", "autoLoad" },
			},
			{
				label = "UnloadPlugin",
				type = "method",
				icon = "Method.png",
				args = { "pluginId" },
			},
			{
				label = "GetLoadedPlugins",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetPluginApi",
				type = "method",
				icon = "Method.png",
				args = { "id" },
			},
			{
				label = "GetPluginsMarketplace",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "pluginManifest",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "PoolerService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Process",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "CreateKinemiumClientProcess",
				type = "method",
				icon = "Method.png",
				args = { "flags" },
			},
			{
				label = "CreateKinemiumClientProcessEx",
				type = "method",
				icon = "Method.png",
				args = { "username", "ip", "port" },
			},
			{
				label = "CreateKinemiumServerProcessPiped",
				type = "method",
				icon = "Method.png",
				args = { "ip", "port", "maxPlayers" },
			},
			{
				label = "CreateKinemiumServerProcessEx",
				type = "method",
				icon = "Method.png",
				args = { "ip", "port" },
			},
			{
				label = "CreateKinemiumServerProcess",
				type = "method",
				icon = "Method.png",
				args = { "flags" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "username",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ip",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ip",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "port",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "ip",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ProfilerService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ProjectLoaderService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "GetProjects",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "StartObserve",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "NewProject",
				type = "method",
				icon = "Method.png",
				args = { "name", "path", "iconPath", "description" },
			},
			{
				label = "GetGamesAsSubmenu",
				type = "method",
				icon = "Method.png",
				args = { "func" },
			},
			{
				label = "onClick",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "path",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "iconPath",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ProjectSyncService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "StartSyncing",
				type = "method",
				icon = "Method.png",
				args = { "projectPath", "options" },
			},
			{
				label = "Refresh",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "StopSyncing",
				type = "method",
				icon = "Method.png",
				args = { "clearManaged" },
			},
			{
				label = "IsSyncing",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetStatus",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetConfig",
				type = "method",
				icon = "Method.png",
				args = { "projectPath" },
			},
			{
				label = "ScheduleRefresh",
				type = "method",
				icon = "Method.png",
				args = { "reason" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "projectPath",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RBXModelImporter",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "ImportModel",
				type = "method",
				icon = "Method.png",
				args = { "binary" },
			},
			{
				label = "ImportPlace",
				type = "method",
				icon = "Method.png",
				args = { "binary" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ReplicatedStorage",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "ReplicatorService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "RegisterStateAdapter",
				type = "method",
				icon = "Method.png",
				args = { "name", "adapter" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "RunService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "BindToRenderStep",
				type = "method",
				icon = "Method.png",
				args = { "name", "priority", "callback" },
			},
			{
				label = "UnbindFromRenderStep",
				type = "method",
				icon = "Method.png",
				args = { "name" },
			},
			{
				label = "BindToSimulation",
				type = "method",
				icon = "Method.png",
				args = { "callback", "frequency" },
			},
			{
				label = "GetSimulationBindings",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetSimulationTick",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetSimulationDT",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "PerformRollback",
				type = "method",
				icon = "Method.png",
				args = { "rollbackTick" },
			},
			{
				label = "SetPredictionMode",
				type = "method",
				icon = "Method.png",
				args = { "context", "mode" },
			},
			{
				label = "GetPredictedInstances",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetPredictionStatus",
				type = "method",
				icon = "Method.png",
				args = { "context" },
			},
			{
				label = "Pause",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Resume",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsPaused",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "SetSchedulerFPS",
				type = "method",
				icon = "Method.png",
				args = { "fps" },
			},
			{
				label = "IsClient",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsServer",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsStudio",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsRunMode",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsRunning",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsEdit",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetFPS",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "priority",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "callback",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "context",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ScriptContext",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "NewRuntime",
				type = "method",
				icon = "Method.png",
				args = { "api" },
			},
			{
				label = "GetActiveThreads",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetRuntimeThreadsActive",
				type = "method",
				icon = "Method.png",
				args = { "language" },
			},
			{
				label = "KillThread",
				type = "method",
				icon = "Method.png",
				args = { "uniqueId", "language" },
			},
			{
				label = "MakeThreadObject",
				type = "method",
				icon = "Method.png",
				args = { "scriptInstance" },
			},
			{
				label = "RunClientScripts",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "RunServerScripts",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "uniqueId",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Selection",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "Get",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Add",
				type = "method",
				icon = "Method.png",
				args = { "Object" },
			},
			{
				label = "Remove",
				type = "method",
				icon = "Method.png",
				args = { "toRemove" },
			},
			{
				label = "Clear",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "IsSelected",
				type = "method",
				icon = "Method.png",
				args = { "object" },
			},
			{
				label = "Set",
				type = "method",
				icon = "Method.png",
				args = { "data" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SerializationService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "SerializeInstancesAsync",
				type = "method",
				icon = "Method.png",
				args = { "instances" },
			},
			{
				label = "Deserialize",
				type = "method",
				icon = "Method.png",
				args = { "str", "cb" },
			},
			{
				label = "Encode",
				type = "method",
				icon = "Method.png",
				args = { "value" },
			},
			{
				label = "Decode",
				type = "method",
				icon = "Method.png",
				args = { "value" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "str",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ServerScriptService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "ServerStorage",
		type = "class",
		icon = "Class.png",
	},
	{
		label = "SoundService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SQLiteService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "CreateBase",
				type = "method",
				icon = "Method.png",
				args = { "name" },
			},
			{
				label = "Open",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "GetAsync",
				type = "method",
				icon = "Method.png",
				args = { "key", "callback" },
			},
			{
				label = "SetAsync",
				type = "method",
				icon = "Method.png",
				args = { "key", "value", "callback" },
			},
			{
				label = "UpdateAsync",
				type = "method",
				icon = "Method.png",
				args = { "key", "transform" },
			},
			{
				label = "Close",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "key",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "key",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "value",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "key",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "StarterGui",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "StarterPlayer",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "SteamService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "StudioThemeService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "datamodel" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TextService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "MeasureText",
				type = "method",
				icon = "Method.png",
				args = { "text", "font", "textSize", "spacing" },
			},
			{
				label = "measureMultilineText",
				type = "method",
				icon = "Method.png",
				args = { "text", "font", "textSize", "spacing" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "text",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "font",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "textSize",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "text",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "font",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "textSize",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TweenService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "RegisterEasingStyle",
				type = "method",
				icon = "Method.png",
				args = { "name", "easingFunction" },
			},
			{
				label = "GetValue",
				type = "method",
				icon = "Method.png",
				args = { "alpha", "style", "direction" },
			},
			{
				label = "GetActiveTweens",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "CancelAll",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "Create",
				type = "method",
				icon = "Method.png",
				args = { "object", "tweenInfo", "properties" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "alpha",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "style",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "object",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "tweenInfo",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UnifiedPhysicsService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal", "game" },
			},
			{
				label = "RegisterEngine",
				type = "method",
				icon = "Method.png",
				args = { "name", "handler" },
			},
			{
				label = "SetPrimaryEngine",
				type = "method",
				icon = "Method.png",
				args = { "name" },
			},
			{
				label = "GetPrimaryEngineName",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer_signal",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "name",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "UserInputService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "VideoService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "datamodel" },
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "WebviewService",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "renderer_signal" },
			},
			{
				label = "MakeULHTMLObj",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "MakeRaylibImage",
				type = "method",
				icon = "Method.png",
				args = { "htmlPath", "w", "h" },
			},
			{
				label = "CreateWindow",
				type = "method",
				icon = "Method.png",
				args = { "title", "x", "y" },
			},
			{
				label = "Navigate",
				type = "method",
				icon = "Method.png",
				args = { "site" },
			},
			{
				label = "SetTitle",
				type = "method",
				icon = "Method.png",
				args = { "title" },
			},
			{
				label = "SetSize",
				type = "method",
				icon = "Method.png",
				args = { "x", "y" },
			},
			{
				label = "Run",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ExplorerHidden",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "htmlPath",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "w",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "title",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "x",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "x",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Workspace",
		type = "class",
		icon = "Class.png",
		members = {
			{
				label = "InitRenderer",
				type = "method",
				icon = "Method.png",
				args = { "renderer", "signal", "game" },
			},
			{
				label = "self",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "renderer",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "signal",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "BlobLoader",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Box2DService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ChatService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "CollectionService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ConfigService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ContentService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "CoreGui",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Debris",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "DiscordService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "EncodingService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "FileDialogService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "GeometryService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "GuiStackService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "HttpService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "HUDService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "InputActionService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "InternalStorage",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "JoltPhysicsService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KineFileService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumFFI",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumFontService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumIconLoader",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumModService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumRaylib",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "KinemiumShaderService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Lighting",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "LogicGateService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "LogService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "NetworkService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PathfindingService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Players",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PlaytestService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Plugin",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PluginLoader",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "PoolerService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Process",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ProfilerService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ProjectLoaderService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ProjectSyncService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "RBXModelImporter",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ReplicatedStorage",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ReplicatorService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "RunService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ScriptContext",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Selection",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "SerializationService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ServerScriptService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "ServerStorage",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "SoundService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "SQLiteService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "StarterGui",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "StarterPlayer",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "SteamService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "StudioThemeService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "TextService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "TweenService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "UnifiedPhysicsService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "UserInputService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "VideoService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "WebviewService",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Workspace",
		type = "service",
		icon = "Service.png",
	},
	{
		label = "Instance",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "className", "parent" },
			},
		},
	},
	{
		label = "Axes",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z", "top", "bottom", "left", "right", "front", "back" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "BoundingBox",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "min", "max" },
			},
			{
				label = "empty",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "BrickColor",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "Random",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "val" },
			},
			{
				label = "palette",
				type = "method",
				icon = "Method.png",
				args = { "id" },
			},
			{
				label = "fromColor3",
				type = "constructor",
				icon = "Function.png",
				args = { "c3" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "White",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Gray",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "DarkGray",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Black",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Red",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Yellow",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Green",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Blue",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CFrame",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "..." },
			},
			{
				label = "lookAt",
				type = "method",
				icon = "Method.png",
				args = { "pos", "target", "up" },
			},
			{
				label = "ProjectPointOntoPlane",
				type = "method",
				icon = "Method.png",
				args = { "point", "normal" },
			},
			{
				label = "fromEulerAnglesXYZ",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z" },
			},
			{
				label = "fromEulerAnglesYXZ",
				type = "constructor",
				icon = "Function.png",
				args = { "y", "x", "z" },
			},
			{
				label = "fromAxisAngle",
				type = "constructor",
				icon = "Function.png",
				args = { "axis", "angle" },
			},
			{
				label = "fromMatrix",
				type = "constructor",
				icon = "Function.png",
				args = { "pos", "x", "y", "z" },
			},
			{
				label = "FromRelative",
				type = "constructor",
				icon = "Function.png",
				args = { "parent", "relative" },
			},
			{
				label = "Angles",
				type = "method",
				icon = "Method.png",
				args = { "x", "y", "z" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "fromQuaternion",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z", "w", "pos" },
			},
			{
				label = "fromOrientation",
				type = "constructor",
				icon = "Function.png",
				args = { "rx", "ry", "rz" },
			},
			{
				label = "identity",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "CFrame2D",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "..." },
			},
			{
				label = "fromAngle",
				type = "constructor",
				icon = "Function.png",
				args = { "pos", "angle" },
			},
			{
				label = "FromRelative",
				type = "constructor",
				icon = "Function.png",
				args = { "parent", "relative" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "CFrameQuat16",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "px", "py", "pz", "qx", "qy", "qz", "qw" },
			},
			{
				label = "fromCFrame",
				type = "constructor",
				icon = "Function.png",
				args = { "cf" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "CFrameint16",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z", "r00", "r01", "r02", "r10", "r11", "r12", "r20", "r21", "r22" },
			},
			{
				label = "fromCFrame",
				type = "constructor",
				icon = "Function.png",
				args = { "cf" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Color3",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "r", "g", "b" },
			},
			{
				label = "fromRGB",
				type = "constructor",
				icon = "Function.png",
				args = { "r", "g", "b" },
			},
			{
				label = "fromHSV",
				type = "constructor",
				icon = "Function.png",
				args = { "h", "s", "v" },
			},
			{
				label = "fromHex",
				type = "constructor",
				icon = "Function.png",
				args = { "hex" },
			},
			{
				label = "fromColor4",
				type = "constructor",
				icon = "Function.png",
				args = { "color4" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Color4",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "r", "g", "b", "a" },
			},
			{
				label = "fromRGB",
				type = "constructor",
				icon = "Function.png",
				args = { "r", "g", "b", "a" },
			},
			{
				label = "fromHSV",
				type = "constructor",
				icon = "Function.png",
				args = { "h", "s", "v", "a" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "ColorSequence",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "keypoints" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "ColorSequenceKeypoint",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "position", "color" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "CustomPhysicalProperties",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "density", "friction", "elasticity", "frictionWeight", "elasticityWeight" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "DateTime",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "now",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "fromUnixTimestamp",
				type = "constructor",
				icon = "Function.png",
				args = { "timestamp" },
			},
			{
				label = "fromIsoDate",
				type = "constructor",
				icon = "Function.png",
				args = { "isoDate" },
			},
			{
				label = "fromUnixTimestampMillis",
				type = "constructor",
				icon = "Function.png",
				args = { "ms" },
			},
			{
				label = "fromLocalDate",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "nowMillis",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Disposable",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
			},
			{
				label = "CleanupTask",
				type = "method",
				icon = "Method.png",
				args = { "task", "methodName" },
			},
		},
	},
	{
		label = "NumberRange",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "minVal", "maxVal" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "NumberSequence",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "..." },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "NumberSequenceKeypoint",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "t", "v" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "ClassName",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Octree",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "center", "size", "capacity", "maxDepth", "looseFactor" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "OverlapParams",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Promise",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "executor" },
			},
			{
				label = "resolve",
				type = "method",
				icon = "Method.png",
				args = { "value" },
			},
			{
				label = "reject",
				type = "method",
				icon = "Method.png",
				args = { "reason" },
			},
			{
				label = "all",
				type = "method",
				icon = "Method.png",
				args = { "promises" },
			},
			{
				label = "race",
				type = "method",
				icon = "Method.png",
				args = { "promises" },
			},
			{
				label = "any",
				type = "method",
				icon = "Method.png",
				args = { "promises" },
			},
			{
				label = "allSettled",
				type = "method",
				icon = "Method.png",
				args = { "promises" },
			},
			{
				label = "delay",
				type = "method",
				icon = "Method.png",
				args = { "ms", "value" },
			},
			{
				label = "await",
				type = "method",
				icon = "Method.png",
				args = { "promise" },
			},
			{
				label = "promisify",
				type = "method",
				icon = "Method.png",
				args = { "fn" },
			},
			{
				label = "andThen",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Quadtree",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "w", "h", "capacity", "maxDepth" },
			},
		},
	},
	{
		label = "Quaternion",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z", "w" },
			},
			{
				label = "identity",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "fromAxisAngle",
				type = "constructor",
				icon = "Function.png",
				args = { "axis", "angle" },
			},
			{
				label = "fromEuler",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z" },
			},
			{
				label = "slerp",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "t" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Random",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "seed" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Ray",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "origin", "direction" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "RaycastParams",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "RaycastResult",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "instance", "position", "normal", "material", "distance" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "ReactPointer",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
			},
		},
	},
	{
		label = "Rect",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "min", "max" },
			},
			{
				label = "fromCoords",
				type = "constructor",
				icon = "Function.png",
				args = { "minX", "minY", "maxX", "maxY" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Region3",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "min", "max" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Region3int16",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "min", "max" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Route",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "add",
				type = "method",
				icon = "Method.png",
				args = { "path", "handler" },
			},
			{
				label = "remove",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "clear",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "count",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "list",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "has",
				type = "method",
				icon = "Method.png",
				args = { "path" },
			},
			{
				label = "use",
				type = "method",
				icon = "Method.png",
				args = { "fn" },
			},
			{
				label = "on",
				type = "method",
				icon = "Method.png",
				args = { "event", "fn" },
			},
			{
				label = "handle",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "deselect",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "callSafe",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "routes",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "middlewares",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "hooks",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "cleanup",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Schema",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "string",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "nonEmptyString",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "stringPattern",
				type = "method",
				icon = "Method.png",
				args = { "pattern" },
			},
			{
				label = "number",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "int",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "u32",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "float",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "positive",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "negative",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "min",
				type = "method",
				icon = "Method.png",
				args = { "minValue" },
			},
			{
				label = "max",
				type = "method",
				icon = "Method.png",
				args = { "maxValue" },
			},
			{
				label = "range",
				type = "method",
				icon = "Method.png",
				args = { "minValue", "maxValue" },
			},
			{
				label = "boolean",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "any",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "positiveInt",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "negativeInt",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "u8",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "u16",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "u64",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "i8",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "i16",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "i32",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "i64",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "allOf",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "anyOf",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "notf",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "minItems",
				type = "method",
				icon = "Method.png",
				args = { "min" },
			},
			{
				label = "maxItems",
				type = "method",
				icon = "Method.png",
				args = { "max" },
			},
			{
				label = "itemCount",
				type = "method",
				icon = "Method.png",
				args = { "min", "max" },
			},
			{
				label = "exact",
				type = "method",
				icon = "Method.png",
				args = { "expected" },
			},
			{
				label = "strictMap",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "noExtraKeys",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "transform",
				type = "method",
				icon = "Method.png",
				args = { "validator", "transformFn" },
			},
			{
				label = "coerceNumber",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "lazy",
				type = "method",
				icon = "Method.png",
				args = { "getValidator" },
			},
			{
				label = "nullable",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "oneOf",
				type = "method",
				icon = "Method.png",
				args = { "values" },
			},
			{
				label = "instanceOf",
				type = "method",
				icon = "Method.png",
				args = { "typeName" },
			},
			{
				label = "tuple",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "record",
				type = "method",
				icon = "Method.png",
				args = { "valueValidator" },
			},
			{
				label = "nonEmptyArray",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "sortedArray",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "uniqueBy",
				type = "method",
				icon = "Method.png",
				args = { "keyFn" },
			},
			{
				label = "custom",
				type = "method",
				icon = "Method.png",
				args = { "fn" },
			},
			{
				label = "deepEqual",
				type = "method",
				icon = "Method.png",
				args = { "expected" },
			},
			{
				label = "throttle",
				type = "method",
				icon = "Method.png",
				args = { "min", "max" },
			},
			{
				label = "finite",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "nonNaN",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "trimmedString",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "lowercase",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "uppercase",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "startsWith",
				type = "method",
				icon = "Method.png",
				args = { "prefix" },
			},
			{
				label = "endsWith",
				type = "method",
				icon = "Method.png",
				args = { "suffix" },
			},
			{
				label = "contains",
				type = "method",
				icon = "Method.png",
				args = { "substr" },
			},
			{
				label = "even",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "odd",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "betweenExclusive",
				type = "method",
				icon = "Method.png",
				args = { "min", "max" },
			},
			{
				label = "multipleOf",
				type = "method",
				icon = "Method.png",
				args = { "n" },
			},
			{
				label = "arrayLengthExactly",
				type = "method",
				icon = "Method.png",
				args = { "n" },
			},
			{
				label = "hasKeys",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "keyType",
				type = "method",
				icon = "Method.png",
				args = { "keyValidator" },
			},
			{
				label = "valueType",
				type = "method",
				icon = "Method.png",
				args = { "valueValidator" },
			},
			{
				label = "default",
				type = "method",
				icon = "Method.png",
				args = { "defaultValue", "validator" },
			},
			{
				label = "decimal",
				type = "method",
				icon = "Method.png",
				args = { "precision" },
			},
			{
				label = "email",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "noHoles",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "readonly",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "frozen",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "callable",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "metatable",
				type = "method",
				icon = "Method.png",
				args = { "expected" },
			},
			{
				label = "deepArray",
				type = "method",
				icon = "Method.png",
				args = { "depth", "validator" },
			},
			{
				label = "shape",
				type = "method",
				icon = "Method.png",
				args = { "shapeFn" },
			},
			{
				label = "guard",
				type = "method",
				icon = "Method.png",
				args = { "predicate" },
			},
			{
				label = "pipe",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "url",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "uuid",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "hexColor",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "length",
				type = "method",
				icon = "Method.png",
				args = { "min", "max" },
			},
			{
				label = "arrayOf",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "setOf",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "dict",
				type = "method",
				icon = "Method.png",
				args = { "keyValidator", "valueValidator" },
			},
			{
				label = "timestamp",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "dateString",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "timeString",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "vector2",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "vector3",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "color3",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "position3D",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "enum",
				type = "method",
				icon = "Method.png",
				args = { "enumTable" },
			},
			{
				label = "optional",
				type = "method",
				icon = "Method.png",
				args = { "validator" },
			},
			{
				label = "emptyTable",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "exactKeys",
				type = "method",
				icon = "Method.png",
				args = { "..." },
			},
			{
				label = "partial",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "zero",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "nonZero",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "clamped",
				type = "method",
				icon = "Method.png",
				args = { "min", "max" },
			},
			{
				label = "identifier",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "snakeCase",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "camelCase",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "component",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "entityId",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "xor",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "implies",
				type = "method",
				icon = "Method.png",
				args = { "a", "b" },
			},
			{
				label = "when",
				type = "method",
				icon = "Method.png",
				args = { "predicate", "thenValidator", "elseValidator" },
			},
			{
				label = "noMetatable",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "shallowImmutable",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "assert",
				type = "method",
				icon = "Method.png",
				args = { "validator", "message" },
			},
			{
				label = "debug",
				type = "method",
				icon = "Method.png",
				args = { "name", "validator" },
			},
			{
				label = "kebabCase",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "table",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "map",
				type = "method",
				icon = "Method.png",
				args = { "definition" },
			},
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "definition" },
			},
		},
	},
	{
		label = "Shader",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "fromMemory",
				type = "constructor",
				icon = "Function.png",
				args = { "vs", "fs" },
			},
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "source" },
			},
		},
	},
	{
		label = "Signal",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
			},
			{
				label = "wrap",
				type = "method",
				icon = "Method.png",
				args = { "signal" },
			},
		},
	},
	{
		label = "Spring",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "damping", "frequency", "typeName", "initialValue" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "target",
				type = "method",
				icon = "Method.png",
				args = { "object", "damping", "frequency", "props" },
			},
			{
				label = "stepTargets",
				type = "method",
				icon = "Method.png",
				args = { "dt" },
			},
		},
	},
	{
		label = "Datatypes",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "Number",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Vector3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color3",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "CFrame",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UDim",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Color4",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "UDim2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "NumberRange",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Rect",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Vector2",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Axes",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "Ray",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "StateMachine",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "initial" },
			},
			{
				label = "ClassName",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "TweenInfo",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "time", "easingStyle", "easingDirection", "repeatCount", "reverses", "delayTime" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "UDim",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "scale", "offset" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "UDim2",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "xScale", "xOffset", "yScale", "yOffset" },
			},
			{
				label = "fromScale",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y" },
			},
			{
				label = "fromOffset",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y" },
			},
			{
				label = "FromPixels",
				type = "constructor",
				icon = "Function.png",
				args = { "pixels", "referenceSize" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "ValueCurveKey",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "time", "value", "interpolation" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
		},
	},
	{
		label = "Vector2",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "Zero",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "One",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Vector2int16",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "x",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "y",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Vector3",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z" },
			},
			{
				label = "Slerp",
				type = "method",
				icon = "Method.png",
				args = { "a", "b", "t" },
			},
			{
				label = "RotationMatrix",
				type = "method",
				icon = "Method.png",
				args = { "axis", "angle" },
			},
			{
				label = "RandomUnit",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "zero",
				type = "property",
				icon = "Property.png",
			},
			{
				label = "one",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Vector3int16",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "x", "y", "z" },
			},
			{
				label = "FromTable",
				type = "constructor",
				icon = "Function.png",
				args = { "tbl" },
			},
			{
				label = "zero",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Video",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "url", "length", "framerate" },
			},
			{
				label = "ClassName",
				type = "property",
				icon = "Property.png",
			},
		},
	},
	{
		label = "Class",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "New",
				type = "method",
				icon = "Method.png",
				args = { "name", "base" },
			},
			{
				label = "IsInstance",
				type = "method",
				icon = "Method.png",
				args = { "obj", "cls" },
			},
		},
	},
	{
		label = "registry",
		type = "library",
		icon = "Module.png",
		members = {
			{
				label = "createclass",
				type = "method",
				icon = "Method.png",
				args = { "data" },
			},
			{
				label = "getClasses",
				type = "method",
				icon = "Method.png",
			},
			{
				label = "ClassValid",
				type = "method",
				icon = "Method.png",
				args = { "class" },
			},
			{
				label = "new",
				type = "constructor",
				icon = "Function.png",
				args = { "class", "renderer", "datamodel", "force" },
			},
		},
	},
}

return completions
