#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Helper script to run Julia with Census.jl properly included

"""
    run_script(script_path)

Run a Julia script with Census.jl properly included in the LOAD_PATH.
The script will have access to the Census module without modification.

# Arguments
- `script_path::String`: Path to the Julia script to run

# Example
```julia
include("run_with_census.jl")
run_script("my_analysis.jl")
```
"""
function run_script(script_path)
    # Get the package directory
    package_dir = @__DIR__
    
    # Construct absolute path to script if relative
    script_abs_path = isabspath(script_path) ? script_path : joinpath(package_dir, script_path)
    
    # Check if script exists
    if !isfile(script_abs_path)
        error("Script not found: $script_abs_path")
    end
    
    # Construct command to run script with proper path
    cmd = `$(Base.julia_cmd()) -L $(joinpath(package_dir, "load_census.jl")) $script_abs_path`
    
    # Print command
    println("Running: $cmd")
    
    # Run script
    run(cmd)
end

"""
Print command-line instructions for running scripts with Census.jl
"""
function print_instructions()
    package_dir = @__DIR__
    
    println("\n=== HOW TO RUN SCRIPTS WITH CENSUS.JL ===")
    println("\nMethod 1: From the Julia REPL")
    println("```julia")
    println("include(\"$(joinpath(package_dir, "load_census.jl"))\")")
    println("using Census")
    println("# Your code here...")
    println("```")
    
    println("\nMethod 2: From the command line")
    println("```bash")
    println("julia -L \"$(joinpath(package_dir, "load_census.jl"))\" your_script.jl")
    println("```")
    
    println("\nMethod 3: Using this helper")
    println("```julia")
    println("include(\"$(joinpath(package_dir, "run_with_census.jl"))\")")
    println("run_script(\"your_script.jl\")  # Will run with Census loaded")
    println("```")
    
    println("\nMethod 4: Inside scripts (at the top of the script)")
    println("```julia")
    println("# Add the Census package to LOAD_PATH")
    println("census_dir = \"$package_dir\"")
    println("if !(census_dir in LOAD_PATH)")
    println("    push!(LOAD_PATH, census_dir)")
    println("end")
    println("using Census")
    println("```")
end

# Print instructions if run directly
if abspath(PROGRAM_FILE) == @__FILE__
    print_instructions()
end 