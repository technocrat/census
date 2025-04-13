# SPDX-License-Identifier: MIT
# SCRIPT - Lonestar Republic with multithreading/GPU acceleration

using Pkg
Pkg.activate("/Users/technocrat/projects/Census.jl")    
# Add Census.jl setup
include("/Users/technocrat/projects/Census.jl/startup_census.jl")

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta, CairoMakie, Breakers, GeoIDs



us = init_census_data()

ca          = subset(us, :stusps => ByRow(==("CA")))
or          = subset(us, :stusps => ByRow(==("OR")))
wa          = subset(us, :stusps => ByRow(==("WA")))

east_of_cascades = GeoIDs.get_geoid_set("east_of_cascades")
northern_rural_california = GeoIDs.get_geoid_set("northern_rural_california")
east_of_sierras = GeoIDs.get_geoid_set("east_of_sierras")
socal = GeoIDs.get_geoid_set("socal")

ca = subset(ca, :geoid => ByRow(x -> x ∈ northern_rural_california &&
                                  x ∉ east_of_sierras &&
                                  x ∉ socal))
or = subset(or, :geoid => ByRow(x -> x ∉ east_of_cascades))
wa = subset(wa, :geoid => ByRow(x -> x ∉ east_of_cascades))


df          = vcat(ca,or,wa)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
                        
dest = CRS_STRINGS["pacific_coast"]

map_title = "Pacifica"
fig = Figure(size=(2400, 1200), fontsize=24)

Census.map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "img"))
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
# set_nation_state_geoids(map_title, df.geoid)











