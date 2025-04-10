# SPDX-License-Identifier: MIT
# Script to migrate geoid constants from Census to GeoIDs module
# SCRIPT

using Pkg
Pkg.activate(".")  # Activate the project environment

using Census, GeoIDs, DataFrames
using LibPQ

println("Starting geoid migration from Census to GeoIDs module...")

# Dictionary to map Census constants to GeoIDs set names
const GEOID_MAPPING = Dict(
    "WESTERN_GEOIDS" => "western",
    "EASTERN_GEOIDS" => "eastern",
    "EAST_OF_UTAH_GEOIDS" => "east_of_utah",
    "WEST_OF_CASCADES_GEOIDS" => "west_of_cascades",
    "EAST_OF_CASCADES_GEOIDS" => "east_of_cascades",
    "SOUTHERN_KANSAS_GEOIDS" => "southern_kansas",
    "NORTHERN_KANSAS_GEOIDS" => "northern_kansas",
    "COLORADO_BASIN_GEOIDS" => "colorado_basin",
    "NE_MISSOURI_GEOIDS" => "ne_missouri",
    "SOUTHERN_MISSOURI_GEOIDS" => "southern_missouri",
    "NORTHERN_MISSOURI_GEOIDS" => "northern_missouri",
    "MISSOURI_RIVER_BASIN_GEOIDS" => "missouri_river_basin",
    "SLOPE_GEOIDS" => "slope",
    "SOCAL_GEOIDS" => "socal",
    "OHIO_BASIN_KY_GEOIDS" => "ohio_basin_ky",
    "OHIO_BASIN_TN_GEOIDS" => "ohio_basin_tn",
    "OHIO_BASIN_IL_GEOIDS" => "ohio_basin_il",
    "OHIO_BASIN_VA_GEOIDS" => "ohio_basin_va",
    "OHIO_BASIN_GA_GEOIDS" => "ohio_basin_ga",
    "OHIO_BASIN_AL_GEOIDS" => "ohio_basin_al",
    "OHIO_BASIN_MS_GEOIDS" => "ohio_basin_ms",
    "OHIO_BASIN_NC_GEOIDS" => "ohio_basin_nc",
    "OHIO_BASIN_PA_GEOIDS" => "ohio_basin_pa",
    "OHIO_BASIN_NY_GEOIDS" => "ohio_basin_ny",
    "OHIO_BASIN_MD_GEOIDS" => "ohio_basin_md",
    "HUDSON_BAY_DRAINAGE_GEOIDS" => "hudson_bay_drainage",
    "MISS_RIVER_BASIN_SD" => "miss_river_basin_sd",
    "MISS_BASIN_KY_GEOIDS" => "miss_basin_ky",
    "MISS_BASIN_TN_GEOIDS" => "miss_basin_tn",
    "MICHIGAN_PENINSULA_GEOIDS" => "michigan_peninsula",
    "METRO_TO_GREAT_LAKES_GEOIDS" => "metro_to_great_lakes",
    "GREAT_LAKES_PA_GEOIDS" => "great_lakes_pa",
    "GREAT_LAKES_IN_GEOIDS" => "great_lakes_in",
    "GREAT_LAKES_OH_GEOIDS" => "great_lakes_oh"
)

# Initialize the GeoIDs database tables if needed
try
    GeoIDs.initialize_database()
    println("GeoIDs database initialized.")
catch e
    println("GeoIDs database already initialized: $e")
end

# Get all Census geoid sets
census_constants = filter(name -> endswith(String(name), "_GEOIDS"), names(Census))

# Add the special case for MISS_RIVER_BASIN_SD which doesn't end with _GEOIDS
if :MISS_RIVER_BASIN_SD in names(Census)
    push!(census_constants, :MISS_RIVER_BASIN_SD)
end

# Number of constants migrated and total count
migrated_count = 0
total_count = length(census_constants)

println("Found $total_count geoid constants in Census module")

# Migrate each constant
for constant_name in census_constants
    constant_str = String(constant_name)
    
    # Skip if not in our mapping
    if !haskey(GEOID_MAPPING, constant_str)
        println("Skipping $constant_str - not found in mapping")
        continue
    end
    
    geoid_set_name = GEOID_MAPPING[constant_str]
    geoids = getfield(Census, constant_name)
    
    # Skip empty collections
    if isempty(geoids)
        println("Skipping $constant_str - empty collection")
        continue
    end
    
    println("Migrating $constant_str to GeoIDs.$constant_str (set name: $geoid_set_name)")
    println("  Contains $(length(geoids)) geoids")
    
    # Store in GeoIDs database
    try
        # Check if set exists
        if GeoIDs.has_geoid_set(geoid_set_name)
            # Create a new version
            GeoIDs.create_geoid_set_version(geoid_set_name, geoids)
            println("  Created new version for existing set $geoid_set_name")
        else
            # Create new set
            GeoIDs.create_geoid_set(geoid_set_name, geoids)
            println("  Created new set $geoid_set_name")
        end
        
        # Update the GeoIDs constant
        constant = getfield(GeoIDs, Symbol(constant_str))
        empty!(constant)
        append!(constant, geoids)
        
        migrated_count += 1
    catch e
        println("  ERROR: Failed to migrate $constant_str: $e")
    end
end

println("Migration complete: Migrated $migrated_count/$total_count geoid sets")

# Print out available sets in GeoIDs
println("\nAvailable GeoID sets in database:")
sets = GeoIDs.list_geoid_sets()
if isempty(sets)
    println("  No sets available")
else
    for (i, row) in enumerate(eachrow(sets))
        set_name = row.set_name
        version = row.latest_version
        count = row.geoid_count
        println("  $i. $set_name (v$version): $count geoids")
    end
end

# Verification
println("\nVerification of migration:")
for constant_name in census_constants
    constant_str = String(constant_name)
    
    # Skip if not in our mapping
    if !haskey(GEOID_MAPPING, constant_str)
        continue
    end
    
    census_geoids = getfield(Census, constant_name)
    geoids_geoids = getfield(GeoIDs, Symbol(constant_str))
    
    census_count = length(census_geoids)
    geoids_count = length(geoids_geoids)
    
    if census_count == 0 && geoids_count == 0
        println("  $constant_str: Both empty")
    elseif census_count == geoids_count
        println("  $constant_str: Match ($census_count geoids)")
    else
        println("  $constant_str: MISMATCH - Census: $census_count,
    "OHIO_BASIN_DIXIE_GEOIDS" => "ohio_basin_dixie",
    "NORTHERN_VA_GEOIDS" => "northern_va", GeoIDs: $geoids_count")
    end
end 