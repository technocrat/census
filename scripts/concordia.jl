# SPDX-License-Identifier: MIT
    # Script to adjust the Concordia dataset by adding 
    # Clinton and Essex counties in New York, 
    # and ceding portions of northern Maine to Canada 
    # plus moving greater Bridgeport to Metropolis
    # SCRIPT

using Census, DataFrames, DataFramesMeta, CairoMakie, Breakers
using StatsBase, Dates, CSV

# Continue with script
us = init_census_data()

ct = subset(us, :stusps => ByRow(==("CT")))
me = subset(us, :stusps => ByRow(==("ME")))
ma = subset(us, :stusps => ByRow(==("MA")))
nh = subset(us, :stusps => ByRow(==("NH")))
ri = subset(us, :stusps => ByRow(==("RI")))
vt = subset(us, :stusps => ByRow(==("VT")))
ny = subset(us, :stusps => ByRow(==("NY")))

add_to_concordia = ["36019","36031"]
take_from_concordia = ["09160","09190"]

me          = filter(:geoid  => x -> x ∉ take_from_concordia,me)
take_from_ny  = setdiff(ny.geoid,add_to_concordia)
ny          = filter(:geoid  => x -> x ∉ take_from_ny,ny)
addns       = filter(:geoid  => x -> x ∈ add_to_concordia,ny)
ny          = vcat(ny,addns)
ct          = subset(ct, :geoid => ByRow(x -> x ∉ take_from_concordia))
df          = vcat(ct,me, ma,nh,ri,vt,ny)

# Get binned data for each classification method using Breakers
bin_indices = Breakers.get_bin_indices(df.pop, 7)

selected_method = "fisher"
df.bin_values = bin_indices[selected_method]

map_title = "Concordia"
# Use the CRS_STRINGS constant exported from Census module
dest = Census.CRS_STRINGS["concordia"]
fig = CairoMakie.Figure(size=(3200, 2400), fontsize=24)
map_poly(df, map_title, dest, fig)
img_dir = abspath(joinpath(@__DIR__, "..", "img"))
mkpath(img_dir)  # Ensure directory exists
@info "Saving to directory: $img_dir"

# Use CairoMakie.save directly
timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
safe_title = replace(map_title, r"[^a-zA-Z0-9]" => "_")
filename = joinpath(img_dir, "$(safe_title)_$(timestamp).png")
CairoMakie.save(filename, fig, px_per_unit=2)
@info "Plot saved to: $filename"

# Verify file exists
if isfile(filename)
    @info "File successfully created at: $filename"
else
    @error "Failed to create file at: $filename"
end

display(fig)
# Store the geoids for later use
Census.set_nation_state_geoids(map_title, df.geoid)
@info "Saved $(length(df.geoid)) county geoids to database under nation state '$(map_title)'"
