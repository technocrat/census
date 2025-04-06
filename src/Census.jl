# SPDX-License-Identifier: MIT

module Census

using DataFrames
using HTTP
using JSON3
using Base.Iterators: partition
using Statistics: mean
using Dates: Year, today
using GeoInterface
using CairoMakie
using GeoMakie
using LibGEOS
using WellKnownGeometry
using LibPQ

# Include core functionality first
include("core/core.jl")
include("core/constants.jl")
include("core/acs.jl")

# Include analysis module
include("analysis/Analysis.jl")

# Re-export functions from Analysis module
using .Analysis: get_breaks,
                get_us_ages,
                make_growth_table,
                make_nation_state_gdp_df,
                make_nation_state_pop_df,
                ga,
                collect_state_age_dataframes,
                get_childbearing_population,
                get_dem_vote,
                get_gop_vote,
                get_nation_state,
                get_state_pop,
                process

# Export functions from core modules
export get_acs_moe,
       get_acs_moe1,
       get_acs_moe3,
       get_acs_moe5,
       make_census_request,
       get_moe_factor,
       is_special_moe,
       get_special_moe_message,
       add_moe_notes!,
       join_estimates_moe!,
       calculate_moe_sum,
       calculate_moe_ratio,
       calculate_moe_product,
       state_postal_to_fips

# Re-export Analysis module functions
export get_breaks,
       get_us_ages,
       make_growth_table,
       make_nation_state_gdp_df,
       make_nation_state_pop_df,
       ga,
       collect_state_age_dataframes,
       get_childbearing_population,
       get_dem_vote,
       get_gop_vote,
       get_nation_state,
       get_state_pop,
       process

end # module Census