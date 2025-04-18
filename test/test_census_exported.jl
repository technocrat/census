#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

println("Importing packages...")
println("Testing init_census_data...")

if isdefined(Census, :init_census_data)
    println("✓ Census.init_census_data is defined")
else
    println("✗ Census.init_census_data is NOT defined")
end

# Test if init_census_data is accessible without qualification
try
    # Try to call the function without module qualification
    println("Calling init_census_data() directly...")
    us = init_census_data()
    println("✓ init_census_data() called successfully - loaded $(nrow(us)) counties")
catch e
    println("✗ Failed to call init_census_data(): $(e)")
end

println("\nTest completed!") 