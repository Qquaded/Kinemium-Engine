local RateLimiter = {}

local WINDOW_SECONDS = 1
local MAX_MESSAGES_PER_WINDOW = 300
local CLEANUP_INTERVAL = 10

local peers = {}
local lastCleanup = 0

local function now()
	return os.clock()
end

function RateLimiter.Allow(peerKey)
	local t = now()

	local peer = peers[peerKey]
	if not peer then
		peer = {
			ring = table.create(MAX_MESSAGES_PER_WINDOW, 0),
			head = 0,
			count = 0,
			windowStart = t,
		}
		peers[peerKey] = peer
	end

	local windowStart = t - WINDOW_SECONDS
	while peer.count > 0 do
		local oldest = peer.ring[((peer.head - peer.count) % MAX_MESSAGES_PER_WINDOW) + 1]
		if oldest < windowStart then
			peer.count -= 1
		else
			break
		end
	end

	if peer.count >= MAX_MESSAGES_PER_WINDOW then
		return false
	end

	peer.ring[(peer.head % MAX_MESSAGES_PER_WINDOW) + 1] = t
	peer.head += 1
	peer.count += 1

	if t - lastCleanup > CLEANUP_INTERVAL then
		lastCleanup = t
		RateLimiter.Cleanup()
	end

	return true
end

function RateLimiter.Reset(peerKey)
	peers[peerKey] = nil
end

function RateLimiter.Cleanup()
	local t = now()
	local cutoff = t - WINDOW_SECONDS * 3
	local toRemove = {}
	for key, peer in pairs(peers) do
		if peer.count == 0 or peer.ring[((peer.head - 1) % MAX_MESSAGES_PER_WINDOW) + 1] < cutoff then
			table.insert(toRemove, key)
		end
	end
	for _, key in ipairs(toRemove) do
		peers[key] = nil
	end
end

function RateLimiter.SetLimit(limit)
	MAX_MESSAGES_PER_WINDOW = limit
end

function RateLimiter.SetWindow(seconds)
	WINDOW_SECONDS = seconds
end

function RateLimiter.GetPeerStats(peerKey)
	local peer = peers[peerKey]
	if not peer then
		return { count = 0, limit = MAX_MESSAGES_PER_WINDOW, window = WINDOW_SECONDS }
	end
	return { count = peer.count, limit = MAX_MESSAGES_PER_WINDOW, window = WINDOW_SECONDS }
end

return RateLimiter
