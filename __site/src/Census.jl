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
using StatsBase
using StatsPlots
using URIs
using Franklin

# Define paths relative to project root
const PROJECT_ROOT = dirname(@__DIR__)
const SCRIPTS_DIR = joinpath(PROJECT_ROOT, "scripts")
const OBJ_DIR = joinpath(PROJECT_ROOT, "obj")
const PARTIALS_DIR = joinpath(PROJECT_ROOT, "_layout", "partials")
const SRC_DIR = @__DIR__

# Wrapper functions
projectroot() = PROJECT_ROOT
scriptsdir() = SCRIPTS_DIR
objdir() = OBJ_DIR
partialsdir() = PARTIALS_DIR
srcdir() = SRC_DIR

# Export path functions
export projectroot, scriptsdir, objdir, partialsdir, srcdir

# Include files in dependency order
include(joinpath(SCRIPTS_DIR, "cons.jl"))  # Constants and basic definitions
include(joinpath(SCRIPTS_DIR, "dict.jl"))  # Dictionary definitions
include(joinpath(SCRIPTS_DIR, "stru.jl"))  # Structure definitions
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))  # Syntax highlighting
include(joinpath(SCRIPTS_DIR, "methods.jl"))  # Method definitions

# Include all function files
include(joinpath(SCRIPTS_DIR, "add_labels.jl"))
include(joinpath(SCRIPTS_DIR, "add_row_totals.jl"))
include(joinpath(SCRIPTS_DIR, "adj_concord.jl"))
include(joinpath(SCRIPTS_DIR, "adj_dixie.jl"))
include(joinpath(SCRIPTS_DIR, "adj_factor.jl"))
include(joinpath(SCRIPTS_DIR, "adj_heart.jl"))
include(joinpath(SCRIPTS_DIR, "adj_lonestar.jl"))
include(joinpath(SCRIPTS_DIR, "adj_metro.jl"))
include(joinpath(SCRIPTS_DIR, "adj_pacifica.jl"))
include(joinpath(SCRIPTS_DIR, "bullseye.jl"))
include(joinpath(SCRIPTS_DIR, "calculate_dependency_ratio.jl"))
include(joinpath(SCRIPTS_DIR, "cleveland_dot_plot.jl"))
include(joinpath(SCRIPTS_DIR, "collect_and_output_birth_tables.jl"))
include(joinpath(SCRIPTS_DIR, "collect_and_output_growth_tables.jl"))
include(joinpath(SCRIPTS_DIR, "collect_and_output_population_tables.jl"))
include(joinpath(SCRIPTS_DIR, "collect_state_age_dataframes.jl"))
include(joinpath(SCRIPTS_DIR, "collect_state_ages.jl"))
include(joinpath(SCRIPTS_DIR, "compare_educ_attainment.jl"))
include(joinpath(SCRIPTS_DIR, "convert_decimals_to_int64!.jl"))
include(joinpath(SCRIPTS_DIR, "create_birth_table.jl"))
include(joinpath(SCRIPTS_DIR, "create_gdp_database.jl"))
include(joinpath(SCRIPTS_DIR, "create_multiple_age_pyramids.jl"))
include(joinpath(SCRIPTS_DIR, "create_state_abbrev_map.jl"))
include(joinpath(SCRIPTS_DIR, "create_state_to_nation_map.jl"))
include(joinpath(SCRIPTS_DIR, "ct_gdp.jl"))
include(joinpath(SCRIPTS_DIR, "display_map.jl"))
include(joinpath(SCRIPTS_DIR, "dms_to_decimal.jl"))
include(joinpath(SCRIPTS_DIR, "educ.jl"))
include(joinpath(SCRIPTS_DIR, "erie.jl"))
include(joinpath(SCRIPTS_DIR, "expand_state_codes.jl"))
include(joinpath(SCRIPTS_DIR, "external_flows.jl"))
include(joinpath(SCRIPTS_DIR, "fill_state.jl"))
include(joinpath(SCRIPTS_DIR, "filter_dataframes.jl"))
include(joinpath(SCRIPTS_DIR, "format_with_commas.jl"))
include(joinpath(SCRIPTS_DIR, "ga.jl"))
include(joinpath(SCRIPTS_DIR, "gdp.jl"))
include(joinpath(SCRIPTS_DIR, "geo.jl"))
include(joinpath(SCRIPTS_DIR, "get_breaks.jl"))
include(joinpath(SCRIPTS_DIR, "get_childbearing_population.jl"))
include(joinpath(SCRIPTS_DIR, "get_colorado_basin_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "get_dem_vote.jl"))
include(joinpath(SCRIPTS_DIR, "get_east_of_utah_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "get_eastern_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "get_geo_pop.jl"))
include(joinpath(SCRIPTS_DIR, "get_gop_vote.jl"))
include(joinpath(SCRIPTS_DIR, "get_nation_state.jl"))
include(joinpath(SCRIPTS_DIR, "get_nation_title.jl"))
include(joinpath(SCRIPTS_DIR, "get_nation_title_by_state.jl"))
include(joinpath(SCRIPTS_DIR, "get_slope_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "get_southern_kansas_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "get_state_gdp.jl"))
include(joinpath(SCRIPTS_DIR, "get_state_pop.jl"))
include(joinpath(SCRIPTS_DIR, "get_us_ages.jl"))
include(joinpath(SCRIPTS_DIR, "get_western_geoids.jl"))
include(joinpath(SCRIPTS_DIR, "gini.jl"))
include(joinpath(SCRIPTS_DIR, "inspect_shapefile_strurture.jl"))
include(joinpath(SCRIPTS_DIR, "make_growth_table.jl"))
include(joinpath(SCRIPTS_DIR, "make_legend.jl"))
include(joinpath(SCRIPTS_DIR, "make_nation_state_gdp_df.jl"))
include(joinpath(SCRIPTS_DIR, "make_nation_state_pop_df.jl"))
include(joinpath(SCRIPTS_DIR, "make_postal_codes.jl"))
include(joinpath(SCRIPTS_DIR, "map_poly.jl"))
include(joinpath(SCRIPTS_DIR, "margins.jl"))
include(joinpath(SCRIPTS_DIR, "midlands.jl"))
include(joinpath(SCRIPTS_DIR, "my_cut.jl"))
include(joinpath(SCRIPTS_DIR, "nation_build.jl"))
include(joinpath(SCRIPTS_DIR, "nocal.jl"))
include(joinpath(SCRIPTS_DIR, "output_gdp_compared_to_eu_table.jl"))
include(joinpath(SCRIPTS_DIR, "output_gdp_compared_to_us.jl"))
include(joinpath(SCRIPTS_DIR, "output_league_table.jl"))
include(joinpath(SCRIPTS_DIR, "parse_geoms.jl"))
include(joinpath(SCRIPTS_DIR, "polarization.jl"))
include(joinpath(SCRIPTS_DIR, "pop_tab.jl"))
include(joinpath(SCRIPTS_DIR, "process_education_by_nation.jl"))
include(joinpath(SCRIPTS_DIR, "q.jl"))
include(joinpath(SCRIPTS_DIR, "queries.jl"))
include(joinpath(SCRIPTS_DIR, "query_all_nation_ages.jl"))
include(joinpath(SCRIPTS_DIR, "query_state_ages.jl"))
include(joinpath(SCRIPTS_DIR, "r_get_acs_data.jl"))
include(joinpath(SCRIPTS_DIR, "r_setup.jl"))
include(joinpath(SCRIPTS_DIR, "report_education.jl"))
include(joinpath(SCRIPTS_DIR, "report_polarization.jl"))
include(joinpath(SCRIPTS_DIR, "rockies.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))
include(joinpath(SCRIPTS_DIR, "socal.jl"))
include(joinpath(SCRIPTS_DIR, "update_pop_bins.jl"))
include(joinpath(SCRIPTS_DIR, "west.jl"))

# Export all public functions
export add_col_margins,
       add_labels!,
       add_margins,
       add_row_margins,
       add_row_totals,
       build_census_query,
       calculate_dependency_ratio,
       CensusQuery,
       check_r_packages,
       cleveland_dot_plot,
       collect_state_age_dataframes,
       collect_state_ages,
       convert_decimals_to_int64!,
       create_age_pyramid,
       create_birth_table,
       create_multiple_age_pyramids,
       create_state_abbrev_map,
       create_state_to_nation_map,
       dms_to_decimal,
       expand_state_codes,
       fetch_census_data,
       fill_state!,
       filter_dataframe,
       find_julia_files,
       format_number,
       format_with_commas,
       ga,
       get_acs_data,
       get_breaks,
       get_census_data,
       get_childbearing_population,
       get_colorado_basin_geoids,
       get_dem_vote,
       get_east_of_utah_geoids,
       get_eastern_geoids,
       get_geo_pop,
       get_gop_vote,
       get_nation_state,
       get_nation_title,
       get_nation_title_by_name,
       get_slope_geoids,
       get_southern_kansas_geoids,
       get_state_gdp,
       get_state_pop,
       get_us_ages,
       get_western_geoids,
       gini,
       has_function_definition,
       inspect_shapefile_structure,
       install_r_packages,
       make_growth_table,
       make_legend,
       make_nation_state_gdp_df,
       make_postal_codes,
       map_poly,
       my_cut,
       parse_geoms,
       plot_cleveland_dots,
       plot_education_heatmap,
       process_education_by_nation,
       q,
       query_all_nation_ages,
       query_nation_ages,
       query_state_ages,
       r_get_acs_data,
       r_setup,
       setup_r_environment,
       table_vis,
       to_decimal

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