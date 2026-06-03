--!strict
local impl = {};
impl.object = nil::any;
impl.default = {};
impl.method = {};
impl.property = {};
impl.property.get = {};
impl.property.set = {};

impl.default["Pivot Offset"] = function(self: any, datatypes: any, default: any): any
    return datatypes.CFrame.new();
end
impl.default["BrickColor"] = function(self: any, datatypes: any, default: any): any
    return datatypes.BrickColor.new(194);
end
impl.default.PivotOffset = "DISABLED";

return impl;
