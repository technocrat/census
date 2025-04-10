module GeoIDs

using DataFrames
using LibPQ
using ArchGDAL

# Include submodules
include("db.jl")
include("store.jl")
include("fetch.jl")
include("operations.jl")
include("setup.jl")
include("predefined_sets.jl")
include("list_all_geoids.jl") # Include the list_all_geoids function

# Import and re-export from sub-modules
using .DB
using .Store
using .Fetch
using .Operations
using .Setup
using .PredefinedSets
using .ListGeoids

# Constants for holding pre-defined GEOID sets that will be loaded from the database
const EASTERN_US_GEOIDS = String[]
const WESTERN_US_GEOIDS = String[]
const SOUTH_FLORIDA_GEOIDS = String[] 
const MIDWEST_GEOIDS = String[]
const MOUNTAIN_WEST_GEOIDS = String[]
const GREAT_PLAINS_GEOIDS = String[]
const EAST_OF_SIERRAS_GEOIDS = String[]
const FLORIDA_GEOIDS_DB = String[]
const COLORADO_BASIN_GEOIDS_DB = String[]
const WEST_OF_100TH_GEOIDS = String[]
const EAST_OF_100TH_GEOIDS = String[]
const MICHIGAN_UPPER_PENINSULA_GEOIDS = String[]
const NORTHERN_RURAL_CALIFORNIA_GEOIDS = String[]

# Additional constants from Census module to centralize all geoid sets
const WESTERN_GEOIDS = String[]
const EASTERN_GEOIDS = String[]
const EAST_OF_UTAH_GEOIDS = String[]
const WEST_OF_CASCADES_GEOIDS = String[]
const EAST_OF_CASCADES_GEOIDS = String[]
const SOUTHERN_KANSAS_GEOIDS = String[]
const NORTHERN_KANSAS_GEOIDS = String[]
const COLORADO_BASIN_GEOIDS = String[]
const NE_MISSOURI_GEOIDS = String[]
const SOUTHERN_MISSOURI_GEOIDS = String[]
const NORTHERN_MISSOURI_GEOIDS = String[]
const MISSOURI_RIVER_BASIN_GEOIDS = String[]
const SLOPE_GEOIDS = String[]
const SOCAL_GEOIDS = String[]
const OHIO_BASIN_KY_GEOIDS = String[]
const OHIO_BASIN_TN_GEOIDS = String[]
const OHIO_BASIN_IL_GEOIDS = String[]
const OHIO_BASIN_VA_GEOIDS = String[]
const OHIO_BASIN_GA_GEOIDS = String[]
const OHIO_BASIN_AL_GEOIDS = String[]
const OHIO_BASIN_MS_GEOIDS = String[]
const OHIO_BASIN_NC_GEOIDS = String[]
const OHIO_BASIN_PA_GEOIDS = String[]
const OHIO_BASIN_NY_GEOIDS = String[]
const OHIO_BASIN_MD_GEOIDS = String[]
const HUDSON_BAY_DRAINAGE_GEOIDS = String[]
const MISS_RIVER_BASIN_SD = String[]
const MISS_BASIN_KY_GEOIDS = String[]
const MISS_BASIN_TN_GEOIDS = String[]
const MICHIGAN_PENINSULA_GEOIDS = String[]
const METRO_TO_GREAT_LAKES_GEOIDS = String[]
const GREAT_LAKES_PA_GEOIDS = String[]
const GREAT_LAKES_IN_GEOIDS = String[]
const GREAT_LAKES_OH_GEOIDS = String[]

"""
    initialize_predefined_geoid_sets()

Initialize all predefined GEOID sets in the database.
This is called during the first module load to ensure all
standard GEOID sets are available in the versioned database.
"""
function initialize_predefined_geoid_sets()
    # Initialize all predefined sets in the database
    create_all_predefined_sets()
    
    # Load the GEOIDs from the database into the constants
    append!(EASTERN_US_GEOIDS, get_geoid_set("eastern_us"))
    append!(WESTERN_US_GEOIDS, get_geoid_set("western_us"))
    append!(SOUTH_FLORIDA_GEOIDS, get_geoid_set("south_florida"))
    append!(MIDWEST_GEOIDS, get_geoid_set("midwest"))
    append!(MOUNTAIN_WEST_GEOIDS, get_geoid_set("mountain_west"))
    append!(GREAT_PLAINS_GEOIDS, get_geoid_set("great_plains"))
    append!(EAST_OF_SIERRAS_GEOIDS, get_geoid_set("east_of_sierras"))
    append!(FLORIDA_GEOIDS_DB, get_geoid_set("florida"))
    append!(COLORADO_BASIN_GEOIDS_DB, get_geoid_set("colorado_basin"))
    append!(WEST_OF_100TH_GEOIDS, get_geoid_set("west_of_100th"))
    append!(EAST_OF_100TH_GEOIDS, get_geoid_set("east_of_100th"))
    append!(MICHIGAN_UPPER_PENINSULA_GEOIDS, get_geoid_set("michigan_upper_peninsula"))
    append!(NORTHERN_RURAL_CALIFORNIA_GEOIDS, get_geoid_set("northern_rural_california"))
    
    # Initialize additional constants from database where available
    try
        append!(WESTERN_GEOIDS, get_geoid_set("western"))
        append!(EASTERN_GEOIDS, get_geoid_set("eastern"))
        append!(EAST_OF_UTAH_GEOIDS, get_geoid_set("east_of_utah"))
        append!(WEST_OF_CASCADES_GEOIDS, get_geoid_set("west_of_cascades"))
        append!(EAST_OF_CASCADES_GEOIDS, get_geoid_set("east_of_cascades"))
        append!(SOUTHERN_KANSAS_GEOIDS, get_geoid_set("southern_kansas"))
        append!(NORTHERN_KANSAS_GEOIDS, get_geoid_set("northern_kansas"))
        append!(COLORADO_BASIN_GEOIDS, get_geoid_set("colorado_basin"))
        append!(NE_MISSOURI_GEOIDS, get_geoid_set("ne_missouri"))
        append!(SOUTHERN_MISSOURI_GEOIDS, get_geoid_set("southern_missouri"))
        append!(NORTHERN_MISSOURI_GEOIDS, get_geoid_set("northern_missouri"))
        append!(MISSOURI_RIVER_BASIN_GEOIDS, get_geoid_set("missouri_river_basin"))
        append!(SLOPE_GEOIDS, get_geoid_set("slope"))
        append!(SOCAL_GEOIDS, get_geoid_set("socal"))
        append!(OHIO_BASIN_KY_GEOIDS, get_geoid_set("ohio_basin_ky"))
        append!(OHIO_BASIN_TN_GEOIDS, get_geoid_set("ohio_basin_tn"))
    catch e
        @warn "Some geoid sets could not be loaded from the database" exception=e
    end
end

"""
    backup_geoid_sets(backup_dir::String)

Backup all GEOID sets to CSV files in the specified directory.
"""
function backup_geoid_sets(backup_dir::String)
    result = list_geoid_sets()
    for row in eachrow(result)
        set_name = row.set_name
        version = row.latest_version
        geoids = get_geoid_set_version(set_name, version)
        
        # Create a DataFrame and save to CSV
        df = DataFrame(geoid = geoids)
        filename = joinpath(backup_dir, "$(set_name)_v$(version).csv")
        CSV.write(filename, df)
    end
end

"""
    restore_geoid_sets(backup_dir::String)

Restore all GEOID sets from CSV files in the specified directory.
"""
function restore_geoid_sets(backup_dir::String)
    for file in readdir(backup_dir)
        if endswith(file, ".csv")
            # Extract set name and version from filename
            parts = split(replace(file, ".csv" => ""), "_v")
            if length(parts) == 2
                set_name = parts[1]
                version = parse(Int, parts[2])
                
                # Read the CSV file
                df = CSV.read(joinpath(backup_dir, file), DataFrame)
                
                # Create or update the GEOID set
                if !has_geoid_set(set_name)
                    create_geoid_set(set_name, df.geoid)
                else
                    create_geoid_set_version(set_name, df.geoid)
                end
            end
        end
    end
end

# Export from GeoIDs module
export backup_geoid_sets,
       restore_geoid_sets,
       EASTERN_US_GEOIDS,
       WESTERN_US_GEOIDS,
       SOUTH_FLORIDA_GEOIDS,
       MIDWEST_GEOIDS,
       MOUNTAIN_WEST_GEOIDS,
       GREAT_PLAINS_GEOIDS,
       EAST_OF_SIERRAS_GEOIDS,
       FLORIDA_GEOIDS_DB,
       COLORADO_BASIN_GEOIDS_DB,
       WEST_OF_100TH_GEOIDS,
       EAST_OF_100TH_GEOIDS,
       MICHIGAN_UPPER_PENINSULA_GEOIDS,
       NORTHERN_RURAL_CALIFORNIA_GEOIDS,
       
       # Additional exports for centralized geoid constants
       WESTERN_GEOIDS,
       EASTERN_GEOIDS,
       EAST_OF_UTAH_GEOIDS,
       WEST_OF_CASCADES_GEOIDS,
       EAST_OF_CASCADES_GEOIDS,
       SOUTHERN_KANSAS_GEOIDS,
       NORTHERN_KANSAS_GEOIDS,
       COLORADO_BASIN_GEOIDS,
       NE_MISSOURI_GEOIDS,
       SOUTHERN_MISSOURI_GEOIDS,
       NORTHERN_MISSOURI_GEOIDS,
       MISSOURI_RIVER_BASIN_GEOIDS,
       SLOPE_GEOIDS,
       SOCAL_GEOIDS,
       OHIO_BASIN_KY_GEOIDS,
       OHIO_BASIN_TN_GEOIDS,
       OHIO_BASIN_IL_GEOIDS,
       OHIO_BASIN_VA_GEOIDS,
       OHIO_BASIN_GA_GEOIDS,
       OHIO_BASIN_AL_GEOIDS,
       OHIO_BASIN_MS_GEOIDS,
       OHIO_BASIN_NC_GEOIDS,
       OHIO_BASIN_PA_GEOIDS,
       OHIO_BASIN_NY_GEOIDS,
       OHIO_BASIN_MD_GEOIDS,
       HUDSON_BAY_DRAINAGE_GEOIDS,
       MISS_RIVER_BASIN_SD,
       MISS_BASIN_KY_GEOIDS,
       MISS_BASIN_TN_GEOIDS,
       MICHIGAN_PENINSULA_GEOIDS,
       METRO_TO_GREAT_LAKES_GEOIDS,
       GREAT_LAKES_PA_GEOIDS,
       GREAT_LAKES_IN_GEOIDS,
       GREAT_LAKES_OH_GEOIDS,
       
       # Export Setup module functions
       setup_census_schema,
       download_county_shapefile,
       load_counties_to_db,
       initialize_database,
       # Re-export predefined sets constants
       EASTERN_US_COUNTIES,
       WESTERN_US_COUNTIES,
       SOUTH_FLORIDA_COUNTIES,
       MIDWEST_COUNTIES,
       MOUNTAIN_WEST_COUNTIES,
       GREAT_PLAINS_COUNTIES,
       EAST_OF_SIERRAS,
       FLORIDA_GEOIDS,
       COLORADO_BASIN_GEOIDS,
       WEST_OF_100TH,
       EAST_OF_100TH,
       MICHIGAN_UPPER_PENINSULA,
       NORTHERN_RURAL_CALIFORNIA,
       # Export utility functions
       list_all_geoids,
       which_sets,
       create_predefined_set,
       create_all_predefined_sets,
       # Export Store module functions for managing geoid sets
       list_geoid_sets

end # module GeoIDs 