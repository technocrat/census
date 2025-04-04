# SPDX-License-Identifier: MIT
using Census

using Census

us = init_census_data()

nm = subset(us, :stusps => ByRow(==("NM")))

co = subset(us, :stusps => ByRow(==("CO")))
co = subset(co, :geoid => ByRow(x -> x ∉ COLORADO_BASIN_GEOIDS))

mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ MISSOURI_RIVER_BASIN_GEOIDS ||
    x ∉  EAST_OF_UTAH_GEOIDS))

id = subset(us, :stusps => ByRow(==("ID")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∉ MISSOURI_RIVER_BASIN_GEOIDS))

nv = subset(us, :stusps => ByRow(==("NV")))
nv = subset(nv, :geoid => ByRow(x -> x ∉ COLORADO_BASIN_GEOIDS))
    
ut = subset(us, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ ["49019", "49037"]))
    
or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ EAST_OF_CASCADE_GEOIDS))

ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∈ EAST_OF_SIERRAS_GEOIDS &&
                                x ∉ SOCAL_GEOIDS))
    
wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∈ EAST_OF_CASCADE_GEOIDS))

df = vcat(id, nv, or, wa, ut, ca)


breaks = rcopy(get_breaks(us, 5))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])

dest = CRS_STRINGS["powell"]
map_title = "Deseret"
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

