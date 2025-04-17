# SPDX-License-Identifier: MIT
# Script to test the SOCAL_GEOIDS constant
# SCRIPT

# Load necessary packages
using Census, DataFrames, DataFramesMeta, CairoMakie, Breakers
using StatsBase, Dates

# Initialize census data
us = init_census_data()

# Filter for Southern California counties using the SOCAL_GEOIDS constant
df = subset(us, :geoid => ByRow(id -> id ∈ SOCAL_GEOIDS))

# Get binned data for each classification method using Breakers
bin_indices = Breakers.get_bin_indices(df.pop, 7)

# For mapping, use the kmeans method
selected_method = "kmeans"
df.bin_values = bin_indices[selected_method]

# Set up map parameters
map_title = "Southern California"
# Use the appropriate CRS string for this region
dest = CRS_STRINGS["pacific_coast"]

# Create figure and map
fig = CairoMakie.Figure(size=(3200, 2400), fontsize=24)
map_poly(df, map_title, dest, fig)

# Save the map
img_dir = abspath(joinpath(@__DIR__, "..", "img"))
mkpath(img_dir)  # Ensure directory exists
@info "Saving to directory: $img_dir"

# Save with timestamp to prevent overwrites
timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
safe_title = replace(map_title, r"[^a-zA-Z0-9]" => "_")
filename = joinpath(img_dir, "$(safe_title)_$(timestamp).png")
CairoMakie.save(filename, fig, px_per_unit=2)

# Verify file exists
if isfile(filename)
    @info "File successfully created at: $filename"
else
    @error "Failed to create file at: $filename"
end

# Display the figure
display(fig)

# Print information about the dataset
@info "Southern California includes $(length(df.geoid)) counties"
@info "Total population: $(sum(df.pop))"

# Store the geoids for later use if needed
# set_nation_state_geoids("socal", df.geoid) 