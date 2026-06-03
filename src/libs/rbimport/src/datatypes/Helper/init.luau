--!strict
local md5 = require("@polyfill").md5;

local helper = {};

function helper.DataTypeIsFn(meta: any): (value: any) -> boolean
    return function(value: any)
        return
            (type(value) == "table" or type(value) == "userdata") and
            getmetatable(value) == meta;
    end;
end;

function helper.ValuesHash(...): string
    local values = {...};
    local packed = table.create(#values);
    for _, value in values do
        table.insert(packed, tostring(value));
    end
    return md5(table.concat(packed, ","));
end;

return helper;
