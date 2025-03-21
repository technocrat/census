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
include(joinpath(SCRIPT_DIR, "cons.jl"))
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))

rejig       = copy(metropolis)
regig       = push!(rejig,"PA")
df          = get_geo_pop(rejig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

addn = filter(:geoid  => x -> x ∈ add_to,df)
df   = vcat(df,addn)
df   = filter(:geoid  => x -> x ∉ take_from_metro,df)
df   = filter(:stusps => x -> x != "WV" && x ∉ add_to_metro,df)
df   = filter(:stusps => x -> x != "CT" && x ∉ add_to_metro,df)

df   = filter(:geoid => x -> x in take_from_metro,df)
df   = filter(:stusps => x -> x != "VA",df)
df   = filter(:stusps => x -> x != "MD",df)
df   = filter(:stusps => x -> x != "DE",df)
df   = filter(:stusps => x -> x != "DC",df)


fig = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Adjusted Metropolis", fontsize=20)
ga1 = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
fig



