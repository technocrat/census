# SPDX-License-Identifier: MIT
# Script to add Southern California counties to the database as a nation state
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census
using DataFrames, DataFramesMeta

# Define the nation state name
nation_state = "southland"

# Define the Southern California GEOIDs directly
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

@info "Setting Southern California counties ($nation_state) in the database"
@info "Counties included: $(length(socal_geoids))"

# Store the geoids in the database using Census.set_nation_state_geoids
# The function expects Vector{String} which is what we have
Census.set_nation_state_geoids(nation_state, socal_geoids)

# Verify the number of counties set
@info "Southern California counties have been set in the database as '$(nation_state)'"

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