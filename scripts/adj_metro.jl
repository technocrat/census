# SPDX-License-Identifier: MIT

rejig       = copy(Census.metropolis)
regig       = push!(rejig,"CT","PA")
df          = get_geo_pop(rejig)
rename!(df, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks      = rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)
take_from_md   = ["24023","24001","24043"]
metro_to_gl    = ["23003", "23029", "36009",
        "36011", "36013", "36014", "36019", "36029",
        "36031", "36033", "36037", "36037", "36037",
        "36041", "36043", "36045", "36049", "36051",
        "36055", "36063", "36065", "36067", "36069",
        "36073", "36075", "36089", "36099", "36117",
        "36121"]
metro_to_concordia = ["36019","36031"]
concordia_to_metro = ["09160","09190"]
keep_va     = ["51131","51103","51133","51099",
    "51159","51630","51179","51153",
    "51683","51685","51059","51600",
    "51510","51107","51043","51840",
    "51069","51013","51001","51013",
    "51193","51061"]

toss_pa = ["36003", "36009", "36011",
    "36013", "36014", "36015", "36019", "36019", "36029",
    "36031", "36031", "36033", "36037", "36037", "36037",
    "36041", "36043", "36045", "36049", "36051", "36055",
    "36063", "36065", "36067", "36069", "36073", "36075",
    "36089", "36097", "36099", "36101", "36107", "36109",
    "36117", "36121", "36123", "42003", "42005", "42007",
    "42009", "42013", "42015", "42019", "42021", "42023",
    "42027", "42031", "42033", "42035", "42037", "42039",
    "42047", "42049", "42051", "42053", "42057", "42059",
    "42061", "42063", "42065", "42067", "42073", "42081",
    "42083", "42085", "42087", "42093", "42097", "42099",
    "42104", "42105", "42109", "42111", "42113", "42117",
    "42119", "42121", "42123", "42125", "42129", "43031",
    "43063"]
toss_va     = setdiff(get_geo_pop(["VA"]).geoid,keep_va)
toss_ct     = setdiff(get_geo_pop(["CT"]).geoid,concordia_to_metro)
keep_ny     = subset(get_geo_pop(["NY"]), :geoid => ByRow(x -> x ∉ metro_to_concordia || x ∉ metro_to_gl))
toss_ny     = setdiff(get_geo_pop(["NY"]).geoid,keep_ny.geoid)
df          = filter(:geoid  => x -> x ∉ take_from_md,df)
df          = filter(:geoid  => x -> x ∉ toss_ny,df)
df          = filter(:geoid  => x -> x ∉ metro_to_gl,df)
df          = filter(:geoid  => x -> x ∉ toss_ct,df)
df          = filter(:geoid  => x -> x ∉ toss_va,df)
df          = filter(:geoid  => x -> x ∉ toss_pa,df)

dest = "+proj=aea +lat_0=39.95 +lon_0=-75.16 +lat_1=37 +lat_2=43 +datum=NAD83 +units=m +no_defs"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Metropolis", dest, fig)
# Display the figure

display(fig)