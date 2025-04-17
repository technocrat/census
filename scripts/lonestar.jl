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
central_west_counties = GeoIDs.get_geoid_set("west_of_100th")
eastern_geoids = GeoIDs.get_geoid_set("eastern_geoids")
southern_missouri = GeoIDs.get_geoid_set("southern_missouri")
eastern_la = GeoIDs.get_geoid_set("eastern_la")

tx             = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ eastern_geoids))

ar          = subset(us, :stusps => ByRow(==("AR")))
mo          = subset(us, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∈ southern_missouri))   

la          = subset(us, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∉ eastern_la))

ok          = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ eastern_geoids))

kansas_south = GeoIDs.get_geoid_set("ks_south")
ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ kansas_south))

df          = vcat(tx,ok,ar,la,ks,mo)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
                        
dest = CRS_STRINGS["lonestar"]

map_title = "The Lonestar Republic"
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

