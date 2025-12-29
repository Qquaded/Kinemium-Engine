import re
import sys
import os
import glob

# Check if header files were provided
if len(sys.argv) < 2:
    print("Usage: python pystruct.py <header1.h> <header2.h> ... or --all [--prefix PREFIX] [--api-macro MACRO] [--output FILENAME]")
    print("  --all, -a: Process all .h files in current directory")
    print("  --prefix PREFIX: Only process functions with this prefix (e.g., R3D_, JPH_, enet_)")
    print("  --api-macro MACRO: Process functions with this API macro (e.g., ENET_API, R3DAPI)")
    print("  --output FILENAME: Output file name (default: funcs.luau)")
    sys.exit(1)

# Parse arguments
header_files = []
function_prefix = None
api_macro = None
output_file = "funcs.luau"

i = 1
while i < len(sys.argv):
    arg = sys.argv[i]
    
    if arg == '--all' or arg == '-a':
        header_files = glob.glob('*.h')
    elif arg == '--prefix':
        if i + 1 < len(sys.argv):
            function_prefix = sys.argv[i + 1]
            i += 1
    elif arg == '--api-macro':
        if i + 1 < len(sys.argv):
            api_macro = sys.argv[i + 1]
            i += 1
    elif arg == '--output' or arg == '-o':
        if i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 1
    elif not arg.endswith('.py'):
        if '*' in arg or '?' in arg:
            header_files.extend(glob.glob(arg))
        else:
            header_files.append(arg)
    
    i += 1

# Filter to only .h files
header_files = [f for f in header_files if f.endswith('.h')]

if len(header_files) == 0:
    print("No header files found!")
    sys.exit(1)

# Only map primitive C types - everything else becomes a pointer
primitive_types = {
    "void": "ffi.types.void",
    "bool": "ffi.types.u8",
    "int": "ffi.types.i32",
    "unsigned int": "ffi.types.u32",
    "int8_t": "ffi.types.i8",
    "uint8_t": "ffi.types.u8",
    "int16_t": "ffi.types.i16",
    "uint16_t": "ffi.types.u16",
    "int32_t": "ffi.types.i32",
    "uint32_t": "ffi.types.u32",
    "int64_t": "ffi.types.i64",
    "uint64_t": "ffi.types.u64",
    "float": "ffi.types.float",
    "double": "ffi.types.double",
    "char": "ffi.types.i8",
    "unsigned char": "ffi.types.u8",
    "short": "ffi.types.i16",
    "unsigned short": "ffi.types.u16",
    "long": "ffi.types.i32",
    "unsigned long": "ffi.types.u32",
    "long long": "ffi.types.i64",
    "unsigned long long": "ffi.types.u64",
    "size_t": "ffi.types.u64",
    # ENet specific types
    "enet_uint8": "ffi.types.u8",
    "enet_uint16": "ffi.types.u16",
    "enet_uint32": "ffi.types.u32",
    "enet_uint64": "ffi.types.u64",
}

# Build function pattern dynamically
if api_macro:
    func_pattern = re.compile(
        rf"{re.escape(api_macro)}\s+(?P<ret>(?:const\s+)?[\w_]+(?:\s*\*)?)\s+(?P<name>\w+)\s*\((?P<args>[^\)]*)\);"
    )
elif function_prefix:
    func_pattern = re.compile(
        rf"\w+\s+(?P<ret>(?:const\s+)?[\w_]+(?:\s*\*)?)\s+(?P<name>{re.escape(function_prefix)}\w+)\s*\((?P<args>[^\)]*)\);"
    )
else:
    func_pattern = re.compile(
        r"(?:extern\s+)?(?P<ret>(?:const\s+)?[\w_]+(?:\s*\*)?)\s+(?P<name>\w+)\s*\((?P<args>[^\)]*)\);"
    )

# Regex to match typedef structs
struct_pattern = re.compile(
    r"typedef\s+struct\s+(?:_)?(?P<name>\w+)?\s*\{(?P<body>[^\}]+)\}\s*(?P<typedef_name>\w+)\s*;",
    re.DOTALL
)

# Regex to match struct fields
field_pattern = re.compile(
    r"(?P<type>(?:const\s+)?(?:struct\s+)?[\w_]+(?:\s*\*)?)\s+(?P<name>\w+)(?:\[(?P<array>[^\]]+)\])?(?:\s*:\s*\d+)?;",
)

# Regex to find constants used in array sizes
const_pattern = re.compile(r"#define\s+(\w+)\s+(.+)")

def extract_constants(content):
    """Extract #define constants that might be used in array sizes."""
    constants = {}
    for match in const_pattern.finditer(content):
        name = match.group(1)
        value = match.group(2).strip()
        # Try to evaluate simple numeric expressions
        try:
            # Remove comments
            value = re.sub(r'/\*.*?\*/', '', value)
            value = re.sub(r'//.*', '', value)
            value = value.strip()
            # Try to evaluate if it's a simple number or expression
            if re.match(r'^[\d\s\+\-\*/\(\)]+$', value):
                constants[name] = str(eval(value))
            else:
                constants[name] = value
        except:
            constants[name] = value
    return constants

def map_type(type_str):
    """Map a C type to FFI type. Returns pointer for non-primitives."""
    type_str = type_str.strip()
    
    if '*' in type_str:
        return "ffi.types.pointer"
    
    if type_str in primitive_types:
        return primitive_types[type_str]
    
    return "ffi.types.pointer"

def map_type_for_struct(type_str, known_structs):
    """Map a C type to FFI type for struct fields."""
    type_str = type_str.strip()
    
    type_str = type_str.replace("const ", "")
    type_str = type_str.replace("struct ", "")
    
    if '*' in type_str:
        return "ffi.types.pointer"
    
    if type_str in primitive_types:
        return primitive_types[type_str]
    
    if type_str in known_structs:
        return type_str
    
    return "ffi.types.pointer"

def substitute_constants(array_expr, constants):
    """Substitute constant names in array expressions with their values."""
    for const_name, const_value in constants.items():
        array_expr = array_expr.replace(const_name, const_value)
    return array_expr

def topological_sort_structs(structs_dict):
    """Sort structs based on dependencies to avoid forward references."""
    sorted_structs = []
    visited = set()
    temp_mark = set()
    
    def visit(name):
        if name in temp_mark:
            return
        if name in visited:
            return
        
        if name not in structs_dict:
            return
            
        temp_mark.add(name)
        
        body = structs_dict[name]
        for match in field_pattern.finditer(body):
            field_type = match.group("type").strip()
            field_type = field_type.replace("const ", "").replace("struct ", "").replace("*", "").strip()
            
            if field_type in structs_dict and field_type != name:
                visit(field_type)
        
        temp_mark.remove(name)
        visited.add(name)
        sorted_structs.append(name)
    
    for name in structs_dict.keys():
        if name not in visited:
            visit(name)
    
    return sorted_structs

def process_structs(content, constants):
    """Extract struct definitions from content."""
    structs_raw = {}
    
    for match in struct_pattern.finditer(content):
        struct_name = match.group("typedef_name")
        body = match.group("body")
        
        if struct_name and struct_name not in structs_raw:
            structs_raw[struct_name] = body
    
    sorted_names = topological_sort_structs(structs_raw)
    
    structs = []
    all_struct_names = set(structs_raw.keys())
    
    for struct_name in sorted_names:
        body = structs_raw[struct_name]
        fields = []
        
        for field_match in field_pattern.finditer(body):
            field_type = field_match.group("type").strip()
            field_name = field_match.group("name").strip()
            array_size = field_match.group("array")
            
            ffi_type = map_type_for_struct(field_type, all_struct_names)
            
            if array_size:
                # Substitute constants in array size
                array_size = substitute_constants(array_size.strip(), constants)
                # If it's still not a number, wrap in comment
                if not re.match(r'^\d+$', array_size):
                    fields.append(f'\t-- FIXME: Array size needs manual definition: {array_size}')
                    fields.append(f'\t-- {{ {field_name} = {ffi_type}:array({array_size}) }},')
                    continue
                fields.append(f'\t{{ {field_name} = {ffi_type}:array({array_size}) }},')
            else:
                fields.append(f'\t{{ {field_name} = {ffi_type} }},')
        
        if fields:
            struct_def = f"local {struct_name} = ffi.struct({{\n"
            struct_def += "\n".join(fields)
            struct_def += "\n})"
            struct_def += f"\nexport type {struct_name} = typeof({struct_name}:new({{}}))\n"
            
            structs.append((struct_name, struct_def))
    
    return structs

def process_header(header_file):
    """Process a single header file and return list of function definitions and structs."""
    try:
        try:
            with open(header_file, "r", encoding="utf-8") as f:
                content = f.read()
        except UnicodeDecodeError:
            with open(header_file, "r", encoding="latin-1") as f:
                content = f.read()
    except FileNotFoundError:
        print(f"Warning: Could not find '{header_file}', skipping...")
        return [], []
    
    # Extract constants before removing comments
    constants = extract_constants(content)
    
    # Store original content for struct parsing
    original_content = content
    
    # Remove comments and preprocessor directives for function parsing
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    content = re.sub(r'//.*', '', content)
    
    funcs = []
    
    for match in func_pattern.finditer(content):
        ret = match.group("ret").strip()
        name = match.group("name").strip()
        args_raw = match.group("args").strip()
        
        args = []
        if args_raw and args_raw.strip() not in ("void", ""):
            for arg in args_raw.split(","):
                arg = arg.strip()
                if not arg or arg == "void":
                    continue
                
                parts = arg.rsplit(None, 1)
                if len(parts) == 2:
                    arg_type = parts[0].strip()
                else:
                    arg_type = parts[0].strip()
                
                lua_type = map_type(arg_type)
                args.append(lua_type)
        
        ret_type = map_type(ret)
        
        funcs.append(f'    {name} = {{ returns = {ret_type}, args = {{ {", ".join(args)} }} }},')
    
    # Parse structs from original content
    original_content = re.sub(r'/\*.*?\*/', '', original_content, flags=re.DOTALL)
    original_content = re.sub(r'//.*', '', original_content)
    structs = process_structs(original_content, constants)
    
    return funcs, structs

# Process all header files
all_funcs = []
all_structs = []
struct_names = []

for header_file in header_files:
    print(f"Processing {header_file}...")
    funcs, structs = process_header(header_file)
    all_funcs.extend(funcs)
    all_structs.extend(structs)
    struct_names.extend([name for name, _ in structs])
    print(f"  Found {len(funcs)} functions and {len(structs)} structs")

# Write output
with open(output_file, "w") as f:
    f.write("--!strict\n")
    f.write("--!optimize 2\n")
    f.write("--!native\n\n")
    f.write("local ffi = zune.ffi\n\n")
    
    f.write("-- Basic type aliases\n")
    f.write("local int = ffi.types.i32\n")
    f.write("local uint = ffi.types.u32\n")
    f.write("local bool = ffi.types.u8\n")
    f.write("local float = ffi.types.float\n")
    f.write("local double = ffi.types.double\n\n")
    
    if all_structs:
        f.write("-- Struct definitions (ordered by dependencies)\n")
        f.write("-- NOTE: Some structs may have FIXME comments for array sizes that need manual definition\n\n")
        for struct_name, struct_def in all_structs:
            f.write(struct_def)
            f.write("\n")
    
    f.write("-- Function definitions\n")
    f.write("local funcs = {\n")
    for func in all_funcs:
        f.write(func + "\n")
    f.write("}\n\n")
    
    if all_structs:
        f.write("local structs = {\n")
        for struct_name, _ in all_structs:
            f.write(f"    {struct_name} = {struct_name},\n")
        f.write("}\n\n")
        f.write("return { funcs = funcs, structs = structs }\n")
    else:
        f.write("return funcs\n")

print(f"\nGenerated {len(all_funcs)} total functions and {len(all_structs)} total structs to {output_file}")
print("\nNOTE: Check for FIXME comments in the output for fields that need manual adjustment")