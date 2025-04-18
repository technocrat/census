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
    create_census_variables_table()

Create and populate the census.variables table with metadata about Census variables.

# Side effects
- Creates table census.variables if it doesn't exist
- Populates the table with variable metadata

# Example
```julia
create_census_variables_table()
```
"""
function create_census_variables_table()
    with_connection() do conn
        # Create the variables table if it doesn't exist
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS census.variables (
            variable_name character varying(100) PRIMARY KEY,
            description text,
            category character varying(100),
            subcategory character varying(100),
            source character varying(100),
            year integer,
            created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
        );
        """
        execute(conn, create_table_sql)
        
        # Insert initial variables
        variables = [
            ("total_population", "Total population", "Demographics", "Population", "ACS", 2022),
            ("median_age", "Median age", "Demographics", "Age", "ACS", 2022),
            ("median_household_income", "Median household income", "Economics", "Income", "ACS", 2022),
            ("poverty_rate", "Poverty rate", "Economics", "Poverty", "ACS", 2022),
            ("unemployment_rate", "Unemployment rate", "Economics", "Employment", "ACS", 2022),
            ("democratic", "Democratic votes in 2020 presidential election", "Politics", "Elections", "MIT Election Lab", 2020),
            ("republican", "Republican votes in 2020 presidential election", "Politics", "Elections", "MIT Election Lab", 2020)
        ]
        
        for (name, desc, cat, subcat, src, yr) in variables
            insert_sql = """
            INSERT INTO census.variables 
                (variable_name, description, category, subcategory, source, year)
            VALUES (\$1, \$2, \$3, \$4, \$5, \$6)
            ON CONFLICT (variable_name) DO NOTHING;
            """
            execute(conn, insert_sql, [name, desc, cat, subcat, src, yr])
        end
    end
    
    return nothing
end

# Run the function
create_census_variables_table()