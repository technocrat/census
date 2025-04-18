# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

# Get individual regions
# Get Florida counties
florida = GeoIDs.get_geoid_set("florida")
df = subset(us, :stusps => ByRow(==("FL")))
df = subset(df, :geoid => ByRow(x -> x ∈ florida))

# Stereographic projection centered on the Keys

selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]

dest = Census.CRS_STRINGS["florida_south"]
# Create figure with larger size for better visibility
fig = Figure(size=(3200, 2400), fontsize=24)

map_title = "Elysia"
Census.map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "img"))
@info "Saving to directory: $img_dir"
saved_path = Census.save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end

# Store the geoids for later use
Census.set_nation_state_geoids("Elysia", df.geoid)

display(fig)