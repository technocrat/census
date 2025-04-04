# SPDX-License-Identifier: MIT

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

using DataFrames
using DataFramesMeta
using LibPQ
using RCall
using CairoMakie
using GeoMakie
using GeometryBasics
using ColorSchemes
using ArchGDAL
using HTTP
using JSON3
using GeoInterface
using LibGEOS
using WellKnownGeometry
using RSetup
using ACS

# Re-export specific types and functions from CairoMakie and GeoMakie
import CairoMakie: Figure, Axis, Label, Colorbar
import GeoMakie: GeoAxis

# Import specific functions
import RCall: rcopy
import LibPQ: execute

# Database configuration
const DB_HOST = get(ENV, "CENSUS_DB_HOST", "localhost")
const DB_PORT = parse(Int, get(ENV, "CENSUS_DB_PORT", "5432"))
const DB_NAME = get(ENV, "CENSUS_DB_NAME", "geocoder")

# Southern California counties (San Luis Obispo, Kern, San Bernardino and all south)
const SOCAL_GEOIDS::Vector{String} = [
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

"""
    get_db_connection() -> LibPQ.Connection

Creates a connection to the PostgreSQL database using default parameters.

# Returns
- A `LibPQ.Connection` object representing an active database connection

# Database Parameters
- Host: $DB_HOST (default: "localhost")
- Port: $DB_PORT (default: 5432)
- Database: $DB_NAME (default: "geocoder")

# Example
```julia
conn = get_db_connection()
try
    # Use connection
finally
    close(conn)
end
```

# Notes
- Connection should be closed after use
- Uses environment variables if set, otherwise defaults
- Environment variables: CENSUS_DB_HOST, CENSUS_DB_PORT, CENSUS_DB_NAME
"""
function get_db_connection()
    conn = LibPQ.Connection("host=$DB_HOST port=$DB_PORT dbname=$DB_NAME")
    return conn
end

# Include files in dependency order
include("constants.jl")
include("core/core.jl")
include("core/acs.jl")
include("core/RSetup.jl")
include("core/geoids.jl")  # get_exclude_from_va_geoids is defined here
include("core/crs.jl")  # Add CRS definitions
include("core/great_lakes.jl")  # Add Great Lakes region constants
include("analysis/get_breaks.jl")  # Move get_breaks.jl earlier
include("utils/add_labels.jl")
include("utils/add_row_totals.jl")
include("utils/customcut.jl")
include("utils/dms_to_decimal.jl")
include("utils/expand_state_codes.jl")
include("utils/fill_state.jl")
include("utils/make_postal_codes.jl")
include("utils/q.jl")
include("geo/map_poly.jl")  # Load map_poly first
include("geo/geo.jl")
include("geo/inspect_shapefile_structure.jl")
include("analysis/analysis.jl")
include("analysis/collect_state_age_dataframes.jl")
include("analysis/ga.jl")
include("analysis/get_childbearing_population.jl")
include("analysis/get_dem_vote.jl")
include("analysis/get_gop_vote.jl")
include("analysis/get_health_insurance_coverage.jl")
include("analysis/get_nation_state.jl")
include("analysis/get_nation_title.jl")
include("analysis/get_state_pop.jl")
include("analysis/get_us_ages.jl")
include("analysis/make_growth_table.jl")
include("analysis/make_nation_state_gdp_df.jl")
include("analysis/make_nation_state_pop_df.jl")
include("analysis/margins.jl")
include("analysis/process.jl")
include("analysis/query_nation_ages.jl")
include("analysis/query_state_ages.jl")
include("viz/viz.jl")
include("viz/make_legend.jl")
include("viz/create_state_to_nation_map.jl")
include("viz/create_state_abbrev_map.jl")
include("viz/create_multiple_age_pyramids.jl")

# Add initialization function
"""
    init_census_data() -> DataFrame

Initialize common Census data used across scripts. This:
1. Gets population data for all US states
2. Renames columns to standard format
3. Sets up R environment
4. Calculates population bins
5. Parses geometries

Returns a DataFrame with columns [:geoid, :stusps, :county, :geom, :pop, :pop_bins, :parsed_geoms]
"""
function init_census_data()
    us = get_geo_pop(postals)
    rename!(us, [:geoid, :stusps, :county, :geom, :pop])
    setup_r_environment()
    breaks = rcopy(get_breaks(us.pop))  # Pass population vector directly
    us.pop_bins = customcut(us.pop, breaks[:kmeans][:brks])
    us.parsed_geoms = parse_geoms(us)
    return us
end

# Initialize R environment during precompilation
try
    RSetup.setup_r_environment(["classInt"])
catch e
    @warn "Failed to initialize R environment during precompilation. Please run RSetup.setup_r_environment() manually."
end

# Export the GreatLakes module
export GreatLakes

# Initialize all geoid constants after geoids.jl is loaded
const EXCLUDE_FROM_VA = get_exclude_from_va_geoids()
const WESTERN_GEOIDS = get_western_geoids()
const EASTERN_GEOIDS = get_eastern_geoids()
const EAST_OF_UTAH_GEOIDS = get_east_of_utah_geoids()
const EAST_OF_CASCADE_GEOIDS = get_east_of_cascade_geoids()
const WEST_OF_CASCADES_GEOIDS = get_west_of_cascades()
const EAST_OF_CASCADES_GEOIDS = get_east_of_cascades()
const SOUTHERN_KANSAS_GEOIDS = get_southern_kansas_geoids()
const NORTHERN_KANSAS_GEOIDS = get_northern_kansas_geoids()
const COLORADO_BASIN_GEOIDS = get_colorado_basin_geoids()
const NE_MISSOURI_GEOIDS = get_ne_missouri_geoids()
const SOUTHERN_MISSOURI_GEOIDS = get_southern_missouri_geoids()
const NORTHERN_MISSOURI_GEOIDS = get_northern_missouri_geoids()
const MISSOURI_RIVER_BASIN_GEOIDS = get_missouri_river_basin_geoids()
const SLOPE_GEOIDS = get_slope_geoids()
const FLORIDA_GEOIDS = get_florida_south_geoids()

const EAST_OF_SIERRAS_GEOIDS = get_east_of_sierras_geoids()

# Initialize Great Lakes constants
const MICHIGAN_PENINSULA_GEOID_LIST = GreatLakes.get_michigan_peninsula_geoids()
const METRO_TO_GREAT_LAKES_GEOID_LIST = GreatLakes.get_metro_to_great_lakes_geoids()
const GREAT_LAKES_PA_GEOID_LIST = GreatLakes.get_great_lakes_pa_geoids()
const GREAT_LAKES_IN_GEOID_LIST = GreatLakes.get_great_lakes_in_geoids()
const GREAT_LAKES_OH_GEOID_LIST = GreatLakes.get_great_lakes_oh_geoids()
const OHIO_BASIN_IL_GEOID_LIST = GreatLakes.get_ohio_basin_il_geoids()

# Export all geoid constants
export WESTERN_GEOIDS,
       EASTERN_GEOIDS,
       EAST_OF_UTAH_GEOIDS,
       EAST_OF_CASCADE_GEOIDS,
       WEST_OF_CASCADES_GEOIDS,
       EAST_OF_CASCADES_GEOIDS,
       SOUTHERN_KANSAS_GEOIDS,
       NORTHERN_KANSAS_GEOIDS,
       COLORADO_BASIN_GEOIDS,
       NE_MISSOURI_GEOIDS,
       SOUTHERN_MISSOURI_GEOIDS,
       NORTHERN_MISSOURI_GEOIDS,
       MISSOURI_RIVER_BASIN_GEOIDS,
       SLOPE_GEOIDS,
       FLORIDA_GEOIDS,
       SOCAL_GEOIDS,
       EAST_OF_SIERRAS_GEOIDS,
       MICHIGAN_PENINSULA_GEOID_LIST,
       METRO_TO_GREAT_LAKES_GEOID_LIST,
       GREAT_LAKES_PA_GEOID_LIST,
       GREAT_LAKES_IN_GEOID_LIST,
       GREAT_LAKES_OH_GEOID_LIST,
       OHIO_BASIN_IL_GEOID_LIST,
       EXCLUDE_FROM_VA

# Export everything from the module
export PostalCode, CensusQuery

# Export all utility functions
export valid_codes, is_valid_postal_code, get_state_name, get_postal_code,
       initialize, get_crs, west_montana,
       get_geo_pop, customcut, parse_geoms,
       US_POSTALS, VALID_POSTAL_CODES,
       add_labels, add_row_totals, dms_to_decimal,
       expand_state_codes, fill_state, make_postal_codes, q

# Export all core functions
export build_census_query, fetch_census_data, get_census_data,
       add_margins, add_row_margins, add_col_margins,
       get_breaks, ga

# Export all analysis functions
export collect_state_age_dataframes, get_childbearing_population,
       get_dem_vote, get_gop_vote, get_health_insurance_coverage,
       get_nation_state, get_nation_title, get_state_pop,
       get_us_ages, make_growth_table,
       make_nation_state_gdp_df, make_nation_state_pop_df,
       query_nation_ages, query_state_ages

# Export visualization functions
export cleveland_dot_plot, create_age_pyramid, create_birth_table
export map_poly, geo, viz

# Re-export functions from RSetup and ACS
export setup_r_environment,
       get_acs, get_acs1, get_acs3, get_acs5,
       get_acs_moe, get_acs_moe1, get_acs_moe3, get_acs_moe5

# Re-export from DataFramesMeta for convenience
export @subset, subset, @select, select, @transform, transform,
       ByRow, @by, by, @combine, combine,
       rename!, vcat

# Re-export entire packages
export DataFrames, DataFramesMeta, ArchGDAL, CairoMakie, GeoMakie, GeometryBasics

# Re-export from RCall
export rcopy

# Export initialization function
export init_census_data

# Export all geoid-related functions and constants
export get_western_geoids, get_eastern_geoids,
       get_colorado_basin_geoids, get_west_montana_geoids,
       get_florida_south_geoids,
       WESTERN_BOUNDARY, EASTERN_BOUNDARY,
       CONTINENTAL_DIVIDE, SLOPE_WEST, SLOPE_EAST, UTAH_BORDER,
       CENTRAL_MERIDIAN, CRS_STRINGS, get_crs, set_nation_state_geoids

# Export database configuration and connection
export DB_HOST, DB_PORT, DB_NAME, get_db_connection

# Re-export visualization types from CairoMakie and GeoMakie
export Figure, Axis, Label, Colorbar, GeoAxis

# Re-export ColorSchemes for convenience
export ColorSchemes

# Export all public functions
export get_db_connection,
       get_nation_state,
       initialize,
       get_us_ages,
       get_dem_vote,
       get_gop_vote,
       get_childbearing_population,
       get_state_pop,
       make_nation_state_pop_df,
       make_nation_state_gdp_df,
       get_breaks,
       map_poly,
       geo_plot,
       save_plot,
       format_number,
       add_labels!,
       add_row_totals!,
       customcut,
       dms_to_decimal,
       expand_state_codes,
       fill_state,
       make_postal_codes,
       q,
       inspect_shapefile_structure

end # module Census
