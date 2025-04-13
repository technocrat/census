# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
include(joinpath(@__DIR__, "preamble.jl"))

# Get geoid sets from GeoIDs

florida_geoids = GeoIDs.get_geoid_set("florida")
eastern_la = GeoIDs.get_geoid_set("eastern_la")
ohio_basin_dixie = GeoIDs.get_geoid_set("ohio_basin_dixie")
northern_va = GeoIDs.get_geoid_set("northern_va")

al = subset(us, :stusps => ByRow(==("AL")))
al = subset(al, :geoid => ByRow(x -> x ∉ ohio_basin_dixie))

fl = subset(us, :stusps => ByRow(==("FL")))
fl = subset(fl, :geoid => ByRow(x -> x ∉ florida_geoids))

ga = subset(us, :stusps => ByRow(==("GA")))
ga = subset(ga, :geoid => ByRow(x -> x ∉ ohio_basin_dixie))

la = subset(us, :stusps => ByRow(==("LA")))
la = subset(la, :geoid => ByRow(x -> x ∈ eastern_la))

ms = subset(us, :stusps => ByRow(==("MS")))
ms = subset(ms, :geoid => ByRow(x -> x ∉ ohio_basin_dixie))

nc = subset(us, :stusps => ByRow(==("NC")))
nc = subset(nc, :geoid => ByRow(x -> x ∉ ohio_basin_dixie))

sc = subset(us, :stusps => ByRow(==("SC")))
sc = subset(sc, :geoid => ByRow(x -> x ∉ ohio_basin_dixie))

va = subset(us, :stusps => ByRow(==("VA")))
va = subset(va, :geoid => ByRow(x -> x ∉ northern_va &&
                                x ∉ ohio_basin_dixie))



df = vcat(al,fl,ga,la,ms,nc,sc,va)


selected_method = "fisher"
bin_indices = Breakers.get_bin_indices(df.pop, 7)
df.bin_values = bin_indices[selected_method]
# Define projection - properly access CRS_STRINGS from Census module
dest = Census.CRS_STRINGS["delta"]

map_title = "New Dixie"
fig = Figure(size=(3200, 2400), fontsize=24)
Census.map_poly(df, map_title, dest, fig)
# Save the figure with absolute path
img_dir = abspath(joinpath(@__DIR__, "..", "img"))
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
