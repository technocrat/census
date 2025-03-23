# SPDX-License-Identifier: MIT

using Census
using DrWatson
@quickactivate "Census"  
using LibPQ


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
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))


df              = get_geo_pop(postals)

rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks          = rcopy(get_breaks(df,5))
df.pop_bins     = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)
western_geoids  = get_western_geoids().geoid


ar = subset(df, :stusps => ByRow(==("AR")))
mo = subset(df, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∈ ar_basin_mo))

tx = subset(df, :stusps => ByRow(==("TX")))           
tx = subset(tx, :geoid => ByRow(x -> x ∉ rio_basin_tx && x ∈ eastern_geoids))

ok = subset(df, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ eastern_geoids))

la = subset(df, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∉ ms_basin_la))

ks_south = get_southern_kansas_geoids()
ks = subset(df, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ ks_south.geoid))
ks = subset(ks, :geoid => ByRow(x -> x != "20195" && 
                                x != "20051" &&
                                x ∉ western_geoids))

df = vcat(tx,ar,ok,la,mo,ks)

fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)



# Use it to filter Kansas





