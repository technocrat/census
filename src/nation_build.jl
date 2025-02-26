include("libr.jl)
include("q.jl")

us         = q(geo_query)
postals    = unique(sort!(us.stusps))
outliers   = ["PR","VI","GU","AS","MP"]
us         = filter(:stusps => x -> !(x in outliers), us)
conus      = filter(:stusps => x -> !(x in ["AK","HI"]), us)
concord    = ["CT", "MA", "ME", "NH", "RI", "VT"]
us.nation  = ifelse.(in.(us.stusps, Ref(concord)), "concord", missing)
metropolis = ["DE", "MD","NY","NJ","VA","DC"]
us.nation .= ifelse.(in.(us.stusps, Ref(metropolis)), "metropolis", us.nation)
factoria   = ["PA", "OH", "MI", "IN", "IL", "WI"]
us.nation .= ifelse.(in.(us.stusps, Ref(factoria)), "factoria", us.nation)
lonestar   = ["TX","OK","AR","LA"]
us.nation .= ifelse.(in.(us.stusps, Ref(lonestar)), "lonestar", us.nation)
dixie      = ["NC", "SC", "FL", "GA","MS","AL"]
us.nation .= ifelse.(in.(us.stusps, Ref(dixie)), "dixie", us.nation)
cumber     = ["WV","KY","TN"]
us.nation .= ifelse.(in.(us.stusps, Ref(cumber)), "cumber", us.nation)
heartland  = ["MN","IA","NE", "ND", "SD", "KS", "MO"]
us.nation .= ifelse.(in.(us.stusps, Ref(heartland)), "heartland", us.nation)
desert     = ["UT","MT","WY", "CO", "ID"]
us.nation .= ifelse.(in.(us.stusps, Ref(desert)), "desert", us.nation)
pacific     = ["WA","OR","AK"]
us.nation .= ifelse.(in.(us.stusps, Ref(pacific)), "pacific", us.nation)
sonora     = ["CA","AZ","NM","NV","HI"]
us.nation .= ifelse.(in.(us.stusps, Ref(sonora)), "sonora", us.nation)

"""
    update_census_counties_schema_and_write_data(df::DataFrame, variable_name::String, conn)
    
Add a 'nation' column to the census.counties table and write census data to the variable_data table.

# Arguments
- `df::DataFrame`: DataFrame containing census data with geoid, name, and variable data columns
- `variable_name::String`: Name of the variable being stored (e.g., "total_population")
- `conn`: PostgreSQL database connection object

# Returns
- `nothing`

# Side effects
- Alters the schema of census.counties to add a 'nation' column if it doesn't exist
- Populates the census.variable_data table with values from the DataFrame
- Updates the nation field in census.counties based on values in the DataFrame if provided

# Example
```julia
conn = LibPQ.Connection("postgresql://user:password@localhost/census_db")
update_census_counties_schema_and_write_data(us, "nation", "geocoder")
"""
function update_census_counties_schema_and_write_data(df::DataFrame, variable_name::String, conn)
    # First, add the nation column to the census.counties table if it doesn't exist
    alter_table_sql = raw"""
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'census' 
            AND table_name = 'counties' 
            AND column_name = 'nation'
        ) THEN
            ALTER TABLE census.counties 
            ADD COLUMN nation VARCHAR(100);
        END IF;
    END $$;
    """
    execute(conn, alter_table_sql)
    
    # Begin a transaction for all the operations
    execute(conn, "BEGIN;")
    
    try
        if variable_name == "nation"
            # Special handling for nation: update census.counties directly
            for row in eachrow(df)
                if !ismissing(row.nation)
                    update_nation_sql = """
                    UPDATE census.counties 
                    SET nation = \$1
                    WHERE geoid = \$2;
                    """
                    execute(conn, update_nation_sql, [row.nation, row.geoid])
                end
            end
        else
            # For non-nation variables (expected to be numeric)
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
        
        # Commit the transaction if everything succeeds
        execute(conn, "COMMIT;")
    catch e
        # Rollback on error
        execute(conn, "ROLLBACK;")
        rethrow(e)
    end
    
    return nothing
end
# First, create a proper connection object
conn = LibPQ.Connection("dbname=geocoder")

# Then call your function with the connection object
update_census_counties_schema_and_write_data(us, "nation", conn)