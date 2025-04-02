# SPDX-License-Identifier: MIT
# Script to adjust the Concordia dataset by adding 
# Clinton and Essex counties in New York, 
# and ceding portions of northern Maine to Canada 
# plus moving greater Bridgeport to Metropolis
using Census
using DataFrames: rename!, transform!, ByRow, nrow
using RSetup
using CairoMakie
using GeoMakie
using ArchGDAL
using GeometryBasics
RSetup.setup_r_environment(["classInt"])

# For development - include map_poly.jl directly
include("../src/map_poly.jl")
include("../src/ga.jl")

# Define the destination projection - Albers Equal Area centered on Lexington, KY
dest = "+proj=aea +lat_0=38 +lon_0=-85 +lat_1=30 +lat_2=45 +datum=NAD83 +units=m +no_defs"

# Create figure first
fig = Figure(size=(2400, 1600), fontsize=22)

rejig       = copy(Census.concord)
regig       = push!(rejig,"NY")
df          = get_geo_pop(rejig)
DataFrames.rename!(df, [:geoid, :stusps, :county, :geom, :pop])
breaks      = RCall.rcopy(get_breaks(df,5))
df.pop_bins = my_cut(df.pop, breaks[:kmeans][:brks])

# Convert WKT strings to geometric objects
df.parsed_geoms = parse_geoms(df)

add_to_concordia = ["36019","36031"]
addns       = filter(:geoid  => x -> x ∈ add_to_concordia,df)
df          = vcat(df,addns)
take_from_concordia = ["23003","20029","09160","09190"]
df          = filter(:geoid  => x -> x ∉ take_from_concordia,df)
take_from_ny  = setdiff(get_geo_pop(["NY"]).geoid,add_to_concordia)
df          = filter(:geoid  => x -> x ∉ take_from_ny,df)
df          = filter(:geoid  => x -> x ∉ take_from_concordia,df)

# Now call map_poly with all required parameters
map_poly(df, "Adjusted Concordia", dest, fig)

# Display the figure
display(fig)

