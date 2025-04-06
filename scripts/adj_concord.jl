# SPDX-License-Identifier: MIT
# Script to adjust the Concordia dataset by adding 
# Clinton and Essex counties in New York, 
# and ceding portions of northern Maine to Canada 
# plus moving greater Bridgeport to Metropolis

using Census

us = init_census_data()

ct = subset(us, :stusps => ByRow(==("CT")))
me = subset(us, :stusps => ByRow(==("ME")))
ma = subset(us, :stusps => ByRow(==("MA")))
nh = subset(us, :stusps => ByRow(==("NH")))
ri = subset(us, :stusps => ByRow(==("RI")))
vt = subset(us, :stusps => ByRow(==("VT")))
ny = subset(us, :stusps => ByRow(==("NY")))


add_to_concordia = ["36019","36031"]

take_from_concordia = ["23003","20029","09160","09190"]
ma          = filter(:geoid  => x -> x ∉ take_from_concordia,ma)
me          = filter(:geoid  => x -> x ∉ take_from_concordia,me)
take_from_ny  = setdiff(get_geo_pop(["NY"]).geoid,add_to_concordia)
ny          = filter(:geoid  => x -> x ∉ take_from_ny,ny)
addns       = filter(:geoid  => x -> x ∈ add_to_concordia,ny)
ma          = vcat(ma,addns)
ct          = subset(ct, :geoid => ByRow(x -> x ∉ take_from_concordia))
df          = vcat(ct,me, ma,nh,ri,vt,ny)

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])

map_title = "Concordia"
dest = CRS_STRINGS["concordia"]
fig = Figure(size=(3200, 2400), fontsize=24)
map_poly(df, map_title, dest, fig)
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
