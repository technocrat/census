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

tx          = get_geo_pop(["TX"])
nm          = get_geo_pop(["NM"])
ar          = get_geo_pop(["AR"])
la          = get_geo_pop(["LA"])
co          = get_geo_pop(["CO"])

df          = vcat(tx,ok,ar,la,nm,co)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

tx           = filter(:stusps  => x -> x == "TX",df)           
tx           = filter(:geoid   => x -> x ∈ rio_basin_tx,tx)
co           = filter(:stusps  => x -> x == "CO",df)           
co           = filter(:geoid   => x -> x ∈ rio_basin_co,co)
nm           = filter(:stusps  => x -> x == "NM",df)
nm           = filter(:geoid   => x -> x ∈ rio_basin_nm,nm)
mo           = filter(:stusps  => x -> x == "MO",df)
mo           = filter(:geoid  => x -> x ∈ ms_basin_mo,mo)
mn           = filter(:stusps  => x -> x == "MN",df)
mn           = filter(:geoid  => x -> x ∉ mo_basin_mn,mn)   
ia           = filter(:stusps  => x -> x == "IA",df)
ia           = filter(:geoid  => x -> x ∈ ms_basin_ia,ia)
df           = vcat(tx,co,nm)

fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



