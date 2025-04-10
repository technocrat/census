# SPDX-License-Identifier: MIT

"""
Census initialization functions.
"""

using DataFrames
using .CensusDB: execute, with_connection

"""
    init_census_data() -> DataFrame

Initialize census data by loading county-level information.

# Returns
- `DataFrame`: A DataFrame containing county data with the following columns:
  - `geoid::String`: FIPS code for the county
  - `stusps::String`: State postal code
  - `county::String`: County name (renamed from 'name')
  - `nation::Union{String, Missing}`: Nation state assignment (if any)
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
- It uses a database connection from CensusDB module
- Returns all counties in the United States with their population data
- Automatically renames the 'name' column to 'county' for consistency
"""
function init_census_data()
    result = with_connection() do conn
        query = """
            SELECT c.geoid, c.stusps, c.name, c.nation, ST_AsText(c.geom) as geom, vd.value as pop
            FROM census.counties c
            LEFT JOIN census.variable_data vd
                ON c.geoid = vd.geoid
                AND vd.variable_name = 'total_population'
            ORDER BY c.geoid;
        """
        execute(conn, query)
    end
    
    df = DataFrame(result)
    # Rename 'name' column to 'county'
    rename!(df, :name => :county)
    
    return df
end

# Export the initialization function
export init_census_data 