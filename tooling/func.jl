# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

include(joinpath(scriptdir(), "add_labels.jl"))
include(joinpath(scriptdir(), "calculate_dependency_ratio.jl"))
include(joinpath(scriptdir(), "cleveland_dot_plot.jl"))
include(joinpath(scriptdir(), "collect_state_age_dataframes.jl"))
include(joinpath(scriptdir(), "collect_state_ages.jl"))
include(joinpath(scriptdir(), "convert_decimals_to_int64!.jl"))
include(joinpath(scriptdir(), "create_age_pyramid.jl"))
include(joinpath(scriptdir(), "create_birth_table.jl"))
include(joinpath(scriptdir(), "create_multiple_age_pyramids.jl"))
include(joinpath(scriptdir(), "create_state_abbrev_map.jl"))
include(joinpath(scriptdir(), "create_state_to_nation_map.jl"))
include(joinpath(scriptdir(), "dms_to_decimal.jl"))
include(joinpath(scriptdir(), "expand_state_codes.jl"))
include(joinpath(scriptdir(), "fill_state.jl"))
include(joinpath(scriptdir(), "filter_dataframes.jl"))
include(joinpath(scriptdir(), "find_functions.jl"))
include(joinpath(scriptdir(), "format_with_commas.jl"))
include(joinpath(scriptdir(), "functions.jl"))
include(joinpath(scriptdir(), "ga.jl"))
include(joinpath(scriptdir(), "geo.jl"))
include(joinpath(scriptdir(), "get_breaks.jl"))
include(joinpath(scriptdir(), "get_childbearing_population.jl"))
include(joinpath(scriptdir(), "get_colorado_basin_geoids.jl"))
include(joinpath(scriptdir(), "get_dem_vote.jl"))
include(joinpath(scriptdir(), "get_east_of_utah_geoids.jl"))
include(joinpath(scriptdir(), "get_eastern_geoids.jl"))
include(joinpath(scriptdir(), "get_geo_pop.jl"))
include(joinpath(scriptdir(), "get_gop_vote.jl"))
include(joinpath(scriptdir(), "get_nation_state.jl"))
include(joinpath(scriptdir(), "get_nation_title_by_state.jl"))
include(joinpath(scriptdir(), "get_nation_title.jl"))
include(joinpath(scriptdir(), "get_slope_geoids.jl"))
include(joinpath(scriptdir(), "get_southern_kansas_geoids.jl"))
include(joinpath(scriptdir(), "get_state_gdp.jl"))
include(joinpath(scriptdir(), "get_state_pop.jl"))
include(joinpath(scriptdir(), "get_us_ages.jl"))
include(joinpath(scriptdir(), "get_western_geoids.jl"))
include(joinpath(scriptdir(), "gini.jl"))
include(joinpath(scriptdir(), "inspect_shapefile_strurture.jl"))
include(joinpath(scriptdir(), "make_growth_table.jl"))
include(joinpath(scriptdir(), "make_legend.jl"))
include(joinpath(scriptdir(), "make_nation_state_gdp_df.jl"))
include(joinpath(scriptdir(), "make_nation_state_pop_df.jl"))
include(joinpath(scriptdir(), "make_postal_codes.jl"))
include(joinpath(scriptdir(), "map_poly.jl"))
include(joinpath(scriptdir(), "margins.jl"))
include(joinpath(scriptdir(), "my_cut.jl"))
include(joinpath(scriptdir(), "parse_geoms.jl"))
include(joinpath(scriptdir(), "process_education_by_nation.jl"))
include(joinpath(scriptdir(), "q.jl"))
include(joinpath(scriptdir(), "query_all_nation_ages.jl"))
include(joinpath(scriptdir(), "query_nation_ages.jl"))
include(joinpath(scriptdir(), "query_state_ages.jl"))
include(joinpath(scriptdir(), "scriptdir.jl"))
