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
include(joinpath(SCRIPT_DIR, "dict.jl"))
include(joinpath(SCRIPT_DIR, "func.jl"))
include(joinpath(SCRIPT_DIR, "highlighters.jl"))
include(joinpath(SCRIPT_DIR, "stru.jl"))
include(joinpath(SCRIPT_DIR, "setup.jl"))


df          = get_geo_pop(postals)

rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks          = rcopy(get_breaks(df,5))
df.pop_bins     = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)
western_geoids  = get_western_geoids().geoid
eastern_geoids  = get_eastern_geoids().geoid


ar = subset(df, :stusps => ByRow(==("AR")))
ar = subset(ar, :geoid => ByRow(x -> x ∈ ar_basin_mo))

mn= subset(df, :stusps => ByRow(==("MN")))
mn = subset(mn, :geoid => ByRow(x -> x ∈ mo_basin_mn))

ia = subset(df, :stusps => ByRow(==("IA")))
ia = subset(ia, :geoid => ByRow(x -> x ∈ mo_basin_ia))

mo = subset(df, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∈ mo_basin_mo))  

ks = subset(df, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∉ ks_south.geoid && x ∉ western_geoids))

ne = subset(df, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∉ western_geoids))

nd = subset(df, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∉ western_geoids))

sd = subset(df, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∉ western_geoids))   

df = vcat(mn,ia,mo,ks,ne,nd,sd) 
fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)




