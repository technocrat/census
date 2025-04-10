# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

us = init_census_data()

ny = subset(us, :stusps => ByRow(==("NY")))`
ny = subset(ny, :county => ==("New York") || :county == "Kings")

ct = subset(us, :stusps => ByRow(==("CT")))
ct = subset(ct, :county => ==("Northwest Hills") || :county == "Western Connecticut")

nj = subset(us, :stusps => ==("NJ"))

pa = subset(us, :stusps => ==("PA"))

md = subset(us, :state => ==("MD"))

va = subset(us, :state => ==("VA"))

de = subset(us, :state => ==("DE"))



# Convert WKT strings to geometric objects


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



breaks          = rcopy(get_breaks(df.pop))  # Pass population vector directly
df.pop_bins     = customcut(df.pop, breaks[:kmeans][:brks])

# Define projection

dest = CRS_STRINGS["metropolis"]

map_title = "Metropolis"
fig = Figure(size=(3200, 2400), fontsize=24)
map_poly(df, map_title, dest, fig)
# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "Census", "img"))
@info "Saving to directory: $img_dir"
saved_path = save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end


display(fig)
# Store the geoids for later use
#set_nation_state_geoids(map_title, df.geoid)
