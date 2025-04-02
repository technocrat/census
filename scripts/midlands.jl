# SPDX-License-Identifier: MIT
using Census

us = get_geo_pop(Census.postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks = rcopy(get_breaks(us,5))
us.pop_bins = my_cut(us.pop, breaks[:kmeans][:brks])
us.parsed_geoms = parse_geoms(us)
western_geoids = get_western_geoids()
eastern_geoids = get_eastern_geoids()
so_mo = get_southern_missouri_counties()
ne_mo = get_ne_missouri_counties()

mn = subset(us, :stusps => ByRow(==("MN")))
mn = subset(mn, :geoid => ByRow(x -> x ∈ mo_basin_mn))

ia = subset(us, :stusps => ByRow(==("IA")))
ia = subset(ia, :geoid => ByRow(x -> x ∈ mo_basin_ia))

mo = subset(us, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∉ ne_mo && x  ∉ so_mo))  

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∉ get_southern_kansas_geoids().geoid && x ∉ western_geoids))

ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∉ western_geoids))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∉ western_geoids))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∉ western_geoids))   

df = vcat(mn,ia,mo,ks,ne,nd,sd) 

breaks = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

dest = """
+proj=aea +lat_1=35 +lat_2=55 +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
"""
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Midlands", dest, fig)
# Display the figure

display(fig)


