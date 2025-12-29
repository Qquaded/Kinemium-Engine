--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

local ENetListNode

ENetListNode = ffi.struct({
	{ next = ffi.types.pointer }, -- ENetListNode*
	{ previous = ffi.types.pointer }, -- ENetListNode*
})
export type ENetListNode = typeof(ENetListNode:new({}))

local ENetList = ffi.struct({
	{ sentinel = ENetListNode },
})
export type ENetList = typeof(ENetList:new({}))

-- ENetCompressor (placeholder)
local ENetCompressor = ffi.struct({
	{ context = ffi.types.pointer },
	{ compress = ffi.types.pointer },
	{ decompress = ffi.types.pointer },
})
export type ENetCompressor = typeof(ENetCompressor:new({}))

local ENetBuffer = ffi.struct({
	{ dataLength = ffi.types.u64 },
})
export type ENetBuffer = typeof(ENetBuffer:new({}))

local ENetAddress = ffi.struct({
	{ host = ffi.types.pointer },
	{ port = ffi.types.u16 },
	{ sin6_scope_id = ffi.types.u16 },
})
export type ENetAddress = typeof(ENetAddress:new({}))

local ENetPacket = ffi.struct({
	{ referenceCount = ffi.types.u64 },
	{ flags = ffi.types.u32 },
	{ dataLength = ffi.types.u64 },
	{ freeCallback = ffi.types.pointer },
})
export type ENetPacket = typeof(ENetPacket:new({}))

local ENetAcknowledgement = ffi.struct({
	{ acknowledgementList = ENetListNode },
	{ sentTime = ffi.types.u32 },
	{ command = ffi.types.pointer },
})
export type ENetAcknowledgement = typeof(ENetAcknowledgement:new({}))

local ENetOutgoingCommand = ffi.struct({
	{ outgoingCommandList = ENetListNode },
	{ reliableSequenceNumber = ffi.types.u16 },
	{ unreliableSequenceNumber = ffi.types.u16 },
	{ sentTime = ffi.types.u32 },
	{ roundTripTimeout = ffi.types.u32 },
	{ queueTime = ffi.types.u32 },
	{ fragmentOffset = ffi.types.u32 },
	{ fragmentLength = ffi.types.u16 },
	{ sendAttempts = ffi.types.u16 },
	{ command = ffi.types.pointer },
})
export type ENetOutgoingCommand = typeof(ENetOutgoingCommand:new({}))

local ENetIncomingCommand = ffi.struct({
	{ incomingCommandList = ENetListNode },
	{ reliableSequenceNumber = ffi.types.u16 },
	{ unreliableSequenceNumber = ffi.types.u16 },
	{ command = ffi.types.pointer },
	{ fragmentCount = ffi.types.u32 },
	{ fragmentsRemaining = ffi.types.u32 },
})
export type ENetIncomingCommand = typeof(ENetIncomingCommand:new({}))

local ENetChannel = ffi.struct({
	{ outgoingReliableSequenceNumber = ffi.types.u16 },
	{ outgoingUnreliableSequenceNumber = ffi.types.u16 },
	{ usedReliableWindows = ffi.types.u16 },
	-- FIXME: Array size needs manual definition: ENET_PEER_RELIABLE_WINDOWS
	-- { reliableWindows = ffi.types.u16:array(ENET_PEER_RELIABLE_WINDOWS) },
	{ incomingReliableSequenceNumber = ffi.types.u16 },
	{ incomingUnreliableSequenceNumber = ffi.types.u16 },
	{ incomingReliableCommands = ENetList },
	{ incomingUnreliableCommands = ENetList },
})
export type ENetChannel = typeof(ENetChannel:new({}))

local ENetPeer = ffi.struct({
	{ dispatchList = ENetListNode },
	{ outgoingPeerID = ffi.types.u16 },
	{ incomingPeerID = ffi.types.u16 },
	{ connectID = ffi.types.u32 },
	{ outgoingSessionID = ffi.types.u8 },
	{ incomingSessionID = ffi.types.u8 },
	{ address = ENetAddress },
	{ state = ffi.types.pointer },
	{ channelCount = ffi.types.u64 },
	{ incomingBandwidth = ffi.types.u32 },
	{ outgoingBandwidth = ffi.types.u32 },
	{ incomingBandwidthThrottleEpoch = ffi.types.u32 },
	{ outgoingBandwidthThrottleEpoch = ffi.types.u32 },
	{ incomingDataTotal = ffi.types.u32 },
	{ totalDataReceived = ffi.types.u64 },
	{ outgoingDataTotal = ffi.types.u32 },
	{ totalDataSent = ffi.types.u64 },
	{ lastSendTime = ffi.types.u32 },
	{ lastReceiveTime = ffi.types.u32 },
	{ nextTimeout = ffi.types.u32 },
	{ earliestTimeout = ffi.types.u32 },
	{ packetLossEpoch = ffi.types.u32 },
	{ packetsSent = ffi.types.u32 },
	{ totalPacketsSent = ffi.types.u64 },
	{ packetsLost = ffi.types.u32 },
	{ totalPacketsLost = ffi.types.u32 },
	{ packetLoss = ffi.types.u32 },
	{ packetLossVariance = ffi.types.u32 },
	{ packetThrottle = ffi.types.u32 },
	{ packetThrottleLimit = ffi.types.u32 },
	{ packetThrottleCounter = ffi.types.u32 },
	{ packetThrottleEpoch = ffi.types.u32 },
	{ packetThrottleAcceleration = ffi.types.u32 },
	{ packetThrottleDeceleration = ffi.types.u32 },
	{ packetThrottleInterval = ffi.types.u32 },
	{ pingInterval = ffi.types.u32 },
	{ timeoutLimit = ffi.types.u32 },
	{ timeoutMinimum = ffi.types.u32 },
	{ timeoutMaximum = ffi.types.u32 },
	{ lastRoundTripTime = ffi.types.u32 },
	{ lowestRoundTripTime = ffi.types.u32 },
	{ lastRoundTripTimeVariance = ffi.types.u32 },
	{ highestRoundTripTimeVariance = ffi.types.u32 },
	{ roundTripTime = ffi.types.u32 },
	{ roundTripTimeVariance = ffi.types.u32 },
	{ mtu = ffi.types.u32 },
	{ windowSize = ffi.types.u32 },
	{ reliableDataInTransit = ffi.types.u32 },
	{ outgoingReliableSequenceNumber = ffi.types.u16 },
	{ acknowledgements = ENetList },
	{ sentReliableCommands = ENetList },
	{ outgoingCommands = ENetList },
	{ outgoingSendReliableCommands = ENetList },
	{ dispatchedCommands = ENetList },
	{ flags = ffi.types.u16 },
	{ reserved = ffi.types.u16 },
	{ incomingUnsequencedGroup = ffi.types.u16 },
	{ outgoingUnsequencedGroup = ffi.types.u16 },
	-- FIXME: Array size needs manual definition: ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32
	-- { unsequencedWindow = ffi.types.u32:array(ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32) },
	{ eventData = ffi.types.u32 },
	{ totalWaitingData = ffi.types.u64 },
})
export type ENetPeer = typeof(ENetPeer:new({}))

local ENetHost = ffi.struct({
	{ socket = ffi.types.pointer },
	{ address = ENetAddress },
	{ incomingBandwidth = ffi.types.u32 },
	{ outgoingBandwidth = ffi.types.u32 },
	{ bandwidthThrottleEpoch = ffi.types.u32 },
	{ mtu = ffi.types.u32 },
	{ randomSeed = ffi.types.u32 },
	{ recalculateBandwidthLimits = ffi.types.i32 },
	{ peerCount = ffi.types.u64 },
	{ channelLimit = ffi.types.u64 },
	{ serviceTime = ffi.types.u32 },
	{ dispatchQueue = ENetList },
	{ totalQueued = ffi.types.u32 },
	{ packetSize = ffi.types.u64 },
	{ headerFlags = ffi.types.u16 },
	-- FIXME: Array size needs manual definition: ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS
	-- { commands = ffi.types.pointer:array(ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS) },
	{ commandCount = ffi.types.u64 },
	-- FIXME: Array size needs manual definition: (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
	-- { buffers = ENetBuffer:array((1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)) },
	{ bufferCount = ffi.types.u64 },
	{ checksum = ffi.types.pointer },
	{ compressor = ENetCompressor },
	{ receivedAddress = ENetAddress },
	{ receivedDataLength = ffi.types.u64 },
	{ totalSentData = ffi.types.u32 },
	{ totalSentPackets = ffi.types.u32 },
	{ totalReceivedData = ffi.types.u32 },
	{ totalReceivedPackets = ffi.types.u32 },
	{ intercept = ffi.types.pointer },
	{ connectedPeers = ffi.types.u64 },
	{ bandwidthLimitedPeers = ffi.types.u64 },
	{ duplicatePeers = ffi.types.u64 },
	{ maximumPacketSize = ffi.types.u64 },
	{ maximumWaitingData = ffi.types.u64 },
})
export type ENetHost = typeof(ENetHost:new({}))

local ENetEvent = ffi.struct({
	{ type = ffi.types.pointer },
	{ channelID = ffi.types.u8 },
	{ data = ffi.types.u32 },
})
export type ENetEvent = typeof(ENetEvent:new({}))

local funcs = {
	enet_initialize = { returns = ffi.types.i32, args = {} },
	enet_initialize_with_callbacks = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_deinitialize = { returns = ffi.types.void, args = {} },
	enet_linked_version = { returns = ffi.types.pointer, args = {} },
	enet_time_get = { returns = ffi.types.u32, args = {} },
	enet_socket_create = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	enet_socket_bind = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_socket_get_address = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_socket_listen = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i32 } },
	enet_socket_accept = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_socket_connect = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_socket_send = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	enet_socket_receive = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	enet_socket_wait = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u32, ffi.types.u64 } },
	enet_socket_set_option = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	enet_socket_get_option = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	enet_socket_shutdown = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_socket_destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_socketset_select = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	enet_address_set_host_ip_old = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_address_set_host_old = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_address_get_host_ip_old = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.u64 },
	},
	enet_address_get_host_old = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i8, ffi.types.u64 } },
	enet_address_set_host_ip_new = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_address_set_host_new = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_address_get_host_ip_new = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i8, ffi.types.u64 },
	},
	enet_address_get_host_new = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.i8, ffi.types.u64 } },
	enet_host_get_peers_count = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_host_get_packets_sent = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_host_get_packets_received = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_host_get_bytes_sent = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_host_get_bytes_received = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_host_get_received_data = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u8 } },
	enet_host_get_mtu = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_peer_get_id = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_peer_get_ip = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.i8, ffi.types.u64 } },
	enet_peer_get_port = { returns = ffi.types.u16, args = { ffi.types.pointer } },
	enet_peer_get_rtt = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_peer_get_packets_sent = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	enet_peer_get_packets_lost = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_peer_get_bytes_sent = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	enet_peer_get_bytes_received = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	enet_peer_get_state = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	enet_peer_set_data = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_packet_get_length = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	enet_packet_set_free_callback = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_crc32 = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u64 } },
	enet_host_destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_host_check_events = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_host_service = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 } },
	enet_packet_create_offset = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- data pointer
			ffi.types.u64, -- data length
			ffi.types.u32, -- flags
		},
	},
	enet_host_create = {
		returns = ffi.types.pointer, -- ENetHost*
		args = {
			ffi.types.pointer, -- ENetAddress*
			ffi.types.u64, -- peerCount
			ffi.types.u64, -- channelLimit
			ffi.types.u32, -- incomingBandwidth
			ffi.types.u32, -- outgoingBandwidth
		},
	},
	enet_host_send_raw = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8, ffi.types.u64 },
	},
	enet_host_send_raw_ex = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8, ffi.types.u64, ffi.types.u64 },
	},
	enet_host_set_intercept = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_host_flush = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_host_broadcast = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8, ffi.types.pointer } },
	enet_host_compress = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	enet_host_channel_limit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	enet_host_bandwidth_limit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 } },
	enet_peer_send = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8, ffi.types.pointer } },
	enet_peer_ping = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_peer_ping_interval = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	enet_peer_timeout = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
	},
	enet_peer_reset = { returns = ffi.types.void, args = { ffi.types.pointer } },
	enet_peer_disconnect = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	enet_peer_disconnect_now = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	enet_peer_disconnect_later = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	enet_peer_throttle_configure = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
	},
}

local structs = {
	ENetBuffer = ENetBuffer,
	ENetList = ENetList,
	ENetAddress = ENetAddress,
	ENetPacket = ENetPacket,
	ENetAcknowledgement = ENetAcknowledgement,
	ENetOutgoingCommand = ENetOutgoingCommand,
	ENetIncomingCommand = ENetIncomingCommand,
	ENetChannel = ENetChannel,
	ENetPeer = ENetPeer,
	ENetHost = ENetHost,
	ENetEvent = ENetEvent,
}

return { funcs = funcs, structs = structs }
