# SPDX-License-Identifier: MIT
module Census

using DrWatson
@quickactivate "Census"  # Use your actual project name

# Define paths directly
const SCRIPT_DIR   = projectdir("scripts")
const OBJ_DIR      = projectdir("obj")
const PARTIALS_DIR = projectdir("_layout/partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR

# Export path functions
export scriptdir, objdir, partialsdir

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))

export calculate_dependency_ratio, cleveland_dot_plot, create_birth_table
export create_state_abbrev_map, create_state_to_nation_map, collect_state_ages
export collect_state_age_dataframes, convert_decimals_to_int64!
export create_age_pyramid, create_multiple_age_pyramids, dms_to_decimal
export expand_state_codes, fill_state, format_with_commas
export get_childbearing_population, get_nation_state, get_state_pop
export get_dem_vote, get_gop_vote, get_us_ages
export make_nation_state_gdp_df, make_nation_state_pop_df, make_growth_table
export process_education_by_nation, q, query_all_nation_ages
export query_nation_ages, query_state_ages

end