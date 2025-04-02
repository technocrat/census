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
using ArchGDAL
using RSetup
using ACS
using DataFramesMeta  # For ByRow and other DataFrame operations
using LibPQ  # For database connections
using GeometryBasics  # For polygon creation and geometric operations

# Import specific functions
import RCall: rcopy
import LibPQ: execute

# Include constants and types first
include("constants.jl")

# Include core functionality
include("core.jl")

# Include and use submodules
include("geoids/geoids.jl")
using .geoids

# Include other modules
include("geo.jl")
include("ga.jl")
include("get_breaks.jl")
include("margins.jl")
include("process.jl")
include("viz.jl")
include("map_poly.jl")
include("customcut.jl")

# Initialize R environment during precompilation
try
    RSetup.setup_r_environment(["classInt", "tidycensus", "tidyr", "dplyr"])
catch e
    @warn "Failed to initialize R environment during precompilation. Please run RSetup.setup_r_environment() manually."
end

# Export core types and functions
export PostalCode, CensusQuery
export valid_codes, is_valid_postal_code, get_state_name, get_postal_code
export get_db_connection, initialize
export get_crs, CRS_STRINGS, west_montana
export get_geo_pop, customcut, parse_geoms
export US_POSTALS, VALID_POSTAL_CODES

# Export data fetching and processing functions
export build_census_query, fetch_census_data, get_census_data
export add_margins, add_row_margins, add_col_margins
export get_breaks
export ga

# Export visualization functions
export cleveland_dot_plot, create_age_pyramid, create_birth_table
export map_poly, map_poly_with_projection, geo, viz, save_plot

# Re-export functions from RSetup and ACS
export setup_r_environment
export get_acs, get_acs1, get_acs3, get_acs5
export get_acs_moe, get_acs_moe1, get_acs_moe3, get_acs_moe5

# Re-export from DataFramesMeta for convenience
export @subset, subset, @select, select, @transform, transform
export ByRow, @by, by, @combine, combine
export rename!, vcat

# Re-export from RCall
export rcopy

# Re-export from geoids module
export get_western_geoids, get_eastern_geoids
export get_east_of_utah_geoids, get_east_of_cascade_geoids
export get_west_of_cascades, get_east_of_cascades
export get_southern_kansas_geoids, get_northern_kansas_geoids
export get_colorado_basin_geoids, get_ne_missouri_geoids
export get_southern_missouri_geoids, get_northern_missouri_geoids
export get_missouri_river_basin_geoids, get_slope_geoids

# Add nation state functions
export setup_nation_states_table, set_nation_state_geoids
export get_nation_state_geoids, clear_nation_state_geoids
export execute

# Re-export geoids constants
export western_geoids, eastern_geoids
export east_of_utah_geoids, east_of_cascade_geoids
export west_of_cascades, east_of_cascades
export southern_kansas_geoids, northern_kansas_geoids
export colorado_basin_geoids, ne_missouri_geoids
export southern_missouri_geoids, northern_missouri_geoids
export missouri_river_basin_geoids, east_of_sierras_geoids

# Export geographic constants
export WESTERN_BOUNDARY, EASTERN_BOUNDARY
export CONTINENTAL_DIVIDE, SLOPE_WEST, SLOPE_EAST
export UTAH_BORDER, CENTRAL_MERIDIAN

# Export Figure from CairoMakie
export Figure

end # module Census
