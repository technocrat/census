# SPDX-License-Identifier: MIT
# SCRIPT 

using Census

us = init_census_data()

# Filter regions using Great Lakes constants
ny = subset(us, :geoid => ByRow(x -> x ∈ METRO_TO_GREAT_LAKES_GEOID_LIST))
pa = subset(us, :geoid => ByRow(x -> x ∈ GREAT_LAKES_PA_GEOID_LIST))
oh = subset(us, :stusps => ByRow(x -> x == "OH"))
oh = subset(oh, :geoid => ByRow(x -> x ∈ GREAT_LAKES_OH_GEOID_LIST))
ind = subset(us, :stusps => ByRow(x -> x == "IN"))
ind = subset(ind, :geoid => ByRow(x -> x ∈ GREAT_LAKES_IN_GEOID_LIST))
mi = subset(us, :stusps => ByRow(x -> x == "MI"))
mi = subset(mi, :geoid => ByRow(x -> x ∉ MICHIGAN_PENINSULA_GEOID_LIST))

# Combine all regions
df = vcat(ny, pa, oh, ind, mi)

breaks          = rcopy(get_breaks(df.pop))  # Pass population vector directly
df.pop_bins     = customcut(df.pop, breaks[:kmeans][:brks])

map_title = "Erie"
# Set up projection for Erie region
dest = CRS_STRINGS["erie"]
# Create and display figure
fig = Figure(size=(2400, 1600), fontsize=22)
map_poly(df, "Erie", dest, fig)
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

# Display the figure
display(fig)

# Store the geoids for later use
#set_nation_state_geoids("Elysia", df.geoid)``

