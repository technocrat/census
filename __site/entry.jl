# SPDX-License-Identifier: MIT

include("scripts/setup.jl")

df           = get_state_pop()
gop          = get_gop_votes()
dem          = get_dem_votes()
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
nation_votes.gop_pct       =  nation_votes.gop_sum ./ (nation_votes.gop_sum .+ nation_votes.dem_sum)
nation_votes.dem_pct       =  nation_votes.dem_sum ./ (nation_votes.gop_sum .+ nation_votes.dem_sum)
nation_votes.margin        =  abs.(nation_votes.gop_pct .- nation_votes.dem_pct)

sort!(nation_votes,:nation)
