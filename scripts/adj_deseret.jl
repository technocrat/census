# SPDX-License-Identifier: MIT
# Script to adjust the Deseret dataset
# SCRIPT

# Include the preamble with correct path
include(joinpath(@__DIR__, "preamble.jl"))

# Initialize census data
us = Census.init_census_data()

# Use GeoIDs module to fetch geoid sets via function calls
colorado_basin_geoids = GeoIDs.get_geoid_set("colorado_basin")
east_of_utah_geoids = GeoIDs.get_geoid_set("east_of_utah")
east_of_cascade_geoids = GeoIDs.get_geoid_set("east_of_cascades")
missouri_river_basin_geoids = GeoIDs.get_geoid_set("missouri_river_basin")
east_of_sierras_geoids = GeoIDs.get_geoid_set("east_of_sierras")
socal_geoids = GeoIDs.get_geoid_set("socal")
# Define excluded Utah geoids if needed
excluded_utah_geoids = ["49019", "49037"]

# Alternative approach using the Census.DESERT constant
# deseret_states = Census.DESERT 
# @info "Deseret states from constant: $deseret_states"

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

# For mapping, use the kmeans method


# Set up map parameters
map_title = "Deseret"
# Use a specific CRS string for this region
dest = "+proj=aea +lat_0=40 +lon_0=-112 +lat_1=33 +lat_2=45 +datum=NAD83 +units=m +no_defs"

# Create figure and map
fig = CairoMakie.Figure(size=(3200, 2400), fontsize=24)
Census.map_poly(df, map_title, dest, fig)

# Save the map
img_dir = abspath(joinpath(@__DIR__, "img"))
mkpath(img_dir)  # Ensure directory exists
@info "Saving to directory: $img_dir"

# Save with timestamp to prevent overwrites
timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
safe_title = replace(map_title, r"[^a-zA-Z0-9]" => "_")
filename = joinpath(img_dir, "$(safe_title)_$(timestamp).png")
CairoMakie.save(filename, fig, px_per_unit=2)

# Verify file exists
if isfile(filename)
    @info "File successfully created at: $filename"
else
    @error "Failed to create file at: $filename"
end

# Display the figure
display(fig)

# After finalizing the dataset, store the geoids for later use
# Use the GeoIDs module's set_nation_state_geoids function
# Filter out any missing values and convert to Vector{String}
clean_geoids = filter(!ismissing, df.geoid)
# Explicitly convert to Vector{String}
string_geoids = String.(clean_geoids)
@info "Saving $(length(string_geoids)) geoids for Deseret"
GeoIDs.set_nation_state_geoids("deseret", string_geoids)

# Get geoids by population range
populated_counties = GeoIDs.get_geoids_by_population_range(0, 25_000)
@info "There are $(length(populated_counties)) counties with population less than 25,000"

boondocks = GeoIDs.get_geoids_by_population_range(25_000, 500_000)
rural = subset(us, :geoid => ByRow(x -> x ∈ boondocks))
rural = subset(rural, :stusps => ByRow(x -> x != "AK" && x != "HI"))
rural = subset(rural, :stusps => ByRow(x -> x ∈ VALID_POSTAL_CODES))    

bin_indices = Breakers.get_bin_indices(rural.pop, 7)

# For mapping, use the kmeans method
selected_method = "fisher"
rural.bin_values = bin_indices[selected_method]

# Set up map parameters
map_title = "Rural America"
# Use a specific CRS string for this region
dest = "+proj=aea +lat_0=40 +lon_0=-112 +lat_1=33 +lat_2=45 +datum=NAD83 +units=m +no_defs"

# Create figure and map
fig = CairoMakie.Figure(size=(3200, 2400), fontsize=24)
Census.map_poly(rural, map_title, dest, fig)
display(fig)

