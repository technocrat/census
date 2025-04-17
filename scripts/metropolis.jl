# SPDX-License-Identifier: MIT
# SCRIPT

# Get the project root directory for reliable path resolution
project_root = dirname(dirname(@__FILE__))

# Load the comprehensive preamble that handles visualization
# the_path will find preamble.jl in the scripts directory
the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

# Directly import CRS_STRINGS from its source file using project_root
include(joinpath("src", "core", "crs.jl"))

great_lakes = GeoIDs.get_geoid_set("great_lakes")
oh_basin_pa_ny = GeoIDs.get_geoid_set("ohio_basin_pa_ny")
northern_va = GeoIDs.get_geoid_set("northern_va")

ny = subset(us, :stusps => ByRow(==("NY")))
ny = subset(ny, :county => ByRow(x -> x != "Clinton" && 
                                 x != "Essex"))
ny = subset(ny, :geoid => ByRow(x -> x ∉ oh_basin_pa_ny))
ny = subset(ny, :geoid => ByRow(x -> x ∉ great_lakes))
nj = subset(us, :stusps => ByRow(==("NJ")))

ct = subset(us, :stusps => ByRow(==("CT")))
ct = subset(ct, :county => ByRow(x -> x == "Northwest Hills" || 
                                 x == "Western Connecticut"))

nj = subset(us, :stusps => ByRow(==("NJ")))

pa = subset(us, :stusps => ByRow(==("PA")))
pa = subset(pa, :geoid => ByRow(x -> x ∉ great_lakes &&
                                x ∉ oh_basin_pa_ny))

dc = subset(us, :stusps => ByRow(==("DC")))

md = subset(us, :stusps => ByRow(==("MD")))

de = subset(us, :stusps => ByRow(==("DE")))

va = subset(us, :stusps => ByRow(==("VA")))
va = subset(va, :geoid => ByRow(x -> x ∈ northern_va))

df = vcat(ny, ct, nj, pa, md, de, va, dc)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]

# Define projection

dest = CRS_STRINGS["metropolis"]

map_title = "Metropolis"
fig = Figure(size=(2400, 1200), fontsize=24)

Census.map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
# Use the exported IMG_DIR from Census
img_dir = Census.IMG_DIR
@info "Saving to directory: $img_dir"
saved_path = Census.save_plot(fig, map_title, directory=img_dir)
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
Census.set_nation_state_geoids(map_title, df.geoid)

