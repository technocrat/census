#!/usr/bin/env julia

"""
Census.jl Startup Script

This script sets up the proper environment and loads the Census.jl package.

Usage:
    julia startup_census.jl
"""

# Force immediate update of ENV if needed
if haskey(ENV, "JULIA_LOAD_PATH")
    ENV["JULIA_LOAD_PATH"] = ENV["JULIA_LOAD_PATH"]
end

# Explicitly load Census in Main
eval_in_Main = Base.eval(Main, quote
    # Load the package with error handling
    try
        using Census
        println("✅ Census.jl loaded successfully!")
        true
    catch e
        println("❌ Error loading Census.jl:")
        println(e)
        false
    end
end)

if !eval_in_Main
    println("Try rebuilding the package with: ")
    println("julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.build(); Pkg.precompile()'")
end 