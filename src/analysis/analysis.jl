# SPDX-License-Identifier: MIT

"""
Analysis module for Census data processing and analysis functions.
"""
module Analysis

using DataFrames
using Statistics
using CSV
using LibPQ
using CairoMakie
using GeoMakie

# Include analysis functions
include("process.jl")
include("margins.jl")
include("ga.jl")
include("get_us_ages.jl")
include("make_growth_table.jl")
include("make_nation_state_gdp_df.jl")
include("make_nation_state_pop_df.jl")
include("collect_state_age_dataframes.jl")
include("get_childbearing_population.jl")
include("get_dem_vote.jl")
include("get_gop_vote.jl")
include("get_nation_state.jl")
include("get_state_pop.jl")

# Export functions
export get_us_ages,
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
       make_nation_state_pop_df,
       process

end # module Analysis 