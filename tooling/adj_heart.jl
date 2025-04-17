# SPDX-License-Identifier: MIT
# SCRIPT

# Get the project root directory for reliable path resolution
project_root = dirname(dirname(@__FILE__))

# Load the comprehensive preamble that handles visualization
# the_path will find preamble.jl in the scripts directory
the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

# Directly import CRS_STRINGS from its source file using project_root
include(joinpath("src", "core", "crs.jl"))
#img_dir = joinpath("..",census_path,"img")
hudson_bay_drainage_geoids = GeoIDs.get_geoid_set("hudson_bay_drainage")
ohio_basin_il_geoids = GeoIDs.get_geoid_set("ohio_basin_il")
missouri_river_basin_geoids = GeoIDs.get_geoid_set("missouri_river_basin")
miss_river_basin_sd = GeoIDs.get_geoid_set("miss_river_basin_sd")
michigan_peninsula_geoid_list = GeoIDs.get_geoid_set("michigan_peninsula")
ms_basin_mo = GeoIDs.get_geoid_set("ms_basin_mo")
mo_basin_mn = GeoIDs.get_geoid_set("mo_basin_mn")

mn = filter(:stusps  => x -> x == "MN",us)
mn = subset(mn, :geoid => ByRow(x -> x ∉ hudson_bay_drainage_geoids && x ∉ mo_basin_mn))

il = filter(:stusps  => x -> x == "IL",us)
il = subset(il, :geoid => ByRow(x -> x ∉ ohio_basin_il_geoids))

ia = filter(:stusps  => x -> x == "IA",us)
ia = subset(ia, :geoid => ByRow(x -> x ∉ missouri_river_basin_geoids))

mo = filter(:stusps  => x -> x == "MO",us)
mo = subset(mo, :geoid => ByRow(x -> x ∈ ms_basin_mo))

sd = filter(:stusps  => x -> x == "SD",us)
sd = subset(sd, :geoid => ByRow(x -> x ∈ miss_river_basin_sd))

mi = filter(:stusps  => x -> x == "MI",us)
mi = subset(mi, :geoid => ByRow(x -> x ∈ michigan_peninsula_geoid_list))

wi = filter(:stusps  => x -> x == "WI",us)

df = vcat(mn,il,mo,ia,sd,wi,mi)

# Get binned data for each classification method using Breakers
bin_indices = Breakers.get_bin_indices(df.pop, 7)

# You can change this to any method: "fisher", "kmeans", "quantile", "equal"
selected_method = "fisher"
df.bin_values = bin_indices[selected_method]

dest =  CRS_STRINGS["heartland"]

map_title = "Heartlandia"
fig = Figure(size=(3200, 2400), fontsize=24)
Census.map_poly(df, map_title, dest, fig)

@info "Saving to directory: $img_dir"
saved_path = Census.save_plot(fig, map_title)
@info "Plot saved to: $saved_path"


# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end


display(fig)
# Store the geoids for later use
set_nation_state_geoids(map_title, df.geoid)
