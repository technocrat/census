include("setup.jl")

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

nation_gdp     = combine(groupby(us_gdp, :nation), :gdp => sum => :gdp)
nation_gdp.gdp = Float64.(nation_gdp.gdp)
nation_gdp.gdp = round.(nation_gdp.gdp,digits=0)
nation_gdp.gdp = Int64.(nation_gdp.gdp)
sort!(nation_gdp,:nation)

# https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
world_gdp = CSV.read("../data/world_gdp.csv",DataFrame)
world_gdp = world_gdp[:,[1,68]]
rename!(world_gdp,[:nation,:gdp23])
dropmissing!(world_gdp, :gdp23)
world_gdp.gdp =  Int64.(round.(world_gdp.gdp23,digits=0))
filter!(row -> row.gdp23 >= 6e11, world_gdp)
# filter(row -> row.gdp23 <= 1e13, world_gdp)
