"""
Get Missouri counties that are south of Perry County's southern boundary,
excluding Vernon, Cedar, Polk, Dallas, Webster, Laclede, Wright, Texas, Dent and Iron counties.
Returns a vector of geoids.
"""
function get_southern_missouri_counties()
    query = """
    WITH perry_boundary AS (
        SELECT ST_YMin(ST_Envelope(geom)) as southern_boundary
        FROM census.counties 
        WHERE name = 'Perry' AND stusps = 'MO'
    )
    SELECT c.geoid, c.name
    FROM census.counties c, perry_boundary p
    WHERE c.stusps = 'MO'
    AND ST_Y(ST_Centroid(c.geom)) < p.southern_boundary
    AND c.name NOT IN ('Vernon', 'Cedar', 'Polk', 'Dallas', 'Webster', 
                      'Laclede', 'Wright', 'Texas', 'Dent', 'Iron', 
                      'Washington', 'St. Francois', 'St. Louis') 
    ORDER BY c.name;
    """
    
    conn = LibPQ.Connection("dbname=geocoder")
    result = execute(conn, query)
    close(conn)
    
    return DataFrame(result).geoid
end 

function get_northern_missouri_counties()
    setdiff(get_geo_pop(["MO"]).geoid, get_southern_missouri_counties())
end