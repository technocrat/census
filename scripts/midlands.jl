# SPDX-License-Identifier: MIT
using Census

us = init_census_data()

mn = subset(us, :stusps => ByRow(==("MN")))
mn = subset(mn, :geoid => ByRow(x -> x ∈ MISSOURI_BASIN_MN_GEOIDS))

ia = subset(us, :stusps => ByRow(==("IA")))
ia = subset(ia, :geoid => ByRow(x -> x ∈ MISSOURI_BASIN_IA_GEOIDS))

mo = subset(us, :stusps => ByRow(==("MO")))
mo = subset(mo, :geoid => ByRow(x -> x ∈ MISSOURI_RIVER_BASIN_GEOIDS))  

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∉ WESTERN_GEOIDS && x ∉ SOUTHERN_KANSAS_GEOIDS))

ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∉ WESTERN_GEOIDS))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∉ WESTERN_GEOIDS && x ∉ HUDSON_BAY_DRAINAGE_GEOIDS))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∉ WESTERN_GEOIDS && x ∉ MISS_RIVER_BASIN_SD))

df = vcat(ia,mo,ks,ne,nd,sd) 

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])

dest = CRS_STRINGS["prairie"]

map_title = "Midlands"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

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
# Display the figure

display(fig)


# Store the geoids for later use
set_nation_state_geoids(map_title, df.geoid)

