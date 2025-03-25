"""
Get Kansas counties south of Osage County (20167) using centroid comparison
"""
function get_southern_kansas_geoids()
    query = """
    WITH osage_centroid AS (
        SELECT ST_Y(ST_Centroid(geom)) as ref_lat 
        FROM census.counties 
        WHERE geoid = '20167'
    )
    SELECT c.geoid 
    FROM census.counties c, osage_centroid o
    WHERE c.stusps = 'KS' 
    AND ST_Y(ST_Centroid(c.geom)) < o.ref_lat
    ORDER BY geoid;
    """
    
    conn = LibPQ.Connection("dbname=geocoder")
    result = execute(conn, query)
    close(conn)
    
    DataFrame(result)
end
