#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script to check available geoid sets
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using GeoIDs
using DataFrames

println("Checking available geoid sets in the database...")

# List all geoid sets
sets_df = GeoIDs.list_geoid_sets()

if isempty(sets_df)
    println("No geoid sets found in the database.")
else
    println("\nAvailable geoid sets:")
    println("--------------------")
    println("Total sets: $(nrow(sets_df))")
    println("\nSet Name | Description | Geoid Count")
    println("---------|-------------|------------")
    
    for row in eachrow(sets_df)
        # Truncate description if too long
        desc = if !ismissing(row.description) && length(row.description) > 40
            row.description[1:37] * "..."
        else
            row.description
        end
        
        println("$(row.set_name) | $(desc) | $(row.geoid_count)")
    end
end

# Try to find a specific set the script is looking for
known_sets_to_check = [
    "north_mo_mo",
    "mo_basin_mo",
    "ms_basin_mo", 
    "mo_river_basin",
    "missouri_river_basin",
    "west_of_100th"
]

println("\nChecking specific sets:")
for set_name in known_sets_to_check
    try
        geoids = GeoIDs.get_geoid_set(set_name)
        println("✓ Set '$set_name' exists with $(length(geoids)) geoids")
    catch e
        println("✗ Set '$set_name' not found or error: $e")
    end
end

println("\nDone!") 