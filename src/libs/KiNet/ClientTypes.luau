-- type definitions for Client module

export type Socket = {
	bindIp: (self: Socket, ip: string, port: number) -> (),
	sendMsg: (self: Socket, port: number, address: string, data: buffer | string) -> (),
	recvMsg: (self: Socket, maxSize: number) -> (string, buffer | string),
	close: (self: Socket) -> (),
}

export type MessageData = {
	type: string?,
	timestamp: number?,
	sequence: number?,
	sessionId: string?,
	messageId: string?,
	reliable: boolean?,
	authToken: string?,
	fragment: boolean?,
	fragmentIndex: number?,
	totalFragments: number?,
	data: any?,
	[string]: any,
}

export type Fragment = {
	fragment: boolean,
	messageId: string?,
	fragmentIndex: number?,
	totalFragments: number?,
	data: any,
}

export type PendingAck = {
	fragments: { Fragment },
	attempts: number,
	lastSent: number,
	channel: string?,
	kind: string?,
	fragmentCount: number?,
}

export type FragmentBuffer = {
	fragments: { [number]: buffer | string },
	totalFragments: number,
	received: number,
	totalBytes: number?,
	createdAt: number?,
	lastUpdated: number?,
}

export type Client = {
	Socket: Socket?,
	ServerAddress: string,
	ServerPort: number,
	AuthToken: string,
	SessionId: string?,
	IsAuthenticated: boolean,
	LastHeartbeat: number,
	MessageSequence: number,
	ReceivedSequences: { [number]: boolean },
	ReceivedSequenceRing: { number }?,
	ReceivedSequenceIndex: number?,
	ReceivedSequenceCount: number?,
	HighestReceivedSequence: number,
	ProcessedReliableMessages: { [string]: boolean }?,
	ProcessedReliableRing: { string }?,
	ProcessedReliableIndex: number?,
	ProcessedReliableCount: number?,
	RateLimitRing: { number }?,
	RateLimitIndex: number?,
	RateLimitCount: number?,
	RateLimitCapacity: number?,
	MaxMessagesPerSecond: number,
	PendingAcks: { [string]: PendingAck },
	FragmentBuffer: { [string]: FragmentBuffer },
	ReliableQueue: { any },
	_OnShutdown: (() -> ())?,

	Init: (self: Client, serverAddress: string?, serverPort: number?, authToken: string?) -> Socket,
	GenerateToken: (self: Client) -> string,
	ValidateMessage: (self: Client, data: MessageData) -> (boolean, string?),
	CheckRateLimit: (self: Client) -> boolean,
	FragmentMessage: (self: Client, data: MessageData, messageId: string) -> { Fragment },
	ReassembleFragments: (self: Client, fragmentData: Fragment) -> MessageData?,
	SendReliable: (self: Client, data: MessageData) -> (),
	SendRaw: (self: Client, data: MessageData) -> (),
	ProcessReliableQueue: (self: Client) -> (),
	OnShutdown: (self: Client, callback: () -> ()) -> (),
	Connect: (self: Client) -> (),
	OnRecieve: (self: Client, callback: (addr: string, data: MessageData) -> ()) -> (),
	Disconnect: (self: Client) -> (),
	Send: (self: Client, data: MessageData, reliable: boolean?) -> (),
	StartHeartbeat: (self: Client) -> (),
	Listen: (self: Client) -> (),
	_middleware: (data: MessageData | string, addr: string) -> (),
}

return {}
