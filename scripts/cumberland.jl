# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

ohio_basin_dixie = GeoIDs.get_geoid_set("ohio_basin_dixie")
great_lakes = GeoIDs.get_geoid_set("great_lakes")
gl_oh = GeoIDs.get_geoid_set("gl_oh")
pa_ny = GeoIDs.get_geoid_set("ohio_basin_pa_ny")
ohio_basin_il = GeoIDs.get_geoid_set("ohio_basin_il")
ms_basin_tn = GeoIDs.get_geoid_set("ms_basin_tn")
ms_basin_ky = GeoIDs.get_geoid_set("ms_basin_ky")

al = filter(:stusps  => x -> x == "AL",us)
al = subset(al, :geoid => ByRow(x -> x ∈ ohio_basin_dixie))

ms = filter(:stusps  => x -> x == "MS",us)
ms = subset(ms, :geoid => ByRow(x -> x ∈ ohio_basin_dixie))

ga = filter(:stusps  => x -> x == "GA",us)
ga = subset(ga, :geoid => ByRow(x -> x ∈ ohio_basin_dixie))

nc = filter(:stusps  => x -> x == "NC",us)
nc = subset(nc, :geoid => ByRow(x -> x ∈ ohio_basin_dixie))

va = filter(:stusps  => x -> x == "VA",us)
va = subset(va, :geoid => ByRow(x -> x ∈ ohio_basin_dixie))

pa = filter(:stusps  => x -> x == "PA",us)
pa = subset(pa, :geoid => ByRow(x -> x ∈ pa_ny && x ∉ great_lakes))

ind = filter(:stusps  => x -> x == "IN",us)
ind = subset(ind, :geoid => ByRow(x -> x ∉ great_lakes))

il = filter(:stusps  => x -> x == "IL",us)
il = subset(il, :geoid => ByRow(x -> x ∈ ohio_basin_il))

ky = filter(:stusps  => x -> x == "KY",us)
ky = subset(ky, :geoid => ByRow(x -> x ∉ ms_basin_ky))

oh = filter(:stusps  => x -> x == "OH",us)
oh = subset(oh, :geoid => ByRow(x -> x ∉ gl_oh))

ny = filter(:stusps  => x -> x == "NY",us)
ny = subset(ny, :geoid => ByRow(x -> x ∈ pa_ny || x ∉ great_lakes))    

tn = filter(:stusps  => x -> x == "TN",us)
tn = subset(tn, :geoid => ByRow(x -> x ∉ ms_basin_tn))

wv = filter(:stusps  => x -> x == "WV",us)

df = vcat(oh,pa,ind,il,ky,va,al,ms,ga,nc,tn,wv)

# Get binned data for each classification method using Breakers
bin_indices = Breakers.get_bin_indices(df.pop, 7)

# You can change this to any method: "fisher", "kmeans", "quantile", "equal"
selected_method = "fisher"
df.bin_values = bin_indices[selected_method]


# Define projection

dest = Census.CRS_STRINGS["gateway"]

map_title = "Factoria"
fig = Figure(size=(3200, 2400), fontsize=24)
Census.map_poly(df, map_title, dest, fig)
# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "img"))
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
