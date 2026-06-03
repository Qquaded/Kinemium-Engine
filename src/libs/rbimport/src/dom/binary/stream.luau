--!strict
local BufferStream = {};
BufferStream.__index = BufferStream;

function BufferStream.new(size: number)
    return setmetatable({
        len = 0,
        buffer = buffer.create(size),
        position = 0,
        capacity = size,
    }, BufferStream);
end

function BufferStream.fromBuffer(buf: buffer)
    local len = buffer.len(buf);
    return setmetatable({
        len = len,
        buffer = buf,
        position = 0,
        capacity = len,
    }, BufferStream);
end

export type BufferStream = typeof(BufferStream.new(0));

local function grow(current: number, minimum: number): number
    local new = math.max(current, 4);
    while true do
        new += (new/2) // 1;
        if (new >= minimum) then
            return new;
        end
    end
end

function BufferStream.move(self: BufferStream, delta: number)
    self.position += delta;
    if (self.position < 0) then
        error("BufferStream position is negative");
    end
end

function BufferStream.reset(self: BufferStream)
    self.position = 0;
end

function BufferStream.couldRead(self: BufferStream, size: number)
    return self.position + size <= self.capacity;
end

function BufferStream.expandToSizePrecise(self: BufferStream, new_size: number)
    if (new_size <= self.capacity) then
        return;
    end

    local current_size = self.capacity;
    self.capacity = new_size;

    local current = self.buffer;
    self.buffer = buffer.create(new_size);
    buffer.copy(self.buffer, 0, current, 0, current_size);
end

function BufferStream.expandToSize(self: BufferStream, new_size: number)
    self.len = new_size;
    if (new_size <= self.capacity) then
        return;
    end
    local predicted_size = grow(self.capacity, new_size);
    self:expandToSizePrecise(predicted_size)
end

function BufferStream.trim(self: BufferStream)
    local final = buffer.create(self.position);
    buffer.copy(final, 0, self.buffer, 0, self.len);

    self.capacity = self.len;
    self.buffer = final;
end

function BufferStream.readi8(self: BufferStream): number
    local value = buffer.readi8(self.buffer, self.position);
    self.position += 1;
    return value;
end

function BufferStream.readu8(self: BufferStream): number
    local value = buffer.readu8(self.buffer, self.position);
    self.position += 1;
    return value;
end

function BufferStream.readi16(self: BufferStream): number
    local value = buffer.readi16(self.buffer, self.position);
    self.position += 2;
    return value;
end

function BufferStream.readu16(self: BufferStream): number
    local value = buffer.readu16(self.buffer, self.position);
    self.position += 2;
    return value;
end

function BufferStream.readi32(self: BufferStream): number
    local value = buffer.readi32(self.buffer, self.position);
    self.position += 4;
    return value;
end

function BufferStream.readu32(self: BufferStream): number
    local value = buffer.readu32(self.buffer, self.position);
    self.position += 4;
    return value;
end

function BufferStream.readf32(self: BufferStream): number
    local value = buffer.readf32(self.buffer, self.position);
    self.position += 4;
    return value;
end

function BufferStream.readf64(self: BufferStream): number
    local value = buffer.readf64(self.buffer, self.position);
    self.position += 8;
    return value;
end

function BufferStream.readstring(self: BufferStream): string
    local len = buffer.readu32(self.buffer, self.position);
    self.position += 4;
    local value = buffer.readstring(self.buffer, self.position, len);
    self.position += len;
    return value;
end

function BufferStream.readbuffer(self: BufferStream, len: number): buffer
    local copy = buffer.create(len);
    buffer.copy(copy, 0, self.buffer, self.position, len);
    self.position += len;
    return copy;
end

function BufferStream.writei8(self: BufferStream, value: number)
    self:expandToSize(self.position + 1);
    buffer.writei8(self.buffer, self.position, value);
    self.position += 1;
end

function BufferStream.writeu8(self: BufferStream, value: number)
    self:expandToSize(self.position + 1);
    buffer.writeu8(self.buffer, self.position, value);
    self.position += 1;
end

function BufferStream.writei16(self: BufferStream, value: number)
    self:expandToSize(self.position + 2);
    buffer.writei16(self.buffer, self.position, value);
    self.position += 2;
end

function BufferStream.writeu16(self: BufferStream, value: number)
    self:expandToSize(self.position + 2);
    buffer.writeu16(self.buffer, self.position, value);
    self.position += 2;
end

function BufferStream.writei32(self: BufferStream, value: number)
    self:expandToSize(self.position + 4);
    buffer.writei32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writeu32(self: BufferStream, value: number)
    self:expandToSize(self.position + 4);
    buffer.writeu32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writef32(self: BufferStream, value: number)
    self:expandToSize(self.position + 4);
    buffer.writef32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writef64(self: BufferStream, value: number)
    self:expandToSize(self.position + 8);
    buffer.writef64(self.buffer, self.position, value);
    self.position += 8;
end

function BufferStream.writerawstring(self: BufferStream, value: string, count: number?)
    count = count or #value;
    assert(type(count) == "number", "Invalid count");
    self:expandToSize(self.position + count);
    buffer.writestring(self.buffer, self.position, value, count);
    self.position += count;
end

function BufferStream.writestring(self: BufferStream, value: string, count: number?)
    count = count or #value;
    assert(type(count) == "number", "Invalid count");
    self:expandToSize(self.position + count + 4);
    buffer.writeu32(self.buffer, self.position, count);
    self.position += 4;
    buffer.writestring(self.buffer, self.position, value, count);
    self.position += count;
end

function BufferStream.writebuffer(self: BufferStream, value: buffer, count: number?)
    count = count or buffer.len(value);
    assert(type(count) == "number", "Invalid count");
    self:expandToSize(self.position + count);
    buffer.copy(self.buffer, self.position, value, 0, count);
    self.position += count;
end

return BufferStream;
