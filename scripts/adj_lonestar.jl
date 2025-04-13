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

central_west_counties = GeoIDs.get_geoid_set("west_of_100th")
eastern_geoids = GeoIDs.get_geoid_set("eastern_geoids")
tx          = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ eastern_geoids))

ar          = subset(us, :stusps => ByRow(==("AR")))

eastern_la = GeoIDs.get_geoid_set("eastern_la")
la          = subset(us, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∉ eastern_la))

ok          = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ eastern_geoids))

kansas_south = GeoIDs.get_geoid_set("ks_south")
ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ kansas_south))

df          = vcat(tx,ok,ar,la,ks)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
                        
dest = CRS_STRINGS["lonestar"]

map_title = "The Lonestar Republic"
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

