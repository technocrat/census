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

# Filter for California counties not in SoCal or east of Sierras
df = subset(us, :stusps => ByRow(==("CA")))
df = subset(df, :geoid => ByRow(x -> x ∈ SOCAL_GEOIDS))
breaks          = rcopy(get_breaks(df.pop))  # Pass population vector directly
df.pop_bins     = customcut(df.pop, breaks[:kmeans][:brks])

# Define projection

dest = CRS_STRINGS["pacific_coast"]

map_title = "Southland"
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
# set_nation_state_geoids(map_title, df.geoid)
