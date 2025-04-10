#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Installer for Census.jl Jupyter kernel integration

using Pkg
using IJulia

# Ensure IJulia is installed
if !haskey(Pkg.project().dependencies, "IJulia")
    println("Installing IJulia...")
    Pkg.add("IJulia")
    using IJulia
end

# Get the path to our Jupyter kernel startup script
repo_jupyter = joinpath(@__DIR__, "jupyter_kernel_startup.jl")

# Check if the script exists
if !isfile(repo_jupyter)
    error("Jupyter startup script not found: $repo_jupyter")
end

# Get the path to the Julia kernel directory
kernel_dir = try
    kernel_spec = IJulia.find_jupyter_kernel("julia")
    if kernel_spec === nothing
        # Create a new kernel if none exists
        println("No existing Julia kernel found. Installing...")
        IJulia.installkernel("Julia", "--project=@.")
        kernel_spec = IJulia.find_jupyter_kernel("julia")
    end
    
    if kernel_spec === nothing
        error("Failed to locate or install Julia kernel")
    end
    
    kernel_spec.dir
catch e
    error("Failed to locate IJulia kernel: $e")
end

println("Found Jupyter kernel directory: $kernel_dir")

# Path for the kernel.json file
kernel_json = joinpath(kernel_dir, "kernel.json")

# Make sure the kernel.json file exists
if !isfile(kernel_json)
    error("kernel.json not found in $kernel_dir")
end

# Read the kernel.json file
println("Reading kernel configuration...")
kernel_config = JSON.parse(read(kernel_json, String))

# Path for the startup script in the kernel directory
dest_jupyter = joinpath(kernel_dir, "kernel_startup.jl")

# Copy the startup script
println("Installing Jupyter startup script to $dest_jupyter")
cp(repo_jupyter, dest_jupyter, force=true)

# Add the startup script to the kernel arguments if not already there
script_arg = "--startup-file=no"
startup_arg = "--load=$dest_jupyter"

if !haskey(kernel_config, "argv") || !(startup_arg in kernel_config["argv"])
    # Add startup script to kernel arguments
    if haskey(kernel_config, "argv")
        # Find the index of the "--startup-file=no" argument
        startup_idx = findfirst(x -> startswith(x, "--startup-file"), kernel_config["argv"])
        
        if startup_idx !== nothing
            # Insert after the startup-file argument
            insert!(kernel_config["argv"], startup_idx + 1, startup_arg)
        else
            # Append to the end
            push!(kernel_config["argv"], startup_arg)
        end
    else
        # Create a default argv array
        kernel_config["argv"] = ["julia", "-i", "--startup-file=no", startup_arg, "--threads=auto", "{connection_file}"]
    end
    
    # Write the updated kernel.json
    println("Updating kernel configuration...")
    open(kernel_json, "w") do f
        write(f, JSON.json(kernel_config, 4))  # 4 spaces for indentation
    end
end

println("✅ Jupyter kernel startup script installed successfully.")
println("\nThe script will automatically load Census.jl in Jupyter notebooks.")
println("To test it, start a new Jupyter notebook with the Julia kernel and run:")
println("  println(\"Census.jl is \", @isdefined(Census) ? \"loaded\" : \"not loaded\")")

# Quick check that the Census.jl directory is actually where we expect
census_dir = expanduser("~/projects/Census.jl")
if !isdir(census_dir)
    println("\n⚠️ Warning: Census.jl directory not found at $census_dir")
    println("   You'll need to edit $dest_jupyter to set the correct path.")
else
    println("\n✅ Census.jl directory found at $census_dir")
end 