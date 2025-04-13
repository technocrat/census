#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Fix library issues for CairoMakie on macOS

println("Library Fix for Julia Visualization on macOS")
println("===========================================")

# Check if we're on macOS
if !Sys.isapple()
    println("This script is only for macOS systems")
    exit(1)
end

# First try to load the library to see if it's already fixed
try
    println("Testing if CairoMakie can be loaded...")
    using CairoMakie
    println("✅ CairoMakie loaded successfully! No fix needed.")
    exit(0)
catch e
    println("❌ CairoMakie failed to load. Applying fixes...")
end

# Define needed libraries and their sources
libraries = [
    Dict("file" => "libxml2.2.dylib", "source" => "/opt/homebrew/lib/libxml2.2.dylib"),
    Dict("file" => "libintl.8.dylib", "source" => "/opt/homebrew/lib/libintl.8.dylib"),
]

# Check if source libraries exist
for lib in libraries
    if !isfile(lib["source"])
        println("❌ Source library not found at $(lib["source"])")
        if occursin("libxml2", lib["source"])
            println("Please install libxml2 with: brew install libxml2")
        elseif occursin("libintl", lib["source"])
            println("Please install gettext with: brew install gettext")
        end
    else
        println("✅ Found source library at $(lib["source"])")
    end
end

# Get the artifact path
artifact_path = "/Users/technocrat/.julia/artifacts"

# Find all lib directories in artifacts
println("\nSearching for library directories in Julia artifacts...")
lib_dirs = []
for dir in readdir(artifact_path, join=true)
    if isdir(dir)
        lib_dir = joinpath(dir, "lib")
        if isdir(lib_dir)
            push!(lib_dirs, lib_dir)
        end
    end
end

println("Found $(length(lib_dirs)) lib directories in artifacts")

# Create symbolic links in each artifact lib directory
for lib_dir in lib_dirs
    println("\nProcessing $lib_dir...")
    
    for lib in libraries
        target_lib = joinpath(lib_dir, lib["file"])
        source_lib = lib["source"]
        
        # Check if target already exists
        if isfile(target_lib) || islink(target_lib)
            println("Removing existing file/link at $target_lib")
            rm(target_lib, force=true)
        end
        
        # Create symbolic link
        println("Linking $(lib["file"]): $source_lib -> $target_lib")
        try
            run(`ln -sf $source_lib $target_lib`)
            println("✅ Created symbolic link successfully")
        catch e
            println("❌ Failed to create symbolic link: $e")
        end
    end
end

# Also create the links in the Julia lib directory
julia_lib_dir = joinpath(dirname(Sys.BINDIR), "lib")
println("\nProcessing Julia lib directory: $julia_lib_dir...")

for lib in libraries
    target_lib = joinpath(julia_lib_dir, lib["file"])
    source_lib = lib["source"]
    
    # Check if target already exists
    if isfile(target_lib) || islink(target_lib)
        println("Removing existing file/link at $target_lib")
        rm(target_lib, force=true)
    end
    
    # Create symbolic link
    println("Linking $(lib["file"]): $source_lib -> $target_lib")
    try
        run(`ln -sf $source_lib $target_lib`)
        println("✅ Created symbolic link successfully")
    catch e
        println("❌ Failed to create symbolic link: $e")
    end
end

# Test if it works now
println("\nTesting if CairoMakie can now be loaded...")
try
    using CairoMakie
    println("✅ SUCCESS! CairoMakie loaded successfully.")
    
    # Create a test plot to confirm everything works
    println("\nCreating a test plot...")
    fig = Figure()
    ax = Axis(fig[1, 1], title="Test Plot")
    scatter!(ax, rand(10), rand(10), color=:blue, markersize=15)
    text!(ax, "Visualization working!", position=(0.5, 0.5), align=(:center, :center), textsize=20)
    
    test_file = joinpath(homedir(), "visualization_test.png")
    save(test_file, fig)
    println("✅ Test plot saved to $test_file")
catch e
    println("❌ CairoMakie still fails to load: $e")
    println("\nAdditional steps you can try:")
    println("1. Add these lines to your ~/.zshrc file:")
    println("   export DYLD_FALLBACK_LIBRARY_PATH=\"/opt/homebrew/lib:\$DYLD_FALLBACK_LIBRARY_PATH\"")
    println("   export LIBXML2_PATH=\"/opt/homebrew/lib\"")
    println("2. Run: source ~/.zshrc")
    println("3. Try again with: julia -e 'using CairoMakie'")
    println("4. If still failing, run: brew install gettext libxml2 libffi pcre dbus glib")
    println("5. Then restart your terminal and try this script again")
end

println("\nDone!") 