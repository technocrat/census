#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Use proper package resolution when running from within the package directory
using Pkg
Pkg.activate(".")  # Activate the current package environment

# Import Census module and GeoIDs
using Census
using GeoIDs
using GeoIDs.Store  # Import Store module for functions
using DataFrames
using LibPQ

# Get existing west_of_100th GeoIDs
west_of_100th = GeoIDs.get_geoid_set("west_of_100th")
println("Original west_of_100th GeoID set contains $(length(west_of_100th)) counties")

# Get counties with centroids between -110°W and -115°W longitude
west_longitude_110_to_115 = Census.get_centroid_longitude_range_geoids(-115.0, -110.0)
println("Found $(length(west_longitude_110_to_115)) counties with centroids between -110°W and -115°W longitude")

# Add these counties to west_of_100th and remove duplicates
updated_west_of_100th = unique(vcat(west_of_100th, west_longitude_110_to_115))
println("Updated west_of_100th GeoID set contains $(length(updated_west_of_100th)) counties")

# Update the GeoID set in the database - create a new version
new_version = GeoIDs.Store.create_geoid_set_version(
    "west_of_100th", 
    updated_west_of_100th, 
    "Updated to include counties with centroids between -110°W and -115°W longitude"
)

println("Successfully updated the west_of_100th GeoID set in the database (new version: $new_version)")

# Display some sample counties that were added
added_counties = setdiff(updated_west_of_100th, west_of_100th)
if length(added_counties) > 0
    println("\nSample counties added (up to 10):")
    conn = Census.get_db_connection()
    for geoid in added_counties[1:min(10, length(added_counties))]
        query = """
        SELECT name, stusps FROM census.counties WHERE geoid = '$geoid'
        """
        result = DataFrame(LibPQ.execute(conn, query))
        if nrow(result) > 0
            println("  $(result.name[1]), $(result.stusps[1]) ($geoid)")
        else
            println("  Unknown county ($geoid)")
        end
    end
    LibPQ.close(conn)
    
    if length(added_counties) > 10
        println("  ... and $(length(added_counties) - 10) more counties")
    end
end

println("\nDone updating west_of_100th GeoID set") 