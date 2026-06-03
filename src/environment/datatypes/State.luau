local StateMachine = {}
StateMachine.__index = StateMachine
StateMachine.ClassName = "StateMachine"

function StateMachine.new(initial)
	local self = setmetatable({}, StateMachine)
	self.Current = initial or nil
	self.States = {}
	self.Transitions = {} -- key: from state, value: {to = callback}
	return self
end

function StateMachine:AddState(name, callbacks)
	callbacks = callbacks or {}
	self.States[name] = {
		OnEnter = callbacks.OnEnter or function() end,
		OnExit = callbacks.OnExit or function() end,
	}
end

function StateMachine:AddTransition(from, to, callback)
	self.Transitions[from] = self.Transitions[from] or {}
	self.Transitions[from][to] = callback or function() end
end

function StateMachine:ChangeState(to)
	local from = self.Current
	if from and self.States[from] then
		self.States[from].OnExit()
	end

	if from and self.Transitions[from] and self.Transitions[from][to] then
		self.Transitions[from][to]()
	end

	self.Current = to
	if self.States[to] then
		self.States[to].OnEnter()
	end
end

function StateMachine:GetState()
	return self.Current
end

return StateMachine
