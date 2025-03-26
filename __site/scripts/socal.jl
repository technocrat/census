# SPDX-License-Identifier: MIT

using Census

# Include core files
include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))

us = get_geo_pop(postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks = rcopy(get_breaks(us,5))
us.pop_bins = my_cut(us.pop, breaks[:kmeans][:brks])
us.parsed_geoms = parse_geoms(us)

df = subset(us, :stusps => ByRow(==("CA")))
df = subset(df, :geoid => ByRow(x -> x ∈ socal))

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)




