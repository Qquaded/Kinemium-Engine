type Middleware = (path: string, ...any) -> (boolean?)  -- return true to stop
type Handler = (...any) -> any
type Hook = (path: string) -> ()

type SchemaType = {
    string: () -> (value: any) -> boolean,
    nonEmptyString: () -> (value: any) -> boolean,
    stringPattern: (pattern: string) -> (value: any) -> boolean,
    number: () -> (value: any) -> boolean,
    int: () -> (value: any) -> boolean,
    u32: () -> (value: any) -> boolean,
    float: () -> (value: any) -> boolean,
    positive: () -> (value: any) -> boolean,
    negative: () -> (value: any) -> boolean,
    min: (minValue: number) -> (value: any) -> boolean,
    max: (maxValue: number) -> (value: any) -> boolean,
    range: (minValue: number, maxValue: number) -> (value: any) -> boolean,
    boolean: () -> (value: any) -> boolean,
    any: () -> (value: any) -> boolean,
    positiveInt: () -> (value: any) -> boolean,
    negativeInt: () -> (value: any) -> boolean,
    u8: () -> (value: any) -> boolean,
    u16: () -> (value: any) -> boolean,
    u64: () -> (value: any) -> boolean,
    i8: () -> (value: any) -> boolean,
    i16: () -> (value: any) -> boolean,
    i32: () -> (value: any) -> boolean,
    i64: () -> (value: any) -> boolean,
    allOf: (...any) -> (value: any) -> boolean,
    anyOf: (...any) -> (value: any) -> boolean,
    notf: ((value: any) -> boolean) -> (value: any) -> boolean,
    minItems: (min: number) -> (value: any) -> boolean,
    maxItems: (max: number) -> (value: any) -> boolean,
    itemCount: (min: number, max: number) -> (value: any) -> boolean,
    exact: (expected: any) -> (value: any) -> boolean,
    strictMap: (definition: { [any]: (any) -> boolean }) -> (value: any) -> boolean,
    noExtraKeys: (definition: { [any]: (any) -> boolean }) -> (value: any) -> boolean,
    transform: ((any) -> boolean, (any) -> any) -> (value: any) -> boolean,
    coerceNumber: () -> (value: any) -> boolean,
    lazy: (() -> (value: any) -> boolean) -> (value: any) -> boolean,
    trimmedString: () -> (value: any) -> boolean,
    lowercase: () -> (value: any) -> boolean,
    uppercase: () -> (value: any) -> boolean,
    startsWith: (prefix: string) -> (value: any) -> boolean,
    endsWith: (suffix: string) -> (value: any) -> boolean,
    contains: (substr: string) -> (value: any) -> boolean,
    even: () -> (value: any) -> boolean,
    odd: () -> (value: any) -> boolean,
    betweenExclusive: (min: number, max: number) -> (value: any) -> boolean,
    multipleOf: (n: number) -> (value: any) -> boolean,
    arrayLengthExactly: (n: number) -> (value: any) -> boolean,
    hasKeys: (...string) -> (value: any) -> boolean,
    keyType: ((key: any) -> boolean) -> (value: any) -> boolean,
    valueType: ((value: any) -> boolean) -> (value: any) -> boolean,
    default: (defaultValue: any, validator: (value: any) -> boolean) -> (value: any) -> boolean,
    decimal: (precision: number) -> (value: any) -> boolean,
    email: () -> (value: any) -> boolean,
    noHoles: () -> (value: any) -> boolean,
    readonly: () -> (value: any) -> boolean,
    frozen: () -> (value: any) -> boolean,
    callable: () -> (value: any) -> boolean,
    metatable: (expected: any) -> (value: any) -> boolean,
    deepArray: (depth: number, validator: (value: any) -> boolean) -> (value: any) -> boolean,
    shape: ((value: any) -> boolean) -> (value: any) -> boolean,
    guard: ((value: any) -> boolean) -> (value: any) -> boolean,
    pipe: (...(value: any) -> boolean) -> (value: any) -> boolean,
    url: () -> (value: any) -> boolean,
    uuid: () -> (value: any) -> boolean,
    hexColor: () -> (value: any) -> boolean,
    length: (min: number?, max: number?) -> (value: any) -> boolean,
    arrayOf: ((value: any) -> boolean) -> (value: any) -> boolean,
    setOf: ((value: any) -> boolean) -> (value: any) -> boolean,
    dict: ((key: any) -> boolean, (value: any) -> boolean) -> (value: any) -> boolean,
    timestamp: () -> (value: any) -> boolean,
    dateString: () -> (value: any) -> boolean,
    timeString: () -> (value: any) -> boolean,
    vector2: () -> (value: any) -> boolean,
    vector3: () -> (value: any) -> boolean,
    color3: () -> (value: any) -> boolean,
    position3D: () -> (value: any) -> boolean,
    enum: (enumTable: { any }) -> (value: any) -> boolean,
    optional: ((value: any) -> boolean) -> (value: any) -> boolean,
    emptyTable: () -> (value: any) -> boolean,
    exactKeys: (...string) -> (value: any) -> boolean,
    partial: ({ [any]: (value: any) -> boolean }) -> (value: any) -> boolean,
    zero: () -> (value: any) -> boolean,
    nonZero: () -> (value: any) -> boolean,
    clamped: (min: number, max: number) -> (value: any) -> boolean,
    identifier: () -> (value: any) -> boolean,
    snakeCase: () -> (value: any) -> boolean,
    camelCase: () -> (value: any) -> boolean,
    component: ({ [any]: (value: any) -> boolean }) -> (value: any) -> boolean,
    entityId: () -> (value: any) -> boolean,
    xor: ((value: any) -> boolean, (value: any) -> boolean) -> (value: any) -> boolean,
    implies: ((value: any) -> boolean, (value: any) -> boolean) -> (value: any) -> boolean,
    when: ((value: any) -> boolean, (value: any) -> boolean, ((value: any) -> boolean)?) -> (value: any) -> boolean,
    noMetatable: () -> (value: any) -> boolean,
    shallowImmutable: () -> (value: any) -> boolean,
    assert: ((value: any) -> boolean, string?) -> (value: any) -> boolean,
    debug: (string, (value: any) -> boolean) -> (value: any) -> boolean,
    kebabCase: () -> (value: any) -> boolean,
    table: ({ (value: any) -> boolean }) -> (value: any) -> boolean,
    map: ({ [any]: (value: any) -> boolean }) -> (value: any) -> boolean,
    new: (definition: any) -> any,
    validate: (self: any, packet: any) -> (boolean, string?, string?),
}

type Class = {
    __name: string,
    __index: any,
    __base: Class?,
    __type: "ClassType",

    New: (...any) -> any,
    Super: (Class, methodName: string, ...any) -> any,
}

type RouteEntry = {
    handler: Handler,
    pattern: string,
}

type RouteHooks = {
    onAdd: {Hook},
    onRemove: {Hook},
}

type Routes = {
    routes: {[string]: RouteEntry},
    middlewares: {Middleware},
    hooks: RouteHooks,

    add: (path: string, handler: Handler) -> (),
    remove: (path: string) -> (),
    clear: () -> (),
    count: () -> number,
    list: () -> {string},
    has: (path: string) -> boolean,
    use: (fn: Middleware) -> (),
    on: (event: "onAdd" | "onRemove", fn: Hook) -> (),
    handle: (path: string, ...any) -> (any, string?),
    callSafe: (path: string, ...any) -> (any, string?),
}

type ClassGlobal = {
    New: (name: string?, base: Class?) -> Class,
    IsInstance: (obj: any, cls: Class) -> boolean,
}

type Task = any

type Disposable = {
    _tasks: { { task: Task, method: string? } },
    _destroyed: boolean,

    Add: (self: Disposable, task: Task, methodName: string?) -> (),
    Remove: (self: Disposable, task: Task) -> (),
    Destroy: (self: Disposable) -> (),
    IsDestroyed: (self: Disposable) -> boolean,
}

type DisposableClass = {
    new: () -> Disposable,
    CleanupTask: (task: Task, methodName: string?) -> (),
}

type Connection = {
    Connected: boolean,
    Priority: number,
    Disconnect: (self: Connection) -> (),
    Fire: (self: Connection, ...any) -> (),
    SetPriority: (self: Connection, priority: number) -> (),
}

type Video = {
	Url: string,
	Length: number,
	Framerate: number,

	Clone: (self: Video) -> Video,
	Equals: (self: Video, other: any) -> boolean,
	GetFrameAtTime: (self: Video, seconds: number) -> number,
}

type VideoDatatype = {
	new: (url: string, length: number?, framerate: number?) -> Video,
	ClassName: string,
}

type Signal = {
    new: () -> Signal,
    Connect: (self: Signal, fn: (...any) -> (), priority: number?) -> Connection,
    Once: (self: Signal, fn: (...any) -> ()) -> Connection,
    Wait: (self: Signal, timeout: number?) -> (...any),
    Fire: (self: Signal, ...any) -> (),
    FireDeferred: (self: Signal, ...any) -> (),
    FireParallel: (self: Signal, ...any) -> (),
    Pause: (self: Signal) -> (),
    Resume: (self: Signal) -> (),
    IsPaused: (self: Signal) -> boolean,
}

type AABB = {
	id: number,
	position: Vector3,
	size: Vector3,
	data: any?,
}

type SerializedNode = {
	c: { number },
	s: number,
	d: number,
	o: {
		{
			id: number,
			p: { number },
			z: { number },
		}
	}?,
	ch: { SerializedNode }?,
}

type SerializedTree = {
	c: { number },
	s: number,
	cap: number,
	max: number,
	loose: number,
	root: SerializedNode,
}

type Node = {
	center: Vector3,
	size: number,
	depth: number,
	objects: { AABB },
	children: { Node }?,
}

type Octree = {
	center: Vector3,
	size: number,
	capacity: number,
	maxDepth: number,
	loose: number,
	root: Node,
	objectMap: { [number]: Node },

	Insert: (self: Octree, obj: AABB) -> boolean,
	Remove: (self: Octree, id: number) -> (),
	Update: (self: Octree, obj: AABB) -> (),
	QueryAABB: (self: Octree, center: Vector3, size: Vector3) -> { AABB },
	Clear: (self: Octree) -> (),
	ToTable: (self: Octree) -> SerializedTree,

	_subdivide: (self: Octree, node: Node) -> (),
	_insert: (self: Octree, node: Node, obj: AABB) -> boolean,
	_query: (self: Octree, node: Node, center: Vector3, size: Vector3, result: { AABB }) -> (),
}

type Quaternion = {
	X: number,
	Y: number,
	Z: number,
	W: number,

	Magnitude: (self: Quaternion) -> number,
	Normalize: (self: Quaternion) -> Quaternion,
	Conjugate: (self: Quaternion) -> Quaternion,
	Inverse: (self: Quaternion) -> Quaternion,
	RotateVector: (self: Quaternion, v: { X: number, Y: number, Z: number }) -> { X: number, Y: number, Z: number },
	ToMatrix4: (self: Quaternion) -> { number },
	ToTable: (self: Quaternion) -> { type: string, X: number, Y: number, Z: number, W: number },

	__tostring: (self: Quaternion) -> string,
}

type QuaternionModule = {
	new: (x: number?, y: number?, z: number?, w: number?) -> Quaternion,
	identity: () -> Quaternion,

	fromAxisAngle: (axis: { X: number, Y: number, Z: number }, angle: number) -> Quaternion,
	fromEuler: (x: number, y: number, z: number) -> Quaternion,

	slerp: (a: Quaternion, b: Quaternion, t: number) -> Quaternion,
	FromTable: (tbl: { type: string, X: number, Y: number, Z: number, W: number }) -> Quaternion,

	__mul: (a: Quaternion, b: Quaternion) -> Quaternion,
}

type ShaderSource = {
	vertex: string,
	fragment: string,
}

type Shader = {
	_vertex: string,
	_fragment: string,
	_shader: any,

	SetUniform: (self: Shader, name: string, value: number | { number } | { [string]: any }, isFloat: boolean?) -> (),
	GetUniformLoc: (self: Shader, field: string) -> number,
}

type ShaderModule = {
	new: (source: ShaderSource) -> Shader,
}

type Color3 = {
	R: number,
	G: number,
	B: number,

	Clamp: (self: Color3) -> Color3,
	PremultiplyAlpha: (self: Color3) -> Color3,
	BlendOver: (self: Color3, bg: Color3) -> Color3,
	Luminance: (self: Color3) -> number,
	Multiply: (self: Color3, other: Color3) -> Color3,
	ToRaylib: (self: Color3) -> { number },
	Lerp: (self: Color3, other: Color3, alpha: number) -> Color3,
	ToRGBA: (self: Color3) -> (number, number, number, number),
	ToTable: (self: Color3) -> { type: string, R: number, G: number, B: number, A: number },

	__tostring: (self: Color3) -> string,
}

type Color4 = {
	R: number,
	G: number,
	B: number,
	A: number,

	Clamp: (self: Color4) -> Color4,
	PremultiplyAlpha: (self: Color4) -> Color4,
	BlendOver: (self: Color4, bg: Color4) -> Color4,
	Luminance: (self: Color4) -> number,
	Multiply: (self: Color4, other: Color4) -> Color4,
	ToRaylib: (self: Color4) -> { number },
	Lerp: (self: Color4, other: Color4, alpha: number) -> Color4,
	ToRGBA: (self: Color4) -> (number, number, number, number),
	ToTable: (self: Color4) -> { type: string, R: number, G: number, B: number, A: number },

	__tostring: (self: Color4) -> string,
}

type Vector2 = {
	X: number,
	Y: number,

	Clone: (self: Vector2) -> Vector2,
	Magnitude: (self: Vector2) -> number,
	Unit: (self: Vector2) -> Vector2,

	Dot: (self: Vector2, other: Vector2) -> number,
	Distance: (self: Vector2, other: Vector2) -> number,
	Lerp: (self: Vector2, target: Vector2, alpha: number) -> Vector2,

	ToTable: (self: Vector2) -> {
		type: string,
		X: number,
		Y: number,
	},

	__tostring: (v: Vector2) -> string,
}

type Vector2Module = {
	new: (x: number?, y: number?) -> Vector2,
	FromTable: (tbl: {
		type: string,
		X: number,
		Y: number,
	}) -> Vector2,

	Zero: Vector2,
	One: Vector2,

	__add: (a: Vector2, b: Vector2) -> Vector2,
	__sub: (a: Vector2, b: Vector2) -> Vector2,
	__mul: (a: Vector2 | number, b: Vector2 | number) -> Vector2,
	__div: (a: Vector2, b: number) -> Vector2,
	__tostring: (v: Vector2) -> string,
}

type Color4Module = {
	new: (r: number?, g: number?, b: number?, a: number?) -> Color4,
	fromRGB: (r: number, g: number, b: number, a: number?) -> Color4,
	fromHSV: (h: number, s: number, v: number, a: number?) -> Color4,

	FromTable: (tbl: { type: string, R: number, G: number, B: number, A: number }) -> Color4,

	__add: (a: Color4, b: Color4) -> Color4,
	__sub: (a: Color4, b: Color4) -> Color4,
	__mul: (a: Color4 | number, b: Color4 | number) -> Color4,
	__div: (a: Color4, b: number) -> Color4,
	__unm: (a: Color4) -> Color4,
	__eq: (a: Color4, b: Color4) -> boolean,
}

type Rotation2x2 = {
	{ number }
}

type CFrame2D = {
	Position: Vector2,
	Rotation: Rotation2x2,

	Inverse: (self: CFrame2D) -> CFrame2D,
	PointToWorldSpace: (self: CFrame2D, point: Vector2) -> Vector2,
	PointToObjectSpace: (self: CFrame2D, point: Vector2) -> Vector2,
	Lerp: (self: CFrame2D, target: CFrame2D, alpha: number) -> CFrame2D,

	GetAngle: (self: CFrame2D) -> number,
	GetRightVector: (self: CFrame2D) -> Vector2,
	GetUpVector: (self: CFrame2D) -> Vector2,

	IsFinite: (self: CFrame2D) -> boolean,
	ToRelative: (self: CFrame2D, parent: CFrame2D) -> CFrame2D,

	ToTable: (self: CFrame2D) -> {
		type: string,
		Position: any,
		Rotation: Rotation2x2,
	},

	__tostring: (self: CFrame2D) -> string,
}

type CFrame2DModule = {
	new: (...any) -> CFrame2D,
	fromAngle: (pos: Vector2, angle: number) -> CFrame2D,

	FromRelative: (parent: CFrame2D, relative: CFrame2D) -> CFrame2D,
	FromTable: (tbl: {
		type: string,
		Position: any,
		Rotation: Rotation2x2,
	}) -> CFrame2D,

	__mul: (a: CFrame2D, b: CFrame2D) -> CFrame2D,
	__eq: (a: CFrame2D, b: CFrame2D) -> boolean,
}

type Vector3int16 = {
	X: number,
	Y: number,
	Z: number,

	ToVector3: (self: Vector3int16) -> Vector3,
	ToTable: (self: Vector3int16) -> {
		type: string,
		X: number,
		Y: number,
		Z: number,
	},

	__tostring: (self: Vector3int16) -> string,
}

type Vector3int16Module = {
	new: (x: number?, y: number?, z: number?) -> Vector3int16,

	FromTable: (tbl: {
		type: string,
		X: number,
		Y: number,
		Z: number,
	}) -> Vector3int16,

	__add: (a: Vector3int16, b: Vector3int16) -> Vector3int16,
	__sub: (a: Vector3int16, b: Vector3int16) -> Vector3int16,
	__mul: (a: Vector3int16 | number, b: Vector3int16 | number) -> Vector3int16,
	__div: (a: Vector3int16, b: Vector3int16 | number) -> Vector3int16,

	x: number?,
	y: number?,
	z: number?,
}

type CFrameint16 = {
	Position: Vector3int16,

	R00: number,
	R01: number,
	R02: number,

	R10: number,
	R11: number,
	R12: number,

	R20: number,
	R21: number,
	R22: number,

	ToCFrame: (self: CFrameint16) -> CFrame,
	ToTable: (self: CFrameint16) -> {
		type: string,
		Position: any,
		R00: number,
		R01: number,
		R02: number,
		R10: number,
		R11: number,
		R12: number,
		R20: number,
		R21: number,
		R22: number,
	},

	__tostring: (self: CFrameint16) -> string,
}

type CFrameint16Module = {
	new: (
		x: number?,
		y: number?,
		z: number?,
		r00: number?,
		r01: number?,
		r02: number?,
		r10: number?,
		r11: number?,
		r12: number?,
		r20: number?,
		r21: number?,
		r22: number?
	) -> CFrameint16,

	fromCFrame: (cf: CFrame) -> CFrameint16,

	FromTable: (tbl: {
		type: string,
		Position: {
			X: number,
			Y: number,
			Z: number,
		},
		R00: number,
		R01: number,
		R02: number,
		R10: number,
		R11: number,
		R12: number,
		R20: number,
		R21: number,
		R22: number,
	}) -> CFrameint16,
}

type UDim2 = {

}

type WindowConfig = {
	Explorer: {
		position: UDim2,
		anchorPoint: Vector2,
		size: UDim2,
	},
	Inspector: {
		position: UDim2,
		anchorPoint: Vector2,
		size: UDim2,
	},
	Output: {
		position: UDim2,
		anchorPoint: Vector2,
		size: UDim2,
	},
	Toolbar: {
		position: UDim2,
		anchorPoint: Vector2,
		size: UDim2,
	},
}

type AereonWindow = {
	BackgroundColor: Color3,
	BackgroundTransparency: number,
	TextColor: Color3,
	SecondaryBackgroundColor: Color3,
	DragColor: Color3,
	DragOutlineTransparency: number,
	TitleBackgroundTransparency: number,
	TitleTextSize: number,
	TitleColor: Color3,
	TitleHeight: number,
	ShadowsEnabled: boolean,
	ShadowTransparency: number,
	ShadowColor: Color3,
}

type AereonIDEAutocomplete = {
	BackgroundColor: Color3,
	OutlineColor: Color3,
	ItemSelectColor: Color3,
	OutlineThickness: number,
	OutlineTransparency: number,
	CornerRadius: number,
	Width: number,
	Height: number,
	ListPadding: number,
}

type AereonIDE = {
	BackgroundColor: Color3,
	SecondaryBackgroundColor: Color3,
	TextColor: Color3,
	currentLineColor: Color3,
	autocomplete: AereonIDEAutocomplete,
}

type AereonTheme = {
	window: AereonWindow,
	ide: AereonIDE,
}

type Theme = {
	WindowConfig: WindowConfig,

	TextColor: Color3,
	ImageColor: Color3,
	ImageTransparency: number,
	GuiHandlesColor: Color3,
	GuiHandlesTransparency: number,
	TextTransparency: number,

	BackgroundColor: Color3,
	BackgroundTransparency: number,

	SecondaryTextTransparency: number,
	SecondaryTextColor: Color3,

	SecondaryBackgroundColor: Color3,
	ThirdBackgroundColor: Color3,
	SecondaryBackgroundColorTransparency: number,

	Accent: Color3,
	AccentTransparency: number,

	WindowBackgroundColor: Color3,
	WindowBackgroundTransparency: number,

	TitleTextSize: number,
	WindowTitleHeight: number,

	ShadowsEnabled: boolean,
	ShadowTransparency: number,
	CornerRadius: number,
	ShadowColor: Color3,

	ArrowImageColor: Color3,
	TitleColor: Color3,

	aereon: AereonTheme,
}

type ThemeCollection = {
	SelectedTheme: Theme,
}

type include = (path: string) -> (any)
type FlagExists = (flag: string) -> (boolean)

type int = any
type float = any
type double = any
type bool = any
type char = any
type int8_t = any
type int16_t = any
type int32_t = any
type int64_t = any
type uint8_t = any
type uint16_t = any
type uint32_t = any
type uint64_t = any
type i8 = any
type i16 = any
type i32 = any
type i64 = any
type i128 = any
type u8 = any
type u16 = any
type u32 = any
type u64 = any
type u128 = any
type f32 = any
type f64 = any
type wchar_t = any
type size_t = any
type ptrdiff_t = any
type long = any
type short = any
type byte = any
type word = any
type dword = any
type qword = any
type uchar = any
type uint = any
type ulong = any
type ushort = any
type const = any
type static = any
type volatile = any
type auto = any
type signed = any
type unsigned = any
type let = any
type mut = any
type var = any
type long_long = any
type unsigned_int = any
type unsigned_long = any
type unsigned_char = any
type signed_int = any
type signed_char = any
type ptr = any
type ref = any
type nullptr_t = any

declare int: int
declare float: float
declare double: double
declare bool: bool
declare char: char
declare int8_t: int8_t
declare int16_t: int16_t
declare int32_t: int32_t
declare int64_t: int64_t
declare uint8_t: uint8_t
declare uint16_t: uint16_t
declare uint32_t: uint32_t
declare uint64_t: uint64_t
declare i8: i8
declare i16: i16
declare i32: i32
declare i64: i64
declare i128: i128
declare u8: u8
declare u16: u16
declare u32: u32
declare u64: u64
declare u128: u128
declare f32: f32
declare f64: f64
declare wchar_t: wchar_t
declare size_t: size_t
declare ptrdiff_t: ptrdiff_t
declare long: long
declare short: short
declare byte: byte
declare word: word
declare dword: dword
declare qword: qword
declare uchar: uchar
declare uint: uint
declare ulong: ulong
declare ushort: ushort
declare const: const
declare static: static
declare volatile: volatile
declare auto: auto
declare signed: signed
declare unsigned: unsigned
declare var: var
declare let: let
declare mut: mut
declare long_long: long_long
declare unsigned_int: unsigned_int
declare unsigned_long: unsigned_long
declare unsigned_char: unsigned_char
declare signed_int: signed_int
declare signed_char: signed_char
declare ptr: ptr
declare ref: ref
declare nullptr_t: nullptr_t
declare Signal: Signal
declare Disposable: DisposableClass
declare kiclass: ClassGlobal
declare Routes: Routes
declare Shader: ShaderModule
declare Quaternion: QuaternionModule
declare Color4: Color4Module
declare CFrame2D: CFrame2DModule
declare CFrameint16: CFrameint16Module
declare Schema: SchemaType
declare Octree: Octree
declare Theme: ThemeCollection
declare Vector3int16: Vector3int16Module
declare ishared: {any}
declare shared: {}
declare Video: VideoDatatype
declare FlagExists: FlagExists
declare include: include