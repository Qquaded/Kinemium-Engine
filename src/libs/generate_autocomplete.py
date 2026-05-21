#!/usr/bin/env python3
"""
Luau Definition to Autocomplete Converter
Converts .d.luau definition files into Luau autocomplete tables
"""

import re
import sys
from pathlib import Path
from typing import List, Dict, Any, Optional


class LuauParser:
    def __init__(self):
        self.completions = []
        self.module_types = {}  # Maps module type name -> body content
        
    def parse_enum(self, content: str) -> List[Dict[str, Any]]:
        """Parse enum declarations from the definition file"""
        enum_items = []
        
        # Match the main Enum declaration
        enum_pattern = r'declare Enum: \{(.*?)\n\}'
        enum_match = re.search(enum_pattern, content, re.DOTALL)
        
        if enum_match:
            enum_content = enum_match.group(1)
            # Extract individual enum types
            enum_type_pattern = r'(\w+): \{([^}]+)\}'
            
            for match in re.finditer(enum_type_pattern, enum_content):
                enum_name = match.group(1)
                enum_values = match.group(2)
                
                # Add the enum type itself
                enum_items.append({
                    "label": f"Enum.{enum_name}",
                    "type": "enum",
                    "icon": "Enum.png"
                })
                
                # Extract enum members
                member_pattern = r'(\w+): number'
                for member_match in re.finditer(member_pattern, enum_values):
                    member_name = member_match.group(1)
                    enum_items.append({
                        "label": f"Enum.{enum_name}.{member_name}",
                        "type": "constant",
                        "icon": "EnumItem.png"
                    })
        
        return enum_items
    
    def parse_class_methods(self, class_content: str) -> List[Dict[str, Any]]:
        """Parse methods from a class/instance definition"""
        methods = []
        
        # Match method signatures: methodName: (args) -> returnType
        method_pattern = r'(\w+): \((.*?)\) -> (.*?)(?:,|\n)'
        
        for match in re.finditer(method_pattern, class_content, re.DOTALL):
            method_name = match.group(1)
            args_str = match.group(2).strip()
            return_type = match.group(3).strip()
            
            # Parse arguments
            args = []
            if args_str and args_str != 'self: ' + method_name.split('.')[0]:
                # Remove 'self' parameter
                args_str = re.sub(r'self:\s*\w+,?\s*', '', args_str)
                
                # Extract argument names
                arg_pattern = r'(\w+):\s*[^,]+'
                for arg_match in re.finditer(arg_pattern, args_str):
                    args.append(arg_match.group(1))
            
            methods.append({
                "label": method_name,
                "type": "method",
                "icon": "Method.png",
                "args": args if args else None
            })
        
        return methods
    
    def parse_class_properties(self, class_content: str) -> List[Dict[str, Any]]:
        """Parse properties from a class/instance definition"""
        properties = []
        
        # Match property signatures: propertyName: Type
        # Exclude methods (those with function signatures)
        property_pattern = r'(\w+): ([^,\n\(]+)(?:,|\n)'
        
        for match in re.finditer(property_pattern, class_content):
            prop_name = match.group(1)
            prop_type = match.group(2).strip()
            
            # Skip if it looks like a method (contains ->)
            if '->' in prop_type:
                continue
            
            properties.append({
                "label": prop_name,
                "type": "property",
                "icon": "Property.png"
            })
        
        return properties
    
    def parse_instance_classes(self, content: str) -> List[Dict[str, Any]]:
        """Parse instance class definitions"""
        classes = []
        
        # Match export type ClassName = Instance & { ... }
        class_pattern = r'export type (\w+) = Instance & \{(.*?)\n\}'
        
        for match in re.finditer(class_pattern, content, re.DOTALL):
            class_name = match.group(1)
            class_content = match.group(2)
            
            # Parse methods and properties
            methods = self.parse_class_methods(class_content)
            properties = self.parse_class_properties(class_content)
            
            # Create class entry
            class_entry = {
                "label": class_name,
                "type": "class",
                "icon": "Class.png"
            }
            
            # Add members if any exist
            members = methods + properties
            if members:
                class_entry["members"] = members
            
            classes.append(class_entry)
        
        return classes
    
    def parse_module_type_definitions(self, content: str) -> None:
        """Pre-parse all 'type XModule = { ... }' blocks into a dictionary.
        Also handles underscore-prefixed variants like _Instance_Module."""
        # Match type definitions that end with Module
        # This handles: type Color3Module = { ... }
        #               type _Instance_Module = { ... }
        module_pattern = r'type (_?\w*Module) = \{(.*?)\n\}'
        
        for match in re.finditer(module_pattern, content, re.DOTALL):
            module_name = match.group(1)
            module_body = match.group(2)
            self.module_types[module_name] = module_body
    
    def parse_module_members(self, module_body: str) -> List[Dict[str, Any]]:
        """Parse members (methods, constructors, properties) from a module type body.
        Excludes metamethods (those starting with __)."""
        members = []
        seen_labels = set()
        
        for line in module_body.split('\n'):
            line = line.strip().rstrip(',')
            if not line:
                continue
            
            # Match: memberName: (args) -> returnType  (methods/constructors)
            method_match = re.match(r'(\w+):\s*\((.*)\)\s*->\s*(.*)', line)
            if method_match:
                member_name = method_match.group(1)
                args_str = method_match.group(2).strip()
                
                # Skip metamethods
                if member_name.startswith('__'):
                    continue
                
                if member_name in seen_labels:
                    continue
                seen_labels.add(member_name)
                
                # Parse arguments (skip 'self' params)
                args = []
                if args_str:
                    # Remove self parameter
                    args_str = re.sub(r'self:\s*\w+,?\s*', '', args_str).strip()
                    if args_str:
                        # Handle variadic
                        if '...' in args_str:
                            args.append('...')
                        else:
                            arg_pattern = r'(\w+):\s*[^,]+'
                            for arg_match in re.finditer(arg_pattern, args_str):
                                args.append(arg_match.group(1))
                
                # Determine if this is a constructor (named 'new', 'from*', 'From*')
                if member_name == 'new' or member_name.startswith('from') or member_name.startswith('From'):
                    member_type = "constructor"
                    icon = "Function.png"
                else:
                    member_type = "method"
                    icon = "Method.png"
                
                entry = {
                    "label": member_name,
                    "type": member_type,
                    "icon": icon,
                }
                if args:
                    entry["args"] = args
                members.append(entry)
                continue
            
            # Match: memberName: Type  (properties/constants)
            prop_match = re.match(r'(\w+):\s*(.+)', line)
            if prop_match:
                member_name = prop_match.group(1)
                member_type_str = prop_match.group(2).strip()
                
                # Skip metamethods
                if member_name.startswith('__'):
                    continue
                
                # Skip if it looks like a function (contains ->)
                if '->' in member_type_str:
                    continue
                
                if member_name in seen_labels:
                    continue
                seen_labels.add(member_name)
                
                members.append({
                    "label": member_name,
                    "type": "property",
                    "icon": "Property.png"
                })
        
        return members
    
    def parse_library_declarations(self, content: str) -> List[Dict[str, Any]]:
        """Parse library declarations: 'declare X: XModule' patterns.
        Resolves the module type to extract members."""
        libraries = []
        
        # Match declare X: YModule (where type ends with Module)
        lib_pattern = r'declare (\w+): (_?\w*Module)'
        
        for match in re.finditer(lib_pattern, content):
            lib_name = match.group(1)
            module_type = match.group(2)
            
            lib_entry = {
                "label": lib_name,
                "type": "library",
                "icon": "Module.png"
            }
            
            # Look up the module type definition and extract members
            if module_type in self.module_types:
                members = self.parse_module_members(self.module_types[module_type])
                if members:
                    lib_entry["members"] = members
            
            libraries.append(lib_entry)
        
        return libraries
    
    def parse_global_functions(self, content: str) -> List[Dict[str, Any]]:
        """Parse global function declarations"""
        functions = []
        
        # Match declare functionName: (args) -> returnType patterns
        func_pattern = r'declare (\w+): \((.*?)\) -> '
        
        for match in re.finditer(func_pattern, content):
            func_name = match.group(1)
            args_str = match.group(2).strip()
            
            # Parse arguments
            args = []
            if args_str and args_str != '':
                # Handle ...any for variadic functions
                if '...' in args_str:
                    args.append('...')
                else:
                    # Extract argument names
                    arg_pattern = r'(\w+):\s*[^,\)]+'
                    for arg_match in re.finditer(arg_pattern, args_str):
                        args.append(arg_match.group(1))
            
            functions.append({
                "label": func_name,
                "type": "function",
                "icon": "Function.png",
                "args": args if args else None
            })
        
        return functions
    
    def parse_services(self, content: str) -> List[Dict[str, Any]]:
        """Parse service definitions from GetService union type"""
        services = []
        
        # Match GetService union type
        service_pattern = r'\| \(self: DataModel, "(\w+)"\) -> (\w+)'
        
        for match in re.finditer(service_pattern, content):
            service_name = match.group(1)
            service_type = match.group(2)
            
            services.append({
                "label": service_name,
                "type": "service",
                "icon": "Service.png"
            })
        
        return services
    
    def parse_global_variables(self, content: str) -> List[Dict[str, Any]]:
        """Parse global variable declarations (non-function, non-module globals)"""
        variables = []
        
        # Match declare varName: Type patterns
        var_pattern = r'declare (\w+): ([^\n]+)'
        
        for match in re.finditer(var_pattern, content):
            var_name = match.group(1)
            var_type = match.group(2).strip()
            
            # Skip if it's a function (contains ->)
            if '->' in var_type:
                continue
            
            # Skip if it's a module type declaration (handled by parse_library_declarations)
            if re.match(r'_?\w*Module$', var_type):
                continue
            
            # Skip Enum (handled separately)
            if var_name == 'Enum':
                continue
            
            # Determine icon and type based on heuristics
            icon = "Variable.png"
            var_type_name = "global"
            
            # Check if type matches a known service/instance class name
            # (i.e. declare Lighting: Lighting - type name matches a class)
            if var_type == var_name or var_type == 'DataModel':
                icon = "Service.png"
                var_type_name = "service"
            elif var_name == 'task':
                icon = "Module.png"
                var_type_name = "library"
            elif var_type == 'boolean':
                icon = "Variable.png"
                var_type_name = "constant"
            elif var_type == 'string' or var_type == 'number' or var_type == 'any':
                icon = "Variable.png"
                var_type_name = "constant"
            
            variables.append({
                "label": var_name,
                "type": var_type_name,
                "icon": icon
            })
        
        return variables
    
    def parse_file(self, filepath: Path) -> List[Dict[str, Any]]:
        """Parse a .d.luau file and extract all completions"""
        print(f"Parsing {filepath}...")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pre-parse module type definitions first (needed for library resolution)
        self.parse_module_type_definitions(content)
        print(f"  Found {len(self.module_types)} module type definitions")
        
        completions = []
        
        # Parse different sections
        completions.extend(self.parse_global_functions(content))
        completions.extend(self.parse_global_variables(content))
        completions.extend(self.parse_enum(content))
        completions.extend(self.parse_instance_classes(content))
        completions.extend(self.parse_services(content))
        
        # Parse library declarations (declare X: XModule)
        libraries = self.parse_library_declarations(content)
        completions.extend(libraries)
        print(f"  Found {len(libraries)} library declarations")
        
        return completions
    
    def format_completion_entry(self, entry: Dict[str, Any], indent: int = 0) -> str:
        """Format a single completion entry as Luau table syntax"""
        indent_str = "\t" * indent
        lines = [f"{indent_str}{{"]
        
        # Add label
        lines.append(f'{indent_str}\tlabel = "{entry["label"]}",')
        
        # Add type
        lines.append(f'{indent_str}\ttype = "{entry["type"]}",')
        
        # Add icon
        lines.append(f'{indent_str}\ticon = "{entry["icon"]}",')
        
        # Add args if present
        if "args" in entry and entry["args"]:
            args_str = ", ".join(f'"{arg}"' for arg in entry["args"])
            lines.append(f'{indent_str}\targs = {{ {args_str} }},')
        
        # Add members if present
        if "members" in entry and entry["members"]:
            lines.append(f'{indent_str}\tmembers = {{')
            for member in entry["members"]:
                member_lines = self.format_completion_entry(member, indent + 2)
                lines.append(member_lines)
            lines.append(f'{indent_str}\t}},')
        
        lines.append(f"{indent_str}}},")
        
        return "\n".join(lines)
    
    def generate_output(self, completions: List[Dict[str, Any]]) -> str:
        """Generate the final Luau autocomplete table"""
        output = ["local completions = {"]
        
        for entry in completions:
            output.append(self.format_completion_entry(entry, 0))
        
        output.append("}")
        output.append("")
        output.append("return completions")
        
        return "\n".join(output)


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_autocomplete.py <input.d.luau> [output.luau]")
        print("Example: python generate_autocomplete.py k.d.luau k_completions.luau")
        sys.exit(1)
    
    input_file = Path(sys.argv[1])
    
    if not input_file.exists():
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)
    
    # Determine output file
    if len(sys.argv) >= 3:
        output_file = Path(sys.argv[2])
    else:
        output_file = input_file.with_name(f"{input_file.stem}_completions.luau")
    
    # Parse the definition file
    parser = LuauParser()
    completions = parser.parse_file(input_file)
    
    print(f"Found {len(completions)} completion entries")
    
    # Generate output
    output_content = parser.generate_output(completions)
    
    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(output_content)
    
    print(f"Generated autocomplete file: {output_file}")
    print(f"Total entries: {len(completions)}")


if __name__ == "__main__":
    main()
