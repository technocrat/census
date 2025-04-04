# SPDX-License-Identifier: MIT
# SCRIPT

using Census

us = init_census_data()

# Filter states to create Powell
az = subset(us, :stusps => ByRow(==("AZ")))
az = subset(az, :geoid => ByRow(x -> x ∈ COLORADO_BASIN_GEOIDS))

nm = subset(us, :stusps => ByRow(==("NM")))

mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ WEST_MONTANA_GEOIDS))

co = subset(us, :stusps => ByRow(x -> x == "CO"))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

ks = subset(us, :stusps => ByRow(==("KS")))
ks = subset(ks, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

ne = subset(us, :stusps => ByRow(==("NE")))
ne = subset(ne, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

nd = subset(us, :stusps => ByRow(==("ND")))
nd = subset(nd, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

sd = subset(us, :stusps => ByRow(==("SD")))
sd = subset(sd, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

ok = subset(us, :stusps => ByRow(==("OK")))
ok = subset(ok, :geoid => ByRow(x -> x ∉ EASTERN_GEOIDS))

tx = subset(us, :stusps => ByRow(==("TX")))
tx = subset(tx, :geoid => ByRow(x -> x ∈ WESTERN_GEOIDS))

ut = subset(us, :stusps => ByRow(==("UT")))
keep_ut = ["49037","49019"]
ut = subset(ut, :geoid => ByRow(x -> x ∈ keep_ut))

df = vcat(mt,nm,wy,az,co,az,nd,sd,ne,ks,tx,ok,ut)

# Get the CRS string for Powell
dest = CRS_STRINGS["powell"]

map_title = "Powell"
# Create figure
fig = Figure(size=(2400, 1600), fontsize=22)

# Create the map
map_poly(df, map_title, dest, fig)

# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "img"))  # Use relative path from script location
@info "Saving to directory: $img_dir"
saved_path = save_plot(fig, map_title, directory=img_dir)
@info "Plot saved to: $saved_path"

# Verify file exists
if isfile(saved_path)
    @info "File successfully created at: $saved_path"
else
    @error "Failed to create file at: $saved_path"
end

# Store the geoids for later use
# set_nation_state_geoids("Powell", df.geoid)
