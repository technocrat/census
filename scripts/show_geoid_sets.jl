# SPDX-License-Identifier: MIT
# Script to show all predefined geoid sets in GeoIDs package
# SCRIPT

# Ensure proper package environment
using Pkg
Pkg.activate(joinpath(@__DIR__, "..")) # Activate the main project environment

# Load necessary packages
using GeoIDs, DataFrames, CSV

println("Showing all predefined geoid sets in the GeoIDs package:")
println("======================================================")

# Display all constants that contain geoid collections
println("\n1. Exported Geoid Constants:")
println("---------------------------")
# These are the predefined constants that are exported directly from GeoIDs
println("EASTERN_US_GEOIDS: $(length(GeoIDs.EASTERN_US_GEOIDS)) geoids")
println("WESTERN_US_GEOIDS: $(length(GeoIDs.WESTERN_US_GEOIDS)) geoids")
println("SOUTH_FLORIDA_GEOIDS: $(length(GeoIDs.SOUTH_FLORIDA_GEOIDS)) geoids")
println("MIDWEST_GEOIDS: $(length(GeoIDs.MIDWEST_GEOIDS)) geoids")
println("MOUNTAIN_WEST_GEOIDS: $(length(GeoIDs.MOUNTAIN_WEST_GEOIDS)) geoids")
println("GREAT_PLAINS_GEOIDS: $(length(GeoIDs.GREAT_PLAINS_GEOIDS)) geoids")
println("EAST_OF_SIERRAS_GEOIDS: $(length(GeoIDs.EAST_OF_SIERRAS_GEOIDS)) geoids")
println("FLORIDA_GEOIDS_DB: $(length(GeoIDs.FLORIDA_GEOIDS_DB)) geoids")
println("COLORADO_BASIN_GEOIDS_DB: $(length(GeoIDs.COLORADO_BASIN_GEOIDS_DB)) geoids")
println("WEST_OF_100TH_GEOIDS: $(length(GeoIDs.WEST_OF_100TH_GEOIDS)) geoids")
println("EAST_OF_100TH_GEOIDS: $(length(GeoIDs.EAST_OF_100TH_GEOIDS)) geoids")
println("MICHIGAN_UPPER_PENINSULA_GEOIDS: $(length(GeoIDs.MICHIGAN_UPPER_PENINSULA_GEOIDS)) geoids")
println("NORTHERN_RURAL_CALIFORNIA_GEOIDS: $(length(GeoIDs.NORTHERN_RURAL_CALIFORNIA_GEOIDS)) geoids")

# Try to list all geoid sets from the database
println("\n2. Database Stored Geoid Sets:")
println("-----------------------------")
try
    # This will show all the sets stored in the database
    sets = GeoIDs.list_geoid_sets()
    println("Found $(nrow(sets)) geoid sets in the database:")
    println(sets)
    
    # For each set, show the first few geoids
    println("\n3. Sample Geoids from Each Set:")
    println("------------------------------")
    for row in eachrow(sets)
        set_name = row.set_name
        geoids = GeoIDs.get_geoid_set(set_name)
        sample = length(geoids) > 5 ? geoids[1:5] : geoids
        println("$set_name: first $(length(sample)) of $(length(geoids)) geoids - $sample...")
    end
catch e
    println("Error listing geoid sets from database: $e")
end

# Try to list all nation states
println("\n4. Nation States in Database:")
println("---------------------------")
try
    conn = GeoIDs.DB.get_connection()
    query = """
    SELECT DISTINCT nation
    FROM census.counties
    WHERE nation IS NOT NULL
    ORDER BY nation;
    """
    result = GeoIDs.DB.execute_query(query)
    if nrow(result) > 0
        println("Found $(nrow(result)) nation states in the database:")
        for row in eachrow(result)
            nation = row.nation
            # Get count of counties in this nation state
            count_query = """
            SELECT COUNT(*) as count
            FROM census.counties
            WHERE nation = '$nation'
            """
            count_result = GeoIDs.DB.execute_query(count_query)
            count = count_result[1, :count]
            println("$nation: $count counties")
            
            # Get sample geoids for this nation
            if count > 0
                sample_query = """
                SELECT geoid
                FROM census.counties
                WHERE nation = '$nation'
                LIMIT 5
                """
                sample_result = GeoIDs.DB.execute_query(sample_query)
                sample_geoids = sample_result.geoid
                println("  Sample geoids: $sample_geoids")
            end
        end
    else
        println("No nation states found in the database.")
    end
catch e
    println("Error listing nation states from database: $e")
end

println("\nScript completed.") 