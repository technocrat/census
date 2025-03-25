# SPDX-License-Identifier: MIT

using Census
using DrWatson
@quickactivate "Census"  

# Defidf paths directly
const SCRIPT_DIR   = projectdir("scripts")
const OBJ_DIR      = projectdir("obj")
const PARTIALS_DIR = projectdir("_layout/partials")

# Wrapper functions
scriptdir()        = SCRIPT_DIR
objdir()           = OBJ_DIR
partialsdir()      = PARTIALS_DIR

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPT_DIR, "libr.jl"))
#include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))

il          = get_geo_pop(["IL"])
wi          = get_geo_pop(["WI"])
mn          = get_geo_pop(["MN"])
ia          = get_geo_pop(["IA"])
mo          = get_geo_pop(["MO"])
mi          = get_geo_pop(["MI"])

df          = vcat(il,wi,mn,ia,mo,mi)

rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

mi           = filter(:stusps  => x -> x == "MI",df)           
mi           = filter(:geoid   => x -> x ∈ peninsula,mi)
il           = filter(:stusps  => x -> x == "IL",df)           
il           = filter(:geoid   => x -> x ∉ ohio_basin_il,il)
wi           = filter(:stusps  => x -> x == "WI",df)
mo           = filter(:stusps  => x -> x == "MO",df)
mo           = filter(:geoid  => x -> x ∈ ms_basin_mo,mo)
mn           = filter(:stusps  => x -> x == "MN",df)
mn           = filter(:geoid  => x -> x ∉ mo_basin_mn,mn)   
ia           = filter(:stusps  => x -> x == "IA",df)
ia           = filter(:geoid  => x -> x ∈ ms_basin_ia,ia)
df           = vcat(wi,mi,ia,il,mn,mo)

fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



