#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script to find counties where nation is NULL
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, LibPQ, DataFrames, DataFramesMeta

println("Finding counties where nation is NULL...")

# Connect to the database
conn = LibPQ.Connection("dbname=tiger")
println("Connected to database.")

# Query counties where nation is NULL
query = """
SELECT geoid, stusps, name as county
FROM census.counties
WHERE nation IS NULL
ORDER BY stusps, county;
"""

result = LibPQ.execute(conn, query)
counties_df = DataFrame(result)

# Print results
println("\nCounties with NULL nation value:")
println("--------------------------------")
println("Total count: $(nrow(counties_df))")

if nrow(counties_df) > 0
    # Group by state for better readability
    state_groups = groupby(counties_df, :stusps)
    
    for state_group in state_groups
        state = first(state_group.stusps)
        count = nrow(state_group)
        println("\n$state ($count counties):")
        
        for row in eachrow(state_group)
            println("  $(row.county), $(row.stusps) ($(row.geoid))")
        end
    end
else
    println("No counties found with NULL nation value.")
end

# Close connection
LibPQ.close(conn)
println("\nDone!") 