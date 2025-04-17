#!/usr/bin/env julia
# SPDX-License-Identifier: MIT
# Script to update nation values in census.counties
# SCRIPT

# Ensure proper package environment
using Pkg
# Activate the root project environment
Pkg.activate(joinpath(@__DIR__, ".."))

# Load necessary packages
using Census, LibPQ, DataFrames, DataFramesMeta, ArgParse

function parse_commandline()
    s = ArgParseSettings(
        description = "Update nation values in census.counties table",
        prog = "update_nation_in_counties.jl"
    )

    add_arg_table!(s,
        "--nation", "-n", Dict(
            "help" => "Nation state name to assign to counties",
            "arg_type" => String,
            "required" => true
        ),

        "--geoid-set", "-g", Dict(
            "help" => "Name of the geoid set to use (e.g., 'ms_basin_mo')",
            "arg_type" => String,
            "required" => false
        ),

        "--list", "-l", Dict(
            "help" => "Comma-separated list of geoids to assign (alternative to --geoid-set)",
            "arg_type" => String,
            "required" => false
        ),

        "--dry-run", "-d", Dict(
            "help" => "Show what would be updated without making changes",
            "action" => :store_true
        ),

        "--verbose", "-v", Dict(
            "help" => "Show detailed information",
            "action" => :store_true
        )
    )

    return parse_args(s)
end

function main()
    args = parse_commandline()
    
    nation_state = args["nation"]
    geoid_set_name = args["geoid-set"]
    geoid_list = args["list"]
    dry_run = args["dry-run"]
    verbose = args["verbose"]
    
    if isnothing(geoid_set_name) && isnothing(geoid_list)
        error("Either --geoid-set or --list must be provided")
    end
    
    if !isnothing(geoid_set_name) && !isnothing(geoid_list)
        error("Only one of --geoid-set or --list can be provided")
    end
    
    # Determine the geoids to update
    geoids = String[]
    
    if !isnothing(geoid_set_name)
        println("Using geoid set: $(geoid_set_name)")
        # Use GeoIDs.get_geoid_set to get geoids from the database
        using GeoIDs
        try
            geoids = GeoIDs.get_geoid_set(geoid_set_name)
            println("Found $(length(geoids)) geoids in set '$(geoid_set_name)'")
        catch e
            error("Failed to get geoid set '$(geoid_set_name)': $(e)")
        end
    else
        println("Using geoid list provided")
        # Parse the comma-separated list
        geoids = split(geoid_list, ",")
        geoids = [strip(geoid) for geoid in geoids]
        println("Found $(length(geoids)) geoids in provided list")
    end
    
    if isempty(geoids)
        error("No geoids found to update")
    end
    
    # Connect to the database
    conn = LibPQ.Connection("dbname=tiger")
    println("Connected to database")
    
    # Check which geoids exist and don't have a nation set
    geoids_str = join(["'$geoid'" for geoid in geoids], ",")
    check_query = """
    SELECT geoid, name, stusps 
    FROM census.counties 
    WHERE geoid IN ($geoids_str) 
    AND nation IS NULL;
    """
    
    result = LibPQ.execute(conn, check_query)
    update_df = DataFrame(result)
    
    # Check which geoids already have a different nation set
    existing_query = """
    SELECT geoid, name, stusps, nation
    FROM census.counties 
    WHERE geoid IN ($geoids_str) 
    AND nation IS NOT NULL;
    """
    
    existing_result = LibPQ.execute(conn, existing_query)
    existing_df = DataFrame(existing_result)
    
    # Check which geoids don't exist in the table
    missing_geoids = setdiff(geoids, vcat(update_df.geoid, existing_df.geoid))
    
    # Display summary
    println("\nSummary of update operation:")
    println("----------------------------")
    println("Nation state to set: $nation_state")
    println("Total geoids specified: $(length(geoids))")
    println("Counties to update: $(nrow(update_df))")
    println("Counties already having a nation: $(nrow(existing_df))")
    println("Geoids not found in database: $(length(missing_geoids))")
    
    if verbose
        if !isempty(update_df)
            println("\nCounties to update:")
            for row in eachrow(update_df)
                println("  $(row.name), $(row.stusps) ($(row.geoid))")
            end
        end
        
        if !isempty(existing_df)
            println("\nCounties already having a nation:")
            for row in eachrow(existing_df)
                println("  $(row.name), $(row.stusps) ($(row.geoid)) - '$(row.nation)'")
            end
        end
        
        if !isempty(missing_geoids)
            println("\nGeoids not found in database:")
            for geoid in missing_geoids
                println("  $geoid")
            end
        end
    end
    
    # If there are counties to update and not a dry run, perform the update
    if !isempty(update_df) && !dry_run
        println("\nUpdating $(nrow(update_df)) counties to nation state '$nation_state'...")
        
        # Start a transaction
        LibPQ.execute(conn, "BEGIN;")
        
        try
            # Update the counties
            update_query = """
            UPDATE census.counties 
            SET nation = '$nation_state'
            WHERE geoid IN ($geoids_str)
            AND nation IS NULL;
            """
            
            update_result = LibPQ.execute(conn, update_query)
            affected_rows = LibPQ.num_affected_rows(update_result)
            
            # Commit the transaction
            LibPQ.execute(conn, "COMMIT;")
            
            println("Update completed successfully!")
            println("Updated $affected_rows counties to nation state '$nation_state'")
        catch e
            # Rollback on error
            LibPQ.execute(conn, "ROLLBACK;")
            println("Error during update: $e")
            println("No changes were made (transaction rolled back)")
        end
    elseif dry_run
        println("\nDRY RUN: No updates performed")
        println("Would have updated $(nrow(update_df)) counties to nation state '$nation_state'")
    else
        println("\nNo counties to update")
    end
    
    # Close connection
    LibPQ.close(conn)
    println("\nDone!")
end

main() 