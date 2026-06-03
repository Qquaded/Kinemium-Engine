export type Socket = {
	bindIp: (self: Socket, ip: string, port: number) -> (),
	sendMsg: (self: Socket, port: number, address: string, data: buffer | string) -> (),
	recvMsg: (self: Socket, maxSize: number) -> (Address, buffer | string),
	close: (self: Socket) -> (),
}

export type Address = {
	address: string,
	port: number,
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
	reason: string?,
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

export type ConnectedClient = {
	address: string,
	port: number,
	sessionId: string,
	authenticated: boolean,
	connectedAt: number,
	lastHeartbeat: number,
	lastSequence: number?,
	recentSequences: { [number]: boolean }?,
	recentSequenceRing: { number }?,
	recentSequenceIndex: number?,
	recentSequenceCount: number?,
	highestSequence: number?,
	processedReliableMessages: { [string]: boolean }?,
	processedReliableRing: { string }?,
	processedReliableIndex: number?,
	processedReliableCount: number?,
	rateLimitRing: { number }?,
	rateLimitIndex: number?,
	rateLimitCount: number?,
	fragmentBuffer: { [string]: FragmentBuffer },
	pendingAcks: { [string]: PendingAck },
}

export type BannedAddress = {
	reason: string,
	timestamp: number,
}

export type Server = {
	Socket: Socket?,
	Address: string,
	Port: number,
	AllowedTokens: { string },
	SessionCounter: number,
	BannedAddresses: { [string]: BannedAddress },
	MessageSequence: number,
	ConnectedClients: { [string]: ConnectedClient },
	_onNewClient: ((addr: Address) -> ())?,
	_onClientRemoved: ((addr: Address) -> ())?,
	_onPreAuthMessage: ((addr: Address, data: MessageData) -> boolean)?,

	Init: (self: Server, address: string?, port: number?, allowedTokens: { string }?) -> Socket,
	GenerateSessionId: (self: Server) -> string,
	ValidateAuthToken: (self: Server, token: string) -> boolean,
	ValidateMessage: (self: Server, data: MessageData, client: ConnectedClient) -> (boolean, string?),
	CheckRateLimit: (self: Server, client: ConnectedClient) -> boolean,
	FragmentMessage: (self: Server, data: MessageData, messageId: string) -> { Fragment },
	ReassembleFragments: (self: Server, fragmentData: Fragment, client: ConnectedClient) -> MessageData?,
	IsBanned: (self: Server, address: string) -> boolean,
	BanClient: (self: Server, address: string, reason: string?) -> (),
	OnRecieve: (self: Server, callback: (addr: Address, data: MessageData) -> ()) -> (),
	OnNewClient: (self: Server, callback: (addr: Address) -> ()) -> (),
	OnClientRemoved: (self: Server, callback: (addr: Address) -> ()) -> (),
	OnPreAuthMessage: (self: Server, callback: (addr: Address, data: MessageData) -> boolean) -> (),
	SendAll: (self: Server, data: MessageData, reliable: boolean?) -> (),
	Shutdown: (self: Server) -> (),
	SendReliable: (self: Server, client: ConnectedClient, data: MessageData) -> (),
	SendRaw: (self: Server, client: ConnectedClient, data: MessageData) -> (),
	Send: (self: Server, client: ConnectedClient, data: MessageData, reliable: boolean?) -> (),
	ProcessReliableQueue: (self: Server) -> (),
	AuthenticateClient: (self: Server, addr: Address, authToken: string) -> boolean,
	StartHeartbeatMonitor: (self: Server) -> (),
	Listen: (self: Server) -> (),
	_middleware: (data: MessageData | string, addr: Address) -> (),
}

return {}
