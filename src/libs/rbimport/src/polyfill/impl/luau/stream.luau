--!strict
--!native
--!optimize 2

export type IoWritable = {
    write: (self: IoWritable, value: string | buffer) -> (),
    writei8: (self: IoWritable, value: number) -> (),
    writeu8: (self: IoWritable, value: number) -> (),
    writei16: (self: IoWritable, value: number) -> (),
    writeu16: (self: IoWritable, value: number) -> (),
    writei32: (self: IoWritable, value: number) -> (),
    writeu32: (self: IoWritable, value: number) -> (),
    writef32: (self: IoWritable, value: number) -> (),
    writef64: (self: IoWritable, value: number) -> (),
}

export type IoReadable = {
    read:
        & ((self: IoReadable, amount: number?, bytes: true?) -> buffer)
        & ((self: IoReadable, amount: number?, bytes: false) -> string),
    readi8: (self: IoReadable) -> number,
    readu8: (self: IoReadable) -> number,
    readi16: (self: IoReadable) -> number,
    readu16: (self: IoReadable) -> number,
    readi32: (self: IoReadable) -> number,
    readu32: (self: IoReadable) -> number,
    readf32: (self: IoReadable) -> number,
    readf64: (self: IoReadable) -> number,
}

local BufferStream = {};
BufferStream.__index = BufferStream;

function BufferStream.create(buf: buffer)
    local len = buffer.len(buf);
    return setmetatable({
        len = len,
        buffer = buf,
        position = 0,
    }, BufferStream);
end

export type BufferStream = typeof(BufferStream.create(buffer.create(0)));

function BufferStream.reader(self: BufferStream): IoReadable
    return self :: any;
end

function BufferStream.writer(self: BufferStream): IoWritable
    return self :: any;
end

function BufferStream.pos(self: BufferStream): number
    return self.position;
end

function BufferStream.size(self: BufferStream): number
    return self.len;
end

function BufferStream.seekTo(self: BufferStream, pos: number)
    self.position = pos;
end

function BufferStream.seekBy(self: BufferStream, pos: number)
    self.position = math.clamp((self.position + pos) // 1, 0, self.len);
end

function BufferStream.canRead(self: BufferStream, size: number)
    return self.position + size <= self.len;
end

function BufferStream.read(self: BufferStream, amount: number?, bytes: boolean?): (string | buffer)?
    local len = amount or self.len - self.position;
    if (amount and amount <= 0) then
        return if (bytes == false) then
            ""
        else
            buffer.create(0);
    end
    if (bytes == false) then
        local value = buffer.readstring(self.buffer, self.position, len);
        self.position += len;
        return value;
    else
        local copy = buffer.create(len);
        buffer.copy(copy, 0, self.buffer, self.position, len);
        self.position += len;
        return copy;
    end
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

function BufferStream.write(self: BufferStream, value: string | buffer)
    if (type(value) == "string") then
        buffer.writestring(self.buffer, self.position, value)
        self.position += #value;
        return;
    else
        buffer.copy(self.buffer, self.position, value);
        return;
    end
end

function BufferStream.writei8(self: BufferStream, value: number)
    buffer.writei8(self.buffer, self.position, value);
    self.position += 1;
end

function BufferStream.writeu8(self: BufferStream, value: number)
    buffer.writeu8(self.buffer, self.position, value);
    self.position += 1;
end

function BufferStream.writei16(self: BufferStream, value: number)
    buffer.writei16(self.buffer, self.position, value);
    self.position += 2;
end

function BufferStream.writeu16(self: BufferStream, value: number)
    buffer.writeu16(self.buffer, self.position, value);
    self.position += 2;
end

function BufferStream.writei32(self: BufferStream, value: number)
    buffer.writei32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writeu32(self: BufferStream, value: number)
    buffer.writeu32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writef32(self: BufferStream, value: number)
    buffer.writef32(self.buffer, self.position, value);
    self.position += 4;
end

function BufferStream.writef64(self: BufferStream, value: number)
    buffer.writef64(self.buffer, self.position, value);
    self.position += 8;
end

return BufferStream;
