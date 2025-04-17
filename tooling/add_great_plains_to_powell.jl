#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# SCRIPT

# Use only the essential packages
using LibPQ
using DataFrames

println("Adding Great Plains counties between -104°W and -100°W to Powell nation state...")
conn = LibPQ.Connection("dbname=tiger")

# Get counties with centroids between -104°W and -100°W from specific states
great_plains_states = ["ND", "SD", "NE", "KS", "OK", "TX"]
state_list = join(["'$state'" for state in great_plains_states], ", ")

println("Getting Great Plains counties with centroids between -104°W and -100°W...")
query = """
SELECT c.geoid, c.stusps, c.name, ST_X(ST_Centroid(c.geom)) as longitude
FROM census.counties c
WHERE c.stusps IN ($state_list) 
AND ST_X(ST_Centroid(c.geom)) BETWEEN -104.0 AND -100.0
ORDER BY c.stusps, c.name;
"""
result = LibPQ.execute(conn, query)
counties_df = DataFrame(result)
println("Found $(nrow(counties_df)) counties in Great Plains states with centroids between -104°W and -100°W")

# Group by state to show summary
println("\nBreakdown by state:")
for state in great_plains_states
    state_counties = filter(row -> row.stusps == state, counties_df)
    println("  $state: $(nrow(state_counties)) counties")
end

# Display counties
println("\nFirst 10 counties by state:")
state_groups = Dict()
for state in great_plains_states
    state_counties = filter(row -> row.stusps == state, counties_df)
    state_groups[state] = state_counties
    if nrow(state_counties) > 0
        println("\n$state counties:")
        for i in 1:min(10, nrow(state_counties))
            row = state_counties[i, :]
            println("  $(row.name) County ($(row.geoid)) at longitude $(round(row.longitude, digits=2))°")
        end
        if nrow(state_counties) > 10
            println("  ... and $(nrow(state_counties) - 10) more counties")
        end
    end
end

# Now we need to check if these counties are already in the west_of_100th set
println("\nChecking which counties are already in west_of_100th...")
query = """
SELECT gsm.geoid
FROM census.geoid_set_members gsm
JOIN census.geoid_sets gs ON gsm.set_name = gs.set_name AND gsm.version = gs.version
WHERE gs.set_name = 'west_of_100th' AND gs.is_current = TRUE;
"""
result = LibPQ.execute(conn, query)
west_of_100th = DataFrame(result).geoid

# Find missing counties
missing_counties = setdiff(counties_df.geoid, west_of_100th)
println("Found $(length(missing_counties)) counties that need to be added to west_of_100th")

if !isempty(missing_counties)
    println("\nDo you want to update the west_of_100th geoid set to include these missing counties? (y/n)")
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
        
        # Calculate the new complete set
        updated_set = unique(vcat(west_of_100th, missing_counties))
        
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
                    TRUE, $current_version, 'Added Great Plains counties with centroids between -104°W and -100°W');
            """)
            
            # Track changes
            for geoid in missing_counties
                LibPQ.execute(conn, """
                INSERT INTO census.geoid_set_changes
                (set_name, version, change_type, geoid)
                VALUES ('west_of_100th', $new_version, 'ADD', '$geoid');
                """)
            end
            
            # Add all geoids to the new version
            for geoid in updated_set
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
end

println("\nThe west_of_100th geoid set has been checked for Great Plains counties with centroids between -104°W and -100°W")

# Now run powell.jl script if user wants
println("\nDo you want to run the powell.jl script to see the updated Powell nation state? (y/n)")
response = lowercase(readline())

if startswith(response, "y")
    println("\nRunning powell.jl script...")
    include(joinpath(@__DIR__, "powell.jl"))
else
    println("Skipping powell.jl script.")
end

LibPQ.close(conn)
println("Done!") 