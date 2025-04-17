#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT: update_michigan_peninsula.jl

# Load required libraries
using LibPQ, DataFrames

# Define the Michigan Upper Peninsula counties
michigan_peninsula = [
    "Alger", "Baraga", "Chippewa", "Delta", "Dickinson", 
    "Gogebic", "Houghton", "Iron", "Keweenaw", "Luce", 
    "Mackinac", "Marquette", "Menominee", "Ontonagon", "Schoolcraft"
]

# Get the geoids for these counties
db_conn = LibPQ.Connection("dbname=tiger")

counties_query = """
    SELECT geoid FROM census.counties 
    WHERE stusps = 'MI' AND name IN ($(join(map(county -> "'$county'", michigan_peninsula), ",")))
"""
result = LibPQ.execute(db_conn, counties_query)
counties_df = DataFrame(result)
LibPQ.close(db_conn)

# Convert geoids to Vector{String}
michigan_peninsula_geoids = String[string(geoid) for geoid in counties_df.geoid]

# Print the geoids
println("Michigan Upper Peninsula geoids: ", join(sort(michigan_peninsula_geoids), ", "))

# Format geoids for copying into source code
formatted_geoids = join(map(geoid -> "    \"$geoid\",", sort(michigan_peninsula_geoids)), "\n")

# Display instructions for updating src/core/great_lakes.jl
println("\nCopy the following GEOIDs into src/core/great_lakes.jl to update MICHIGAN_PENINSULA_GEOID_LIST:")
println("\nconst MICHIGAN_PENINSULA_GEOID_LIST = [\n$formatted_geoids\n]")
