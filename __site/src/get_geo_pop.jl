# SPDX-License-Identifier: MIT
"""
    get_geo_pop(target_states::Vector{PostalCode})
Query geographic and population data for counties in the specified states.

Dependencies: DataFrame, LibPQ

# Arguments
- `target_states::Vector{PostalCode}`: A vector of valid state postal codes (e.g., [PostalCode("OH"), PostalCode("MI")])

# Returns
- `DataFrame`: A DataFrame containing county geographic and population data with columns:
    - `geoid`: The geographic identifier for each county
    - `stusps`: The state code
    - `name`: The county name
    - `json_geom`: The geometry of the county as WKT (Well-Known Text)
    - `total_population`: The total population of the county

# Example
```julia
target_states = [PostalCode("OH"), PostalCode("MI"), PostalCode("IN"), PostalCode("IL"), PostalCode("WI")]
midwest_counties = get_geo_pop(target_states)
```
"""
function get_geo_pop(target_states::Vector{String})
    target_states = make_postal_codes(target_states)
    # Connect to database
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Convert PostalCode objects to their string values for the query
    state_codes = [pc.code for pc in target_states]
    
    # Prepare the query with parameter placeholder
    geo_query = """
        SELECT q.geoid, q.stusps, q.name, ST_AsText(q.geom) as geom, vd.value as total_population
        FROM census.counties q
        LEFT JOIN census.variable_data vd
            ON q.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        WHERE q.stusps = ANY(\$1)
    """
    
    # Execute the query with parameters
    result = execute(conn, geo_query, [state_codes])
    
    # Process the result
    df = DataFrame(result)
    
    # Close the connection
    close(conn)
    
    return df
end
