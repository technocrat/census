# SPDX-License-Identifier: MIT


necal = ["06015", "06093", "06049", "06023", "06105",
    "06089", "06035"]

us                  = get_geo_pop(Census.postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])

const slope_geoids  = get_slope_geoids().geoid

or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∉ slope_geoids ||
                                x ∈ necal))

wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∉ slope_geoids))

ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∈ necal && x ∉ slope_geoids))

df = vcat(wa,or,ca)
setup_r_environment()
breaks              = rcopy(get_breaks(df,5))
df.pop_bins         = my_cut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms     = parse_geoms(df)

dest = "+proj=aea +lat_0=43.1 +lon_0=-121.5 +lat_1=38.6 +lat_2=47.6 +datum=NAD83 +units=m +no_defs"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Pacifica", dest, fig)
# Display the figure

display(fig)
