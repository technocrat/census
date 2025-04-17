# SPDX-License-Identifier: MIT
# SCRIPT TEMPLATE

# Load required packages
using Census
using DataFrames
using DataFramesMeta
using CairoMakie

# The Census module correctly defines the appropriate IMG_DIR at the project root
println("Working with Census module")
println("Using Census.IMG_DIR: $(Census.IMG_DIR)")

# Set example data 
nation_name = "Example"
map_title = titlecase(nation_name)

# Create a simple example plot
fig = Figure(size=(1600, 1200), fontsize=18)
ax = Axis(fig[1, 1], title="$map_title Visualization")

# Example plot code - in a real script you would have actual data and plots
CairoMakie.text!(ax, 0.5, 0.5, text="Example Plot\nfor $map_title", 
              align=(:center, :center), fontsize=24)

# Save the figure using the standardized method
# This will ensure it always goes to the correct img/ directory at the project root
saved_path = Census.save_plot_to_img_dir(fig, map_title)
println("Plot saved to: $saved_path")

# Display the figure
display(fig)

println("Script completed successfully!") 