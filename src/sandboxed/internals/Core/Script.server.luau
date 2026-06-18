local boolValue = Instance.new("BoolValue")

boolValue.Parent = workspace

boolValue.Value = 1 -- this should error

boolValue.Destroy = function() -- should error too
end
