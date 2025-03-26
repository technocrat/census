# SPDX-License-Identifier: MIT

using Census

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))

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

az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∈ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))

mt = subset(us, :stusps => ByRow(==("MT")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∈ western_geoids))

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ western_geoids))
ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ western_geoids))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ western_geoids))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ western_geoids))

ok = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∉ eastern_geoids))

tx = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ rio_basin_tx ||
                                x ∉ eastern_geoids))

df = vcat(mt,nm,wy,az,co,az,nd,sd,ne,ks,tx,ok)

df = subset(df, :stusps => ByRow(x -> x ∉ ["AK"]))

fig   = Figure(size=(1200, 800), fontsize=22)
title = Label(fig[0, 2], "Erie", fontsize=20)
ga1   = ga(1, 1, "Population")
poly1 = map_poly(df,ga1, "pop")
add_labels!(df, ga1, :geoid, fontsize=6)
display(fig)




