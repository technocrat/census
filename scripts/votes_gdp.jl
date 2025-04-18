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

include(joinpath(@__DIR__, "setup.jl"))

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

us_gdp = q(gdp_query)

# only needed for mapping
# conus_gdp      = filter(:state => x -> !(x in ["AK","HI"]), us_gdp)
us_gdp[!, :nation] = fill("", nrow(us_gdp))
us_gdp.nation     .= ifelse.(in.(:state, Ref(concord)), "concord", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(metropolis)), "metropolis", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(factoria)), "factoria", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(lonestar)), "lonestar", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(dixie)), "dixie", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(cumber)), "cumber", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(heartland)), "heartland", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(desert)), "desert", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(pacific)), "pacific", us_gdp.nation)
us_gdp.nation     .= ifelse.(in.(:state, Ref(sonora)), "sonora", us_gdp.nation)

us_gdp.nation = map(state -> begin
    # Get the abbreviation
    abbr = get(reverse_state_dict, state, nothing)
    # Return the nation
    abbr === nothing ? "Unknown" : get_nation(abbr)
end, us_gdp.state)

nation_gdp               = combine(groupby(us_gdp, :nation), :gdp => sum => :gdp)
nation_gdp.gdp           = Float64.(nation_gdp.gdp)
nation_gdp.gdp           = round.(nation_gdp.gdp,digits=0)
nation_gdp.gdp           = Int64.(nation_gdp.gdp)
sort!(nation_gdp,:nation)
nation_gdp               = transform(nation_gdp, :nation => ByRow(n -> get(nat_abbr_dict, n, n)) => :nation_full)
nation_gdp               = nation_gdp[!,[3,2]]
rename!(nation_gdp,[:nation,:gdp])
productivity             = innerjoin(nation_votes,nation_gdp)
productivity.per_capital = productivity.gdp ./ productivity.pop_sum
us_pop                   = sum(productivity.pop_sum)
us_gdp                   = sum(productivity.gdp)
us_pc                    = us_gdp/us_pop
margin_table             = productivity[!,[1,8]]
prod_table               = productivity[!,[1,10]]
prod_table.per_capital   = Int64.(round.(prod_table.per_capital,digits = 0))
prod_table               = format_with_commas(prod_table)
us_pc                    = format(Int64(round(us_pc,digits = 0)), commas = true)
us_pc                    = DataFrame(nation = "United States", per_capital = us_pc)
prod_table               = vcat(prod_table, us_pc)

output_gdp_compared_to_us(prod_table, nations, Titles)


