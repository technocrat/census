# SPDX-License-Identifier: MIT

"""
    init_census_data() -> DataFrame

Initialize census data by loading county-level information.

# Returns
- `DataFrame`: A DataFrame containing county data with the following columns:
  - `geoid::String`: FIPS code for the county
  - `stusps::String`: State postal code
  - `name::String`: County name
  - `geom::String`: WKT geometry string
  - `pop::Int`: Total population

# Example
```julia
us = init_census_data()
# Filter to specific state
ca = subset(us, :stusps => ByRow(==("CA")))
```

# Notes
- This function queries the census.counties and census.variable_data tables
- It uses a database connection from LibPQ
- Returns all counties in the United States with their population data
"""
function init_census_data()
    conn = LibPQ.Connection("dbname=tiger")
    
    query = """
        SELECT c.geoid, c.stusps, c.name, ST_AsText(c.geom) as geom, vd.value as pop
        FROM census.counties c
        LEFT JOIN census.variable_data vd
            ON c.geoid = vd.geoid
            AND vd.variable_name = 'total_population'
        ORDER BY c.geoid;
    """
    
    result = LibPQ.execute(conn, query)
    df = DataFrame(result)
    LibPQ.close(conn)
    return df
end 