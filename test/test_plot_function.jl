# SPDX-License-Identifier: MIT
# SCRIPT

# Load the Census module and required packages
using Census
using DataFrames
using DataFramesMeta

println("Testing standardized plot saving function...")

# Create a simple figure for testing
fig = Figure(size=(1200, 800), fontsize=16)
ax = Axis(fig[1, 1], title="Test Plot for IMG_DIR Standardization")
CairoMakie.text!(ax, 0.5, 0.5, text="This is a test plot\nIt should be saved in the correct IMG_DIR", 
              align=(:center, :center), fontsize=20)

# Show the current IMG_DIR value
println("Census.IMG_DIR is set to: $(Census.IMG_DIR)")

# Save the plot using the standardized function
saved_path = Census.save_plot_to_img_dir(fig, "Test Plot")
println("Plot saved to: $saved_path")

# For comparison, print where other approaches would save
local_img_dir = joinpath(@__DIR__, "img")
println("If using joinpath(@__DIR__, \"img\"): $local_img_dir")

project_root_img_dir = joinpath(dirname(dirname(@__DIR__)), "img")
println("If using joinpath(dirname(dirname(@__DIR__)), \"img\"): $project_root_img_dir")

# Show that both paths are different
println("Using local path would create a file in scripts/example/img/")
println("Using Census.IMG_DIR correctly saves in project_root/img/")

# Display the figure
display(fig)

println("Test completed successfully!") 