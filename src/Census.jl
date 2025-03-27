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
using RCall
using RDatasets
using RSetup  # Use the new RSetup package
using StatsBase
using StatsPlots
using URIs
using Franklin

# Include files in dependency order
include(joinpath(dirname(@__DIR__), "scripts", "cons.jl"))  # Constants and basic definitions
include(joinpath(dirname(@__DIR__), "scripts", "dict.jl"))  # Dictionary definitions
include(joinpath(dirname(@__DIR__), "scripts", "stru.jl"))  # Structure definitions
include(joinpath(dirname(@__DIR__), "scripts", "methods.jl"))  # Method definitions
include(joinpath(dirname(@__DIR__), "scripts", "highlighters.jl"))  # Syntax highlighting

# Include all function files
include(joinpath(@__DIR__, "acs.jl"))
include(joinpath(@__DIR__, "add_labels.jl"))
include(joinpath(@__DIR__, "add_row_totals.jl"))
include(joinpath(@__DIR__, "calculate_dependency_ratio.jl"))
include(joinpath(@__DIR__, "cleveland_dot_plot.jl"))
include(joinpath(@__DIR__, "collect_state_age_dataframes.jl"))
include(joinpath(@__DIR__, "collect_state_ages.jl"))
include(joinpath(@__DIR__, "convert_decimals_to_int64!.jl"))
include(joinpath(@__DIR__, "create_age_pyramid.jl"))
include(joinpath(@__DIR__, "create_birth_table.jl"))
include(joinpath(@__DIR__, "create_multiple_age_pyramids.jl"))
include(joinpath(@__DIR__, "create_state_abbrev_map.jl"))
include(joinpath(@__DIR__, "create_state_to_nation_map.jl"))
include(joinpath(@__DIR__, "dms_to_decimal.jl"))
include(joinpath(@__DIR__, "expand_state_codes.jl"))
include(joinpath(@__DIR__, "fill_state.jl"))
include(joinpath(@__DIR__, "filter_dataframes.jl"))
include(joinpath(@__DIR__, "format_with_commas.jl"))
include(joinpath(@__DIR__, "ga.jl"))
include(joinpath(@__DIR__, "get_breaks.jl"))
include(joinpath(@__DIR__, "get_childbearing_population.jl"))
include(joinpath(@__DIR__, "get_colorado_basin_geoids.jl"))
include(joinpath(@__DIR__, "get_dem_vote.jl"))
include(joinpath(@__DIR__, "get_east_of_utah_geoids.jl"))
include(joinpath(@__DIR__, "get_eastern_geoids.jl"))
include(joinpath(@__DIR__, "get_geo_pop.jl"))
include(joinpath(@__DIR__, "get_gop_vote.jl"))
include(joinpath(@__DIR__, "get_nation_state.jl"))
include(joinpath(@__DIR__, "get_nation_title.jl"))
include(joinpath(@__DIR__, "get_slope_geoids.jl"))
include(joinpath(@__DIR__, "get_southern_kansas_geoids.jl"))
include(joinpath(@__DIR__, "get_state_gdp.jl"))
include(joinpath(@__DIR__, "get_state_pop.jl"))
include(joinpath(@__DIR__, "get_us_ages.jl"))
include(joinpath(@__DIR__, "get_western_geoids.jl"))
include(joinpath(@__DIR__, "gini.jl"))
include(joinpath(@__DIR__, "inspect_shapefile_structure.jl"))
include(joinpath(@__DIR__, "make_growth_table.jl"))
include(joinpath(@__DIR__, "make_legend.jl"))
include(joinpath(@__DIR__, "make_nation_state_gdp_df.jl"))
include(joinpath(@__DIR__, "make_nation_state_pop_df.jl"))
include(joinpath(@__DIR__, "make_postal_codes.jl"))
include(joinpath(@__DIR__, "map_poly.jl"))
include(joinpath(@__DIR__, "margins.jl"))
include(joinpath(@__DIR__, "my_cut.jl"))
include(joinpath(@__DIR__, "parse_geoms.jl"))
include(joinpath(@__DIR__, "q.jl"))
include(joinpath(@__DIR__, "query_all_nation_ages.jl"))
include(joinpath(@__DIR__, "query_nation_ages.jl"))
include(joinpath(@__DIR__, "query_state_ages.jl"))

# Export all public functions
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
export dms_to_decimal 
export expand_state_codes 
export fill_state 
export filter_dataframes 
export format_with_commas 
export ga 
export geo 
export get_breaks 
export get_childbearing_population 
export get_colorado_basin_geoids 
export get_dem_vote 
export get_east_of_utah_geoids 
export get_eastern_geoids 
export get_geo_pop 
export get_gop_vote 
export get_nation_state 
export get_nation_title 
export get_slope_geoids 
export get_southern_kansas_geoids 
export get_state_gdp 
export get_state_pop 
export get_us_ages 
export get_western_geoids 
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
export q 
export query_all_nation_ages 
export query_nation_ages 
export query_state_ages 
export r_get_acs_data 
export RCall  # Add RCall to exports
export Figure  # Add Figure to exports
export CairoMakie  # Add CairoMakie to exports
export Label
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
