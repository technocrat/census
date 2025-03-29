# SPDX-License-Identifier: MIT

# Import get_db_connection from parent module
import ..Census: get_db_connection

"""
    get_western_geoids() -> Vector{String}

Returns GEOIDs for counties west of 100°W longitude and east of 115°W longitude
to get the high plains counties with historically low rainfall
(< 20 inches per year) requiring irrigation.
"""
function get_western_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM Census.counties
    WHERE ST_X(ST_Centroid(geom)) < $EASTERN_BOUNDARY
    AND ST_X(ST_Centroid(geom)) > $WESTERN_BOUNDARY
    ORDER BY lon;
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_eastern_geoids() -> Vector{String}

Returns GEOIDs for counties between 90°W and 100°W longitude
to get the eastern counties with historically highlighters rainfall 
(> 20 inches per year) not requiring irrigation.
"""
function get_eastern_geoids()
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM Census.counties
    WHERE ST_X(ST_Centroid(geom)) > -100
    AND ST_X(ST_Centroid(geom)) < -90
    ORDER BY lon;
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_utah_geoids() -> Vector{String}

Returns GEOIDs for counties east of Utah's border (109°W longitude).
"""
function get_east_of_utah_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM Census.counties
    WHERE ST_X(ST_Centroid(geom)) > $UTAH_BORDER
    ORDER BY lon;
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_east_of_cascade_geoids()::Vector{String}

Returns GEOIDs for counties between 115°W and 120°W longitude—used to get
trans-Cascade counties of WA and OR.
"""
function get_east_of_cascade_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    SELECT geoid, name, stusps, ST_X(ST_Centroid(geom)) as lon
    FROM census.counties
    WHERE ST_X(ST_Centroid(geom)) BETWEEN $SLOPE_WEST AND $SLOPE_EAST
    ORDER BY lon;
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_southern_kansas_geoids() -> Vector{String}

Returns GEOIDs for Kansas counties south of Osage County, an approximate
boundary for the Missouri Basin
"""
function get_southern_kansas_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM Census.counties WHERE geoid = '20167'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM Census.counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_Y(ST_Centroid(c.geom)) < ST_Y(ST_Centroid(o.geom))  -- South of Osage County
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_northern_kansas_geoids() -> Vector{String}

Returns GEOIDs for Kansas counties north of Osage County, an approximate
boundary for the Missouri Basin
"""
function get_northern_kansas_geoids()::Vector{String}
    conn = get_db_connection()
    query = """
    WITH osage AS (
        SELECT geom FROM Census.counties WHERE geoid = '20167'
    )
    SELECT c.geoid, c.name, c.stusps
    FROM Census.counties c, osage o
    WHERE c.stusps = 'KS'
    AND ST_Y(ST_Centroid(c.geom)) > ST_Y(ST_Centroid(o.geom))  -- North of Osage County
    ORDER BY ST_Distance(c.geom, o.geom);
    """
    result = execute(conn, query)
    close(conn)
    return DataFrame(result).geoid
end

"""
    get_colorado_basin_geoids()::Vector{String}

Extracts GEOID values from the Colorado River Basin county boundaries shapefile.
Colorado Basin boundaries https://coloradoriverbasin-lincolninstitute.hub.arcgis.com/datasets/a922a3809058416b8260813e822f8980_0/explore?location=36.663436%2C-110.573590%2C5.51
Returns a vector of GEOID strings.
"""
function get_colorado_basin_geoids()::Vector{String}
    shapefile_path = joinpath(dirname(@__DIR__), "..", "data", "Colorado_River_Basin_County_Boundaries")

    # Read the shapefile
    dataset = ArchGDAL.read(shapefile_path)

    # Extract GEOIDs from the feature layer
    layer = ArchGDAL.getlayer(dataset, 0)
    geoids = String[]

    for feature in layer
        geoid = ArchGDAL.getfield(feature, "GEOID")
        push!(geoids, geoid)
    end

    ArchGDAL.destroy(dataset)
    return sort(unique(geoids))
end

"""
Get Missouri county geoids that are north of St. Charles County and east of Schuyler County,
plus Schuyler and Adair counties, which drain into the Mississippi River.
"""
function get_ne_missouri_geoids()::Vector{String}
    query = """
    WITH reference_counties AS (
        SELECT 
            geom as schuyler_geom,
            ST_XMin(geom) as schuyler_west
        FROM census.counties 
        WHERE name = 'Schuyler' AND stusps = 'MO'
    ),
    st_charles AS (
        SELECT ST_YMax(geom) as st_charles_north
        FROM census.counties 
        WHERE name = 'St. Charles' AND stusps = 'MO'
    )
    SELECT DISTINCT c.geoid, c.name
    FROM census.counties c, reference_counties r, st_charles s
    WHERE c.stusps = 'MO'
    AND (
        -- Include Schuyler and Adair counties regardless of position
        c.name IN ('Schuyler', 'Adair')
        OR (
            -- All other counties must be north of St. Charles and east of Schuyler
            ST_YMin(c.geom) > s.st_charles_north  -- North of St. Charles
            AND ST_XMin(c.geom) > r.schuyler_west  -- East of Schuyler
        )
    )
    ORDER BY c.name;
    """

    conn = get_db_connection()
    result = DataFrame(execute(conn, query))
    close(conn)
    return result.geoid
end

"""
Get Missouri counties that are south of Perry County's southern boundary,
excluding Vernon, Cedar, Polk, Dallas, Webster, Laclede, Wright, Texas, Dent 
and Iron counties, which generally do not drain into the Missouri River.
"""
function get_southern_missouri_geoids()::Vector{String}
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

    conn = get_db_connection()
    result = execute(conn, query)
    close(conn)

    DataFrame(result).geoid
end

function get_northern_missouri_geoids()::Vector{String}
    setdiff(get_geo_pop(["MO"]).geoid, get_southern_missouri_geoids())
end

"""
Get Missouri River Basin county geoids by combining northern and southern Missouri counties,
excluding those that drain into the Mississippi River.
"""
function get_missouri_river_basin_geoids()::Vector{String}
    # Get all Missouri counties
    all_mo = get_geo_pop(["MO"]).geoid
    
    # Get counties that drain into the Mississippi
    mississippi_counties = get_ne_missouri_geoids()
    
    # Get counties that don't drain into the Missouri
    non_missouri_counties = get_southern_missouri_geoids()
    
    # The Missouri River Basin counties are all Missouri counties
    # minus those that drain into the Mississippi
    # minus those that don't drain into the Missouri
    return setdiff(all_mo, mississippi_counties, non_missouri_counties)
end

# Define static geoid sets
const east_of_sierras_geoids = ["06049", "06035", "06051", "06027"]
