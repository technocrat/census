# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

using .CensusDB: execute, with_connection

"""
    write_census_data(df::DataFrame, variable_name::String)

Write census data to the variable_data table.

# Arguments
- `df::DataFrame`: DataFrame containing census data with geoid, name, and variable data columns
- `variable_name::String`: Name of the variable being stored (e.g., "total_population")

# Requirements
- Requires table census.counties with unique constraint on geoid field
- Creates table census.variable_data with foreign key to counties.geoid if it doesn't exist

# Side effects
Inserts or updates records in census.variable_data table, using an upsert operation

# Example
```julia
write_census_data(df, "total_population")
```
"""
function write_census_data(df::DataFrame, variable_name::String)
    with_connection() do conn
        # Create the variable_data table if it doesn't exist
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS census.variable_data (
            geoid character varying(5) REFERENCES census.counties(geoid),
            variable_name character varying(100),
            value numeric,
            name character varying(100),
            PRIMARY KEY (geoid, variable_name)
        );
        """
        execute(conn, create_table_sql)
        
        # Insert or update data
        for row in eachrow(df)
            upsert_sql = """
            INSERT INTO census.variable_data (geoid, variable_name, value, name)
            VALUES (\$1, \$2, \$3, \$4)
            ON CONFLICT (geoid, variable_name) 
            DO UPDATE SET value = EXCLUDED.value, name = EXCLUDED.name;
            """
            execute(conn, upsert_sql, [row.geoid, variable_name, row[variable_name], row.name])
        end
    end
    
    return nothing
end

