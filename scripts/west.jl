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


us              = get_geo_pop(postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks          = rcopy(get_breaks(us,5))
us.pop_bins     = my_cut(us.pop, breaks[:kmeans][:brks])
us.parsed_geoms = parse_geoms(us)
western_geoids  = get_western_geoids().geoid
eastern_geoids  = get_eastern_geoids().geoid
const colorado_basin_geoids = get_colorado_basin_geoids()
const slope_geoids = get_slope_geoids().geoid
east_of_utah = get_east_of_utah_geoids().geoid

az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))
nm = subset(nm, :geoid => ByRow(x -> x ∈ rio_basin_nm || 
                                x ∈ western_geoids))
mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ missouri_river_basin ||
                                x ∈ east_of_utah))

id = subset(us, :stusps => ByRow(==("ID")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∉ missouri_river_basin))

nv = subset(us, :stusps => ByRow(==("NV")))

ut = subset(us, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ slope_geoids ||
                                x ∈ necal))
ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∈ necal))

wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid  => ByRow(x -> x ∈ slope_geoids))
 
df = vcat(az,id,nv,or,wa,ut,ca)

df = subset(df, :stusps => ByRow(x -> x ∉ ["AK"]))

fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)

