import re

def escape_lua_string(s):
    # Safeguard against None and escape backslashes and quotes
    if s is None:
        return ""
    return s.replace('\\', '\\\\').replace('"', '\\"')

def remove_note_prefix(desc):
    # Check if desc starts with "1  " or "2  " and remove it
    if desc.startswith("1  ") or desc.startswith("2  "):
        return desc[3:]  # Remove the first three characters (note + two spaces)
    return desc

def parse_vim_keybindings(input_file, output_file):
    keybindings = []
    
    with open(input_file, 'r') as file:
        lines = file.readlines()

    mode = None

    for line in lines:
        line = line.strip()
        
        # Check for mode headers
        if "Insert mode" in line:
            mode = "Insert"
        elif "Normal mode" in line:
            mode = "Normal"
        elif "Visual mode" in line:
            mode = "Visual"
        elif "Command-line editing" in line:
            mode = "Command-line"
        elif "Terminal-Job mode" in line:
            mode = "Terminal-Job"
        elif "EX commands" in line:
            mode = "EX"
        
        # Regex to handle keybinding entries with multiple key commands and descriptions
        match = re.match(r'\|([^\|]+)\|\s+([^\t]+)\t+(.+)', line)

        if match and mode:
            lhs = match.group(2).strip()  # Capture the keybinding part, including multiple keys
            desc = match.group(3).strip()  # Capture the description part

            # Remove note prefix (if any)
            desc = remove_note_prefix(desc)

            # Escape backslashes and quotes in lhs and desc
            lhs = escape_lua_string(lhs)
            desc = escape_lua_string(desc)

            # Only add valid keybindings
            if lhs and desc:
                keybindings.append(f'{{ mode = "{mode}", lhs = "{lhs}", desc = "{desc}" }}')

    # Write the keybindings to the Lua file
    with open(output_file, 'w') as file:
        file.write("local common_vim_keybindings = {\n")
        for binding in keybindings:
            file.write(f"    {binding},\n")
        file.write("}\n")
        # Add the return statement at the end
        file.write("return common_vim_keybindings\n")

# Call the function with the paths to the input and output files
parse_vim_keybindings('index.txt', 'common_keybindings.lua')
