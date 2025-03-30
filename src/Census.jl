"""
    Census

A Julia package for analyzing alternatives for nation states to replace the existing United States.
This package provides tools for analyzing various aspects of potential nation states, including:

- Population characteristics
- Economic indicators
- Political structures
- Historical context
- Geographic features

The package integrates with R's statistical packages and provides GIS functionality through various Julia packages.

# Main Features
- Data processing and analysis tools
- Visualization capabilities using CairoMakie and GeoMakie
- Integration with R's statistical packages
- Geographic information system (GIS) functionality
- Population analysis tools

# Example
```julia
using Census

# Get population data for a state
state_pop = get_state_pop("CA")

# Create visualizations
map_poly(population_data)
```
"""
module Census

using RCall
using DataFrames
using HTTP
using JSON3
using GeoInterface
using CairoMakie
using GeoMakie
using LibGEOS
using WellKnownGeometry

# Include constants and types first
include("constants.jl")

# Include core functionality
include("core.jl")

# Include submodules
include("RSetup.jl")
using .RSetup

# Include processing and analysis functions
include("acs.jl")
include("ga.jl")
include("get_breaks.jl")
include("margins.jl")
include("process.jl")
include("viz.jl")

# Initialize R environment during precompilation
try
    setup_r_environment()
catch e
    @warn "Failed to initialize R environment during precompilation. Please run setup_r_environment() manually."
end

# Export core types and functions
export PostalCode, CensusQuery
export valid_codes, is_valid_postal_code, get_state_name, get_postal_code
export get_db_connection, initialize

# Export R setup functions
export setup_r_environment, SETUP_COMPLETE, RSetup

# Export data fetching and processing functions
export build_census_query, fetch_census_data, get_census_data
export add_margins, add_row_margins, add_col_margins
export get_breaks
export ga

# Export visualization functions
export cleveland_dot_plot, create_age_pyramid, create_birth_table
export map_poly, geo, viz

end # module Census
