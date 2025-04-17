#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Example script showing how to use the Census package

# Method 1: Using the load_census.jl helper (recommended)
include(joinpath(@__DIR__, "load_census.jl"))

# Method 2: Manual approach (alternative)
# package_dir = @__DIR__
# if !(package_dir in LOAD_PATH)
#     push!(LOAD_PATH, package_dir)
# end
# using Census

# Ensure DataFrames is imported (often needed with Census)
using DataFrames, DataFramesMeta

# Check if Census loaded correctly
if @isdefined(Census)
    println("Census package loaded successfully!")
    
    # Initialize census data
    println("Loading census data...")
    @time us = Census.init_census_data()
    println("Loaded $(nrow(us)) counties")
    
    # Simple example: Get counties in California
    ca_counties = @subset(us, :stusps .== "CA")
    println("California has $(nrow(ca_counties)) counties")
    
    # Display the first few counties
    println("\nFirst 5 California counties:")
    display(first(ca_counties, 5))
else
    println("Failed to load Census package!")
end 