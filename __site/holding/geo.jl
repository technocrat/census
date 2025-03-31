# deprecated; move to holding/geo.jl
# SPDX-License-Identifier: MIT
# this is the model for doing a thematic map

# First, let's get the joined data directly from postgres
geo_query = """
    SELECT ne.geoid, ne.stusps, ne.name, ST_AsText(ne.geom) as json_geom, vd.value as total_population
    FROM census.counties ne
    LEFT JOIN census.variable_data vd
        ON ne.geoid = vd.geoid
        AND vd.variable_name = 'total_population'
    WHERE ne.stusps IN ('ME', 'NH', 'VT', 'MA', 'RI', 'CT')
"""

ne = DataFrame(q(geo_query))
rename!(ne, [:geoid, :stusps, :county, :geom, :pop])
gdp_query = """
    SELECT gdp.county, gdp.state, gdp.gdp
    FROM gdp
    WHERE gdp         .state IN ('Massachusetts','Connecticut','New Hampshire','Rhode Island','Vermont', 'Maine')
"""

ne_gdp = DataFrame(q(gdp_query))

# trim out the county entries for CT
gdp = ne_gdp[9:76, :]

"""
convert from Decimals.Decimal to Float64
because makie expects it and will give
    julia> fig
        Error showing value of type Figure:
        ERROR: MethodError: no method matching set_source(::Cairo.CairoContext, ::Float32)
        The function `set_source` exists, but no method is defined for this combination of argument types.
"""
gdp.gdp = Float64.(gdp.gdp)
# Create a mapping from state names (Ne) to state abbreviations (NE)
state_to_abbreviation = Dict(Ne .=> NE)

# Add the `stusps` column to the `gdp` DataFrame by mapping `gdp.state`
gdp.stusps = [state_to_abbreviation[state] for state in gdp.state]
joined_data = leftjoin(ne, gdp, on=[:county, :stusps])
joined_data.pop = Float64.(joined_data.pop)
joined_data.gdp = Float64.(joined_data.gdp)
joined_data.den = joined_data.gdp ./ joined_data.pop
include("src/r_setup.jl")
kpop = get_breaks(joined_data, 5)[3][2]
kgdp = get_breaks(joined_data, 7)[3][2]
kden = get_breaks(joined_data, 8)[3][2]
joined_data.pop_bins = my_cut(joined_data.pop, kpop)
joined_data.gdp_bins = my_cut(joined_data.gdp, kgdp)
joined_data.den_bins = my_cut(joined_data.den, kden)

# Convert WKT strings to geometric objects
geometries = joined_data.geom
parsed_geometries = [ArchGDAL.fromWKT(geom) for geom in geometries if !ismissing(geom)]

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "New England Counties", fontsize=20)

ga1 = ga(1, 1, "Population")
poly1 = make_poly(ga1, "pop")
# ga2 = ga(1,2,"Gross Domestic Product")
# poly1 = make_poly(ga2,"gdp")
ga3 = ga(1, 3, "GDP Per Capita")
poly1 = make_poly(ga3, "den")
fig

total_by_state = combine(groupby(ne, :stusps), :pop => sum => :total_population)
 sort!(total_by_state, :total_population, rev=true)
 total_by_state.total_population = format.(round.(total_by_state.total_population), commas = true)
 total_by_state.stusps = Ne

 geo_query = """
     SELECT ne.geoid, ne.stusps, ne.name, ST_AsText(ne.geom) as json_geom, vd.value as total_population
     FROM census.counties ne
     LEFT JOIN census.variable_data vd
         ON ne.geoid = vd.geoid
         AND vd.variable_name = 'total_population'
     WHERE ne.stusps NOT IN ('ME', 'NH', 'VT', 'MA', 'RI', 'CT')
 """
us = DataFrame(q(geo_query)
us = us[in.(us.stusps, Ref(STATES)),:]
us_pop = combine(groupby(us, :stusps), :total_population => sum => :pop)
us_pop = dropmissing(us_pop, :pop)
deleteat!(us_pop,20)
sort!(us_pop,:pop)
us_tot = sum(us_pop.pop)
big_tot = us_tot + sum(ne.pop)
sum(ne.pop)/big_tot
us_pop[us_pop.pop > sum(ne.pop),:]
total_ne_pop = sum(ne.pop)
filter(row -> row.pop > sum(ne.pop), us_pop)

gdp_query = """
    SELECT gdp.county, gdp.state, gdp.gdp
    FROM gdp"""
    WHERE gdp         .state NOT IN ('Massachusetts','Connecticut','New Hampshire','Rhode Island','Vermont', 'Maine')
"""

us_gdp = DataFrame(q(gdp_query))
us_gdp.gdp = Float64.(us_gdp.gdp)
us_gdp = us_gdp[in.(us_gdp.state, Ref(States)),:]
us_gdp = combine(groupby(us_gdp, :nation), :gdp => sum => :gdp)
us_gdp = dropmissing(us_gdp, :gdp)
#deleteat!(us_pop,20)
sort!(us_gdp,:gdp)
us_gdp_tot = sum(us_gdp.gdp)
world_gdp = CSV.read("data/world_gdp.csv",DataFrame)
world_gdp.gdp = Float64.(world_gdp.gdp_2022)
peers = world_gdp[world_gdp.gdp > 1e12]
world_pop = CSV.read("data/world_pop24.csv",DataFrame)
neigh = world_pop[world_pop.population .> 10e6 & world_pop.population .< 20e6]
