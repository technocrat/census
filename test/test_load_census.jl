#!/usr/bin/env julia
# Simple test script to check if Census.jl loads correctly

println("Testing Census.jl loading...")

# Method 1: Using the new load_census.jl helper
try
    include(joinpath(@__DIR__, "load_census.jl"))
    println("✅ Census.jl loaded successfully with load_census.jl!")
    
    # Test calling a function from the package
    println("Testing init_census_data function...")
    us = Census.init_census_data()
    println("✅ Retrieved $(nrow(us)) counties")
    
    # Display the first few rows
    println("\nFirst 5 counties:")
    display(first(us, 5))
catch e
    println("❌ Error with Method 1 (load_census.jl):")
    println(e)
    
    # Try Method 2: Direct LOAD_PATH modification as fallback
    try
        println("\nTrying Method 2: Direct LOAD_PATH modification...")
        package_dir = @__DIR__
        if !(package_dir in LOAD_PATH)
            push!(LOAD_PATH, package_dir)
        end
        @time using Census
        println("✅ Census.jl loaded successfully with LOAD_PATH modification!")
        
        # Test calling a function from the package
        println("Testing init_census_data function...")
        us = Census.init_census_data()
        println("✅ Retrieved $(nrow(us)) counties")
    catch e2
        println("❌ Error with Method 2 (LOAD_PATH):")
        println(e2)
    end
end 