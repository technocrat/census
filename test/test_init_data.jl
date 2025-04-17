# SPDX-License-Identifier: MIT

# This script demonstrates how to initialize census data without using the Census.init_census_data function
using DataFrames
using LibPQ
using DataFramesMeta
using Census

# Define a local version of the function
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

# Use the function
println("Initializing census data...")
us = init_census_data()
println("Census data loaded: $(nrow(us)) rows")

# Run some basic operations
println("\nRunning some basic operations:")

println("Getting Connecticut data...")
ct = subset(us, :stusps => ByRow(==("CT")))
println("Connecticut counties: $(nrow(ct))")

println("Getting Maine data...")
me = subset(us, :stusps => ByRow(==("ME")))
println("Maine counties: $(nrow(me))")

println("Getting Massachusetts data...")
ma = subset(us, :stusps => ByRow(==("MA")))
println("Massachusetts counties: $(nrow(ma))")

println("\nAll operations completed successfully!") 