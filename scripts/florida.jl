# SPDX-License-Identifier: MIT

south_fl      = ["12075","12083","12107","12035","12127","12117",
                 "12053","12119","12069","12095","12009","12101",
                 "12103","12057","12105","12097","12009","12081",
                 "12115","12097","12061","12049","12093","12061",
                 "12027","12111","12015","12043","12085","12071",
                 "12027","12071","12051","12099","12021","12011",
                 "12087","12086","12055","12017"]
df          = get_geo_pop(Census.postals)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
df = filter(:geoid => x -> x ∈ south_fl, df)
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)


# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df,"Florida")
# Display the figure
display(fig)