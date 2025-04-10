#!/usr/bin/env julia
# SPDX-License-Identifier: MIT

# Import the Census module
println("Importing Census...")
using Census

# Check if subset is defined and available
println("Checking if subset is available...")
if isdefined(Main, :subset)
    println("✓ subset is defined in Main namespace")
else
    println("✗ subset is NOT defined in Main namespace")
    println("It should be available from the Census module")
end

# Test with init_census_data and subset
println("\nTesting with init_census_data and subset...")
try
    # Initialize census data
    us = init_census_data()
    println("✓ init_census_data() called successfully")
    
    # Use subset function
    ct = subset(us, :stusps => ByRow(==("CT")))
    println("✓ subset() called successfully")
    println("Connecticut counties: $(nrow(ct))")
catch e
    println("✗ Error: $e")
end

println("\nTest completed!") 