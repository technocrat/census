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

al = filter(:stusps  => x -> x == "AL",us)
al = subset(al, :geoid => ByRow(x -> x ∈ OHIO_BASIN_AL_GEOIDS))

ms = filter(:stusps  => x -> x == "MS",us)
ms = subset(ms, :geoid => ByRow(x -> x ∈ OHIO_BASIN_MS_GEOIDS))

ga = filter(:stusps  => x -> x == "GA",us)
ga = subset(ga, :geoid => ByRow(x -> x ∈ OHIO_BASIN_GA_GEOIDS))

nc = filter(:stusps  => x -> x == "NC",us)
nc = subset(nc, :geoid => ByRow(x -> x ∈ OHIO_BASIN_NC_GEOIDS))

va = filter(:stusps  => x -> x == "VA",us)
va = subset(va, :geoid => ByRow(x -> x ∈ OHIO_BASIN_VA_GEOIDS))

pa = filter(:stusps  => x -> x == "PA",us)
pa = subset(pa, :geoid => ByRow(x -> x ∈ OHIO_BASIN_PA_GEOIDS))

in = filter(:stusps  => x -> x == "IN",us)
in = subset(in, :geoid => ByRow(x -> x ∉ GREAT_LAKES_IN_GEOID_LIST))

il = filter(:stusps  => x -> x == "IL",us)
il = subset(il, :geoid => ByRow(x -> x ∈ OHIO_BASIN_IL_GEOIDS))

ky = filter(:stusps  => x -> x == "KY",us)
ky = subset(ky, :geoid => ByRow(x -> x ∈ OHIO_BASIN_KY_GEOIDS))

oh = filter(:stusps  => x -> x == "OH",us)
oh = subset(oh, :geoid => ByRow(x -> x ∉ GREAT_LAKES_OH_GEOID_LIST))

ny = filter(:stusps  => x -> x == "NY",us)
ny = subset(ny, :geoid => ByRow(x -> x ∈ OHIO_BASIN_NY_GEOIDS))    

tn = filter(:stusps  => x -> x == "TN",us)
tn = subset(tn, :geoid => ByRow(x -> x ∈ OHIO_BASIN_TN_GEOIDS))

wv = filter(:stusps  => x -> x == "WV",us)

df = vcat(oh,pa,in,il,ky,md,va,al,ms,ga,nc,tn,wv)

breaks      = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])


# Define projection

dest = CRS_STRINGS["gateway"]

map_title = "Factoria"
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
