# SPDX-License-Identifier: MIT

using Census

# Initialize census data
us = init_census_data()


al = subset(us, :stusps => ByRow(==("AL")))
al = subset(al, :geoid => ByRow(x -> x ∉ OHIO_BASIN_AL_GEOIDS))

fl = subset(us, :stusps => ByRow(==("FL")))
fl = subset(fl, :geoid => ByRow(x -> x ∉ FLORIDA_GEOIDS))

ga = subset(us, :stusps => ByRow(==("GA")))
ga = subset(ga, :geoid => ByRow(x -> x ∉ OHIO_BASIN_GA_GEOIDS))

la = subset(us, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∈ MS_EAST_LA_GEOIDS))

ms = subset(us, :stusps => ByRow(==("MS")))
ms = subset(ms, :geoid => ByRow(x -> x ∉ OHIO_BASIN_MS_GEOIDS))

nc = subset(us, :stusps => ByRow(==("NC")))
nc = subset(nc, :geoid => ByRow(x -> x ∉ OHIO_BASIN_NC_GEOIDS))

sc = subset(us, :stusps => ByRow(==("SC")))

va = subset(us, :stusps => ByRow(==("VA")))
va = subset(va, :geoid => ByRow(x -> x ∉ EXCLUDE_FROM_VA))


df = vcat(al,fl,ga,la,ms,nc,sc,va)

breaks          = rcopy(get_breaks(df.pop))  # Pass population vector directly
df.pop_bins     = customcut(df.pop, breaks[:kmeans][:brks])

# Define projection

dest = CRS_STRINGS["delta"]

map_title = "New Dixie"
fig = Figure(size=(3200, 2400), fontsize=24)
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


display(fig)
# Store the geoids for later use
# set_nation_state_geoids(map_title, df.geoid)
