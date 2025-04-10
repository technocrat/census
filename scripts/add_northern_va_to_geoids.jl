# SPDX-License-Identifier: MIT
# Script to add NORTHERN_VA GEOID set to GeoIDs module
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, DataFrames, DataFramesMeta, LibPQ

# Define the set name
set_name = "northern_va"
description = "Counties in Northern Virginia, including areas surrounding Washington D.C."

@info "Setting up Northern Virginia counties ($set_name) in the GeoIDs database"
@info "Total counties: $(length(Census.NORTHERN_VA_GEOIDS))"

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
    for geoid in Census.NORTHERN_VA_GEOIDS
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Recreated '$set_name' geoid set with $(length(Census.NORTHERN_VA_GEOIDS)) counties"
else
    # Create a new set
    @info "Creating new geoid set '$set_name'..."
    
    # Create new set
    LibPQ.execute(conn, 
        "INSERT INTO census.geoid_sets (set_name, description, created_at) VALUES (\$1, \$2, NOW())",
        [set_name, description]
    )
    
    # Add the geoids to the set
    for geoid in Census.NORTHERN_VA_GEOIDS
        LibPQ.execute(conn,
            "INSERT INTO census.geoid_set_members (set_name, geoid) VALUES (\$1, \$2)",
            [set_name, geoid]
        )
    end
    
    @info "Created new geoid set '$set_name'"
end

# Break down the counties by state for verification
us = Census.init_census_data()
va_df = subset(us, :geoid => ByRow(id -> id ∈ Census.NORTHERN_VA_GEOIDS))
total_pop = sum(va_df.pop)
total_counties = length(va_df.geoid)

@info "Northern Virginia counties summary:"
@info "  - Total counties: $total_counties"
@info "  - Total population: $total_pop"

# List the counties for verification
println("\nCounties included in Northern Virginia region:")
for row in eachrow(va_df)
    println("  - $(row.county), $(row.stusps): $(row.geoid) (Pop: $(row.pop))")
end

# Verify the geoid set was stored correctly
verify_query = "SELECT geoid FROM census.geoid_set_members WHERE set_name = \$1"
result = LibPQ.execute(conn, verify_query, [set_name])
result_df = DataFrame(result)
stored_geoids = result_df.geoid

@info "Retrieved $(length(stored_geoids)) GEOIDs from the '$set_name' set in the database"
if Set(stored_geoids) == Set(Census.NORTHERN_VA_GEOIDS)
    @info "Verification successful: Stored GEOIDs match original set"
else
    @warn "Verification failed: Stored GEOIDs do not match original set"
end

# Close the database connection
LibPQ.close(conn)
@info "Database connection closed" 