#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Use only the essential packages
using LibPQ
using DataFrames

println("Updating west_of_100th geoid set with counties between -104°W and -100°W...")
conn = LibPQ.Connection("dbname=tiger")

# Get counties with centroids between -104°W and -100°W
println("Getting counties with centroids between -104°W and -100°W...")
query = """
SELECT geoid 
FROM census.counties 
WHERE ST_X(ST_Centroid(geom)) BETWEEN -104.0 AND -100.0
ORDER BY geoid;
"""
result = LibPQ.execute(conn, query)
longitude_geoids = DataFrame(result).geoid
println("Found $(length(longitude_geoids)) counties with centroids between -104°W and -100°W")

# Get existing west_of_100th geoids
println("Getting current west_of_100th geoids...")
query = """
SELECT gsm.geoid
FROM census.geoid_set_members gsm
JOIN census.geoid_sets gs ON gsm.set_name = gs.set_name AND gsm.version = gs.version
WHERE gs.set_name = 'west_of_100th' AND gs.is_current = TRUE
ORDER BY gsm.geoid;
"""
result = LibPQ.execute(conn, query)
west_of_100th = DataFrame(result).geoid
println("Original west_of_100th set contains $(length(west_of_100th)) counties")

# Combine the sets (removing duplicates)
updated_west_of_100th = unique(vcat(west_of_100th, longitude_geoids))
println("Updated west_of_100th would contain $(length(updated_west_of_100th)) counties")

# Find which counties would be added
added_counties = setdiff(updated_west_of_100th, west_of_100th)
println("\nWould add $(length(added_counties)) new counties to west_of_100th")

# Display counties that would be added
if length(added_counties) > 0
    println("\nSample counties to be added (up to 10):")
    for geoid in added_counties[1:min(10, length(added_counties))]
        query = """
        SELECT name, stusps FROM census.counties WHERE geoid = '$geoid'
        """
        result = LibPQ.execute(conn, query)
        result_df = DataFrame(result)
        if nrow(result_df) > 0
            println("  $(result_df.name[1]), $(result_df.stusps[1]) ($geoid)")
        else
            println("  Unknown county ($geoid)")
        end
    end
    
    if length(added_counties) > 10
        println("  ... and $(length(added_counties) - 10) more counties")
    end
end

# Let's also check which states are represented in the -104°W to -100°W range
println("\nStates represented in the -104°W to -100°W range:")
query = """
SELECT DISTINCT stusps, COUNT(*) as county_count 
FROM census.counties 
WHERE ST_X(ST_Centroid(geom)) BETWEEN -104.0 AND -100.0
GROUP BY stusps
ORDER BY county_count DESC;
"""
result = LibPQ.execute(conn, query)
states_df = DataFrame(result)
for row in eachrow(states_df)
    println("  $(row.stusps): $(row.county_count) counties")
end

println("\nDo you want to update the west_of_100th geoid set? (y/n)")
response = lowercase(readline())

if startswith(response, "y")
    # Get current version info
    version_query = """
    SELECT version FROM census.geoid_sets
    WHERE set_name = 'west_of_100th' AND is_current = TRUE;
    """
    version_result = LibPQ.execute(conn, version_query)
    current_version = version_result[1,1]
    new_version = current_version + 1
    
    # Begin transaction
    LibPQ.execute(conn, "BEGIN;")
    
    try
        # Mark current version as not current
        LibPQ.execute(conn, """
        UPDATE census.geoid_sets 
        SET is_current = FALSE
        WHERE set_name = 'west_of_100th' AND is_current = TRUE;
        """)
        
        # Create new version
        LibPQ.execute(conn, """
        INSERT INTO census.geoid_sets 
        (set_name, version, description, is_current, parent_version, change_description)
        VALUES ('west_of_100th', $new_version, 'Counties west of the 100th meridian', 
                TRUE, $current_version, 'Updated to include counties with centroids between -104°W and -100°W');
        """)
        
        # Track changes
        for geoid in added_counties
            LibPQ.execute(conn, """
            INSERT INTO census.geoid_set_changes
            (set_name, version, change_type, geoid)
            VALUES ('west_of_100th', $new_version, 'ADD', '$geoid');
            """)
        end
        
        # Add all geoids to the new version
        for geoid in updated_west_of_100th
            LibPQ.execute(conn, """
            INSERT INTO census.geoid_set_members
            (set_name, version, geoid)
            VALUES ('west_of_100th', $new_version, '$geoid');
            """)
        end
        
        # Commit transaction
        LibPQ.execute(conn, "COMMIT;")
        println("Successfully updated west_of_100th to version $new_version")
        
    catch e
        # Rollback on error
        LibPQ.execute(conn, "ROLLBACK;")
        println("Error updating west_of_100th: $e")
    end
else
    println("Update cancelled.")
end

println("\nThe west_of_100th geoid set has been updated to include counties with centroids between -104°W and -100°W longitude")

LibPQ.close(conn)
println("Done!") 