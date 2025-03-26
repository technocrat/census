# SPDX-License-Identifier: MIT
module Census

# All dependencies
using ArchGDAL
using BSON
using CairoMakie
using Colors
using CSV
using DataFrames
using Dates
using Decimals
using DrWatson
using FixedPointNumbers
using Format
using GeoInterface
using GeoJSON
using GeoMakie
using GeometryBasics
using HTTP
using JSON3
using LibPQ
using Measures
using PlotlyJS
using Plots
using Polynomials
using PrettyTables
using RCall
using RDatasets
using StatsBase
using URIs

# Define paths directly
const SCRIPT_DIR   = joinpath(@__DIR__, "..", "scripts")
const OBJ_DIR      = joinpath(@__DIR__, "..", "obj")
const PARTIALS_DIR = joinpath(@__DIR__, "..", "_layout", "partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR
srcdir()           = @__DIR__

# Export path functions
export scriptdir, objdir, partialsdir, srcdir

# Include files in dependency order
include(joinpath(SCRIPT_DIR, "cons.jl"))  # Constants and basic definitions
include(joinpath(SCRIPT_DIR, "dict.jl"))  # Dictionary definitions
include(joinpath(SCRIPT_DIR, "stru.jl"))  # Structure definitions
include(joinpath(SCRIPT_DIR, "highlighters.jl"))  # Syntax highlighting

# Include all function files
include(joinpath(SCRIPT_DIR, "add_labels.jl"))
include(joinpath(SCRIPT_DIR, "calculate_dependency_ratio.jl"))
include(joinpath(SCRIPT_DIR, "cleveland_dot_plot.jl"))
include(joinpath(SCRIPT_DIR, "collect_state_age_dataframes.jl"))
include(joinpath(SCRIPT_DIR, "collect_state_ages.jl"))
include(joinpath(SCRIPT_DIR, "convert_decimals_to_int64!.jl"))
include(joinpath(SCRIPT_DIR, "create_age_pyramid.jl"))
include(joinpath(SCRIPT_DIR, "create_birth_table.jl"))
include(joinpath(SCRIPT_DIR, "create_multiple_age_pyramids.jl"))
include(joinpath(SCRIPT_DIR, "create_state_abbrev_map.jl"))
include(joinpath(SCRIPT_DIR, "create_state_to_nation_map.jl"))
include(joinpath(SCRIPT_DIR, "dms_to_decimal.jl"))
include(joinpath(SCRIPT_DIR, "expand_state_codes.jl"))
include(joinpath(SCRIPT_DIR, "fill_state.jl"))
include(joinpath(SCRIPT_DIR, "filter_dataframes.jl"))
include(joinpath(SCRIPT_DIR, "find_functions.jl"))
include(joinpath(SCRIPT_DIR, "format_with_commas.jl"))
include(joinpath(SCRIPT_DIR, "functions.jl"))
include(joinpath(SCRIPT_DIR, "ga.jl"))
include(joinpath(SCRIPT_DIR, "geo.jl"))
include(joinpath(SCRIPT_DIR, "get_breaks.jl"))
include(joinpath(SCRIPT_DIR, "get_childbearing_population.jl"))
include(joinpath(SCRIPT_DIR, "get_colorado_basin_geoids.jl"))
include(joinpath(SCRIPT_DIR, "get_dem_vote.jl"))
include(joinpath(SCRIPT_DIR, "get_east_of_utah_geoids.jl"))
include(joinpath(SCRIPT_DIR, "get_eastern_geoids.jl"))
include(joinpath(SCRIPT_DIR, "get_geo_pop.jl"))
include(joinpath(SCRIPT_DIR, "get_gop_vote.jl"))
include(joinpath(SCRIPT_DIR, "get_nation_state.jl"))
include(joinpath(SCRIPT_DIR, "get_nation_title_by_state.jl"))
include(joinpath(SCRIPT_DIR, "get_nation_title.jl"))
include(joinpath(SCRIPT_DIR, "get_slope_geoids.jl"))
include(joinpath(SCRIPT_DIR, "get_southern_kansas_geoids.jl"))
include(joinpath(SCRIPT_DIR, "get_state_gdp.jl"))
include(joinpath(SCRIPT_DIR, "get_state_pop.jl"))
include(joinpath(SCRIPT_DIR, "get_us_ages.jl"))
include(joinpath(SCRIPT_DIR, "get_western_geoids.jl"))
include(joinpath(SCRIPT_DIR, "gini.jl"))
include(joinpath(SCRIPT_DIR, "inspect_shapefile_strurture.jl"))
include(joinpath(SCRIPT_DIR, "make_growth_table.jl"))
include(joinpath(SCRIPT_DIR, "make_legend.jl"))
include(joinpath(SCRIPT_DIR, "make_nation_state_gdp_df.jl"))
include(joinpath(SCRIPT_DIR, "make_nation_state_pop_df.jl"))
include(joinpath(SCRIPT_DIR, "make_postal_codes.jl"))
include(joinpath(SCRIPT_DIR, "map_poly.jl"))
include(joinpath(SCRIPT_DIR, "margins.jl"))
include(joinpath(SCRIPT_DIR, "my_cut.jl"))
include(joinpath(SCRIPT_DIR, "parse_geoms.jl"))
include(joinpath(SCRIPT_DIR, "process_education_by_nation.jl"))
include(joinpath(SCRIPT_DIR, "q.jl"))
include(joinpath(SCRIPT_DIR, "query_all_nation_ages.jl"))
include(joinpath(SCRIPT_DIR, "query_nation_ages.jl"))
include(joinpath(SCRIPT_DIR, "query_state_ages.jl"))
include(joinpath(SCRIPT_DIR, "r_get_acs_data.jl"))
include(joinpath(SCRIPT_DIR, "r_setup.jl"))
include(joinpath(SCRIPT_DIR, "scriptdir.jl"))

# Export all public functions
export add_col_margins
export add_labels!
export add_margins
export add_row_margins
export add_row_totals
export build_census_query
export calculate_dependency_ratio
export CensusQuery
export check_r_packages
export cleveland_dot_plot
export collect_state_age_dataframes
export collect_state_ages
export convert_decimals_to_int64!
export create_age_pyramid
export create_birth_table
export create_multiple_age_pyramids
export create_state_abbrev_map
export create_state_to_nation_map
export dms_to_decimal
export expand_state_codes
export fetch_census_data
export fill_state!
export filter_dataframe
export find_julia_files
export format_number
export format_with_commas
export ga
export get_acs_data
export get_breaks
export get_census_data
export get_childbearing_population
export get_colorado_basin_geoids
export get_dem_vote
export get_east_of_utah_geoids
export get_eastern_geoids
export get_geo_pop
export get_gop_vote
export get_nation_state
export get_nation_title
export get_nation_title_by_name
export get_slope_geoids
export get_southern_kansas_geoids
export get_state_gdp
export get_state_pop
export get_us_ages
export get_western_geoids
export gini
export has_function_definition
export inspect_shapefile_structure
export install_r_packages
export make_growth_table
export make_legend
export make_nation_state_gdp_df
export make_nation_state_pop_df
export make_postal_codes
export map_poly
export my_cut
export parse_geoms
export plot_cleveland_dots
export plot_education_heatmap
export process_education_by_nation
export q
export query_all_nation_ages
export query_nation_ages
export query_state_ages
export r_get_acs_data
export r_setup
export scriptdir
export setup_r_environment
export table_vis
export to_decimal

# Define and export utility functions
function valid_codes()
    return sort(collect(VALID_POSTAL_CODES))
end
export valid_codes

function ohio_basin_oh()
    return setdiff(get_geo_pop(["OH"]).geoid, gl_oh)
end
export ohio_basin_oh

end # module