# SPDX-License-Identifier: MIT

using Census
using Census.GreatLakes

rejig       = copy(Census.metropolis)
regig       = push!(rejig,"CT","PA")
df          = get_geo_pop(regig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)
take_from_md   = ["24023","24001","24043"]
metro_to_concordia = ["36019","36031"]
concordia_to_metro = ["09160","09190"]
keep_va     = ["51131","51103","51133","51099",
    "51159","51630","51179","51153",
    "51683","51685","51059","51600",
    "51510","51107","51043","51840",
    "51069","51013","51001","51013",
    "51193","51061"]

# Use GreatLakes constants for filtering
df          = filter(:geoid  => x -> x ∉ take_from_md, df)
df          = filter(:geoid  => x -> x ∉ metro_to_concordia, df)
df          = filter(:geoid  => x -> x ∉ GreatLakes.METRO_TO_GREAT_LAKES_GEOID_LIST, df)
df          = filter(:geoid  => x -> x ∉ setdiff(get_geo_pop(["CT"]).geoid, concordia_to_metro), df)
df          = filter(:geoid  => x -> x ∉ setdiff(get_geo_pop(["VA"]).geoid, keep_va), df)
df          = filter(:geoid  => x -> x ∉ GreatLakes.GREAT_LAKES_PA_GEOID_LIST, df)

dest = "+proj=aea +lat_0=39.95 +lon_0=-75.16 +lat_1=37 +lat_2=43 +datum=NAD83 +units=m +no_defs"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Metropolis", dest, fig)
# Display the figure
display(fig)