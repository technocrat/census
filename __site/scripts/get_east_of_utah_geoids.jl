function get_east_of_utah_geoids(; host="localhost", port=5432, dbname="geocoder")
    # Connect to PostgreSQL
    conn = LibPQ.Connection("dbname=geocoder")
    
    # Query for geoids from census.counties west of 109W longitude
    query = """
    SELECT geoid, stusps, name
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) > -109.0 
    ORDER BY geoid;
    """
    
    # Execute query and convert to DataFrame
    result = execute(conn, query)
    df = DataFrame(result)
    
    close(conn)
    return df
end
