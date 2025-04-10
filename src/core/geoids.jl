# SPDX-License-Identifier: MIT

using LibPQ
using DataFrames
using ArchGDAL

# Import CensusDB module and export from it
import ..Census.CensusDB

"""
    set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})

Store the geoids for a nation state in the database.

# Arguments
- `nation_state::String`: The name of the nation state
- `geoids::Union{Vector{String}, Vector{Union{Missing, String}}}`: Vector of geoids to associate with the nation state

# Notes
This function updates the `nation` column in the `census.counties` table.
This column stores the nation state value for each county.

# Example
```julia
set_nation_state_geoids("Powell", powell_geoids)
```
"""
function set_nation_state_geoids(nation_state::String, geoids::Union{Vector{String}, Vector{Union{Missing, String}}})
    try
        conn = LibPQ.Connection("dbname=tiger") 
        @info "Database connection established"
        
        # Check if the nation column exists in the tiger database's census.counties table
        result = LibPQ.execute(conn, "SELECT column_name FROM information_schema.columns WHERE table_schema = 'census' AND table_name = 'counties' AND column_name = 'nation';")
        has_nation_column = !isempty(DataFrame(result))
        
        if !has_nation_column
            @info "Column 'nation' does not exist in tiger.census.counties table. Creating it now..."
            LibPQ.execute(conn, "ALTER TABLE census.counties ADD COLUMN nation VARCHAR(50);")
            @info "Column 'nation' created successfully."
        end
        
        # Start a transaction
        LibPQ.execute(conn, "BEGIN;")
        
        # First, clear the nation for any counties that currently have it
        LibPQ.execute(conn, 
            "UPDATE census.counties SET nation = NULL WHERE nation = \$1;",
            [nation_state]
        )
        
        # Filter out missing values and convert to array
        valid_geoids = filter(!ismissing, collect(String, geoids))
        
        if !isempty(valid_geoids)
            # Then set the new nation for all specified counties in one query
            LibPQ.execute(conn, 
                "UPDATE census.counties SET nation = \$1 WHERE geoid = ANY(\$2::text[]);",
                [nation_state, valid_geoids]
            )
            
            # Log the number of rows updated - fixed to use position-based access
            count_result = LibPQ.execute(conn, 
                "SELECT COUNT(*) FROM census.counties WHERE nation = \$1;",
                [nation_state]
            )
            count_df = DataFrame(count_result)
            count = count_df[1, 1]  # Access first row, first column by position
            @info "Updated $count counties with nation_state=$nation_state in tiger database"
        end
        
        # Commit the transaction
        LibPQ.execute(conn, "COMMIT;")
        @info "Nation state data committed to database."
        
        # Close connection
        LibPQ.close(conn)
    catch e
        # Handle error and log
        @error "Error updating nation state in database:" exception=(e, catch_backtrace())
        rethrow(e)
    end
end

# Export only the set_nation_state_geoids function
export set_nation_state_geoids

module Geoids

using LibPQ
using DataFrames
import ...Census.CensusDB

"""
    get_geoid_by_state_county(state::String, county::String)

Get the GEOID for a specific state and county combination.
"""
function get_geoid_by_state_county(state::String, county::String)
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid FROM counties 
        WHERE state = \$1 AND county = \$2;
        """
        df = CensusDB.execute(conn, query, [state, county])
        return isempty(df) ? nothing : df[1, :geoid]
    end
end

"""
    get_state_county_by_geoid(geoid::String)

Get the state and county names for a specific GEOID.
"""
function get_state_county_by_geoid(geoid::String)
    CensusDB.with_connection() do conn
        query = """
        SELECT state, county FROM counties 
        WHERE geoid = \$1;
        """
        df = CensusDB.execute(conn, query, [geoid])
        return isempty(df) ? nothing : (df[1, :state], df[1, :county])
    end
end

"""
    get_geoids_by_state(state::String)

Get all GEOIDs for a specific state.
"""
function get_geoids_by_state(state::String)
    CensusDB.with_connection() do conn
        query = """
        SELECT geoid FROM counties 
        WHERE state = \$1 
        ORDER BY geoid;
        """
        df = CensusDB.execute(conn, query, [state])
        return df.geoid
    end
end

end # module Geoids