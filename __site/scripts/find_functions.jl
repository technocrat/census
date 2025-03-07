#!/usr/bin/env julia

"""
This script traverses a directory to find Julia files containing function definitions
and writes include statements to an output file.

Usage: julia find_functions.jl <directory>
"""

using Dates

# Check for command line arguments
if length(ARGS) != 1
    println("Usage: julia $(PROGRAM_FILE) <directory>")
    exit(1)
end

const input_dir = ARGS[1]
const output_file = "includes.jl"

# Check if directory exists
if !isdir(input_dir)
    println("Error: Directory '$(input_dir)' does not exist")
    exit(1)
end

# Function to check if a file contains function definitions
function has_function_definition(file_path)
    content = read(file_path, String)
    # Match function definitions like:
    # function name(...) or
    # name(...) = 
    return occursin(r"(function\s+\w+|^\s*\w+\s*\([^)]*\)\s*=)", content)
end

# Find all Julia files in directory and subdirectories
function find_julia_files(dir)
    julia_files = String[]
    for (root, _, files) in walkdir(dir)
        for file in files
            if endswith(file, ".jl")
                push!(julia_files, joinpath(root, file))
            end
        end
    end
    return julia_files
end

# Main processing
try
    println("Searching for Julia files in $(input_dir)...")
    julia_files = find_julia_files(input_dir)
    
    # Open output file for writing includes
    open(output_file, "w") do io
        println(io, "# Auto-generated include statements")
        println(io, "# Generated on: $(now())")
        println(io)
        
        for file in julia_files
            if has_function_definition(file)
                # Convert absolute path to relative path
                rel_path = relpath(file, dirname(output_file))
                println(io, "include(\"$(rel_path)\")")
            end
        end
    end
    
    println("Successfully wrote include statements to $(output_file)")
catch e
    println("Error occurred: $(e)")
    exit(1)
end

