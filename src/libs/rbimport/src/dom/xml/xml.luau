--!strict
local polyfill = require("@polyfill");
local mem = polyfill.mem;

local xml = {};

export type Node = {
    tag: string,
    attributes: { [string]: string },
    children: string | { Node },
    cdata: boolean?,
    raw: boolean?,
}

local function parseAttributes(attrStr: string): { [string]: string }
    local attrs = {};
    for key, value in string.gmatch(attrStr, '([%w_]+)="([^"]*)"') do
        attrs[key] = assert(value, `missing attribute value`);
    end
    return attrs;
end

local function escapeText(text: string): string
    text = string.gsub(text, "&", "&amp;");
    text = string.gsub(text, "<", "&lt;");
    text = string.gsub(text, ">", "&gt;");
    text = string.gsub(text, "\"", "&quot;");
    text = string.gsub(text, "'", "&apos;");
    return text;
end

local function unescapeText(text: string): string
    text = string.gsub(text, "&lt;", "<");
    text = string.gsub(text, "&gt;", ">");
    text = string.gsub(text, "&quot;", "\"");
    text = string.gsub(text, "&apos;", "'");
    text = string.gsub(text, "&amp;", "&");
    return text;
end

local function CDATA(text: string): string
    if (string.find(text, "[<=/\\>&]") ~= nil) then
        return `<![CDATA[{text}]]>`;
    else
        return text;
    end
end

local function parse(buf: buffer): Node?
    local len = buffer.len(buf);
    local pos = 0
    local parent_stack: {Node} = {}
    local root: Node? = nil
    while (pos < len) do
        if (buffer.readu8(buf, pos) == 60) then -- '<'
            if (mem.eqlSlice(buf, pos + 1, "![CDATA[", 0, 8)) then -- CDATA
                local end_pos = mem.findPos(buf, pos + 9, "]]>");
                if (end_pos) then
                    local text = buffer.readstring(buf, pos + 9, end_pos - pos - 9);
                    if (#parent_stack > 0) then
                        local parent = parent_stack[#parent_stack];
                        parent.cdata = true;
                        parent.children = text;
                    end
                    pos = end_pos + 3;
                else
                    error("unclosed CDATA")
                end
            elseif (mem.eqlSlice(buf, pos + 1, "!--", 0, 3)) then -- Comment
                local end_pos = mem.findPos(buf, pos + 4, "-->");
                if end_pos then
                    pos = end_pos + 3;
                else
                    error("unclosed comment");
                end
            else -- Tag
                local tag_end = assert(mem.findAnyPos(buf, pos + 1, "\32>"), "invalid tag");
                local tag_name = buffer.readstring(buf, pos + 1, tag_end - pos - 1);
                local is_closing = string.sub(tag_name, 1, 1) == '/';
                if (is_closing) then
                    tag_name = string.sub(tag_name, 2);
                    assert(#parent_stack > 0 and parent_stack[#parent_stack].tag == tag_name, `mismatched closing tag: {tag_name}`);
                    local node = assert(table.remove(parent_stack), "unreachable");
                    local close_pos = assert(mem.findScalarPos(buf, tag_end, string.byte('>')), "invalid closing tag");
                    pos = close_pos + 1;
                    if (type(node.children) == "table" and #node.children == 0) then
                        node.children = "";
                    end
                else -- Opening tag
                    local attr_end = assert(mem.findScalarPos(buf, tag_end, string.byte('>')), "invalid tag");
                    local attr_str = buffer.readstring(buf, tag_end + 1, attr_end - tag_end);
                    local indep_closing = string.sub(attr_str, -1) == '/';
                    if (indep_closing) then
                        attr_str = string.sub(attr_str, 1, -2);
                    end
                    local attrs = parseAttributes(attr_str);
                    local node: Node = {
                        tag = tag_name,
                        attributes = attrs,
                        children = {},
                    }
                    if (#parent_stack > 0) then
                        local parent = parent_stack[#parent_stack];
                        table.insert(parent.children :: any, node);
                    else
                        root = node;
                    end
                    if (not indep_closing) then
                        table.insert(parent_stack, node);
                    end
                    pos = attr_end + 1;
                end
            end
        else -- Text content
            local text_end = mem.findScalarPos(buf, pos, string.byte('<')) or len + 1;
            local content = buffer.readstring(buf, pos, text_end - pos);
            local text = string.gsub((string.gsub(content, "^%s+", '')), "%s+$", '');
            if (text ~= '' and #parent_stack > 0) then
                local parent = parent_stack[#parent_stack];
                parent.children = unescapeText(text);
            end
            pos = text_end;
        end
    end

    if (#parent_stack > 0) then
        assert(false, `unclosed tag: {parent_stack[#parent_stack].tag}`);
    end

    return root;
end

function xml.parse(buf: buffer)
    return parse(buf);
end

local function serializeAttributes(attrs: { [string]: string }): string
    local parts = {}
    for key, value in pairs(attrs) do
        table.insert(parts, string.format(`%s="%s"`, key, value))
    end
    return table.concat(parts, ' ')
end

local function serializeNode(node: Node, depth: number): string
    local parts = {}
    local attr_str = serializeAttributes(node.attributes)
    local tag_str = string.format('<%s%s>', node.tag, if (attr_str ~= "") then ` {attr_str}` else "")
    local indent = string.rep('\t', depth)
    table.insert(parts, indent)
    table.insert(parts, tag_str)
    local children_len = #node.children
    if (type(node.children) == "string") then
        if (node.cdata) then
            table.insert(parts, CDATA(node.children))
        else
            if (node.raw) then
                table.insert(parts, node.children)
            else
                table.insert(parts, escapeText(node.children))
            end
        end
    else
        for i, child in node.children do
            table.insert(parts, '\n')
            table.insert(parts, serializeNode(child, depth + 1))
        end
    end
    if (children_len > 0 and type(node.children) ~= "string") then
        table.insert(parts, '\n')
        table.insert(parts, indent)
    end
    table.insert(parts, string.format('</%s>', node.tag))
    return table.concat(parts, "");
end

function xml.stringify(node: Node): string
    return serializeNode(node, 0)
end

return xml
