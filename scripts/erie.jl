# SPDX-License-Identifier: MIT
# SCRIPT 

using Census
using Census.GreatLakes
using RCall

# Get base data
us = get_geo_pop(Census.postals)
rename!(us, [:geoid, :stusps, :county, :geom, :pop])

# Get individual regions
ny = subset(us, :geoid => ByRow(x -> x ∈ GreatLakes.GREAT_LAKES_NY_GEOID_LIST))
pa = subset(us, :geoid => ByRow(x -> x ∈ GreatLakes.GREAT_LAKES_PA_GEOID_LIST))
oh = subset(us, :stusps => ByRow(x -> x == "OH"))
oh = subset(oh, :geoid => ByRow(x -> x ∈ GreatLakes.GREAT_LAKES_OH_GEOID_LIST))
ind = subset(us, :stusps => ByRow(x -> x == "IN"))
ind = subset(ind, :geoid => ByRow(x -> x ∈ GreatLakes.GREAT_LAKES_IN_GEOID_LIST))
mi = subset(us, :stusps => ByRow(x -> x == "MI"))
mi = subset(mi, :geoid => ByRow(x -> x ∉ GreatLakes.MICHIGAN_PENINSULA_GEOID_LIST))

# Combine all regions
df = vcat(ny, pa, oh, ind, mi)

# Get counties west of Iroquois County, IL
exclude_query = """
    WITH Iroquois_lat AS (
        SELECT ST_X(ST_Centroid(geom)) as lat 
        FROM census.counties 
        WHERE name = 'Iroquois' AND stusps = 'IL'
    )
    SELECT geoid
    FROM census.counties c, Iroquois_lat i
    WHERE ST_X(ST_Centroid(c.geom)) < i.lat
    ORDER BY geoid;
"""
exclude_from_erie = execute(exclude_query).geoid
df = filter(:geoid => x -> x ∉ exclude_from_erie, df)

# Prepare for plotting
setup_r_environment()
breaks = rcopy(get_breaks(df.pop))
df.pop_bins = customcut(df.pop, breaks[:kmeans][:brks])
df.parsed_geoms = parse_geoms(df)

# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

# Use CRS string from constants
map_poly(df, "Erie", CRS_STRINGS["erie"], fig)

# Display the figure
display(fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "Census", "img"))
@info "Saving to directory: $img_dir"
saved_path = save_plot(fig, "Erie", directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end

# Store the geoids for later use
# set_nation_state_geoids(map_title, df.geoid)






