#!/usr/bin/env julia

using Pkg
using Base.Filesystem

# Find all .jl files in the scripts directory
scripts_dir = joinpath(@__DIR__, "scripts")
script_files = filter(file -> endswith(file, ".jl"), readdir(scripts_dir, join=true))

println("Found $(length(script_files)) script files to process")

header_template = """
# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta
"""

# Patterns to look for and ensure they exist
required_imports = [
    r"using\s+Census"i,
    r"using\s+DataFrames"i,
    r"using\s+DataFramesMeta"i,
]

# Environment variables to ensure
required_env_vars = [
    r"ENV\[\"RCALL_ENABLE_REPL\"\]\s*=\s*\"false\""i,
    r"ENV\[\"R_HOME\"\]\s*="i,
]

for script_file in script_files
    println("Processing $script_file")
    
    # First, make a backup if we don't already have one
    backup_file = script_file * ".bak"
    if !isfile(backup_file)
        cp(script_file, backup_file)
        println("  Created backup: $backup_file")
    end
    
    # Read the script file
    content = read(script_file, String)
    original_content = content
    
    # Clean up any duplicate headers from previous runs
    content = replace(content, r"# SCRIPT\s+# SCRIPT"i => "# SCRIPT")
    content = replace(content, r"# SPDX-License-Identifier: MIT\s+# SPDX-License-Identifier: MIT"i => "# SPDX-License-Identifier: MIT")
    
    # Check if the file already has the SCRIPT marker
    has_script_marker = occursin("# SCRIPT", content)
    if !has_script_marker
        # If it doesn't have the marker, add it near the top
        # Find a good insertion point after any initial comments
        lines = split(content, "\n")
        insert_index = 1
        
        # Look for a place after initial comments/headers
        for (i, line) in enumerate(lines)
            if startswith(line, "#!") || startswith(line, "# ")
                insert_index = i + 1
            elseif !isempty(strip(line))
                break
            end
        end
        
        # Insert SCRIPT marker
        insert!(lines, insert_index, "# SCRIPT")
        content = join(lines, "\n")
        println("  Added SCRIPT marker")
    end
    
    # Check for required environment variables
    env_vars_missing = false
    for pattern in required_env_vars
        if !occursin(pattern, content)
            env_vars_missing = true
            break
        end
    end
    
    # Check for required imports
    imports_missing = false
    for pattern in required_imports
        if !occursin(pattern, content)
            imports_missing = true
            break
        end
    end
    
    # If any required elements are missing, we need to overhaul the file structure
    if env_vars_missing || imports_missing
        # Start with a clean representation of the file
        lines = split(content, "\n")
        
        # Extract the shebang line if any
        shebang_line = ""
        if length(lines) > 0 && startswith(lines[1], "#!")
            shebang_line = lines[1]
            lines = lines[2:end]
        end
        
        # Remove existing SPDX, SCRIPT markers, imports and env vars to avoid duplication
        filtered_lines = String[]
        skip_next = false
        
        for (i, line) in enumerate(lines)
            # Skip lines from previous template and header
            if occursin("# SPDX-License-Identifier", line) || 
               occursin("# SCRIPT", line) ||
               occursin("ENV[\"RCALL_ENABLE_REPL\"]", line) ||
               occursin("ENV[\"R_HOME\"]", line) ||
               occursin("using Census", line) ||
               occursin("using DataFrames", line) ||
               occursin("using DataFramesMeta", line) ||
               occursin("# IMPORTANT:", line) ||
               occursin("# Import Census module", line) ||
               occursin("# Set environment variables", line)
                skip_next = true
            elseif skip_next && (isempty(strip(line)) || startswith(line, "#"))
                skip_next = true  # Continue skipping empty/comment lines
            else
                skip_next = false
                push!(filtered_lines, line)
            end
        end
        
        # Recreate the file with the proper template
        new_content = ""
        if !isempty(shebang_line)
            new_content *= shebang_line * "\n"
        end
        
        # Add our template header
        new_content *= header_template * "\n"
        
        # Add the remaining content
        if !isempty(filtered_lines)
            new_content *= join(filtered_lines, "\n")
        end
        
        content = new_content
        println("  Added standard header with imports and environment variables")
    end
    
    # Write back the modified content if changes were made
    if content != original_content
        write(script_file, content)
        println("  Updated file")
    else
        println("  No changes needed")
    end
end

println("\nScript fix completed. Please review the changes manually to ensure everything is working correctly.")
println("For more information, see SCRIPT_GUIDANCE.md") 