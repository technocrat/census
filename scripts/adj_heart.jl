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

mn = filter(:stusps  => x -> x == "MN",us)
mn = subset(mn, :geoid => ByRow(x -> x ∉ HUDSON_BAY_DRAINAGE_GEOIDS))

il = filter(:stusps  => x -> x == "IL",us)
il = subset(il, :geoid => ByRow(x -> x ∉ OHIO_BASIN_IL_GEOIDS))

ia = filter(:stusps  => x -> x == "IA",us)
ia = subset(ia, :geoid => ByRow(x -> x ∉ MISSOURI_RIVER_BASIN_GEOIDS))

mo = filter(:stusps  => x -> x == "MO",us)
mo = subset(mo, :geoid => ByRow(x -> x ∉ MISSOURI_RIVER_BASIN_GEOIDS))

sd = filter(:stusps  => x -> x == "SD",us)
sd = subset(sd, :geoid => ByRow(x -> x ∈ MISS_RIVER_BASIN_SD))

mi = filter(:stusps  => x -> x == "MI",us)
mi = subset(mi, :geoid => ByRow(x -> x ∈ MICHIGAN_PENINSULA_GEOID_LIST))

wi = filter(:stusps  => x -> x == "WI",us)

df = vcat(mn,il,mo,ia,sd,wi,mi)

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
dest = CRS_STRINGS["heartland"]

map_title = "Heartlandia"
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
#set_nation_state_geoids(map_title, df.geoid)
