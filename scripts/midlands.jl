# SPDX-License-Identifier: MIT
using Census

dest = get_crs("heart")

map_title = "Midlands"
us = get_geo_pop(Census.postals)

mo_basin_ia = ["19071", "19129", "19155", "19085", "19133", "19193"]
mo_basin_mn = ["27117", "27133", "27195"]

mn = subset(us, :stusps => ByRow(==("MN")))
mn = subset(mn, :geoid => ByRow(x -> x ∈ mo_basin_mn))

ia = subset(us, :stusps => ByRow(==("IA")))
ia = subset(ia, :geoid => ByRow(x -> x ∈ mo_basin_ia))

mo = subset(us, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∈ missouri_river_basin_geoids))  

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ northern_kansas_geoids
                                  && x ∈ eastern_geoids))

ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ eastern_geoids))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ eastern_geoids))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ eastern_geoids))   

df = vcat(mn,ia,mo,ks,ne,nd,sd) 




plot_map(df, map_title, dest)


