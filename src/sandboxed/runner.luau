local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")

repeat
	task.wait()
until ScriptContext.RunClientScripts and ScriptContext.RunServerScripts

if RunService:IsClient() then
	ScriptContext.RunClientScripts()
else
	ScriptContext.RunServerScripts()
end
