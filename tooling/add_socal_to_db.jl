# SPDX-License-Identifier: MIT
# Script to add Southern California counties to the database as a nation state
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment instead of the script directory
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census
using DataFrames, DataFramesMeta

# Define the nation state name
nation_state = "southland"

# Use the SOCAL_GEOIDS constant defined in the Census module - use full qualification
@info "Setting Southern California counties ($nation_state) in the database"
@info "Counties included: $(length(Census.SOCAL_GEOIDS))"

# Store the geoids in the database
Census.set_nation_state_geoids(nation_state, Census.SOCAL_GEOIDS)

# Verify the number of counties set
@info "Southern California counties have been set in the database as '$(nation_state)'"

# Print information about the dataset
counties_info = ""
us = Census.init_census_data()
socal_df = subset(us, :geoid => ByRow(id -> id ∈ Census.SOCAL_GEOIDS))
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