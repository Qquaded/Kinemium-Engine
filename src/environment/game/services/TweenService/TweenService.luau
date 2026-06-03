local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local TweenService = Instance.new("TweenService")
TweenService.ExplorerHidden = true
TweenService._Intents = Enum.PluginIntents.Graphics

local TweenCompleted = signal.new()
local activeTweens = {}

-- Easing Functions
local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local exp = math.exp

local function linear(t)
	return t
end

local function sine(t)
	return 1 - cos((t * pi) / 2)
end

local function quad(t)
	return t * t
end

local function cubic(t)
	return t * t * t
end

local function quart(t)
	return t * t * t * t
end

local function quint(t)
	return t * t * t * t * t
end

local function expo(t)
	return t == 0 and 0 or pow(2, 10 * (t - 1))
end

local function circ(t)
	return 1 - sqrt(1 - t * t)
end

local function back(t)
	local c1 = 1.70158
	local c3 = c1 + 1
	return c3 * t * t * t - c1 * t * t
end

local function elastic(t)
	if t == 0 then
		return 0
	end
	if t == 1 then
		return 1
	end
	local c4 = (2 * pi) / 3
	return -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * c4)
end

local function bounce(t)
	local n1 = 7.5625
	local d1 = 2.75

	if t < 1 / d1 then
		return n1 * t * t
	elseif t < 2 / d1 then
		t = t - 1.5 / d1
		return n1 * t * t + 0.75
	elseif t < 2.5 / d1 then
		t = t - 2.25 / d1
		return n1 * t * t + 0.9375
	else
		t = t - 2.625 / d1
		return n1 * t * t + 0.984375
	end
end

local function smooth(t)
	return t * t * (3 - 2 * t)
end

local function smoother(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

local function ridiculousWiggle(t)
	return sin(t * pi * 10) * (1 - t)
end

local function revBack(t)
	local c1 = 1.70158
	local c3 = c1 + 1
	return 1 - (c3 * (1 - t) * (1 - t) * (1 - t) - c1 * (1 - t) * (1 - t))
end

local function spring(t)
	return 1 + (-exp(-6 * t) * cos(10 * t)) / (1 + (t * 2)) -- Dampened
end

local function softSpring(t)
	return 1 - cos(t * pi * 2) * exp(-4 * t)
end

local easings = {
	[Enum.EasingStyle.Linear] = linear,
	[Enum.EasingStyle.Sine] = sine,
	[Enum.EasingStyle.Quad] = quad,
	[Enum.EasingStyle.Cubic] = cubic,
	[Enum.EasingStyle.Quart] = quart,
	[Enum.EasingStyle.Quint] = quint,
	[Enum.EasingStyle.Expo] = expo,
	[Enum.EasingStyle.Circular] = circ,
	[Enum.EasingStyle.Back] = back,
	[Enum.EasingStyle.Elastic] = elastic,
	[Enum.EasingStyle.Bounce] = bounce,
	[Enum.EasingStyle.Smooth] = smooth,
	[Enum.EasingStyle.Smoother] = smoother,
	[Enum.EasingStyle.RidiculousWiggle] = ridiculousWiggle,
	[Enum.EasingStyle.RevBack] = revBack,
	[Enum.EasingStyle.Spring] = spring,
	[Enum.EasingStyle.SoftSpring] = softSpring,
}

local customEasings = {}

function TweenService:RegisterEasingStyle(name, easingFunction)
	assert(type(name) == "string", "Easing style name must be a string")
	assert(type(easingFunction) == "function", "Easing style must be a function")
	customEasings[name] = easingFunction
end

function TweenService:GetValue(alpha, style, direction)
	local easeFunc = easings[style] or customEasings[style]

	-- Support passing a function directly
	if type(style) == "function" then
		easeFunc = style
	end

	if not easeFunc then
		easeFunc = linear
	end

	if style == Enum.EasingStyle.Linear or style == Enum.EasingStyle.RidiculousWiggle then
		return easeFunc(alpha)
	end

	if direction == Enum.EasingDirection.In then
		return easeFunc(alpha)
	elseif direction == Enum.EasingDirection.Out then
		return 1 - easeFunc(1 - alpha)
	elseif direction == Enum.EasingDirection.InOut then
		if alpha < 0.5 then
			return easeFunc(2 * alpha) / 2
		else
			return 1 - easeFunc(2 * (1 - alpha)) / 2
		end
	end
	return alpha
end

function TweenService:GetActiveTweens()
	local list = {}
	for t, _ in pairs(activeTweens) do
		table.insert(list, t)
	end
	return list
end

function TweenService:CancelAll()
	for t, _ in pairs(activeTweens) do
		t:Cancel()
	end
	activeTweens = {}
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function getTypeOf(v)
	if type(v) == "table" then
		if getmetatable(v) and type(v.Lerp) == "function" then
			return "Instance" -- Placeholder or specific type check if possible
		end
	end
	return type(v)
end

local function lerpProp(startVal, endVal, alpha)
	if type(startVal) == "number" then
		return lerp(startVal, endVal, alpha)
	elseif type(startVal) == "table" and startVal.Lerp then
		return startVal:Lerp(endVal, alpha)
	end
	return startVal
end

local function createTween(object, tweenInfo, properties)
	local tween = {}

	tween.TweenInfo = tweenInfo
	tween.Instance = object
	tween.PlaybackState = Enum.PlaybackState.Begin

	tween._time = 0
	tween._delayElapsed = 0
	tween._playing = false
	tween._completed = false
	tween._reversing = false
	tween._cycleCount = 0
	tween._initialValues = {}
	tween._targetValues = properties

	tween.Completed = signal.new()

	for prop, _ in pairs(properties) do
		tween._initialValues[prop] = object[prop]
	end

	function tween:Play()
		if self.PlaybackState == Enum.PlaybackState.Playing then
			return
		end

		if self.PlaybackState == Enum.PlaybackState.Completed or self.PlaybackState == Enum.PlaybackState.Cancelled then
			self._time = 0
			self._delayElapsed = 0
			self._cycleCount = 0
			self._reversing = false
		end

		self.PlaybackState = Enum.PlaybackState.Playing
		self._playing = true
		activeTweens[self] = true
	end

	function tween:Pause()
		if self.PlaybackState == Enum.PlaybackState.Playing then
			self.PlaybackState = Enum.PlaybackState.Paused
			self._playing = false
			activeTweens[self] = nil
		end
	end

	function tween:Cancel()
		if self.PlaybackState == Enum.PlaybackState.Cancelled then
			return
		end

		self.PlaybackState = Enum.PlaybackState.Cancelled
		self._playing = false
		activeTweens[self] = nil
		self.Completed:Fire(Enum.PlaybackState.Cancelled)
	end

	function tween:Destroy()
		self:Cancel()
	end

	return tween
end

function TweenService:Create(object, tweenInfo, properties)
	return createTween(object, tweenInfo, properties)
end

TweenService.InitRenderer = function(renderer, renderer_signal)
	TweenService:SetProperties({
		Create = TweenService.Create,
		Completed = TweenCompleted,
		GetValue = TweenService.GetValue,
		RegisterEasingStyle = TweenService.RegisterEasingStyle,
	})

	renderer_signal:Connect(function(route, dt)
		if route ~= "Heartbeat" then
			return
		end

		for tween, _ in pairs(activeTweens) do
			if tween._playing then
				local info = tween.TweenInfo

				if tween._delayElapsed < info.DelayTime then
					-- do nothing, just wait
				else
					tween._time = tween._time + dt
					local rawTime = tween._time
					local duration = info.Time

					local totalCycleTime = duration
					if info.Reverses then
						totalCycleTime = duration * 2
					end

					local currentCycleIndex = math.floor(rawTime / totalCycleTime)

					local finished = false
					if info.RepeatCount >= 0 and currentCycleIndex > info.RepeatCount then
						finished = true
						rawTime = totalCycleTime * (info.RepeatCount + 1)
					end

					local cycleTime = rawTime % totalCycleTime
					if finished then
						cycleTime = totalCycleTime
					end

					local alpha = 0

					if info.Reverses then
						if cycleTime <= duration then
							alpha = cycleTime / duration
						else
							alpha = 1 - ((cycleTime - duration) / duration)
						end
					else
						alpha = cycleTime / duration
					end

					if alpha > 1 then
						alpha = 1
					end
					if alpha < 0 then
						alpha = 0
					end

					local easedAlpha = TweenService:GetValue(alpha, info.EasingStyle, info.EasingDirection)

					for prop, endVal in pairs(tween._targetValues) do
						local startVal = tween._initialValues[prop]
						tween.Instance[prop] = lerpProp(startVal, endVal, easedAlpha)
					end

					if finished then
						tween._playing = false
						tween.PlaybackState = Enum.PlaybackState.Completed
						activeTweens[tween] = nil
						tween.Completed:Fire(Enum.PlaybackState.Completed)
						TweenCompleted:Fire(tween)
					end
				end
			end
		end
	end)
end

return TweenService
