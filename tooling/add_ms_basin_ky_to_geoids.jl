# SPDX-License-Identifier: MIT
# Script to add MS_BASIN_KY GEOID set to GeoIDs module
# SCRIPT

the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
include(the_path)

using GeoIDs, LibPQ, DataFrames

# Define Kentucky counties in the Mississippi River Basin 
ms_basin_ky_counties = ["Ballard", "Carlisle", "Fulton", "Hickman", "Graves", "McCracken"]
KY = subset(us, :stusps => ByRow(x -> x == "KY"))
ms_basin_ky = subset(KY, :county => ByRow(x -> x ∈ ms_basin_ky_counties)).geoid

# Convert to Vector{String} to match function signature
ms_basin_ky_string = String[string(x) for x in ms_basin_ky if !ismissing(x)]

# Set name and description
set_name = "ms_basin_ky"
description = "Kentucky counties in the Mississippi River Basin"

# Check if set exists
existing_sets = GeoIDs.list_geoid_sets().set_name
if !(set_name in existing_sets)
    @info "Creating '$set_name' geoid set..."
    GeoIDs.create_geoid_set(
        set_name,
        description,
        ms_basin_ky_string
    )
    @info "Created '$set_name' geoid set with $(length(ms_basin_ky_string)) counties"
else
    @info "'$set_name' geoid set already exists"
    
    # Get database connection
    db_conn = GeoIDs.DB.get_connection()
    
    # Delete existing set and recreate
    @info "Recreating '$set_name' geoid set..."
    
    # Delete existing set
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_set_members WHERE set_name = \$1", [set_name])
    LibPQ.execute(db_conn, "DELETE FROM census.geoid_sets WHERE set_name = \$1", [set_name])
    
    # Create new set
    LibPQ.execute(db_conn, 
        "INSERT INTO census.geoid_sets (set_name, description, created_at) VALUES (\$1, \$2, NOW())",
        [set_name, description]
    )
    
    # Add the geoids to the set
    for geoid in ms_basin_ky_string
        LibPQ.execute(db_conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    LibPQ.close(db_conn)
    @info "Recreated '$set_name' geoid set with $(length(ms_basin_ky_string)) counties"
end

# Get the geoids from the database to verify
ms_basin_ky_geoids = GeoIDs.get_geoid_set(set_name)
@info "Geoid set '$set_name' has $(length(ms_basin_ky_geoids)) counties"

# Get county information and print
counties_query = """
SELECT geoid, name, stusps FROM census.counties 
WHERE geoid IN ($(join(map(g -> "'$g'", ms_basin_ky_geoids), ",")))
ORDER BY stusps, name
"""

db_conn = GeoIDs.DB.get_connection()
result = LibPQ.execute(db_conn, counties_query)
counties_df = DataFrame(result)
LibPQ.close(db_conn)

println("Kentucky counties in the Mississippi River Basin:")
for row in eachrow(counties_df)
    println("  $(row.geoid): $(row.name), $(row.stusps)")
end

@info "Completed creation of Mississippi Basin Kentucky geoid set" 