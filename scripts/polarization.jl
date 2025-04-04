# SPDX-License-Identifier: MIT

using CSV
using DataFrames
using Statistics

# Define paths relative to project root
const PROJECT_ROOT = dirname(dirname(@__FILE__))
const DATA_DIR = joinpath(PROJECT_ROOT, "data")

include(joinpath(@__DIR__, "setup.jl"))
include(joinpath(@__DIR__, "func.jl"))
include(joinpath(dirname(@__DIR__), "src", "q.jl"))
df           = get_state_pop()
gop          = get_gop_vote()
dem          = get_dem_vote()
df           = leftjoin(df,gop,on = :stusps)
df           = leftjoin(df,dem,on = :stusps)
sort!(df,:stusps)
df[1,3]      = 184458    # Alaska county-level returns missing from source data
df[1,4]      = 140026
df[12,3]     = 193661    # Hawaii county-level returns missing from source data
df[12,4]     = 313044
df.nation    = [get_nation_title(state, nations, Titles) for state in df.stusps]

nation_votes = combine(groupby(df, :nation), 
    :pop    => sum,
    :gop    => sum,
    :dem    => sum
)

nation_votes.participation = (nation_votes.gop_sum .+ nation_votes.dem_sum) ./ nation_vote.pop_sum
nation_votes.gop_pct       = nation_votes.gop_sum ./ (nation_votes.gop_sum .+ nation_votes.dem_sum)
nation_votes.dem_pct       = nation_votes.dem_sum ./ (nation_votes.gop_sum .+ nation_votes.dem_sum)
nation_votes.margin        = abs.(nation_votes.gop_pct .- nation_votes.dem_pct)
nation_votes.margin        = nation_votes.margin .* 100
nation_votes.margin        = round.(nation_votes.margin, digits = 2)
nation_votes.margin        = string.(nation_votes.margin) .* "%"

sort!(nation_votes,:nation)
long_term = CSV.read(joinpath(DATA_DIR, "long_votes.csv"), DataFrame)
long_term.nation = [get_nation_title_by_name(state, nations, Titles) for state in long_term.State]
long_term.stusps = [get(reverse_state_dict, state, missing) for state in long_term.State]
df               = get_state_pop()
df               = leftjoin(df,long_term, on = :stusps)
df.dem_pop       = df.pop .* df.Dem ./ 100 
df.gop_pop       = df.pop .* df.Rep ./ 100 

last_votes = combine(groupby(df, :nation), 
    :pop     => sum,
    :gop_pop => sum,
    :dem_pop => sum
)

long_term_votes.dem_pct = long_term_votes.dem_pop_sum ./ long_term_votes.pop_sum
long_term_votes.gop_pct = long_term_votes.gop_pop_sum ./ long_term_votes.pop_sum
long_term_votes.margin  = abs.(long_term_votes.gop_pct .- long_term_votes.dem_pct)
long_term_votes.margin  = long_term_votes.margin .* 100
long_term_votes.margin  = round.(long_term_votes.margin, digits = 2)
long_term_votes.margin  = string.(long_term_votes.margin) .* "%"
sort!(long_term_votes)

recently = nations_vote
historical = long_term_votes
report_polarization(recently,historical)
