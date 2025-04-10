# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

us = init_census_data()

tx          = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ EASTERN_GEOIDS))

ar          = subset(us, :stusps => ByRow(==("AR")))
ar = subset(ar, :geoid => ByRow(x -> x ∈ ARKANSAS_BASIN_AR))

la          = subset(us, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∈ EXCLUDE_FROM_LA_GEOIDS))

ok          = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ EASTERN_GEOIDS))

ks          = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∉ WESTERN_GEOIDS && 
                                     x ∈ SOUTHERN_KANSAS_GEOIDS))

df          = vcat(tx,ok,ar,la,ks)

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
                        
dest = CRS_STRINGS["lonestar"]

map_title = "The Lonestar Republic"
# Create figure
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



# Display the figure

display(fig)

# Store the geoids for later use
# set_nation_state_geoids(map_title, df.geoid)






