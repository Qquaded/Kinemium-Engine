--!strict
local impl = {};
impl.object = nil::any;
impl.method = {};

function impl.method.GetService(self: any, service: string): string
    return self:FindFirstChildOfClass(service);
end

function impl.method.FindService(self: any, service: string): string
    return self:FindFirstChildOfClass(service);
end

return impl;
