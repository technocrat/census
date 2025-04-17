# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "scripts/preamble.jl")
include(the_path)

# DataFrames and LibPQ are likely already included in preamble
# but include them explicitly just in case
using DataFrames
using LibPQ

colorado_basin = GeoIDs.get_geoid_set("colorado_basin")
west_of_100th = GeoIDs.get_geoid_set("west_of_100th")
east_of_cascades = GeoIDs.get_geoid_set("east_of_cascades")

# Debug info for west_of_100th
@info "west_of_100th contains $(length(west_of_100th)) counties"

# Filter states to create Powell
az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∈ colorado_basin))

nm = subset(us, :stusps => ByRow(==("NM")))

mt = subset(us, :stusps => ByRow(==("MT")))

co = subset(us, :stusps => ByRow(x -> x == "CO"))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))

nd = subset(us, :stusps => ByRow(x -> x == "ND"))

# Get counties for each state
ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ west_of_100th))


ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ west_of_100th))
@info "Nebraska: $(nrow(ne)) counties in Powell"

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ west_of_100th))
@info "North Dakota: $(nrow(nd)) counties in Powell"

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ west_of_100th))
@info "South Dakota: $(nrow(sd)) counties in Powell"

ok = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∈ west_of_100th))
@info "Oklahoma: $(nrow(ok)) counties in Powell"

tx = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ west_of_100th))
@info "Texas: $(nrow(tx)) counties in Powell"

ut = subset(us, :stusps => ByRow(==("UT")))
keep_ut = ["49037","49019"]
ut = subset(ut, :geoid => ByRow(x -> x ∈ keep_ut))



df = vcat(mt, nm, wy, az, co, nd, sd, ne, ks, tx, ok, ut)
@info "Powell nation state contains $(nrow(df)) counties total"

selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
# Get the CRS string for Powell
dest = Census.CRS_STRINGS["powell"]

map_title = "Powell"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

# Create the map
Census.map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "img"))  # Use relative path from script location
@info "Saving to directory: $img_dir"
saved_path = Census.save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end

# Store the geoids for later use
Census.set_nation_state_geoids("Powell", df.geoid)

display(fig)
