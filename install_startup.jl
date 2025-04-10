#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Installer for Census.jl startup script

# Get the path to the Julia config directory
config_dir = joinpath(homedir(), ".julia", "config")

# Create the directory if it doesn't exist
if !isdir(config_dir)
    println("Creating config directory: $config_dir")
    mkpath(config_dir)
end

# Path to startup script in repo
repo_startup = joinpath(@__DIR__, "startup.jl")

# Destination path for startup script
dest_startup = joinpath(config_dir, "startup.jl")

# Check if we have a startup script to copy
if !isfile(repo_startup)
    error("Startup script not found: $repo_startup")
end

# Check if a startup script already exists
if isfile(dest_startup)
    println("Found existing startup.jl at $dest_startup")
    println("Backing up existing file...")
    backup_file = joinpath(config_dir, "startup.jl.bak")
    cp(dest_startup, backup_file, force=true)
    println("✅ Backed up to $backup_file")
    
    # Read the existing file to check for our code
    existing_content = read(dest_startup, String)
    if occursin("Census.jl", existing_content)
        println("⚠️ Census.jl configuration already exists in startup.jl")
        println("   Would you like to overwrite it? (y/n)")
        response = readline()
        if lowercase(response) != "y"
            println("Installation aborted. You can:")
            println("1. Manually edit $dest_startup to include Census.jl setup")
            println("2. Re-run this script and choose to overwrite")
            exit(0)
        end
    end
end

# Copy startup.jl to the config directory
println("Installing startup.jl to $dest_startup")
cp(repo_startup, dest_startup, force=true)
println("✅ Installed startup.jl")

# Verify installation
println("\nVerifying installation...")
if isfile(dest_startup)
    println("✅ Startup script installed successfully.")
    println("\nThe startup script will automatically load Census.jl when you start Julia.")
    println("To test it, restart your Julia REPL and you should see:")
    println("  ✅ Added Census.jl to LOAD_PATH")
    println("  ✅ Census module preloaded")
else
    println("❌ Installation failed!")
    println("Please try installing manually by copying:")
    println("$repo_startup")
    println("to:")
    println("$dest_startup")
end

# Quick check that the Census.jl directory is actually where we expect
census_dir = expanduser("~/projects/Census.jl")
if !isdir(census_dir)
    println("\n⚠️ Warning: Census.jl directory not found at $census_dir")
    println("   You'll need to edit $dest_startup to set the correct path.")
else
    println("\n✅ Census.jl directory found at $census_dir")
end 