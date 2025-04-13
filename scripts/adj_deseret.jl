# SPDX-License-Identifier: MIT
# SCRIPT

# Load the comprehensive preamble that handles visualization
# do  not change next line  NO MATTER WHERE THIS FILE IS LOCATED
# in the project, @__DIR__ will be the directory of the project
# unless explicitly overridden by the user
the_path = joinpath(@__DIR__, "scripts", "preamble.jl")
include(the_path)

# Get geoid sets from GeoIDs
colorado_basin_geoids = GeoIDs.get_geoid_set("colorado_basin")
east_of_utah_geoids = GeoIDs.get_geoid_set("east_of_utah")
east_of_cascade_geoids = GeoIDs.get_geoid_set("east_of_cascades")
missouri_river_basin_geoids = GeoIDs.get_geoid_set("missouri_river_basin")
east_of_sierras_geoids = GeoIDs.get_geoid_set("east_of_sierras")
socal_geoids = GeoIDs.get_geoid_set("socal")

# Define excluded Utah geoids
excluded_utah_geoids = ["49019", "49037"]

# Process counties by state
co = subset(us, :stusps => ByRow(==("CO")))
co = subset(co, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))

mt = subset(us, :stusps => ByRow(==("MT")))
mt = subset(mt, :geoid => ByRow(x -> x ∉ east_of_utah_geoids))

id = subset(us, :stusps => ByRow(==("ID")))

wy = subset(us, :stusps => ByRow(x -> x == "WY"))
wy = subset(wy, :geoid => ByRow(x -> x ∉ missouri_river_basin_geoids))

nv = subset(us, :stusps => ByRow(==("NV")))
nv = subset(nv, :geoid => ByRow(x -> x ∉ colorado_basin_geoids))
    
ut = subset(us, :stusps => ByRow(==("UT")))
ut = subset(ut, :geoid => ByRow(x -> x ∉ excluded_utah_geoids))
    
or = subset(us, :stusps => ByRow(==("OR")))
or = subset(or, :geoid => ByRow(x -> x ∈ east_of_cascade_geoids))

ca = subset(us, :stusps => ByRow(==("CA")))
ca = subset(ca, :geoid => ByRow(x -> x ∈ east_of_sierras_geoids &&
                                x ∉ socal_geoids))
    
wa = subset(us, :stusps => ByRow(==("WA")))
wa = subset(wa, :geoid => ByRow(x -> x ∈ east_of_cascade_geoids))

df = vcat(id, nv, or, wa, ut, ca)

# Get binned data for each classification method using Breakers
bin_indices = Breakers.get_bin_indices(df.pop, 7)

# You can change this to any method: "fisher", "kmeans", "quantile", "equal"
selected_method = "fisher"
df.bin_values = bin_indices[selected_method]

# Define the map title
map_title = "Deseret"  

# Create the figure and map
fig = Figure(size=(3200, 2400), fontsize=24)
dest = Census.CRS_STRINGS["powell"]
Census.map_poly(df, map_title, dest, fig)



# Save the figure
img_dir = abspath(joinpath(@__DIR__, "img"))
mkpath(img_dir)
timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
safe_title = replace(map_title, r"[^a-zA-Z0-9]" => "_")
filename = joinpath(img_dir, "$(safe_title)_$(timestamp).png")
save(filename, fig, px_per_unit=2)
@info "Plot saved to: $filename"

# Display the figure
display(fig)

# Save the geoids to database if possible
if @isdefined(set_nation_state_geoids)
    set_nation_state_geoids(map_title, df.geoid)
    @info "Saved $(length(df.geoid)) county geoids to database under nation state '$(map_title)'"
end