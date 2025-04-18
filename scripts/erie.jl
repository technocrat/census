# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

# Get individual regions

great_lakes = GeoIDs.get_geoid_set("great_lakes")
gl_oh = GeoIDs.get_geoid_set("gl_oh")
michigan_peninsula = GeoIDs.get_geoid_set("michigan_peninsula")

ny = subset(us, :stusps => ByRow(x -> x == "NY"))
pa = subset(us, :stusps => ByRow(x -> x == "PA"))
oh = subset(us, :stusps => ByRow(x -> x == "OH"))
ind = subset(us, :stusps => ByRow(x -> x == "IN"))
mi = subset(us, :stusps => ByRow(x -> x == "MI"))

ny = subset(ny, :geoid => ByRow(x -> x ∈ great_lakes))
pa = subset(pa, :geoid => ByRow(x -> x ∈ great_lakes))
oh = subset(oh, :geoid => ByRow(x -> x ∈ gl_oh))
ind = subset(ind, :geoid => ByRow(x -> x ∈ great_lakes))
mi = subset(mi, :geoid => ByRow(x -> x ∉ michigan_peninsula))

# Combine all regions
df = vcat(ny, pa, oh, ind, mi)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
                        
dest = Census.CRS_STRINGS["erie"]


map_title = "Erie"
fig = Figure(size=(2400, 1200), fontsize=24)

Census.map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath("..", @__DIR__, "img"))
@info "Saving to directory: $img_dir"
saved_path = Census.save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end


display(fig)

# Store the geoids for later use - Using the refactored set_nation_state_geoids function
try
    Census.set_nation_state_geoids(map_title, df.geoid)
catch e
    @error "Error storing geoids in database:" exception=(e, catch_backtrace())
end
if @isdefined(set_nation_state_geoids)
    Census.set_nation_state_geoids(map_title, df.geoid)
    @info "Saved $(length(df.geoid)) county geoids to database under nation state '$(map_title)'"
end