--!strict
local datatypes = require("../datatypes");

local types = {}

type DataType = {
    new: (...any) -> any,
    load: (...any) -> any,
};

for type, datatype in datatypes do
    local dt = (datatype::any).DataType::DataType;
    if (dt and type ~= "Enums" and dt.load == nil) then
        dt.load = dt.new;
    end
    types[type::string] = dt;
end

return (types::any)::{
    Enums: any,
    [string]: DataType,
};
