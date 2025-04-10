# SPDX-License-Identifier: MIT
# Script to demonstrate using predefined geoid sets from GeoIDs
# SCRIPT

# Ensure proper package environment
using Pkg
Pkg.activate(joinpath(@__DIR__, "..")) # Activate the main project environment

# Load necessary packages
using Census, DataFrames, DataFramesMeta, GeoIDs

# Initialize census data
us = init_census_data()

println("Examples of using predefined geoid sets from GeoIDs:")
println("==================================================")

# 1. Using a predefined constant GEOID set
eastern_us_geoids = GeoIDs.EASTERN_US_GEOIDS
println("\n1. Eastern US (using EASTERN_US_GEOIDS constant):")
println("Number of counties: $(length(eastern_us_geoids))")
if !isempty(eastern_us_geoids)
    println("Sample GEOIDs: $(eastern_us_geoids[1:min(5, length(eastern_us_geoids))])")
    eastern_df = subset(us, :geoid => ByRow(id -> id ∈ eastern_us_geoids))
    println("States in Eastern US: $(unique(eastern_df.stusps))")
    println("Total population: $(sum(eastern_df.pop))")
end

# 2. Using database-stored set via get_geoid_set
florida_geoids = GeoIDs.get_geoid_set("florida")
println("\n2. Florida Counties (using database-stored set 'florida'):")
println("Number of counties: $(length(florida_geoids))")
if !isempty(florida_geoids)
    println("Sample GEOIDs: $(florida_geoids[1:min(5, length(florida_geoids))])")
    florida_df = subset(us, :geoid => ByRow(id -> id ∈ florida_geoids))
    println("Total population: $(sum(florida_df.pop))")
end

# 3. Using the Colorado Basin geoids
colorado_basin_geoids = GeoIDs.COLORADO_BASIN_GEOIDS_DB
println("\n3. Colorado Basin Counties (using COLORADO_BASIN_GEOIDS_DB constant):")
println("Number of counties: $(length(colorado_basin_geoids))")
if !isempty(colorado_basin_geoids)
    println("Sample GEOIDs: $(colorado_basin_geoids[1:min(5, length(colorado_basin_geoids))])")
    colorado_df = subset(us, :geoid => ByRow(id -> id ∈ colorado_basin_geoids))
    println("States in Colorado Basin: $(unique(colorado_df.stusps))")
    println("Total population: $(sum(colorado_df.pop))")
end

# 4. Using Mountain West geoids
mountain_west_geoids = GeoIDs.MOUNTAIN_WEST_GEOIDS
println("\n4. Mountain West Counties (using MOUNTAIN_WEST_GEOIDS constant):")
println("Number of counties: $(length(mountain_west_geoids))")
if !isempty(mountain_west_geoids)
    println("Sample GEOIDs: $(mountain_west_geoids[1:min(5, length(mountain_west_geoids))])")
    mountain_df = subset(us, :geoid => ByRow(id -> id ∈ mountain_west_geoids))
    println("States in Mountain West: $(unique(mountain_df.stusps))")
    println("Total population: $(sum(mountain_df.pop))")
end

# 5. Creating a custom region by combining predefined sets
custom_region = vcat(
    GeoIDs.MOUNTAIN_WEST_GEOIDS,
    GeoIDs.COLORADO_BASIN_GEOIDS_DB,
    GeoIDs.WEST_OF_100TH_GEOIDS
)
custom_region = unique(custom_region) # Remove duplicates
println("\n5. Custom Western Region (combining multiple predefined sets):")
println("Number of counties: $(length(custom_region))")
if !isempty(custom_region)
    println("Sample GEOIDs: $(custom_region[1:min(5, length(custom_region))])")
    custom_df = subset(us, :geoid => ByRow(id -> id ∈ custom_region))
    println("States in Custom Region: $(unique(custom_df.stusps))")
    println("Total population: $(sum(custom_df.pop))")
end

println("\nScript completed.") 