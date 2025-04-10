# SPDX-License-Identifier: MIT
# Script to add Southern California counties to the GeoIDs module database
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using GeoIDs, Census, DataFrames, DataFramesMeta

# Define the set name and nation state name
set_name = "socal"
nation_state = "southland"

# Use the SOCAL_GEOIDS constant defined in the Census module
# Define the Southern California GEOIDs
socal_geoids = [
    "06025",  # Imperial County
    "06029",  # Kern County
    "06037",  # Los Angeles County
    "06059",  # Orange County
    "06065",  # Riverside County
    "06071",  # San Bernardino County
    "06073",  # San Diego County
    "06079",  # San Luis Obispo County
    "06083",  # Santa Barbara County
    "06111"   # Ventura County
]

@info "Setting up Southern California counties ($set_name) in the GeoIDs database"
@info "Counties included: $(length(socal_geoids))"

# Store the geoids in the GeoIDs database
if GeoIDs.has_geoid_set(set_name)
    # Create a new version if the set already exists
    GeoIDs.create_geoid_set_version(set_name, socal_geoids)
    @info "Created new version of existing '$set_name' geoid set"
else
    # Create new set if it doesn't exist
    GeoIDs.create_geoid_set(set_name, socal_geoids)
    @info "Created new geoid set '$set_name'"
end

# Store as a nation state in the database
GeoIDs.set_nation_state_geoids(nation_state, socal_geoids)
@info "Saved $(length(socal_geoids)) counties to database as nation state '$(nation_state)'"

# Print information about the dataset
us = Census.init_census_data()
socal_df = subset(us, :geoid => ByRow(id -> id ∈ socal_geoids))
total_pop = sum(socal_df.pop)
total_counties = length(socal_df.geoid)

@info "Southern California nation state summary:"
@info "  - Total counties: $total_counties"
@info "  - Total population: $total_pop"

# List the counties for verification
println("\nCounties included in Southern California:")
for row in eachrow(socal_df)
    println("  - $(row.name), $(row.stusps): $(row.geoid) (Pop: $(row.pop))")
end

# Verify the geoid set was stored correctly
if GeoIDs.has_geoid_set(set_name)
    stored_geoids = GeoIDs.get_geoid_set(set_name)
    @info "Retrieved $(length(stored_geoids)) GEOIDs from the '$set_name' set in the database"
    if Set(stored_geoids) == Set(socal_geoids)
        @info "Verification successful: Stored GEOIDs match original set"
    else
        @warn "Verification failed: Stored GEOIDs do not match original set"
    end
else
    @error "Failed to store geoid set '$set_name' in the database"
end 