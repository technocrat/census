# SPDX-License-Identifier: MIT
using Census

# Include files with absolute paths to avoid potential issues
include(joinpath(SCRIPTS_DIR, "libr.jl"))
include(joinpath(SCRIPTS_DIR, "dict.jl"))
include(joinpath(SCRIPTS_DIR, "func.jl"))
include(joinpath(SCRIPTS_DIR, "highlighters.jl"))
include(joinpath(SCRIPTS_DIR, "stru.jl"))
include(joinpath(SCRIPTS_DIR, "setup.jl"))

us = get_geo_pop(postals)

rename!(us, [:geoid, :stusps, :county, :geom, :pop])
setup_r_environment()
breaks = rcopy(get_breaks(us, 5))
us.pop_bins = customcut(us.pop, breaks[:kmeans][:brks])
us.parsed_geoms = parse_geoms(us)
western_geoids = get_western_geoids().geoid
eastern_geoids = get_eastern_geoids().geoid
const colorado_basin_geoids = get_colorado_basin_geoids()
const slope_geoids = get_slope_geoids().geoid
east_of_utah = get_east_of_utah_geoids().geoid
necal = ["06015", "06093", "06049", "06023", "06105",
    "06089", "06035"]
az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

nm = subset(us, :stusps => ByRow(==("NM")))
nm = subset(nm, :geoid => ByRow(x -> x ∈ rio_basin_nm ||
    x ∈ western_geoids))
mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ missouri_river_basin ||
    x ∈ east_of_utah))

id = subset(us, :stusps => ByRow(==("ID")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∉ missouri_river_basin))

nv = subset(us, :stusps => ByRow(==("NV")))

ut = subset(us, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ slope_geoids ||
    x ∈ necal))
ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∉ necal))

wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∈ slope_geoids))

df = vcat(az, id, nv, or, wa, ut, ca)

df = subset(df, :stusps => ByRow(x -> x ∉ ["AK"]))

dest = "+proj=aea +lat_0=40.8 +lon_0=-115.8 +lat_1=31.8 +lat_2=49 +datum=NAD83 +units=m +no_defs"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

map_poly(df, "Adjusted Deseret", dest, fig)
# Display the figure

display(fig)
