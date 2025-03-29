# SPDX-License-Identifier: MIT

us = get_geo_pop(postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks = rcopy(get_breaks(us,5))
us.pop_bins = my_cut(us.pop, breaks[:kmeans][:brks])
us.parsed_geoms = parse_geoms(us)

df = subset(us, :stusps => ByRow(==("CA")))
df = subset(df, :geoid => ByRow(x -> x ∉ socal && x ∉ east_of_sierras))

dest = """
+proj=aea +lat_1=35 +lat_2=45 +lat_0=40 +lon_0=-120 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
"""
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Midlands", dest, fig)
# Display the figure

display(fig)
                                




