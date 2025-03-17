# SPDX-License-Identifier: MIT

"""
        get_geo_pop(target_states::Vector{String})

Query geographic and population data for counties in the specified states.
Dependencies: DataFrame, LibPQ
# Arguments
- `target_states::Vector{String}`: A vector of two-letter state codes (e.g., ["OH", "MI"])

# Returns
- `DataFrame`: A DataFrame containing county geographic and population data with columns:
    - `geoid`: The geographic identifier for each county
    - `stusps`: The state code
    - `name`: The county name
    - `json_geom`: The geometry of the county as WKT (Well-Known Text)
    - `total_population`: The total population of the county

# Example
```julia
target_states = ["OH", "MI", "IN", "IL", "WI"]
midwest_counties = get_geo_pop(target_states)
function get_geo_pop(target_states::Vector{String})
    # Connect to database
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Prepare the query with parameter placeholder
    geo_query = """
        SELECT q.geoid, q.stusps, q.name, ST_AsText(q.geom) as json_geom, vd.value as total_population
        FROM census.counties q
        LEFT JOIN census.variable_data vd
            ON q.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        WHERE q.stusps = ANY(\$1)
    """
    
    # Execute the query with parameters
    result = execute(conn, geo_query, [target_states])
    
    # Process the result
    df = DataFrame(result)
    
    # Close the connection
    close(conn)
    
    return df
end
