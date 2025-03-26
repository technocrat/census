# SPDX-License-Identifier: MIT
using Census

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))

ny = get_geo_pop(["NY"])
pa = get_geo_pop(["PA"])
oh = get_geo_pop(["OH"])
ind = get_geo_pop(["IN"])
mi = get_geo_pop(["MI"])
il = get_geo_pop(["IL"])
df = vcat(ny,pa,oh,ind,mi,il)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

ny = filter(:geoid => x -> x ∈ metro_to_gl,df)
pa = filter(:geoid => x -> x ∈ gl_pa,df)
oh = filter(:stusps => x -> x == "OH",df)
oh = filter(:geoid => x -> x ∈ gl_oh,oh)
ind = filter(:stusps => x -> x == "IN",df)
ind = filter(:geoid => x -> x ∈ gl_in,ind)
mi = filter(:stusps => x -> x == "MI",df)
mi = filter(:geoid => x -> x ∉ peninsula,mi)
il = filter(:geoid => x -> x ∈ ohio_basin_il,df)

df = vcat(ny,pa,oh,ind,mi,il)

fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



