--!strict
--!native
--!optimize 2

-- Based on https://github.com/Scythe-Technology/zune-lib/blob/f48c5343edfbed189ad92abc7af7616afd81e5c0/std/mem/init.luau

local mem = {};

function mem.reverse(target: buffer, offset: number, count: number?): ()
    local len = if count then count else buffer.len(target) - offset
    local half = len // 2
    local m1 = len - 1
    for i = 0, half - 1 do
        local a = offset + i
        local b = offset + m1 - i
        local temp = buffer.readu8(target, a)
        buffer.writeu8(target, a, buffer.readu8(target, b))
        buffer.writeu8(target, b, temp)
    end
end

function mem.eqlSlice(a: string | buffer, offset1: number, b: string | buffer, offset2: number, count: number?): boolean
    local a_buf: buffer = if type(a) == "string" then buffer.fromstring(a) else a
    local b_buf: buffer = if (type(b) == "string") then buffer.fromstring(b) else b
    
    local len = 0
    if count then
        len = count
    else
        local lenA = buffer.len(a_buf) - offset1
        local lenB = buffer.len(b_buf) - offset2
        if lenA ~= lenB then
            return false
        end
        len = lenA
    end
    if len == 0 then
        return true
    end
    if len > 3 then
        -- fast path: chunk (len >= 4)
        for i = 0, (((len - 1) // 4) - 1) * 4, 4 do
            if buffer.readu32(a_buf, offset1 + i) ~= buffer.readu32(b_buf, offset2 + i) then
                return false
            end
        end
        -- eql overlapped
        return buffer.readu32(a_buf, offset1 + len - 4) == buffer.readu32(b_buf, offset2 + len - 4)
    else
        -- slow path: byte by byte (len < 4)
        for i = 0, len - 1, 1 do
            if buffer.readu8(a_buf, offset1 + i) ~= buffer.readu8(b_buf, offset2 + i) then
                return false
            end
        end
    end
    return true
end

function mem.eql(a: buffer, b: buffer): boolean
    return mem.eqlSlice(a, 0, b, 0)
end

function mem.startsWith(haystack: buffer, needle: buffer): boolean
    local len = buffer.len(haystack)
    local needle_len = buffer.len(needle)
    if needle_len == 0 then
        return true
    end
    if len < needle_len then
        return false
    end
    return mem.eqlSlice(haystack, 0, needle, 0, needle_len)
end

function mem.endsWith(haystack: buffer, needle: buffer): boolean
    local len = buffer.len(haystack)
    local needle_len = buffer.len(needle)
    if needle_len == 0 then
        return true
    end
    if len < needle_len then
        return false
    end
    return mem.eqlSlice(haystack, len - needle_len, needle, 0, needle_len)
end

function mem.findScalarPos(haystack: buffer, offset: number, value: number): number?
    local byte = if type(value) == "string" then string.byte(value) else value % 256
    local len = buffer.len(haystack)
    if len == 0 then
        return nil
    end
    for i = offset, len - 1, 1 do
        if buffer.readu8(haystack, i) == byte then
            return i
        end
    end
    return nil
end

function mem.findScalar(haystack: buffer, value: number): number?
    return mem.findScalarPos(haystack, 0, value)
end

function mem.findAnyPos(haystack: buffer, offset: number, needle: string | buffer): number?
    local needle_buf: buffer = if type(needle) == "string" then buffer.fromstring(needle) else needle
    local len = buffer.len(haystack)
    local needle_len = buffer.len(needle_buf)
    if len == 0 or needle_len == 0 then
        return nil
    end
    for i = offset, len - 1, 1 do
        local byte = buffer.readu8(haystack, i);
        for o = 0, needle_len - 1, 1 do
            if buffer.readu8(needle_buf, o) == byte then
                return i
            end
        end
    end
    return nil
end

function mem.findAny(haystack: buffer, needle: string | buffer): number?
    return mem.findAnyPos(haystack, 0, needle)
end

function mem.findPos(haystack: buffer, offset: number, needle: string | buffer): number?
    local needle_buf: buffer = if type(needle) == "string" then buffer.fromstring(needle) else needle
    local len = buffer.len(haystack)
    local needle_len = buffer.len(needle_buf)
    if needle_len == 0 then
        return offset
    end
    if len == 0 then
        return nil
    end
    for i = offset, len - needle_len, 1 do
        if mem.eqlSlice(haystack, i, needle_buf, 0, needle_len) then
            return i
        end
    end
    return nil
end

function mem.find(haystack: buffer, needle: string | buffer): number?
    return mem.findPos(haystack, 0, needle)
end

return mem;
