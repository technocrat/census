# SPDX-License-Identifier: MIT
# SCRIPT
using Census

us = init_census_data()

# Get Florida counties
df = subset(us, :stusps => ByRow(==("FL")))
df = subset(df, :geoid => ByRow(x -> x ∈ FLORIDA_GEOIDS))

# Stereographic projection centered on the Keys
dest = CRS_STRINGS["florida_south"]
# Create figure with larger size for better visibility
fig = Figure(size=(3200, 2400), fontsize=24)

map_title = "Elysia"
map_poly_with_projection(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "img"))
@info "Saving to directory: $img_dir"
saved_path = save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end

# Store the geoids for later use
#set_nation_state_geoids("Elysia", df.geoid)
