# SPDX-License-Identifier: MIT


df          = get_geo_pop(Census.postals)
DataFrames.rename!(df, [:geoid, :stusps, :county, :geom, :pop])
df = filter(:geoid => x -> x ∈ south_fl, df)
RSetup.setup_r_environment()
breaks      = rcopy(RSetup.get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)


# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df,"Florida")
# Display the figure
display(fig)