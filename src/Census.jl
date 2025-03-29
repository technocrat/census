# SPDX-License-Identifier: MIT
module Census

# Import RCall first since we need it for R setup
using RCall

# Include R setup code first since we need it for precompilation
include(joinpath(dirname(@__DIR__), "scripts", "r_setup.jl"))

# Initialize R environment during module precompilation
try
    R"$(R_LIBPATH)"
    R"$(R_CHECK_CODE)"
    SETUP_COMPLETE[] = true
catch e
    @warn "R environment check failed during precompilation. You may need to run install_r_packages()" exception=e
end

# All dependencies
using ArchGDAL
using BSON
using CairoMakie
using Colors
using CSV
using DataFrames
using Dates
using Decimals
using FixedPointNumbers
using Format
using GeoInterface
using GeoJSON
using GeoMakie
using GeometryBasics
using Graphs
using GraphPlot
using HTTP
using JSON3
using LibPQ
using Measures
using PlotlyJS
using Plots
using Polynomials
using PrettyTables
using RDatasets
using StatsBase
using StatsPlots
using URIs
using Franklin

# Include core types and structures
include(joinpath(@__DIR__, "core.jl"))

# Include syntax highlighting
include(joinpath(dirname(@__DIR__), "scripts", "highlighters.jl"))

# Include make_postal_codes before get_geo_pop since it's needed there
include(joinpath(@__DIR__, "make_postal_codes.jl"))

# Include geographic functions
include(joinpath(@__DIR__, "geo.jl"))

# Include the geoids submodule (which includes its implementation)
include("geoids/geoids.jl")

# Import and re-export geoids submodule functions and constants
import .geoids: get_crs, CRS_STRINGS
export get_crs, CRS_STRINGS

# Include analysis functions
include(joinpath(@__DIR__, "analysis.jl"))

# Include visualization functions
include(joinpath(@__DIR__, "viz.jl"))

# Include data processing functions
include(joinpath(@__DIR__, "process.jl"))

# Include all other function files
include(joinpath(@__DIR__, "acs.jl"))
include(joinpath(@__DIR__, "add_labels.jl"))
include(joinpath(@__DIR__, "add_row_totals.jl"))
include(joinpath(@__DIR__, "collect_state_age_dataframes.jl"))
include(joinpath(@__DIR__, "create_multiple_age_pyramids.jl"))
include(joinpath(@__DIR__, "create_state_abbrev_map.jl"))
include(joinpath(@__DIR__, "create_state_to_nation_map.jl"))
include(joinpath(@__DIR__, "dms_to_decimal.jl"))
include(joinpath(@__DIR__, "expand_state_codes.jl"))
include(joinpath(@__DIR__, "fill_state.jl"))
include(joinpath(@__DIR__, "ga.jl"))
include(joinpath(@__DIR__, "get_breaks.jl"))
include(joinpath(@__DIR__, "get_childbearing_population.jl"))
include(joinpath(@__DIR__, "get_dem_vote.jl"))
include(joinpath(@__DIR__, "get_gop_vote.jl"))
include(joinpath(@__DIR__, "get_nation_state.jl"))
include(joinpath(@__DIR__, "get_nation_title.jl"))
include(joinpath(@__DIR__, "get_state_pop.jl"))
include(joinpath(@__DIR__, "get_us_ages.jl"))
include(joinpath(@__DIR__, "inspect_shapefile_structure.jl"))
include(joinpath(@__DIR__, "make_growth_table.jl"))
include(joinpath(@__DIR__, "make_legend.jl"))
include(joinpath(@__DIR__, "make_nation_state_gdp_df.jl"))
include(joinpath(@__DIR__, "make_nation_state_pop_df.jl"))
include(joinpath(@__DIR__, "margins.jl"))
include(joinpath(@__DIR__, "my_cut.jl"))
include(joinpath(@__DIR__, "q.jl"))
include(joinpath(@__DIR__, "query_nation_ages.jl"))
include(joinpath(@__DIR__, "query_state_ages.jl"))

# Define all geoid constants using the geoids submodule
const western_geoids = geoids.western_geoids
const eastern_geoids = geoids.eastern_geoids
const east_of_utah_geoids = geoids.east_of_utah_geoids
const east_of_cascade_geoids = geoids.east_of_cascade_geoids
const southern_kansas_geoids = geoids.southern_kansas_geoids
const northern_kansas_geoids = geoids.northern_kansas_geoids
const colorado_basin_geoids = geoids.colorado_basin_geoids
const ne_missouri_geoids = geoids.ne_missouri_geoids
const southern_missouri_geoids = geoids.southern_missouri_geoids
const northern_missouri_geoids = geoids.northern_missouri_geoids
const missouri_river_basin_geoids = geoids.missouri_river_basin_geoids

# Export all public functions and constants
export acs 
export add_labels! 
export add_row_totals 
export calculate_dependency_ratio 
export cleveland_dot_plot 
export collect_state_age_dataframes 
export collect_state_ages 
export convert_decimals_to_int64! 
export create_age_pyramid 
export create_birth_table 
export create_multiple_age_pyramids 
export create_state_abbrev_map 
export create_state_to_nation_map 
export DataFrames, DataFrame
export dms_to_decimal 
export expand_state_codes 
export fill_state 
export filter_dataframes 
export format_with_commas 
export ga 
export geo 
export get_breaks 
export get_childbearing_population 
export get_geo_pop 
export get_dem_vote 
export get_gop_vote 
export get_nation_state 
export get_nation_title 
export get_state_gdp 
export get_state_pop 
export get_us_ages 
export gini 
export inspect_shapefile_structure 
export make_growth_table 
export make_legend 
export make_nation_state_gdp_df 
export make_nation_state_pop_df 
export make_postal_codes 
export map_poly 
export margins 
export my_cut 
export parse_geoms 
export plot_map 
export q 
export query_all_nation_ages 
export query_nation_ages 
export query_state_ages 
export r_get_acs_data 
export RCall  # Add RCall to exports
export Figure  # Add Figure to exports
export CairoMakie  # Add CairoMakie to exports
export Label
export rename!  # Add rename! to exports
export setup_r_environment  # Add setup_r_environment to exports
export DataFrames
export ByRow  # Add ByRow to exports
export subset  # Add subset to exports
export rcopy  # Add rcopy to exports
export @R_str  # Add R string macro to exports
export check_r_packages  # Add check_r_packages to exports
export install_r_packages  # Add install_r_packages to exports
export LibPQ  # Add LibPQ to exports
export save_plot  # Add save_plot to exports
export format_number  # Add format_number to exports
export clean_column_names!  # Add clean_column_names! to exports
export remove_empty_columns!  # Add remove_empty_columns! to exports
export standardize_missing!  # Add standardize_missing! to exports

# Export all geoid constants
export western_geoids,
       eastern_geoids,
       east_of_utah_geoids,
       east_of_cascade_geoids,
       southern_kansas_geoids,
       northern_kansas_geoids,
       colorado_basin_geoids,
       ne_missouri_geoids,
       southern_missouri_geoids,
       northern_missouri_geoids,
       missouri_river_basin_geoids

end # module
