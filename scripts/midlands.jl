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
const colorado_basin_geoids = get_colorado_basin_geoids()


tx = subset(df, :stusps => ByRow(==("TX")))           
tx = subset(tx, :geoid => ByRow(x -> x ∉ rio_basin_tx && x ∈ eastern_geoids))

ok = subset(df, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ eastern_geoids))

la = subset(df, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∉ ms_basin_la))


co = subset(df, :stusps => ByRow(==("CO")))           
co = subset(co, :geoid => ByRow(x -> x ∈ rio_basin_co))

nm = subset(df, :stusps => ByRow(==("NM")))
nm = subset(nm, :geoid => ByRow(x -> x ∈ rio_basin_nm))

mt = subset(df, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ columbia_river_basin && x ∉ colorado_basin_geoids))

ut = subset(df, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ columbia_river_basin && x ∉ colorado_basin_geoids))

sd = subset(df, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ western_geoids))

id = subset(df, :stusps => ByRow(==("ID")))
id = subset(id, :geoid => ByRow(x -> x ∈ columbia_river_basin))

or = subset(df, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ columbia_river_basin))

wa = subset(df, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∈ columbia_river_basin))

nv = subset(df, :stusps => ByRow(==("NV")))
nv = subset(nv, :geoid => ByRow(x -> x ∈ colorado_basin_geoids))

wy = subset(df, :stusps => ByRow(==("WY")))
wy = subset(wy, :geoid => ByRow(x -> x ∉ columbia_river_basin && x ∉ colorado_basin_geoids))



wst = subset(df, :geoid => ByRow(x -> x ∈ western_geoids && x ∈ colorado_basin_geoids))
crb = subset(df, :geoid => ByRow(x -> x ∈ colorado_basin_geoids))
rio = subset(df, :geoid => ByRow(x -> (x ∈ rio_basin_tx || 
                                      x ∈ rio_basin_co || 
                                      x ∈ rio_basin_nm || 
                                      (x ∈ western_geoids && x ∉ colorado_basin_geoids))))

df = vcat(tx,ar,ok,la,mo)
fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)




