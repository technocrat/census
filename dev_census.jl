#!/usr/bin/env julia

"""
Census.jl Development Setup Script

This script properly sets up the Census package environment
so it can be used directly with `using Census`.

Run this script once to set up your environment:
    julia dev_census.jl
"""

using Pkg

# Get the absolute path to the current directory (package root)
package_dir = dirname(Base.source_path())
package_dir = isempty(package_dir) ? pwd() : package_dir

println("📦 Setting up environment for Census.jl at: $package_dir")

# Activate the project
Pkg.activate(package_dir)

# Build/rebuild the package
println("🔄 Building Census.jl...")
Pkg.build()

# Precompile the package
println("🔄 Precompiling Census.jl...")
try
    Pkg.precompile()
    println("✅ Precompilation complete!")
    
    # Test loading the package
    println("🔄 Testing package loading...")
    @eval using Census
    println("✅ Census.jl loaded successfully!")
catch e
    println("❌ Error during precompilation or loading:")
    println(e)
    
    # Show more detailed build info if there's an error
    println("\n📋 Checking package status...")
    Pkg.status()
    
    println("\n📋 Checking package dependencies...")
    Pkg.dependencies()
end

println("\n📋 Usage instructions:")
println("1. Start Julia with: julia --project=$(package_dir)")
println("2. Then you can directly use: using Census")
println("3. Or use the startup script: julia $(joinpath(package_dir, "startup_census.jl"))") 