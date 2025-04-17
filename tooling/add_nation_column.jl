# SPDX-License-Identifier: MIT
# Script to add the 'nation' column to the census.counties table
# SCRIPT

using LibPQ
using DataFrames

function add_nation_column()
    # Connect to the tiger database
    conn = LibPQ.Connection("dbname=tiger")
    
    try
        # Check if the column exists
        query = """
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_schema = 'census' 
        AND table_name = 'counties' 
        AND column_name = 'nation';
        """
        
        result = LibPQ.execute(conn, query)
        df = DataFrame(result)
        
        has_nation_column = !isempty(df)
        
        if !has_nation_column
            println("Column 'nation' does not exist in tiger.census.counties table. Creating it now...")
            
            # Create the nation column
            alter_query = "ALTER TABLE census.counties ADD COLUMN nation VARCHAR(50);"
            LibPQ.execute(conn, alter_query)
            
            println("Column 'nation' created successfully.")
        else
            println("Column 'nation' already exists in tiger.census.counties table.")
        end
        
        # Add the nation state for Concordia
        concordia_query = """
        UPDATE census.counties SET nation = 'Concordia' 
        WHERE stusps IN ('ME', 'NH', 'VT', 'MA', 'CT', 'RI') 
        AND geoid NOT IN ('23003', '20029', '09160', '09190')
        OR geoid IN ('36019', '36031');
        """
        
        result = LibPQ.execute(conn, concordia_query)
        affected_rows = LibPQ.num_affected_rows(result)
        println("Updated $affected_rows counties with nation_state=Concordia")
        
    catch e
        println("Error: ", e)
        rethrow(e)
    finally
        # Close the connection
        LibPQ.close(conn)
    end
end

# Call the function to add the nation column
add_nation_column() 