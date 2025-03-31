using JSON
using LibPQ
using DataFrames

"""
    create_census_variables_table()

Create a PostgreSQL table for Census ACS 2023 variables.
"""
function create_census_variables_table()
    # Read the JSON file
    json_data = JSON.parsefile("data/census_acs_2023_variables.json")
    
    # Access the variables
    variables_dict = json_data["variables"]
    println("Found $(length(variables_dict)) variables")
    
    # Create DataFrame including attributes
    variables_df = DataFrame(
        variable_id = String[],
        label = Union{String, Nothing}[],
        concept = Union{String, Nothing}[],
        group = Union{String, Nothing}[],
        predicate_type = Union{String, Nothing}[],
        limit = Union{String, Nothing, Number}[],
        attributes = String[]
    )
    
    # Add rows with proper attributes handling
    for (var_id, var_info) in variables_dict
        # Handle attributes - ensure it's properly quoted JSON
        attributes_val = get(var_info, "attributes", nothing)
        attributes_json = if attributes_val !== nothing
            if isa(attributes_val, String)
                # If it's already a string, make sure it's properly quoted for JSON
                # Some attributes appear to be comma-separated variable IDs
                if occursin(r"^[A-Z0-9_,]+$", attributes_val)
                    # It's a comma-separated list - wrap in quotes to make valid JSON
                    "\"$(attributes_val)\""
                else
                    # Already JSON formatted?
                    attributes_val
                end
            else
                # Try to convert to JSON
                try
                    JSON.json(attributes_val)
                catch e
                    println("Error converting attributes for $var_id: $e")
                    "null"
                end
            end
        else
            "null"
        end
        
        # Get limit value and ensure it can be converted to string
        limit_val = get(var_info, "limit", nothing)
        if isa(limit_val, Number)
            limit_val = string(limit_val)
        end
        
        push!(variables_df, [
            var_id,
            get(var_info, "label", nothing),
            get(var_info, "concept", nothing),
            get(var_info, "group", nothing),
            get(var_info, "predicateType", nothing),
            limit_val,
            attributes_json
        ])
    end
    
    println("Added $(nrow(variables_df)) rows to DataFrame")
    
    # Connect to PostgreSQL
    conn = LibPQ.Connection("dbname=geocoder host=localhost port=5432")
    
    # Create table with attributes column
    execute(conn, """
        DROP TABLE IF EXISTS acs_2023_variables;
        
        CREATE TABLE acs_2023_variables (
            variable_id TEXT PRIMARY KEY,
            label TEXT,
            concept TEXT,
            group_name TEXT,
            predicate_type TEXT,
            limit_value TEXT,
            attributes TEXT
        )
    """)
    
    # Changed JSONB to TEXT for now to avoid JSON parsing issues
    
    # Process in batches
    batch_size = 1000
    total_processed = 0
    errors = 0
    
    for batch_start in 1:batch_size:nrow(variables_df)
        batch_end = min(batch_start + batch_size - 1, nrow(variables_df))
        batch = variables_df[batch_start:batch_end, :]
        
        for row in eachrow(batch)
            try
                execute(conn, """
                    INSERT INTO acs_2023_variables 
                    (variable_id, label, concept, group_name, predicate_type, limit_value, attributes)
                    VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
                """, [
                    row.variable_id,
                    row.label,
                    row.concept,
                    row.group,
                    row.predicate_type,
                    row.limit,
                    row.attributes
                ])
                
                total_processed += 1
            catch e
                errors += 1
                if errors <= 5  # Only show first few errors
                    println("Error inserting row with ID $(row.variable_id): $e")
                    println("Attributes value: $(row.attributes)")
                end
            end
        end
        
        println("Processed $total_processed rows (with $errors errors)")
    end
    
    # Verify
    result = execute(conn, "SELECT COUNT(*) FROM acs_2023_variables")
    count_df = DataFrame(result)
    println("Database count: $(count_df[1,1])")
    
    close(conn)
    println("Done!")
end

# Run the function
create_census_variables_table()