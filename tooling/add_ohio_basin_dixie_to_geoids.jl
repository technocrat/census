# SPDX-License-Identifier: MIT
# Script to add OHIO_BASIN_DIXIE GEOID set to GeoIDs module
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, DataFrames, DataFramesMeta, LibPQ

ohio_basin_pa_ny = ["Allegheny", "Armstrong", "Beaver", "Bedford", "Butler", "Cambria", "Clarion", "Clearfield", "Crawford", "Elk", "Erie", "Fayette", "Forest", "Greene", "Indiana", "Jefferson", "Lawrence", "McKean", "Mercer", "Potter", "Somerset", "Venango", "Warren", "Washington", "Westmoreland", "Allegany", "Cattaraugus", "Chautauqua"]

pa = filter(:stusps  => x -> x == "PA",us)
pa = subset(pa, :county => ByRow(x -> x ∈ ohio_basin_pa_ny))

ny = filter(:stusps  => x -> x == "NY",us)
ny = subset(ny, :county => ByRow(x -> x ∈ ohio_basin_pa_ny))

ny_pa = vcat(pa, ny).geoid

# Define the set name
set_name = "ohio_basin_pa_ny"
description = "Geoids in Ohio Basin PA and NY"

@info "Setting up Ohio Basin PA and NY counties ($set_name) in the GeoIDs database"
@info "Total counties: $(length(ny_pa))"

# Get a database connection
conn = LibPQ.Connection("dbname=tiger")
@info "Connected to database"

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
    for geoid in ny_pa
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Recreated '$set_name' geoid set with $(length(ny_pa)) counties"
else
    # Create a new set
    @info "Creating new geoid set '$set_name'..."
    
    # Create new set
    LibPQ.execute(conn, 
        "INSERT INTO census.geoid_sets (set_name, description, created_at) VALUES (\$1, \$2, NOW())",
        [set_name, description]
    )
    
    # Add the geoids to the set
    for geoid in ny_pa
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Created new geoid set '$set_name'"
end

# Break down the counties by state for verification
us = Census.init_census_data()
pa_ny_df = subset(us, :geoid => ByRow(id -> id ∈ ny_pa))
total_pop = sum(pa_ny_df.pop)
total_counties = length(pa_ny_df.geoid)

@info "Ohio Basin PA and NY counties summary:"
@info "  - Total counties: $total_counties"
@info "  - Total population: $total_pop"

# Group counties by state
state_groups = groupby(pa_ny_df, :stusps)
for state_group in state_groups
    state = first(state_group.stusps)
    county_count = nrow(state_group)
    state_pop = sum(state_group.pop)
    @info "  - $state: $county_count counties, population $state_pop"
end

# List the counties for verification
println("\nCounties included in Ohio Basin PA and NY:")
for row in eachrow(pa_ny_df)
    println("  - $(row.county), $(row.stusps): $(row.geoid) (Pop: $(row.pop))")
end

# Verify the geoid set was stored correctly
verify_query = "SELECT geoid FROM census.geoid_set_members WHERE set_name = \$1"
result = LibPQ.execute(conn, verify_query, [set_name])
result_df = DataFrame(result)
stored_geoids = result_df.geoid

@info "Retrieved $(length(stored_geoids)) GEOIDs from the '$set_name' set in the database"
if Set(stored_geoids) == Set(ny_pa)
    @info "Verification successful: Stored GEOIDs match original set"
else
    @warn "Verification failed: Stored GEOIDs do not match original set"
end

# Close the database connection
LibPQ.close(conn)
@info "Database connection closed" 