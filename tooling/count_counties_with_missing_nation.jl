#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script to count counties where nation is NULL, grouped by state
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, LibPQ, DataFrames, DataFramesMeta

println("Counting counties where nation is NULL, grouped by state...")

# Connect to the database
conn = LibPQ.Connection("dbname=tiger")
println("Connected to database.")

# Query to count counties where nation is NULL, grouped by state
query = """
SELECT stusps, COUNT(*) as county_count
FROM census.counties
WHERE nation IS NULL
GROUP BY stusps
ORDER BY stusps;
"""

result = LibPQ.execute(conn, query)
state_counts_df = DataFrame(result)

# Query to get total number of counties with NULL nation
total_query = """
SELECT COUNT(*) as total_count
FROM census.counties
WHERE nation IS NULL;
"""

total_result = LibPQ.execute(conn, total_query)
total_count = DataFrame(total_result)[1, :total_count]

# Query to get total number of counties
all_counties_query = """
SELECT COUNT(*) as all_counties
FROM census.counties;
"""

all_counties_result = LibPQ.execute(conn, all_counties_query)
all_counties = DataFrame(all_counties_result)[1, :all_counties]

# Print results
println("\nCounts of counties with NULL nation value by state:")
println("------------------------------------------------")
println("Total counties with NULL nation: $total_count out of $all_counties ($(round(total_count/all_counties*100, digits=2))%)")
println("")

# Format as a table with columns aligned
println("State | Count")
println("------|------")
for row in eachrow(state_counts_df)
    println("$(row.stusps)    | $(row.county_count)")
end

# Close connection
LibPQ.close(conn)
println("\nDone!") 