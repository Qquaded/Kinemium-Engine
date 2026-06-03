--!strict
local dump = require("@self/generated");

local api_dump: dump.ApiDump = dump.ApiDump;

local ReflectionDatabase = {};

export type ApiDump = dump.ApiDump;
export type EnumInfo = dump.EnumInfo;
export type Security = dump.Security;
export type TypeInfo = dump.TypeInfo;
export type ClassInfo = dump.ClassInfo;
export type ValueType = dump.ValueType;
export type MemberInfo = dump.MemberInfo;
export type Capabilities = dump.Capabilities;
export type ThreadSafety = dump.ThreadSafety;
export type EventMemberInfo = dump.EventMemberInfo;
export type FunctionMemberInfo = dump.FunctionMemberInfo;
export type PropertyMemberInfo = dump.PropertyMemberInfo;

export type ReflectionDatabase = typeof(ReflectionDatabase);

local API_CLASS_MAP = {};
local API_CLASS_MEMBER_MAP = {};
local API_ENUM_MAP = {};

for _, enum in api_dump.Enums do
    API_ENUM_MAP[enum.Name] = enum;
end
for _, class in api_dump.Classes do
    API_CLASS_MAP[class.Name] = class;
    local member_map = {};
    for _, member in class.Members do
        member_map[member.Name] = member;
    end
    API_CLASS_MEMBER_MAP[class.Name] = member_map;
end

ReflectionDatabase.Version = dump.Version;
ReflectionDatabase.API_CLASS_MAP = API_CLASS_MAP;
ReflectionDatabase.API_CLASS_MEMBER_MAP = API_CLASS_MEMBER_MAP;
ReflectionDatabase.API_ENUM_MAP = API_ENUM_MAP;

function ReflectionDatabase.GetApiDump(self: ReflectionDatabase)
    return api_dump;
end

function ReflectionDatabase.GetClassNames(self: ReflectionDatabase): {string}
    local names = table.create(#api_dump.Classes);
    for _, class in api_dump.Classes do
        table.insert(names, class.Name);
    end
    return names;
end

function ReflectionDatabase.GetEnumNames(self: ReflectionDatabase): {string}
    local names = table.create(#api_dump.Enums);
    for _, enum in api_dump.Enums do
        table.insert(names, enum.Name);
    end
    return names;
end

function ReflectionDatabase.GetClass(self: ReflectionDatabase, name: string): dump.ClassInfo?
    return API_CLASS_MAP[name];
end

function ReflectionDatabase.GetClassMember(self: ReflectionDatabase, name: string, memberName: string, super: boolean?): dump.MemberInfo?
    local member_map = API_CLASS_MEMBER_MAP[name];
    if (not member_map or not member_map[memberName]) then
        if (not super) then
            return;
        end
        local class = API_CLASS_MAP[name];
        if (not class) then
            return;
        end
        if (class.Superclass and class.Superclass ~= "<<<ROOT>>>") then
            return self:GetClassMember(class.Superclass, memberName, super);
        end
        return;
    end
    return member_map[memberName];
end

function ReflectionDatabase.GetEnum(self: ReflectionDatabase, name: string): dump.EnumInfo?
    return API_ENUM_MAP[name];
end

function ReflectionDatabase.FindClass(self: ReflectionDatabase, name: string): dump.ClassInfo?
    name = name:lower();
    for _, class in api_dump.Classes do
        if (class.Name:lower() == name) then
            return class;
        end
    end
    return;
end

function ReflectionDatabase.FindEnum(self: ReflectionDatabase, name: string): dump.EnumInfo?
    name = name:lower();
    for _, enum in api_dump.Enums do
        if (enum.Name:lower() == name) then
            return enum;
        end
    end
    return;
end

return ReflectionDatabase;
