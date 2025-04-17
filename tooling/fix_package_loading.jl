#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# This script helps fix package loading issues with Census.jl

println("Running Census.jl Package Fix...")

# Get the current directory (assuming it's the package root)
package_dir = @__DIR__

println("Package directory: $package_dir")

# Add package directory to LOAD_PATH to allow 'using Census'
println("\nAdding package directory to LOAD_PATH...")
if !(package_dir in LOAD_PATH)
    push!(LOAD_PATH, package_dir)
    println("✅ Added to LOAD_PATH")
else
    println("Already in LOAD_PATH")
end

# Add specific /src directory to LOAD_PATH
src_dir = joinpath(package_dir, "src")
if isdir(src_dir) && !(src_dir in LOAD_PATH)
    push!(LOAD_PATH, src_dir)
    println("✅ Added src/ directory to LOAD_PATH")
end

# Try to load the Census module
println("\nTesting Census module loading...")
try
    @time using Census
    println("✅ Successfully loaded Census module!")
    
    # Test a simple function
    println("\nTesting basic functionality...")
    if isdefined(Census, :init_census_data)
        println("✅ init_census_data function is defined")
    else
        println("❌ init_census_data function is not defined")
    end
catch e
    println("❌ Error loading Census module:")
    println(e)
end

println("\n=== INSTRUCTIONS ===")
println("To use Census.jl in your scripts, add the following at the top:")
println("""
# Add package to LOAD_PATH (adjust path if needed)
push!(LOAD_PATH, "$(package_dir)")
using Census
""")
println("\nYou can also run this script at the beginning of your session with:")
println("include(\"$(joinpath(package_dir, "fix_package_loading.jl"))\")") 