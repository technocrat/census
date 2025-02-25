"""
   write_census_data(df::DataFrame, variable_name::String, conn) -> Nothing

Write census data to PostgreSQL database in the census schema's variable_data table.

# Arguments
- `df::DataFrame`: DataFrame containing census data with geoid, name, and value columns
- `variable_name::String`: Name of the census variable being stored 
- `conn`: LibPQ connection to PostgreSQL database

# Database Requirements
- Requires PostgreSQL database with schema 'census'
- Requires table census.counties with unique constraint on geoid field
- Creates table census.variable_data with foreign key to counties.geoid if it doesn't exist

# Effects
Inserts or updates records in census.variable_data table, using an upsert operation
on the primary key (geoid, variable_name).

# Example
```julia
conn = LibPQ.Connection("dbname=geocoder user=geo")
df = get_census_data("S0101_C01_001E", "total_population")
write_census_data(df, "total_population", conn)

# Census naming convention for subject tables
- ends in -C01_001E for county level estimates
- Begins with code for subject matter
"""
function write_census_data(df::DataFrame, variable_name::String, conn)
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS census.variable_data (
        geoid character varying(5) REFERENCES census.counties(geoid),
        variable_name VARCHAR(50),
        value BIGINT,
        name VARCHAR(100),
        PRIMARY KEY (geoid, variable_name)
    );
    """
    execute(conn, create_table_sql)
    
    for row in eachrow(df)
        upsert_sql = """
        INSERT INTO census.variable_data (geoid, variable_name, value, name)
        VALUES (\$1, \$2, \$3, \$4)
        ON CONFLICT (geoid, variable_name) 
        DO UPDATE SET value = EXCLUDED.value, name = EXCLUDED.name;
        """
        execute(conn, upsert_sql, [row.geoid, variable_name, row[variable_name], row.name])
    end
    
    return nothing
end

