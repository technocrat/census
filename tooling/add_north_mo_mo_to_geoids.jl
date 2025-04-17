#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script to add NORTH_MO_MO GEOID set to GeoIDs module
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using GeoIDs, LibPQ, DataFrames

# Define the specific Northern Missouri counties
north_mo_mo_counties = [
    "Atchison",
    "Nodaway",
    "Holt",
    "Andrew",
    "Buchanan",
    "Platte",
    "Clinton",
    "DeKalb",
    "Gentry",
    "Worth",
    "Harrison",
    "Daviess",
    "Caldwell",
    "Ray",
    "Mercer",
    "Grundy",
    "Livingston",
    "Carroll",
    "Linn",
    "Sullivan",
    "Putnam",
    "Schuyler",
    "Adair",
    "Macon",
    "Chariton",
    "Randolph",
    "Shelby",
    "Knox",
    "Clark",
    "Scotland",
    "Lewis",
    "Marion",
    "Ralls",
    "Monroe",
    "Pike",
    "Clay"
]

# Get a database connection
conn = LibPQ.Connection("dbname=tiger")
@info "Connected to database"

# Look up GEOIDs for the specified counties
county_lookup_query = """
SELECT geoid, name, stusps FROM census.counties 
WHERE stusps = 'MO' AND name IN ($(join(map(c -> "'$c'", north_mo_mo_counties), ",")))
ORDER BY name;
"""

result = LibPQ.execute(conn, county_lookup_query)
counties_df = DataFrame(result)

# Extract geoids from the result
north_mo_mo = counties_df.geoid

# Ensure no duplicates
north_mo_mo = unique(north_mo_mo)

# Define the set name
set_name = "north_mo_mo"
description = "Northern Missouri counties"

@info "Setting up Northern Missouri counties ($set_name) in the GeoIDs database"
@info "Total counties: $(length(north_mo_mo))"

# Check if the set exists
check_query = "SELECT COUNT(*) FROM census.geoid_sets WHERE set_name = \$1"
result = LibPQ.execute(conn, check_query, [set_name])
set_exists = result[1, 1] > 0

if set_exists
    # Delete existing set and recreate
    @info "Recreating '$set_name' geoid set..."
    
    # Delete existing set
    LibPQ.execute(conn, "DELETE FROM census.geoid_set_members WHERE set_name = \$1", [set_name])
    LibPQ.execute(conn, "DELETE FROM census.geoid_sets WHERE set_name = \$1", [set_name])
    
    # Create new set
    LibPQ.execute(conn, 
        "INSERT INTO census.geoid_sets (set_name, description, created_at) VALUES (\$1, \$2, NOW())",
        [set_name, description]
    )
    
    # Add the geoids to the set
    for geoid in north_mo_mo
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Recreated '$set_name' geoid set with $(length(north_mo_mo)) counties"
else
    # Create a new set
    @info "Creating new geoid set '$set_name'..."
    
    # Create new set
    LibPQ.execute(conn, 
        "INSERT INTO census.geoid_sets (set_name, description, created_at) VALUES (\$1, \$2, NOW())",
        [set_name, description]
    )
    
    # Add the geoids to the set
    for geoid in north_mo_mo
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Created new geoid set '$set_name'"
end

# Display the included counties
println("\nCounties included in Northern Missouri set:")
for row in eachrow(counties_df)
    println("  $(row.name), MO ($(row.geoid))")
end

LibPQ.close(conn)
@info "Completed creation of Northern Missouri geoid set" 